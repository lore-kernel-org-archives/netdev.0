From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add alloc_skb_with_frags() helper
Date: Wed, 17 Sep 2014 04:49:49 -0700
Message-ID: <1410954589.7106.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:47914 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaIQLtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 07:49:51 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so2003465pab.18
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 04:49:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Extract from sock_alloc_send_pskb() code building skb with frags,
so that we can reuse this in other contexts.

Intent is to use it from tcp_send_rcvq(), tcp_collapse(), ...

We also want to replace some skb_linearize() calls to a more reliable
strategy in pathological cases where we need to reduce number of frags.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |    6 +++
 net/core/skbuff.c      |   78 +++++++++++++++++++++++++++++++++++++++
 net/core/sock.c        |   78 +++++++--------------------------------
 3 files changed, 99 insertions(+), 63 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 756e3d057e84..f1bfa3781c75 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -769,6 +769,12 @@ static inline struct sk_buff *alloc_skb(unsigned int size,
 	return __alloc_skb(size, priority, 0, NUMA_NO_NODE);
 }
 
+struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
+				     unsigned long data_len,
+				     int max_page_order,
+				     int *errcode,
+				     gfp_t gfp_mask);
+
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 29f7f0121491..06a8feb10099 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4102,3 +4102,81 @@ err_free:
 	return NULL;
 }
 EXPORT_SYMBOL(skb_vlan_untag);
+
+/**
+ * alloc_skb_with_frags - allocate skb with page frags
+ *
+ * header_len: size of linear part
+ * data_len: needed length in frags
+ * max_page_order: max page order desired.
+ * errcode: pointer to error code if any
+ * gfp_mask: allocation mask
+ *
+ * This can be used to allocate a paged skb, given a maximal order for frags.
+ */
+struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
+				     unsigned long data_len,
+				     int max_page_order,
+				     int *errcode,
+				     gfp_t gfp_mask)
+{
+	int npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
+	unsigned long chunk;
+	struct sk_buff *skb;
+	struct page *page;
+	gfp_t gfp_head;
+	int i;
+
+	*errcode = -EMSGSIZE;
+	/* Note this test could be relaxed, if we succeed to allocate
+	 * high order pages...
+	 */
+	if (npages > MAX_SKB_FRAGS)
+		return NULL;
+
+	gfp_head = gfp_mask;
+	if (gfp_head & __GFP_WAIT)
+		gfp_head |= __GFP_REPEAT;
+
+	*errcode = -ENOBUFS;
+	skb = alloc_skb(header_len, gfp_head);
+	if (!skb)
+		return NULL;
+
+	skb->truesize += npages << PAGE_SHIFT;
+
+	for (i = 0; npages > 0; i++) {
+		int order = max_page_order;
+
+		while (order) {
+			if (npages >= 1 << order) {
+				page = alloc_pages(gfp_mask |
+						   __GFP_COMP |
+						   __GFP_NOWARN |
+						   __GFP_NORETRY,
+						   order);
+				if (page)
+					goto fill_page;
+				/* Do not retry other high order allocations */
+				order = 1;
+				max_page_order = 0;
+			}
+			order--;
+		}
+		page = alloc_page(gfp_mask);
+		if (!page)
+			goto failure;
+fill_page:
+		chunk = min_t(unsigned long, data_len,
+			      PAGE_SIZE << order);
+		skb_fill_page_desc(skb, i, page, 0, chunk);
+		data_len -= chunk;
+		npages -= 1 << order;
+	}
+	return skb;
+
+failure:
+	kfree_skb(skb);
+	return NULL;
+}
+EXPORT_SYMBOL(alloc_skb_with_frags);
diff --git a/net/core/sock.c b/net/core/sock.c
index 6f436b5e4961..de887c45c63b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1762,21 +1762,12 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 				     unsigned long data_len, int noblock,
 				     int *errcode, int max_page_order)
 {
-	struct sk_buff *skb = NULL;
-	unsigned long chunk;
-	gfp_t gfp_mask;
+	struct sk_buff *skb;
 	long timeo;
 	int err;
-	int npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
-	struct page *page;
-	int i;
-
-	err = -EMSGSIZE;
-	if (npages > MAX_SKB_FRAGS)
-		goto failure;
 
 	timeo = sock_sndtimeo(sk, noblock);
-	while (!skb) {
+	for (;;) {
 		err = sock_error(sk);
 		if (err != 0)
 			goto failure;
@@ -1785,66 +1776,27 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		if (sk->sk_shutdown & SEND_SHUTDOWN)
 			goto failure;
 
-		if (atomic_read(&sk->sk_wmem_alloc) >= sk->sk_sndbuf) {
-			set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
-			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
-			err = -EAGAIN;
-			if (!timeo)
-				goto failure;
-			if (signal_pending(current))
-				goto interrupted;
-			timeo = sock_wait_for_wmem(sk, timeo);
-			continue;
-		}
-
-		err = -ENOBUFS;
-		gfp_mask = sk->sk_allocation;
-		if (gfp_mask & __GFP_WAIT)
-			gfp_mask |= __GFP_REPEAT;
+		if (sk_wmem_alloc_get(sk) < sk->sk_sndbuf)
+			break;
 
-		skb = alloc_skb(header_len, gfp_mask);
-		if (!skb)
+		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		err = -EAGAIN;
+		if (!timeo)
 			goto failure;
-
-		skb->truesize += data_len;
-
-		for (i = 0; npages > 0; i++) {
-			int order = max_page_order;
-
-			while (order) {
-				if (npages >= 1 << order) {
-					page = alloc_pages(sk->sk_allocation |
-							   __GFP_COMP |
-							   __GFP_NOWARN |
-							   __GFP_NORETRY,
-							   order);
-					if (page)
-						goto fill_page;
-					/* Do not retry other high order allocations */
-					order = 1;
-					max_page_order = 0;
-				}
-				order--;
-			}
-			page = alloc_page(sk->sk_allocation);
-			if (!page)
-				goto failure;
-fill_page:
-			chunk = min_t(unsigned long, data_len,
-				      PAGE_SIZE << order);
-			skb_fill_page_desc(skb, i, page, 0, chunk);
-			data_len -= chunk;
-			npages -= 1 << order;
-		}
+		if (signal_pending(current))
+			goto interrupted;
+		timeo = sock_wait_for_wmem(sk, timeo);
 	}
-
-	skb_set_owner_w(skb, sk);
+	skb = alloc_skb_with_frags(header_len, data_len, max_page_order,
+				   errcode, sk->sk_allocation);
+	if (skb)
+		skb_set_owner_w(skb, sk);
 	return skb;
 
 interrupted:
 	err = sock_intr_errno(timeo);
 failure:
-	kfree_skb(skb);
 	*errcode = err;
 	return NULL;
 }
