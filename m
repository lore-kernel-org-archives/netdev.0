From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: SELinux/IP_PASSSEC regression in 4.13-rcX
Date: Mon, 24 Jul 2017 14:25:17 +0200
Message-ID: <1500899117.2458.2.camel@redhat.com>
References: <CAHC9VhS9QO8jGBodsSeQxxbgoxrmThRgbc3_m17h7gFmfP=GGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: selinux@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45450 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753370AbdGXMZT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 08:25:19 -0400
In-Reply-To: <CAHC9VhS9QO8jGBodsSeQxxbgoxrmThRgbc3_m17h7gFmfP=GGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2017-07-21 at 18:19 -0400, Paul Moore wrote:
> I've been seeing a SELinux regression with IP_PASSSEC on the v4.13-rcX
> kernels and finally tracked the problem down to the
> skb_release_head_state() call in __udp_queue_rcv_skb().  Looking at
> the code and the git log it would appear that the likely culprit is
> 0a463c78d25b ("udp: avoid a cache miss on dequeue
> "); it looks similar to IP option problem fixed in 0ddf3fb2c43d2.

Thank you for the report!
My bad, I completely missed that code path.

> From a SELinux/IP_PASSSEC point of view we need access to the skb->sp
> pointer to examine the SAs.  I'm posting this here without a patch
> because it isn't clear to me how you would like to fix the problem; my
> initial thought would be to simply make the skb_release_head_state()
> conditional on the skb->sp pointer, much like the IP options fix, but
> I'm not sure if you have a more clever idea.

Unfortunately explicitly checking skb->sp at skb free time will defeat
completely the intended optimization.

To preserve it, something like the following patch is required, could
you please test it in your environment?

Such patch is still prone to a kind of race, as only UDP packets
enqueued to the UDP socket after the setsockopt() will carry the
relevant cmsg info.

e.g. with the following event sequence:

<an UDP packet is enqueued to the revevant socket>
setsockopt(...,IP_CMSG_PASSSEC)
recvmsg(...);

the ancillary message data will not include the IP_CMSG_PASSSEC, while
kernel pre 0a463c78d25b will provide it. Do you think such behavior
will be acceptable?

If not, I fear a revert will be needed.

Cheers,

Paolo
---
diff --git a/include/net/udp.h b/include/net/udp.h
index 972ce4b..f109126 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -319,19 +319,24 @@ struct udp_dev_scratch {
 	bool csum_unnecessary;
 };
 
+static inline struct udp_dev_scratch* udp_skb_scratch(struct sk_buff *skb)
+{
+	return (struct udp_dev_scratch *)&skb->dev_scratch;
+}
+
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
index b057653..582c13e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1163,32 +1163,47 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
+#define UDP_SKB_IS_STATELESS 0x80000000
+
 #if BITS_PER_LONG == 64
 static void udp_set_dev_scratch(struct sk_buff *skb)
 {
-	struct udp_dev_scratch *scratch;
+	struct udp_dev_scratch *scratch = udp_skb_scratch(skb);
 
 	BUILD_BUG_ON(sizeof(struct udp_dev_scratch) > sizeof(long));
-	scratch = (struct udp_dev_scratch *)&skb->dev_scratch;
 	scratch->truesize = skb->truesize;
 	scratch->len = skb->len;
 	scratch->csum_unnecessary = !!skb_csum_unnecessary(skb);
 	scratch->is_linear = !skb_is_nonlinear(skb);
+	if (likely(!skb->_skb_refdst))
+		scratch->truesize |= UDP_SKB_IS_STATELESS;
 }
 
 static int udp_skb_truesize(struct sk_buff *skb)
 {
-	return ((struct udp_dev_scratch *)&skb->dev_scratch)->truesize;
+	return udp_skb_scratch(skb)->truesize & ~UDP_SKB_IS_STATELESS;
+}
+
+static bool udp_skb_has_head_state(struct sk_buff *skb)
+{
+	return !(udp_skb_scratch(skb)->truesize & UDP_SKB_IS_STATELESS);
 }
 #else
 static void udp_set_dev_scratch(struct sk_buff *skb)
 {
 	skb->dev_scratch = skb->truesize;
+	if (likely(!skb->_skb_refdst))
+		scratch->dev_scratch |= UDP_SKB_IS_STATELESS;
 }
 
 static int udp_skb_truesize(struct sk_buff *skb)
 {
-	return skb->dev_scratch;
+	return skb->dev_scratch & ~UDP_SKB_IS_STATELESS;
+}
+
+static bool udp_skb_has_head_state(struct sk_buff *skb)
+{
+	return !(skb->dev_scratch & UDP_SKB_IS_STATELESS);
 }
 #endif
 
@@ -1388,10 +1403,10 @@ void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
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
@@ -1784,11 +1799,12 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
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
+	if (likely(IPCB(skb)->opt.optlen == 0 &&
+	           !(inet_sk(sk)->cmsg_flags & IP_CMSG_PASSSEC)))
 		skb_release_head_state(skb);
 
 	rc = __udp_enqueue_schedule_skb(sk, skb);
