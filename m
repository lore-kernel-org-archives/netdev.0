From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: take care of misalignments
Date: Sun, 04 Dec 2011 08:39:53 +0100
Message-ID: <1322984393.2762.134.camel@edumazet-laptop>
References: <1322857369.2762.63.camel@edumazet-laptop>
	 <20111202.152426.447759025066188323.davem@davemloft.net>
	 <1322858756.2762.68.camel@edumazet-laptop>
	 <20111202.163024.1294014889349291295.davem@davemloft.net>
	 <1322924992.2762.117.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62784 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab1LDHj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 02:39:58 -0500
Received: by wgbdr13 with SMTP id dr13so4723744wgb.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 23:39:57 -0800 (PST)
In-Reply-To: <1322924992.2762.117.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here is the patch I tested this morning on my machine.

To simulate misalignement without a malicious peer, I did a quick hack
in tcp_ack() to ack N-1 bytes instead of N bytes every 10 acks.

Here is the patch suited for net tree.

Thanks

[PATCH] tcp: take care of misalignments

We discovered that TCP stack could retransmit misaligned skbs if a
malicious peer acknowledged sub MSS frame. This currently can happen
only if output interface is non SG enabled : If SG is enabled, tcp
builds headless skbs (all payload is included in fragments), so the tcp
trimming process only removes parts of skb fragments, header stay
aligned.

Some arches cant handle misalignments, so force a head reallocation and
shrink headroom to MAX_TCP_HEADER.

Dont care about misaligments on x86 and PPC (or other arches setting
NET_IP_ALIGN to 0)

This patch introduces __pskb_copy() which can specify the headroom of
new head, and pskb_copy() becomes a wrapper on top of __pskb_copy()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |   11 +++++++++--
 net/core/skbuff.c      |   11 ++++++-----
 net/ipv4/tcp_output.c  |   10 +++++++++-
 3 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fe86488..dd9a0cd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -561,8 +561,9 @@ extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
 extern struct sk_buff *skb_copy(const struct sk_buff *skb,
 				gfp_t priority);
-extern struct sk_buff *pskb_copy(struct sk_buff *skb,
-				 gfp_t gfp_mask);
+extern struct sk_buff *__pskb_copy(struct sk_buff *skb,
+				 int headroom, gfp_t gfp_mask);
+
 extern int	       pskb_expand_head(struct sk_buff *skb,
 					int nhead, int ntail,
 					gfp_t gfp_mask);
@@ -1824,6 +1825,12 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
 			    frag->page_offset + offset, size, dir);
 }
 
+static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
+					gfp_t gfp_mask)
+{
+	return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
+}
+
 /**
  *	skb_clone_writable - is the header of a clone writable
  *	@skb: buffer to check
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3c30ee4..21c7361 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -791,8 +791,9 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 EXPORT_SYMBOL(skb_copy);
 
 /**
- *	pskb_copy	-	create copy of an sk_buff with private head.
+ *	__pskb_copy	-	create copy of an sk_buff with private head.
  *	@skb: buffer to copy
+ *	@headroom: headroom of new skb
  *	@gfp_mask: allocation priority
  *
  *	Make a copy of both an &sk_buff and part of its data, located
@@ -803,16 +804,16 @@ EXPORT_SYMBOL(skb_copy);
  *	The returned buffer has a reference count of 1.
  */
 
-struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
+struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
 {
-	unsigned int size = skb_end_pointer(skb) - skb->head;
+	unsigned int size = skb_headlen(skb) + headroom;
 	struct sk_buff *n = alloc_skb(size, gfp_mask);
 
 	if (!n)
 		goto out;
 
 	/* Set the data pointer */
-	skb_reserve(n, skb_headroom(skb));
+	skb_reserve(n, headroom);
 	/* Set the tail pointer and length */
 	skb_put(n, skb_headlen(skb));
 	/* Copy the bytes */
@@ -848,7 +849,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 out:
 	return n;
 }
-EXPORT_SYMBOL(pskb_copy);
+EXPORT_SYMBOL(__pskb_copy);
 
 /**
  *	pskb_expand_head - reallocate header of &sk_buff
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 63170e2..0973631 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2147,7 +2147,15 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 
-	err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
+	/* make sure skb->data is aligned on arches that require it */
+	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3))) {
+		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
+						   GFP_ATOMIC);
+		err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
+			     -ENOBUFS;
+	} else {
+		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
+	}
 
 	if (err == 0) {
 		/* Update global TCP statistics. */
