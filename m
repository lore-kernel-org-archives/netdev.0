From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/9] AF_RXRPC: Move generic skbuff stuff from XFRM code to
	generic code
Date: Mon, 02 Apr 2007 23:45:03 +0100
Message-ID: <20070402224503.31568.1112.stgit@warthog.cambridge.redhat.com>
References: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move generic skbuff stuff from XFRM code to generic code so that AF_RXRPC can
use it too.

The kdoc comments I've attached to the functions needs to be checked by whoever
wrote them as I had to make some guesses about the workings of these functions.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 include/linux/skbuff.h |    6 ++
 include/net/esp.h      |    2 -
 net/core/skbuff.c      |  188 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_algo.c   |  169 -------------------------------------------
 4 files changed, 194 insertions(+), 171 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 82f43ad..d53ff7c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -83,6 +83,7 @@
  */
 
 struct net_device;
+struct scatterlist;
 
 #ifdef CONFIG_NETFILTER
 struct nf_conntrack {
@@ -364,6 +365,11 @@ extern struct sk_buff *skb_realloc_headroom(struct sk_buff *skb,
 extern struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 				       int newheadroom, int newtailroom,
 				       gfp_t priority);
+extern int	       skb_to_sgvec(struct sk_buff *skb,
+				    struct scatterlist *sg, int offset,
+				    int len);
+extern int	       skb_cow_data(struct sk_buff *skb, int tailbits,
+				    struct sk_buff **trailer);
 extern int	       skb_pad(struct sk_buff *skb, int pad);
 #define dev_kfree_skb(a)	kfree_skb(a)
 extern void	      skb_over_panic(struct sk_buff *skb, int len,
diff --git a/include/net/esp.h b/include/net/esp.h
index 713d039..d05d8d2 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -40,8 +40,6 @@ struct esp_data
 	} auth;
 };
 
-extern int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len);
-extern int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer);
 extern void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 
 static inline int esp_mac_digest(struct esp_data *esp, struct sk_buff *skb,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 87573ae..156b9c0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -55,6 +55,7 @@
 #include <linux/cache.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
+#include <linux/scatterlist.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
@@ -2060,6 +2061,190 @@ void __init skb_init(void)
 						NULL, NULL);
 }
 
