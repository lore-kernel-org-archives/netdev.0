From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Remove tcp_pcount_t
Date: Mon, 17 Jan 2005 21:10:58 +1100
Message-ID: <20050117101058.GA27521@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

IMHO the TSO stuff has mostly settled down now.  As a result
tcp_pcount_t is now more of a liability in that it reduces the
readability of the code.

So here is a patch to remove it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/tcp.h 1.33 vs edited =====
--- 1.33/include/linux/tcp.h	2004-12-29 05:22:40 +11:00
+++ edited/include/linux/tcp.h	2005-01-17 20:42:09 +11:00
@@ -203,10 +203,6 @@
 	__u32	end_seq;
 };
 
-typedef struct tcp_pcount {
-	__u32	val;
-} tcp_pcount_t;
-
 enum tcp_congestion_algo {
 	TCP_RENO=0,
 	TCP_VEGAS,
@@ -289,9 +285,9 @@
 	__u32	rtt_seq;	/* sequence number to update rttvar	*/
 	__u32	rto;		/* retransmit timeout			*/
 
-	tcp_pcount_t packets_out; /* Packets which are "in flight"	*/
-	tcp_pcount_t left_out;	  /* Packets which leaved network	*/
-	tcp_pcount_t retrans_out; /* Retransmitted packets out		*/
+	__u32	packets_out;	/* Packets which are "in flight"	*/
+	__u32	left_out;	/* Packets which leaved network	*/
+	__u32	retrans_out;	/* Retransmitted packets out		*/
 
 
 /*
@@ -352,9 +348,9 @@
 	__u8	syn_retries;	/* num of allowed syn retries */
 	__u8	ecn_flags;	/* ECN status bits.			*/
 	__u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
-	tcp_pcount_t lost_out;	/* Lost packets			*/
-	tcp_pcount_t sacked_out;/* SACK'd packets			*/
-	tcp_pcount_t fackets_out;/* FACK'd packets			*/
+	__u32	lost_out;	/* Lost packets			*/
+	__u32	sacked_out;	/* SACK'd packets			*/
+	__u32	fackets_out;	/* FACK'd packets			*/
 	__u32	high_seq;	/* snd_nxt at onset of congestion	*/
 
 	__u32	retrans_stamp;	/* Timestamp of the last retransmit,
===== include/net/tcp.h 1.102 vs edited =====
--- 1.102/include/net/tcp.h	2005-01-07 10:13:39 +11:00
+++ edited/include/net/tcp.h	2005-01-17 20:45:40 +11:00
@@ -1176,55 +1176,23 @@
 	return skb_shinfo(skb)->tso_size;
 }
 
-static inline void tcp_inc_pcount(tcp_pcount_t *count,
-				  const struct sk_buff *skb)
-{
-	count->val += tcp_skb_pcount(skb);
-}
-
-static inline void tcp_inc_pcount_explicit(tcp_pcount_t *count, int amt)
-{
-	count->val += amt;
-}
-
-static inline void tcp_dec_pcount_explicit(tcp_pcount_t *count, int amt)
-{
-	count->val -= amt;
-}
-
-static inline void tcp_dec_pcount(tcp_pcount_t *count, 
-				  const struct sk_buff *skb)
-{
-	count->val -= tcp_skb_pcount(skb);
-}
-
-static inline void tcp_dec_pcount_approx(tcp_pcount_t *count,
+static inline void tcp_dec_pcount_approx(__u32 *count,
 					 const struct sk_buff *skb)
 {
-	if (count->val) {
-		count->val -= tcp_skb_pcount(skb);
-		if ((int)count->val < 0)
-			count->val = 0;
+	if (*count) {
+		*count -= tcp_skb_pcount(skb);
+		if ((int)*count < 0)
+			*count = 0;
 	}
 }
 
-static inline __u32 tcp_get_pcount(const tcp_pcount_t *count)
-{
-	return count->val;
-}
-
-static inline void tcp_set_pcount(tcp_pcount_t *count, __u32 val)
-{
-	count->val = val;
-}
-
 static inline void tcp_packets_out_inc(struct sock *sk, 
 				       struct tcp_sock *tp,
 				       const struct sk_buff *skb)
 {
-	int orig = tcp_get_pcount(&tp->packets_out);
+	int orig = tp->packets_out;
 
-	tcp_inc_pcount(&tp->packets_out, skb);
+	tp->packets_out += tcp_skb_pcount(skb);
 	if (!orig)
 		tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
 }
@@ -1232,7 +1200,7 @@
 static inline void tcp_packets_out_dec(struct tcp_sock *tp, 
 				       const struct sk_buff *skb)
 {
-	tcp_dec_pcount(&tp->packets_out, skb);
+	tp->packets_out -= tcp_skb_pcount(skb);
 }
 
 /* This determines how many packets are "in the network" to the best
@@ -1251,9 +1219,7 @@
  */
 static __inline__ unsigned int tcp_packets_in_flight(const struct tcp_sock *tp)
 {
-	return (tcp_get_pcount(&tp->packets_out) -
-		tcp_get_pcount(&tp->left_out) +
-		tcp_get_pcount(&tp->retrans_out));
+	return (tp->packets_out - tp->left_out + tp->retrans_out);
 }
 
 /*
@@ -1357,14 +1323,9 @@
 static inline void tcp_sync_left_out(struct tcp_sock *tp)
 {
 	if (tp->sack_ok &&
-	    (tcp_get_pcount(&tp->sacked_out) >=
-	     tcp_get_pcount(&tp->packets_out) - tcp_get_pcount(&tp->lost_out)))
-		tcp_set_pcount(&tp->sacked_out,
-			       (tcp_get_pcount(&tp->packets_out) -
-				tcp_get_pcount(&tp->lost_out)));
-	tcp_set_pcount(&tp->left_out,
-		       (tcp_get_pcount(&tp->sacked_out) +
-			tcp_get_pcount(&tp->lost_out)));
+	    (tp->sacked_out >= tp->packets_out - tp->lost_out))
+		tp->sacked_out = tp->packets_out - tp->lost_out;
+	tp->left_out = tp->sacked_out + tp->lost_out;
 }
 
 extern void tcp_cwnd_application_limited(struct sock *sk);
@@ -1373,7 +1334,7 @@
 
 static inline void tcp_cwnd_validate(struct sock *sk, struct tcp_sock *tp)
 {
-	__u32 packets_out = tcp_get_pcount(&tp->packets_out);
+	__u32 packets_out = tp->packets_out;
 
 	if (packets_out >= tp->snd_cwnd) {
 		/* Network is feed fully. */
@@ -1381,8 +1342,8 @@
 		tp->snd_cwnd_stamp = tcp_time_stamp;
 	} else {
 		/* Network starves. */
-		if (tcp_get_pcount(&tp->packets_out) > tp->snd_cwnd_used)
-			tp->snd_cwnd_used = tcp_get_pcount(&tp->packets_out);
+		if (tp->packets_out > tp->snd_cwnd_used)
+			tp->snd_cwnd_used = tp->packets_out;
 
 		if ((s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= tp->rto)
 			tcp_cwnd_application_limited(sk);
@@ -1450,7 +1411,7 @@
 		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
 		((nonagle&TCP_NAGLE_CORK) ||
 		 (!nonagle &&
-		  tcp_get_pcount(&tp->packets_out) &&
+		  tp->packets_out &&
 		  tcp_minshall_check(tp))));
 }
 
