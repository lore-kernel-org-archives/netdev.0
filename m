From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and MSS
Date: Thu, 30 Sep 2004 21:18:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930211850.53da1542.davem@davemloft.net>
References: <20040929154645.4e8987d2.davem@davemloft.net>
	<Pine.NEB.4.33.0409291848350.3434-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409291848350.3434-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 18:51:36 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> On Wed, 29 Sep 2004, David S. Miller wrote:
> 
> > If you are on ethernet using different MTU's, shouldn't you be
> > getting ICMP messages back when trying to communicate with that
> > host which will decrease the PMTU of the path?  TCP's MSS is
> > determined in terms of this, so I can't see what the issue is.
> 
> Unfortunately no.  If there's no router in between, the frame gets smashed
> and no ICMP is generated.  Proper communication relies on honoring the MSS
> value for directly connected machines.
> 
> Regardless, it is probably a good idea to honor the MSS value anyway,
> because I think you're violating the TCP spec otherwise.

Ok, I hacked up the fix for this.  There are some nice
results to these changes:

1) All the 'hack zone' crap disappeared from ip_output.c
2) tcp_skb_cb got smaller again
3) ipv6 support could be added very easily, once we
   have cards that support this (none currently)

It also fixes the MSS problem John Heffner noticed which
caused this thread.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/30 20:58:53-07:00 davem@nuts.davemloft.net 
#   [TCP]: Kill tso_{factor,mss}.
#   
#   We can just use skb_shinfo(skb)->tso_{segs,size}
#   directly.  This also allows us to kill the
#   hack zone code in ip_output.c
#   
#   The original impetus for thus change was a problem
#   noted by John Heffner.  We do not abide by the MSS
#   of the connection for TCP segmentation, we were using
#   the path MTU instead.  This broke various local
#   network setups with TSO enabled and is fixed as a side
#   effect of these changes.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2004/09/30 20:56:45-07:00 davem@nuts.davemloft.net +30 -28
#   [TCP]: Kill tso_{factor,mss}.
# 
# net/ipv4/tcp_input.c
#   2004/09/30 20:56:45-07:00 davem@nuts.davemloft.net +7 -7
#   [TCP]: Kill tso_{factor,mss}.
# 
# net/ipv4/tcp.c
#   2004/09/30 20:56:45-07:00 davem@nuts.davemloft.net +2 -2
#   [TCP]: Kill tso_{factor,mss}.
# 
# net/ipv4/ip_output.c
#   2004/09/30 20:56:45-07:00 davem@nuts.davemloft.net +1 -14
#   [TCP]: Kill tso_{factor,mss}.
# 
# include/net/tcp.h
#   2004/09/30 20:56:45-07:00 davem@nuts.davemloft.net +11 -7
#   [TCP]: Kill tso_{factor,mss}.
# 
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-09-30 20:59:22 -07:00
+++ b/include/net/tcp.h	2004-09-30 20:59:22 -07:00
@@ -1152,8 +1152,6 @@
 
 	__u16		urg_ptr;	/* Valid w/URG flags is set.	*/
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
-	__u16		tso_factor;	/* If > 1, TSO frame		*/
-	__u16		tso_mss;	/* MSS that FACTOR's in terms of*/
 };
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
@@ -1165,7 +1163,13 @@
  */
 static inline int tcp_skb_pcount(struct sk_buff *skb)
 {
-	return TCP_SKB_CB(skb)->tso_factor;
+	return skb_shinfo(skb)->tso_segs;
+}
+
+/* This is valid iff tcp_skb_pcount() > 1. */
+static inline int tcp_skb_psize(struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->tso_size;
 }
 
 static inline void tcp_inc_pcount(tcp_pcount_t *count, struct sk_buff *skb)
@@ -1440,7 +1444,7 @@
 		  tcp_minshall_check(tp))));
 }
 
