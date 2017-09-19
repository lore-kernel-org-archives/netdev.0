From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sk_buff rbnode reorg
Date: Mon, 18 Sep 2017 22:06:56 -0700
Message-ID: <1505797616.29839.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38005 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdISFG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 01:06:59 -0400
Received: by mail-io0-f194.google.com with SMTP id e9so1709712iod.5
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 22:06:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb->rbnode shares space with skb->next, skb->prev and skb->tstamp

Current uses (TCP receive ofo queue and netem) need to save/restore
tstamp.
    
Since we might use an RB tree for TCP retransmit queue at some point
to speedup SACK processing with large rtx queues, this patch exchanges
skb->dev and skb->tstamp.
    
This saves some overhead in both TCP and netem.
    
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |   16 ++++++++--------
 include/net/tcp.h      |    5 -----
 net/ipv4/tcp_input.c   |   27 +++++----------------------
 net/sched/sch_netem.c  |    7 ++++---
 4 files changed, 17 insertions(+), 38 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef00061db1ce70d34b96ae1639ecde08837..492828801acba42ac6bccb287d3cc5080039135c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -661,8 +661,12 @@ struct sk_buff {
 			struct sk_buff		*prev;
 
 			union {
-				ktime_t		tstamp;
-				u64		skb_mstamp;
+				struct net_device	*dev;
+				/* Some protocols might use this space to store information,
+				 * while device pointer would be NULL.
+				 * UDP receive path is one user.
+				 */
+				unsigned long		dev_scratch;
 			};
 		};
 		struct rb_node	rbnode; /* used in netem & tcp stack */
@@ -670,12 +674,8 @@ struct sk_buff {
 	struct sock		*sk;
 
 	union {
-		struct net_device	*dev;
-		/* Some protocols might use this space to store information,
-		 * while device pointer would be NULL.
-		 * UDP receive path is one user.
-		 */
-		unsigned long		dev_scratch;
+		ktime_t		tstamp;
+		u64		skb_mstamp;
 	};
 	/*
 	 * This is the control buffer. It is free to use for every
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b510f284427aabc1f508d24d29d0f812e5e0aa61..6ecc01aa667b26a3e2270a3566b2076bfebd8605 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -797,11 +797,6 @@ struct tcp_skb_cb {
 			u16	tcp_gso_segs;
 			u16	tcp_gso_size;
 		};
-
-		/* Used to stash the receive timestamp while this skb is in the
-		 * out of order queue, as skb->tstamp is overwritten by the
-		 * rbnode.
-		 */
 		ktime_t		swtstamp;
 	};
 	__u8		tcp_flags;	/* TCP header flags. (tcp[13])	*/
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bddf724f5c02abe1d11110cffe2517f6376e440d..db9bb46b5776f9ee332298c0e95afb0a5966b938 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4266,11 +4266,6 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 	tp->rx_opt.num_sacks = num_sacks;
 }
 
-enum tcp_queue {
-	OOO_QUEUE,
-	RCV_QUEUE,
-};
-
 /**
  * tcp_try_coalesce - try to merge skb to prior one
  * @sk: socket
@@ -4286,7 +4281,6 @@ enum tcp_queue {
  * Returns true if caller should free @from instead of queueing it
  */
 static bool tcp_try_coalesce(struct sock *sk,
-			     enum tcp_queue dest,
 			     struct sk_buff *to,
 			     struct sk_buff *from,
 			     bool *fragstolen)
@@ -4311,10 +4305,7 @@ static bool tcp_try_coalesce(struct sock *sk,
 
 	if (TCP_SKB_CB(from)->has_rxtstamp) {
 		TCP_SKB_CB(to)->has_rxtstamp = true;
-		if (dest == OOO_QUEUE)
-			TCP_SKB_CB(to)->swtstamp = TCP_SKB_CB(from)->swtstamp;
-		else
-			to->tstamp = from->tstamp;
+		to->tstamp = from->tstamp;
 	}
 
 	return true;
@@ -4351,9 +4342,6 @@ static void tcp_ofo_queue(struct sock *sk)
 		}
 		p = rb_next(p);
 		rb_erase(&skb->rbnode, &tp->out_of_order_queue);
