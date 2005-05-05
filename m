From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH] TSO Reloaded
Date: Wed, 4 May 2005 23:07:31 -0700
Message-ID: <20050504230731.12be1bc3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, here it is, first draft of the new TSO handling
I promised so long ago :-)  I was lazy and waited until
today to implement the entire thing.

It works with basic testing over tg3.

I'll discuss the changes in more detail tomorrow, but
the only potentially sore spot right now is the tcp_push_one()
avoidance done in tcp_sendmsg() and tcp_sendpages().  It may
need to be changed to do so mething like "if not TSO then
tcp_push_one(), else wait for N packets to accumulate" where
N is configurable or dynamically measured in some way.

It would be nice to know that this thing works with e1000 and
other TSO capable cards, also I did not do much sendfile() testing
at all.

Thanks.

--- ./include/linux/tcp.h.~1~	2005-04-20 10:18:11.000000000 -0700
+++ ./include/linux/tcp.h	2005-05-04 15:21:50.000000000 -0700
@@ -280,8 +280,7 @@ struct tcp_sock {
 	__u32	snd_wnd;	/* The window we expect to receive	*/
 	__u32	max_window;	/* Maximal window ever seen from peer	*/
 	__u32	pmtu_cookie;	/* Last pmtu seen by socket		*/
-	__u32	mss_cache;	/* Cached effective mss, not including SACKS */
-	__u16	mss_cache_std;	/* Like mss_cache, but without TSO */
+	__u16	mss_cache;	/* Cached effective mss, not including SACKS */
 	__u16	ext_header_len;	/* Network protocol overhead (IP/IPv6 options) */
 	__u8	ca_state;	/* State of fast-retransmit machine 	*/
 	__u8	retransmits;	/* Number of unrecovered RTO timeouts.	*/
--- ./include/net/tcp.h.~1~	2005-05-03 14:32:02.000000000 -0700
+++ ./include/net/tcp.h	2005-05-04 22:42:49.000000000 -0700
@@ -943,7 +943,6 @@ extern int tcp_write_xmit(struct sock *,
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
-extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
 
 extern void tcp_send_probe0(struct sock *);
 extern void tcp_send_partial(struct sock *);
@@ -962,7 +961,7 @@ extern void tcp_clear_xmit_timers(struct
 extern void tcp_delete_keepalive_timer(struct sock *);
 extern void tcp_reset_keepalive_timer(struct sock *, unsigned long);
 extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
-extern unsigned int tcp_current_mss(struct sock *sk, int large);
+extern unsigned int tcp_current_mss(struct sock *sk);
 
 #ifdef TCP_DEBUG
 extern const char tcp_timer_bug_msg[];
@@ -1054,7 +1053,7 @@ static inline void tcp_reset_xmit_timer(
 static inline void tcp_initialize_rcv_mss(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned int hint = min(tp->advmss, tp->mss_cache_std);
+	unsigned int hint = min(tp->advmss, tp->mss_cache);
 
 	hint = min(hint, tp->rcv_wnd/2);
 	hint = min(hint, TCP_MIN_RCVMSS);
@@ -1163,45 +1162,16 @@ struct tcp_skb_cb {
 
 #include <net/tcp_ecn.h>
 
-/* Due to TSO, an SKB can be composed of multiple actual
- * packets.  To keep these tracked properly, we use this.
- */
-static inline int tcp_skb_pcount(const struct sk_buff *skb)
-{
-	return skb_shinfo(skb)->tso_segs;
-}
-
-/* This is valid iff tcp_skb_pcount() > 1. */
-static inline int tcp_skb_mss(const struct sk_buff *skb)
-{
-	return skb_shinfo(skb)->tso_size;
-}
-
-static inline void tcp_dec_pcount_approx(__u32 *count,
-					 const struct sk_buff *skb)
-{
-	if (*count) {
-		*count -= tcp_skb_pcount(skb);
-		if ((int)*count < 0)
-			*count = 0;
-	}
-}
-
 static inline void tcp_packets_out_inc(struct sock *sk, 
-				       struct tcp_sock *tp,
-				       const struct sk_buff *skb)
+				       struct tcp_sock *tp)
 {
-	int orig = tp->packets_out;
-
-	tp->packets_out += tcp_skb_pcount(skb);
-	if (!orig)
+	if (!tp->packets_out++)
 		tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
 }
 
-static inline void tcp_packets_out_dec(struct tcp_sock *tp, 
-				       const struct sk_buff *skb)
+static inline void tcp_packets_out_dec(struct tcp_sock *tp)
 {
-	tp->packets_out -= tcp_skb_pcount(skb);
+	tp->packets_out--;
 }
 
 /* This determines how many packets are "in the network" to the best
@@ -1397,57 +1367,39 @@ static __inline__ void tcp_minshall_upda
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
+/* This determines how many packets, starting with skb,
+ * should be put on the wire right now.  It is guarenteed
+ * that this many valid packets are in the socket write
+ * queue, and all of which are in-window.
  */
-static __inline__ int tcp_snd_test(struct sock *sk,
-				   struct sk_buff *skb,
-				   unsigned cur_mss, int nonagle)
+static __inline__ unsigned int tcp_snd_test(struct sock *sk,
+					    struct sk_buff *skb,
+					    unsigned cur_mss, int nonagle)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int pkts = tcp_skb_pcount(skb);
-
-	if (!pkts) {
-		tcp_set_skb_tso_segs(sk, skb);
-		pkts = tcp_skb_pcount(skb);
-	}
+	unsigned int in_flight, cwnd;
+	int nagle_check, nagle_allows;
 
 	/*	RFC 1122 - section 4.2.3.4
 	 *
-	 *	We must queue if
-	 *
-	 *	a) The right edge of this frame exceeds the window
-	 *	b) There are packets in flight and we have a small segment
-	 *	   [SWS avoidance and Nagle algorithm]
-	 *	   (part of SWS is done on packetization)
-	 *	   Minshall version sounds: there are no _small_
-	 *	   segments in flight. (tcp_nagle_check)
-	 *	c) We have too many packets 'in flight'
+	 *	We must queue if the right edge of this frame exceeds
+	 *	the window.
+	 */
+	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd))
+		return 0;
+
+	/*	If we're looking at the final FIN frame, just sent it
+	 *	out now.
+	 */
+	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
+		return 1;
+
+	/*	We must queue if there are packets in flight and we have
+	 *	a small segment (SWS avoidance and Nagle algorithm, part
+	 *	of SWS is done on packetization).  Minshall version sounds:
+	 *	there are no _small_ segments in flight.
 	 *
-	 * 	Don't use the nagle rule for urgent data (or
-	 *	for the final FIN -DaveM).
+	 * 	Don't use the nagle rule for urgent data.
 	 *
 	 *	Also, Nagle rule does not apply to frames, which
 	 *	sit in the middle of queue (they have no chances
@@ -1455,14 +1407,36 @@ static __inline__ int tcp_snd_test(struc
 	 *	not enough to save something seriously (<32 for now).
 	 */
 
-	/* Don't be strict about the congestion window for the
-	 * final FIN frame.  -DaveM
-	 */
-	return (((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
-		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
-		(((tcp_packets_in_flight(tp) + (pkts-1)) < tp->snd_cwnd) ||
-		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
-		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
+	nagle_check = (skb->len < cur_mss &&
+		       ((nonagle&TCP_NAGLE_CORK) ||
+			(!nonagle &&
+			 tp->packets_out &&
+			 tcp_minshall_check(tp))));
+	nagle_allows = ((nonagle & TCP_NAGLE_PUSH) ||
+			tp->urg_mode		   ||
+			!nagle_check);
+	if (!nagle_allows)
+		return 0;
+
+	/*	We must queue if we have too many packets 'in flight'.  */
+	in_flight = tcp_packets_in_flight(tp);
+	cwnd = tp->snd_cwnd;
+	if (in_flight < cwnd) {
+		unsigned int ret = 0;
+
+		cwnd -= in_flight;
+		while (cwnd--) {
+			ret++;
+			skb = skb->next;
+			if (skb == (struct sk_buff *)&sk->sk_write_queue ||
+			    after(TCP_SKB_CB(skb)->end_seq,
+				  tp->snd_una+tp->snd_wnd))
+				break;
+		}
+		return ret;
+	}
+
+	return 0;
 }
 
 static __inline__ void tcp_check_probe_timer(struct sock *sk, struct tcp_sock *tp)
@@ -1501,7 +1475,7 @@ static __inline__ void __tcp_push_pendin
 static __inline__ void tcp_push_pending_frames(struct sock *sk,
 					       struct tcp_sock *tp)
 {
-	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk, 1), tp->nonagle);
+	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk), tp->nonagle);
 }
 
 static __inline__ int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
@@ -1509,7 +1483,7 @@ static __inline__ int tcp_may_send_now(s
 	struct sk_buff *skb = sk->sk_send_head;
 
 	return (skb &&
-		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
+		tcp_snd_test(sk, skb, tcp_current_mss(sk),
 			     tcp_skb_is_last(sk, skb) ? TCP_NAGLE_PUSH : tp->nonagle));
 }
 
@@ -1986,7 +1960,7 @@ static inline void tcp_westwood_update_r
 static inline __u32 __tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
 {
         return max((tp->westwood.bw_est) * (tp->westwood.rtt_min) /
-		   (__u32) (tp->mss_cache_std),
+		   (__u32) (tp->mss_cache),
 		   2U);
 }
 
--- ./include/net/sock.h.~1~	2005-05-03 11:34:28.000000000 -0700
+++ ./include/net/sock.h	2005-05-04 16:35:59.000000000 -0700
@@ -1128,13 +1128,16 @@ static inline void sk_stream_moderate_sn
 static inline struct sk_buff *sk_stream_alloc_pskb(struct sock *sk,
 						   int size, int mem, int gfp)
 {
-	struct sk_buff *skb = alloc_skb(size + sk->sk_prot->max_header, gfp);
+	struct sk_buff *skb;
+	int hdr_len;
 
+	hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
+	skb = alloc_skb(size + hdr_len, gfp);
 	if (skb) {
 		skb->truesize += mem;
 		if (sk->sk_forward_alloc >= (int)skb->truesize ||
 		    sk_stream_mem_schedule(sk, skb->truesize, 0)) {
-			skb_reserve(skb, sk->sk_prot->max_header);
+			skb_reserve(skb, hdr_len);
 			return skb;
 		}
 		__kfree_skb(skb);
--- ./net/ipv4/tcp_output.c.~1~	2005-04-24 19:06:29.000000000 -0700
+++ ./net/ipv4/tcp_output.c	2005-05-04 22:55:15.000000000 -0700
@@ -41,6 +41,7 @@
 #include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/smp_lock.h>
+#include <linux/kallsyms.h>
 
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse = 1;
@@ -58,7 +59,7 @@ static inline void update_send_head(stru
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
-	tcp_packets_out_inc(sk, tp, skb);
+	tcp_packets_out_inc(sk, tp);
 }
 
 /* SND.NXT, if window was not shrunk.
@@ -274,12 +275,13 @@ static int tcp_transmit_skb(struct sock 
 		int sysctl_flags;
 		int err;
 
-		BUG_ON(!tcp_skb_pcount(skb));
-
 #define SYSCTL_FLAG_TSTAMPS	0x1
 #define SYSCTL_FLAG_WSCALE	0x2
 #define SYSCTL_FLAG_SACK	0x4
 
+		/* Callers must make sure this is set to 1 or greater.  */
+		BUG_ON(!skb_shinfo(skb)->tso_segs);
+
 		sysctl_flags = 0;
 		if (tcb->flags & TCPCB_FLAG_SYN) {
 			tcp_header_size = sizeof(struct tcphdr) + TCPOLEN_MSS;
@@ -409,58 +411,32 @@ static void tcp_queue_skb(struct sock *s
 		sk->sk_send_head = skb;
 }
 
-static inline void tcp_tso_set_push(struct sk_buff *skb)
-{
-	/* Force push to be on for any TSO frames to workaround
-	 * problems with busted implementations like Mac OS-X that
-	 * hold off socket receive wakeups until push is seen.
-	 */
-	if (tcp_skb_pcount(skb) > 1)
-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
-}
-
 /* Send _single_ skb sitting at the send head. This function requires
- * true push pending frames to setup probe timer etc.
+ * true push pending frames to setup probe timer etc.  Since we are
+ * sending only one frame, at most, there is no reason to try to
+ * cons up a TSO frame here.
  */
 void tcp_push_one(struct sock *sk, unsigned cur_mss)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = sk->sk_send_head;
 
-	if (tcp_snd_test(sk, skb, cur_mss, TCP_NAGLE_PUSH)) {
+	if (tcp_snd_test(sk, skb, cur_mss, TCP_NAGLE_PUSH) != 0) {
 		/* Send it out now. */
+#if 0
+		printk("TCP: tcp_push_one() PACKETS_OUT(%d) CWND(%d) WRITE_QLEN(%d)\n",
+		       tp->packets_out, tp->snd_cwnd, skb_queue_len(&sk->sk_write_queue));
+#endif
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
-		tcp_tso_set_push(skb);
 		if (!tcp_transmit_skb(sk, skb_clone(skb, sk->sk_allocation))) {
 			sk->sk_send_head = NULL;
 			tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
-			tcp_packets_out_inc(sk, tp, skb);
+			tcp_packets_out_inc(sk, tp);
 			return;
 		}
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
@@ -468,7 +444,6 @@ void tcp_set_skb_tso_segs(struct sock *s
  */
 static int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
 	int nsize;
 	u16 flags;
@@ -488,6 +463,10 @@ static int tcp_fragment(struct sock *sk,
 		return -ENOMEM; /* We'll just try again later. */
 	sk_charge_skb(sk, buff);
 
+	/* Init TSO state.  */
+	skb_shinfo(buff)->tso_segs = 1;
+	skb_shinfo(buff)->tso_size = 0;
+
 	/* Correct the sequence numbers. */
 	TCP_SKB_CB(buff)->seq = TCP_SKB_CB(skb)->seq + len;
 	TCP_SKB_CB(buff)->end_seq = TCP_SKB_CB(skb)->end_seq;
@@ -522,93 +501,12 @@ static int tcp_fragment(struct sock *sk,
 	 */
 	TCP_SKB_CB(buff)->when = TCP_SKB_CB(skb)->when;
 
-	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
-		tp->lost_out -= tcp_skb_pcount(skb);
-		tp->left_out -= tcp_skb_pcount(skb);
-	}
-
-	/* Fix up tso_factor for both original and new SKB.  */
-	tcp_set_skb_tso_segs(sk, skb);
-	tcp_set_skb_tso_segs(sk, buff);
-
-	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
-		tp->lost_out += tcp_skb_pcount(skb);
-		tp->left_out += tcp_skb_pcount(skb);
-	}
-
-	if (TCP_SKB_CB(buff)->sacked&TCPCB_LOST) {
-		tp->lost_out += tcp_skb_pcount(buff);
-		tp->left_out += tcp_skb_pcount(buff);
-	}
-
 	/* Link BUFF into the send queue. */
 	__skb_append(skb, buff);
 
 	return 0;
 }
 
-/* This is similar to __pskb_pull_head() (it will go to core/skbuff.c
- * eventually). The difference is that pulled data not copied, but
- * immediately discarded.
- */
-static unsigned char *__pskb_trim_head(struct sk_buff *skb, int len)
-{
-	int i, k, eat;
-
-	eat = len;
-	k = 0;
-	for (i=0; i<skb_shinfo(skb)->nr_frags; i++) {
-		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
-			eat -= skb_shinfo(skb)->frags[i].size;
-		} else {
-			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
-			if (eat) {
-				skb_shinfo(skb)->frags[k].page_offset += eat;
-				skb_shinfo(skb)->frags[k].size -= eat;
-				eat = 0;
-			}
-			k++;
-		}
-	}
-	skb_shinfo(skb)->nr_frags = k;
-
-	skb->tail = skb->data;
-	skb->data_len -= len;
-	skb->len = skb->data_len;
-	return skb->tail;
-}
-
-int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
-{
-	if (skb_cloned(skb) &&
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-		return -ENOMEM;
-
-	if (len <= skb_headlen(skb)) {
-		__skb_pull(skb, len);
-	} else {
-		if (__pskb_trim_head(skb, len-skb_headlen(skb)) == NULL)
-			return -ENOMEM;
-	}
-
-	TCP_SKB_CB(skb)->seq += len;
-	skb->ip_summed = CHECKSUM_HW;
-
-	skb->truesize	     -= len;
-	sk->sk_wmem_queued   -= len;
-	sk->sk_forward_alloc += len;
-	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
-
-	/* Any change of skb->len requires recalculation of tso
-	 * factor and mss.
-	 */
-	if (tcp_skb_pcount(skb) > 1)
-		tcp_set_skb_tso_segs(sk, skb);
-
-	return 0;
-}
-
 /* This function synchronize snd mss to current pmtu/exthdr set.
 
    tp->rx_opt.user_mss is mss set by user by TCP_MAXSEG. It does NOT counts
@@ -662,7 +560,7 @@ unsigned int tcp_sync_mss(struct sock *s
 
 	/* And store cached results */
 	tp->pmtu_cookie = pmtu;
-	tp->mss_cache = tp->mss_cache_std = mss_now;
+	tp->mss_cache = mss_now;
 
 	return mss_now;
 }
@@ -675,56 +573,306 @@ unsigned int tcp_sync_mss(struct sock *s
  * is not a big flaw.
  */
 
-unsigned int tcp_current_mss(struct sock *sk, int large)
+unsigned int tcp_current_mss(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
-	unsigned int do_large, mss_now;
+	unsigned int mss_now;
 
-	mss_now = tp->mss_cache_std;
+	mss_now = tp->mss_cache;
 	if (dst) {
 		u32 mtu = dst_mtu(dst);
 		if (mtu != tp->pmtu_cookie)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
-	do_large = (large &&
-		    (sk->sk_route_caps & NETIF_F_TSO) &&
-		    !tp->urg_mode);
-
-	if (do_large) {
-		unsigned int large_mss, factor, limit;
-
-		large_mss = 65535 - tp->af_specific->net_header_len -
-			tp->ext_header_len - tp->tcp_header_len;
-
-		if (tp->max_window && large_mss > (tp->max_window>>1))
-			large_mss = max((tp->max_window>>1),
-					68U - tp->tcp_header_len);
-
-		factor = large_mss / mss_now;
-
-		/* Always keep large mss multiple of real mss, but
-		 * do not exceed 1/tso_win_divisor of the congestion window
-		 * so we can keep the ACK clock ticking and minimize
-		 * bursting.
+	if (tp->rx_opt.eff_sacks)
+		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
+			    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
+	return mss_now;
+}
+
+static inline int tcp_skb_data_all_paged(struct sk_buff *skb)
+{
+	return (skb->len == skb->data_len);
+}
+
+/* If possible, append paged data of SRC_SKB onto the
+ * tail of DST_SKB.
+ *
+ * The only truly complicated part about this is cleanly
+ * unwinding the state when we hit MAX_SKB_FRAGS.  We defer
+ * updating nr_frags and data_len until all frags are appended
+ * successfully.
+ */
+static int skb_append_pages(struct sk_buff *dst_skb, struct sk_buff *src_skb)
+{
+	int i, dst_nr_frags, dst_new_data_len, err;
+	int first_new_frag = -1;
+	int orig_tail_frag_size = -1;
+
+	if (!tcp_skb_data_all_paged(src_skb)) {
+#if 0
+		printk("skb_append_data: SRC skb not all paged, len(%d) data_len(%d)\n",
+		       src_skb->len, src_skb->data_len);
+#endif
+		return -EINVAL;
+	}
+
+	dst_nr_frags = skb_shinfo(dst_skb)->nr_frags;
+	dst_new_data_len = 0;
+	if (dst_nr_frags != 0) {
+		skb_frag_t *frag = &skb_shinfo(dst_skb)->frags[dst_nr_frags-1];
+
+		orig_tail_frag_size = frag->size;
+	}
+	for (i = 0; i < skb_shinfo(src_skb)->nr_frags; i++) {
+		skb_frag_t *src_frag = &skb_shinfo(src_skb)->frags[i];
+		skb_frag_t *dst_frag;
+		int dst_frag_idx;
+
+		dst_frag_idx = dst_nr_frags;
+
+		if (skb_can_coalesce(dst_skb, dst_frag_idx,
+				     src_frag->page, src_frag->page_offset)) {
+			dst_frag = &skb_shinfo(dst_skb)->frags[dst_frag_idx-1];
+			dst_frag->size += src_frag->size;
+		} else {
+			err = -EMSGSIZE;
+			if (dst_frag_idx >= MAX_SKB_FRAGS) {
+#if 0
+				printk("skb_append_data: Hit MAX_SKB_FRAGS, unwinding.\n");
+#endif
+				goto unwind_state;
+			}
+
+			if (first_new_frag == -1)
+				first_new_frag = dst_frag_idx;
+			dst_frag = &skb_shinfo(dst_skb)->frags[dst_frag_idx];
+			dst_nr_frags = dst_frag_idx + 1;
+
+			dst_frag->page = src_frag->page;
+			get_page(src_frag->page);
+
+			dst_frag->page_offset = src_frag->page_offset;
+			dst_frag->size = src_frag->size;
+		}
+		dst_new_data_len += src_frag->size;
+	}
+	skb_shinfo(dst_skb)->nr_frags = dst_nr_frags;
+	dst_skb->len += dst_new_data_len;
+	dst_skb->data_len += dst_new_data_len;
+	dst_skb->truesize += dst_new_data_len;
+	TCP_SKB_CB(dst_skb)->end_seq += dst_new_data_len;
+	TCP_SKB_CB(dst_skb)->flags |=
+	  (TCP_SKB_CB(src_skb)->flags & (TCPCB_FLAG_FIN|TCPCB_FLAG_PSH));
+
+	return 0;
+
+unwind_state:
+	/* Release any coalesced data.  */
+	if (orig_tail_frag_size != -1) {
+		int nr_frags = skb_shinfo(dst_skb)->nr_frags;
+		skb_frag_t *frag = &skb_shinfo(dst_skb)->frags[nr_frags-1];
+
+		frag->size = orig_tail_frag_size;
+	}
+
+	/* Release any pages we added.  */
+	if (first_new_frag != -1) {
+		for (i = first_new_frag; i < dst_nr_frags; i++) {
+			skb_frag_t *frag = &skb_shinfo(dst_skb)->frags[i];
+
+			BUG_ON(!frag->page);
+			put_page(frag->page);
+			frag->page = NULL;
+		}
+	}
+
+	return err;
+}
+
+static inline struct sk_buff *alloc_tso_skb(struct sock *sk,
+					    struct tcp_sock *tp,
+					    struct sk_buff *cur,
+					    struct sk_buff *head)
+{
+	int hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
+
+	if (cur)
+		return cur;
+
+	if (!(sk->sk_route_caps & NETIF_F_TSO) ||
+	    tp->urg_mode)
+		return NULL;
+
+	cur = alloc_skb(hdr_len, GFP_ATOMIC);
+	if (cur) {
+		skb_reserve(cur, hdr_len);
+		skb_shinfo(cur)->tso_segs = 1;
+		skb_shinfo(cur)->tso_size = 0;
+		TCP_SKB_CB(cur)->seq = TCP_SKB_CB(head)->seq;
+		TCP_SKB_CB(cur)->end_seq = TCP_SKB_CB(head)->seq;
+		TCP_SKB_CB(cur)->flags = TCPCB_FLAG_ACK;
+		TCP_SKB_CB(cur)->sacked = 0;
+		cur->ip_summed = head->ip_summed;
+	}
+	return cur;
+}
+
+static inline int tcp_transmit_tso_skb(struct sock *sk, unsigned int mss_now, unsigned int tso_count, struct sk_buff *tso_skb, struct sk_buff *last)
+{
+	int err;
+
+	BUG_ON(!last);
+	if (tso_skb->len > mss_now) {
+		unsigned int len = tso_skb->len;
+
+		len += (mss_now - 1);
+		skb_shinfo(tso_skb)->tso_segs = len / mss_now;
+		skb_shinfo(tso_skb)->tso_size = mss_now;
+	}
+
+	err = tcp_transmit_skb(sk, tso_skb);
+	if (!err) {
+		struct tcp_sock *tp = tcp_sk(sk);
+		int orig;
+
+		sk->sk_send_head = last->next;
+		if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
+			sk->sk_send_head = NULL;
+		tp->snd_nxt = TCP_SKB_CB(tso_skb)->end_seq;
+
+		orig = tp->packets_out;
+		tp->packets_out += tso_count;
+		if (!orig)
+			tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
+
+		tcp_minshall_update(tp, mss_now, tso_skb);
+	}
+
+	return err;
+}
+
+/* Transmit N packets starting at SKB.  If possible, coalesce packets
+ * into TSO frames, else just send them one-by-one.  Return the number
+ * of frames actually sent.
+ */
+static unsigned int segment_and_xmit(struct sock *sk, struct sk_buff *skb, unsigned int mss_now, unsigned int n)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *tso_skb, *last;
+	unsigned int sent = 0, tso_count;
+
+#if 0
+	printk("TCP: segment_and_xmit() N(%d) PACKETS_OUT(%d) CWND(%d) WRITE_QLEN(%d) ",
+	       n, tp->packets_out, tp->snd_cwnd, skb_queue_len(&sk->sk_write_queue));
+	print_symbol("from(%s)\n", (unsigned long)__builtin_return_address(0));
+#endif
+	tso_skb = alloc_tso_skb(sk, tp, NULL, skb);
+	last = NULL;
+	tso_count = 0;
+	while (n--) {
+		struct sk_buff *next;
+
+		/* tcp_snd_test() guarentees this for us.  */
+		BUG_ON(skb == (struct sk_buff *)&sk->sk_write_queue ||
+		       after(TCP_SKB_CB(skb)->end_seq,
+			     tp->snd_una+tp->snd_wnd));
+
+		if (skb->len > mss_now &&
+		    tcp_fragment(sk, skb, mss_now))
+			break;
+
+		/* This must be after the tcp_fragment() call.  */
+		next = skb->next;
+
+		/* Always update transmit stamp, even when doing TSO
+		 * gathering.
 		 */
-		limit = tp->snd_cwnd;
-		if (sysctl_tcp_tso_win_divisor)
-			limit /= sysctl_tcp_tso_win_divisor;
-		limit = max(1U, limit);
-		if (factor > limit)
-			factor = limit;
+		TCP_SKB_CB(skb)->when = tcp_time_stamp;
+
+		if (tso_skb) {
+			int err;
+
+		do_append:
+			err = skb_append_pages(tso_skb, skb);
+			if (!err) {
+				last = skb;
+				tso_count++;
+				goto next_packet;
+			}
+
+			/* Either we hit the MAX_SKB_FRAGS limit, or
+			 * we hit a packet that has non-paged data.
+			 * Regardless, we first send off the existing
+			 * TSO frame we've been building if it contains
+			 * any data.
+			 */
+			if (tso_skb->len) {
+				TCP_SKB_CB(tso_skb)->when = tcp_time_stamp;
+				if (tcp_transmit_tso_skb(sk, mss_now, tso_count,
+							 tso_skb, last))
+					break;
+				tso_skb = NULL;
+			}
+			tso_skb = alloc_tso_skb(sk, tp, tso_skb, skb);
+			last = NULL;
+			tso_count = 0;
+			if (tso_skb && err == -EMSGSIZE)
+				goto do_append;
 
-		tp->mss_cache = mss_now * factor;
+			/* Fallthrough to send the non-paged SKB.  */
+		}
+		if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
+			break;
+
+		update_send_head(sk, tp, skb);
 
-		mss_now = tp->mss_cache;
+		tcp_minshall_update(tp, mss_now, skb);
+
+	next_packet:
+		sent++;
+
+		skb = next;
+	}
+	if (tso_skb) {
+		if (tso_skb->len) {
+			TCP_SKB_CB(tso_skb)->when = tcp_time_stamp;
+			tcp_transmit_tso_skb(sk, mss_now, tso_count,
+					     tso_skb, last);
+		} else
+			kfree_skb(tso_skb);
 	}
 
-	if (tp->rx_opt.eff_sacks)
-		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
-			    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
-	return mss_now;
+	return sent;
+}
+
+/* Send as much of the send queue as possible, possibly coalescing
+ * single frames into TSO frames.  Return whether any packets were
+ * sent successfully.
+ */
+static inline unsigned int emit_send_queue(struct sock *sk, int nonagle)
+{
+	struct sk_buff *skb = sk->sk_send_head;
+	unsigned int mss_now = tcp_current_mss(sk);
+	unsigned int packets_allowed;
+	unsigned int sent_pkts = 0;
+
+	if (!skb)
+		goto out;
+
+	packets_allowed = tcp_snd_test(sk, skb, mss_now,
+				       tcp_skb_is_last(sk, skb) ?
+				       nonagle :
+				       TCP_NAGLE_PUSH);
+	if (!packets_allowed)
+		goto out;
+
+	sent_pkts = segment_and_xmit(sk, skb, mss_now, packets_allowed);
+
+out:
+	return sent_pkts;
 }
 
 /* This routine writes packets to the network.  It advances the
@@ -736,48 +884,14 @@ unsigned int tcp_current_mss(struct sock
  */
 int tcp_write_xmit(struct sock *sk, int nonagle)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned int mss_now;
-
 	/* If we are closed, the bytes will have to remain here.
 	 * In time closedown will finish, we empty the write queue and all
 	 * will be happy.
 	 */
 	if (sk->sk_state != TCP_CLOSE) {
-		struct sk_buff *skb;
-		int sent_pkts = 0;
-
-		/* Account for SACKS, we may need to fragment due to this.
-		 * It is just like the real MSS changing on us midstream.
-		 * We also handle things correctly when the user adds some
-		 * IP options mid-stream.  Silly to do, but cover it.
-		 */
-		mss_now = tcp_current_mss(sk, 1);
-
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
-				break;
-
-			/* Advance the send_head.  This one is sent out.
-			 * This call will increment packets_out.
-			 */
-			update_send_head(sk, tp, skb);
-
-			tcp_minshall_update(tp, mss_now, skb);
-			sent_pkts = 1;
-		}
+		struct tcp_sock *tp = tcp_sk(sk);
 
-		if (sent_pkts) {
+		if (emit_send_queue(sk, nonagle)) {
 			tcp_cwnd_validate(sk, tp);
 			return 0;
 		}
@@ -928,9 +1042,6 @@ static void tcp_retrans_try_collapse(str
 		    ((skb_size + next_skb_size) > mss_now))
 			return;
 
-		BUG_ON(tcp_skb_pcount(skb) != 1 ||
-		       tcp_skb_pcount(next_skb) != 1);
-
 		/* Ok.  We will be able to collapse the packet. */
 		__skb_unlink(next_skb, next_skb->list);
 
@@ -954,22 +1065,23 @@ static void tcp_retrans_try_collapse(str
 		 */
 		TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked&(TCPCB_EVER_RETRANS|TCPCB_AT_TAIL);
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_SACKED_RETRANS)
-			tp->retrans_out -= tcp_skb_pcount(next_skb);
+			tp->retrans_out--;
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_LOST) {
-			tp->lost_out -= tcp_skb_pcount(next_skb);
-			tp->left_out -= tcp_skb_pcount(next_skb);
+			tp->lost_out--;
+			tp->left_out--;
 		}
 		/* Reno case is special. Sigh... */
 		if (!tp->rx_opt.sack_ok && tp->sacked_out) {
-			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
-			tp->left_out -= tcp_skb_pcount(next_skb);
+			tp->sacked_out--;
+			tp->left_out--;
 		}
 
 		/* Not quite right: it can be > snd.fack, but
 		 * it is better to underestimate fackets.
 		 */
-		tcp_dec_pcount_approx(&tp->fackets_out, next_skb);
-		tcp_packets_out_dec(tp, next_skb);
+		if (tp->fackets_out)
+			tp->fackets_out--;
+		tcp_packets_out_dec(tp);
 		sk_stream_free_skb(sk, next_skb);
 	}
 }
@@ -982,7 +1094,7 @@ void tcp_simple_retransmit(struct sock *
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	unsigned int mss = tcp_current_mss(sk, 0);
+	unsigned int mss = tcp_current_mss(sk);
 	int lost = 0;
 
 	sk_stream_for_retrans_queue(skb, sk) {
@@ -990,11 +1102,11 @@ void tcp_simple_retransmit(struct sock *
 		    !(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
 			if (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -= tcp_skb_pcount(skb);
+				tp->retrans_out--;
 			}
 			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_LOST)) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tp->lost_out += tcp_skb_pcount(skb);
+				tp->lost_out++;
 				lost = 1;
 			}
 		}
@@ -1027,7 +1139,7 @@ void tcp_simple_retransmit(struct sock *
 int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
- 	unsigned int cur_mss = tcp_current_mss(sk, 0);
+ 	unsigned int cur_mss = tcp_current_mss(sk);
 	int err;
 
 	/* Do not sent more than we queued. 1/4 is reserved for possible
@@ -1037,20 +1149,6 @@ int tcp_retransmit_skb(struct sock *sk, 
 	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
 		return -EAGAIN;
 
-	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
-		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
-			BUG();
-
-		if (sk->sk_route_caps & NETIF_F_TSO) {
-			sk->sk_route_caps &= ~NETIF_F_TSO;
-			sock_set_flag(sk, SOCK_NO_LARGESEND);
-			tp->mss_cache = tp->mss_cache_std;
-		}
-
-		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
-			return -ENOMEM;
-	}
-
 	/* If receiver has shrunk his window, and skb is out of
 	 * new window, do not retransmit it. The exception is the
 	 * case, when window is shrunk to zero. In this case
@@ -1061,16 +1159,11 @@ int tcp_retransmit_skb(struct sock *sk, 
 		return -EAGAIN;
 
 	if (skb->len > cur_mss) {
-		int old_factor = tcp_skb_pcount(skb);
-		int new_factor;
-
 		if (tcp_fragment(sk, skb, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
 
 		/* New SKB created, account for it. */
-		new_factor = tcp_skb_pcount(skb);
-		tp->packets_out -= old_factor - new_factor;
-		tp->packets_out += tcp_skb_pcount(skb->next);
+		tp->packets_out++;
 	}
 
 	/* Collapse two adjacent packets if worthwhile and we can. */
@@ -1079,7 +1172,6 @@ int tcp_retransmit_skb(struct sock *sk, 
 	   (skb->next != sk->sk_send_head) &&
 	   (skb->next != (struct sk_buff *)&sk->sk_write_queue) &&
 	   (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(skb->next)->nr_frags == 0) &&
-	   (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(skb->next) == 1) &&
 	   (sysctl_tcp_retrans_collapse != 0))
 		tcp_retrans_try_collapse(sk, skb, cur_mss);
 
@@ -1095,8 +1187,6 @@ int tcp_retransmit_skb(struct sock *sk, 
 	   tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
 			TCP_SKB_CB(skb)->seq = TCP_SKB_CB(skb)->end_seq - 1;
-			skb_shinfo(skb)->tso_segs = 1;
-			skb_shinfo(skb)->tso_size = 0;
 			skb->ip_summed = CHECKSUM_NONE;
 			skb->csum = 0;
 		}
@@ -1106,7 +1196,6 @@ int tcp_retransmit_skb(struct sock *sk, 
 	 * is still in somebody's hands, else make a clone.
 	 */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
-	tcp_tso_set_push(skb);
 
 	err = tcp_transmit_skb(sk, (skb_cloned(skb) ?
 				    pskb_copy(skb, GFP_ATOMIC):
@@ -1125,7 +1214,7 @@ int tcp_retransmit_skb(struct sock *sk, 
 		}
 #endif
 		TCP_SKB_CB(skb)->sacked |= TCPCB_RETRANS;
-		tp->retrans_out += tcp_skb_pcount(skb);
+		tp->retrans_out++;
 
 		/* Save stamp of the first retransmit. */
 		if (!tp->retrans_stamp)
@@ -1184,8 +1273,7 @@ void tcp_xmit_retransmit_queue(struct so
 						tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
 				}
 
-				packet_cnt -= tcp_skb_pcount(skb);
-				if (packet_cnt <= 0)
+				if (--packet_cnt <= 0)
 					break;
 			}
 		}
@@ -1254,7 +1342,7 @@ void tcp_send_fin(struct sock *sk)
 	 * unsent frames.  But be careful about outgoing SACKS
 	 * and IP options.
 	 */
-	mss_now = tcp_current_mss(sk, 1);
+	mss_now = tcp_current_mss(sk);
 
 	if (sk->sk_send_head != NULL) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
@@ -1510,7 +1598,7 @@ int tcp_connect(struct sock *sk)
 	skb_header_release(buff);
 	__skb_queue_tail(&sk->sk_write_queue, buff);
 	sk_charge_skb(sk, buff);
-	tp->packets_out += tcp_skb_pcount(buff);
+	tp->packets_out++;
 	tcp_transmit_skb(sk, skb_clone(buff, GFP_KERNEL));
 	TCP_INC_STATS(TCP_MIB_ACTIVEOPENS);
 
@@ -1655,7 +1743,7 @@ int tcp_write_wakeup(struct sock *sk)
 		if ((skb = sk->sk_send_head) != NULL &&
 		    before(TCP_SKB_CB(skb)->seq, tp->snd_una+tp->snd_wnd)) {
 			int err;
-			unsigned int mss = tcp_current_mss(sk, 0);
+			unsigned int mss = tcp_current_mss(sk);
 			unsigned int seg_size = tp->snd_una+tp->snd_wnd-TCP_SKB_CB(skb)->seq;
 
 			if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
@@ -1671,19 +1759,10 @@ int tcp_write_wakeup(struct sock *sk)
 				TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 				if (tcp_fragment(sk, skb, seg_size))
 					return -1;
-				/* SWS override triggered forced fragmentation.
-				 * Disable TSO, the connection is too sick. */
-				if (sk->sk_route_caps & NETIF_F_TSO) {
-					sock_set_flag(sk, SOCK_NO_LARGESEND);
-					sk->sk_route_caps &= ~NETIF_F_TSO;
-					tp->mss_cache = tp->mss_cache_std;
-				}
-			} else if (!tcp_skb_pcount(skb))
-				tcp_set_skb_tso_segs(sk, skb);
+			}
 
 			TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
-			tcp_tso_set_push(skb);
 			err = tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC));
 			if (!err) {
 				update_send_head(sk, tp, skb);
--- ./net/ipv4/tcp_input.c.~1~	2005-04-25 21:39:24.000000000 -0700
+++ ./net/ipv4/tcp_input.c	2005-05-04 22:42:23.000000000 -0700
@@ -805,10 +805,10 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp,
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
 
 	if (!cwnd) {
-		if (tp->mss_cache_std > 1460)
+		if (tp->mss_cache > 1460)
 			cwnd = 2;
 		else
-			cwnd = (tp->mss_cache_std > 1095) ? 3 : 4;
+			cwnd = (tp->mss_cache > 1095) ? 3 : 4;
 	}
 	return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
 }
@@ -974,14 +974,6 @@ tcp_sacktag_write_queue(struct sock *sk,
 	int flag = 0;
 	int i;
 
-	/* So, SACKs for already sent large segments will be lost.
-	 * Not good, but alternative is to resegment the queue. */
-	if (sk->sk_route_caps & NETIF_F_TSO) {
-		sk->sk_route_caps &= ~NETIF_F_TSO;
-		sock_set_flag(sk, SOCK_NO_LARGESEND);
-		tp->mss_cache = tp->mss_cache_std;
-	}
-
 	if (!tp->sacked_out)
 		tp->fackets_out = 0;
 	prior_fackets = tp->fackets_out;
@@ -1038,7 +1030,7 @@ tcp_sacktag_write_queue(struct sock *sk,
 			if(!before(TCP_SKB_CB(skb)->seq, end_seq))
 				break;
 
-			fack_count += tcp_skb_pcount(skb);
+			fack_count++;
 
 			in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 				!before(end_seq, TCP_SKB_CB(skb)->end_seq);
@@ -1082,8 +1074,8 @@ tcp_sacktag_write_queue(struct sock *sk,
 					 */
 					if (sacked & TCPCB_LOST) {
 						TCP_SKB_CB(skb)->sacked &= ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
-						tp->lost_out -= tcp_skb_pcount(skb);
-						tp->retrans_out -= tcp_skb_pcount(skb);
+						tp->lost_out--;
+						tp->retrans_out--;
 					}
 				} else {
 					/* New sack for not retransmitted frame,
@@ -1095,13 +1087,13 @@ tcp_sacktag_write_queue(struct sock *sk,
 
 					if (sacked & TCPCB_LOST) {
 						TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
-						tp->lost_out -= tcp_skb_pcount(skb);
+						tp->lost_out--;
 					}
 				}
 
 				TCP_SKB_CB(skb)->sacked |= TCPCB_SACKED_ACKED;
 				flag |= FLAG_DATA_SACKED;
-				tp->sacked_out += tcp_skb_pcount(skb);
+				tp->sacked_out++;
 
 				if (fack_count > tp->fackets_out)
 					tp->fackets_out = fack_count;
@@ -1118,7 +1110,7 @@ tcp_sacktag_write_queue(struct sock *sk,
 			if (dup_sack &&
 			    (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS)) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -= tcp_skb_pcount(skb);
+				tp->retrans_out--;
 			}
 		}
 	}
@@ -1142,12 +1134,12 @@ tcp_sacktag_write_queue(struct sock *sk,
 			    (IsFack(tp) ||
 			     !before(lost_retrans,
 				     TCP_SKB_CB(skb)->ack_seq + tp->reordering *
-				     tp->mss_cache_std))) {
+				     tp->mss_cache))) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -= tcp_skb_pcount(skb);
+				tp->retrans_out--;
 
 				if (!(TCP_SKB_CB(skb)->sacked&(TCPCB_LOST|TCPCB_SACKED_ACKED))) {
-					tp->lost_out += tcp_skb_pcount(skb);
+					tp->lost_out++;
 					TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 					flag |= FLAG_DATA_SACKED;
 					NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
@@ -1222,7 +1214,7 @@ static void tcp_enter_frto_loss(struct s
 	tp->fackets_out = 0;
 
 	sk_stream_for_retrans_queue(skb, sk) {
-		cnt += tcp_skb_pcount(skb);
+		cnt++;
 		TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
 
@@ -1232,10 +1224,10 @@ static void tcp_enter_frto_loss(struct s
 			if (!after(TCP_SKB_CB(skb)->end_seq,
 				   tp->frto_highmark)) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tp->lost_out += tcp_skb_pcount(skb);
+				tp->lost_out++;
 			}
 		} else {
-			tp->sacked_out += tcp_skb_pcount(skb);
+			tp->sacked_out++;
 			tp->fackets_out = cnt;
 		}
 	}
@@ -1297,16 +1289,16 @@ void tcp_enter_loss(struct sock *sk, int
 		tp->undo_marker = tp->snd_una;
 
 	sk_stream_for_retrans_queue(skb, sk) {
-		cnt += tcp_skb_pcount(skb);
+		cnt++;
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			tp->undo_marker = 0;
 		TCP_SKB_CB(skb)->sacked &= (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || how) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-			tp->lost_out += tcp_skb_pcount(skb);
+			tp->lost_out++;
 		} else {
-			tp->sacked_out += tcp_skb_pcount(skb);
+			tp->sacked_out++;
 			tp->fackets_out = cnt;
 		}
 	}
@@ -1542,12 +1534,12 @@ static void tcp_mark_head_lost(struct so
 	BUG_TRAP(cnt <= tp->packets_out);
 
 	sk_stream_for_retrans_queue(skb, sk) {
-		cnt -= tcp_skb_pcount(skb);
+		cnt--;
 		if (cnt < 0 || after(TCP_SKB_CB(skb)->end_seq, high_seq))
 			break;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-			tp->lost_out += tcp_skb_pcount(skb);
+			tp->lost_out++;
 		}
 	}
 	tcp_sync_left_out(tp);
@@ -1578,7 +1570,7 @@ static void tcp_update_scoreboard(struct
 			if (tcp_skb_timedout(tp, skb) &&
 			    !(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tp->lost_out += tcp_skb_pcount(skb);
+				tp->lost_out++;
 			}
 		}
 		tcp_sync_left_out(tp);
@@ -2170,7 +2162,7 @@ static void vegas_cong_avoid(struct tcp_
 		 * is the cwnd during the previous RTT.
 		 */
 		old_wnd = (tp->vegas.beg_snd_nxt - tp->vegas.beg_snd_una) /
-			tp->mss_cache_std;
+			tp->mss_cache;
 		old_snd_cwnd = tp->vegas.beg_snd_cwnd;
 
 		/* Save the extent of the current window so we can use this
@@ -2348,72 +2340,6 @@ static inline void tcp_ack_packets_out(s
 	}
 }
 
-/* There is one downside to this scheme.  Although we keep the
- * ACK clock ticking, adjusting packet counters and advancing
- * congestion window, we do not liberate socket send buffer
- * space.
- *
- * Mucking with skb->truesize and sk->sk_wmem_alloc et al.
- * then making a write space wakeup callback is a possible
- * future enhancement.  WARNING: it is not trivial to make.
- */
-static int tcp_tso_acked(struct sock *sk, struct sk_buff *skb,
-			 __u32 now, __s32 *seq_rtt)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
-	__u32 seq = tp->snd_una;
-	__u32 packets_acked;
-	int acked = 0;
-
-	/* If we get here, the whole TSO packet has not been
-	 * acked.
-	 */
-	BUG_ON(!after(scb->end_seq, seq));
-
-	packets_acked = tcp_skb_pcount(skb);
-	if (tcp_trim_head(sk, skb, seq - scb->seq))
-		return 0;
-	packets_acked -= tcp_skb_pcount(skb);
-
-	if (packets_acked) {
-		__u8 sacked = scb->sacked;
-
-		acked |= FLAG_DATA_ACKED;
-		if (sacked) {
-			if (sacked & TCPCB_RETRANS) {
-				if (sacked & TCPCB_SACKED_RETRANS)
-					tp->retrans_out -= packets_acked;
-				acked |= FLAG_RETRANS_DATA_ACKED;
-				*seq_rtt = -1;
-			} else if (*seq_rtt < 0)
-				*seq_rtt = now - scb->when;
-			if (sacked & TCPCB_SACKED_ACKED)
-				tp->sacked_out -= packets_acked;
-			if (sacked & TCPCB_LOST)
-				tp->lost_out -= packets_acked;
-			if (sacked & TCPCB_URG) {
-				if (tp->urg_mode &&
-				    !before(seq, tp->snd_up))
-					tp->urg_mode = 0;
-			}
-		} else if (*seq_rtt < 0)
-			*seq_rtt = now - scb->when;
-
-		if (tp->fackets_out) {
-			__u32 dval = min(tp->fackets_out, packets_acked);
-			tp->fackets_out -= dval;
-		}
-		tp->packets_out -= packets_acked;
-
-		BUG_ON(tcp_skb_pcount(skb) == 0);
-		BUG_ON(!before(scb->seq, scb->end_seq));
-	}
-
-	return acked;
-}
-
-
 /* Remove acknowledged frames from the retransmission queue. */
 static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 {
@@ -2432,12 +2358,8 @@ static int tcp_clean_rtx_queue(struct so
 		 * discard it as it's confirmed to have arrived at
 		 * the other end.
 		 */
-		if (after(scb->end_seq, tp->snd_una)) {
-			if (tcp_skb_pcount(skb) > 1)
-				acked |= tcp_tso_acked(sk, skb,
-						       now, &seq_rtt);
+		if (after(scb->end_seq, tp->snd_una))
 			break;
-		}
 
 		/* Initial outgoing SYN's get put onto the write_queue
 		 * just like anything else we transmit.  It is not
@@ -2456,15 +2378,15 @@ static int tcp_clean_rtx_queue(struct so
 		if (sacked) {
 			if (sacked & TCPCB_RETRANS) {
 				if(sacked & TCPCB_SACKED_RETRANS)
-					tp->retrans_out -= tcp_skb_pcount(skb);
+					tp->retrans_out--;
 				acked |= FLAG_RETRANS_DATA_ACKED;
 				seq_rtt = -1;
 			} else if (seq_rtt < 0)
 				seq_rtt = now - scb->when;
 			if (sacked & TCPCB_SACKED_ACKED)
-				tp->sacked_out -= tcp_skb_pcount(skb);
+				tp->sacked_out--;
 			if (sacked & TCPCB_LOST)
-				tp->lost_out -= tcp_skb_pcount(skb);
+				tp->lost_out--;
 			if (sacked & TCPCB_URG) {
 				if (tp->urg_mode &&
 				    !before(scb->end_seq, tp->snd_up))
@@ -2472,8 +2394,9 @@ static int tcp_clean_rtx_queue(struct so
 			}
 		} else if (seq_rtt < 0)
 			seq_rtt = now - scb->when;
-		tcp_dec_pcount_approx(&tp->fackets_out, skb);
-		tcp_packets_out_dec(tp, skb);
+		if (tp->fackets_out)
+			tp->fackets_out--;
+		tcp_packets_out_dec(tp);
 		__skb_unlink(skb, skb->list);
 		sk_stream_free_skb(sk, skb);
 	}
@@ -2799,19 +2722,19 @@ static void westwood_dupack_update(struc
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	tp->westwood.accounted += tp->mss_cache_std;
-	tp->westwood.cumul_ack = tp->mss_cache_std;
+	tp->westwood.accounted += tp->mss_cache;
+	tp->westwood.cumul_ack = tp->mss_cache;
 }
 
 static inline int westwood_may_change_cumul(struct tcp_sock *tp)
 {
-	return (tp->westwood.cumul_ack > tp->mss_cache_std);
+	return (tp->westwood.cumul_ack > tp->mss_cache);
 }
 
 static inline void westwood_partial_update(struct tcp_sock *tp)
 {
 	tp->westwood.accounted -= tp->westwood.cumul_ack;
-	tp->westwood.cumul_ack = tp->mss_cache_std;
+	tp->westwood.cumul_ack = tp->mss_cache;
 }
 
 static inline void westwood_complete_update(struct tcp_sock *tp)
@@ -3952,7 +3875,7 @@ static void tcp_new_space(struct sock *s
 	    !(sk->sk_userlocks & SOCK_SNDBUF_LOCK) &&
 	    !tcp_memory_pressure &&
 	    atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
- 		int sndmem = max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache_std) +
+ 		int sndmem = max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
 			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff),
 		    demanded = max_t(unsigned int, tp->snd_cwnd,
 						   tp->reordering + 1);
--- ./net/ipv4/tcp.c.~1~	2005-04-20 10:18:18.000000000 -0700
+++ ./net/ipv4/tcp.c	2005-05-04 22:23:45.000000000 -0700
@@ -646,7 +646,7 @@ static ssize_t do_tcp_sendpages(struct s
 
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
-	mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
+	mss_now = tcp_current_mss(sk);
 	copied = 0;
 
 	err = -EPIPE;
@@ -702,7 +702,8 @@ new_segment:
 		skb->ip_summed = CHECKSUM_HW;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
-		skb_shinfo(skb)->tso_segs = 0;
+		skb_shinfo(skb)->tso_segs = 1;
+		skb_shinfo(skb)->tso_size = 0;
 
 		if (!copied)
 			TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_PSH;
@@ -718,8 +719,15 @@ new_segment:
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
 			__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
-		} else if (skb == sk->sk_send_head)
-			tcp_push_one(sk, mss_now);
+		} else if (skb == sk->sk_send_head) {
+			/* If we can potentially do TSO, it is better to queue
+			 * things up and accumulate then to push the frame right
+			 * now.
+			 */
+			if (!(sk->sk_route_caps & NETIF_F_TSO) ||
+			    tp->urg_mode)
+				tcp_push_one(sk, mss_now);
+		}
 		continue;
 
 wait_for_sndbuf:
@@ -731,7 +739,7 @@ wait_for_memory:
 		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 			goto do_error;
 
-		mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
+		mss_now = tcp_current_mss(sk);
 	}
 
 out:
@@ -773,15 +781,11 @@ ssize_t tcp_sendpage(struct socket *sock
 
 static inline int select_size(struct sock *sk, struct tcp_sock *tp)
 {
-	int tmp = tp->mss_cache_std;
+	int tmp = tp->mss_cache;
 
-	if (sk->sk_route_caps & NETIF_F_SG) {
-		int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
+	if (sk->sk_route_caps & NETIF_F_SG)
+		tmp = 0;
 
-		if (tmp >= pgbreak &&
-		    tmp <= pgbreak + (MAX_SKB_FRAGS - 1) * PAGE_SIZE)
-			tmp = pgbreak;
-	}
 	return tmp;
 }
 
@@ -810,7 +814,7 @@ int tcp_sendmsg(struct kiocb *iocb, stru
 	/* This should be in poll */
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
-	mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
+	mss_now = tcp_current_mss(sk);
 
 	/* Ok commence sending. */
 	iovlen = msg->msg_iovlen;
@@ -949,7 +953,8 @@ new_segment:
 
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
-			skb_shinfo(skb)->tso_segs = 0;
+			skb_shinfo(skb)->tso_segs = 1;
+			skb_shinfo(skb)->tso_size = 0;
 
 			from += copy;
 			copied += copy;
@@ -962,8 +967,15 @@ new_segment:
 			if (forced_push(tp)) {
 				tcp_mark_push(tp, skb);
 				__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
-			} else if (skb == sk->sk_send_head)
-				tcp_push_one(sk, mss_now);
+			} else if (skb == sk->sk_send_head) {
+				/* If we can potentially do TSO, it is better to queue
+				 * things up and accumulate then to push the frame right
+				 * now.
+				 */
+				if (!(sk->sk_route_caps & NETIF_F_TSO) ||
+				    tp->urg_mode)
+					tcp_push_one(sk, mss_now);
+			}
 			continue;
 
 wait_for_sndbuf:
@@ -975,7 +987,7 @@ wait_for_memory:
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 				goto do_error;
 
-			mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
+			mss_now = tcp_current_mss(sk);
 		}
 	}
 
@@ -2135,7 +2147,7 @@ void tcp_get_info(struct sock *sk, struc
 
 	info->tcpi_rto = jiffies_to_usecs(tp->rto);
 	info->tcpi_ato = jiffies_to_usecs(tp->ack.ato);
-	info->tcpi_snd_mss = tp->mss_cache_std;
+	info->tcpi_snd_mss = tp->mss_cache;
 	info->tcpi_rcv_mss = tp->ack.rcv_mss;
 
 	info->tcpi_unacked = tp->packets_out;
@@ -2185,7 +2197,7 @@ int tcp_getsockopt(struct sock *sk, int 
 
 	switch (optname) {
 	case TCP_MAXSEG:
-		val = tp->mss_cache_std;
+		val = tp->mss_cache;
 		if (!val && ((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN)))
 			val = tp->rx_opt.user_mss;
 		break;
--- ./net/ipv4/tcp_ipv4.c.~1~	2005-05-03 14:36:08.000000000 -0700
+++ ./net/ipv4/tcp_ipv4.c	2005-05-04 15:17:16.000000000 -0700
@@ -2060,7 +2060,7 @@ static int tcp_v4_init_sock(struct sock 
 	 */
 	tp->snd_ssthresh = 0x7fffffff;	/* Infinity */
 	tp->snd_cwnd_clamp = ~0;
-	tp->mss_cache_std = tp->mss_cache = 536;
+	tp->mss_cache = 536;
 
 	tp->reordering = sysctl_tcp_reordering;
 
--- ./net/ipv6/tcp_ipv6.c.~1~	2005-05-03 14:36:44.000000000 -0700
+++ ./net/ipv6/tcp_ipv6.c	2005-05-04 15:17:09.000000000 -0700
@@ -2021,7 +2021,7 @@ static int tcp_v6_init_sock(struct sock 
 	 */
 	tp->snd_ssthresh = 0x7fffffff;
 	tp->snd_cwnd_clamp = ~0;
-	tp->mss_cache_std = tp->mss_cache = 536;
+	tp->mss_cache = 536;
 
 	tp->reordering = sysctl_tcp_reordering;
 