-extern void tcp_set_skb_tso_factor(struct sk_buff *, unsigned int);
+extern void tcp_set_skb_tso_segs(struct sk_buff *, unsigned int);
 
 /* This checks if the data bearing packet SKB (usually sk->sk_send_head)
  * should be put on the wire right now.
@@ -1448,11 +1452,11 @@
 static __inline__ int tcp_snd_test(struct tcp_opt *tp, struct sk_buff *skb,
 				   unsigned cur_mss, int nonagle)
 {
-	int pkts = TCP_SKB_CB(skb)->tso_factor;
+	int pkts = tcp_skb_pcount(skb);
 
 	if (!pkts) {
-		tcp_set_skb_tso_factor(skb, tp->mss_cache_std);
-		pkts = TCP_SKB_CB(skb)->tso_factor;
+		tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
+		pkts = tcp_skb_pcount(skb);
 	}
 
 	/*	RFC 1122 - section 4.2.3.4
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	2004-09-30 20:59:22 -07:00
+++ b/net/ipv4/ip_output.c	2004-09-30 20:59:22 -07:00
@@ -305,7 +305,6 @@
 	struct ip_options *opt = inet->opt;
 	struct rtable *rt;
 	struct iphdr *iph;
-	u32 mtu;
 
 	/* Skip all of this if the packet is already routed,
 	 * f.e. by something like SCTP.
@@ -366,21 +365,9 @@
 	skb->nh.iph   = iph;
 	/* Transport layer set skb->h.foo itself. */
 
-	if(opt && opt->optlen) {
+	if (opt && opt->optlen) {
 		iph->ihl += opt->optlen >> 2;
 		ip_options_build(skb, opt, inet->daddr, rt, 0);
-	}
-
-	mtu = dst_pmtu(&rt->u.dst);
-	if (skb->len > mtu && (sk->sk_route_caps & NETIF_F_TSO)) {
-		unsigned int hlen;
-
-		/* Hack zone: all this must be done by TCP. */
-		hlen = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
-		skb_shinfo(skb)->tso_size = mtu - hlen;
-		skb_shinfo(skb)->tso_segs =
-			(skb->len - hlen + skb_shinfo(skb)->tso_size - 1)/
-				skb_shinfo(skb)->tso_size - 1;
 	}
 
 	ip_select_ident_more(iph, &rt->u.dst, sk, skb_shinfo(skb)->tso_segs);
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-09-30 20:59:22 -07:00
+++ b/net/ipv4/tcp.c	2004-09-30 20:59:22 -07:00
@@ -691,7 +691,7 @@
 		skb->ip_summed = CHECKSUM_HW;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
-		TCP_SKB_CB(skb)->tso_factor = 0;
+		skb_shinfo(skb)->tso_segs = 0;
 
 		if (!copied)
 			TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_PSH;
@@ -938,7 +938,7 @@
 
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
-			TCP_SKB_CB(skb)->tso_factor = 0;
+			skb_shinfo(skb)->tso_segs = 0;
 
 			from += copy;
 			copied += copy;
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-09-30 20:59:22 -07:00
+++ b/net/ipv4/tcp_input.c	2004-09-30 20:59:22 -07:00
@@ -1035,7 +1035,7 @@
 			if(!before(TCP_SKB_CB(skb)->seq, end_seq))
 				break;
 
-			fack_count += TCP_SKB_CB(skb)->tso_factor;
+			fack_count += tcp_skb_pcount(skb);
 
 			in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 				!before(end_seq, TCP_SKB_CB(skb)->end_seq);
@@ -1224,7 +1224,7 @@
 	tcp_set_pcount(&tp->fackets_out, 0);
 
 	sk_stream_for_retrans_queue(skb, sk) {
-		cnt += TCP_SKB_CB(skb)->tso_factor;;
+		cnt += tcp_skb_pcount(skb);
 		TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
 
@@ -1299,7 +1299,7 @@
 		tp->undo_marker = tp->snd_una;
 
 	sk_stream_for_retrans_queue(skb, sk) {
-		cnt += TCP_SKB_CB(skb)->tso_factor;
+		cnt += tcp_skb_pcount(skb);
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			tp->undo_marker = 0;
 		TCP_SKB_CB(skb)->sacked &= (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
@@ -1550,7 +1550,7 @@
 	BUG_TRAP(cnt <= tcp_get_pcount(&tp->packets_out));
 
 	sk_stream_for_retrans_queue(skb, sk) {
-		cnt -= TCP_SKB_CB(skb)->tso_factor;
+		cnt -= tcp_skb_pcount(skb);
 		if (cnt < 0 || after(TCP_SKB_CB(skb)->end_seq, high_seq))
 			break;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
@@ -2369,7 +2369,7 @@
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
-	__u32 mss = scb->tso_mss;
+	__u32 mss = tcp_skb_psize(skb);
 	__u32 snd_una = tp->snd_una;
 	__u32 orig_seq, seq;
 	__u32 packets_acked = 0;
@@ -2423,7 +2423,7 @@
 		}
 		tcp_dec_pcount_explicit(&tp->packets_out, packets_acked);
 
-		BUG_ON(scb->tso_factor == 0);
+		BUG_ON(tcp_skb_pcount(skb) == 0);
 		BUG_ON(!before(scb->seq, scb->end_seq));
 	}
 
@@ -2450,7 +2450,7 @@
 		 * the other end.
 		 */
 		if (after(scb->end_seq, tp->snd_una)) {
-			if (scb->tso_factor > 1)
+			if (tcp_skb_pcount(skb) > 1)
 				acked |= tcp_tso_acked(sk, skb,
 						       now, &seq_rtt);
 			break;
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-09-30 20:59:22 -07:00
+++ b/net/ipv4/tcp_output.c	2004-09-30 20:59:22 -07:00
@@ -274,7 +274,7 @@
 		int sysctl_flags;
 		int err;
 
-		BUG_ON(!TCP_SKB_CB(skb)->tso_factor);
+		BUG_ON(!tcp_skb_pcount(skb));
 
 #define SYSCTL_FLAG_TSTAMPS	0x1
 #define SYSCTL_FLAG_WSCALE	0x2
@@ -428,21 +428,22 @@
 	}
 }
 
-void tcp_set_skb_tso_factor(struct sk_buff *skb, unsigned int mss_std)
+void tcp_set_skb_tso_segs(struct sk_buff *skb, unsigned int mss_std)
 {
 	if (skb->len <= mss_std) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
-		TCP_SKB_CB(skb)->tso_factor = 1;
+		skb_shinfo(skb)->tso_segs = 1;
+		skb_shinfo(skb)->tso_size = 0;
 	} else {
 		unsigned int factor;
 
 		factor = skb->len + (mss_std - 1);
 		factor /= mss_std;
-		TCP_SKB_CB(skb)->tso_factor = factor;
+		skb_shinfo(skb)->tso_segs = factor;
+		skb_shinfo(skb)->tso_size = mss_std;
 	}
-	TCP_SKB_CB(skb)->tso_mss = mss_std;
 }
 
 /* Function to create two new TCP segments.  Shrinks the given segment
@@ -508,8 +509,8 @@
 	}
 
 	/* Fix up tso_factor for both original and new SKB.  */
-	tcp_set_skb_tso_factor(skb, tp->mss_cache_std);
-	tcp_set_skb_tso_factor(buff, tp->mss_cache_std);
+	tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
+	tcp_set_skb_tso_segs(buff, tp->mss_cache_std);
 
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
 		tcp_inc_pcount(&tp->lost_out, skb);
@@ -585,7 +586,7 @@
 	/* Any change of skb->len requires recalculation of tso
 	 * factor and mss.
 	 */
-	tcp_set_skb_tso_factor(skb, tp->mss_cache_std);
+	tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
 
 	return 0;
 }
