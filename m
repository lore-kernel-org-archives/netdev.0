From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 3/4] [TCP]: using new interface
Date: Sun, 30 Dec 2007 03:53:53 -0500
Message-ID: <47775CA1.10307@redhat.com>
References: <47775B25.7020401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net,
	Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	vladislav.yasevich@hp.com, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127AbXL3I7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 03:59:51 -0500
In-Reply-To: <47775B25.7020401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces present memory accounting calls with new interface
in TCP.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Cc: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/tcp.h     |    4 ++--
 net/ipv4/tcp.c        |   23 ++++++++++++-----------
 net/ipv4/tcp_input.c  |   26 +++++++++++++-------------
 net/ipv4/tcp_output.c |   26 ++++++++++++++++----------
 net/ipv4/tcp_timer.c  |    8 ++++----
 5 files changed, 47 insertions(+), 40 deletions(-)

diff -pruN net-2.6.25-t12t19m-p2/include/net/tcp.h net-2.6.25-t12t19m-p3/include/net/tcp.h
--- net-2.6.25-t12t19m-p2/include/net/tcp.h	2007-12-27 10:18:58.000000000 -0500
+++ net-2.6.25-t12t19m-p3/include/net/tcp.h	2007-12-29 20:49:59.000000000 -0500
@@ -1196,8 +1196,8 @@ static inline void tcp_write_queue_purge
 	struct sk_buff *skb;

 	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
-		sk_stream_free_skb(sk, skb);
-	sk_stream_mem_reclaim(sk);
+		sk_wmem_free_skb(sk, skb);
+	sk_mem_reclaim(sk);
 }

 static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
