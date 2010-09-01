From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: skbuff.c cleanup
Date: Wed, 01 Sep 2010 17:25:10 +0200
Message-ID: <1283354710.2556.344.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38296 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab0IAPZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 11:25:16 -0400
Received: by wwj40 with SMTP id 40so99393wwj.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 08:25:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(skb->data - skb->head) can be changed by skb_headroom(skb)

Remove some uses of NET_SKBUFF_DATA_USES_OFFSET, using
(skb_end_pointer(skb) - skb->head) or 
(skb_tail_pointer(skb) - skb->head) : compiler does the right thing,
and this is more readable for us ;)

(struct skb_shared_info *) casts in pskb_expand_head() to help memcpy()
to use aligned moves.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |   47 ++++++++++++++------------------------------
 1 files changed, 15 insertions(+), 32 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e2535fb..231dff0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -685,16 +685,10 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 
 struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 {
-	int headerlen = skb->data - skb->head;
-	/*
-	 *	Allocate the copy buffer
-	 */
-	struct sk_buff *n;
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n = alloc_skb(skb->end + skb->data_len, gfp_mask);
-#else
-	n = alloc_skb(skb->end - skb->head + skb->data_len, gfp_mask);
-#endif
+	int headerlen = skb_headroom(skb);
+	unsigned int size = (skb_end_pointer(skb) - skb->head) + skb->data_len;
+	struct sk_buff *n = alloc_skb(size, gfp_mask);
+
 	if (!n)
 		return NULL;
 
@@ -726,20 +720,14 @@ EXPORT_SYMBOL(skb_copy);
 
 struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	/*
-	 *	Allocate the copy buffer
-	 */
-	struct sk_buff *n;
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n = alloc_skb(skb->end, gfp_mask);
-#else
-	n = alloc_skb(skb->end - skb->head, gfp_mask);
-#endif
+	unsigned int size = skb_end_pointer(skb) - skb->head;
+	struct sk_buff *n = alloc_skb(size, gfp_mask);
+
 	if (!n)
 		goto out;
 
 	/* Set the data pointer */
-	skb_reserve(n, skb->data - skb->head);
+	skb_reserve(n, skb_headroom(skb));
 	/* Set the tail pointer and length */
 	skb_put(n, skb_headlen(skb));
 	/* Copy the bytes */
@@ -791,11 +779,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 {
 	int i;
 	u8 *data;
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	int size = nhead + skb->end + ntail;
-#else
-	int size = nhead + (skb->end - skb->head) + ntail;
-#endif
+	int size = nhead + (skb_end_pointer(skb) - skb->head) + ntail;
 	long off;
 
 	BUG_ON(nhead < 0);
@@ -810,13 +794,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		goto nodata;
 
 	/* Copy only real data... and, alas, header. This should be
-	 * optimized for the cases when header is void. */
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	memcpy(data + nhead, skb->head, skb->tail);
-#else
-	memcpy(data + nhead, skb->head, skb->tail - skb->head);
-#endif
-	memcpy(data + size, skb_end_pointer(skb),
+	 * optimized for the cases when header is void.
+	 */
+	memcpy(data + nhead, skb->head, skb_tail_pointer(skb) - skb->head);
+
+	memcpy((struct skb_shared_info *)(data + size),
+	       skb_shinfo(skb),
 	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)