-		/* Replace tstamp which was stomped by rbnode */
-		if (TCP_SKB_CB(skb)->has_rxtstamp)
-			skb->tstamp = TCP_SKB_CB(skb)->swtstamp;
 
 		if (unlikely(!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))) {
 			SOCK_DEBUG(sk, "ofo packet was already received\n");
@@ -4365,8 +4353,7 @@ static void tcp_ofo_queue(struct sock *sk)
 			   TCP_SKB_CB(skb)->end_seq);
 
 		tail = skb_peek_tail(&sk->sk_receive_queue);
-		eaten = tail && tcp_try_coalesce(sk, RCV_QUEUE,
-						 tail, skb, &fragstolen);
+		eaten = tail && tcp_try_coalesce(sk, tail, skb, &fragstolen);
 		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
 		fin = TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN;
 		if (!eaten)
@@ -4420,10 +4407,6 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
-	/* Stash tstamp to avoid being stomped on by rbnode */
-	if (TCP_SKB_CB(skb)->has_rxtstamp)
-		TCP_SKB_CB(skb)->swtstamp = skb->tstamp;
-
 	/* Disable header prediction. */
 	tp->pred_flags = 0;
 	inet_csk_schedule_ack(sk);
@@ -4451,7 +4434,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	/* In the typical case, we are adding an skb to the end of the list.
 	 * Use of ooo_last_skb avoids the O(Log(N)) rbtree lookup.
 	 */
-	if (tcp_try_coalesce(sk, OOO_QUEUE, tp->ooo_last_skb,
+	if (tcp_try_coalesce(sk, tp->ooo_last_skb,
 			     skb, &fragstolen)) {
 coalesce_done:
 		tcp_grow_window(sk, skb);
@@ -4502,7 +4485,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 				__kfree_skb(skb1);
 				goto merge_right;
 			}
-		} else if (tcp_try_coalesce(sk, OOO_QUEUE, skb1,
+		} else if (tcp_try_coalesce(sk, skb1,
 					    skb, &fragstolen)) {
 			goto coalesce_done;
 		}
@@ -4554,7 +4537,7 @@ static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int
 
 	__skb_pull(skb, hdrlen);
 	eaten = (tail &&
-		 tcp_try_coalesce(sk, RCV_QUEUE, tail,
+		 tcp_try_coalesce(sk, tail,
 				  skb, fragstolen)) ? 1 : 0;
 	tcp_rcv_nxt_update(tcp_sk(sk), TCP_SKB_CB(skb)->end_seq);
 	if (!eaten) {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index b1266e75ca43cf5a66b951ecabccfc5b24069444..063a4bdb9ee6f26b01387959e8f6ccd15ec16191 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -146,7 +146,6 @@ struct netem_sched_data {
  */
 struct netem_skb_cb {
 	psched_time_t	time_to_send;
-	ktime_t		tstamp_save;
 };
 
 
@@ -561,7 +560,6 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		}
 
 		cb->time_to_send = now + delay;
-		cb->tstamp_save = skb->tstamp;
 		++q->counter;
 		tfifo_enqueue(skb, sch);
 	} else {
@@ -629,7 +627,10 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			qdisc_qstats_backlog_dec(sch, skb);
 			skb->next = NULL;
 			skb->prev = NULL;
-			skb->tstamp = netem_skb_cb(skb)->tstamp_save;
+			/* skb->dev shares skb->rbnode area,
+			 * we need to restore its value.
+			 */
+			skb->dev = qdisc_dev(sch);
 
 #ifdef CONFIG_NET_CLS_ACT
 			/*
