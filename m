From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove k{un}map_skb_frag()
Date: Thu, 05 Apr 2012 11:35:15 +0200
Message-ID: <1333618515.6309.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59769 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407Ab2DEJfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 05:35:25 -0400
Received: by eekc41 with SMTP id c41so377161eek.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 02:35:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 3e4d3af501 (mm: stack based kmap_atomic()) we dont have to
disable BH anymore while mapping skb frags.

We can remove  kmap_skb_frag() / kunmap_skb_frag() helpers and use
kmap_atomic() / kunmap_atomic()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/appletalk/ddp.c |    6 +++---
 net/core/kmap_skb.h |   19 -------------------
 net/core/skbuff.c   |   42 +++++++++++++++++++++---------------------
 3 files changed, 24 insertions(+), 43 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index bfa9ab9..0301b32 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -63,7 +63,7 @@
 #include <net/tcp_states.h>
 #include <net/route.h>
 #include <linux/atalk.h>
-#include "../core/kmap_skb.h"
+#include <linux/highmem.h>
 
 struct datalink_proto *ddp_dl, *aarp_dl;
 static const struct proto_ops atalk_dgram_ops;
@@ -960,10 +960,10 @@ static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap_skb_frag(frag);
+			vaddr = kmap_atomic(skb_frag_page(frag));
 			sum = atalk_sum_partial(vaddr + frag->page_offset +
 						  offset - start, copy, sum);
-			kunmap_skb_frag(vaddr);
+			kunmap_atomic(vaddr);
 
 			if (!(len -= copy))
 				return sum;
diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
deleted file mode 100644
index 52d0a44..0000000
--- a/net/core/kmap_skb.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#include <linux/highmem.h>
-
-static inline void *kmap_skb_frag(const skb_frag_t *frag)
-{
-#ifdef CONFIG_HIGHMEM
-	BUG_ON(in_irq());
-
-	local_bh_disable();
-#endif
-	return kmap_atomic(skb_frag_page(frag));
-}
-
-static inline void kunmap_skb_frag(void *vaddr)
-{
-	kunmap_atomic(vaddr);
-#ifdef CONFIG_HIGHMEM
-	local_bh_enable();
-#endif
-}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a690cae..b2595ad 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -68,8 +68,7 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <trace/events/skb.h>
-
-#include "kmap_skb.h"
+#include <linux/highmem.h>
 
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
@@ -708,10 +707,10 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 			}
 			return -ENOMEM;
 		}
-		vaddr = kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
+		vaddr = kmap_atomic(skb_frag_page(f));
 		memcpy(page_address(page),
 		       vaddr + f->page_offset, skb_frag_size(f));
-		kunmap_skb_frag(vaddr);
+		kunmap_atomic(vaddr);
 		page->private = (unsigned long)head;
 		head = page;
 	}
@@ -1486,21 +1485,22 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		end = start + skb_frag_size(f);
 		if ((copy = end - offset) > 0) {
 			u8 *vaddr;
 
 			if (copy > len)
 				copy = len;
 
-			vaddr = kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
+			vaddr = kmap_atomic(skb_frag_page(f));
 			memcpy(to,
-			       vaddr + skb_shinfo(skb)->frags[i].page_offset+
-			       offset - start, copy);
-			kunmap_skb_frag(vaddr);
+			       vaddr + f->page_offset + offset - start,
+			       copy);
+			kunmap_atomic(vaddr);
 
 			if ((len -= copy) == 0)
 				return 0;
@@ -1805,10 +1805,10 @@ int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len)
 			if (copy > len)
 				copy = len;
 
-			vaddr = kmap_skb_frag(frag);
+			vaddr = kmap_atomic(skb_frag_page(frag));
 			memcpy(vaddr + frag->page_offset + offset - start,
 			       from, copy);
-			kunmap_skb_frag(vaddr);
+			kunmap_atomic(vaddr);
 
 			if ((len -= copy) == 0)
 				return 0;
@@ -1868,21 +1868,21 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		WARN_ON(start > offset + len);
 
-		end = start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
 			__wsum csum2;
 			u8 *vaddr;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap_skb_frag(frag);
+			vaddr = kmap_atomic(skb_frag_page(frag));
 			csum2 = csum_partial(vaddr + frag->page_offset +
 					     offset - start, copy, 0);
-			kunmap_skb_frag(vaddr);
+			kunmap_atomic(vaddr);
 			csum = csum_block_add(csum, csum2, pos);
 			if (!(len -= copy))
 				return csum;
@@ -1954,12 +1954,12 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap_skb_frag(frag);
+			vaddr = kmap_atomic(skb_frag_page(frag));
 			csum2 = csum_partial_copy_nocheck(vaddr +
 							  frag->page_offset +
 							  offset - start, to,
 							  copy, 0);
-			kunmap_skb_frag(vaddr);
+			kunmap_atomic(vaddr);
 			csum = csum_block_add(csum, csum2, pos);
 			if (!(len -= copy))
 				return csum;
@@ -2479,7 +2479,7 @@ next_skb:
 
 		if (abs_offset < block_limit) {
 			if (!st->frag_data)
-				st->frag_data = kmap_skb_frag(frag);
+				st->frag_data = kmap_atomic(skb_frag_page(frag));
 
 			*data = (u8 *) st->frag_data + frag->page_offset +
 				(abs_offset - st->stepped_offset);
@@ -2488,7 +2488,7 @@ next_skb:
 		}
 
 		if (st->frag_data) {
-			kunmap_skb_frag(st->frag_data);
+			kunmap_atomic(st->frag_data);
 			st->frag_data = NULL;
 		}
 
@@ -2497,7 +2497,7 @@ next_skb:
 	}
 
 	if (st->frag_data) {
-		kunmap_skb_frag(st->frag_data);
+		kunmap_atomic(st->frag_data);
 		st->frag_data = NULL;
 	}
 
@@ -2525,7 +2525,7 @@ EXPORT_SYMBOL(skb_seq_read);
 void skb_abort_seq_read(struct skb_seq_state *st)
 {
 	if (st->frag_data)
-		kunmap_skb_frag(st->frag_data);
+		kunmap_atomic(st->frag_data);
 }
 EXPORT_SYMBOL(skb_abort_seq_read);
 
