From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/8] ixgbevf: Cleanup accounting for space needed at start of xmit_frame
Date: Tue, 17 Jul 2012 03:09:16 -0700
Message-ID: <1342519759-25137-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49016 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133Ab2GQKJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 06:09:25 -0400
In-Reply-To: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change cleans up the accounting needed at the start of xmit_frame so
that we can avoid doing too much work to determine how many descriptors we
will need.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   46 +++++++++++----------
 1 file changed, 24 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 75af192..855bb21 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -175,10 +175,8 @@ static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_adapter *adapter,
 #define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
 
 /* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
-			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
-#define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)      /* for context */
+#define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IXGBE_MAX_DATA_PER_TXD)
+#define DESC_NEEDED (MAX_SKB_FRAGS + 4)
 
 static void ixgbevf_tx_timeout(struct net_device *netdev);
 
@@ -2932,33 +2930,37 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int tx_flags = 0;
 	u8 hdr_len = 0;
 	int r_idx = 0, tso;
-	int count = 0;
-
-	unsigned int f;
+	u16 count = TXD_USE_COUNT(skb_headlen(skb));
+#if PAGE_SIZE > IXGBE_MAX_DATA_PER_TXD
+	unsigned short f;
+#endif
 
 	tx_ring = &adapter->tx_ring[r_idx];
 
+	/*
+	 * need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
+	 *       + 1 desc for skb_headlen/IXGBE_MAX_DATA_PER_TXD,
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
+	if (ixgbevf_maybe_stop_tx(netdev, tx_ring, count + 3)) {
+		adapter->tx_busy++;
+		return NETDEV_TX_BUSY;
+	}
+
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb);
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
 
-	/* four things can cause us to need a context descriptor */
-	if (skb_is_gso(skb) ||
-	    (skb->ip_summed == CHECKSUM_PARTIAL) ||
-	    (tx_flags & IXGBE_TX_FLAGS_VLAN))
-		count++;
-
-	count += TXD_USE_COUNT(skb_headlen(skb));
-	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
-		count += TXD_USE_COUNT(skb_frag_size(&skb_shinfo(skb)->frags[f]));
-
-	if (ixgbevf_maybe_stop_tx(netdev, tx_ring, count)) {
-		adapter->tx_busy++;
-		return NETDEV_TX_BUSY;
-	}
-
 	first = tx_ring->next_to_use;
 
 	if (skb->protocol == htons(ETH_P_IP))
-- 
1.7.10.4
