From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: TCP delayed ACK heuristic
Date: Tue, 18 Dec 2012 08:30:24 -0800
Message-ID: <1355848224.9380.30.camel@edumazet-glaptop>
References: <2088500005.27728019.1355843484620.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>, Thomas Graf <tgraf@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:49280 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202Ab2LRQhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 11:37:15 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so423488dae.17
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 08:37:14 -0800 (PST)
In-Reply-To: <2088500005.27728019.1355843484620.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 10:11 -0500, Cong Wang wrote:
> Hello, TCP experts!
> 
> Some time ago, Ben sent a patch [1] to add some knobs for
> tuning TCP delayed ACK, but rejected by David.
> 
> David's point is that we can do some heuristics for TCP
> delayed ACK, so the question is that what kind of heuristics
> can we use?
> 
> RFC1122 explicitly mentions:
> 
>             A TCP SHOULD implement a delayed ACK, but an ACK should not
>             be excessively delayed; in particular, the delay MUST be
>             less than 0.5 seconds, and in a stream of full-sized
>             segments there SHOULD be an ACK for at least every second
>             segment.
> 
> so this prevents us from using any heuristic for the number
> of coalesced delayed ACK.
> 
> For the timeout of a delayed ACK, my idea is guessing how many
> packet we suppose to receive is the TCP stream is fully utilized,
> something like below:
> 
> +static inline u32 tcp_expect_packets(struct sock *sk)
> +{
> +       struct tcp_sock *tp = tcp_sk(sk);
> +       int rtt = tp->srtt >> 3;
> +       u32 idle = tcp_time_stamp - inet_csk(sk)->icsk_ack.lrcvtime;
> +
> +       return idle * 2 / rtt;
> +}
> ...
> +       ato -= tcp_expect_packets(sk) * delta;
> 
> 
> The more we expect, the less we should delay. However this is
> not accurate due to congestion control.
> 
> Meanwhile, we can also check how many packets are pending in TCP
> sending queue, the more we pend, the more we can piggyback with
> a single ACK, but not beyond how much we are able to send at
> that time.
> 
> Comments? Ideas?
> 

ACKS might also be delayed because of bidirectional traffic, and is more
controlled by the application response time. TCP stack can not easily
estimate it.

If you focus on bulk receive, LRO/GRO should already lower number of
ACKS to an acceptable level and without major disruption.

Stretch acks are not only the receiver concern, there are issues for the
sender that you cannot always control/change.

I recommend reading RFC2525 2.13
