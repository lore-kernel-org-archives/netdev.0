From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/13] net: xfrm: convert to SKB frag APIs
Date: Fri, 22 Jul 2011 14:17:27 +0100
Message-ID: <1311340653-19336-7-git-send-email-ian.campbell@citrix.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311340095.12772.57.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 net/xfrm/xfrm_ipcomp.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index fc91ad7..f781b9a 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -70,26 +70,29 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 
 	while ((scratch += len, dlen -= len) > 0) {
 		skb_frag_t *frag;
+		struct page *page;
 
 		err = -EMSGSIZE;
 		if (WARN_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS))
 			goto out;
 
 		frag = skb_shinfo(skb)->frags + skb_shinfo(skb)->nr_frags;
-		frag->page = alloc_page(GFP_ATOMIC);
+		page = alloc_page(GFP_ATOMIC);
 
 		err = -ENOMEM;
-		if (!frag->page)
+		if (!page)
 			goto out;
 
+		__skb_frag_set_page(frag, page);
+
 		len = PAGE_SIZE;
 		if (dlen < len)
 			len = dlen;
 
-		memcpy(page_address(frag->page), scratch, len);
-
 		frag->page_offset = 0;
 		frag->size = len;
+		memcpy(skb_frag_address(frag), scratch, len);
+
 		skb->truesize += len;
 		skb->data_len += len;
 		skb->len += len;
-- 
1.7.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
