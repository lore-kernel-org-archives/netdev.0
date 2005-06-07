From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 3/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:17:56 -0700 (PDT)
Message-ID: <20050606.211756.30188342.davem@davemloft.net>
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


[TCP]: Move send test logic out of net/tcp.h

This just moves the code into tcp_output.c, no code logic changes are
made by this patch.

Using this as a baseline, we can begin to untangle the mess of
comparisons for the Nagle test et al.  We will also be able to reduce
all of the redundant computation that occurs when outputting data
packets.

Signed-off-by: David S. Miller <davem@davemloft.net>

cba5d690f46699d37df7dc087247d1f7c7155692 (from 00cb08b2ec091f4b461210026392edeaccf31d9c)
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -945,6 +945,9 @@ extern __u32 cookie_v4_init_sequence(str
 /* tcp_output.c */
 
 extern int tcp_write_xmit(struct sock *, int nonagle);
+extern void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
+				      unsigned cur_mss, int nonagle);
+extern int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
@@ -1389,12 +1392,6 @@ static __inline__ __u32 tcp_max_burst(co
 	return 3;
 }
 
-static __inline__ int tcp_minshall_check(const struct tcp_sock *tp)
-{
-	return after(tp->snd_sml,tp->snd_una) &&
-		!after(tp->snd_sml, tp->snd_nxt);
-}
-
 static __inline__ void tcp_minshall_update(struct tcp_sock *tp, int mss, 
 					   const struct sk_buff *skb)
 {
@@ -1402,122 +1399,18 @@ static __inline__ void tcp_minshall_upda
 		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
 }
 
