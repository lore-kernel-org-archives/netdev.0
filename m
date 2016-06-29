From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] igb: implement igb_ptp_suspend
Date: Wed, 29 Jun 2016 14:32:57 -0700
Message-ID: <1467235982-55437-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37786 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846AbcF2VdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:08 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Make igb_ptp_stop take advantage of this new function to reduce code
duplication.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h     |  1 +
 drivers/net/ethernet/intel/igb/igb_ptp.c | 22 +++++++++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 38daaab..5387b3a 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -550,6 +550,7 @@ void igb_set_fw_version(struct igb_adapter *);
 void igb_ptp_init(struct igb_adapter *adapter);
 void igb_ptp_stop(struct igb_adapter *adapter);
 void igb_ptp_reset(struct igb_adapter *adapter);
+void igb_ptp_suspend(struct igb_adapter *adapter);
 void igb_ptp_rx_hang(struct igb_adapter *adapter);
 void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector, struct sk_buff *skb);
 void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, unsigned char *va,
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 907c225..e61b647 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -1147,12 +1147,13 @@ void igb_ptp_init(struct igb_adapter *adapter)
 }
 
 /**
- * igb_ptp_stop - Disable PTP device and stop the overflow check.
- * @adapter: Board private structure.
+ * igb_ptp_suspend - Disable PTP work items and prepare for suspend
+ * @adapter: Board private structure
  *
- * This function stops the PTP support and cancels the delayed work.
- **/
-void igb_ptp_stop(struct igb_adapter *adapter)
+ * This function stops the overflow check work and PTP Tx timestamp work, and
+ * will prepare the device for OS suspend.
+ */
+void igb_ptp_suspend(struct igb_adapter *adapter)
 {
 	if (!(adapter->ptp_flags & IGB_PTP_ENABLED))
 		return;
@@ -1166,6 +1167,17 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 		adapter->ptp_tx_skb = NULL;
 		clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
 	}
+}
+
+/**
+ * igb_ptp_stop - Disable PTP device and stop the overflow check.
+ * @adapter: Board private structure.
+ *
+ * This function stops the PTP support and cancels the delayed work.
+ **/
+void igb_ptp_stop(struct igb_adapter *adapter)
+{
+	igb_ptp_suspend(adapter);
 
 	if (adapter->ptp_clock) {
 		ptp_clock_unregister(adapter->ptp_clock);
-- 
2.5.5
