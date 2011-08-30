From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 14/14] greth: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:30 +0100
Message-ID: <1314695910-22344-14-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22544 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972Ab1H3JSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:18:52 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid long lines also use phys_to_virt(page_to_phys(page)) =>
page_address(page) (since the are effectively the same thing for lowmem pages).

Also dump the frag's size instead of the headlen when dumping a frag.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/aeroflex/greth.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index a5f6b07..bc3bd34 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -113,9 +113,8 @@ static void greth_print_tx_packet(struct sk_buff *skb)
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 
 		print_hex_dump(KERN_DEBUG, "TX: ", DUMP_PREFIX_OFFSET, 16, 1,
-			       phys_to_virt(page_to_phys(skb_shinfo(skb)->frags[i].page)) +
-			       skb_shinfo(skb)->frags[i].page_offset,
-			       length, true);
+			       skb_frag_address(&skb_shinfo(skb)->frags[i]),
+			       skb_shinfo(skb)->frags[i].size, true);
 	}
 }
 
@@ -528,11 +527,8 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 
 		greth_write_bd(&bdp->stat, status);
 
-		dma_addr = dma_map_page(greth->dev,
-					frag->page,
-					frag->page_offset,
-					frag->size,
-					DMA_TO_DEVICE);
+		dma_addr = skb_frag_dma_map(greth->dev, frag, 0, frag->size,
+					    DMA_TO_DEVICE);
 
 		if (unlikely(dma_mapping_error(greth->dev, dma_addr)))
 			goto frag_map_error;
-- 
1.7.2.5