+/**
+ *	skb_to_sgvec - Fill a scatter-gather list from a socket buffer
+ *	@skb: Socket buffer containing the buffers to be mapped
+ *	@sg: The scatter-gather list to map into
+ *	@offset: The offset into the buffer's contents to start mapping
+ *	@len: Length of buffer space to be mapped
+ *
+ *	Fill the specified scatter-gather list with mappings/pointers into a
+ *	region of the buffer space attached to a socket buffer.
+ */
+int
+skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
+{
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+	int elt = 0;
+
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		sg[elt].page = virt_to_page(skb->data + offset);
+		sg[elt].offset = (unsigned long)(skb->data + offset) % PAGE_SIZE;
+		sg[elt].length = copy;
+		elt++;
+		if ((len -= copy) == 0)
+			return elt;
+		offset += copy;
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		int end;
+
+		BUG_TRAP(start <= offset + len);
+
+		end = start + skb_shinfo(skb)->frags[i].size;
+		if ((copy = end - offset) > 0) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+			if (copy > len)
+				copy = len;
+			sg[elt].page = frag->page;
+			sg[elt].offset = frag->page_offset+offset-start;
+			sg[elt].length = copy;
+			elt++;
+			if (!(len -= copy))
+				return elt;
+			offset += copy;
+		}
+		start = end;
+	}
+
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
+
+		for (; list; list = list->next) {
+			int end;
+
+			BUG_TRAP(start <= offset + len);
+
+			end = start + list->len;
+			if ((copy = end - offset) > 0) {
+				if (copy > len)
+					copy = len;
+				elt += skb_to_sgvec(list, sg+elt, offset - start, copy);
+				if ((len -= copy) == 0)
+					return elt;
+				offset += copy;
+			}
+			start = end;
+		}
+	}
+	BUG_ON(len);
+	return elt;
+}
+
+/**
+ *	skb_cow_data - Check that a socket buffer's data buffers are writable
+ *	@skb: The socket buffer to check.
+ *	@tailbits: Amount of trailing space to be added
+ *	@trailer: Returned pointer to the skb where the @tailbits space begins
+ *
+ *	Make sure that the data buffers attached to a socket buffer are
+ *	writable. If they are not, private copies are made of the data buffers
+ *	and the socket buffer is set to use these instead.
+ *
+ *	If @tailbits is given, make sure that there is space to write @tailbits
+ *	bytes of data beyond current end of socket buffer.  @trailer will be
+ *	set to point to the skb in which this space begins.
+ *
+ *	The number of scatterlist elements required to completely map the
+ *	COW'd and extended socket buffer will be returned.
+ */
+int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
+{
+	int copyflag;
+	int elt;
+	struct sk_buff *skb1, **skb_p;
+
+	/* If skb is cloned or its head is paged, reallocate
+	 * head pulling out all the pages (pages are considered not writable
+	 * at the moment even if they are anonymous).
+	 */
+	if ((skb_cloned(skb) || skb_shinfo(skb)->nr_frags) &&
+	    __pskb_pull_tail(skb, skb_pagelen(skb)-skb_headlen(skb)) == NULL)
+		return -ENOMEM;
+
+	/* Easy case. Most of packets will go this way. */
+	if (!skb_shinfo(skb)->frag_list) {
+		/* A little of trouble, not enough of space for trailer.
+		 * This should not happen, when stack is tuned to generate
+		 * good frames. OK, on miss we reallocate and reserve even more
+		 * space, 128 bytes is fair. */
+
+		if (skb_tailroom(skb) < tailbits &&
+		    pskb_expand_head(skb, 0, tailbits-skb_tailroom(skb)+128, GFP_ATOMIC))
+			return -ENOMEM;
+
+		/* Voila! */
+		*trailer = skb;
+		return 1;
+	}
+
+	/* Misery. We are in troubles, going to mincer fragments... */
+
+	elt = 1;
+	skb_p = &skb_shinfo(skb)->frag_list;
+	copyflag = 0;
+
+	while ((skb1 = *skb_p) != NULL) {
+		int ntail = 0;
+
+		/* The fragment is partially pulled by someone,
+		 * this can happen on input. Copy it and everything
+		 * after it. */
+
+		if (skb_shared(skb1))
+			copyflag = 1;
+
+		/* If the skb is the last, worry about trailer. */
+
+		if (skb1->next == NULL && tailbits) {
+			if (skb_shinfo(skb1)->nr_frags ||
+			    skb_shinfo(skb1)->frag_list ||
+			    skb_tailroom(skb1) < tailbits)
+				ntail = tailbits + 128;
+		}
+
+		if (copyflag ||
+		    skb_cloned(skb1) ||
+		    ntail ||
+		    skb_shinfo(skb1)->nr_frags ||
+		    skb_shinfo(skb1)->frag_list) {
+			struct sk_buff *skb2;
+
+			/* Fuck, we are miserable poor guys... */
+			if (ntail == 0)
+				skb2 = skb_copy(skb1, GFP_ATOMIC);
+			else
+				skb2 = skb_copy_expand(skb1,
+						       skb_headroom(skb1),
+						       ntail,
+						       GFP_ATOMIC);
+			if (unlikely(skb2 == NULL))
+				return -ENOMEM;
+
+			if (skb1->sk)
+				skb_set_owner_w(skb2, skb1->sk);
+
+			/* Looking around. Are we still alive?
+			 * OK, link new skb, drop old one */
+
+			skb2->next = skb1->next;
+			*skb_p = skb2;
+			kfree_skb(skb1);
+			skb1 = skb2;
+		}
+		elt++;
+		*trailer = skb1;
+		skb_p = &skb1->next;
+	}
+
+	return elt;
+}
+
 EXPORT_SYMBOL(___pskb_trim);
 EXPORT_SYMBOL(__kfree_skb);
 EXPORT_SYMBOL(kfree_skb);
@@ -2094,3 +2279,6 @@ EXPORT_SYMBOL(skb_seq_read);
 EXPORT_SYMBOL(skb_abort_seq_read);
 EXPORT_SYMBOL(skb_find_text);
 EXPORT_SYMBOL(skb_append_datato_frags);
+
+EXPORT_SYMBOL_GPL(skb_to_sgvec);
+EXPORT_SYMBOL_GPL(skb_cow_data);
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index f373a8a..6249a94 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -612,175 +612,6 @@ EXPORT_SYMBOL_GPL(skb_icv_walk);
 
 #if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
 
