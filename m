From: "David S. Miller" <davem@davemloft.net>
Subject: Re: fixing sk_stream_rfree()
Date: Sat, 15 Apr 2006 02:03:08 -0700 (PDT)
Message-ID: <20060415.020308.108561770.davem@davemloft.net>
References: <20060414.205927.13626300.davem@davemloft.net>
	<20060415.012327.68977713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26079
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751596AbWDOJDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 05:03:23 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060415.012327.68977713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "David S. Miller" <davem@davemloft.net>
Date: Sat, 15 Apr 2006 01:23:27 -0700 (PDT)

> I came up with one more possible approach, it goes something like
> this:
> 
> 1) Get rid of the skb->destructor callback for TCP receive
>    data.
> 
> 2) Adjust sk_rmem_alloc and sk_forward_alloc explicitly when we add
>    packets to sk_receive_queue/out_of_order_queue, and when we unlink
>    them from sk_receive_queue and __kfree_skb() them up.

It turns out DCCP doesn't use the sk_forward_alloc memory
scheduling at least not for receive.

So, as food for thought, below is a comile-tested-only
implementation of the above idea.  The basic transformations
are:

1) sk_eat_skb --> sk_stream_eat_skb which does the sk_forward_alloc
   et al. accounting by hand which would have been done by the
   skb->destructor sk_stream_rfree()

2) __skb_queue_purge --> sk_stream_eat_queue

3) sk_stream_set_owner_r --> sk_stream_charge_r which does
   the accounting for a new receive skb but does not hook up
   the destructor

4) unlink and free SKB not received to userspace yet -->
   sk_stream_eat_skb()

... and then I noticed that ip_rcv() unshares the SKB, so
skb->users should always be 1 and therefore it is impossible
for sk_stream_rfree() to be called from a non socket locked
context.

And all of this was a wild goose chase, oh well :-)
So the BUG_ON(!sk_forward_alloc) problem is elsewhere. :-/

diff --git a/arch/x86_64/kernel/functionlist b/arch/x86_64/kernel/functionlist
index 2bcebdc..da3379a 100644
--- a/arch/x86_64/kernel/functionlist
+++ b/arch/x86_64/kernel/functionlist
@@ -751,7 +751,6 @@
 *(.text.strcmp)
 *(.text.steal_locks)
 *(.text.sock_create)
-*(.text.sk_stream_rfree)
 *(.text.sk_stream_mem_schedule)
 *(.text.skip_atoi)
 *(.text.sk_alloc)
diff --git a/include/net/sock.h b/include/net/sock.h
index af2b054..54d5a2f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -442,14 +442,56 @@ static inline int sk_stream_memory_free(
 	return sk->sk_wmem_queued < sk->sk_sndbuf;
 }
 
-extern void sk_stream_rfree(struct sk_buff *skb);
-
-static inline void sk_stream_set_owner_r(struct sk_buff *skb, struct sock *sk)
+/* Charge SKB as receive queue memory to SK.  The socket must be locked
+ * when we get here.
+ */
+static inline void sk_stream_charge_r(struct sk_buff *skb, struct sock *sk)
 {
-	skb->sk = sk;
-	skb->destructor = sk_stream_rfree;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 	sk->sk_forward_alloc -= skb->truesize;
+}
+
+/* Release SKB as receive queue memory from SK.  The socket must be
+ * locked when we get here.
+ */
+static inline void sk_stream_release_r(struct sk_buff *skb, struct sock *sk)
+{
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+	sk->sk_forward_alloc += skb->truesize;
+}
+
+/**
+ * sk_stream_eat_skb - Release a skb if it is no longer needed
+ * @sk: socket to eat this skb from
+ * @skb: socket buffer to eat
+ * @queue: skb queue to unlink from
+ *
+ * This routine must be called with interrupts disabled or with the socket
+ * locked so that the sk_buff queue operation is ok.
+ */
+static inline void sk_stream_eat_skb(struct sk_buff *skb, struct sock *sk, struct sk_buff_head *queue)
+{
+	__skb_unlink(skb, queue);
+	sk_stream_release_r(skb, sk);
+	__kfree_skb(skb);
+}
+
+/*
+ * sk_stream_eat_queue - Release an entire queue of skbs, when no longer needed
+ * @sk: socket to eat these skbs from
+ * @queue: queue of skbs to eat
+ *
+ * This routine must be called with interrupts disabled or with the socket
+ * locked so that the sk_buff queue operation is ok.
+ */
+static inline void sk_stream_eat_queue(struct sock *sk, struct sk_buff_head *queue)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(queue)) != NULL) {
+		sk_stream_release_r(skb, sk);
+		__kfree_skb(skb);
+	}
 }
 
 static inline void sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