@@ -1503,7 +1464,7 @@
 
 static __inline__ void tcp_check_probe_timer(struct sock *sk, struct tcp_sock *tp)
 {
-	if (!tcp_get_pcount(&tp->packets_out) && !tp->pending)
+	if (!tp->packets_out && !tp->pending)
 		tcp_reset_xmit_timer(sk, TCP_TIME_PROBE0, tp->rto);
 }
 
===== net/ipv4/tcp.c 1.90 vs edited =====
--- 1.90/net/ipv4/tcp.c	2005-01-15 15:37:59 +11:00
+++ edited/net/ipv4/tcp.c	2005-01-17 20:42:08 +11:00
@@ -1822,7 +1822,7 @@
 	tp->backoff = 0;
 	tp->snd_cwnd = 2;
 	tp->probes_out = 0;
-	tcp_set_pcount(&tp->packets_out, 0);
+	tp->packets_out = 0;
 	tp->snd_ssthresh = 0x7fffffff;
 	tp->snd_cwnd_cnt = 0;
 	tcp_set_ca_state(tp, TCP_CA_Open);
@@ -2137,11 +2137,11 @@
 	info->tcpi_snd_mss = tp->mss_cache_std;
 	info->tcpi_rcv_mss = tp->ack.rcv_mss;
 
-	info->tcpi_unacked = tcp_get_pcount(&tp->packets_out);
-	info->tcpi_sacked = tcp_get_pcount(&tp->sacked_out);
-	info->tcpi_lost = tcp_get_pcount(&tp->lost_out);
-	info->tcpi_retrans = tcp_get_pcount(&tp->retrans_out);
-	info->tcpi_fackets = tcp_get_pcount(&tp->fackets_out);
+	info->tcpi_unacked = tp->packets_out;
+	info->tcpi_sacked = tp->sacked_out;
+	info->tcpi_lost = tp->lost_out;
+	info->tcpi_retrans = tp->retrans_out;
+	info->tcpi_fackets = tp->fackets_out;
 
 	info->tcpi_last_data_sent = jiffies_to_msecs(now - tp->lsndtime);
 	info->tcpi_last_data_recv = jiffies_to_msecs(now - tp->ack.lrcvtime);
===== net/ipv4/tcp_input.c 1.88 vs edited =====
--- 1.88/net/ipv4/tcp_input.c	2005-01-07 10:13:39 +11:00
+++ edited/net/ipv4/tcp_input.c	2005-01-17 20:42:08 +11:00
@@ -902,8 +902,8 @@
 		printk(KERN_DEBUG "Disorder%d %d %u f%u s%u rr%d\n",
 		       tp->sack_ok, tp->ca_state,
 		       tp->reordering,
-		       tcp_get_pcount(&tp->fackets_out),
-		       tcp_get_pcount(&tp->sacked_out),
+		       tp->fackets_out,
+		       tp->sacked_out,
 		       tp->undo_marker ? tp->undo_retrans : 0);
 #endif
 		/* Disable FACK yet. */
@@ -966,7 +966,7 @@
 	unsigned char *ptr = ack_skb->h.raw + TCP_SKB_CB(ack_skb)->sacked;
 	struct tcp_sack_block *sp = (struct tcp_sack_block *)(ptr+2);
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
-	int reord = tcp_get_pcount(&tp->packets_out);
+	int reord = tp->packets_out;
 	int prior_fackets;
 	u32 lost_retrans = 0;
 	int flag = 0;
@@ -980,9 +980,9 @@
 		tp->mss_cache = tp->mss_cache_std;
 	}
 
