From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: SELinux/IP_PASSSEC regression in 4.13-rcX
Date: Mon, 24 Jul 2017 18:09:15 +0200
Message-ID: <1500912555.2458.12.camel@redhat.com>
References: <CAHC9VhS9QO8jGBodsSeQxxbgoxrmThRgbc3_m17h7gFmfP=GGw@mail.gmail.com>
         <1500899117.2458.2.camel@redhat.com>
         <CAHC9VhRjju-_3V21x+BogdRg-brDho1g_HzW+0CvU0PbhEtQqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39332 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752336AbdGXQJR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 12:09:17 -0400
In-Reply-To: <CAHC9VhRjju-_3V21x+BogdRg-brDho1g_HzW+0CvU0PbhEtQqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2017-07-24 at 10:42 -0400, Paul Moore wrote:
> The change in behavior for userspace makes me a little nervous as
> there is no way of knowing how any random application may be coded.
> Even if we are confident that the majority of applications set
> IP_PASSSEC before calling bind(), we are likely still stuck with a few
> that will break, and that means a lot of hard to debug problem
> reports.
> 
> I would feel much more comfortable if we could preserve the existing behavior.

I agree, we must preserve the original behavior. 

Re-thinking about the problem, checking skb->sp in the BH, and storing
the status in the scratch area should both fix the issue in a sane way
and preserve the optimization.

Something like the code below. Could you please try in your
environment? (or point me to simple reproducer ;-) 

There are some cosmetics changes vs the previous iteration, but the
only relevant difference is that now the code always preserve skb->sb,
as per the pre-0a463c78d25b kernel behavior.

Thank you!

Paolo
---
diff --git a/include/net/udp.h b/include/net/udp.h
index 972ce4b..8d2c406 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -305,33 +305,44 @@ struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 /* UDP uses skb->dev_scratch to cache as much information as possible and avoid
  * possibly multiple cache miss on dequeue()
  */
-#if BITS_PER_LONG == 64
-
-/* truesize, len and the bit needed to compute skb_csum_unnecessary will be on
- * cold cache lines at recvmsg time.
- * skb->len can be stored on 16 bits since the udp header has been already
- * validated and pulled.
- */
 struct udp_dev_scratch {
-	u32 truesize;
+	/* skb->truesize and the stateless bit embeded in a single field;
+	 * do not use a bitfield since the compiler emits better/smaller code
+	 * this way
+	 */
+	u32 _tsize_state;
+
+#if BITS_PER_LONG == 64
+	/* len and the bit needed to compute skb_csum_unnecessary
+	 * will be on cold cache lines at recvmsg time.
+	 * skb->len can be stored on 16 bits since the udp header has been
+	 * already validated and pulled.
+	 */
 	u16 len;
 	bool is_linear;
 	bool csum_unnecessary;
+#endif
 };
 
+static inline struct udp_dev_scratch* udp_skb_scratch(struct sk_buff *skb)
+{
+	return (struct udp_dev_scratch *)&skb->dev_scratch;
+}
+
+#if BITS_PER_LONG == 64
 static inline unsigned int udp_skb_len(struct sk_buff *skb)
 {
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->len;
+	return udp_skb_scratch(skb)->len;
 }
 
 static inline bool udp_skb_csum_unnecessary(struct sk_buff *skb)
 {
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->csum_unnecessary;
+	return udp_skb_scratch(skb)->csum_unnecessary;
 }
 
 static inline bool udp_skb_is_linear(struct sk_buff *skb)
 {
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->is_linear;
+	return udp_skb_scratch(skb)->is_linear;
 }
 
 #else
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b057653..d243772 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1163,34 +1163,32 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
-#if BITS_PER_LONG == 64
+#define UDP_SKB_IS_STATELESS 0x80000000
+
 static void udp_set_dev_scratch(struct sk_buff *skb)
 {
-	struct udp_dev_scratch *scratch;
+	struct udp_dev_scratch *scratch = udp_skb_scratch(skb);
 
 	BUILD_BUG_ON(sizeof(struct udp_dev_scratch) > sizeof(long));
-	scratch = (struct udp_dev_scratch *)&skb->dev_scratch;
-	scratch->truesize = skb->truesize;
+	scratch->_tsize_state = skb->truesize;
+#if BITS_PER_LONG == 64
 	scratch->len = skb->len;
 	scratch->csum_unnecessary = !!skb_csum_unnecessary(skb);
 	scratch->is_linear = !skb_is_nonlinear(skb);
+#endif
+	if (likely(!skb->_skb_refdst))
+		scratch->_tsize_state |= UDP_SKB_IS_STATELESS;
 }
 
 static int udp_skb_truesize(struct sk_buff *skb)
 {
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->truesize;
-}
-#else
-static void udp_set_dev_scratch(struct sk_buff *skb)
-{
-	skb->dev_scratch = skb->truesize;
+	return udp_skb_scratch(skb)->_tsize_state & ~UDP_SKB_IS_STATELESS;
 }
 
-static int udp_skb_truesize(struct sk_buff *skb)
+static bool udp_skb_has_head_state(struct sk_buff *skb)
 {
-	return skb->dev_scratch;
+	return !(udp_skb_scratch(skb)->_tsize_state & UDP_SKB_IS_STATELESS);
 }
-#endif
 
 /* fully reclaim rmem/fwd memory allocated for skb */
 static void udp_rmem_release(struct sock *sk, int size, int partial,
@@ -1388,10 +1386,10 @@ void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
 		unlock_sock_fast(sk, slow);
 	}
 
-	/* we cleared the head states previously only if the skb lacks any IP
-	 * options, see __udp_queue_rcv_skb().
+	/* In the more common cases we cleared the head states previously,
+	 * see __udp_queue_rcv_skb().
 	 */
-	if (unlikely(IPCB(skb)->opt.optlen > 0))
+	if (unlikely(udp_skb_has_head_state(skb)))
 		skb_release_head_state(skb);
 	consume_stateless_skb(skb);
 }
@@ -1784,11 +1782,11 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_mark_napi_id_once(sk, skb);
 	}
 
-	/* At recvmsg() time we need skb->dst to process IP options-related
-	 * cmsg, elsewhere can we clear all pending head states while they are
-	 * hot in the cache
+	/* At recvmsg() time we may access skb->dst or skb->sp depending on
+	 * the IP options and the cmsg flags, elsewhere can we clear all
+	 * pending head states while they are hot in the cache
 	 */
-	if (likely(IPCB(skb)->opt.optlen == 0))
+	if (likely(IPCB(skb)->opt.optlen == 0 && !skb->sp))
 		skb_release_head_state(skb);
 
 	rc = __udp_enqueue_schedule_skb(sk, skb);
