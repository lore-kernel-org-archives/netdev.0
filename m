From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 7/7] e1000: switch to napi_gro_frags api
Date: Sat, 30 Aug 2014 20:28:27 +0200
Message-ID: <1409423307-23470-8-git-send-email-fw@strlen.de>
References: <1409423307-23470-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43563 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751800AbaH3S26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 14:28:58 -0400
In-Reply-To: <1409423307-23470-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi_gro_frags allows skb re-use in case GRO can merge payload pages
into an skb on the gro lists.

netperf TCP_STREAM, kvm-e1000 emulation, mtu 9k:
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec
old: 87380  16384  16384    30.00  8985.78
new: 87380  16384  16384    30.00  9907.05

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 50 ++++++++++++++++++---------
 1 file changed, 33 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 9ac9a77..784a67f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2117,10 +2117,8 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 	}
 
 	/* there also may be some cached data from a chained receive */
-	if (rx_ring->rx_skb_top) {
-		dev_kfree_skb(rx_ring->rx_skb_top);
-		rx_ring->rx_skb_top = NULL;
-	}
+	napi_free_frags(&adapter->napi);
+	rx_ring->rx_skb_top = NULL;
 
 	size = sizeof(struct e1000_rx_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
@@ -4130,7 +4128,6 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 	int cleaned_count = 0;
 	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
-	static const unsigned int bufsz = 256 - 16; /* for skb_reserve */
 
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC(*rx_ring, i);
@@ -4189,7 +4186,7 @@ process_skb:
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
 				/* this is the beginning of a chain */
-				rxtop = e1000_alloc_rx_skb(adapter, bufsz);
+				rxtop = napi_get_frags(&adapter->napi);
 				if (!rxtop)
 					break;
 
@@ -4218,14 +4215,17 @@ process_skb:
 				/* no chain, got EOP, this buf is the packet
 				 * copybreak to save the put_page/alloc_page
 				 */
-				skb = e1000_alloc_rx_skb(adapter, bufsz);
-				if (!skb)
-					break;
 				p = buffer_info->rxbuf.page;
-				if (length <= copybreak &&
-				    skb_tailroom(skb) >= length) {
+				if (length <= copybreak) {
 					u8 *vaddr;
 
+					if (likely(!(netdev->features & NETIF_F_RXFCS)))
+						length -= 4;
+					skb = e1000_alloc_rx_skb(adapter,
+								 length);
+					if (!skb)
+						break;
+
 					vaddr = kmap_atomic(p);
 					memcpy(skb_tail_pointer(skb), vaddr,
 					       length);
@@ -4234,7 +4234,23 @@ process_skb:
 					 * buffer_info->rxbuf.page
 					 */
 					skb_put(skb, length);
+					e1000_rx_checksum(adapter,
+							  (u32)(status) |
+							  ((u32)(rx_desc->errors) << 24),
+							  le16_to_cpu(rx_desc->csum), skb);
+
+					total_rx_bytes += skb->len;
+					total_rx_packets++;
+
+					e1000_receive_skb(adapter, status,
+							  rx_desc->special, skb);
+					goto next_desc;
 				} else {
+					skb = napi_get_frags(&adapter->napi);
+					if (!skb) {
+						adapter->alloc_rx_buff_failed++;
+						break;
+					}
 					skb_fill_page_desc(skb, 0, p, 0,
 							   length);
 					e1000_consume_page(buffer_info, skb,
@@ -4254,14 +4270,14 @@ process_skb:
 			pskb_trim(skb, skb->len - 4);
 		total_rx_packets++;
 
-		/* eth type trans needs skb->data to point to something */
-		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			e_err(drv, "pskb_may_pull failed.\n");
-			dev_kfree_skb(skb);
-			goto next_desc;
+		if (status & E1000_RXD_STAT_VP) {
+			__le16 vlan = rx_desc->special;
+			u16 vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
+
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 		}
 
-		e1000_receive_skb(adapter, status, rx_desc->special, skb);
+		napi_gro_frags(&adapter->napi);
 
 next_desc:
 		rx_desc->status = 0;
-- 
1.8.1.5
