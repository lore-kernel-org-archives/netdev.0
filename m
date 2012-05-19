From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/3] net: introduce skb_try_coalesce()
Date: Sat, 19 May 2012 15:02:02 +0200
Message-ID: <1337432522.7029.194.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63691 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756815Ab2ESNCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 09:02:06 -0400
Received: by wibhj8 with SMTP id hj8so966927wib.1
        for <netdev@vger.kernel.org>; Sat, 19 May 2012 06:02:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Move tcp_try_coalesce() protocol independent part to 
skb_try_coalesce().

skb_try_coalesce() can be used in IPv4 defrag and IPv6 reassembly,
to build optimized skbs (less sk_buff, and possibly less 'headers')

skb_try_coalesce() is zero copy, unless the copy can fit in destination
header (its a rare case)

kfree_skb_partial() is also moved to net/core/skbuff.c and exported,
because IPv6 will need it in patch (ipv6: use skb coalescing in
reassembly).

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/skbuff.h |    5 ++
 net/core/skbuff.c      |   86 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c   |   67 +-----------------------------
 3 files changed, 94 insertions(+), 64 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fe37c21..0e50171 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -562,6 +562,11 @@ extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct kmem_cache *skbuff_head_cache;
+
+extern void kfree_skb_partial(struct sk_buff *skb, bool head_stolen);
+extern bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
+			     bool *fragstolen, int *delta_truesize);
+
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone, int node);
 extern struct sk_buff *build_skb(void *data, unsigned int frag_size);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7ceb673..ba8a470 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3346,3 +3346,89 @@ void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 			     skb->dev->name);
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
+
+void kfree_skb_partial(struct sk_buff *skb, bool head_stolen)
+{
+	if (head_stolen)
+		kmem_cache_free(skbuff_head_cache, skb);
+	else
+		__kfree_skb(skb);
+}
+EXPORT_SYMBOL(kfree_skb_partial);
+
+/**
+ * skb_try_coalesce - try to merge skb to prior one
+ * @to: prior buffer
+ * @from: buffer to add
+ * @fragstolen: pointer to boolean
+ *
+ */
+bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
+		      bool *fragstolen, int *delta_truesize)
+{
+	int i, delta, len = from->len;
+
+	*fragstolen = false;
+
+	if (skb_cloned(to))
+		return false;
+
+	if (len <= skb_tailroom(to)) {
+		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
+		*delta_truesize = 0;
+		return true;
+	}
+
+	if (skb_has_frag_list(to) || skb_has_frag_list(from))
+		return false;
+
+	if (skb_headlen(from) != 0) {
+		struct page *page;
+		unsigned int offset;
+
+		if (skb_shinfo(to)->nr_frags +
+		    skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
+			return false;
+
+		if (skb_head_is_locked(from))
+			return false;
+
+		delta = from->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
+
+		page = virt_to_head_page(from->head);
+		offset = from->data - (unsigned char *)page_address(page);
+
+		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
+				   page, offset, skb_headlen(from));
+		*fragstolen = true;
+	} else {
+		if (skb_shinfo(to)->nr_frags +
+		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
+			return false;
+
+		delta = from->truesize -
+			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
+	}
+
+	WARN_ON_ONCE(delta < len);
+
+	memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
+	       skb_shinfo(from)->frags,
+	       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
+	skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
+
+	if (!skb_cloned(from))
+		skb_shinfo(from)->nr_frags = 0;
+
+	/* if the skb is cloned this does nothing since we set nr_frags to 0 */
+	for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
+		skb_frag_ref(from, i);
+
+	to->truesize += delta;
+	to->len += len;
+	to->data_len += len;
+
+	*delta_truesize = delta;
+	return true;
+}
+EXPORT_SYMBOL(skb_try_coalesce);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b961ef5..cfa2aa1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4549,84 +4549,23 @@ static bool tcp_try_coalesce(struct sock *sk,
 			     struct sk_buff *from,
 			     bool *fragstolen)
 {
-	int i, delta, len = from->len;
+	int delta;
 
 	*fragstolen = false;
 
-	if (tcp_hdr(from)->fin || skb_cloned(to))
+	if (tcp_hdr(from)->fin)
 		return false;
-
-	if (len <= skb_tailroom(to)) {
-		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
-		goto merge;
-	}
-
-	if (skb_has_frag_list(to) || skb_has_frag_list(from))
+	if (!skb_try_coalesce(to, from, fragstolen, &delta))
 		return false;
 
-	if (skb_headlen(from) != 0) {
-		struct page *page;
-		unsigned int offset;
-
-		if (skb_shinfo(to)->nr_frags +
-		    skb_shinfo(from)->nr_frags >= MAX_SKB_FRAGS)
-			return false;
-
-		if (skb_head_is_locked(from))
-			return false;
-
-		delta = from->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
-
-		page = virt_to_head_page(from->head);
-		offset = from->data - (unsigned char *)page_address(page);
-
-		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
-				   page, offset, skb_headlen(from));
-		*fragstolen = true;
-	} else {
-		if (skb_shinfo(to)->nr_frags +
-		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
-			return false;
-
-		delta = from->truesize -
-			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
-	}
-
-	WARN_ON_ONCE(delta < len);
-
-	memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
-	       skb_shinfo(from)->frags,
-	       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
-	skb_shinfo(to)->nr_frags += skb_shinfo(from)->nr_frags;
-
-	if (!skb_cloned(from))
-		skb_shinfo(from)->nr_frags = 0;
-
-	/* if the skb is cloned this does nothing since we set nr_frags to 0 */
-	for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
-		skb_frag_ref(from, i);
-
-	to->truesize += delta;
 	atomic_add(delta, &sk->sk_rmem_alloc);
 	sk_mem_charge(sk, delta);
-	to->len += len;
-	to->data_len += len;
-
-merge:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
 	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
 	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
 	return true;
 }
 
-static void kfree_skb_partial(struct sk_buff *skb, bool head_stolen)
-{
-	if (head_stolen)
-		kmem_cache_free(skbuff_head_cache, skb);
-	else
-		__kfree_skb(skb);
-}
-
 static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
