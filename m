From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] e1000: switch to napi_gro_frags api
Date: Fri, 12 Sep 2014 05:33:51 -0700
Message-ID: <1410525231-19851-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49791 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754476AbaILMeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 08:34:06 -0400
In-Reply-To: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

napi_gro_frags allows skb re-use in case GRO can merge payload pages
into an skb on the GRO lists.

netperf TCP_STREAM, kvm-e1000 emulation, mtu 9k:
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec
old: 87380  16384  16384    30.00  8985.78
new: 87380  16384  16384    30.00  9907.05

Signed-off-by: Florian Westphal <fw@strlen.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 49 +++++++++++++++++----------
 1 file changed, 32 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 2ba640a..5f6aded 100644
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
@@ -4133,7 +4131,6 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 	int cleaned_count = 0;
 	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
-	static const unsigned int bufsz = 256 - 16; /* for skb_reserve */
 
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC(*rx_ring, i);
@@ -4192,7 +4189,7 @@ process_skb:
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
 				/* this is the beginning of a chain */
-				rxtop = e1000_alloc_rx_skb(adapter, bufsz);
+				rxtop = napi_get_frags(&adapter->napi);
 				if (!rxtop)
 					break;
 
@@ -4221,14 +4218,17 @@ process_skb:
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
@@ -4237,7 +4237,22 @@ process_skb:
 					 * buffer_info->rxbuf.page
 					 */
 					skb_put(skb, length);
+					e1000_rx_checksum(adapter,
+							  status | rx_desc->errors << 24,
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
@@ -4257,14 +4272,14 @@ process_skb:
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
1.9.3
