From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 net-next 2/2] tcp: reduce cpu usage when SO_SNDBUF is set
Date: Wed, 22 Jun 2016 11:32:51 -0400
Message-ID: <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
References: <cover.1466608332.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:52671 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752353AbcFVPfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 11:35:17 -0400
In-Reply-To: <cover.1466608332.git.jbaron@akamai.com>
In-Reply-To: <cover.1466608332.git.jbaron@akamai.com>
References: <cover.1466608332.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

When SO_SNDBUF is set and we are under tcp memory pressure, the effective
write buffer space can be much lower than what was set using SO_SNDBUF. For
example, we may have set the buffer to 100kb, but we may only be able to
write 10kb. In this scenario poll()/select()/epoll(), are going to
continuously return POLLOUT, followed by -EAGAIN from write(), and thus
result in a tight loop. Note that epoll in edge-triggered does not have
this issue since it only triggers once data has been ack'd. There is no
issue here when SO_SNDBUF is not set, since the tcp layer will auto tune
the sk->sndbuf.

Introduce a new socket flag, SOCK_SHORT_WRITE, such that we can mark the
socket when we have a short write due to memory pressure. By then testing
for SOCK_SHORT_WRITE in tcp_poll(), we hold off the POLLOUT until a
non-zero amount of data has been ack'd. In a previous approach:
http://marc.info/?l=linux-netdev&m=143930393211782&w=2, I had introduced a
new field in 'struct sock' to solve this issue, but its undesirable to add
bloat to 'struct sock'. We also could address this issue, by waiting for
the buffer to become completely empty, but that may reduce throughput since
the write buffer would be empty while waiting for subsequent writes. This
change brings us in line with the current epoll edge-trigger behavior for
the poll()/select() and epoll level-trigger.

We guarantee that SOCK_SHORT_WRITE will eventually clear, since when we set
SOCK_SHORT_WRITE, we make sure that sk_wmem_queued is non-zero and
SOCK_NOSPACE is set as well (in sk_stream_wait_memory()).

I tested this patch using 10,000 sockets, and setting SO_SNDBUF on the
server side, to induce tcp memory pressure. A single server thread reduced
its cpu usage from 100% to 19%, while maintaining the same level of
throughput.

Note: This is not a new issue, it has been this way for some time.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 include/net/sock.h   |  6 ++++++
 net/ipv4/tcp.c       | 26 +++++++++++++++++++-------
 net/ipv4/tcp_input.c |  3 ++-
 3 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 649d2a8c17fc..616e8e1a5d5d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -741,6 +741,7 @@ enum sock_flags {
 	SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
 	SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
 	SOCK_RCU_FREE, /* wait rcu grace period in sk_destruct() */
+	SOCK_SHORT_WRITE, /* Couldn't fill sndbuf due to memory pressure */
 };
 
 #define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
@@ -1114,6 +1115,11 @@ static inline bool sk_stream_is_writeable(const struct sock *sk)
 	       sk_stream_memory_free(sk);
 }
 
+static inline void sk_set_short_write(struct sock *sk)
+{
+	if (sk->sk_wmem_queued > 0 && sk_stream_is_writeable(sk))
+		sock_set_flag(sk, SOCK_SHORT_WRITE);
+}
 
 static inline bool sk_has_memory_pressure(const struct sock *sk)
 {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5c7ed147449c..4577a90d7d87 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -517,7 +517,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 			mask |= POLLIN | POLLRDNORM;
 
 		if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
-			if (sk_stream_is_writeable(sk)) {
+			if (sk_stream_is_writeable(sk) &&
+			    !sock_flag(sk, SOCK_SHORT_WRITE)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
 				sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
@@ -529,7 +530,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 				 * pairs with the input side.
 				 */
 				smp_mb__after_atomic();
-				if (sk_stream_is_writeable(sk))
+				if (sk_stream_is_writeable(sk) &&
+				    !sock_flag(sk, SOCK_SHORT_WRITE))
 					mask |= POLLOUT | POLLWRNORM;
 			}
 		} else
@@ -917,8 +919,10 @@ new_segment:
 
 			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation,
 						  skb_queue_empty(&sk->sk_write_queue));
-			if (!skb)
+			if (!skb) {
+				sk_set_short_write(sk);
 				goto wait_for_memory;
+			}
 
 			skb_entail(sk, skb);
 			copy = size_goal;
@@ -933,8 +937,10 @@ new_segment:
 			tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
-		if (!sk_wmem_schedule(sk, copy))
+		if (!sk_wmem_schedule(sk, copy)) {
+			sk_set_short_write(sk);
 			goto wait_for_memory;
+		}
 
 		if (can_coalesce) {
 			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
@@ -1176,8 +1182,10 @@ new_segment:
 						  select_size(sk, sg),
 						  sk->sk_allocation,
 						  skb_queue_empty(&sk->sk_write_queue));
-			if (!skb)
+			if (!skb) {
+				sk_set_short_write(sk);
 				goto wait_for_memory;
+			}
 
 			process_backlog = true;
 			/*
@@ -1214,8 +1222,10 @@ new_segment:
 			int i = skb_shinfo(skb)->nr_frags;
 			struct page_frag *pfrag = sk_page_frag(sk);
 
-			if (!sk_page_frag_refill(sk, pfrag))
+			if (!sk_page_frag_refill(sk, pfrag)) {
+				sk_set_short_write(sk);
 				goto wait_for_memory;
+			}
 
 			if (!skb_can_coalesce(skb, i, pfrag->page,
 					      pfrag->offset)) {
@@ -1228,8 +1238,10 @@ new_segment:
 
 			copy = min_t(int, copy, pfrag->size - pfrag->offset);
 
-			if (!sk_wmem_schedule(sk, copy))
+			if (!sk_wmem_schedule(sk, copy)) {
+				sk_set_short_write(sk);
 				goto wait_for_memory;
+			}
 
 			err = skb_copy_to_page_nocache(sk, &msg->msg_iter, skb,
 						       pfrag->page,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3ba526ecdeb9..e216f41a325b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4985,7 +4985,8 @@ static void tcp_new_space(struct sock *sk)
 static void tcp_check_space(struct sock *sk)
 {
 	if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
-		sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);
+		sk->sk_flags &= ~((1UL << SOCK_QUEUE_SHRUNK) |
+				  (1UL << SOCK_SHORT_WRITE));
 		/* pairs with tcp_poll() */
 		smp_mb();
 		if (sk->sk_socket &&
-- 
2.6.1
