From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 6/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:20:39 -0700 (PDT)
Message-ID: <20050606.212039.48802169.davem@davemloft.net>
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


[TCP]: Kill extra cwnd validate in __tcp_push_pending_frames().

The tcp_cwnd_validate() function should only be invoked
if we actually send some frames, yet __tcp_push_pending_frames()
will always invoke it.  tcp_write_xmit() does the call for us,
so the call here can simply be removed.

Also, tcp_write_xmit() can be marked static.

Signed-off-by: David S. Miller <davem@davemloft.net>

ae083bd3447865cbaf0996a69ba03807fd9fce01 (from 79eb6b25499ed5470cb7b20428c435288fcb3502)
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -944,7 +944,6 @@ extern __u32 cookie_v4_init_sequence(str
 
 /* tcp_output.c */
 
-extern int tcp_write_xmit(struct sock *, int nonagle);
 extern void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb);
 extern void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
 				      unsigned cur_mss, int nonagle);
@@ -964,6 +963,9 @@ extern void tcp_push_one(struct sock *, 
 extern void tcp_send_ack(struct sock *sk);
 extern void tcp_send_delayed_ack(struct sock *sk);
 
+/* tcp_input.c */
+extern void tcp_cwnd_application_limited(struct sock *sk);
+
 /* tcp_timer.c */
 extern void tcp_init_xmit_timers(struct sock *);
 extern void tcp_clear_xmit_timers(struct sock *);
@@ -1339,28 +1341,6 @@ static inline void tcp_sync_left_out(str
 	tp->left_out = tp->sacked_out + tp->lost_out;
 }
 
-extern void tcp_cwnd_application_limited(struct sock *sk);
-
-/* Congestion window validation. (RFC2861) */
-
-static inline void tcp_cwnd_validate(struct sock *sk, struct tcp_sock *tp)
-{
-	__u32 packets_out = tp->packets_out;
-
-	if (packets_out >= tp->snd_cwnd) {
-		/* Network is feed fully. */
-		tp->snd_cwnd_used = 0;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
-	} else {
-		/* Network starves. */
-		if (tp->packets_out > tp->snd_cwnd_used)
-			tp->snd_cwnd_used = tp->packets_out;
-
-		if ((s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= tp->rto)
-			tcp_cwnd_application_limited(sk);
-	}
-}
-
 /* Set slow start threshould and cwnd not falling to slow start */
 static inline void __tcp_enter_cwr(struct tcp_sock *tp)
 {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -517,35 +517,6 @@ static inline int tcp_skb_is_last(const 
 	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
 }
 
-/* Push out any pending frames which were held back due to
- * TCP_CORK or attempt at coalescing tiny packets.
- * The socket must be locked by the caller.
- */
-void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
-			       unsigned cur_mss, int nonagle)
-{
-	struct sk_buff *skb = sk->sk_send_head;
-
-	if (skb) {
-		if (!tcp_skb_is_last(sk, skb))
-			nonagle = TCP_NAGLE_PUSH;
-		if (!tcp_snd_test(sk, skb, cur_mss, nonagle) ||
-		    tcp_write_xmit(sk, nonagle))
-			tcp_check_probe_timer(sk, tp);
-	}
-	tcp_cwnd_validate(sk, tp);
-}
-
-void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) ||
-	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
-	    tcp_write_xmit(sk, tp->nonagle))
-		tcp_check_probe_timer(sk, tp);
-}
-
 int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
 {
 	struct sk_buff *skb = sk->sk_send_head;
@@ -846,6 +817,26 @@ unsigned int tcp_current_mss(struct sock
 	return mss_now;
 }
 
+/* Congestion window validation. (RFC2861) */
+
+static inline void tcp_cwnd_validate(struct sock *sk, struct tcp_sock *tp)
+{
+	__u32 packets_out = tp->packets_out;
+
+	if (packets_out >= tp->snd_cwnd) {
+		/* Network is feed fully. */
+		tp->snd_cwnd_used = 0;
+		tp->snd_cwnd_stamp = tcp_time_stamp;
+	} else {
+		/* Network starves. */
+		if (tp->packets_out > tp->snd_cwnd_used)
+			tp->snd_cwnd_used = tp->packets_out;
+
+		if ((s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= tp->rto)
+			tcp_cwnd_application_limited(sk);
+	}
+}
+
 /* This routine writes packets to the network.  It advances the
  * send_head.  This happens as incoming acks open up the remote
  * window for us.
@@ -853,7 +844,7 @@ unsigned int tcp_current_mss(struct sock
  * Returns 1, if no segments are in flight and we have queued segments, but
  * cannot send anything now because of SWS or another problem.
  */
-int tcp_write_xmit(struct sock *sk, int nonagle)
+static int tcp_write_xmit(struct sock *sk, int nonagle)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int mss_now;
@@ -906,6 +897,34 @@ int tcp_write_xmit(struct sock *sk, int 
 	return 0;
 }
 
+/* Push out any pending frames which were held back due to
+ * TCP_CORK or attempt at coalescing tiny packets.
+ * The socket must be locked by the caller.
+ */
+void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
+			       unsigned cur_mss, int nonagle)
+{
+	struct sk_buff *skb = sk->sk_send_head;
+
+	if (skb) {
+		if (!tcp_skb_is_last(sk, skb))
+			nonagle = TCP_NAGLE_PUSH;
+		if (!tcp_snd_test(sk, skb, cur_mss, nonagle) ||
+		    tcp_write_xmit(sk, nonagle))
+			tcp_check_probe_timer(sk, tp);
+	}
+}
+
+void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) ||
+	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
+	    tcp_write_xmit(sk, tp->nonagle))
+		tcp_check_probe_timer(sk, tp);
+}
+
 /* This function returns the amount that we can raise the
  * usable window based on the following constraints
  *  
