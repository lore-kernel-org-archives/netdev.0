From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 8/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:22:23 -0700 (PDT)
Message-ID: <20050606.212223.74566928.davem@davemloft.net>
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


[TCP]: Fix redundant calculations of tcp_current_mss()

tcp_write_xmit() uses tcp_current_mss(), but some of it's callers,
namely __tcp_push_pending_frames(), already has this value available
already.

While we're here, fix the "cur_mss" argument to be "unsigned int"
instead of plain "unsigned".

Signed-off-by: David S. Miller <davem@davemloft.net>

f22c7890049ef8c51b0cdcc5d7e0cd06333de6b0 (from b8d892e4dc753d796e80da6e17f2a88aede0695e)
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -946,7 +946,7 @@ extern __u32 cookie_v4_init_sequence(str
 
 extern void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb);
 extern void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
-				      unsigned cur_mss, int nonagle);
+				      unsigned int cur_mss, int nonagle);
 extern int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_xmit_retransmit_queue(struct sock *);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -844,11 +844,10 @@ static inline void tcp_cwnd_validate(str
  * Returns 1, if no segments are in flight and we have queued segments, but
  * cannot send anything now because of SWS or another problem.
  */
-static int tcp_write_xmit(struct sock *sk, int nonagle)
+static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	unsigned int mss_now;
 	int sent_pkts;
 
 	/* If we are closed, the bytes will have to remain here.
@@ -858,13 +857,6 @@ static int tcp_write_xmit(struct sock *s
 	if (unlikely(sk->sk_state == TCP_CLOSE))
 		return 0;
 
-
-	/* Account for SACKS, we may need to fragment due to this.
-	 * It is just like the real MSS changing on us midstream.
-	 * We also handle things correctly when the user adds some
-	 * IP options mid-stream.  Silly to do, but cover it.
-	 */
-	mss_now = tcp_current_mss(sk, 1);
 	sent_pkts = 0;
 	while ((skb = sk->sk_send_head) &&
 	       tcp_snd_test(sk, skb, mss_now,
@@ -902,7 +894,7 @@ static int tcp_write_xmit(struct sock *s
  * The socket must be locked by the caller.
  */
 void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
-			       unsigned cur_mss, int nonagle)
+			       unsigned int cur_mss, int nonagle)
 {
 	struct sk_buff *skb = sk->sk_send_head;
 
@@ -910,7 +902,7 @@ void __tcp_push_pending_frames(struct so
 		if (!tcp_skb_is_last(sk, skb))
 			nonagle = TCP_NAGLE_PUSH;
 		if (!tcp_snd_test(sk, skb, cur_mss, nonagle) ||
-		    tcp_write_xmit(sk, nonagle))
+		    tcp_write_xmit(sk, cur_mss, nonagle))
 			tcp_check_probe_timer(sk, tp);
 	}
 }
@@ -921,7 +913,7 @@ void __tcp_data_snd_check(struct sock *s
 
 	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) ||
 	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
-	    tcp_write_xmit(sk, tp->nonagle))
+	    tcp_write_xmit(sk, tcp_current_mss(sk, 1), tp->nonagle))
 		tcp_check_probe_timer(sk, tp);
 }
 