diff -pruN net-2.6.25-t12t19m-p2/net/ipv4/tcp.c net-2.6.25-t12t19m-p3/net/ipv4/tcp.c
--- net-2.6.25-t12t19m-p2/net/ipv4/tcp.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p3/net/ipv4/tcp.c	2007-12-29 20:49:59.000000000 -0500
@@ -308,7 +308,7 @@ struct tcp_splice_state {
 /*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
- * All the sk_stream_mem_schedule() is of this nature: accounting
+ * All the __sk_mem_schedule() is of this nature: accounting
  * is strict, actions are advisory and have some latency.
  */
 int tcp_memory_pressure __read_mostly;
@@ -485,7 +485,8 @@ static inline void skb_entail(struct soc
 	tcb->sacked  = 0;
 	skb_header_release(skb);
 	tcp_add_write_queue_tail(sk, skb);
-	sk_charge_skb(sk, skb);
+	sk->sk_wmem_queued += skb->truesize;
+	sk_mem_charge(sk, skb->truesize);
 	if (tp->nonagle & TCP_NAGLE_PUSH)
 		tp->nonagle &= ~TCP_NAGLE_PUSH;
 }
@@ -638,7 +639,7 @@ struct sk_buff *sk_stream_alloc_skb(stru

 	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
 	if (skb) {
-		if (sk_stream_wmem_schedule(sk, skb->truesize)) {
+		if (sk_wmem_schedule(sk, skb->truesize)) {
 			/*
 			 * Make sure that we have exactly size bytes
 			 * available to the caller, no more, no less.
@@ -707,7 +708,7 @@ new_segment:
 			tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
-		if (!sk_stream_wmem_schedule(sk, copy))
+		if (!sk_wmem_schedule(sk, copy))
 			goto wait_for_memory;

 		if (can_coalesce) {
@@ -721,7 +722,7 @@ new_segment:
 		skb->data_len += copy;
 		skb->truesize += copy;
 		sk->sk_wmem_queued += copy;
-		sk->sk_forward_alloc -= copy;
+		sk_mem_charge(sk, copy);
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
@@ -928,7 +929,7 @@ new_segment:
 				if (copy > PAGE_SIZE - off)
 					copy = PAGE_SIZE - off;

-				if (!sk_stream_wmem_schedule(sk, copy))
+				if (!sk_wmem_schedule(sk, copy))
 					goto wait_for_memory;

 				if (!page) {
@@ -1019,7 +1020,7 @@ do_fault:
 		 * reset, where we can be unlinking the send_head.
 		 */
 		tcp_check_send_head(sk, skb);
-		sk_stream_free_skb(sk, skb);
+		sk_wmem_free_skb(sk, skb);
 	}

 do_error:
@@ -1738,7 +1739,7 @@ void tcp_close(struct sock *sk, long tim
 		__kfree_skb(skb);
 	}

-	sk_stream_mem_reclaim(sk);
+	sk_mem_reclaim(sk);

 	/* As outlined in RFC 2525, section 2.17, we send a RST here because
 	 * data was lost. To witness the awful effects of the old behavior of
@@ -1841,7 +1842,7 @@ adjudge_to_death:
 		}
 	}
 	if (sk->sk_state != TCP_CLOSE) {
-		sk_stream_mem_reclaim(sk);
+		sk_mem_reclaim(sk);
 		if (tcp_too_many_orphans(sk,
 				atomic_read(sk->sk_prot->orphan_count))) {
 			if (net_ratelimit())
@@ -2658,11 +2659,11 @@ void __init tcp_init(void)
 	limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
 	max_share = min(4UL*1024*1024, limit);

-	sysctl_tcp_wmem[0] = SK_STREAM_MEM_QUANTUM;
+	sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
 	sysctl_tcp_wmem[1] = 16*1024;
 	sysctl_tcp_wmem[2] = max(64*1024, max_share);

-	sysctl_tcp_rmem[0] = SK_STREAM_MEM_QUANTUM;
+	sysctl_tcp_rmem[0] = SK_MEM_QUANTUM;
 	sysctl_tcp_rmem[1] = 87380;
 	sysctl_tcp_rmem[2] = max(87380, max_share);

diff -pruN net-2.6.25-t12t19m-p2/net/ipv4/tcp_input.c net-2.6.25-t12t19m-p3/net/ipv4/tcp_input.c
--- net-2.6.25-t12t19m-p2/net/ipv4/tcp_input.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p3/net/ipv4/tcp_input.c	2007-12-29 20:49:59.000000000 -0500
@@ -591,7 +591,7 @@ static void tcp_event_data_recv(struct s
 			 * restart window, so that we send ACKs quickly.
 			 */
 			tcp_incr_quickack(sk);
-			sk_stream_mem_reclaim(sk);
+			sk_mem_reclaim(sk);
 		}
 	}
 	icsk->icsk_ack.lrcvtime = now;
@@ -2848,7 +2848,7 @@ static int tcp_clean_rtx_queue(struct so
 			break;

 		tcp_unlink_write_queue(skb, sk);
-		sk_stream_free_skb(sk, skb);
+		sk_wmem_free_skb(sk, skb);
 		tcp_clear_all_retrans_hints(tp);
 	}

@@ -3564,7 +3564,7 @@ static void tcp_fin(struct sk_buff *skb,
 	__skb_queue_purge(&tp->out_of_order_queue);
 	if (tcp_is_sack(tp))
 		tcp_sack_reset(&tp->rx_opt);
-	sk_stream_mem_reclaim(sk);
+	sk_mem_reclaim(sk);

 	if (!sock_flag(sk, SOCK_DEAD)) {
 		sk->sk_state_change(sk);
@@ -3847,12 +3847,12 @@ static void tcp_data_queue(struct sock *
 queue_and_out:
 			if (eaten < 0 &&
 			    (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-			     !sk_stream_rmem_schedule(sk, skb))) {
+			     !sk_rmem_schedule(sk, skb->truesize))) {
 				if (tcp_prune_queue(sk) < 0 ||
-				    !sk_stream_rmem_schedule(sk, skb))
+				    !sk_rmem_schedule(sk, skb->truesize))
 					goto drop;
 			}
-			sk_stream_set_owner_r(skb, sk);
+			skb_set_owner_r(skb, sk);
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 		}
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
@@ -3921,9 +3921,9 @@ drop:
 	TCP_ECN_check_ce(tp, skb);

 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    !sk_stream_rmem_schedule(sk, skb)) {
+	    !sk_rmem_schedule(sk, skb->truesize)) {
 		if (tcp_prune_queue(sk) < 0 ||
-		    !sk_stream_rmem_schedule(sk, skb))
+		    !sk_rmem_schedule(sk, skb->truesize))
 			goto drop;
 	}

