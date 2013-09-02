From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] ibmveth: Fix little endian issues
Date: Tue, 3 Sep 2013 09:55:32 +1000
Message-ID: <20130903095532.507dcb44@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: santil@linux.vnet.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43846 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756805Ab3IBXze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 19:55:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The hypervisor is big endian, so little endian kernel builds need
to byteswap.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 70fd559..5d41aee 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -106,7 +106,7 @@ struct ibmveth_stat ibmveth_stats[] = {
 /* simple methods of getting data from the current rxq entry */
 static inline u32 ibmveth_rxq_flags(struct ibmveth_adapter *adapter)
 {
-	return adapter->rx_queue.queue_addr[adapter->rx_queue.index].flags_off;
+	return be32_to_cpu(adapter->rx_queue.queue_addr[adapter->rx_queue.index].flags_off);
 }
 
 static inline int ibmveth_rxq_toggle(struct ibmveth_adapter *adapter)
@@ -132,7 +132,7 @@ static inline int ibmveth_rxq_frame_offset(struct ibmveth_adapter *adapter)
 
 static inline int ibmveth_rxq_frame_length(struct ibmveth_adapter *adapter)
 {
-	return adapter->rx_queue.queue_addr[adapter->rx_queue.index].length;
+	return be32_to_cpu(adapter->rx_queue.queue_addr[adapter->rx_queue.index].length);
 }
 
 static inline int ibmveth_rxq_csum_good(struct ibmveth_adapter *adapter)
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 43a794f..84066ba 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -164,14 +164,26 @@ struct ibmveth_adapter {
     u64 tx_send_failed;
 };
 
+/*
+ * We pass struct ibmveth_buf_desc_fields to the hypervisor in registers,
+ * so we don't need to byteswap the two elements. However since we use
+ * a union (ibmveth_buf_desc) to convert from the struct to a u64 we
+ * do end up with endian specific ordering of the elements and that
+ * needs correcting.
+ */
 struct ibmveth_buf_desc_fields {
+#ifdef __BIG_ENDIAN
+	u32 flags_len;
+	u32 address;
+#else
+	u32 address;
 	u32 flags_len;
+#endif
 #define IBMVETH_BUF_VALID	0x80000000
 #define IBMVETH_BUF_TOGGLE	0x40000000
 #define IBMVETH_BUF_NO_CSUM	0x02000000
 #define IBMVETH_BUF_CSUM_GOOD	0x01000000
 #define IBMVETH_BUF_LEN_MASK	0x00FFFFFF
-	u32 address;
 };
 
 union ibmveth_buf_desc {
@@ -180,7 +192,7 @@ union ibmveth_buf_desc {
 };
 
 struct ibmveth_rx_q_entry {
-	u32 flags_off;
+	__be32 flags_off;
 #define IBMVETH_RXQ_TOGGLE		0x80000000
 #define IBMVETH_RXQ_TOGGLE_SHIFT	31
 #define IBMVETH_RXQ_VALID		0x40000000
@@ -188,7 +200,8 @@ struct ibmveth_rx_q_entry {
 #define IBMVETH_RXQ_CSUM_GOOD		0x01000000
 #define IBMVETH_RXQ_OFF_MASK		0x0000FFFF
 
-	u32 length;
+	__be32 length;
+	/* correlator is only used by the OS, no need to byte swap */
 	u64 correlator;
 };
 
