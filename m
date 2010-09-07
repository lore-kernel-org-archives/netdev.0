From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 06 Sep 2010 19:20:03 -0700 (PDT)
Message-ID: <20100906.192003.232914158.davem@davemloft.net>
References: <1283492880.3699.1437.camel@edumazet-laptop>
	<1283504972.2453.257.camel@edumazet-laptop>
	<20100903.064633.27806839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36008
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751530Ab0IGCTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 22:19:45 -0400
In-Reply-To: <20100903.064633.27806839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 03 Sep 2010 06:46:33 -0700 (PDT)

> There are only two operations that make a double-linked list currently
> impossible.  This pskb_expand_head() thing, and pskb_copy().
> 
> They cause the situation where the list is shared between multiple SKB
> data shared areas.
> 
> And because of this a doubly-linked list like list_head won't work at
> all.
> 
> For the optimized case of pskb_expand_head() you discovered we can avoid
> this sharing.  And at this point I imagine that for the remaining cases
> we can simply copy the full SKBs in the frag list to avoid this list
> sharing.

Eric, this goes on top of your patch and demonstrates the idea.

Please review if you have a chance:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2d1bc76..aeb56af 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -327,6 +327,32 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 		skb_get(list);
 }
 
+static struct sk_buff *skb_copy_fraglist(struct sk_buff *parent,
+					 gfp_t gfp_mask)
+{
+	struct sk_buff *first_skb = NULL;
+	struct sk_buff *prev_skb = NULL;
+	struct sk_buff *skb;
+
+	skb_walk_frags(parent, skb) {
+		struct sk_buff *nskb = pskb_copy(skb, gfp_mask);
+
+		if (!nskb)
+			goto fail;
+		if (!first_skb)
+			first_skb = skb;
+		else
+			prev_skb->next = skb;
+		prev_skb = skb;
+	}
+
+	return first_skb;
+
+fail:
+	skb_drop_list(&first_skb);
+	return NULL;
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
@@ -812,17 +838,22 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
 	}
 
-	if (fastpath) {
-		kfree(skb->head);
-	} else {
+	if (!fastpath) {
+		if (skb_has_frag_list(skb)) {
+			struct sk_buff *new_list;
+
+			new_list = skb_copy_fraglist(skb, gfp_mask);
+			if (!new_list)
+				goto free_data;
+			skb_shinfo(skb)->frag_list = new_list;
+		}
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 			get_page(skb_shinfo(skb)->frags[i].page);
 
-		if (skb_has_frag_list(skb))
-			skb_clone_fraglist(skb);
-
-		skb_release_data(skb);
 	}
+
+	kfree(skb->head);
+
 	off = (data + nhead) - skb->head;
 
 	skb->head     = data;
@@ -848,6 +879,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 	return 0;
 
+free_data:
+	kfree(data);
 nodata:
 	return -ENOMEM;
 }