diff --git a/net/core/stream.c b/net/core/stream.c
index 35e2525..a034f2d 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -172,16 +172,6 @@ do_interrupted:
 
 EXPORT_SYMBOL(sk_stream_wait_memory);
 
-void sk_stream_rfree(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
-	sk->sk_forward_alloc += skb->truesize;
-}
-
-EXPORT_SYMBOL(sk_stream_rfree);
-
 int sk_stream_error(struct sock *sk, int flags, int err)
 {
 	if (err == -EPIPE)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 87f68e7..c45a9c2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1072,11 +1072,11 @@ int tcp_read_sock(struct sock *sk, read_
 				break;
 		}
 		if (skb->h.th->fin) {
-			sk_eat_skb(sk, skb);
+			sk_stream_eat_skb(skb, sk, &sk->sk_receive_queue);
 			++seq;
 			break;
 		}
-		sk_eat_skb(sk, skb);
+		sk_stream_eat_skb(skb, sk, &sk->sk_receive_queue);
 		if (!desc->count)
 			break;
 	}
@@ -1355,15 +1355,17 @@ skip_copy:
 
 		if (skb->h.th->fin)
 			goto found_fin_ok;
-		if (!(flags & MSG_PEEK))
-			sk_eat_skb(sk, skb);
+		if (!(flags & MSG_PEEK)) {
+			sk_stream_eat_skb(skb, sk, &sk->sk_receive_queue);
+		}
 		continue;
 
 	found_fin_ok:
 		/* Process the FIN. */
 		++*seq;
-		if (!(flags & MSG_PEEK))
-			sk_eat_skb(sk, skb);
+		if (!(flags & MSG_PEEK)) {
+			sk_stream_eat_skb(skb, sk, &sk->sk_receive_queue);
+		}
 		break;
 	} while (len > 0);
 
@@ -1489,6 +1491,7 @@ void tcp_close(struct sock *sk, long tim
 		u32 len = TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq -
 			  skb->h.th->fin;
 		data_was_unread += len;
+		sk_stream_release_r(skb, sk);
 		__kfree_skb(skb);
 	}
 
@@ -1650,9 +1653,9 @@ int tcp_disconnect(struct sock *sk, int 
 		sk->sk_err = ECONNRESET;
 
 	tcp_clear_xmit_timers(sk);
-	__skb_queue_purge(&sk->sk_receive_queue);
+	sk_stream_eat_queue(sk, &sk->sk_receive_queue);
 	sk_stream_writequeue_purge(sk);
-	__skb_queue_purge(&tp->out_of_order_queue);
+	sk_stream_eat_queue(sk, &tp->out_of_order_queue);
 
 	inet->dport = 0;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9f0cca4..5a30648 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2875,7 +2875,7 @@ static void tcp_fin(struct sk_buff *skb,
 	/* It _is_ possible, that we have something out-of-order _after_ FIN.
 	 * Probably, we should reset in this case. For now drop them.
 	 */
-	__skb_queue_purge(&tp->out_of_order_queue);
+	sk_stream_eat_queue(sk, &tp->out_of_order_queue);
 	if (tp->rx_opt.sack_ok)
 		tcp_sack_reset(&tp->rx_opt);
 	sk_stream_mem_reclaim(sk);
@@ -3093,8 +3093,7 @@ static void tcp_ofo_queue(struct sock *s
 
 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
 			SOCK_DEBUG(sk, "ofo packet was already received \n");
-			__skb_unlink(skb, &tp->out_of_order_queue);
-			__kfree_skb(skb);
+			sk_stream_eat_skb(skb, sk, &tp->out_of_order_queue);
 			continue;
 		}
 		SOCK_DEBUG(sk, "ofo requeuing : rcv_next %X seq %X - %X\n",
@@ -3166,7 +3165,7 @@ queue_and_out:
 				    !sk_stream_rmem_schedule(sk, skb))
 					goto drop;
 			}
-			sk_stream_set_owner_r(skb, sk);
+			sk_stream_charge_r(skb, sk);
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 		}
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
@@ -3248,7 +3247,7 @@ drop:
 	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
 		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
 