@@ -3934,7 +3934,7 @@ drop:
 	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
 		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);

-	sk_stream_set_owner_r(skb, sk);
+	skb_set_owner_r(skb, sk);

 	if (!skb_peek(&tp->out_of_order_queue)) {
 		/* Initial out of order segment, build 1 SACK. */
@@ -4076,7 +4076,7 @@ tcp_collapse(struct sock *sk, struct sk_
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
 		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
 		__skb_insert(nskb, skb->prev, skb, list);
-		sk_stream_set_owner_r(nskb, sk);
+		skb_set_owner_r(nskb, sk);

 		/* Copy data, releasing collapsed skbs. */
 		while (copy > 0) {
@@ -4174,7 +4174,7 @@ static int tcp_prune_queue(struct sock *
 		     sk->sk_receive_queue.next,
 		     (struct sk_buff*)&sk->sk_receive_queue,
 		     tp->copied_seq, tp->rcv_nxt);
-	sk_stream_mem_reclaim(sk);
+	sk_mem_reclaim(sk);

 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf)
 		return 0;
@@ -4194,7 +4194,7 @@ static int tcp_prune_queue(struct sock *
 		 */
 		if (tcp_is_sack(tp))
 			tcp_sack_reset(&tp->rx_opt);
-		sk_stream_mem_reclaim(sk);
+		sk_mem_reclaim(sk);
 	}

 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf)
@@ -4696,7 +4696,7 @@ int tcp_rcv_established(struct sock *sk,
 				/* Bulk data transfer: receiver */
 				__skb_pull(skb,tcp_header_len);
 				__skb_queue_tail(&sk->sk_receive_queue, skb);
-				sk_stream_set_owner_r(skb, sk);
+				skb_set_owner_r(skb, sk);
 				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 			}

diff -pruN net-2.6.25-t12t19m-p2/net/ipv4/tcp_output.c net-2.6.25-t12t19m-p3/net/ipv4/tcp_output.c
--- net-2.6.25-t12t19m-p2/net/ipv4/tcp_output.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p3/net/ipv4/tcp_output.c	2007-12-29 20:49:59.000000000 -0500
@@ -637,7 +637,8 @@ static void tcp_queue_skb(struct sock *s
 	tp->write_seq = TCP_SKB_CB(skb)->end_seq;
 	skb_header_release(skb);
 	tcp_add_write_queue_tail(sk, skb);
-	sk_charge_skb(sk, skb);
+	sk->sk_wmem_queued += skb->truesize;
+	sk_mem_charge(sk, skb->truesize);
 }

 static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb, unsigned int mss_now)
