From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] skb pcount with MTU discovery
Date: Fri, 1 Apr 2005 16:05:49 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0504011340510.17051@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The problem is that when doing MTU discovery, the too-large segments in
the write queue will be calculated as having a pcount of >1.  When
tcp_write_xmit() is trying to send, tcp_snd_test() fails the cwnd test
when pcount > cwnd.

The segments are eventually transmitted one at a time by keepalive, but
this can take a long time.

This patch checks if TSO is enabled when setting pcount.

  -John



Signed-off-by: John Heffner <jheffner@psc.edu>


===== include/net/tcp.h 1.114 vs edited =====
--- 1.114/include/net/tcp.h	2005-03-31 11:51:09 -05:00
+++ edited/include/net/tcp.h	2005-04-01 14:44:13 -05:00
@@ -1470,19 +1470,20 @@
 		  tcp_minshall_check(tp))));
 }

-extern void tcp_set_skb_tso_segs(struct sk_buff *, unsigned int);
+extern void tcp_set_skb_tso_segs(struct sock *, struct sk_buff *);

 /* This checks if the data bearing packet SKB (usually sk->sk_send_head)
  * should be put on the wire right now.
  */
-static __inline__ int tcp_snd_test(const struct tcp_sock *tp,
+static __inline__ int tcp_snd_test(struct sock *sk,
 				   struct sk_buff *skb,
 				   unsigned cur_mss, int nonagle)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	int pkts = tcp_skb_pcount(skb);

 	if (!pkts) {
-		tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
+		tcp_set_skb_tso_segs(sk, skb);
 		pkts = tcp_skb_pcount(skb);
 	}

@@ -1543,7 +1544,7 @@
 	if (skb) {
 		if (!tcp_skb_is_last(sk, skb))
 			nonagle = TCP_NAGLE_PUSH;
-		if (!tcp_snd_test(tp, skb, cur_mss, nonagle) ||
+		if (!tcp_snd_test(sk, skb, cur_mss, nonagle) ||
 		    tcp_write_xmit(sk, nonagle))
 			tcp_check_probe_timer(sk, tp);
 	}
@@ -1561,7 +1562,7 @@
 	struct sk_buff *skb = sk->sk_send_head;

 	return (skb &&
-		tcp_snd_test(tp, skb, tcp_current_mss(sk, 1),
+		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
 			     tcp_skb_is_last(sk, skb) ? TCP_NAGLE_PUSH : tp->nonagle));
 }

===== net/ipv4/tcp_output.c 1.90 vs edited =====
--- 1.90/net/ipv4/tcp_output.c	2005-04-01 09:08:34 -05:00
+++ edited/net/ipv4/tcp_output.c	2005-04-01 14:45:27 -05:00
@@ -433,7 +433,7 @@
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = sk->sk_send_head;

-	if (tcp_snd_test(tp, skb, cur_mss, TCP_NAGLE_PUSH)) {
+	if (tcp_snd_test(sk, skb, cur_mss, TCP_NAGLE_PUSH)) {
 		/* Send it out now. */
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
 		tcp_tso_set_push(skb);
@@ -446,9 +446,12 @@
 	}
 }

-void tcp_set_skb_tso_segs(struct sk_buff *skb, unsigned int mss_std)
+void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb)
 {
-	if (skb->len <= mss_std) {
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (skb->len <= tp->mss_cache_std ||
+	    !(sk->sk_route_caps & NETIF_F_TSO)) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
@@ -457,10 +460,10 @@
 	} else {
 		unsigned int factor;

-		factor = skb->len + (mss_std - 1);
-		factor /= mss_std;
+		factor = skb->len + (tp->mss_cache_std - 1);
+		factor /= tp->mss_cache_std;
 		skb_shinfo(skb)->tso_segs = factor;
-		skb_shinfo(skb)->tso_size = mss_std;
+		skb_shinfo(skb)->tso_size = tp->mss_cache_std;
 	}
 }

@@ -531,8 +534,8 @@
 	}

 	/* Fix up tso_factor for both original and new SKB.  */
-	tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
-	tcp_set_skb_tso_segs(buff, tp->mss_cache_std);
+	tcp_set_skb_tso_segs(sk, skb);
+	tcp_set_skb_tso_segs(sk, buff);

 	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
 		tp->lost_out += tcp_skb_pcount(skb);
@@ -607,7 +610,7 @@
 	 * factor and mss.
 	 */
 	if (tcp_skb_pcount(skb) > 1)
-		tcp_set_skb_tso_segs(skb, tcp_skb_mss(skb));
+		tcp_set_skb_tso_segs(sk, skb);

 	return 0;
 }
@@ -815,7 +818,7 @@
 			sk_stream_free_skb(sk, skb);
 		} else {
 			TCP_SKB_CB(skb)->seq += copy;
-			tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
+			tcp_set_skb_tso_segs(sk, skb);
 		}

 		len += copy;
@@ -824,7 +827,7 @@

 	__skb_insert(nskb, skb->prev, skb, &sk->sk_write_queue);
 	sk->sk_send_head = nskb;
-	tcp_set_skb_tso_segs(nskb, tp->mss_cache_std);
+	tcp_set_skb_tso_segs(sk, nskb);

 	/* We're ready to send.  If this fails, the probe will
 	 * be resegmented into mss-sized pieces by tcp_write_xmit(). */
@@ -885,7 +888,7 @@
 		mss_now = tcp_current_mss(sk, 1);

 		while ((skb = sk->sk_send_head) &&
-		       tcp_snd_test(tp, skb, mss_now,
+		       tcp_snd_test(sk, skb, mss_now,
 			       	    tcp_skb_is_last(sk, skb) ? nonagle :
 				    			       TCP_NAGLE_PUSH)) {
 			if (skb->len > mss_now) {
@@ -1822,7 +1825,7 @@
 					tp->mss_cache = tp->mss_cache_std;
 				}
 			} else if (!tcp_skb_pcount(skb))
-				tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
+				tcp_set_skb_tso_segs(sk, skb);

 			TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
