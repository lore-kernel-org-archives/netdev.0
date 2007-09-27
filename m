From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] Make TCP prequeue configurable
Date: Fri, 28 Sep 2007 00:08:33 +0200
Message-ID: <46FC29E1.9010809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050009010505050807050003"
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:53376 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757347AbXI0WIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 18:08:41 -0400
Received: from [192.168.30.15] (153.237.66-86.rev.gaoland.net [86.66.237.153] (may be forged))
	by gw1.cosmosbay.com (8.13.7/8.13.7) with ESMTP id l8RM8Y9O017500
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 00:08:39 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050009010505050807050003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all

I am sure some of you are going to tell me that prequeue is not
all black :)

Thank you

[RFC] Make TCP prequeue configurable

The TCP prequeue thing is based on old facts, and has drawbacks.

1) It adds 48 bytes per 'struct tcp_sock'
2) It adds some ugly code in hot paths
3) It has a small hit ratio on typical servers using many sockets
4) It may have a high hit ratio on UP machines running one process,
    where the prequeue adds litle gain. (In fact, letting the user
    doing the copy after being woke up is better for cache reuse)
5) Doing a copy to user in softirq handler is not good, because of
    potential page faults :(
6) Maybe the NET_DMA thing is the only thing that might need prequeue.

This patch introduces a CONFIG_TCP_PREQUEUE, automatically selected if 
CONFIG_NET_DMA is on.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------050009010505050807050003
Content-Type: text/plain;
 name="net_prequeue.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net_prequeue.patch"

diff --git a/drivers/dma/Kconfig b/drivers/dma/Kconfig
index 8f670da..14e3f01 100644
--- a/drivers/dma/Kconfig
+++ b/drivers/dma/Kconfig
@@ -16,6 +16,7 @@ comment "DMA Clients"
 config NET_DMA
 	bool "Network: TCP receive copy offload"
 	depends on DMA_ENGINE && NET
