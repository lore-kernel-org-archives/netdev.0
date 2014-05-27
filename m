From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] ixgbe: separate the PTP suspend and stop actions
Date: Tue, 27 May 2014 02:12:22 -0700
Message-ID: <1401181951-31358-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbaE0JMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:41 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since we are adding proper support for suspend of PTP, extract out of
ixgbe_ptp_stop those things relevant to suspend. Then, have
ixgbe_ptp_stop call ixgbe_ptp_suspend. The next patch in the series will
have ixgbe_ptp_suspend called from the ixgbe_suspend path.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h     |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 31 +++++++++++++++++++++-------
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 4c0203b..ac9f214 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -957,6 +957,7 @@ static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
 }
 
 void ixgbe_ptp_init(struct ixgbe_adapter *adapter);
+void ixgbe_ptp_suspend(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_stop(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_overflow_check(struct ixgbe_adapter *adapter);
 void ixgbe_ptp_rx_hang(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 9df7e57..b3266b7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -960,28 +960,45 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_ptp_stop - disable ptp device and stop the overflow check
- * @adapter: pointer to adapter struct
+ * ixgbe_ptp_suspend - stop PTP work items
+ * @ adapter: pointer to adapter struct
  *
- * this function stops the ptp support, and cancels the delayed work.
+ * this function suspends PTP activity, and prevents more PTP work from being
+ * generated, but does not destroy the PTP clock device.
  */
-void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
+void ixgbe_ptp_suspend(struct ixgbe_adapter *adapter)
 {
 	/* Leave the IXGBE_PTP_RUNNING state. */
 	if (!test_and_clear_bit(__IXGBE_PTP_RUNNING, &adapter->state))
 		return;
 
-	/* stop the PPS signal */
-	adapter->flags2 &= ~IXGBE_FLAG2_PTP_PPS_ENABLED;
-	ixgbe_ptp_setup_sdp(adapter);
+	/* since this might be called in suspend, we don't clear the state,
+	 * but simply reset the auxiliary PPS signal control register
+	 */
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TSAUXC, 0x0);
 
+	/* ensure that we cancel any pending PTP Tx work item in progress */
 	cancel_work_sync(&adapter->ptp_tx_work);
 	if (adapter->ptp_tx_skb) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
 		clear_bit_unlock(__IXGBE_PTP_TX_IN_PROGRESS, &adapter->state);
 	}
+}
+
+/**
+ * ixgbe_ptp_stop - close the PTP device
+ * @adapter: pointer to adapter struct
+ *
+ * completely destroy the PTP device, should only be called when the device is
+ * being fully closed.
+ */
+void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
+{
+	/* first, suspend PTP activity */
+	ixgbe_ptp_suspend(adapter);
 
+	/* disable the PTP clock device */
 	if (adapter->ptp_clock) {
 		ptp_clock_unregister(adapter->ptp_clock);
 		adapter->ptp_clock = NULL;
-- 
1.9.3
