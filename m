From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] tcp: Remove debug macro of TCP_CHECK_TIMER
Date: Sun, 20 Feb 2011 15:55:45 +0800
Message-ID: <4D60C901.8050307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52690 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751731Ab1BTH6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 02:58:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now, TCP_CHECK_TIMER is not used for debuging, it does nothing.
And, it has been there for several years, maybe 6 years.

Remove it to keep code clearer.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/tcp.h    |    2 --
 net/ipv4/tcp.c       |    9 ---------
 net/ipv4/tcp_ipv4.c  |    5 -----
 net/ipv4/tcp_timer.c |    3 ---
 net/ipv6/tcp_ipv6.c  |    4 ----
 5 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index adfe6db..cda30ea 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1068,8 +1068,6 @@ static inline int tcp_paws_reject(const struct tcp_options_received *rx_opt,
 	return 1;
 }
 
-#define TCP_CHECK_TIMER(sk) do { } while (0)
-
 static inline void tcp_mib_init(struct net *net)
 {
 	/* See RFC 2012 */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f9867d2..a17a5a7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -873,9 +873,7 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 					flags);
 
 	lock_sock(sk);
-	TCP_CHECK_TIMER(sk);
 	res = do_tcp_sendpages(sk, &page, offset, size, flags);
-	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return res;
 }
@@ -916,7 +914,6 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	long timeo;
 
 	lock_sock(sk);
-	TCP_CHECK_TIMER(sk);
 
 	flags = msg->msg_flags;
 	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
@@ -1104,7 +1101,6 @@ wait_for_memory:
 out:
 	if (copied)
 		tcp_push(sk, flags, mss_now, tp->nonagle);
-	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return copied;
 
@@ -1123,7 +1119,6 @@ do_error:
 		goto out;
 out_err:
 	err = sk_stream_error(sk, flags, err);
-	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return err;
 }
@@ -1415,8 +1410,6 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	lock_sock(sk);
 
-	TCP_CHECK_TIMER(sk);
-
 	err = -ENOTCONN;
 	if (sk->sk_state == TCP_LISTEN)
 		goto out;
@@ -1767,12 +1760,10 @@ skip_copy:
 	/* Clean up data we have read: This will do ACK frames. */
 	tcp_cleanup_rbuf(sk, copied);
 
-	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return copied;
 
 out:
-	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return err;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e2b9be2..ef5a90b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1556,12 +1556,10 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		sock_rps_save_rxhash(sk, skb->rxhash);
-		TCP_CHECK_TIMER(sk);
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
 			goto reset;
 		}
-		TCP_CHECK_TIMER(sk);
 		return 0;
 	}
 
@@ -1583,13 +1581,10 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	} else
 		sock_rps_save_rxhash(sk, skb->rxhash);
 
-
-	TCP_CHECK_TIMER(sk);
 	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len)) {
 		rsk = sk;
 		goto reset;
 	}
-	TCP_CHECK_TIMER(sk);
 	return 0;
 
 reset:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 74a6aa0..ecd44b0 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -259,7 +259,6 @@ static void tcp_delack_timer(unsigned long data)
 		tcp_send_ack(sk);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKS);
 	}
-	TCP_CHECK_TIMER(sk);
 
 out:
 	if (tcp_memory_pressure)
@@ -481,7 +480,6 @@ static void tcp_write_timer(unsigned long data)
 		tcp_probe_timer(sk);
 		break;
 	}
-	TCP_CHECK_TIMER(sk);
 
 out:
 	sk_mem_reclaim(sk);
@@ -589,7 +587,6 @@ static void tcp_keepalive_timer (unsigned long data)
 		elapsed = keepalive_time_when(tp) - elapsed;
 	}
 
-	TCP_CHECK_TIMER(sk);
 	sk_mem_reclaim(sk);
 
 resched:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d6954e3..1d0ab55 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1636,10 +1636,8 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		opt_skb = skb_clone(skb, GFP_ATOMIC);
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
-		TCP_CHECK_TIMER(sk);
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
 			goto reset;
-		TCP_CHECK_TIMER(sk);
 		if (opt_skb)
 			goto ipv6_pktoptions;
 		return 0;
@@ -1667,10 +1665,8 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	TCP_CHECK_TIMER(sk);
 	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len))
 		goto reset;
-	TCP_CHECK_TIMER(sk);
 	if (opt_skb)
 		goto ipv6_pktoptions;
 	return 0;
-- 
1.6.3.3