-/* Looking generic it is not used in another places. */
-
-int
-skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
-{
-	int start = skb_headlen(skb);
-	int i, copy = start - offset;
-	int elt = 0;
-
-	if (copy > 0) {
-		if (copy > len)
-			copy = len;
-		sg[elt].page = virt_to_page(skb->data + offset);
-		sg[elt].offset = (unsigned long)(skb->data + offset) % PAGE_SIZE;
-		sg[elt].length = copy;
-		elt++;
-		if ((len -= copy) == 0)
-			return elt;
-		offset += copy;
-	}
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		int end;
-
-		BUG_TRAP(start <= offset + len);
-
-		end = start + skb_shinfo(skb)->frags[i].size;
-		if ((copy = end - offset) > 0) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-
-			if (copy > len)
-				copy = len;
-			sg[elt].page = frag->page;
-			sg[elt].offset = frag->page_offset+offset-start;
-			sg[elt].length = copy;
-			elt++;
-			if (!(len -= copy))
-				return elt;
-			offset += copy;
-		}
-		start = end;
-	}
-
-	if (skb_shinfo(skb)->frag_list) {
-		struct sk_buff *list = skb_shinfo(skb)->frag_list;
-
-		for (; list; list = list->next) {
-			int end;
-
-			BUG_TRAP(start <= offset + len);
-
-			end = start + list->len;
-			if ((copy = end - offset) > 0) {
-				if (copy > len)
-					copy = len;
-				elt += skb_to_sgvec(list, sg+elt, offset - start, copy);
-				if ((len -= copy) == 0)
-					return elt;
-				offset += copy;
-			}
-			start = end;
-		}
-	}
-	BUG_ON(len);
-	return elt;
-}
-EXPORT_SYMBOL_GPL(skb_to_sgvec);
-
-/* Check that skb data bits are writable. If they are not, copy data
- * to newly created private area. If "tailbits" is given, make sure that
- * tailbits bytes beyond current end of skb are writable.
- *
- * Returns amount of elements of scatterlist to load for subsequent
- * transformations and pointer to writable trailer skb.
- */
-
-int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
-{
-	int copyflag;
-	int elt;
-	struct sk_buff *skb1, **skb_p;
-
-	/* If skb is cloned or its head is paged, reallocate
-	 * head pulling out all the pages (pages are considered not writable
-	 * at the moment even if they are anonymous).
-	 */
-	if ((skb_cloned(skb) || skb_shinfo(skb)->nr_frags) &&
-	    __pskb_pull_tail(skb, skb_pagelen(skb)-skb_headlen(skb)) == NULL)
-		return -ENOMEM;
-
-	/* Easy case. Most of packets will go this way. */
-	if (!skb_shinfo(skb)->frag_list) {
-		/* A little of trouble, not enough of space for trailer.
-		 * This should not happen, when stack is tuned to generate
-		 * good frames. OK, on miss we reallocate and reserve even more
-		 * space, 128 bytes is fair. */
-
-		if (skb_tailroom(skb) < tailbits &&
-		    pskb_expand_head(skb, 0, tailbits-skb_tailroom(skb)+128, GFP_ATOMIC))
-			return -ENOMEM;
-
-		/* Voila! */
-		*trailer = skb;
-		return 1;
-	}
-
-	/* Misery. We are in troubles, going to mincer fragments... */
-
-	elt = 1;
-	skb_p = &skb_shinfo(skb)->frag_list;
-	copyflag = 0;
-
-	while ((skb1 = *skb_p) != NULL) {
-		int ntail = 0;
-
-		/* The fragment is partially pulled by someone,
-		 * this can happen on input. Copy it and everything
-		 * after it. */
-
-		if (skb_shared(skb1))
-			copyflag = 1;
-
-		/* If the skb is the last, worry about trailer. */
-
-		if (skb1->next == NULL && tailbits) {
-			if (skb_shinfo(skb1)->nr_frags ||
-			    skb_shinfo(skb1)->frag_list ||
-			    skb_tailroom(skb1) < tailbits)
-				ntail = tailbits + 128;
-		}
-
-		if (copyflag ||
-		    skb_cloned(skb1) ||
-		    ntail ||
-		    skb_shinfo(skb1)->nr_frags ||
-		    skb_shinfo(skb1)->frag_list) {
-			struct sk_buff *skb2;
-
-			/* Fuck, we are miserable poor guys... */
-			if (ntail == 0)
-				skb2 = skb_copy(skb1, GFP_ATOMIC);
-			else
-				skb2 = skb_copy_expand(skb1,
-						       skb_headroom(skb1),
-						       ntail,
-						       GFP_ATOMIC);
-			if (unlikely(skb2 == NULL))
-				return -ENOMEM;
-
-			if (skb1->sk)
-				skb_set_owner_w(skb2, skb1->sk);
-
-			/* Looking around. Are we still alive?
-			 * OK, link new skb, drop old one */
-
-			skb2->next = skb1->next;
-			*skb_p = skb2;
-			kfree_skb(skb1);
-			skb1 = skb2;
-		}
-		elt++;
-		*trailer = skb1;
-		skb_p = &skb1->next;
-	}
-
-	return elt;
-}
-EXPORT_SYMBOL_GPL(skb_cow_data);
-
 void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len)
 {
 	if (tail != skb) {

