From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 21:33:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929213310.40f5f33a.davem@davemloft.net>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
	<415B24C0.2020208@us.ibm.com>
	<20040929145050.71afa1ac.davem@davemloft.net>
	<20040929215613.GC26714@wotan.suse.de>
	<20040929162923.796d142e.davem@davemloft.net>
	<20040930000515.GA10496@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, jheffner@psc.edu, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040930000515.GA10496@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 10:05:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Sep 29, 2004 at 04:29:23PM -0700, David S. Miller wrote:
> >
> > @@ -567,12 +567,18 @@
> >  	skb->ip_summed = CHECKSUM_HW;
> > +
> > +	/* Any change of skb->len requires recalculation of tso
> > +	 * factor and mss.
> > +	 */
> > +	tcp_set_skb_tso_factor(skb, tp->mss_cache_std);
> 
> Minor optimsations: __tcp_trim_head is only called directly when
> tso_factor has already been adjusted by tcp_tso_acked.  So you can
> move this setting into tcp_trim_head.

Right.  This patch below combines that with adjustment of socket
send queue usage when we trim the head.

I also added John Heffner's snd_cwnd TSO factor tweak.  I adjusted
it down to 1/4 of the congestion window because it gave the best
ramp-up performance for a cross-continental transfer test.

John, this might make your netperf case go better.  Give it a try
and let me know how it goes.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/29 21:12:18-07:00 davem@nuts.davemloft.net 
#   [TCP]: Smooth out TSO ack clocking.
#   
#   - Export tcp_trim_head() and call it directly from
#     tcp_tso_acked().  This also fixes URG handling.
#   
#   - Make tcp_trim_head() adjust the skb->truesize of
#     the packet and liberate that space from the socket
#     send buffer.
#   
#   - In tcp_current_mss(), limit TSO factor to 1/4 of
#     snd_cwnd.  The idea is from John Heffner.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2004/09/29 21:11:53-07:00 davem@nuts.davemloft.net +15 -35
#   [TCP]: Smooth out TSO ack clocking.
#   
#   - Export tcp_trim_head() and call it directly from
#     tcp_tso_acked().  This also fixes URG handling.
#   
#   - Make tcp_trim_head() adjust the skb->truesize of
#     the packet and liberate that space from the socket
#     send buffer.
#   
#   - In tcp_current_mss(), limit TSO factor to 1/4 of
#     snd_cwnd.  The idea is from John Heffner.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_input.c
#   2004/09/29 21:11:53-07:00 davem@nuts.davemloft.net +9 -13
#   [TCP]: Smooth out TSO ack clocking.
#   
#   - Export tcp_trim_head() and call it directly from
#     tcp_tso_acked().  This also fixes URG handling.
#   
#   - Make tcp_trim_head() adjust the skb->truesize of
#     the packet and liberate that space from the socket
#     send buffer.
#   
#   - In tcp_current_mss(), limit TSO factor to 1/4 of
#     snd_cwnd.  The idea is from John Heffner.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/net/tcp.h
#   2004/09/29 21:11:52-07:00 davem@nuts.davemloft.net +1 -0
#   [TCP]: Smooth out TSO ack clocking.
#   
#   - Export tcp_trim_head() and call it directly from
#     tcp_tso_acked().  This also fixes URG handling.
#   
#   - Make tcp_trim_head() adjust the skb->truesize of
#     the packet and liberate that space from the socket
#     send buffer.
#   
#   - In tcp_current_mss(), limit TSO factor to 1/4 of
#     snd_cwnd.  The idea is from John Heffner.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-09-29 21:12:59 -07:00
+++ b/include/net/tcp.h	2004-09-29 21:12:59 -07:00
@@ -944,6 +944,7 @@
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
+extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
 
 extern void tcp_send_probe0(struct sock *);
 extern void tcp_send_partial(struct sock *);
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-09-29 21:12:59 -07:00
+++ b/net/ipv4/tcp_input.c	2004-09-29 21:12:59 -07:00
@@ -2364,13 +2364,14 @@
  * then making a write space wakeup callback is a possible
  * future enhancement.  WARNING: it is not trivial to make.
  */