-	if (!tcp_get_pcount(&tp->sacked_out))
-		tcp_set_pcount(&tp->fackets_out, 0);
-	prior_fackets = tcp_get_pcount(&tp->fackets_out);
+	if (!tp->sacked_out)
+		tp->fackets_out = 0;
+	prior_fackets = tp->fackets_out;
 
 	for (i=0; i<num_sacks; i++, sp++) {
 		struct sk_buff *skb;
@@ -1080,8 +1080,8 @@
 					 */
 					if (sacked & TCPCB_LOST) {
 						TCP_SKB_CB(skb)->sacked &= ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
-						tcp_dec_pcount(&tp->lost_out, skb);
-						tcp_dec_pcount(&tp->retrans_out, skb);
+						tp->lost_out -= tcp_skb_pcount(skb);
+						tp->retrans_out -= tcp_skb_pcount(skb);
 					}
 				} else {
 					/* New sack for not retransmitted frame,
@@ -1093,16 +1093,16 @@
 
 					if (sacked & TCPCB_LOST) {
 						TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
-						tcp_dec_pcount(&tp->lost_out, skb);
+						tp->lost_out -= tcp_skb_pcount(skb);
 					}
 				}
 
 				TCP_SKB_CB(skb)->sacked |= TCPCB_SACKED_ACKED;
 				flag |= FLAG_DATA_SACKED;
-				tcp_inc_pcount(&tp->sacked_out, skb);
+				tp->sacked_out += tcp_skb_pcount(skb);
 
-				if (fack_count > tcp_get_pcount(&tp->fackets_out))
-					tcp_set_pcount(&tp->fackets_out, fack_count);
+				if (fack_count > tp->fackets_out)
+					tp->fackets_out = fack_count;
 			} else {
 				if (dup_sack && (sacked&TCPCB_RETRANS))
 					reord = min(fack_count, reord);
@@ -1116,7 +1116,7 @@
 			if (dup_sack &&
 			    (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS)) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tcp_dec_pcount(&tp->retrans_out, skb);
+				tp->retrans_out -= tcp_skb_pcount(skb);
 			}
 		}
 	}
@@ -1142,10 +1142,10 @@
 				     TCP_SKB_CB(skb)->ack_seq + tp->reordering *
 				     tp->mss_cache_std))) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tcp_dec_pcount(&tp->retrans_out, skb);
+				tp->retrans_out -= tcp_skb_pcount(skb);
 
 				if (!(TCP_SKB_CB(skb)->sacked&(TCPCB_LOST|TCPCB_SACKED_ACKED))) {
-					tcp_inc_pcount(&tp->lost_out, skb);
+					tp->lost_out += tcp_skb_pcount(skb);
 					TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 					flag |= FLAG_DATA_SACKED;
 					NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
@@ -1154,20 +1154,15 @@
 		}
 	}
 
-	tcp_set_pcount(&tp->left_out,
-		       (tcp_get_pcount(&tp->sacked_out) +
-			tcp_get_pcount(&tp->lost_out)));
-
-	if ((reord < tcp_get_pcount(&tp->fackets_out)) &&
-	    tp->ca_state != TCP_CA_Loss)
-		tcp_update_reordering(tp,
-				      ((tcp_get_pcount(&tp->fackets_out) + 1) -
-				       reord), 0);
+	tp->left_out = tp->sacked_out + tp->lost_out;
+
+	if ((reord < tp->fackets_out) && tp->ca_state != TCP_CA_Loss)
+		tcp_update_reordering(tp, ((tp->fackets_out + 1) - reord), 0);
 
 #if FASTRETRANS_DEBUG > 0
-	BUG_TRAP((int)tcp_get_pcount(&tp->sacked_out) >= 0);
-	BUG_TRAP((int)tcp_get_pcount(&tp->lost_out) >= 0);
-	BUG_TRAP((int)tcp_get_pcount(&tp->retrans_out) >= 0);
+	BUG_TRAP((int)tp->sacked_out >= 0);
+	BUG_TRAP((int)tp->lost_out >= 0);
+	BUG_TRAP((int)tp->retrans_out >= 0);
 	BUG_TRAP((int)tcp_packets_in_flight(tp) >= 0);
 #endif
 	return flag;
@@ -1197,7 +1192,7 @@
 	 * If something was really lost, it is eventually caught up
 	 * in tcp_enter_frto_loss.
 	 */
-	tcp_set_pcount(&tp->retrans_out, 0);
+	tp->retrans_out = 0;
 	tp->undo_marker = tp->snd_una;
 	tp->undo_retrans = 0;
 
@@ -1220,9 +1215,9 @@
 	struct sk_buff *skb;
 	int cnt = 0;
 
-	tcp_set_pcount(&tp->sacked_out, 0);
-	tcp_set_pcount(&tp->lost_out, 0);
-	tcp_set_pcount(&tp->fackets_out, 0);
+	tp->sacked_out = 0;
+	tp->lost_out = 0;
+	tp->fackets_out = 0;
 
 	sk_stream_for_retrans_queue(skb, sk) {
 		cnt += tcp_skb_pcount(skb);
@@ -1235,11 +1230,11 @@
 			if (!after(TCP_SKB_CB(skb)->end_seq,
 				   tp->frto_highmark)) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tcp_inc_pcount(&tp->lost_out, skb);
+				tp->lost_out += tcp_skb_pcount(skb);
 			}
 		} else {
-			tcp_inc_pcount(&tp->sacked_out, skb);
-			tcp_set_pcount(&tp->fackets_out, cnt);
+			tp->sacked_out += tcp_skb_pcount(skb);
+			tp->fackets_out = cnt;
 		}
 	}
 	tcp_sync_left_out(tp);
