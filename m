From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 08/11] tcp: increment sk_drops for dropped rx packets
Date: Fri,  1 Apr 2016 08:52:19 -0700
Message-ID: <1459525942-30399-9-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34708 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758966AbcDAPwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:45 -0400
Received: by mail-pa0-f51.google.com with SMTP id fe3so93955782pab.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:45 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now ss can report sk_drops, we can instruct TCP to increment
this per socket counter when it drops an incoming frame, to refine
monitoring and debugging.

Following patch takes care of listeners drops.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h   |  7 +++++++
 net/ipv4/tcp_input.c | 33 ++++++++++++++++++++-------------
 net/ipv4/tcp_ipv4.c  |  1 +
 net/ipv6/tcp_ipv6.c  |  1 +
 4 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c3a707d1cee8..0d49b92ca59c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2009,6 +2009,13 @@ sock_skb_set_dropcount(const struct sock *sk, struct sk_buff *skb)
 	SOCK_SKB_CB(skb)->dropcount = atomic_read(&sk->sk_drops);
 }
 
+static inline void sk_drops_add(struct sock *sk, const struct sk_buff *skb)
+{
+	int segs = max_t(u16, 1, skb_shinfo(skb)->gso_segs);
+
+	atomic_add(segs, &sk->sk_drops);
+}
+
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			   struct sk_buff *skb);
 void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e6e65f79ade8..d994d358ccbe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4318,6 +4318,12 @@ static bool tcp_try_coalesce(struct sock *sk,
 	return true;
 }
 
+static void tcp_drop(struct sock *sk, struct sk_buff *skb)
+{
+	sk_drops_add(sk, skb);
+	__kfree_skb(skb);
+}
+
 /* This one checks to see if we can put data from the
  * out_of_order queue into the receive_queue.
  */
@@ -4342,7 +4348,7 @@ static void tcp_ofo_queue(struct sock *sk)
 		__skb_unlink(skb, &tp->out_of_order_queue);
 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
 			SOCK_DEBUG(sk, "ofo packet was already received\n");
-			__kfree_skb(skb);
+			tcp_drop(sk, skb);
 			continue;
 		}
 		SOCK_DEBUG(sk, "ofo requeuing : rcv_next %X seq %X - %X\n",
@@ -4394,7 +4400,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 
 	if (unlikely(tcp_try_rmem_schedule(sk, skb, skb->truesize))) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFODROP);
-		__kfree_skb(skb);
+		tcp_drop(sk, skb);
 		return;
 	}
 
@@ -4458,7 +4464,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 			/* All the bits are present. Drop. */
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOMERGE);
-			__kfree_skb(skb);
+			tcp_drop(sk, skb);
 			skb = NULL;
 			tcp_dsack_set(sk, seq, end_seq);
 			goto add_sack;
@@ -4497,7 +4503,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
 				 TCP_SKB_CB(skb1)->end_seq);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOMERGE);
-		__kfree_skb(skb1);
+		tcp_drop(sk, skb1);
 	}
 
 add_sack:
@@ -4580,12 +4586,13 @@ err:
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int eaten = -1;
 	bool fragstolen = false;
+	int eaten = -1;
 
-	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
-		goto drop;
-
+	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq) {
+		__kfree_skb(skb);
+		return;
+	}
 	skb_dst_drop(skb);
 	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
 
@@ -4667,7 +4674,7 @@ out_of_window:
 		tcp_enter_quickack_mode(sk);
 		inet_csk_schedule_ack(sk);
 drop:
-		__kfree_skb(skb);
+		tcp_drop(sk, skb);
 		return;
 	}
 
@@ -5244,7 +5251,7 @@ syn_challenge:
 	return true;
 
 discard:
-	__kfree_skb(skb);
+	tcp_drop(sk, skb);
 	return false;
 }
 
@@ -5462,7 +5469,7 @@ csum_error:
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 
 discard:
-	__kfree_skb(skb);
+	tcp_drop(sk, skb);
 }
 EXPORT_SYMBOL(tcp_rcv_established);
 
@@ -5693,7 +5700,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
 discard:
-			__kfree_skb(skb);
+			tcp_drop(sk, skb);
 			return 0;
 		} else {
 			tcp_send_ack(sk);
@@ -6054,7 +6061,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 
 	if (!queued) {
 discard:
-		__kfree_skb(skb);
+		tcp_drop(sk, skb);
 	}
 	return 0;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e5f924b29946..059a98f5e7e1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1694,6 +1694,7 @@ discard_it:
 	return 0;
 
 discard_and_relse:
+	sk_drops_add(sk, skb);
 	if (refcounted)
 		sock_put(sk);
 	goto discard_it;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f0422e782731..5fa8fea394c9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1484,6 +1484,7 @@ discard_it:
 	return 0;
 
 discard_and_relse:
+	sk_drops_add(sk, skb);
 	if (refcounted)
 		sock_put(sk);
 	goto discard_it;
-- 
2.8.0.rc3.226.g39d4020
