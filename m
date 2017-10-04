From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: cache skb_shinfo() in skb_try_coalesce()
Date: Wed, 04 Oct 2017 10:48:35 -0700
Message-ID: <1507139315.14419.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38428 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751133AbdJDRsh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:48:37 -0400
Received: by mail-pf0-f194.google.com with SMTP id a7so12865974pfj.5
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 10:48:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Compiler does not really know that skb_shinfo(to|from) are constants
in skb_try_coalesce(), lets cache their values to shrink code.

We might even take care of skb_zcopy() calls later.

$ size net/core/skbuff.o.before net/core/skbuff.o
   text	   data	    bss	    dec	    hex	filename
  40727	   1298	      0	  42025	   a429	net/core/skbuff.o.before
  40631	   1298	      0	  41929	   a3c9	net/core/skbuff.o


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d98c2e3ce2bfd9549647d6914b69cecd840de480..822a90e56aea2078a11d5361a2b2595812291274 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4767,6 +4767,7 @@ EXPORT_SYMBOL(kfree_skb_partial);
 bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		      bool *fragstolen, int *delta_truesize)
 {
+	struct skb_shared_info *to_shinfo, *from_shinfo;
 	int i, delta, len = from->len;
 
 	*fragstolen = false;
@@ -4781,7 +4782,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		return true;
 	}
 
-	if (skb_has_frag_list(to) || skb_has_frag_list(from))
+	to_shinfo = skb_shinfo(to);
+	from_shinfo = skb_shinfo(from);
+	if (to_shinfo->frag_list || from_shinfo->frag_list)
 		return false;
 	if (skb_zcopy(to) || skb_zcopy(from))
 		return false;
@@ -4790,8 +4793,8 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		struct page *page;
 		unsigned int offset;
 
-		if (skb_shinfo(to)->nr_frags +
-		    skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
+		if (to_shinfo->nr_frags +
+		    from_shinfo->nr_frags >= MAX_SKB_FRAGS)
 			return false;
 
 		if (skb_head_is_locked(from))
@@ -4802,12 +4805,12 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		page = virt_to_head_page(from->head);
 		offset = from->data - (unsigned char *)page_address(page);
 
-		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
+		skb_fill_page_desc(to, to_shinfo->nr_frags,
 				   page, offset, skb_headlen(from));
 		*fragstolen = true;
 	} else {
-		if (skb_shinfo(to)->nr_frags +
-		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
+		if (to_shinfo->nr_frags +
+		    from_shinfo->nr_frags > MAX_SKB_FRAGS)
 			return false;
 
 		delta = from->truesize - SKB_TRUESIZE(skb_end_offset(from));
@@ -4815,19 +4818,19 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 
 	WARN_ON_ONCE(delta < len);
 
-	memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
-	       skb_shinfo(from)->frags,
-	       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
-	skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
+	memcpy(to_shinfo->frags + to_shinfo->nr_frags,
+	       from_shinfo->frags,
+	       from_shinfo->nr_frags * sizeof(skb_frag_t));
+	to_shinfo->nr_frags += from_shinfo->nr_frags;
 
 	if (!skb_cloned(from))
-		skb_shinfo(from)->nr_frags = 0;
+		from_shinfo->nr_frags = 0;
 
 	/* if the skb is not cloned this does nothing
 	 * since we set nr_frags to 0.
 	 */
-	for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
-		skb_frag_ref(from, i);
+	for (i = 0; i < from_shinfo->nr_frags; i++)
+		__skb_frag_ref(&from_shinfo->frags[i]);
 
 	to->truesize += delta;
 	to->len += len;
