From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: Update method used for determining descriptor count for an skb
Date: Sat, 25 Jun 2011 00:22:22 -0700
Message-ID: <1308986546-12964-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28761 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403Ab1FYHWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 03:22:30 -0400
In-Reply-To: <1308986546-12964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch updates the current methods used for determining if we have
enough space to transmit a given skb.  The current method is quite wasteful
as it has us go through and determine how each page is going to be broken
up.  That only needs to be done if pages are larger than our maximum data
per TXD.  As such I have wrapped that in a page size check.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    7 +++++
 drivers/net/ixgbe/ixgbe_main.c |   55 +++++++++++++++++++---------------------
 2 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 393ceae..744b641 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -131,6 +131,13 @@ struct vf_macvlans {
 	u8 vf_macvlan[ETH_ALEN];
 };
 
+#define IXGBE_MAX_TXD_PWR	14
+#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
+
+/* Tx Descriptors needed, worst case */
+#define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IXGBE_MAX_DATA_PER_TXD)
+#define DESC_NEEDED ((MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE)) + 4)
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 00e60c5..305e1e4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -772,15 +772,6 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_ring *tx_ring)
 	return ret;
 }
 
-#define IXGBE_MAX_TXD_PWR       14
-#define IXGBE_MAX_DATA_PER_TXD  (1 << IXGBE_MAX_TXD_PWR)
-
-/* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
-			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
-#define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1) /* for context */
-
 /**
  * ixgbe_tx_timeout_reset - initiate reset due to Tx timeout
  * @adapter: driver private struct
@@ -6832,14 +6823,34 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
 {
-	unsigned int tx_flags = 0;
 	int tso;
-	u16 count = 0;
+	u32  tx_flags = 0;
+#if PAGE_SIZE > IXGBE_MAX_DATA_PER_TXD
+	unsigned short f;
+#endif
 	u16 first;
-	unsigned int f;
+	u16 count = TXD_USE_COUNT(skb_headlen(skb));
 	__be16 protocol;
 	u8 hdr_len = 0;
 
+	/*
+	 * need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
+	 *       + 1 desc for skb_head_len/IXGBE_MAX_DATA_PER_TXD,
+	 *       + 2 desc gap to keep tail from touching head,
+	 *       + 1 desc for context descriptor,
+	 * otherwise try next time
+	 */
+#if PAGE_SIZE > IXGBE_MAX_DATA_PER_TXD
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
+#else
+	count += skb_shinfo(skb)->nr_frags;
+#endif
+	if (ixgbe_maybe_stop_tx(tx_ring, count + 3)) {
+		tx_ring->tx_stats.tx_busy++;
+		return NETDEV_TX_BUSY;
+	}
+
 	protocol = vlan_get_protocol(skb);
 
 	if (vlan_tx_tag_present(skb)) {
@@ -6863,25 +6874,11 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
 	    (protocol == htons(ETH_P_FCOE)))
 		tx_flags |= IXGBE_TX_FLAGS_FCOE;
-#endif
-
-	/* four things can cause us to need a context descriptor */
-	if (skb_is_gso(skb) ||
-	    (skb->ip_summed == CHECKSUM_PARTIAL) ||
-	    (tx_flags & IXGBE_TX_FLAGS_VLAN) ||
-	    (tx_flags & IXGBE_TX_FLAGS_FCOE))
-		count++;
-
-	count += TXD_USE_COUNT(skb_headlen(skb));
-	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
-
-	if (ixgbe_maybe_stop_tx(tx_ring, count)) {
-		tx_ring->tx_stats.tx_busy++;
-		return NETDEV_TX_BUSY;
-	}
 
+#endif
+	/* record the location of the first descriptor for this packet */
 	first = tx_ring->next_to_use;
+
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
 #ifdef IXGBE_FCOE
 		/* setup tx offload for FCoE */
-- 
1.7.5.4

