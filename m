From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] igb: implement SIOCGHWTSTAMP ioctl
Date: Fri, 21 Mar 2014 05:10:01 -0700
Message-ID: <1395403806-29302-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15007 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965514AbaCUMKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:14 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds support for the SIOCGHWTSTAMP ioctl which enables user
processes to read the current hwtstamp_config settings
non-destructively. Previously a process had to be privileged and could
only set values, it couldn't return what is currently set without
possibly overwriting the value.

This patch adds support for this new operation into igb by keeping a
shadow copy of the config in the adapter structure, which is returned
upon request.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |  5 ++--
 drivers/net/ethernet/intel/igb/igb_main.c |  4 ++-
 drivers/net/ethernet/intel/igb/igb_ptp.c  | 46 +++++++++++++++++++++----------
 3 files changed, 38 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index a202c96..411b213 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -434,6 +434,7 @@ struct igb_adapter {
 	struct delayed_work ptp_overflow_work;
 	struct work_struct ptp_tx_work;
 	struct sk_buff *ptp_tx_skb;
+	struct hwtstamp_config tstamp_config;
 	unsigned long ptp_tx_start;
 	unsigned long last_rx_ptp_check;
 	spinlock_t tmreg_lock;
@@ -545,8 +546,8 @@ static inline void igb_ptp_rx_hwtstamp(struct igb_ring *rx_ring,
 	rx_ring->last_rx_timestamp = jiffies;
 }
 
-int igb_ptp_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr,
-			   int cmd);
+int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
+int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
 #ifdef CONFIG_IGB_HWMON
 void igb_sysfs_exit(struct igb_adapter *adapter);
 int igb_sysfs_init(struct igb_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 17feea0..f623e6c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7162,8 +7162,10 @@ static int igb_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
 		return igb_mii_ioctl(netdev, ifr, cmd);
+	case SIOCGHWTSTAMP:
+		return igb_ptp_get_ts_config(netdev, ifr);
 	case SIOCSHWTSTAMP:
-		return igb_ptp_hwtstamp_ioctl(netdev, ifr, cmd);
+		return igb_ptp_set_ts_config(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index a894551a..da55fbb 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -541,10 +541,26 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 }
 
 /**
- * igb_ptp_hwtstamp_ioctl - control hardware time stamping
+ * igb_ptp_get_ts_config - get hardware time stamping config
+ * @netdev:
+ * @ifreq:
+ *
+ * Get the hwtstamp_config settings to return to the user. Rather than attempt
+ * to deconstruct the settings from the registers, just return a shadow copy
+ * of the last known settings.
+ **/
+int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct hwtstamp_config *config = &adapter->tstamp_config;
+
+	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
+		-EFAULT : 0;
+}
+/**
+ * igb_ptp_set_ts_config - control hardware time stamping
  * @netdev:
  * @ifreq:
- * @cmd:
  *
  * Outgoing time stamping can be enabled and disabled. Play nice and
  * disable it when requested, although it shouldn't case any overhead
@@ -558,12 +574,11 @@ void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
  * not supported, with the exception of "all V2 events regardless of
  * level 2 or 4".
  **/
-int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
-			   struct ifreq *ifr, int cmd)
+int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct hwtstamp_config config;
+	struct hwtstamp_config *config = &adapter->tstamp_config;
 	u32 tsync_tx_ctl = E1000_TSYNCTXCTL_ENABLED;
 	u32 tsync_rx_ctl = E1000_TSYNCRXCTL_ENABLED;
 	u32 tsync_rx_cfg = 0;
@@ -571,14 +586,14 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	bool is_l2 = false;
 	u32 regval;
 
-	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+	if (copy_from_user(config, ifr->ifr_data, sizeof(*config)))
 		return -EFAULT;
 
 	/* reserved for future extensions */
-	if (config.flags)
+	if (config->flags)
 		return -EINVAL;
 
-	switch (config.tx_type) {
+	switch (config->tx_type) {
 	case HWTSTAMP_TX_OFF:
 		tsync_tx_ctl = 0;
 	case HWTSTAMP_TX_ON:
@@ -587,7 +602,7 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 		return -ERANGE;
 	}
 
-	switch (config.rx_filter) {
+	switch (config->rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		tsync_rx_ctl = 0;
 		break;
@@ -611,7 +626,7 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
 		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_EVENT_V2;
-		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		is_l2 = true;
 		is_l4 = true;
 		break;
@@ -622,12 +637,12 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 		 */
 		if (hw->mac.type != e1000_82576) {
 			tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_ALL;
-			config.rx_filter = HWTSTAMP_FILTER_ALL;
+			config->rx_filter = HWTSTAMP_FILTER_ALL;
 			break;
 		}
 		/* fall through */
 	default:
-		config.rx_filter = HWTSTAMP_FILTER_NONE;
+		config->rx_filter = HWTSTAMP_FILTER_NONE;
 		return -ERANGE;
 	}
 
@@ -644,7 +659,7 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	if ((hw->mac.type >= e1000_82580) && tsync_rx_ctl) {
 		tsync_rx_ctl = E1000_TSYNCRXCTL_ENABLED;
 		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_ALL;
-		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		config->rx_filter = HWTSTAMP_FILTER_ALL;
 		is_l2 = true;
 		is_l4 = true;
 
@@ -708,7 +723,7 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	regval = rd32(E1000_RXSTMPL);
 	regval = rd32(E1000_RXSTMPH);
 
-	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
 		-EFAULT : 0;
 }
 
@@ -865,6 +880,9 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	if (!(adapter->flags & IGB_FLAG_PTP))
 		return;
 
+	/* reset the tstamp_config */
+	memset(&adapter->tstamp_config, 0, sizeof(adapter->tstamp_config));
+
 	switch (adapter->hw.mac.type) {
 	case e1000_82576:
 		/* Dial the nominal frequency. */
-- 
1.8.3.1
