From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 7/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:21:35 -0700 (PDT)
Message-ID: <20050606.212135.27954595.davem@davemloft.net>
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


[TCP]: tcp_write_xmit() tabbing cleanup

Put the main basic block of work at the top-level of
tabbing, and mark the TCP_CLOSE test with unlikely().

Signed-off-by: David S. Miller <davem@davemloft.net>

b8d892e4dc753d796e80da6e17f2a88aede0695e (from ae083bd3447865cbaf0996a69ba03807fd9fce01)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -847,54 +847,54 @@ static inline void tcp_cwnd_validate(str
 static int tcp_write_xmit(struct sock *sk, int nonagle)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
 	unsigned int mss_now;
+	int sent_pkts;
 
 	/* If we are closed, the bytes will have to remain here.
 	 * In time closedown will finish, we empty the write queue and all
 	 * will be happy.
 	 */
-	if (sk->sk_state != TCP_CLOSE) {
-		struct sk_buff *skb;
-		int sent_pkts = 0;
+	if (unlikely(sk->sk_state == TCP_CLOSE))
+		return 0;
 
-		/* Account for SACKS, we may need to fragment due to this.
-		 * It is just like the real MSS changing on us midstream.
-		 * We also handle things correctly when the user adds some
-		 * IP options mid-stream.  Silly to do, but cover it.
-		 */
-		mss_now = tcp_current_mss(sk, 1);
 
-		while ((skb = sk->sk_send_head) &&
-		       tcp_snd_test(sk, skb, mss_now,
-			       	    tcp_skb_is_last(sk, skb) ? nonagle :
-				    			       TCP_NAGLE_PUSH)) {
-			if (skb->len > mss_now) {
-				if (tcp_fragment(sk, skb, mss_now))
-					break;
-			}
-
-			TCP_SKB_CB(skb)->when = tcp_time_stamp;
-			tcp_tso_set_push(skb);
-			if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
+	/* Account for SACKS, we may need to fragment due to this.
+	 * It is just like the real MSS changing on us midstream.
+	 * We also handle things correctly when the user adds some
+	 * IP options mid-stream.  Silly to do, but cover it.
+	 */
+	mss_now = tcp_current_mss(sk, 1);
+	sent_pkts = 0;
+	while ((skb = sk->sk_send_head) &&
+	       tcp_snd_test(sk, skb, mss_now,
+			    tcp_skb_is_last(sk, skb) ? nonagle :
+			    TCP_NAGLE_PUSH)) {
+		if (skb->len > mss_now) {
+			if (tcp_fragment(sk, skb, mss_now))
 				break;
+		}
 
-			/* Advance the send_head.  This one is sent out.
-			 * This call will increment packets_out.
-			 */
-			update_send_head(sk, tp, skb);
+		TCP_SKB_CB(skb)->when = tcp_time_stamp;
+		tcp_tso_set_push(skb);
+		if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
+			break;
 
-			tcp_minshall_update(tp, mss_now, skb);
-			sent_pkts = 1;
-		}
+		/* Advance the send_head.  This one is sent out.
+		 * This call will increment packets_out.
+		 */
+		update_send_head(sk, tp, skb);
 
-		if (sent_pkts) {
-			tcp_cwnd_validate(sk, tp);
-			return 0;
-		}
+		tcp_minshall_update(tp, mss_now, skb);
+		sent_pkts = 1;
+	}
 
-		return !tp->packets_out && sk->sk_send_head;
+	if (sent_pkts) {
+		tcp_cwnd_validate(sk, tp);
+		return 0;
 	}
-	return 0;
+
+	return !tp->packets_out && sk->sk_send_head;
 }
 
 /* Push out any pending frames which were held back due to
