From: Jason Baron <jbaron@akamai.com>
Subject: [RFC PATCH net-next] tcp: reduce cpu usage under tcp memory pressure when SO_SNDBUF is set
Date: Fri,  7 Aug 2015 18:31:36 +0000 (GMT)
Message-ID: <20150807183136.D0DF92026@prod-mail-relay10.akamai.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-179.deploy.static.akamaitechnologies.com ([23.79.238.179]:27497
	"EHLO prod-mail-xrelay05.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1946186AbbHGS6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 14:58:01 -0400
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

In my testing, this brought a single threaad's cpu usage down from 100% to 1%
while maintaining the same level of throughput when under memory pressure.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 include/net/sock.h | 12 ++++++++++++
 net/core/sock.c    |  1 +
 net/core/stream.c  |  1 +
 net/ipv4/tcp.c     | 10 +++++++---
 4 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 43c6abc..ca49415 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -380,6 +380,7 @@ struct sock {
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
+	int			sk_effective_sndbuf;
 	struct sk_buff_head	sk_write_queue;
 	kmemcheck_bitfield_begin(flags);
 	unsigned int		sk_shutdown  : 2,
@@ -779,6 +780,14 @@ static inline bool sk_acceptq_is_full(const struct sock *sk)
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
@@ -789,6 +798,9 @@ static inline int sk_stream_min_wspace(const struct sock *sk)
 
 static inline int sk_stream_wspace(const struct sock *sk)
 {
+	if (sk->sk_effective_sndbuf)
+		return sk->sk_effective_sndbuf - sk->sk_wmem_queued;
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
index 45534a5..9e7f0a5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -845,6 +845,7 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp,
 		sk->sk_prot->enter_memory_pressure(sk);
 		sk_stream_moderate_sndbuf(sk);
 	}
+	sk_set_effective_sndbuf(sk);
 	return NULL;
 }
 
@@ -939,9 +940,10 @@ new_segment:
 			tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
-		if (!sk_wmem_schedule(sk, copy))
+		if (!sk_wmem_schedule(sk, copy)) {
+			sk_set_effective_sndbuf(sk);
 			goto wait_for_memory;
-
+		}
 		if (can_coalesce) {
 			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 		} else {
@@ -1214,8 +1216,10 @@ new_segment:
 
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