@@ -914,8 +915,8 @@
 		    ((skb_size + next_skb_size) > mss_now))
 			return;
 
-		BUG_ON(TCP_SKB_CB(skb)->tso_factor != 1 ||
-		       TCP_SKB_CB(next_skb)->tso_factor != 1);
+		BUG_ON(tcp_skb_pcount(skb) != 1 ||
+		       tcp_skb_pcount(next_skb) != 1);
 
 		/* Ok.  We will be able to collapse the packet. */
 		__skb_unlink(next_skb, next_skb->list);
@@ -1047,14 +1048,14 @@
 		return -EAGAIN;
 
 	if (skb->len > cur_mss) {
-		int old_factor = TCP_SKB_CB(skb)->tso_factor;
+		int old_factor = tcp_skb_pcount(skb);
 		int new_factor;
 
 		if (tcp_fragment(sk, skb, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
 
 		/* New SKB created, account for it. */
-		new_factor = TCP_SKB_CB(skb)->tso_factor;
+		new_factor = tcp_skb_pcount(skb);
 		tcp_dec_pcount_explicit(&tp->packets_out,
 					old_factor - new_factor);
 		tcp_inc_pcount(&tp->packets_out, skb->next);
@@ -1081,7 +1082,8 @@
 	   tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
 			TCP_SKB_CB(skb)->seq = TCP_SKB_CB(skb)->end_seq - 1;
-			TCP_SKB_CB(skb)->tso_factor = 1;
+			skb_shinfo(skb)->tso_segs = 1;
+			skb_shinfo(skb)->tso_size = 0;
 			skb->ip_summed = CHECKSUM_NONE;
 			skb->csum = 0;
 		}
@@ -1166,7 +1168,7 @@
 						tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
 				}
 
-				packet_cnt -= TCP_SKB_CB(skb)->tso_factor;
+				packet_cnt -= tcp_skb_pcount(skb);
 				if (packet_cnt <= 0)
 					break;
 			}
