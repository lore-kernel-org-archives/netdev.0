From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Sun, 06 Aug 2006 23:17:37 -0400
Message-ID: <1154920659.3388.4.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:50104 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1750904AbWHGCYt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 22:24:49 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch has been fixed.

On Friday 04 August 2006 07:23, David Miller wrote:
> From: Wei Yongjun <yjwei@nanjing-fnst.com>
> Date: Fri, 04 Aug 2006 08:46:13 -0400
>
> > This always correct except when do active open in tcp client, which
will
> > send a SYN, that segment will not be counted, even if it is not
> > restrained. Maybe I can do following to fix this:
> >
> >
> > Do you agree with me? If It is correctly, I will send this patch
soon.
>
> This looks fine and should work.
>
> Please add some comments in tcp_connect() explaining the ordering of
> assignments, so that a future developer does not break things by
> accident.

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- a/net/ipv4/tcp_output.c	2006-08-03 18:05:22.425081936 -0400
+++ b/net/ipv4/tcp_output.c	2006-08-07 09:48:41.186372896 -0400
@@ -462,7 +462,8 @@ static int tcp_transmit_skb(struct sock 
 	if (skb->len != tcp_header_size)
 		tcp_event_data_sent(tp, skb, sk);
 
-	TCP_INC_STATS(TCP_MIB_OUTSEGS);
+	if(!before(tcb->seq, tp->snd_nxt))
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


