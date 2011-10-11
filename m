From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] igb: leave staterr in place and instead us a helper function to check bits
Date: Tue, 11 Oct 2011 08:45:49 -0700
Message-ID: <1318347952-25068-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29971 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754694Ab1JKPp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 11:45:58 -0400
In-Reply-To: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Instead of doing a byte swap on the staterr bits in the Rx descriptor we can
save ourselves a bit of space and some CPU time by instead just testing for
the various bits out of the RX descriptor directly.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |    7 +++
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    5 +--
 drivers/net/ethernet/intel/igb/igb_main.c    |   55 ++++++++++++++-----------
 3 files changed, 39 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 8a15d43..04dd6d7 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -257,6 +257,13 @@ enum e1000_ring_flags_t {
 #define IGB_TX_CTXTDESC(R, i)	    \
 	(&(((struct e1000_adv_tx_context_desc *)((R)->desc))[i]))
 
+/* igb_test_staterr - tests bits within Rx descriptor status and error fields */
+static inline __le32 igb_test_staterr(union e1000_adv_rx_desc *rx_desc,
+				      const u32 stat_err_bits)
+{
+	return rx_desc->wb.upper.status_error & cpu_to_le32(stat_err_bits);
+}
+
 /* igb_desc_unused - calculate if we have unused descriptors */
 static inline int igb_desc_unused(struct igb_ring *ring)
 {
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 0a9e309..43873eb 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1577,16 +1577,14 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 	union e1000_adv_rx_desc *rx_desc;
 	struct igb_rx_buffer *rx_buffer_info;
 	struct igb_tx_buffer *tx_buffer_info;
-	u32 staterr;
 	u16 rx_ntc, tx_ntc, count = 0;
 
 	/* initialize next to clean and descriptor values */
 	rx_ntc = rx_ring->next_to_clean;
 	tx_ntc = tx_ring->next_to_clean;
 	rx_desc = IGB_RX_DESC(rx_ring, rx_ntc);
-	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
-	while (staterr & E1000_RXD_STAT_DD) {
+	while (igb_test_staterr(rx_desc, E1000_RXD_STAT_DD)) {
 		/* check rx buffer */
 		rx_buffer_info = &rx_ring->rx_buffer_info[rx_ntc];
 
@@ -1615,7 +1613,6 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 
 		/* fetch next descriptor */
 		rx_desc = IGB_RX_DESC(rx_ring, rx_ntc);
-		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
 	/* re-map buffers to ring, store next to clean values */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 33b250f..6917c33 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5720,12 +5720,13 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 }
 
 static inline void igb_rx_checksum(struct igb_ring *ring,
-				   u32 status_err, struct sk_buff *skb)
+				   union e1000_adv_rx_desc *rx_desc,
+				   struct sk_buff *skb)
 {
 	skb_checksum_none_assert(skb);
 
 	/* Ignore Checksum bit is set */
-	if (status_err & E1000_RXD_STAT_IXSM)
+	if (igb_test_staterr(rx_desc, E1000_RXD_STAT_IXSM))
 		return;
 
 	/* Rx checksum disabled via ethtool */
@@ -5733,8 +5734,9 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
 		return;
 
 	/* TCP/UDP checksum error bit is set */
-	if (status_err &
-	    (E1000_RXDEXT_STATERR_TCPE | E1000_RXDEXT_STATERR_IPE)) {
+	if (igb_test_staterr(rx_desc,
+			     E1000_RXDEXT_STATERR_TCPE |
+			     E1000_RXDEXT_STATERR_IPE)) {
 		/*
 		 * work around errata with sctp packets where the TCPE aka
 		 * L4E bit is set incorrectly on 64 byte (60 byte w/o crc)
@@ -5750,19 +5752,26 @@ static inline void igb_rx_checksum(struct igb_ring *ring,
 		return;
 	}
 	/* It must be a TCP or UDP packet with a valid checksum */
-	if (status_err & (E1000_RXD_STAT_TCPCS | E1000_RXD_STAT_UDPCS))
+	if (igb_test_staterr(rx_desc, E1000_RXD_STAT_TCPCS |
+				      E1000_RXD_STAT_UDPCS))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	dev_dbg(ring->dev, "cksum success: bits %08X\n", status_err);
+	dev_dbg(ring->dev, "cksum success: bits %08X\n",
+		le32_to_cpu(rx_desc->wb.upper.status_error));
 }
 
-static void igb_rx_hwtstamp(struct igb_q_vector *q_vector, u32 staterr,
-                                   struct sk_buff *skb)
+static void igb_rx_hwtstamp(struct igb_q_vector *q_vector,
+			    union e1000_adv_rx_desc *rx_desc,
+			    struct sk_buff *skb)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 	u64 regval;
 
+	if (!igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP |
+				       E1000_RXDADV_STAT_TS))
+		return;
+
 	/*
 	 * If this bit is set, then the RX registers contain the time stamp. No
 	 * other packet will be time stamped until we read these registers, so
@@ -5774,7 +5783,7 @@ static void igb_rx_hwtstamp(struct igb_q_vector *q_vector, u32 staterr,
 	 * If nothing went wrong, then it should have a shared tx_flags that we
 	 * can turn into a skb_shared_hwtstamps.
 	 */
-	if (staterr & E1000_RXDADV_STAT_TSIP) {
+	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
 		u32 *stamp = (u32 *)skb->data;
 		regval = le32_to_cpu(*(stamp + 2));
 		regval |= (u64)le32_to_cpu(*(stamp + 3)) << 32;
@@ -5808,14 +5817,12 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 	union e1000_adv_rx_desc *rx_desc;
 	const int current_node = numa_node_id();
 	unsigned int total_bytes = 0, total_packets = 0;
-	u32 staterr;
 	u16 cleaned_count = igb_desc_unused(rx_ring);
 	u16 i = rx_ring->next_to_clean;
 
 	rx_desc = IGB_RX_DESC(rx_ring, i);
-	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
-	while (staterr & E1000_RXD_STAT_DD) {
+	while (igb_test_staterr(rx_desc, E1000_RXD_STAT_DD)) {
 		struct igb_rx_buffer *buffer_info = &rx_ring->rx_buffer_info[i];
 		struct sk_buff *skb = buffer_info->skb;
 		union e1000_adv_rx_desc *next_rxd;
@@ -5868,7 +5875,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 			buffer_info->page_dma = 0;
 		}
 
-		if (!(staterr & E1000_RXD_STAT_EOP)) {
+		if (!igb_test_staterr(rx_desc, E1000_RXD_STAT_EOP)) {
 			struct igb_rx_buffer *next_buffer;
 			next_buffer = &rx_ring->rx_buffer_info[i];
 			buffer_info->skb = next_buffer->skb;
@@ -5878,25 +5885,26 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 			goto next_desc;
 		}
 
-		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
+		if (igb_test_staterr(rx_desc,
+				     E1000_RXDEXT_ERR_FRAME_ERR_MASK)) {
 			dev_kfree_skb_any(skb);
 			goto next_desc;
 		}
 
-		if (staterr & (E1000_RXDADV_STAT_TSIP | E1000_RXDADV_STAT_TS))
-			igb_rx_hwtstamp(q_vector, staterr, skb);
-		total_bytes += skb->len;
-		total_packets++;
-
-		igb_rx_checksum(rx_ring, staterr, skb);
-
-		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+		igb_rx_hwtstamp(q_vector, rx_desc, skb);
+		igb_rx_checksum(rx_ring, rx_desc, skb);
 
-		if (staterr & E1000_RXD_STAT_VP) {
+		if (igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
 			u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
 
 			__vlan_hwaccel_put_tag(skb, vid);
 		}
+
+		total_bytes += skb->len;
+		total_packets++;
+
+		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+
 		napi_gro_receive(&q_vector->napi, skb);
 
 		budget--;
@@ -5913,7 +5921,6 @@ next_desc:
 
 		/* use prefetched values */
 		rx_desc = next_rxd;
-		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
 	rx_ring->next_to_clean = i;
-- 
1.7.6.4
