From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 21:59:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927215901.6f65dc15.davem@davemloft.net>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
	<20040927160411.22b44f48.davem@davemloft.net>
	<20040927233639.GA8333@gondor.apana.org.au>
	<20040927171356.6a59d039.davem@davemloft.net>
	<20040928003412.GA8755@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040928003412.GA8755@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 10:34:12 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Yes this looks very good.

It's got a nasty bug though, I'm not updating
TCP_SKB_CB(skb)->seq so retransmits have corrupted
sequence numbers, doh!  And hey if I update that
then I do not need this tso_offset thingy.

> > +static int tcp_tso_acked(struct tcp_opt *tp, struct sk_buff *skb,
> > +			 __u32 now, __s32 *seq_rtt)
> > +{
> > +	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
> > +	__u32 tso_seq = scb->seq + scb->tso_offset;
> > +	__u32 mss = tp->mss_cache_std;
> 
> In future we should probably record the MSS in the scb just in case
> it changes.

Fixed in my updated patch below, the above bug made me
consider this exact issue.

> > -		if (after(scb->end_seq, tp->snd_una))
> > +		if (after(scb->end_seq, tp->snd_una)) {
> > +			if (scb->tso_factor)
> 
> tso_factor > 1

Good catch, fixed below as well.

> >  		TCP_SKB_CB(skb)->tso_factor = 1;
> > +		TCP_SKB_CB(skb)->tso_offset = 1;
> 
> Is this a clever trick that I don't understand? :)

What a dumb bug, also fixed below.

This should do it for RTX queue purging and congestion
window growth.

Next I'll work on the other issues.  In particular:

1) Moving TSO mss calculations to tcp_current_mss()
   as you suggested.  Also integrating the 'large'
   usage bug fixes you sent a patch for earlier.

   I'm making this thing non-inline too, it gets
   expanded a lot.

2) The tcp_init_metrics() consistency fix you made.

3) Consider limiting 'factor' such as jheffner and myself
   have suggested over the past few days.  It might not
   be necessary, I'll do some tests.

Note the trick below wrt. adjusting the SKB data
area lazily.  I defer it to tcp_retransmit_skb()
otherwise we copy the data area around in the packet
several times, and that would undo the gain of
zerocopy + TSO wouldn't it? :-)

I mention that we might want mess with skb->truesize
and liberate space from sk->sk_wmem_alloc... but on
further reflection that might not really gain us
anything.  We'll make less work for the process by
waking up only on full TSO packet liberation.

Please scream loudly if you can find a bug in this
current patch.

===== include/net/tcp.h 1.89 vs edited =====
--- 1.89/include/net/tcp.h	2004-09-27 11:57:52 -07:00
+++ edited/include/net/tcp.h	2004-09-27 18:02:21 -07:00
@@ -1180,7 +1180,8 @@
 
 	__u16		urg_ptr;	/* Valid w/URG flags is set.	*/
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
-	__u32		tso_factor;
+	__u16		tso_factor;	/* If > 1, TSO frame		*/
+	__u16		tso_mss;	/* MSS that FACTOR's in terms of*/
 };
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
===== net/ipv4/tcp_input.c 1.75 vs edited =====
--- 1.75/net/ipv4/tcp_input.c	2004-09-27 12:00:32 -07:00
+++ edited/net/ipv4/tcp_input.c	2004-09-27 21:27:08 -07:00
@@ -2355,6 +2355,86 @@
 	}
 }
 
