From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] igb: separate hardware setting from the set_ts_config ioctl
Date: Wed, 11 Jun 2014 09:33:11 -0700
Message-ID: <1402504404-8954-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55587 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755686AbaFKQd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:28 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch separates the hardware logic from the set function, so that
we can re-use it during a ptp_reset. This enables the reset to return
functionality to the last known timestamp mode, rather than resetting
the value. We initialize the mode to off during the ptp_init cycle.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 50 ++++++++++++++++++++++++--------
 1 file changed, 38 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index e291be2..794c139 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -559,10 +559,11 @@ int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr)
 	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
 		-EFAULT : 0;
 }
+
 /**
- * igb_ptp_set_ts_config - control hardware time stamping
- * @netdev:
- * @ifreq:
+ * igb_ptp_set_timestamp_mode - setup hardware for timestamping
+ * @adapter: networking device structure
+ * @config: hwtstamp configuration
  *
  * Outgoing time stamping can be enabled and disabled. Play nice and
  * disable it when requested, although it shouldn't case any overhead
@@ -575,12 +576,11 @@ int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr)
  * type has to be specified. Matching the kind of event packet is
  * not supported, with the exception of "all V2 events regardless of
  * level 2 or 4".
- **/
-int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
+ */
+static int igb_ptp_set_timestamp_mode(struct igb_adapter *adapter,
+				      struct hwtstamp_config *config)
 {
-	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct hwtstamp_config *config = &adapter->tstamp_config;
 	u32 tsync_tx_ctl = E1000_TSYNCTXCTL_ENABLED;
 	u32 tsync_rx_ctl = E1000_TSYNCRXCTL_ENABLED;
 	u32 tsync_rx_cfg = 0;
@@ -588,9 +588,6 @@ int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
 	bool is_l2 = false;
 	u32 regval;
 
-	if (copy_from_user(config, ifr->ifr_data, sizeof(*config)))
-		return -EFAULT;
-
 	/* reserved for future extensions */
 	if (config->flags)
 		return -EINVAL;
@@ -725,7 +722,33 @@ int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
 	regval = rd32(E1000_RXSTMPL);
 	regval = rd32(E1000_RXSTMPH);
 
-	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
+	return 0;
+}
+
+/**
+ * igb_ptp_set_ts_config - set hardware time stamping config
+ * @netdev:
+ * @ifreq:
+ *
+ **/
+int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct hwtstamp_config config;
+	int err;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	err = igb_ptp_set_timestamp_mode(adapter, &config);
+	if (err)
+		return err;
+
+	/* save these settings for future reference */
+	memcpy(&adapter->tstamp_config, &config,
+	       sizeof(adapter->tstamp_config));
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
 		-EFAULT : 0;
 }
 
@@ -820,6 +843,9 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		wr32(E1000_IMS, E1000_IMS_TS);
 	}
 
+	adapter->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
+	adapter->tstamp_config.tx_type = HWTSTAMP_TX_OFF;
+
 	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
 						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
@@ -884,7 +910,7 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 		return;
 
 	/* reset the tstamp_config */
-	memset(&adapter->tstamp_config, 0, sizeof(adapter->tstamp_config));
+	igb_ptp_set_timestamp_mode(adapter, &adapter->tstamp_config);
 
 	switch (adapter->hw.mac.type) {
 	case e1000_82576:
-- 
1.9.3
