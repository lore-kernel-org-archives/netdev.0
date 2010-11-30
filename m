From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] net: avoid the unnecessary kmalloc
Date: Tue, 30 Nov 2010 08:40:29 +0800
Message-ID: <1291077629-6339-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:54818 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab0K3Akx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 19:40:53 -0500
Received: by pzk6 with SMTP id 6so794032pzk.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 16:40:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the old memory allocated by kmalloc() is larger than the new requested,
pskb_expand_head() doesn't need to allocate a new one, unless the skb->head
is shared.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
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