@@ -701,7 +702,8 @@ int tcp_fragment(struct sock *sk, struct
 	if (buff == NULL)
 		return -ENOMEM; /* We'll just try again later. */

-	sk_charge_skb(sk, buff);
+	sk->sk_wmem_queued += buff->truesize;
+	sk_mem_charge(sk, buff->truesize);
 	nlen = skb->len - len - nsize;
 	buff->truesize += nlen;
 	skb->truesize -= nlen;
@@ -825,7 +827,7 @@ int tcp_trim_head(struct sock *sk, struc

 	skb->truesize	     -= len;
 	sk->sk_wmem_queued   -= len;
-	sk->sk_forward_alloc += len;
+	sk_mem_uncharge(sk, len);
 	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);

 	/* Any change of skb->len requires recalculation of tso
@@ -1197,7 +1199,8 @@ static int tso_fragment(struct sock *sk,
 	if (unlikely(buff == NULL))
 		return -ENOMEM;

-	sk_charge_skb(sk, buff);
+	sk->sk_wmem_queued += buff->truesize;
+	sk_mem_charge(sk, buff->truesize);
 	buff->truesize += nlen;
 	skb->truesize -= nlen;

@@ -1350,7 +1353,8 @@ static int tcp_mtu_probe(struct sock *sk
 	/* We're allowed to probe.  Build it now. */
 	if ((nskb = sk_stream_alloc_skb(sk, probe_size, GFP_ATOMIC)) == NULL)
 		return -1;
-	sk_charge_skb(sk, nskb);
+	sk->sk_wmem_queued += nskb->truesize;
+	sk_mem_charge(sk, nskb->truesize);

 	skb = tcp_send_head(sk);

@@ -1377,7 +1381,7 @@ static int tcp_mtu_probe(struct sock *sk
 			 * Throw it away. */
 			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags;
 			tcp_unlink_write_queue(skb, sk);
-			sk_stream_free_skb(sk, skb);
+			sk_wmem_free_skb(sk, skb);
 		} else {
 			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags &
 						   ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
@@ -1744,7 +1748,7 @@ static void tcp_retrans_try_collapse(str
 		/* changed transmit queue under us so clear hints */
 		tcp_clear_retrans_hints_partial(tp);

-		sk_stream_free_skb(sk, next_skb);
+		sk_wmem_free_skb(sk, next_skb);
 	}
 }

@@ -2139,8 +2143,9 @@ int tcp_send_synack(struct sock *sk)
 			tcp_unlink_write_queue(skb, sk);
 			skb_header_release(nskb);
 			__tcp_add_write_queue_head(sk, nskb);
-			sk_stream_free_skb(sk, skb);
-			sk_charge_skb(sk, nskb);
+			sk_wmem_free_skb(sk, skb);
+			sk->sk_wmem_queued += nskb->truesize;
+			sk_mem_charge(sk, nskb->truesize);
 			skb = nskb;
 		}

@@ -2343,7 +2348,8 @@ int tcp_connect(struct sock *sk)
 	tp->retrans_stamp = TCP_SKB_CB(buff)->when;
 	skb_header_release(buff);
 	__tcp_add_write_queue_tail(sk, buff);
-	sk_charge_skb(sk, buff);
+	sk->sk_wmem_queued += buff->truesize;
+	sk_mem_charge(sk, buff->truesize);
 	tp->packets_out += tcp_skb_pcount(buff);
 	tcp_transmit_skb(sk, buff, 1, GFP_KERNEL);

diff -pruN net-2.6.25-t12t19m-p2/net/ipv4/tcp_timer.c net-2.6.25-t12t19m-p3/net/ipv4/tcp_timer.c
--- net-2.6.25-t12t19m-p2/net/ipv4/tcp_timer.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p3/net/ipv4/tcp_timer.c	2007-12-29 20:49:59.000000000 -0500
@@ -186,7 +186,7 @@ static void tcp_delack_timer(unsigned lo
 		goto out_unlock;
 	}

-	sk_stream_mem_reclaim(sk);
+	sk_mem_reclaim(sk);

 	if (sk->sk_state == TCP_CLOSE || !(icsk->icsk_ack.pending & ICSK_ACK_TIMER))
 		goto out;
@@ -226,7 +226,7 @@ static void tcp_delack_timer(unsigned lo

 out:
 	if (tcp_memory_pressure)
-		sk_stream_mem_reclaim(sk);
+		sk_mem_reclaim(sk);
 out_unlock:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -420,7 +420,7 @@ static void tcp_write_timer(unsigned lon
 	TCP_CHECK_TIMER(sk);

 out:
-	sk_stream_mem_reclaim(sk);
+	sk_mem_reclaim(sk);
 out_unlock:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -514,7 +514,7 @@ static void tcp_keepalive_timer (unsigne
 	}

 	TCP_CHECK_TIMER(sk);
-	sk_stream_mem_reclaim(sk);
+	sk_mem_reclaim(sk);

 resched:
 	inet_csk_reset_keepalive_timer (sk, elapsed);
-- 
Hitachi Computer Products (America) Inc.
