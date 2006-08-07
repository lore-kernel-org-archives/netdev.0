From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Mon, 07 Aug 2006 04:45:13 -0400
Message-ID: <1154940314.4001.3.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:58298 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751128AbWHGH2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 03:28:10 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I used tcb->end_seq instead of tcb->seq. And add a new condition 'tcb-
seq == tcb->end_seq' to make ACK segment to be counted.

On Sunday 06 August 2006 22:48, Herbert Xu wrote:
> On Sun, Aug 06, 2006 at 07:44:47PM -0700, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Mon, 07 Aug 2006 12:40:34 +1000
> >
> > > The general approach looks sound.  I have one esoteric question
> > > though.  If a retransmitted packet is coalesced with one that is
> > > yet to be transmitted (a fairly unlikely scenario, but possible I
> > > think), should it count towards OUTSEGS?
> >
> > Probably the packet should be counted to OUTSEGS if any of it
contains
> > new data.
>
> OK, in that case Yongjun please update your patch to test against
> tcb->end_seq instead of tcb->seq.
>
> Cheers,

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- a/net/ipv4/tcp_output.c	2006-08-03 18:05:22.425081936 -0400
+++ b/net/ipv4/tcp_output.c	2006-08-07 09:48:41.186372896 -0400
@@ -462,7 +462,8 @@ static int tcp_transmit_skb(struct sock 
 	if (skb->len != tcp_header_size)
 		tcp_event_data_sent(tp, skb, sk);
 
-	TCP_INC_STATS(TCP_MIB_OUTSEGS);
+	if(after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
+		TCP_INC_STATS(TCP_MIB_OUTSEGS);
 
 	err = icsk->icsk_af_ops->queue_xmit(skb, 0);
 	if (likely(err <= 0))
@@ -2151,10 +2152,9 @@ int tcp_connect(struct sock *sk)
 	skb_shinfo(buff)->tso_segs = 1;
 	skb_shinfo(buff)->tso_size = 0;
 	buff->csum = 0;
+	tp->snd_nxt = tp->write_seq;
 	TCP_SKB_CB(buff)->seq = tp->write_seq++;
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
-	tp->snd_nxt = tp->write_seq;
-	tp->pushed_seq = tp->write_seq;
 
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
@@ -2164,6 +2164,11 @@ int tcp_connect(struct sock *sk)
 	sk_charge_skb(sk, buff);
 	tp->packets_out += tcp_skb_pcount(buff);
 	tcp_transmit_skb(sk, buff, 1, GFP_KERNEL);
+	/* change tp->snd_nxt after tcp_transmit_skb() to make this packet to be
+	 * counted to tcpOutSegs
+	 */
+	tp->snd_nxt = tp->write_seq;
+	tp->pushed_seq = tp->write_seq;
 	TCP_INC_STATS(TCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the SYN until an answer. */


