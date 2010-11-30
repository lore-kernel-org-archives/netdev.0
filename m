From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v3] net: don't reallocate skb->head unless the current one hasn't the needed extra size or is shared
Date: Tue, 30 Nov 2010 16:48:46 +0800
Message-ID: <1291106926-1898-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:63964 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab0K3ItG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 03:49:06 -0500
Received: by gwj20 with SMTP id 20so2561200gwj.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 00:49:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb head being allocated by kmalloc(), it might be larger than what
actually requested because of discrete kmem caches sizes. Before
reallocating a new skb head, check if the current one has the needed
extra size.

Do this check only if skb head is not shared.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
V3: update the comment.
v2: apply this trick for the cloned but not shared skb
 net/core/skbuff.c |   34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 104f844..8814a9a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -778,6 +778,28 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	size = SKB_DATA_ALIGN(size);
 
+	/* Check if we can avoid taking references on fragments if we own
+	 * the last reference on skb->head. (see skb_release_data())
+	 */
+	if (!skb->cloned)
+		fastpath = true;
+	else {
+		int delta = skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1;
+
+		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
+	}
+
+	if (fastpath &&
+	    size + sizeof(struct skb_shared_info) <= ksize(skb->head)) {
+		memmove(skb->head + size, skb_shinfo(skb),
+			offsetof(struct skb_shared_info,
+				 frags[skb_shinfo(skb)->nr_frags]));
+		memmove(skb->head + nhead, skb->head,
+			skb_tail_pointer(skb) - skb->head);
+		off = nhead;
+		goto adjust_others;
+	}
+
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;
@@ -791,17 +813,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	       skb_shinfo(skb),
 	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
 
-	/* Check if we can avoid taking references on fragments if we own
-	 * the last reference on skb->head. (see skb_release_data())
-	 */
-	if (!skb->cloned)
-		fastpath = true;
-	else {
-		int delta = skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1;
-
-		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
-	}
-
 	if (fastpath) {
 		kfree(skb->head);
 	} else {
@@ -816,6 +827,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	off = (data + nhead) - skb->head;
 
 	skb->head     = data;
+adjust_others:
 	skb->data    += off;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->end      = size;
