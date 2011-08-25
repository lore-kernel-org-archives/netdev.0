From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/9] IPoIB: convert to SKB paged frag API.
Date: Thu, 25 Aug 2011 09:28:10 +0100
Message-ID: <1314260895-15936-4-git-send-email-ian.campbell@citrix.com>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1314260881.10283.48.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |    5 +++--
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 39913a0..67a477b 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -169,7 +169,7 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct net_device *dev,
 			goto partial_error;
 		skb_fill_page_desc(skb, i, page, 0, PAGE_SIZE);
 
-		mapping[i + 1] = ib_dma_map_page(priv->ca, skb_shinfo(skb)->frags[i].page,
+		mapping[i + 1] = ib_dma_map_page(priv->ca, page,
 						 0, PAGE_SIZE, DMA_FROM_DEVICE);
 		if (unlikely(ib_dma_mapping_error(priv->ca, mapping[i + 1])))
 			goto partial_error;
@@ -537,7 +537,8 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 
 		if (length == 0) {
 			/* don't need this page */
-			skb_fill_page_desc(toskb, i, frag->page, 0, PAGE_SIZE);
+			skb_fill_page_desc(toskb, i, skb_frag_page(frag),
+					   0, PAGE_SIZE);
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 81ae61d..00435be 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -182,7 +182,7 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
 			goto partial_error;
 		skb_fill_page_desc(skb, 0, page, 0, PAGE_SIZE);
 		mapping[1] =
-			ib_dma_map_page(priv->ca, skb_shinfo(skb)->frags[0].page,
+			ib_dma_map_page(priv->ca, page,
 					0, PAGE_SIZE, DMA_FROM_DEVICE);
 		if (unlikely(ib_dma_mapping_error(priv->ca, mapping[1])))
 			goto partial_error;
@@ -323,7 +323,8 @@ static int ipoib_dma_map_tx(struct ib_device *ca,
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; ++i) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		mapping[i + off] = ib_dma_map_page(ca, frag->page,
+		mapping[i + off] = ib_dma_map_page(ca,
+						 skb_frag_page(frag),
 						 frag->page_offset, frag->size,
 						 DMA_TO_DEVICE);
 		if (unlikely(ib_dma_mapping_error(ca, mapping[i + off])))
-- 
1.7.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