@@ -1261,12 +1256,12 @@
 
 void tcp_clear_retrans(struct tcp_sock *tp)
 {
-	tcp_set_pcount(&tp->left_out, 0);
-	tcp_set_pcount(&tp->retrans_out, 0);
+	tp->left_out = 0;
+	tp->retrans_out = 0;
 
-	tcp_set_pcount(&tp->fackets_out, 0);
-	tcp_set_pcount(&tp->sacked_out, 0);
-	tcp_set_pcount(&tp->lost_out, 0);
+	tp->fackets_out = 0;
+	tp->sacked_out = 0;
+	tp->lost_out = 0;
 
 	tp->undo_marker = 0;
 	tp->undo_retrans = 0;
@@ -1307,10 +1302,10 @@
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || how) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-			tcp_inc_pcount(&tp->lost_out, skb);
+			tp->lost_out += tcp_skb_pcount(skb);
 		} else {
-			tcp_inc_pcount(&tp->sacked_out, skb);
-			tcp_set_pcount(&tp->fackets_out, cnt);
+			tp->sacked_out += tcp_skb_pcount(skb);
+			tp->fackets_out = cnt;
 		}
 	}
 	tcp_sync_left_out(tp);
@@ -1347,8 +1342,7 @@
 
 static inline int tcp_fackets_out(struct tcp_sock *tp)
 {
-	return IsReno(tp) ? tcp_get_pcount(&tp->sacked_out)+1 :
-		tcp_get_pcount(&tp->fackets_out);
+	return IsReno(tp) ? tp->sacked_out+1 : tp->fackets_out;
 }
 
 static inline int tcp_skb_timedout(struct tcp_sock *tp, struct sk_buff *skb)
@@ -1358,7 +1352,7 @@
 
 static inline int tcp_head_timedout(struct sock *sk, struct tcp_sock *tp)
 {
-	return tcp_get_pcount(&tp->packets_out) &&
+	return tp->packets_out &&
 	       tcp_skb_timedout(tp, skb_peek(&sk->sk_write_queue));
 }
 
@@ -1460,7 +1454,7 @@
 	__u32 packets_out;
 
 	/* Trick#1: The loss is proven. */
-	if (tcp_get_pcount(&tp->lost_out))
+	if (tp->lost_out)
 		return 1;
 
 	/* Not-A-Trick#2 : Classic rule... */
@@ -1476,9 +1470,9 @@
 	/* Trick#4: It is still not OK... But will it be useful to delay
 	 * recovery more?
 	 */
-	packets_out = tcp_get_pcount(&tp->packets_out);
+	packets_out = tp->packets_out;
 	if (packets_out <= tp->reordering &&
-	    tcp_get_pcount(&tp->sacked_out) >= max_t(__u32, packets_out/2, sysctl_tcp_reordering) &&
+	    tp->sacked_out >= max_t(__u32, packets_out/2, sysctl_tcp_reordering) &&
 	    !tcp_may_send_now(sk, tp)) {
 		/* We have nothing to send. This connection is limited
 		 * either by receiver window or by application.
@@ -1497,16 +1491,12 @@
 {
 	u32 holes;
 
-	holes = max(tcp_get_pcount(&tp->lost_out), 1U);
-	holes = min(holes, tcp_get_pcount(&tp->packets_out));
+	holes = max(tp->lost_out, 1U);
+	holes = min(holes, tp->packets_out);
 
-	if ((tcp_get_pcount(&tp->sacked_out) + holes) >
-	    tcp_get_pcount(&tp->packets_out)) {
-		tcp_set_pcount(&tp->sacked_out,
-			       (tcp_get_pcount(&tp->packets_out) - holes));
-		tcp_update_reordering(tp,
-				      tcp_get_pcount(&tp->packets_out)+addend,
-				      0);
+	if ((tp->sacked_out + holes) > tp->packets_out) {
+		tp->sacked_out = tp->packets_out - holes;
+		tcp_update_reordering(tp, tp->packets_out+addend, 0);
 	}
 }
 
@@ -1514,7 +1504,7 @@
 
 static void tcp_add_reno_sack(struct tcp_sock *tp)
 {
-	tcp_inc_pcount_explicit(&tp->sacked_out, 1);
+	tp->sacked_out++;
 	tcp_check_reno_reordering(tp, 0);
 	tcp_sync_left_out(tp);
 }
@@ -1525,10 +1515,10 @@
 {
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
-		if (acked-1 >= tcp_get_pcount(&tp->sacked_out))
-			tcp_set_pcount(&tp->sacked_out, 0);
+		if (acked-1 >= tp->sacked_out)
+			tp->sacked_out = 0;
 		else
-			tcp_dec_pcount_explicit(&tp->sacked_out, acked-1);
+			tp->sacked_out -= acked-1;
 	}
 	tcp_check_reno_reordering(tp, acked);
 	tcp_sync_left_out(tp);
@@ -1536,8 +1526,8 @@
 
 static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
 {
-	tcp_set_pcount(&tp->sacked_out, 0);
-	tcp_set_pcount(&tp->left_out, tcp_get_pcount(&tp->lost_out));
+	tp->sacked_out = 0;
+	tp->left_out = tp->lost_out;
 }
 
 /* Mark head of queue up as lost. */
@@ -1547,7 +1537,7 @@
 	struct sk_buff *skb;
 	int cnt = packets;
 
-	BUG_TRAP(cnt <= tcp_get_pcount(&tp->packets_out));
+	BUG_TRAP(cnt <= tp->packets_out);
 
 	sk_stream_for_retrans_queue(skb, sk) {
 		cnt -= tcp_skb_pcount(skb);
@@ -1555,7 +1545,7 @@
 			break;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-			tcp_inc_pcount(&tp->lost_out, skb);
+			tp->lost_out += tcp_skb_pcount(skb);
 		}
 	}
 	tcp_sync_left_out(tp);