-/* Return 0, if packet can be sent now without violation Nagle's rules:
-   1. It is full sized.
-   2. Or it contains FIN.
-   3. Or TCP_NODELAY was set.
-   4. Or TCP_CORK is not set, and all sent packets are ACKed.
-      With Minshall's modification: all sent small packets are ACKed.
- */
-
-static __inline__ int
-tcp_nagle_check(const struct tcp_sock *tp, const struct sk_buff *skb, 
-		unsigned mss_now, int nonagle)
-{
-	return (skb->len < mss_now &&
-		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
-		((nonagle&TCP_NAGLE_CORK) ||
-		 (!nonagle &&
-		  tp->packets_out &&
-		  tcp_minshall_check(tp))));
-}
-
-extern void tcp_set_skb_tso_segs(struct sock *, struct sk_buff *);
-
-/* This checks if the data bearing packet SKB (usually sk->sk_send_head)
- * should be put on the wire right now.
- */
-static __inline__ int tcp_snd_test(struct sock *sk,
-				   struct sk_buff *skb,
-				   unsigned cur_mss, int nonagle)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	int pkts = tcp_skb_pcount(skb);
-
-	if (!pkts) {
-		tcp_set_skb_tso_segs(sk, skb);
-		pkts = tcp_skb_pcount(skb);
-	}
-
-	/*	RFC 1122 - section 4.2.3.4
-	 *
-	 *	We must queue if
-	 *
-	 *	a) The right edge of this frame exceeds the window
-	 *	b) There are packets in flight and we have a small segment
-	 *	   [SWS avoidance and Nagle algorithm]
-	 *	   (part of SWS is done on packetization)
-	 *	   Minshall version sounds: there are no _small_
-	 *	   segments in flight. (tcp_nagle_check)
-	 *	c) We have too many packets 'in flight'
-	 *
-	 * 	Don't use the nagle rule for urgent data (or
-	 *	for the final FIN -DaveM).
-	 *
-	 *	Also, Nagle rule does not apply to frames, which
-	 *	sit in the middle of queue (they have no chances
-	 *	to get new data) and if room at tail of skb is
-	 *	not enough to save something seriously (<32 for now).
-	 */
-
-	/* Don't be strict about the congestion window for the
-	 * final FIN frame.  -DaveM
-	 */
-	return (((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
-		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
-		(((tcp_packets_in_flight(tp) + (pkts-1)) < tp->snd_cwnd) ||
-		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
-		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
-}
-
 static __inline__ void tcp_check_probe_timer(struct sock *sk, struct tcp_sock *tp)
 {
 	if (!tp->packets_out && !tp->pending)
 		tcp_reset_xmit_timer(sk, TCP_TIME_PROBE0, tp->rto);
 }
 
-static __inline__ int tcp_skb_is_last(const struct sock *sk, 
-				      const struct sk_buff *skb)
-{
-	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
-}
-
-/* Push out any pending frames which were held back due to
- * TCP_CORK or attempt at coalescing tiny packets.
- * The socket must be locked by the caller.
- */
-static __inline__ void __tcp_push_pending_frames(struct sock *sk,
-						 struct tcp_sock *tp,
-						 unsigned cur_mss,
-						 int nonagle)
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
 static __inline__ void tcp_push_pending_frames(struct sock *sk,
 					       struct tcp_sock *tp)
 {
 	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk, 1), tp->nonagle);
 }
 
-static __inline__ int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
-{
-	struct sk_buff *skb = sk->sk_send_head;
-
-	return (skb &&
-		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
-			     tcp_skb_is_last(sk, skb) ? TCP_NAGLE_PUSH : tp->nonagle));
-}
-
 static __inline__ void tcp_init_wl(struct tcp_sock *tp, u32 ack, u32 seq)
 {
 	tp->snd_wl1 = seq;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -419,6 +419,135 @@ static inline void tcp_tso_set_push(stru
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 }
 
+static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (skb->len <= tp->mss_cache_std ||
+	    !(sk->sk_route_caps & NETIF_F_TSO)) {
+		/* Avoid the costly divide in the normal
+		 * non-TSO case.
+		 */
+		skb_shinfo(skb)->tso_segs = 1;
+		skb_shinfo(skb)->tso_size = 0;
+	} else {
+		unsigned int factor;
+
+		factor = skb->len + (tp->mss_cache_std - 1);
+		factor /= tp->mss_cache_std;
+		skb_shinfo(skb)->tso_segs = factor;
+		skb_shinfo(skb)->tso_size = tp->mss_cache_std;
+	}
+}
+
+static inline int tcp_minshall_check(const struct tcp_sock *tp)
+{
+	return after(tp->snd_sml,tp->snd_una) &&
+		!after(tp->snd_sml, tp->snd_nxt);
+}
+
+/* Return 0, if packet can be sent now without violation Nagle's rules:
+ * 1. It is full sized.
+ * 2. Or it contains FIN.
+ * 3. Or TCP_NODELAY was set.
+ * 4. Or TCP_CORK is not set, and all sent packets are ACKed.
+ *    With Minshall's modification: all sent small packets are ACKed.
+ */
+
+static inline int tcp_nagle_check(const struct tcp_sock *tp,
+				  const struct sk_buff *skb, 
+				  unsigned mss_now, int nonagle)
+{
+	return (skb->len < mss_now &&
+		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
+		((nonagle&TCP_NAGLE_CORK) ||
+		 (!nonagle &&
+		  tp->packets_out &&
+		  tcp_minshall_check(tp))));
+}
+
+/* This checks if the data bearing packet SKB (usually sk->sk_send_head)
+ * should be put on the wire right now.
+ */
+static int tcp_snd_test(struct sock *sk, struct sk_buff *skb,
+			unsigned cur_mss, int nonagle)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int pkts = tcp_skb_pcount(skb);
+
+	if (!pkts) {
+		tcp_set_skb_tso_segs(sk, skb);
+		pkts = tcp_skb_pcount(skb);
+	}
+
+	/*	RFC 1122 - section 4.2.3.4
+	 *
+	 *	We must queue if
+	 *
+	 *	a) The right edge of this frame exceeds the window
+	 *	b) There are packets in flight and we have a small segment
+	 *	   [SWS avoidance and Nagle algorithm]
+	 *	   (part of SWS is done on packetization)
+	 *	   Minshall version sounds: there are no _small_
+	 *	   segments in flight. (tcp_nagle_check)
+	 *	c) We have too many packets 'in flight'
+	 *
+	 * 	Don't use the nagle rule for urgent data (or
+	 *	for the final FIN -DaveM).
+	 *
+	 *	Also, Nagle rule does not apply to frames, which
+	 *	sit in the middle of queue (they have no chances
+	 *	to get new data) and if room at tail of skb is
+	 *	not enough to save something seriously (<32 for now).
+	 */
+
+	/* Don't be strict about the congestion window for the
+	 * final FIN frame.  -DaveM
+	 */
+	return (((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
+		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
+		(((tcp_packets_in_flight(tp) + (pkts-1)) < tp->snd_cwnd) ||
+		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
+		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
+}
+
+static inline int tcp_skb_is_last(const struct sock *sk, 
+				  const struct sk_buff *skb)
+{
+	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
+}
+
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
+	tcp_cwnd_validate(sk, tp);
+}
+
+int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
+{
+	struct sk_buff *skb = sk->sk_send_head;
+
+	return (skb &&
+		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
+			     (tcp_skb_is_last(sk, skb) ?
+			      TCP_NAGLE_PUSH :
+			      tp->nonagle)));
+}
+
+
 /* Send _single_ skb sitting at the send head. This function requires
  * true push pending frames to setup probe timer etc.
  */
@@ -440,27 +569,6 @@ void tcp_push_one(struct sock *sk, unsig
 	}
 }
 
-void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (skb->len <= tp->mss_cache_std ||
-	    !(sk->sk_route_caps & NETIF_F_TSO)) {
-		/* Avoid the costly divide in the normal
-		 * non-TSO case.
-		 */
-		skb_shinfo(skb)->tso_segs = 1;
-		skb_shinfo(skb)->tso_size = 0;
-	} else {
-		unsigned int factor;
-
-		factor = skb->len + (tp->mss_cache_std - 1);
-		factor /= tp->mss_cache_std;
-		skb_shinfo(skb)->tso_segs = factor;
-		skb_shinfo(skb)->tso_size = tp->mss_cache_std;
-	}
-}
-
 /* Function to create two new TCP segments.  Shrinks the given segment
  * to the specified size and appends a new segment with the rest of the
  * packet to the list.  This won't be called frequently, I hope. 
