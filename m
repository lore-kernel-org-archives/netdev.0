From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] mark assert error cases in skbuff unlikely
Date: Thu, 19 Jun 2003 12:24:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619122433.2dc720ec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

skbuff.h includes a number of checks for error conditions which can be optimized
by the compiler.  Use BUG_ON where possible.

--- include/linux/skbuff.h.orig	2003-06-19 12:10:27.000000000 -0700
+++ include/linux/skbuff.h	2003-06-19 11:44:43.000000000 -0700
@@ -802,12 +802,9 @@
 	skb_shinfo(skb)->nr_frags = i+1;
 }
 
-#define SKB_PAGE_ASSERT(skb) do { if (skb_shinfo(skb)->nr_frags) \
-					BUG(); } while (0)
-#define SKB_FRAG_ASSERT(skb) do { if (skb_shinfo(skb)->frag_list) \
-					BUG(); } while (0)
-#define SKB_LINEAR_ASSERT(skb) do { if (skb_is_nonlinear(skb)) \
-					BUG(); } while (0)
+#define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
+#define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->frag_list)
+#define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
 
 /*
  *	Add data to an sk_buff
@@ -836,7 +833,7 @@
 	SKB_LINEAR_ASSERT(skb);
 	skb->tail += len;
 	skb->len  += len;
-	if (skb->tail>skb->end)
+	if (unlikely(skb->tail>skb->end))
 		skb_over_panic(skb, len, current_text_addr());
 	return tmp;
 }
@@ -861,7 +858,7 @@
 {
 	skb->data -= len;
 	skb->len  += len;
-	if (skb->data<skb->head)
+	if (unlikely(skb->data<skb->head))
 		skb_under_panic(skb, len, current_text_addr());
 	return skb->data;
 }
@@ -869,8 +866,7 @@
 static inline char *__skb_pull(struct sk_buff *skb, unsigned int len)
 {
 	skb->len -= len;
-	if (skb->len < skb->data_len)
-		BUG();
+	BUG_ON(skb->len < skb->data_len);
 	return skb->data += len;
 }
 
@@ -1132,8 +1128,7 @@
 static inline void *kmap_skb_frag(const skb_frag_t *frag)
 {
 #ifdef CONFIG_HIGHMEM
-	if (in_irq())
-		BUG();
+	BUG_ON(in_irq());
 
 	local_bh_disable();
 #endif