+/* There is one downside to this scheme.  Although we keep the
+ * ACK clock ticking, adjusting packet counters and advancing
+ * congestion window, we do not liberate socket send buffer
+ * space.
+ *
+ * Mucking with skb->truesize and sk->sk_wmem_alloc et al.
+ * then making a write space wakeup callback is a possible
+ * future enhancement.  WARNING: it is not trivial to make.
+ */
+static int tcp_tso_acked(struct tcp_opt *tp, struct sk_buff *skb,
+			 __u32 now, __s32 *seq_rtt)
+{
+	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
+	__u32 mss = scb->tso_mss;
+	__u32 snd_una = tp->snd_una;
+	__u32 seq = scb->seq;
+	__u32 packets_acked = 0;
+	int acked = 0;
+
+	/* If we get here, the whole TSO packet has not been
+	 * acked.
+	 */
+	BUG_ON(!after(scb->end_seq, snd_una));
+
+	while (!after(seq + mss, snd_una)) {
+		packets_acked++;
+		seq += mss;
+	}
+
+	if (packets_acked) {
+		__u8 sacked = scb->sacked;
+
+		/* We adjust scb->seq but we do not pskb_pull() the
+		 * SKB.  We let tcp_retransmit_skb() handle this case
+		 * by checking skb->len against the data sequence span.
+		 * This way, we avoid the pskb_pull() work unless we
+		 * actually need to retransmit the SKB.
+		 */
+		scb->seq = seq;
+
+		acked |= FLAG_DATA_ACKED;
+		if (sacked) {
+			if (sacked & TCPCB_RETRANS) {
+				if (sacked & TCPCB_SACKED_RETRANS)
+					tcp_dec_pcount_explicit(&tp->retrans_out,
+								packets_acked);
+				acked |= FLAG_RETRANS_DATA_ACKED;
+				*seq_rtt = -1;
+			} else if (*seq_rtt < 0)
+				*seq_rtt = now - scb->when;
+			if (sacked & TCPCB_SACKED_ACKED)
+				tcp_dec_pcount_explicit(&tp->sacked_out,
+							packets_acked);
+			if (sacked & TCPCB_LOST)
+				tcp_dec_pcount_explicit(&tp->lost_out,
+							packets_acked);
+			if (sacked & TCPCB_URG) {
+				if (tp->urg_mode &&
+				    !before(scb->seq, tp->snd_up))
+					tp->urg_mode = 0;
+			}
+		} else if (*seq_rtt < 0)
+			*seq_rtt = now - scb->when;
+
+		if (tcp_get_pcount(&tp->fackets_out)) {
+			__u32 dval = min(tcp_get_pcount(&tp->fackets_out),
+					 packets_acked);
+			tcp_dec_pcount_explicit(&tp->fackets_out, dval);
+		}
+		tcp_dec_pcount_explicit(&tp->packets_out, packets_acked);
+		scb->tso_factor -= packets_acked;
+
+		BUG_ON(scb->tso_factor == 0);
+		BUG_ON(!before(scb->seq, scb->end_seq));
+	}
+
+	return acked;
+}
+
+
 /* Remove acknowledged frames from the retransmission queue. */
 static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 {
@@ -2373,8 +2453,12 @@
 		 * discard it as it's confirmed to have arrived at
 		 * the other end.
 		 */
-		if (after(scb->end_seq, tp->snd_una))
+		if (after(scb->end_seq, tp->snd_una)) {
+			if (scb->tso_factor > 1)
+				acked |= tcp_tso_acked(tp, skb,
+						       now, &seq_rtt);
 			break;
+		}
 
 		/* Initial outgoing SYN's get put onto the write_queue
 		 * just like anything else we transmit.  It is not
===== net/ipv4/tcp_output.c 1.59 vs edited =====
--- 1.59/net/ipv4/tcp_output.c	2004-09-27 11:57:52 -07:00
+++ edited/net/ipv4/tcp_output.c	2004-09-27 21:27:50 -07:00
@@ -436,6 +436,7 @@
 		factor /= mss_std;
 		TCP_SKB_CB(skb)->tso_factor = factor;
 	}
+	TCP_SKB_CB(skb)->tso_mss = mss_std;
 }
 
 /* Function to create two new TCP segments.  Shrinks the given segment
@@ -552,7 +553,7 @@
 	return skb->tail;
 }
 
-static int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
+static int __tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
 	if (skb_cloned(skb) &&
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
@@ -565,11 +566,20 @@
 			return -ENOMEM;
 	}
 
-	TCP_SKB_CB(skb)->seq += len;
 	skb->ip_summed = CHECKSUM_HW;
 	return 0;
 }
 
+static inline int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
+{
+	int err = __tcp_trim_head(sk, skb, len);
+
+	if (!err)
+		TCP_SKB_CB(skb)->seq += len;
+
+	return err;
+}
+
 /* This function synchronize snd mss to current pmtu/exthdr set.
 
    tp->user_mss is mss set by user by TCP_MAXSEG. It does NOT counts
@@ -949,6 +959,7 @@
 {
 	struct tcp_opt *tp = tcp_sk(sk);
  	unsigned int cur_mss = tcp_current_mss(sk, 0);
+	__u32 data_seq, data_end_seq;
 	int err;
 
 	/* Do not sent more than we queued. 1/4 is reserved for possible
@@ -958,6 +969,22 @@
 	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
 		return -EAGAIN;
 
+	/* What is going on here?  When TSO packets are partially ACK'd,
+	 * we adjust the TCP_SKB_CB(skb)->seq value forward but we do
+	 * not adjust the data area of the SKB.  We defer that to here
+	 * so that we can avoid the work unless we really retransmit
+	 * the packet.
+	 */
+	data_seq = TCP_SKB_CB(skb)->seq;
+	data_end_seq = TCP_SKB_CB(skb)->end_seq;
+	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
+		data_end_seq--;
+
+	if (skb->len != (data_end_seq - data_seq)) {
+		if (__tcp_trim_head(sk, skb, data_end_seq - data_seq))
+			return -ENOMEM;
+	}		
+
 	if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
 		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 			BUG();
@@ -1191,6 +1218,7 @@
 		TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
 		TCP_SKB_CB(skb)->sacked = 0;
 		TCP_SKB_CB(skb)->tso_factor = 1;
+		TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
 
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		TCP_SKB_CB(skb)->seq = tp->write_seq;
@@ -1223,6 +1251,7 @@
 	TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
 	TCP_SKB_CB(skb)->sacked = 0;
 	TCP_SKB_CB(skb)->tso_factor = 1;
+	TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
 
 	/* Send it off. */
 	TCP_SKB_CB(skb)->seq = tcp_acceptable_seq(sk, tp);
@@ -1304,6 +1333,7 @@
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;
 	TCP_SKB_CB(skb)->sacked = 0;
 	TCP_SKB_CB(skb)->tso_factor = 1;
+	TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(req->rcv_isn + 1);
 	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
@@ -1406,6 +1436,7 @@
 	TCP_ECN_send_syn(sk, tp, buff);
 	TCP_SKB_CB(buff)->sacked = 0;
 	TCP_SKB_CB(buff)->tso_factor = 1;
+	TCP_SKB_CB(buff)->tso_mss = tp->mss_cache_std;
 	buff->csum = 0;
 	TCP_SKB_CB(buff)->seq = tp->write_seq++;
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
@@ -1506,6 +1537,7 @@
 		TCP_SKB_CB(buff)->flags = TCPCB_FLAG_ACK;
 		TCP_SKB_CB(buff)->sacked = 0;
 		TCP_SKB_CB(buff)->tso_factor = 1;
+		TCP_SKB_CB(buff)->tso_mss = tp->mss_cache_std;
 
 		/* Send it off, this clears delayed acks for us. */
 		TCP_SKB_CB(buff)->seq = TCP_SKB_CB(buff)->end_seq = tcp_acceptable_seq(sk, tp);
@@ -1541,6 +1573,7 @@
 	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(skb)->sacked = urgent;
 	TCP_SKB_CB(skb)->tso_factor = 1;
+	TCP_SKB_CB(skb)->tso_mss = tp->mss_cache_std;
 
 	/* Use a previous sequence.  This should cause the other
 	 * end to send an ack.  Don't queue or clone SKB, just
