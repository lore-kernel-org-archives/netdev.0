From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] igb: Split Rx timestamping into two separate functions
Date: Fri, 19 Oct 2012 04:45:06 -0700
Message-ID: <1350647114-6768-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64516 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758654Ab2JSLpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:45 -0400
In-Reply-To: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In order to support page based receive we will need to split up the two
different types of timestamping into two separate functions.  The first one
will handle legacy timestamps with the value in the register, and the new
one will handle timestamps in the Rx buffer itself.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h     | 17 ++++++++--
 drivers/net/ethernet/intel/igb/igb_ptp.c | 55 ++++++++++++++++++++++----------
 2 files changed, 53 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 8aad230..f6a1cd9 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -442,9 +442,22 @@ extern void igb_ptp_stop(struct igb_adapter *adapter);
 extern void igb_ptp_reset(struct igb_adapter *adapter);
 extern void igb_ptp_tx_work(struct work_struct *work);
 extern void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter);
-extern void igb_ptp_rx_hwtstamp(struct igb_q_vector *q_vector,
-				union e1000_adv_rx_desc *rx_desc,
+extern void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 				struct sk_buff *skb);
+extern void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector,
+				unsigned char *va,
+				struct sk_buff *skb);
+static inline void igb_ptp_rx_hwtstamp(struct igb_q_vector *q_vector,
+				       union e1000_adv_rx_desc *rx_desc,
+				       struct sk_buff *skb)
+{
+	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
+		igb_ptp_rx_pktstamp(q_vector, skb->data, skb);
+		skb_pull(skb, IGB_TS_HDR_LEN);
+	} else if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TS)) {
+		igb_ptp_rx_rgtstamp(q_vector, skb);
+	}
+}
 extern int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 				  struct ifreq *ifr, int cmd);
 #endif /* CONFIG_IGB_PTP */
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index ee21445..a7db4ce 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -441,18 +441,46 @@ void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 	adapter->ptp_tx_skb = NULL;
 }
 
-void igb_ptp_rx_hwtstamp(struct igb_q_vector *q_vector,
-			 union e1000_adv_rx_desc *rx_desc,
+/**
+ * igb_ptp_rx_pktstamp - retrieve Rx per packet timestamp
+ * @q_vector: Pointer to interrupt specific structure
+ * @va: Pointer to address containing Rx buffer
+ * @skb: Buffer containing timestamp and packet
+ *
+ * This function is meant to retrieve a timestamp from the first buffer of an
+ * incoming frame.  The value is stored in little endian format starting on
+ * byte 8.
+ */
+void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector,
+			 unsigned char *va,
+			 struct sk_buff *skb)
+{
+	u64 *regval = (u64 *)va;
+
+	/*
+	 * The timestamp is recorded in little endian format.
+	 * DWORD: 0        1        2        3
+	 * Field: Reserved Reserved SYSTIML  SYSTIMH
+	 */
+	igb_ptp_systim_to_hwtstamp(q_vector->adapter, skb_hwtstamps(skb),
+				   le64_to_cpu(regval[1]));
+}
+
+/**
+ * igb_ptp_rx_rgtstamp - retrieve Rx timestamp stored in register
+ * @q_vector: Pointer to interrupt specific structure
+ * @skb: Buffer containing timestamp and packet
+ *
+ * This function is meant to retrieve a timestamp from the internal registers
+ * of the adapter and store it in the skb.
+ */
+void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector,
 			 struct sk_buff *skb)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 	u64 regval;
 
-	if (!igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP |
-				       E1000_RXDADV_STAT_TS))
-		return;
-
 	/*
 	 * If this bit is set, then the RX registers contain the time stamp. No
 	 * other packet will be time stamped until we read these registers, so
@@ -464,18 +492,11 @@ void igb_ptp_rx_hwtstamp(struct igb_q_vector *q_vector,
 	 * If nothing went wrong, then it should have a shared tx_flags that we
 	 * can turn into a skb_shared_hwtstamps.
 	 */
-	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
-		u32 *stamp = (u32 *)skb->data;
-		regval = le32_to_cpu(*(stamp + 2));
-		regval |= (u64)le32_to_cpu(*(stamp + 3)) << 32;
-		skb_pull(skb, IGB_TS_HDR_LEN);
-	} else {
-		if (!(rd32(E1000_TSYNCRXCTL) & E1000_TSYNCRXCTL_VALID))
-			return;
+	if (!(rd32(E1000_TSYNCRXCTL) & E1000_TSYNCRXCTL_VALID))
+		return;
 
-		regval = rd32(E1000_RXSTMPL);
-		regval |= (u64)rd32(E1000_RXSTMPH) << 32;
-	}
+	regval = rd32(E1000_RXSTMPL);
+	regval |= (u64)rd32(E1000_RXSTMPH) << 32;
 
 	igb_ptp_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
 }
-- 
1.7.11.7
