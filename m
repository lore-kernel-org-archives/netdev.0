From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: [PATCH 24/37] drivers/net/wireless/b43: Use kmemdup
Date: Sat, 15 May 2010 23:20:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152320070.21345@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-ja
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

---
 drivers/net/wireless/b43/dma.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -u -p a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -1221,14 +1221,14 @@ static int dma_tx_fragment(struct b43_dm
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	/* create a bounce buffer in zone_dma on mapping failure. */
 	if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
-		priv_info->bouncebuffer = kmalloc(skb->len, GFP_ATOMIC | GFP_DMA);
+		priv_info->bouncebuffer = kmemdup(skb->data, skb->len,
+						  GFP_ATOMIC | GFP_DMA);
 		if (!priv_info->bouncebuffer) {
 			ring->current_slot = old_top_slot;
 			ring->used_slots = old_used_slots;
 			err = -ENOMEM;
 			goto out_unmap_hdr;
 		}
-		memcpy(priv_info->bouncebuffer, skb->data, skb->len);
 
 		meta->dmaaddr = map_descbuffer(ring, priv_info->bouncebuffer, skb->len, 1);
 		if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
