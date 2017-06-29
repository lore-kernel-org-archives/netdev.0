From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH rfc net-next] net: add skb_frag_foreach_page and use with kmap_atomic
Date: Thu, 29 Jun 2017 12:12:38 -0400
Message-ID: <20170629161238.141225-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36189 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752584AbdF2QMu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:12:50 -0400
Received: by mail-qk0-f194.google.com with SMTP id r62so12190351qkf.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 09:12:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Skb frags may contain compound pages. Various operations map frags
temporarily using kmap_atomic, but this function works on single
pages, not whole compound pages. The distinction is only relevant
for high mem pages that require temporary mappings.

Introduce a looping mechanism that for compound highmem pages maps
one page at a time, does not change behavior on other pages.
Use the loop in the kmap_atomic callers in net/core/skbuff.c.

Verified by triggering skb_copy_bits with

    tcpdump -n -c 100 -i ${DEV} -w /dev/null &
    netperf -t TCP_STREAM -H ${HOST}

  and by triggering __skb_checksum with

    ethtool -K ${DEV} tx off

  repeated the tests with looping on a non-highmem platform
  (x86_64) by making skb_frag_must_loop always return true.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 36 +++++++++++++++++++++
 net/core/skbuff.c      | 88 +++++++++++++++++++++++++++++++++-----------------
 2 files changed, 95 insertions(+), 29 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a17e235639ae..6bf3280dfd37 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -345,6 +345,42 @@ static inline void skb_frag_size_sub(skb_frag_t *frag, int delta)
 	frag->size -= delta;
 }
 
+static inline bool skb_frag_must_loop(struct page *p)
+{
+#if defined(CONFIG_HIGHMEM)
+	if (PageHighMem(p))
+		return true;
+#endif
+	return false;
+}
+
+/**
+ *	skb_frag_foreach_page - loop over pages in a fragment
+ *
+ *	@f:		skb frag to operate on
+ *	@f_off:		offset from start of f->page.p
+ *	@f_len:		length from f_off to loop over
+ *	@p:		(temp var) current page
+ *	@p_off:		(temp var) offset from start of current page,
+ *	                           non-zero only on first page.
+ *	@p_len:		(temp var) length in current page,
+ *				   < PAGE_SIZE only on first and last page.
+ *	@copied:	(temp var) length so far, excluding current p_len.
+ *
+ *	A fragment can hold a compound page, in which case per-page
+ *	operations, notably kmap_atomic, must be called for each
+ *	regular page.
+ */
+#define skb_frag_foreach_page(f, f_off, f_len, p, p_off, p_len, copied)	\
+	for (p = skb_frag_page(f) + ((f_off) >> PAGE_SHIFT),		\
+	     p_off = (f_off) & (PAGE_SIZE - 1),				\
+	     p_len = skb_frag_must_loop(p) ?				\
+	     min_t(u32, f_len, PAGE_SIZE - p_off) : f_len,		\
+	     copied = 0;						\
+	     copied < f_len;						\
+	     copied += p_len, p++, p_off = 0,				\
+	     p_len = min_t(u32, f_len - copied, PAGE_SIZE))		\
+
 #define HAVE_HW_TIME_STAMP
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f75897a33fa4..42d49c5c3cb9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -964,8 +964,10 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
 
 	for (i = 0; i < num_frags; i++) {
-		u8 *vaddr;
 		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		u32 p_off, p_len, copied;
+		struct page *p;
+		u8 *vaddr;
 
 		page = alloc_page(gfp_mask);
 		if (!page) {
@@ -976,10 +978,15 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 			}
 			return -ENOMEM;
 		}
-		vaddr = kmap_atomic(skb_frag_page(f));
-		memcpy(page_address(page),
-		       vaddr + f->page_offset, skb_frag_size(f));
-		kunmap_atomic(vaddr);
+
+		skb_frag_foreach_page(f, f->page_offset, skb_frag_size(f),
+				      p, p_off, p_len, copied) {
+			vaddr = kmap_atomic(p);
+			memcpy(page_address(page) + copied, vaddr + p_off,
+			       p_len);
+			kunmap_atomic(vaddr);
+		}
+
 		set_page_private(page, (unsigned long)head);
 		head = page;
 	}
