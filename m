From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH] Discard tcp out-of-order queue if system limit is reached
Date: Tue, 15 Apr 2008 18:54:44 +0400
Message-ID: <200804151854.45021.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:15560 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbYDOOw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 10:52:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

tcp_prune_queue() doesn't prune an out-of-order queue if socket
is under rcvbuf. However even if socket is under rcvbuf but system-wide limit is
reached then skb cannot be queued. It can lead to deadlock situation as any skb that
fills sequence hole is dropped.
So discard out-of-order queue if system-wide limit is reached.

Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

---
 net/ipv4/tcp_input.c |   78 +++++++++++++++++++++++++++++++++----------------
 1 files changed, 52 insertions(+), 26 deletions(-)


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5119856..bbb7d88 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3841,8 +3841,28 @@ static void tcp_ofo_queue(struct sock *sk)
 	}
 }
 
+static int tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
+static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
+{
+	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
+	    !sk_rmem_schedule(sk, size)) {
+
+		if (tcp_prune_queue(sk) < 0)
+			return -1;
+
+		if (!sk_rmem_schedule(sk, size)) {
+			if (!tcp_prune_ofo_queue(sk))
+				return -1;
+
+			if (!sk_rmem_schedule(sk, size))
+				return -1;
+		}
+	}
+	return 0;
+}
+
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th = tcp_hdr(skb);
@@ -3892,12 +3912,9 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 		if (eaten <= 0) {
 queue_and_out:
 			if (eaten < 0 &&
-			    (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-			     !sk_rmem_schedule(sk, skb->truesize))) {
-				if (tcp_prune_queue(sk) < 0 ||
-				    !sk_rmem_schedule(sk, skb->truesize))
-					goto drop;
-			}
+			    tcp_try_rmem_schedule(sk, skb->truesize))
+				goto drop;
+
 			skb_set_owner_r(skb, sk);
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 		}
@@ -3966,12 +3983,8 @@ drop:
 
 	TCP_ECN_check_ce(tp, skb);
 
-	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    !sk_rmem_schedule(sk, skb->truesize)) {
-		if (tcp_prune_queue(sk) < 0 ||
-		    !sk_rmem_schedule(sk, skb->truesize))
-			goto drop;
-	}
+	if (tcp_try_rmem_schedule(sk, skb->truesize))
+		goto drop;
 
 	/* Disable header prediction. */
 	tp->pred_flags = 0;
@@ -4198,6 +4211,32 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
 	}
 }
 
+/*
+ * Purge the out-of-order queue.
+ * Return true if queue was pruned.
+ */
+static int tcp_prune_ofo_queue(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int res = 0;
+
+	if (!skb_queue_empty(&tp->out_of_order_queue)) {
+		NET_INC_STATS_BH(LINUX_MIB_OFOPRUNED);
+		__skb_queue_purge(&tp->out_of_order_queue);
+
+		/* Reset SACK state.  A conforming SACK implementation will
+		 * do the same at a timeout based retransmit.  When a connection
+		 * is in a sad state like this, we care only about integrity
+		 * of the connection not performance.
+		 */
+		if (tp->rx_opt.sack_ok)
+			tcp_sack_reset(&tp->rx_opt);
+		sk_mem_reclaim(sk);
+		res = 1;
+	}
+	return res;
+}
+
 /* Reduce allocated memory if we can, trying to get
  * the socket within its memory limits again.
  *
@@ -4231,20 +4270,7 @@ static int tcp_prune_queue(struct sock *sk)
 	/* Collapsing did not help, destructive actions follow.
 	 * This must not ever occur. */
 
-	/* First, purge the out_of_order queue. */
-	if (!skb_queue_empty(&tp->out_of_order_queue)) {
-		NET_INC_STATS_BH(LINUX_MIB_OFOPRUNED);
-		__skb_queue_purge(&tp->out_of_order_queue);
-
-		/* Reset SACK state.  A conforming SACK implementation will
-		 * do the same at a timeout based retransmit.  When a connection
-		 * is in a sad state like this, we care only about integrity
-		 * of the connection not performance.
-		 */
-		if (tcp_is_sack(tp))
-			tcp_sack_reset(&tp->rx_opt);
-		sk_mem_reclaim(sk);
-	}
+	tcp_prune_ofo_queue(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf)
 		return 0;