+	select TCP_PREQUEUE
 	default y
 	---help---
 	  This enables the use of DMA engines in the network stack to
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c6b9f92..844a05e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -268,11 +268,13 @@ struct tcp_sock {
 
 	/* Data for direct copy to user */
 	struct {
+#ifdef CONFIG_TCP_PREQUEUE
 		struct sk_buff_head	prequeue;
 		struct task_struct	*task;
 		struct iovec		*iov;
 		int			memory;
 		int			len;
+#endif
 #ifdef CONFIG_NET_DMA
 		/* members for async copy */
 		struct dma_chan		*dma_chan;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 185c7ec..3430d8e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -835,10 +835,12 @@ static inline int tcp_checksum_complete(struct sk_buff *skb)
 
 static inline void tcp_prequeue_init(struct tcp_sock *tp)
 {
+#ifdef CONFIG_TCP_PREQUEUE
 	tp->ucopy.task = NULL;
 	tp->ucopy.len = 0;
 	tp->ucopy.memory = 0;
 	skb_queue_head_init(&tp->ucopy.prequeue);
+#endif
 #ifdef CONFIG_NET_DMA
 	tp->ucopy.dma_chan = NULL;
 	tp->ucopy.wakeup = 0;
@@ -857,6 +859,7 @@ static inline void tcp_prequeue_init(struct tcp_sock *tp)
  */
 static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 {
+#ifdef CONFIG_TCP_PREQUEUE
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (!sysctl_tcp_low_latency && tp->ucopy.task) {
@@ -882,6 +885,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 		}
 		return 1;
 	}
+#endif
 	return 0;
 }
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index fb79097..b770829 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -616,5 +616,20 @@ config TCP_MD5SIG
 
 	  If unsure, say N.
 
+config TCP_PREQUEUE
+	bool "Enable TCP prequeue"
+	default n
+	---help---
+	  TCP PREQUEUE is an 'optimization' loosely based on the famous
+	  "30 instruction TCP receive" Van Jacobson mail.
+	  Van's trick is to deposit buffers into socket queue
+	  on a device interrupt, to call tcp_recv function
+	  on the receive process context and checksum and copy
+	  the buffer to user space. smart...
+	 
+	  Some people believe this 'optimization' is not really needed
+	  but for some benchmarks. Also, taking potential pagefaults in 
+	  softirq handler seems a high price to pay.
+
 source "net/ipv4/ipvs/Kconfig"
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 7e74011..8659533 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -994,6 +994,7 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 		tcp_send_ack(sk);
 }
 
+#ifdef CONFIG_TCP_PREQUEUE
 static void tcp_prequeue_process(struct sock *sk)
 {
 	struct sk_buff *skb;
@@ -1011,6 +1012,7 @@ static void tcp_prequeue_process(struct sock *sk)
 	/* Clear memory counter. */
 	tp->ucopy.memory = 0;
 }
+#endif
 
 static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 {
@@ -1251,6 +1253,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 		tcp_cleanup_rbuf(sk, copied);
 
+#ifdef CONFIG_TCP_PREQUEUE
 		if (!sysctl_tcp_low_latency && tp->ucopy.task == user_recv) {
 			/* Install new reader */
 			if (!user_recv && !(flags & (MSG_TRUNC | MSG_PEEK))) {
@@ -1295,7 +1298,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 			/* __ Set realtime policy in scheduler __ */
 		}
-
+#endif
 		if (copied >= target) {
 			/* Do not sleep, just process backlog. */
 			release_sock(sk);
@@ -1307,6 +1310,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		tp->ucopy.wakeup = 0;
 #endif
 
+#ifdef CONFIG_TCP_PREQUEUE
 		if (user_recv) {
 			int chunk;
 
@@ -1330,6 +1334,7 @@ do_prequeue:
 				}
 			}
 		}
+#endif
 		if ((flags & MSG_PEEK) && peek_seq != tp->copied_seq) {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK.\n",
@@ -1430,6 +1435,7 @@ skip_copy:
 		break;
 	} while (len > 0);
 
+#ifdef CONFIG_TCP_PREQUEUE
 	if (user_recv) {
 		if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 			int chunk;
@@ -1448,6 +1454,7 @@ skip_copy:
 		tp->ucopy.task = NULL;
 		tp->ucopy.len = 0;
 	}
+#endif
 
 #ifdef CONFIG_NET_DMA
 	if (tp->ucopy.dma_chan) {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bbad2cd..85d3a5c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3467,6 +3467,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 			goto out_of_window;
 
 		/* Ok. In sequence. In window. */
+#ifdef CONFIG_TCP_PREQUEUE
 		if (tp->ucopy.task == current &&
 		    tp->copied_seq == tp->rcv_nxt && tp->ucopy.len &&
 		    sock_owned_by_user(sk) && !tp->urg_data) {
@@ -3484,7 +3485,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 			}
 			local_bh_disable();
 		}
-
+#endif
 		if (eaten <= 0) {
 queue_and_out:
 			if (eaten < 0 &&
@@ -4078,6 +4079,7 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
 	}
 }
 
+#ifdef CONFIG_TCP_PREQUEUE
 static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -4100,6 +4102,7 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 	local_bh_disable();
 	return err;
 }
+#endif
 
 static __sum16 __tcp_checksum_complete_user(struct sock *sk, struct sk_buff *skb)
 {
@@ -4279,8 +4282,9 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			}
 		} else {
 			int eaten = 0;
-			int copied_early = 0;
 
+#ifdef CONFIG_TCP_PREQUEUE
+			int copied_early = 0;
 			if (tp->copied_seq == tp->rcv_nxt &&
 			    len - tcp_header_len <= tp->ucopy.len) {
 #ifdef CONFIG_NET_DMA
@@ -4315,6 +4319,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				if (copied_early)
 					tcp_cleanup_rbuf(sk, skb->len);
 			}
+#endif
 			if (!eaten) {
 				if (tcp_checksum_complete_user(sk, skb))
 					goto csum_error;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9c94627..7ac5bc1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1916,8 +1916,10 @@ int tcp_v4_destroy_sock(struct sock *sk)
 	__skb_queue_purge(&sk->sk_async_wait_queue);
 #endif
 
+#ifdef CONFIG_TCP_PREQUEUE
 	/* Clean prequeue, it must be empty really */
 	__skb_queue_purge(&tp->ucopy.prequeue);
+#endif
 
 	/* Clean up a referenced TCP bind bucket. */
 	if (inet_csk(sk)->icsk_bind_hash)
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index e9b151b..5f3b38c 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -167,7 +167,9 @@ static int tcp_write_timeout(struct sock *sk)
 static void tcp_delack_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock*)data;
+#ifdef CONFIG_TCP_PREQUEUE
 	struct tcp_sock *tp = tcp_sk(sk);
+#endif
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	bh_lock_sock(sk);
@@ -190,6 +192,7 @@ static void tcp_delack_timer(unsigned long data)
 	}
 	icsk->icsk_ack.pending &= ~ICSK_ACK_TIMER;
 
+#ifdef CONFIG_TCP_PREQUEUE
 	if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 		struct sk_buff *skb;
 
@@ -200,6 +203,7 @@ static void tcp_delack_timer(unsigned long data)
 
 		tp->ucopy.memory = 0;
 	}
+#endif
 
 	if (inet_csk_ack_scheduled(sk)) {
 		if (!icsk->icsk_ack.pingpong) {

--------------050009010505050807050003--