@@ -1256,8 +1258,8 @@
 		skb->csum = 0;
 		TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
 		TCP_SKB_CB(skb)->sacked = 0;
-		TCP_SKB_CB(skb)->tso_factor = 1;
-		TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
+		skb_shinfo(skb)->tso_segs = 1;
+		skb_shinfo(skb)->tso_size = 0;
 
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		TCP_SKB_CB(skb)->seq = tp->write_seq;
@@ -1289,8 +1291,8 @@
 	skb->csum = 0;
 	TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
 	TCP_SKB_CB(skb)->sacked = 0;
-	TCP_SKB_CB(skb)->tso_factor = 1;
-	TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
+	skb_shinfo(skb)->tso_segs = 1;
+	skb_shinfo(skb)->tso_size = 0;
 
 	/* Send it off. */
 	TCP_SKB_CB(skb)->seq = tcp_acceptable_seq(sk, tp);
@@ -1371,8 +1373,8 @@
 	TCP_SKB_CB(skb)->seq = req->snt_isn;
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;
 	TCP_SKB_CB(skb)->sacked = 0;
-	TCP_SKB_CB(skb)->tso_factor = 1;
-	TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
+	skb_shinfo(skb)->tso_segs = 1;
+	skb_shinfo(skb)->tso_size = 0;
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(req->rcv_isn + 1);
 	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
@@ -1474,8 +1476,8 @@
 	TCP_SKB_CB(buff)->flags = TCPCB_FLAG_SYN;
 	TCP_ECN_send_syn(sk, tp, buff);
 	TCP_SKB_CB(buff)->sacked = 0;
-	TCP_SKB_CB(buff)->tso_factor = 1;
-	TCP_SKB_CB(buff)->tso_mss = tp->mss_cache_std;
+	skb_shinfo(buff)->tso_segs = 1;
+	skb_shinfo(buff)->tso_size = 0;
 	buff->csum = 0;
 	TCP_SKB_CB(buff)->seq = tp->write_seq++;
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
@@ -1575,8 +1577,8 @@
 		buff->csum = 0;
 		TCP_SKB_CB(buff)->flags = TCPCB_FLAG_ACK;
 		TCP_SKB_CB(buff)->sacked = 0;
-		TCP_SKB_CB(buff)->tso_factor = 1;
-		TCP_SKB_CB(buff)->tso_mss = tp->mss_cache_std;
+		skb_shinfo(buff)->tso_segs = 1;
+		skb_shinfo(buff)->tso_size = 0;
 
 		/* Send it off, this clears delayed acks for us. */
 		TCP_SKB_CB(buff)->seq = TCP_SKB_CB(buff)->end_seq = tcp_acceptable_seq(sk, tp);
@@ -1611,8 +1613,8 @@
 	skb->csum = 0;
 	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(skb)->sacked = urgent;
-	TCP_SKB_CB(skb)->tso_factor = 1;
-	TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
+	skb_shinfo(skb)->tso_segs = 1;
+	skb_shinfo(skb)->tso_size = 0;
 
 	/* Use a previous sequence.  This should cause the other
 	 * end to send an ack.  Don't queue or clone SKB, just
@@ -1656,8 +1658,8 @@
 					sk->sk_route_caps &= ~NETIF_F_TSO;
 					tp->mss_cache = tp->mss_cache_std;
 				}
-			} else if (!TCP_SKB_CB(skb)->tso_factor)
-				tcp_set_skb_tso_factor(skb, tp->mss_cache_std);
+			} else if (!tcp_skb_pcount(skb))
+				tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
 
 			TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
