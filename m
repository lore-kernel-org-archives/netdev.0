From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 3/9] netdev: bfin_mac: invalid data cache only once for each new rx skb buffer
Date: Mon, 10 May 2010 11:39:08 -0400
Message-ID: <1273505954-32588-3-git-send-email-vapier@gentoo.org>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43477 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397Ab0EJPgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 11:36:21 -0400
In-Reply-To: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

The skb buffer isn't actually used until we finish transferring and pass
it up to higher layers, so only invalidate the range once before we start
receiving actual data.  This also avoids the problem with data invalidating
on Blackfin systems -- there is no invalidate-only, just invalidate+flush.
So when running in writeback mode, there is the small (but not uncommon)
possibility of the flush overwriting valid DMA-ed data from the cache.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c888465..f9ba598 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -203,6 +203,11 @@ static int desc_list_init(void)
 			goto init_error;
 		}
 		skb_reserve(new_skb, NET_IP_ALIGN);
+		/* Invidate the data cache of skb->data range when it is write back
+		 * cache. It will prevent overwritting the new data from DMA
+		 */
+		blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
+					 (unsigned long)new_skb->end);
 		r->skb = new_skb;
 
 		/*
@@ -1012,19 +1017,17 @@ static void bfin_mac_rx(struct net_device *dev)
 	}
 	/* reserve 2 bytes for RXDWA padding */
 	skb_reserve(new_skb, NET_IP_ALIGN);
-	current_rx_ptr->skb = new_skb;
-	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
-
 	/* Invidate the data cache of skb->data range when it is write back
 	 * cache. It will prevent overwritting the new data from DMA
 	 */
 	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
 					 (unsigned long)new_skb->end);
 
+	current_rx_ptr->skb = new_skb;
+	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
+
 	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
 	skb_put(skb, len);
-	blackfin_dcache_invalidate_range((unsigned long)skb->head,
-					 (unsigned long)skb->tail);
 
 	skb->protocol = eth_type_trans(skb, dev);
 
-- 
1.7.1

