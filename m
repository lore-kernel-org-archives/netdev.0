From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] ixgbe: extract the hardware setup from the ixgbe_ptp_set_ts_config
Date: Tue, 27 May 2014 02:12:19 -0700
Message-ID: <1401181951-31358-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbaE0JMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:37 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Currently all of the hardware setup logic for the PTP hardware bits is
buried inside of the ioctl which sets the timestamp configuration. This
makes it hard to use this logic in other places (primarily reset), and
this means we can't restore current timestamp mode upon a MAC reset.
Extracting this logic into a separate function will enable future work
for the ixgbe_ptp_reset function.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 50 ++++++++++++++++++++--------
 1 file changed, 36 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 1a88609..5a75dd5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -570,9 +570,9 @@ int ixgbe_ptp_get_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
 }
 
 /**
- * ixgbe_ptp_set_ts_config - control hardware time stamping
- * @adapter: pointer to adapter struct
- * @ifreq: ioctl data
+ * ixgbe_ptp_set_timestamp_mode - setup the hardware for the requested mode
+ * @adapter: the private ixgbe adapter structure
+ * @config: the hwtstamp configuration requested
  *
  * Outgoing time stamping can be enabled and disabled. Play nice and
  * disable it when requested, although it shouldn't cause any overhead
@@ -590,25 +590,25 @@ int ixgbe_ptp_get_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
  * packets, regardless of the type specified in the register, only use V2
  * Event mode. This more accurately tells the user what the hardware is going
  * to do anyways.
+ *
+ * Note: this may modify the hwtstamp configuration towards a more general
+ * mode, if required to support the specifically requested mode.
  */
-int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
+static int ixgbe_ptp_set_timestamp_mode(struct ixgbe_adapter *adapter,
+				 struct hwtstamp_config *config)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct hwtstamp_config config;
 	u32 tsync_tx_ctl = IXGBE_TSYNCTXCTL_ENABLED;
 	u32 tsync_rx_ctl = IXGBE_TSYNCRXCTL_ENABLED;
 	u32 tsync_rx_mtrl = PTP_EV_PORT << 16;
 	bool is_l2 = false;
 	u32 regval;
 
-	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
-		return -EFAULT;
-
 	/* reserved for future extensions */
-	if (config.flags)
+	if (config->flags)
 		return -EINVAL;
 
-	switch (config.tx_type) {
+	switch (config->tx_type) {
 	case HWTSTAMP_TX_OFF:
 		tsync_tx_ctl = 0;
 	case HWTSTAMP_TX_ON:
@@ -617,7 +617,7 @@ int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
 		return -ERANGE;
 	}
 
-	switch (config.rx_filter) {
+	switch (config->rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		tsync_rx_ctl = 0;
 		tsync_rx_mtrl = 0;
@@ -641,7 +641,7 @@ int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_EVENT_V2;
 		is_l2 = true;
-		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
 	case HWTSTAMP_FILTER_ALL:
@@ -652,7 +652,7 @@ int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
 		 * Delay_Req messages and hardware does not support
 		 * timestamping all packets => return error
 		 */
-		config.rx_filter = HWTSTAMP_FILTER_NONE;
+		config->rx_filter = HWTSTAMP_FILTER_NONE;
 		return -ERANGE;
 	}
 
@@ -671,7 +671,6 @@ int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
 	else
 		IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_1588), 0);
 
-
 	/* enable/disable TX */
 	regval = IXGBE_READ_REG(hw, IXGBE_TSYNCTXCTL);
 	regval &= ~IXGBE_TSYNCTXCTL_ENABLED;
@@ -693,6 +692,29 @@ int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
 	regval = IXGBE_READ_REG(hw, IXGBE_TXSTMPH);
 	regval = IXGBE_READ_REG(hw, IXGBE_RXSTMPH);
 
+	return 0;
+}
+
+/**
+ * ixgbe_ptp_set_ts_config - user entry point for timestamp mode
+ * @adapter: pointer to adapter struct
+ * @ifreq: ioctl data
+ *
+ * Set hardware to requested mode. If unsupported, return an error with no
+ * changes. Otherwise, store the mode for future reference.
+ */
+int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq *ifr)
+{
+	struct hwtstamp_config config;
+	int err;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	err = ixgbe_ptp_set_timestamp_mode(adapter, &config);
+	if (err)
+		return err;
+
 	/* save these settings for future reference */
 	memcpy(&adapter->tstamp_config, &config,
 	       sizeof(adapter->tstamp_config));
-- 
1.9.3
