From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: preserve head state for IP_CMSG_PASSSEC
Date: Tue, 25 Jul 2017 17:57:47 +0200
Message-ID: <0bd907843b74bc2112ad960f7d11e75ca095eee3.1500998196.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Paul Moore <paul@paul-moore.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45476 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752625AbdGYP72 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 11:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore reported a SELinux/IP_PASSSEC regression
caused by missing skb->sp at recvmsg() time. We need to
preserve the skb head state to process the IP_CMSG_PASSSEC
cmsg.

With this commit we avoid releasing the skb head state in the
BH even if a secpath is attached to the current skb, and stores
the skb status (with/without head states) in the scratch area,
so that we can access it at skb deallocation time, without
incurring in cache-miss penalties.

This also avoids misusing the skb CB for ipv6 packets,
as introduced by the commit 0ddf3fb2c43d ("udp: preserve
skb->dst if required for IP options processing").

Clean a bit the scratch area helpers implementation, to
reduce the code differences between 32 and 64 bits build.

Reported-by: Paul Moore <paul@paul-moore.com>
Fixes: 0a463c78d25b ("udp: avoid a cache miss on dequeue")
Fixes: 0ddf3fb2c43d ("udp: preserve skb->dst if required for IP options processing")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Tested-by: Paul Moore <paul@paul-moore.com>
---
 include/net/udp.h | 33 ++++++++++++++++++++++-----------
 net/ipv4/udp.c    | 38 ++++++++++++++++++--------------------
 2 files changed, 40 insertions(+), 31 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 972ce4baab6b..56ce2d2a612d 100644
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
+	/* skb->truesize and the stateless bit are embedded in a single field;
+	 * do not use a bitfield since the compiler emits better/smaller code
+	 * this way
+	 */
+	u32 _tsize_state;
+
+#if BITS_PER_LONG == 64
+	/* len and the bit needed to compute skb_csum_unnecessary
+	 * will be on cold cache lines at recvmsg time.
+	 * skb->len can be stored on 16 bits since the udp header has been
+	 * already validated and pulled.
+	 */
 	u16 len;
 	bool is_linear;
 	bool csum_unnecessary;
+#endif
 };
 
+static inline struct udp_dev_scratch *udp_skb_scratch(struct sk_buff *skb)
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
index b057653ceca9..d243772f6efc 100644
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
-	 * options, see __udp_queue_rcv_skb().
+	/* In the more common cases we cleared the head states previously,
+	 * see __udp_queue_rcv_skb().
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
-	 * cmsg, elsewhere can we clear all pending head states while they are
-	 * hot in the cache
+	/* At recvmsg() time we may access skb->dst or skb->sp depending on
+	 * the IP options and the cmsg flags, elsewhere can we clear all
+	 * pending head states while they are hot in the cache
 	 */
-	if (likely(IPCB(skb)->opt.optlen == 0))
+	if (likely(IPCB(skb)->opt.optlen == 0 && !skb->sp))
 		skb_release_head_state(skb);
 
 	rc = __udp_enqueue_schedule_skb(sk, skb);
-- 
2.13.3
