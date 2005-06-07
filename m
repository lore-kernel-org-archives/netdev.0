From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 9/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:23:27 -0700 (PDT)
Message-ID: <20050606.212327.18313062.davem@davemloft.net>
References: <20050606.210846.07641049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050606.210846.07641049.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[TCP]: Fix __tcp_push_pending_frames() 'nonagle' handling.

'nonagle' should be passed to the tcp_snd_test() function
as 'TCP_NAGLE_PUSH' if we are checking an SKB not at the
tail of the write_queue.  This is because Nagle does not
apply to such frames since we cannot possibly tack more
data onto them.

However, while doing this __tcp_push_pending_frames() makes
all of the packets in the write_queue use this modified
'nonagle' value.

Fix the bug and simplify this function by just calling
tcp_write_xmit() directly if sk_send_head is non-NULL.

As a result, we can now make tcp_data_snd_check() just call
tcp_push_pending_frames() instead of the specialized
__tcp_data_snd_check().

Signed-off-by: David S. Miller <davem@davemloft.net>

45d0377c7d18e1a036b0a1f96788a998dccf73cf (from f22c7890049ef8c51b0cdcc5d7e0cd06333de6b0)
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -944,7 +944,6 @@ extern __u32 cookie_v4_init_sequence(str
 
 /* tcp_output.c */
 
-extern void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb);
 extern void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
 				      unsigned int cur_mss, int nonagle);
 extern int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3975,12 +3975,9 @@ static inline void tcp_check_space(struc
 	}
 }
 
-static __inline__ void tcp_data_snd_check(struct sock *sk)
+static __inline__ void tcp_data_snd_check(struct sock *sk, struct tcp_sock *tp)
 {
-	struct sk_buff *skb = sk->sk_send_head;
-
-	if (skb != NULL)
-		__tcp_data_snd_check(sk, skb);
+	tcp_push_pending_frames(sk, tp);
 	tcp_check_space(sk);
 }
 
@@ -4274,7 +4271,7 @@ int tcp_rcv_established(struct sock *sk,
 				 */
 				tcp_ack(sk, skb, 0);
 				__kfree_skb(skb); 
-				tcp_data_snd_check(sk);
+				tcp_data_snd_check(sk, tp);
 				return 0;
 			} else { /* Header too small */
 				TCP_INC_STATS_BH(TCP_MIB_INERRS);
@@ -4340,7 +4337,7 @@ int tcp_rcv_established(struct sock *sk,
 			if (TCP_SKB_CB(skb)->ack_seq != tp->snd_una) {
 				/* Well, only one small jumplet in fast path... */
 				tcp_ack(sk, skb, FLAG_DATA);
-				tcp_data_snd_check(sk);
+				tcp_data_snd_check(sk, tp);
 				if (!tcp_ack_scheduled(tp))
 					goto no_ack;
 			}
@@ -4418,7 +4415,7 @@ step5:
 	/* step 7: process the segment text */
 	tcp_data_queue(sk, skb);
 
-	tcp_data_snd_check(sk);
+	tcp_data_snd_check(sk, tp);
 	tcp_ack_snd_check(sk);
 	return 0;
 
@@ -4732,7 +4729,7 @@ int tcp_rcv_state_process(struct sock *s
 		/* Do step6 onward by hand. */
 		tcp_urg(sk, skb, th);
 		__kfree_skb(skb);
-		tcp_data_snd_check(sk);
+		tcp_data_snd_check(sk, tp);
 		return 0;
 	}
 
@@ -4921,7 +4918,7 @@ int tcp_rcv_state_process(struct sock *s
 
 	/* tcp_data could move socket to TIME-WAIT */
 	if (sk->sk_state != TCP_CLOSE) {
-		tcp_data_snd_check(sk);
+		tcp_data_snd_check(sk, tp);
 		tcp_ack_snd_check(sk);
 	}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -899,24 +899,11 @@ void __tcp_push_pending_frames(struct so
 	struct sk_buff *skb = sk->sk_send_head;
 
 	if (skb) {
-		if (!tcp_skb_is_last(sk, skb))
-			nonagle = TCP_NAGLE_PUSH;
-		if (!tcp_snd_test(sk, skb, cur_mss, nonagle) ||
-		    tcp_write_xmit(sk, cur_mss, nonagle))
+		if (tcp_write_xmit(sk, cur_mss, nonagle))
 			tcp_check_probe_timer(sk, tp);
 	}
 }
 
-void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) ||
-	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
-	    tcp_write_xmit(sk, tcp_current_mss(sk, 1), tp->nonagle))
-		tcp_check_probe_timer(sk, tp);
-}
-
 /* This function returns the amount that we can raise the
  * usable window based on the following constraints
  *  