-static int tcp_tso_acked(struct tcp_opt *tp, struct sk_buff *skb,
+static int tcp_tso_acked(struct sock *sk, struct sk_buff *skb,
 			 __u32 now, __s32 *seq_rtt)
 {
+	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
 	__u32 mss = scb->tso_mss;
 	__u32 snd_una = tp->snd_una;
-	__u32 seq = scb->seq;
+	__u32 orig_seq, seq;
 	__u32 packets_acked = 0;
 	int acked = 0;
 
@@ -2379,22 +2380,18 @@
 	 */
 	BUG_ON(!after(scb->end_seq, snd_una));
 
+	seq = orig_seq = scb->seq;
 	while (!after(seq + mss, snd_una)) {
 		packets_acked++;
 		seq += mss;
 	}
 
+	if (tcp_trim_head(sk, skb, (seq - orig_seq)))
+		return 0;
+
 	if (packets_acked) {
 		__u8 sacked = scb->sacked;
 
-		/* We adjust scb->seq but we do not pskb_pull() the
-		 * SKB.  We let tcp_retransmit_skb() handle this case
-		 * by checking skb->len against the data sequence span.
-		 * This way, we avoid the pskb_pull() work unless we
-		 * actually need to retransmit the SKB.
-		 */
-		scb->seq = seq;
-
 		acked |= FLAG_DATA_ACKED;
 		if (sacked) {
 			if (sacked & TCPCB_RETRANS) {
@@ -2413,7 +2410,7 @@
 							packets_acked);
 			if (sacked & TCPCB_URG) {
 				if (tp->urg_mode &&
-				    !before(scb->seq, tp->snd_up))
+				    !before(orig_seq, tp->snd_up))
 					tp->urg_mode = 0;
 			}
 		} else if (*seq_rtt < 0)
@@ -2425,7 +2422,6 @@
 			tcp_dec_pcount_explicit(&tp->fackets_out, dval);
 		}
 		tcp_dec_pcount_explicit(&tp->packets_out, packets_acked);
-		scb->tso_factor -= packets_acked;
 
 		BUG_ON(scb->tso_factor == 0);
 		BUG_ON(!before(scb->seq, scb->end_seq));
@@ -2455,7 +2451,7 @@
 		 */
 		if (after(scb->end_seq, tp->snd_una)) {
 			if (scb->tso_factor > 1)
-				acked |= tcp_tso_acked(tp, skb,
+				acked |= tcp_tso_acked(sk, skb,
 						       now, &seq_rtt);
 			break;
 		}
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-09-29 21:12:59 -07:00
+++ b/net/ipv4/tcp_output.c	2004-09-29 21:12:59 -07:00
@@ -525,7 +525,7 @@
  * eventually). The difference is that pulled data not copied, but
  * immediately discarded.
  */
-unsigned char * __pskb_trim_head(struct sk_buff *skb, int len)
+static unsigned char *__pskb_trim_head(struct sk_buff *skb, int len)
 {
 	int i, k, eat;
 
@@ -553,8 +553,10 @@
 	return skb->tail;
 }
 
-static int __tcp_trim_head(struct tcp_opt *tp, struct sk_buff *skb, u32 len)
+int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
+	struct tcp_opt *tp = tcp_sk(sk);
+
 	if (skb_cloned(skb) &&
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
@@ -566,8 +568,14 @@
 			return -ENOMEM;
 	}
 
+	TCP_SKB_CB(skb)->seq += len;
 	skb->ip_summed = CHECKSUM_HW;
 
+	skb->truesize	     -= len;
+	sk->sk_queue_shrunk   = 1;
+	sk->sk_wmem_queued   -= len;
+	sk->sk_forward_alloc += len;
+
 	/* Any change of skb->len requires recalculation of tso
 	 * factor and mss.
 	 */
@@ -576,16 +584,6 @@
 	return 0;
 }
 
-static inline int tcp_trim_head(struct tcp_opt *tp, struct sk_buff *skb, u32 len)
-{
-	int err = __tcp_trim_head(tp, skb, len);
-
-	if (!err)
-		TCP_SKB_CB(skb)->seq += len;
-
-	return err;
-}
-
 /* This function synchronize snd mss to current pmtu/exthdr set.
 
    tp->user_mss is mss set by user by TCP_MAXSEG. It does NOT counts
@@ -686,11 +684,12 @@
 					68U - tp->tcp_header_len);
 
 		/* Always keep large mss multiple of real mss, but
-		 * do not exceed congestion window.
+		 * do not exceed 1/4 of the congestion window so we
+		 * can keep the ACK clock ticking.
 		 */
 		factor = large_mss / mss_now;
-		if (factor > tp->snd_cwnd)
-			factor = tp->snd_cwnd;
+		if (factor > (tp->snd_cwnd >> 2))
+			factor = max(1, tp->snd_cwnd >> 2);
 
 		tp->mss_cache = mss_now * factor;
 
@@ -1003,7 +1002,6 @@
 {
 	struct tcp_opt *tp = tcp_sk(sk);
  	unsigned int cur_mss = tcp_current_mss(sk, 0);
-	__u32 data_seq, data_end_seq;
 	int err;
 
 	/* Do not sent more than we queued. 1/4 is reserved for possible
@@ -1013,24 +1011,6 @@
 	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
 		return -EAGAIN;
 
-	/* What is going on here?  When TSO packets are partially ACK'd,
-	 * we adjust the TCP_SKB_CB(skb)->seq value forward but we do
-	 * not adjust the data area of the SKB.  We defer that to here
-	 * so that we can avoid the work unless we really retransmit
-	 * the packet.
-	 */
-	data_seq = TCP_SKB_CB(skb)->seq;
-	data_end_seq = TCP_SKB_CB(skb)->end_seq;
-	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
-		data_end_seq--;
-
-	if (skb->len > (data_end_seq - data_seq)) {
-		u32 to_trim = skb->len - (data_end_seq - data_seq);
-
-		if (__tcp_trim_head(tp, skb, to_trim))
-			return -ENOMEM;
-	}		
-
 	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
 		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 			BUG();
@@ -1041,7 +1021,7 @@
 			tp->mss_cache = tp->mss_cache_std;
 		}
 
-		if (tcp_trim_head(tp, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
+		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
 			return -ENOMEM;
 	}
 