@@ -1566,7 +1556,7 @@
 static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp)
 {
 	if (IsFack(tp)) {
-		int lost = tcp_get_pcount(&tp->fackets_out) - tp->reordering;
+		int lost = tp->fackets_out - tp->reordering;
 		if (lost <= 0)
 			lost = 1;
 		tcp_mark_head_lost(sk, tp, lost, tp->high_seq);
@@ -1586,7 +1576,7 @@
 			if (tcp_skb_timedout(tp, skb) &&
 			    !(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tcp_inc_pcount(&tp->lost_out, skb);
+				tp->lost_out += tcp_skb_pcount(skb);
 			}
 		}
 		tcp_sync_left_out(tp);
@@ -1651,9 +1641,9 @@
 	printk(KERN_DEBUG "Undo %s %u.%u.%u.%u/%u c%u l%u ss%u/%u p%u\n",
 	       msg,
 	       NIPQUAD(inet->daddr), ntohs(inet->dport),
-	       tp->snd_cwnd, tcp_get_pcount(&tp->left_out),
+	       tp->snd_cwnd, tp->left_out,
 	       tp->snd_ssthresh, tp->prior_ssthresh,
-	       tcp_get_pcount(&tp->packets_out));
+	       tp->packets_out);
 }
 #else
 #define DBGUNDO(x...) do { } while (0)
@@ -1724,13 +1714,13 @@
 				int acked)
 {
 	/* Partial ACK arrived. Force Hoe's retransmit. */
-	int failed = IsReno(tp) || tcp_get_pcount(&tp->fackets_out)>tp->reordering;
+	int failed = IsReno(tp) || tp->fackets_out>tp->reordering;
 
 	if (tcp_may_undo(tp)) {
 		/* Plain luck! Hole if filled with delayed
 		 * packet, rather than with a retransmit.
 		 */
-		if (tcp_get_pcount(&tp->retrans_out) == 0)
+		if (tp->retrans_out == 0)
 			tp->retrans_stamp = 0;
 
 		tcp_update_reordering(tp, tcp_fackets_out(tp)+acked, 1);
@@ -1757,8 +1747,8 @@
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
 		}
 		DBGUNDO(sk, tp, "partial loss");
-		tcp_set_pcount(&tp->lost_out, 0);
-		tcp_set_pcount(&tp->left_out, tcp_get_pcount(&tp->sacked_out));
+		tp->lost_out = 0;
+		tp->left_out = tp->sacked_out;
 		tcp_undo_cwr(tp, 1);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSSUNDO);
 		tp->retransmits = 0;
