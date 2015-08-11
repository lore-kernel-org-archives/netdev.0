From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next v2] tcp: reduce cpu usage under tcp memory pressure when SO_SNDBUF is set
Date: Tue, 11 Aug 2015 14:38:46 +0000 (GMT)
Message-ID: <20150811143846.672A92039@prod-mail-relay10.akamai.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-175.deploy.static.akamaitechnologies.com ([23.79.238.175]:10892
	"EHLO prod-mail-xrelay07.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965056AbbHKOir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 10:38:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

When SO_SNDBUF is set and we are under tcp memory pressure, the effective write
buffer space can be much lower than what was set using SO_SNDBUF. For example,
we may have set the buffer to 100kb, but we may only be able to write 10kb. In
this scenario poll()/select()/epoll(), are going to continuously return POLLOUT,
followed by -EAGAIN from write() in a very tight loop.

Introduce sk->sk_effective_sndbuf, such that we can track the 'effective' size
of the sndbuf, when we have a short write due to memory pressure. By using the
sk->sk_effective_sndbuf instead of the sk->sk_sndbuf when we are under memory
pressure, we can delay the POLLOUT until 1/3 of the buffer clears as we normally
do. There is no issue here when SO_SNDBUF is not set, since the tcp layer will
auto tune the sk->sndbuf.

Although sk->sk_effective_sndbuf, and even sk->sk_sndbuf can change in
subsequent calls to tcp_poll() (queued via wakeups), we can guarantee that we
will eventually satisfy the write space check in all cases, since the write
queue will eventually drain to 0, and sk->sk_sndbuf and sk->sk_effective_sndbuf
will be non-zero when used in the write space check. If the write queue does not
drain to 0, then the client is not responding, and we will eventually timeout
the socket.

In my testing, this brought a single threaad's cpu usage down from 100% to ~1%
while maintaining the same level of throughput.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
Changes from V1:
	-Add READ_ONCE() in sk_stream_wspace() (Eric Dumazet)
	-Restrict sk_set_effective_sndbuf() to the write() path
---
 include/net/sock.h | 16 ++++++++++++++++
 net/core/sock.c    |  1 +
 net/core/stream.c  |  1 +
 net/ipv4/tcp.c     | 20 +++++++++++++++-----
 4 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 43c6abc..86598e4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -243,6 +243,8 @@ struct cg_proto;
   *	@sk_pacing_rate: Pacing rate (if supported by transport/packet scheduler)
   *	@sk_max_pacing_rate: Maximum pacing rate (%SO_MAX_PACING_RATE)
   *	@sk_sndbuf: size of send buffer in bytes
+  *	@sk_effective_sndbuf: Less than or equal to the size of sk_sndbuf when
+  *			      under memory pressure, 0 otherwise.
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
   *		   %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
   *	@sk_no_check_tx: %SO_NO_CHECK setting, set checksum in TX packets
@@ -380,6 +382,7 @@ struct sock {
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
+	int			sk_effective_sndbuf;
 	struct sk_buff_head	sk_write_queue;
 	kmemcheck_bitfield_begin(flags);
 	unsigned int		sk_shutdown  : 2,
@@ -779,6 +782,14 @@ static inline bool sk_acceptq_is_full(const struct sock *sk)
 	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
 }
 
+static inline void sk_set_effective_sndbuf(struct sock *sk)
+{
+	if (sk->sk_wmem_queued > sk->sk_sndbuf)
+		sk->sk_effective_sndbuf = sk->sk_sndbuf;
+	else
+		sk->sk_effective_sndbuf = sk->sk_wmem_queued;
+}
+
 /*
  * Compute minimal free write space needed to queue new packets.
  */
@@ -789,6 +800,11 @@ static inline int sk_stream_min_wspace(const struct sock *sk)
 
 static inline int sk_stream_wspace(const struct sock *sk)
 {
+	int effective_sndbuf = READ_ONCE(sk->sk_effective_sndbuf);
+
+	if (effective_sndbuf)
+		return effective_sndbuf - sk->sk_wmem_queued;
+
 	return sk->sk_sndbuf - sk->sk_wmem_queued;
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 193901d..4fce879 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2309,6 +2309,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_allocation	=	GFP_KERNEL;
 	sk->sk_rcvbuf		=	sysctl_rmem_default;
 	sk->sk_sndbuf		=	sysctl_wmem_default;
+	sk->sk_effective_sndbuf =	0;
 	sk->sk_state		=	TCP_CLOSE;
 	sk_set_socket(sk, sock);
 
diff --git a/net/core/stream.c b/net/core/stream.c
index d70f77a..7c175e7 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -32,6 +32,7 @@ void sk_stream_write_space(struct sock *sk)
 
 	if (sk_stream_is_writeable(sk) && sock) {
 		clear_bit(SOCK_NOSPACE, &sock->flags);
+		sk->sk_effective_sndbuf = 0;
 
 		rcu_read_lock();
 		wq = rcu_dereference(sk->sk_wq);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 45534a5..d935ad5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -923,8 +923,10 @@ new_segment:
 
 			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation,
 						  skb_queue_empty(&sk->sk_write_queue));
-			if (!skb)
+			if (!skb) {
+				sk_set_effective_sndbuf(sk);
 				goto wait_for_memory;
+			}
 
 			skb_entail(sk, skb);
 			copy = size_goal;
@@ -939,8 +941,10 @@ new_segment:
 			tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
-		if (!sk_wmem_schedule(sk, copy))
+		if (!sk_wmem_schedule(sk, copy)) {
+			sk_set_effective_sndbuf(sk);
 			goto wait_for_memory;
+		}
 
 		if (can_coalesce) {
 			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
@@ -1163,8 +1167,10 @@ new_segment:
 						  select_size(sk, sg),
 						  sk->sk_allocation,
 						  skb_queue_empty(&sk->sk_write_queue));
-			if (!skb)
+			if (!skb) {
+				sk_set_effective_sndbuf(sk);
 				goto wait_for_memory;
+			}
 
 			/*
 			 * Check whether we can use HW checksum.
@@ -1200,8 +1206,10 @@ new_segment:
 			int i = skb_shinfo(skb)->nr_frags;
 			struct page_frag *pfrag = sk_page_frag(sk);
 
-			if (!sk_page_frag_refill(sk, pfrag))
+			if (!sk_page_frag_refill(sk, pfrag)) {
+				sk_set_effective_sndbuf(sk);
 				goto wait_for_memory;
+			}
 
 			if (!skb_can_coalesce(skb, i, pfrag->page,
 					      pfrag->offset)) {
@@ -1214,8 +1222,10 @@ new_segment:
 
 			copy = min_t(int, copy, pfrag->size - pfrag->offset);
 
-			if (!sk_wmem_schedule(sk, copy))
+			if (!sk_wmem_schedule(sk, copy)) {
+				sk_set_effective_sndbuf(sk);
 				goto wait_for_memory;
+			}
 
 			err = skb_copy_to_page_nocache(sk, &msg->msg_iter, skb,
 						       pfrag->page,
-- 
1.8.2.rc2
