From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/15] ixgbevf: Test Rx status bits directly out of the descriptor
Date: Thu, 20 Nov 2014 15:09:00 -0800
Message-ID: <1416524953-15161-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19656 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756722AbaKTXJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:18 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Instead of keeping a local copy of the status bits from the descriptor
we can just read them directly - this is accomplished with the addition
of ixgbevf_test_staterr().

In addition instead of doing a byteswap on the status bits value, we
can byteswap the constant values we are testing since that can be done
at compile time which should help to improve performance on big-endian
systems.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  7 +++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 59 ++++++++++-------------
 2 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index ba96cb5..5f7d2f3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -307,6 +307,13 @@ static inline bool ixgbevf_qv_disable(struct ixgbevf_q_vector *q_vector)
 	((_eitr) ? (1000000000 / ((_eitr) * 256)) : 8)
 #define EITR_REG_TO_INTS_PER_SEC EITR_INTS_PER_SEC_TO_REG
 
+/* ixgbevf_test_staterr - tests bits in Rx descriptor status and error fields */
+static inline __le32 ixgbevf_test_staterr(union ixgbe_adv_rx_desc *rx_desc,
+					  const u32 stat_err_bits)
+{
+	return rx_desc->wb.upper.status_error & cpu_to_le32(stat_err_bits);
+}
+
 static inline u16 ixgbevf_desc_unused(struct ixgbevf_ring *ring)
 {
 	u16 ntc = ring->next_to_clean;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index deda74d..19062dc 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -331,15 +331,14 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
  * ixgbevf_receive_skb - Send a completed packet up the stack
  * @q_vector: structure containing interrupt and ring information
  * @skb: packet to send up
- * @status: hardware indication of status of receive
  * @rx_desc: rx descriptor
  **/
 static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
-				struct sk_buff *skb, u8 status,
+				struct sk_buff *skb,
 				union ixgbe_adv_rx_desc *rx_desc)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
-	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
+	bool is_vlan = !!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
 	if (is_vlan && test_bit(tag & VLAN_VID_MASK, adapter->active_vlans))
@@ -355,11 +354,10 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
  * ixgbevf_rx_skb - Helper function to determine proper Rx method
  * @q_vector: structure containing interrupt and ring information
  * @skb: packet to send up
- * @status: hardware indication of status of receive
  * @rx_desc: rx descriptor
  **/
 static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
-			   struct sk_buff *skb, u8 status,
+			   struct sk_buff *skb,
 			   union ixgbe_adv_rx_desc *rx_desc)
 {
 #ifdef CONFIG_NET_RX_BUSY_POLL
@@ -372,17 +370,17 @@ static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
 	}
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
-	ixgbevf_receive_skb(q_vector, skb, status, rx_desc);
+	ixgbevf_receive_skb(q_vector, skb, rx_desc);
 }
 
-/**
- * ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
- * @ring: pointer to Rx descriptor ring structure
- * @status_err: hardware indication of status of receive
+/* ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
+ * @ring: structure containig ring specific data
+ * @rx_desc: current Rx descriptor being processed
  * @skb: skb currently being received and modified
- **/
+ */
 static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
-				       u32 status_err, struct sk_buff *skb)
+				       union ixgbe_adv_rx_desc *rx_desc,
+				       struct sk_buff *skb)
 {
 	skb_checksum_none_assert(skb);
 
@@ -391,16 +389,16 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
 		return;
 
 	/* if IP and error */
-	if ((status_err & IXGBE_RXD_STAT_IPCS) &&
-	    (status_err & IXGBE_RXDADV_ERR_IPE)) {
+	if (ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_IPCS) &&
+	    ixgbevf_test_staterr(rx_desc, IXGBE_RXDADV_ERR_IPE)) {
 		ring->rx_stats.csum_err++;
 		return;
 	}
 
-	if (!(status_err & IXGBE_RXD_STAT_L4CS))
+	if (!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_L4CS))
 		return;
 
-	if (status_err & IXGBE_RXDADV_ERR_TCPE) {
+	if (ixgbevf_test_staterr(rx_desc, IXGBE_RXDADV_ERR_TCPE)) {
 		ring->rx_stats.csum_err++;
 		return;
 	}
@@ -520,33 +518,29 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 	struct ixgbevf_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
 	unsigned int i;
-	u32 len, staterr;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
-	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	rx_buffer_info = &rx_ring->rx_buffer_info[i];
 
-	while (staterr & IXGBE_RXD_STAT_DD) {
+	while (ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD)) {
 		if (!budget)
 			break;
 		budget--;
 
 		rmb(); /* read descriptor and rx_buffer_info after status DD */
-		len = le16_to_cpu(rx_desc->wb.upper.length);
+
 		skb = rx_buffer_info->skb;
 		prefetch(skb->data - NET_IP_ALIGN);
 		rx_buffer_info->skb = NULL;
 
-		if (rx_buffer_info->dma) {
-			dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
-					 rx_ring->rx_buf_len,
-					 DMA_FROM_DEVICE);
-			rx_buffer_info->dma = 0;
-			skb_put(skb, len);
-		}
+		dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
+				 rx_ring->rx_buf_len,
+				 DMA_FROM_DEVICE);
+		rx_buffer_info->dma = 0;
+		skb_put(skb, le16_to_cpu(rx_desc->wb.upper.length));
 
 		i++;
 		if (i == rx_ring->count)
@@ -558,7 +552,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 
 		next_buffer = &rx_ring->rx_buffer_info[i];
 
-		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
+		if (!(ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))) {
 			skb->next = next_buffer->skb;
 			IXGBE_CB(skb->next)->prev = skb;
 			rx_ring->rx_stats.non_eop_descs++;
@@ -576,12 +570,13 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		}
 
 		/* ERR_MASK will only have valid bits if EOP set */
-		if (unlikely(staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK)) {
+		if (unlikely(ixgbevf_test_staterr(rx_desc,
+					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
 
-		ixgbevf_rx_checksum(rx_ring, staterr, skb);
+		ixgbevf_rx_checksum(rx_ring, rx_desc, skb);
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
@@ -600,7 +595,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbevf_rx_skb(q_vector, skb, staterr, rx_desc);
+		ixgbevf_rx_skb(q_vector, skb, rx_desc);
 
 next_desc:
 		/* return some buffers to hardware, one at a time is too slow */
@@ -612,8 +607,6 @@ next_desc:
 		/* use prefetched values */
 		rx_desc = next_rxd;
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
-
-		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
 	rx_ring->next_to_clean = i;
-- 
1.9.3
