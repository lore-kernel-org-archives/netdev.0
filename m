From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 17:13:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927171356.6a59d039.davem@davemloft.net>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>
	<20040927160411.22b44f48.davem@davemloft.net>
	<20040927233639.GA8333@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040927233639.GA8333@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 09:36:39 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I think you need to at least decrement packets_out here.  Otherwise
> the prior_in_flight >= tp->snd_cwnd check in tcp_ack() might become
> incorrect for the next ack.
> 
> Even better, you could move the skb->data pointer forward and forget
> about that segment altogether.

Bright minds think alike.  :-)  We have to keep all the other
packet counts in sync as well.

Andi, others, forget my previous hack patch to tcp_clean_rtx_queue()
and give this more complete patch a try.

I'm getting really good results here on my tg3<-->tg3 setup using
this patch.

===== include/net/tcp.h 1.89 vs edited =====
--- 1.89/include/net/tcp.h	2004-09-27 11:57:52 -07:00
+++ edited/include/net/tcp.h	2004-09-27 15:56:24 -07:00
@@ -1180,7 +1180,8 @@
 
 	__u16		urg_ptr;	/* Valid w/URG flags is set.	*/
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
-	__u32		tso_factor;
+	__u16		tso_factor;	/* If > 1, TSO frame		*/
+	__u16		tso_offset;	/* ACK within TSO frame		*/
 };
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
===== net/ipv4/tcp_input.c 1.75 vs edited =====
--- 1.75/net/ipv4/tcp_input.c	2004-09-27 12:00:32 -07:00
+++ edited/net/ipv4/tcp_input.c	2004-09-27 16:36:29 -07:00
@@ -2355,6 +2355,60 @@
 	}
 }
 
+static int tcp_tso_acked(struct tcp_opt *tp, struct sk_buff *skb,
+			 __u32 now, __s32 *seq_rtt)
+{
+	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
+	__u32 tso_seq = scb->seq + scb->tso_offset;
+	__u32 mss = tp->mss_cache_std;
+	__u32 snd_una = tp->snd_una;
+	int acked = 0;
+
+	/* If we get here, the whole TSO packet has not been
+	 * acked.
+	 */
+	BUG_ON(!after(scb->end_seq, snd_una) ||
+	       tso_seq == scb->end_seq);
+
+	while (!after(tso_seq + mss, snd_una)) {
+		__u8 sacked = scb->sacked;
+
+		tso_seq += mss;
+		acked |= FLAG_DATA_ACKED;
+		BUG_ON(pskb_pull(skb, mss) == NULL);
+		if (sacked) {
+			if (sacked & TCPCB_RETRANS) {
+				if(sacked & TCPCB_SACKED_RETRANS)
+					tcp_dec_pcount_explicit(&tp->retrans_out, 1);
+				acked |= FLAG_RETRANS_DATA_ACKED;
+				*seq_rtt = -1;
+			} else if (*seq_rtt < 0)
+				*seq_rtt = now - scb->when;
+			if (sacked & TCPCB_SACKED_ACKED)
+				tcp_dec_pcount_explicit(&tp->sacked_out, 1);
+			if (sacked & TCPCB_LOST)
+				tcp_dec_pcount_explicit(&tp->lost_out, 1);
+			/* We can only exit URG mode for full TSO packet ack,
+			 * by definition, so we need not do that check here.
+			 */
+		} else if (*seq_rtt < 0)
+			*seq_rtt = now - scb->when;
+
+		if (tcp_get_pcount(&tp->fackets_out))
+			tcp_dec_pcount_explicit(&tp->fackets_out, 1);
+		tcp_dec_pcount_explicit(&tp->packets_out, 1);
+		scb->tso_factor--;
+
+		BUG_ON(scb->tso_factor == 0);
+		BUG_ON(!before(tso_seq, scb->end_seq));
+	}
+
+	scb->tso_offset = (tso_seq - scb->seq);
+
+	return acked;
+}
+
+
 /* Remove acknowledged frames from the retransmission queue. */
 static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 {
@@ -2373,8 +2427,12 @@
 		 * discard it as it's confirmed to have arrived at
 		 * the other end.
 		 */
-		if (after(scb->end_seq, tp->snd_una))
+		if (after(scb->end_seq, tp->snd_una)) {
+			if (scb->tso_factor)
+				acked |= tcp_tso_acked(tp, skb,
+						       now, &seq_rtt);
 			break;
+		}
 
 		/* Initial outgoing SYN's get put onto the write_queue
 		 * just like anything else we transmit.  It is not
===== net/ipv4/tcp_output.c 1.59 vs edited =====
--- 1.59/net/ipv4/tcp_output.c	2004-09-27 11:57:52 -07:00
+++ edited/net/ipv4/tcp_output.c	2004-09-27 15:52:15 -07:00
@@ -436,6 +436,7 @@
 		factor /= mss_std;
 		TCP_SKB_CB(skb)->tso_factor = factor;
 	}
+	TCP_SKB_CB(skb)->tso_offset = 0;
 }
 
 /* Function to create two new TCP segments.  Shrinks the given segment
@@ -1191,6 +1192,7 @@
 		TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
 		TCP_SKB_CB(skb)->sacked = 0;
 		TCP_SKB_CB(skb)->tso_factor = 1;
+		TCP_SKB_CB(skb)->tso_offset = 1;
 
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		TCP_SKB_CB(skb)->seq = tp->write_seq;
@@ -1223,6 +1225,7 @@
 	TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
 	TCP_SKB_CB(skb)->sacked = 0;
 	TCP_SKB_CB(skb)->tso_factor = 1;
+	TCP_SKB_CB(skb)->tso_offset = 1;
 
 	/* Send it off. */
 	TCP_SKB_CB(skb)->seq = tcp_acceptable_seq(sk, tp);
@@ -1304,6 +1307,7 @@
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;
 	TCP_SKB_CB(skb)->sacked = 0;
 	TCP_SKB_CB(skb)->tso_factor = 1;
+	TCP_SKB_CB(skb)->tso_offset = 1;
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(req->rcv_isn + 1);
 	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
@@ -1406,6 +1410,7 @@
 	TCP_ECN_send_syn(sk, tp, buff);
 	TCP_SKB_CB(buff)->sacked = 0;
 	TCP_SKB_CB(buff)->tso_factor = 1;
+	TCP_SKB_CB(buff)->tso_offset = 1;
 	buff->csum = 0;
 	TCP_SKB_CB(buff)->seq = tp->write_seq++;
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
@@ -1506,6 +1511,7 @@
 		TCP_SKB_CB(buff)->flags = TCPCB_FLAG_ACK;
 		TCP_SKB_CB(buff)->sacked = 0;
 		TCP_SKB_CB(buff)->tso_factor = 1;
+		TCP_SKB_CB(buff)->tso_offset = 1;
 
 		/* Send it off, this clears delayed acks for us. */
 		TCP_SKB_CB(buff)->seq = TCP_SKB_CB(buff)->end_seq = tcp_acceptable_seq(sk, tp);
@@ -1541,6 +1547,7 @@
 	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(skb)->sacked = urgent;
 	TCP_SKB_CB(skb)->tso_factor = 1;
+	TCP_SKB_CB(skb)->tso_offset = 1;
 
 	/* Use a previous sequence.  This should cause the other
 	 * end to send an ack.  Don't queue or clone SKB, just
