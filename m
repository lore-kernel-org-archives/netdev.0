From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/5] ixgbe: implement SIOCGHWTSTAMP ioctl
Date: Thu, 13 Feb 2014 00:00:47 -0800
Message-ID: <1392278450-27062-3-git-send-email-aaron.f.brown@intel.com>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61219 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753054AbaBMIDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 03:03:11 -0500
In-Reply-To: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds support for the new SIOCGHWTSTAMP ioctl, which enables
a process to determine the current timestamp configuration. In order to
implement this, store a copy of the timestamp configuration. In addition,
we can remove the 'int cmd' parameter as the new set_ts_config function
doesn't use it. I also fixed a typo in the function description.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  5 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  4 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 35 +++++++++++++++++----------
 3 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 0186ea2..d7c7f13 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -765,6 +765,7 @@ struct ixgbe_adapter {
 	struct ptp_clock_info ptp_caps;
 	struct work_struct ptp_tx_work;
 	struct sk_buff *ptp_tx_skb;
+	struct hwtstamp_config tstamp_config;
 	unsigned long ptp_tx_start;
 	unsigned long last_overflow_check;
 	unsigned long last_rx_ptp_check;
@@ -958,8 +959,8 @@ static inline void ixgbe_ptp_rx_hwtstamp(struct ixgbe_ring *rx_ring,
 	rx_ring->last_rx_timestamp = jiffies;
 }
 
-int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter, struct ifreq *ifr,
-			     int cmd);
+int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr);
+int ixgbe_ptp_get_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr);
 void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_reset(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7824559..84ca49b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7149,7 +7149,9 @@ static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
 
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return ixgbe_ptp_hwtstamp_ioctl(adapter, req, cmd);
+		return ixgbe_ptp_set_ts_config(adapter, req);
+	case SIOCGHWTSTAMP:
+		return ixgbe_ptp_get_ts_config(adapter, req);
 	default:
 		return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 5184e2a..95ed8ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -576,14 +576,21 @@ void __ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
 	shhwtstamps->hwtstamp = ns_to_ktime(ns);
 }
 
+int ixgbe_ptp_get_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
+{
+	struct hwtstamp_config *config = &adapter->tstamp_config;
+
+	return copy_to_user(ifr->ifr_data, config,
+			    sizeof(*config)) ? -EFAULT : 0;
+}
+
 /**
- * ixgbe_ptp_hwtstamp_ioctl - control hardware time stamping
+ * ixgbe_ptp_set_ts_config - control hardware time stamping
  * @adapter: pointer to adapter struct
  * @ifreq: ioctl data
- * @cmd: particular ioctl requested
  *
  * Outgoing time stamping can be enabled and disabled. Play nice and
- * disable it when requested, although it shouldn't case any overhead
+ * disable it when requested, although it shouldn't cause any overhead
  * when no packet needs it. At most one packet in the queue may be
  * marked for time stamping, otherwise it would be impossible to tell
  * for sure to which packet the hardware time stamp belongs.
@@ -599,25 +606,24 @@ void __ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
  * Event mode. This more accurately tells the user what the hardware is going
  * to do anyways.
  */
-int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
-			     struct ifreq *ifr, int cmd)
+int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct hwtstamp_config config;
+	struct hwtstamp_config *config = &adapter->tstamp_config;
 	u32 tsync_tx_ctl = IXGBE_TSYNCTXCTL_ENABLED;
 	u32 tsync_rx_ctl = IXGBE_TSYNCRXCTL_ENABLED;
 	u32 tsync_rx_mtrl = PTP_EV_PORT << 16;
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
@@ -626,7 +632,7 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 		return -ERANGE;
 	}
 
-	switch (config.rx_filter) {
+	switch (config->rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		tsync_rx_ctl = 0;
 		tsync_rx_mtrl = 0;
@@ -650,7 +656,7 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_EVENT_V2;
 		is_l2 = true;
-		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
 	case HWTSTAMP_FILTER_ALL:
@@ -661,7 +667,7 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 		 * Delay_Req messages and hardware does not support
 		 * timestamping all packets => return error
 		 */
-		config.rx_filter = HWTSTAMP_FILTER_NONE;
+		config->rx_filter = HWTSTAMP_FILTER_NONE;
 		return -ERANGE;
 	}
 
@@ -702,7 +708,7 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 	regval = IXGBE_READ_REG(hw, IXGBE_TXSTMPH);
 	regval = IXGBE_READ_REG(hw, IXGBE_RXSTMPH);
 
-	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
 		-EFAULT : 0;
 }
 
@@ -809,6 +815,9 @@ void ixgbe_ptp_reset(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_SYSTIMH, 0x00000000);
 	IXGBE_WRITE_FLUSH(hw);
 
+	/* Reset the saved tstamp_config */
+	memset(&adapter->tstamp_config, 0, sizeof(adapter->tstamp_config));
+
 	ixgbe_ptp_start_cyclecounter(adapter);
 
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
-- 
1.8.5.GIT
