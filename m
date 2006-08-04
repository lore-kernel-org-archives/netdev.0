From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Fri, 04 Aug 2006 08:46:13 -0400
Message-ID: <1154695575.8425.16.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:23217 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1161186AbWHDKsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:48:12 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This always correct except when do active open in tcp client, which will
send a SYN, that segment will not be counted, even if it is not
restrained. Maybe I can do following to fix this:

int tcp_connect(struct sock *sk)
...
+	tp->snd_nxt = tp->write_seq;
	TCP_SKB_CB(buff)->seq = tp->write_seq++;
	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
-	tp->snd_nxt = tp->write_seq;
-	tp->pushed_seq = tp->write_seq;

	tcp_transmit_skb(sk, buff, 1, GFP_KERNEL);
+	tp->snd_nxt = tp->write_seq;
+	tp->pushed_seq = tp->write_seq;
	TCP_INC_STATS(TCP_MIB_ACTIVEOPENS);

Do you agree with me? If It is correctly, I will send this patch soon.

On Thursday 03 August 2006 19:35, David Miller wrote:
> From: Wei Yongjun <yjwei@nanjing-fnst.com>
> Date: Thu, 03 Aug 2006 11:46:58 -0400
>
> > I modified my patch by add a flag to sacked when retransmit, and it
> > work well.
>
> This is the most timing critical code path of the TCP stack output
> packet processing, and you're adding a read-modify-write operation
> just to get some statistics correct.
>
> Let's look for a cheaper test, perhaps something like:
>
>  if (!before(TCP_SKB_CB(skb)->seq, tp->snd_nxt))
>   TCP_INC_STATS(TCP_MIB_OUTSEGS);
>
> Would that work?
>
> It should, because tp->snd_nxt always advances on new data
> via update_send_head().
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