@@ -1776,16 +1783,20 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 
 		end = start + skb_frag_size(f);
 		if ((copy = end - offset) > 0) {
+			u32 p_off, p_len, copied;
+			struct page *p;
 			u8 *vaddr;
 
 			if (copy > len)
 				copy = len;
 
-			vaddr = kmap_atomic(skb_frag_page(f));
-			memcpy(to,
-			       vaddr + f->page_offset + offset - start,
-			       copy);
-			kunmap_atomic(vaddr);
+			skb_frag_foreach_page(f,
+					      f->page_offset + offset - start,
+					      copy, p, p_off, p_len, copied) {
+				vaddr = kmap_atomic(p);
+				memcpy(to + copied, vaddr + p_off, p_len);
+				kunmap_atomic(vaddr);
+			}
 
 			if ((len -= copy) == 0)
 				return 0;
@@ -2044,15 +2055,20 @@ int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len)
 
 		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
+			u32 p_off, p_len, copied;
+			struct page *p;
 			u8 *vaddr;
 
 			if (copy > len)
 				copy = len;
 
-			vaddr = kmap_atomic(skb_frag_page(frag));
-			memcpy(vaddr + frag->page_offset + offset - start,
-			       from, copy);
-			kunmap_atomic(vaddr);
+			skb_frag_foreach_page(frag,
+					      frag->page_offset + offset - start,
+					      copy, p, p_off, p_len, copied) {
+				vaddr = kmap_atomic(p);
+				memcpy(vaddr + p_off, from + copied, p_len);
+				kunmap_atomic(vaddr);
+			}
 
 			if ((len -= copy) == 0)
 				return 0;
@@ -2117,20 +2133,27 @@ __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
 
 		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
+			u32 p_off, p_len, copied;
+			struct page *p;
 			__wsum csum2;
 			u8 *vaddr;
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap_atomic(skb_frag_page(frag));
-			csum2 = ops->update(vaddr + frag->page_offset +
-					    offset - start, copy, 0);
-			kunmap_atomic(vaddr);
-			csum = ops->combine(csum, csum2, pos, copy);
+
+			skb_frag_foreach_page(frag,
+					      frag->page_offset + offset - start,
+					      copy, p, p_off, p_len, copied) {
+				vaddr = kmap_atomic(p);
+				csum2 = ops->update(vaddr + p_off, p_len, 0);
+				kunmap_atomic(vaddr);
+				csum = ops->combine(csum, csum2, pos, p_len);
+				pos += p_len;
+			}
+
 			if (!(len -= copy))
 				return csum;
 			offset += copy;
-			pos    += copy;
 		}
 		start = end;
 	}
@@ -2203,24 +2226,31 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 
 		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy = end - offset) > 0) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			u32 p_off, p_len, copied;
+			struct page *p;
 			__wsum csum2;
 			u8 *vaddr;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap_atomic(skb_frag_page(frag));
-			csum2 = csum_partial_copy_nocheck(vaddr +
-							  frag->page_offset +
-							  offset - start, to,
-							  copy, 0);
-			kunmap_atomic(vaddr);
-			csum = csum_block_add(csum, csum2, pos);
+
+			skb_frag_foreach_page(frag,
+					      frag->page_offset + offset - start,
+					      copy, p, p_off, p_len, copied) {
+				vaddr = kmap_atomic(p);
+				csum2 = csum_partial_copy_nocheck(vaddr + p_off,
+								  to + copied,
+								  p_len, 0);
+				kunmap_atomic(vaddr);
+				csum = csum_block_add(csum, csum2, pos);
+				pos += p_len;
+			}
+
 			if (!(len -= copy))
 				return csum;
 			offset += copy;
 			to     += copy;
-			pos    += copy;
 		}
 		start = end;
 	}
-- 
2.13.2.725.g09c95d1e9-goog