@@ -1781,9 +1771,9 @@
 
 static void tcp_try_to_open(struct sock *sk, struct tcp_sock *tp, int flag)
 {
-	tcp_set_pcount(&tp->left_out, tcp_get_pcount(&tp->sacked_out));
+	tp->left_out = tp->sacked_out;
 
-	if (tcp_get_pcount(&tp->retrans_out) == 0)
+	if (tp->retrans_out == 0)
 		tp->retrans_stamp = 0;
 
 	if (flag&FLAG_ECE)
@@ -1792,9 +1782,7 @@
 	if (tp->ca_state != TCP_CA_CWR) {
 		int state = TCP_CA_Open;
 
-		if (tcp_get_pcount(&tp->left_out) ||
-		    tcp_get_pcount(&tp->retrans_out) ||
-		    tp->undo_marker)
+		if (tp->left_out || tp->retrans_out || tp->undo_marker)
 			state = TCP_CA_Disorder;
 
 		if (tp->ca_state != state) {
@@ -1827,11 +1815,11 @@
 
 	/* Some technical things:
 	 * 1. Reno does not count dupacks (sacked_out) automatically. */
-	if (!tcp_get_pcount(&tp->packets_out))
-		tcp_set_pcount(&tp->sacked_out, 0);
+	if (!tp->packets_out)
+		tp->sacked_out = 0;
         /* 2. SACK counts snd_fack in packets inaccurately. */
-	if (tcp_get_pcount(&tp->sacked_out) == 0)
-		tcp_set_pcount(&tp->fackets_out, 0);
+	if (tp->sacked_out == 0)
+		tp->fackets_out = 0;
 
         /* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
@@ -1839,15 +1827,15 @@
 		tp->prior_ssthresh = 0;
 
 	/* B. In all the states check for reneging SACKs. */
-	if (tcp_get_pcount(&tp->sacked_out) && tcp_check_sack_reneging(sk, tp))
+	if (tp->sacked_out && tcp_check_sack_reneging(sk, tp))
 		return;
 
 	/* C. Process data loss notification, provided it is valid. */
 	if ((flag&FLAG_DATA_LOST) &&
 	    before(tp->snd_una, tp->high_seq) &&
 	    tp->ca_state != TCP_CA_Open &&
-	    tcp_get_pcount(&tp->fackets_out) > tp->reordering) {
-		tcp_mark_head_lost(sk, tp, tcp_get_pcount(&tp->fackets_out)-tp->reordering, tp->high_seq);
+	    tp->fackets_out > tp->reordering) {
+		tcp_mark_head_lost(sk, tp, tp->fackets_out-tp->reordering, tp->high_seq);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
 
@@ -1858,7 +1846,7 @@
 	 *    when high_seq is ACKed. */
 	if (tp->ca_state == TCP_CA_Open) {
 		if (!sysctl_tcp_frto)
-			BUG_TRAP(tcp_get_pcount(&tp->retrans_out) == 0);
+			BUG_TRAP(tp->retrans_out == 0);
 		tp->retrans_stamp = 0;
 	} else if (!before(tp->snd_una, tp->high_seq)) {
 		switch (tp->ca_state) {
@@ -1905,8 +1893,7 @@
 			if (IsReno(tp) && is_dupack)
 				tcp_add_reno_sack(tp);
 		} else {
-			int acked = prior_packets -
-				tcp_get_pcount(&tp->packets_out);
+			int acked = prior_packets - tp->packets_out;
 			if (IsReno(tp))
 				tcp_remove_reno_sacks(sk, tp, acked);
 			is_dupack = tcp_try_undo_partial(sk, tp, acked);
@@ -1949,7 +1936,7 @@
 		tp->high_seq = tp->snd_nxt;
 		tp->prior_ssthresh = 0;
 		tp->undo_marker = tp->snd_una;
-		tp->undo_retrans = tcp_get_pcount(&tp->retrans_out);
+		tp->undo_retrans = tp->retrans_out;
 
 		if (tp->ca_state < TCP_CA_CWR) {
 			if (!(flag&FLAG_ECE))
@@ -2349,7 +2336,7 @@
 
 static inline void tcp_ack_packets_out(struct sock *sk, struct tcp_sock *tp)
 {
-	if (!tcp_get_pcount(&tp->packets_out)) {
+	if (!tp->packets_out) {
 		tcp_clear_xmit_timer(sk, TCP_TIME_RETRANS);
 	} else {
 		tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
@@ -2391,18 +2378,15 @@
 		if (sacked) {
 			if (sacked & TCPCB_RETRANS) {
 				if (sacked & TCPCB_SACKED_RETRANS)
-					tcp_dec_pcount_explicit(&tp->retrans_out,
-								packets_acked);
+					tp->retrans_out -= packets_acked;
 				acked |= FLAG_RETRANS_DATA_ACKED;
 				*seq_rtt = -1;
 			} else if (*seq_rtt < 0)
 				*seq_rtt = now - scb->when;
 			if (sacked & TCPCB_SACKED_ACKED)
-				tcp_dec_pcount_explicit(&tp->sacked_out,
-							packets_acked);
+				tp->sacked_out -= packets_acked;
 			if (sacked & TCPCB_LOST)
-				tcp_dec_pcount_explicit(&tp->lost_out,
-							packets_acked);
+				tp->lost_out -= packets_acked;
 			if (sacked & TCPCB_URG) {
 				if (tp->urg_mode &&
 				    !before(seq, tp->snd_up))
@@ -2411,12 +2395,11 @@
 		} else if (*seq_rtt < 0)
 			*seq_rtt = now - scb->when;
 
-		if (tcp_get_pcount(&tp->fackets_out)) {
-			__u32 dval = min(tcp_get_pcount(&tp->fackets_out),
-					 packets_acked);
-			tcp_dec_pcount_explicit(&tp->fackets_out, dval);
+		if (tp->fackets_out) {
+			__u32 dval = min(tp->fackets_out, packets_acked);
+			tp->fackets_out -= dval;
 		}
-		tcp_dec_pcount_explicit(&tp->packets_out, packets_acked);
+		tp->packets_out -= packets_acked;
 
 		BUG_ON(tcp_skb_pcount(skb) == 0);
 		BUG_ON(!before(scb->seq, scb->end_seq));
@@ -2468,15 +2451,15 @@
 		if (sacked) {
 			if (sacked & TCPCB_RETRANS) {
 				if(sacked & TCPCB_SACKED_RETRANS)
-					tcp_dec_pcount(&tp->retrans_out, skb);
+					tp->retrans_out -= tcp_skb_pcount(skb);
 				acked |= FLAG_RETRANS_DATA_ACKED;
 				seq_rtt = -1;
 			} else if (seq_rtt < 0)
 				seq_rtt = now - scb->when;
 			if (sacked & TCPCB_SACKED_ACKED)
-				tcp_dec_pcount(&tp->sacked_out, skb);
+				tp->sacked_out -= tcp_skb_pcount(skb);
 			if (sacked & TCPCB_LOST)
-				tcp_dec_pcount(&tp->lost_out, skb);
+				tp->lost_out -= tcp_skb_pcount(skb);
 			if (sacked & TCPCB_URG) {
 				if (tp->urg_mode &&
 				    !before(scb->end_seq, tp->snd_up))
@@ -2496,27 +2479,24 @@
 	}
 
 #if FASTRETRANS_DEBUG > 0
-	BUG_TRAP((int)tcp_get_pcount(&tp->sacked_out) >= 0);
-	BUG_TRAP((int)tcp_get_pcount(&tp->lost_out) >= 0);
-	BUG_TRAP((int)tcp_get_pcount(&tp->retrans_out) >= 0);
-	if (!tcp_get_pcount(&tp->packets_out) && tp->sack_ok) {
-		if (tcp_get_pcount(&tp->lost_out)) {
+	BUG_TRAP((int)tp->sacked_out >= 0);
+	BUG_TRAP((int)tp->lost_out >= 0);
+	BUG_TRAP((int)tp->retrans_out >= 0);
+	if (!tp->packets_out && tp->sack_ok) {
+		if (tp->lost_out) {
 			printk(KERN_DEBUG "Leak l=%u %d\n",
-			       tcp_get_pcount(&tp->lost_out),
-			       tp->ca_state);
-			tcp_set_pcount(&tp->lost_out, 0);
+			       tp->lost_out, tp->ca_state);
+			tp->lost_out = 0;
 		}
-		if (tcp_get_pcount(&tp->sacked_out)) {
+		if (tp->sacked_out) {
 			printk(KERN_DEBUG "Leak s=%u %d\n",
-			       tcp_get_pcount(&tp->sacked_out),
-			       tp->ca_state);
-			tcp_set_pcount(&tp->sacked_out, 0);
+			       tp->sacked_out, tp->ca_state);
+			tp->sacked_out = 0;
 		}
-		if (tcp_get_pcount(&tp->retrans_out)) {
+		if (tp->retrans_out) {
 			printk(KERN_DEBUG "Leak r=%u %d\n",
-			       tcp_get_pcount(&tp->retrans_out),
-			       tp->ca_state);
-			tcp_set_pcount(&tp->retrans_out, 0);
+			       tp->retrans_out, tp->ca_state);
+			tp->retrans_out = 0;
 		}
 	}
 #endif
@@ -2943,7 +2923,7 @@
 	 */
 	sk->sk_err_soft = 0;
 	tp->rcv_tstamp = tcp_time_stamp;
-	prior_packets = tcp_get_pcount(&tp->packets_out);
+	prior_packets = tp->packets_out;
 	if (!prior_packets)
 		goto no_queue;
 
@@ -3964,7 +3944,7 @@
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (tcp_get_pcount(&tp->packets_out) < tp->snd_cwnd &&
+	if (tp->packets_out < tp->snd_cwnd &&
 	    !(sk->sk_userlocks & SOCK_SNDBUF_LOCK) &&
 	    !tcp_memory_pressure &&
 	    atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
===== net/ipv4/tcp_minisocks.c 1.62 vs edited =====
--- 1.62/net/ipv4/tcp_minisocks.c	2005-01-14 15:41:05 +11:00
+++ edited/net/ipv4/tcp_minisocks.c	2005-01-17 20:42:09 +11:00
@@ -754,11 +754,11 @@
 		newtp->mdev = TCP_TIMEOUT_INIT;
 		newtp->rto = TCP_TIMEOUT_INIT;
 
-		tcp_set_pcount(&newtp->packets_out, 0);
-		tcp_set_pcount(&newtp->left_out, 0);
-		tcp_set_pcount(&newtp->retrans_out, 0);
-		tcp_set_pcount(&newtp->sacked_out, 0);
-		tcp_set_pcount(&newtp->fackets_out, 0);
+		newtp->packets_out = 0;
+		newtp->left_out = 0;
+		newtp->retrans_out = 0;
+		newtp->sacked_out = 0;
+		newtp->fackets_out = 0;
 		newtp->snd_ssthresh = 0x7fffffff;
 
 		/* So many TCP implementations out there (incorrectly) count the
===== net/ipv4/tcp_output.c 1.75 vs edited =====
--- 1.75/net/ipv4/tcp_output.c	2004-12-29 05:22:40 +11:00
+++ edited/net/ipv4/tcp_output.c	2005-01-17 20:42:09 +11:00
@@ -129,8 +129,7 @@
 {
 	u32 now = tcp_time_stamp;
 
-	if (!tcp_get_pcount(&tp->packets_out) &&
-	    (s32)(now - tp->lsndtime) > tp->rto)
+	if (!tp->packets_out && (s32)(now - tp->lsndtime) > tp->rto)
 		tcp_cwnd_restart(tp, __sk_dst_get(sk));
 
 	tp->lsndtime = now;
@@ -509,8 +508,8 @@
 	TCP_SKB_CB(buff)->when = TCP_SKB_CB(skb)->when;
 
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
-		tcp_dec_pcount(&tp->lost_out, skb);
-		tcp_dec_pcount(&tp->left_out, skb);
+		tp->lost_out -= tcp_skb_pcount(skb);
+		tp->left_out -= tcp_skb_pcount(skb);
 	}
 
 	/* Fix up tso_factor for both original and new SKB.  */
@@ -518,13 +517,13 @@
 	tcp_set_skb_tso_segs(buff, tp->mss_cache_std);
 
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
-		tcp_inc_pcount(&tp->lost_out, skb);
-		tcp_inc_pcount(&tp->left_out, skb);
+		tp->lost_out += tcp_skb_pcount(skb);
+		tp->left_out += tcp_skb_pcount(skb);
 	}
 
 	if (TCP_SKB_CB(buff)->sacked&TCPCB_LOST) {
-		tcp_inc_pcount(&tp->lost_out, buff);
-		tcp_inc_pcount(&tp->left_out, buff);
+		tp->lost_out += tcp_skb_pcount(buff);
+		tp->left_out += tcp_skb_pcount(buff);
 	}
 
 	/* Link BUFF into the send queue. */
@@ -773,7 +772,7 @@
 			return 0;
 		}
 
-		return !tcp_get_pcount(&tp->packets_out) && sk->sk_send_head;
+		return !tp->packets_out && sk->sk_send_head;
 	}
 	return 0;
 }
@@ -945,15 +944,15 @@
 		 */
 		TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked&(TCPCB_EVER_RETRANS|TCPCB_AT_TAIL);
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_SACKED_RETRANS)
-			tcp_dec_pcount(&tp->retrans_out, next_skb);
+			tp->retrans_out -= tcp_skb_pcount(next_skb);
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_LOST) {
-			tcp_dec_pcount(&tp->lost_out, next_skb);
-			tcp_dec_pcount(&tp->left_out, next_skb);
+			tp->lost_out -= tcp_skb_pcount(next_skb);
+			tp->left_out -= tcp_skb_pcount(next_skb);
 		}
 		/* Reno case is special. Sigh... */
-		if (!tp->sack_ok && tcp_get_pcount(&tp->sacked_out)) {
+		if (!tp->sack_ok && tp->sacked_out) {
 			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
-			tcp_dec_pcount(&tp->left_out, next_skb);
+			tp->left_out -= tcp_skb_pcount(next_skb);
 		}
 
 		/* Not quite right: it can be > snd.fack, but
@@ -981,11 +980,11 @@
 		    !(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
 			if (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tcp_dec_pcount(&tp->retrans_out, skb);
+				tp->retrans_out -= tcp_skb_pcount(skb);
 			}
 			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_LOST)) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tcp_inc_pcount(&tp->lost_out, skb);
+				tp->lost_out += tcp_skb_pcount(skb);
 				lost = 1;
 			}
 		}
@@ -1060,9 +1059,8 @@
 
 		/* New SKB created, account for it. */
 		new_factor = tcp_skb_pcount(skb);
-		tcp_dec_pcount_explicit(&tp->packets_out,
-					old_factor - new_factor);
-		tcp_inc_pcount(&tp->packets_out, skb->next);
+		tp->packets_out -= old_factor - new_factor;
+		tp->packets_out += tcp_skb_pcount(skb->next);
 	}
 
 	/* Collapse two adjacent packets if worthwhile and we can. */
@@ -1115,7 +1113,7 @@
 		}
 #endif
 		TCP_SKB_CB(skb)->sacked |= TCPCB_RETRANS;
-		tcp_inc_pcount(&tp->retrans_out, skb);
+		tp->retrans_out += tcp_skb_pcount(skb);
 
 		/* Save stamp of the first retransmit. */
 		if (!tp->retrans_stamp)
@@ -1143,7 +1141,7 @@
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	int packet_cnt = tcp_get_pcount(&tp->lost_out);
+	int packet_cnt = tp->lost_out;
 
 	/* First pass: retransmit lost packets. */
 	if (packet_cnt) {
@@ -1210,7 +1208,7 @@
 		 * real MSS sized packet because tcp_retransmit_skb()
 		 * will fragment it if necessary.
 		 */
-		if (++packet_cnt > tcp_get_pcount(&tp->fackets_out))
+		if (++packet_cnt > tp->fackets_out)
 			break;
 
 		if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
@@ -1496,7 +1494,7 @@
 	tp->retrans_stamp = TCP_SKB_CB(buff)->when;
 	__skb_queue_tail(&sk->sk_write_queue, buff);
 	sk_charge_skb(sk, buff);
-	tcp_inc_pcount(&tp->packets_out, buff);
+	tp->packets_out += tcp_skb_pcount(buff);
 	tcp_transmit_skb(sk, skb_clone(buff, GFP_KERNEL));
 	TCP_INC_STATS(TCP_MIB_ACTIVEOPENS);
 
@@ -1694,7 +1692,7 @@
 
 	err = tcp_write_wakeup(sk);
 
-	if (tcp_get_pcount(&tp->packets_out) || !sk->sk_send_head) {
+	if (tp->packets_out || !sk->sk_send_head) {
 		/* Cancel probe timer, if it is not required. */
 		tp->probes_out = 0;
 		tp->backoff = 0;
===== net/ipv4/tcp_timer.c 1.28 vs edited =====
--- 1.28/net/ipv4/tcp_timer.c	2005-01-07 10:13:39 +11:00
+++ edited/net/ipv4/tcp_timer.c	2005-01-17 20:42:09 +11:00
@@ -123,7 +123,7 @@
 		 *      1. Last segment was sent recently. */
 		if ((s32)(tcp_time_stamp - tp->lsndtime) <= TCP_TIMEWAIT_LEN ||
 		    /*  2. Window is closed. */
-		    (!tp->snd_wnd && !tcp_get_pcount(&tp->packets_out)))
+		    (!tp->snd_wnd && !tp->packets_out))
 			do_reset = 1;
 		if (do_reset)
 			tcp_send_active_reset(sk, GFP_ATOMIC);
@@ -271,7 +271,7 @@
 	struct tcp_sock *tp = tcp_sk(sk);
 	int max_probes;
 
-	if (tcp_get_pcount(&tp->packets_out) || !sk->sk_send_head) {
+	if (tp->packets_out || !sk->sk_send_head) {
 		tp->probes_out = 0;
 		return;
 	}
@@ -318,7 +318,7 @@
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (!tcp_get_pcount(&tp->packets_out))
+	if (!tp->packets_out)
 		goto out;
 
 	BUG_TRAP(!skb_queue_empty(&sk->sk_write_queue));
@@ -608,7 +608,7 @@
 	elapsed = keepalive_time_when(tp);
 
 	/* It is alive without keepalive 8) */
-	if (tcp_get_pcount(&tp->packets_out) || sk->sk_send_head)
+	if (tp->packets_out || sk->sk_send_head)
 		goto resched;
 
 	elapsed = tcp_time_stamp - tp->rcv_tstamp;

--lrZ03NoBR/3+SXJZ--
