From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/5] AF_RXRPC: Move generic skbuff stuff from XFRM code to
	generic code [try #2]
Date: Fri, 16 Mar 2007 12:50:21 +0000
Message-ID: <20070316125021.3740.49616.stgit@warthog.cambridge.redhat.com>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbXCPMug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 08:50:36 -0400
In-Reply-To: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move generic skbuff stuff from XFRM code to generic code so that AF_RXRPC can
use it too.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 include/linux/skbuff.h |    4 +
 include/net/esp.h      |    2 -
 net/core/skbuff.c      |  173 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_algo.c   |  169 -----------------------------------------------
 4 files changed, 177 insertions(+), 171 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..8701b12 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1481,5 +1481,9 @@ static inline int skb_is_gso(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_size;
 }
 
+struct scatterlist;
+extern int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len);
+extern int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer);
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
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
index 820761f..a70c152 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -55,6 +55,7 @@
 #include <linux/cache.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
+#include <linux/scatterlist.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
@@ -2059,6 +2060,175 @@ void __init skb_init(void)
 						NULL, NULL);
 }
 
+/*
+ * fill a scatter-gather list with pointers into a part of a socket buffer
+ * chain
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
+/*
+ * Check that skb data bits are writable. If they are not, copy data
+ * to newly created private area. If "tailbits" is given, make sure that
+ * tailbits bytes beyond current end of skb are writable.
+ *
+ * Returns amount of elements of scatterlist to load for subsequent
+ * transformations and pointer to writable trailer skb.
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
@@ -2093,3 +2263,6 @@ EXPORT_SYMBOL(skb_seq_read);
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