-	sk_stream_set_owner_r(skb, sk);
+	sk_stream_charge_r(skb, sk);
 
 	if (!skb_peek(&tp->out_of_order_queue)) {
 		/* Initial out of order segment, build 1 SACK. */
@@ -3290,6 +3289,7 @@ drop:
 		    before(seq, TCP_SKB_CB(skb1)->end_seq)) {
 			if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 				/* All the bits are present. Drop. */
+				sk_stream_release_r(skb, sk);
 				__kfree_skb(skb);
 				tcp_dsack_set(tp, seq, end_seq);
 				goto add_sack;
@@ -3311,9 +3311,8 @@ drop:
 			       tcp_dsack_extend(tp, TCP_SKB_CB(skb1)->seq, end_seq);
 			       break;
 		       }
-		       __skb_unlink(skb1, &tp->out_of_order_queue);
 		       tcp_dsack_extend(tp, TCP_SKB_CB(skb1)->seq, TCP_SKB_CB(skb1)->end_seq);
-		       __kfree_skb(skb1);
+		       sk_stream_eat_skb(skb1, sk, &tp->out_of_order_queue);
 		}
 
 add_sack:
@@ -3340,8 +3339,7 @@ tcp_collapse(struct sock *sk, struct sk_
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 			struct sk_buff *next = skb->next;
-			__skb_unlink(skb, list);
-			__kfree_skb(skb);
+			sk_stream_eat_skb(skb, sk, list);
 			NET_INC_STATS_BH(LINUX_MIB_TCPRCVCOLLAPSED);
 			skb = next;
 			continue;
@@ -3387,7 +3385,7 @@ tcp_collapse(struct sock *sk, struct sk_
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
 		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
 		__skb_insert(nskb, skb->prev, skb, list);
-		sk_stream_set_owner_r(nskb, sk);
+		sk_stream_charge_r(nskb, sk);
 
 		/* Copy data, releasing collapsed skbs. */
 		while (copy > 0) {
@@ -3405,8 +3403,7 @@ tcp_collapse(struct sock *sk, struct sk_
 			}
 			if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 				struct sk_buff *next = skb->next;
-				__skb_unlink(skb, list);
-				__kfree_skb(skb);
+				sk_stream_eat_skb(skb, sk, list);
 				NET_INC_STATS_BH(LINUX_MIB_TCPRCVCOLLAPSED);
 				skb = next;
 				if (skb == tail || skb->h.th->syn || skb->h.th->fin)
@@ -3494,7 +3491,7 @@ static int tcp_prune_queue(struct sock *
 	/* First, purge the out_of_order queue. */
 	if (!skb_queue_empty(&tp->out_of_order_queue)) {
 		NET_INC_STATS_BH(LINUX_MIB_OFOPRUNED);
-		__skb_queue_purge(&tp->out_of_order_queue);
+		sk_stream_eat_queue(sk, &tp->out_of_order_queue);
 
 		/* Reset SACK state.  A conforming SACK implementation will
 		 * do the same at a timeout based retransmit.  When a connection
@@ -3703,10 +3700,8 @@ static void tcp_check_urg(struct sock * 
 	    tp->copied_seq != tp->rcv_nxt) {
 		struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
 		tp->copied_seq++;
-		if (skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq)) {
-			__skb_unlink(skb, &sk->sk_receive_queue);
-			__kfree_skb(skb);
-		}
+		if (skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq))
+			sk_stream_eat_skb(skb, sk, &sk->sk_receive_queue);
 	}
 
 	tp->urg_data   = TCP_URG_NOTYET;
@@ -3950,7 +3945,7 @@ int tcp_rcv_established(struct sock *sk,
 				/* Bulk data transfer: receiver */
 				__skb_pull(skb,tcp_header_len);
 				__skb_queue_tail(&sk->sk_receive_queue, skb);
-				sk_stream_set_owner_r(skb, sk);
+				sk_stream_charge_r(skb, sk);
 				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 			}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 672950e..e518d97 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1294,7 +1294,7 @@ int tcp_v4_destroy_sock(struct sock *sk)
   	sk_stream_writequeue_purge(sk);
 
 	/* Cleans up our, hopefully empty, out_of_order_queue. */
-  	__skb_queue_purge(&tp->out_of_order_queue);
+	sk_stream_eat_queue(sk, &tp->out_of_order_queue);
 
 	/* Clean prequeue, it must be empty really */
 	__skb_queue_purge(&tp->ucopy.prequeue);
