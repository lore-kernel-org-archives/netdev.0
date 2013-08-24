From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Fri, 23 Aug 2013 23:17:56 -0400
Message-ID: <CADVnQymvQz67k1_f4rRJxPVUFWL=rM5vnT-ZO1VPSxN-E0uzDA@mail.gmail.com>
References: <1377304192.8828.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:61534 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab3HXDR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 23:17:58 -0400
Received: by mail-ea0-f180.google.com with SMTP id h10so603613eaj.11
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 20:17:57 -0700 (PDT)
In-Reply-To: <1377304192.8828.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 8:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> After hearing many people over past years complaining against TSO being
> bursty or even buggy, we are proud to present automatic sizing of TSO
> packets.
>
> One part of the problem is that tcp_tso_should_defer() uses an heuristic
> relying on upcoming ACKS instead of a timer, but more generally, having
> big TSO packets makes little sense for low rates, as it tends to create
> micro bursts on the network, and general consensus is to reduce the
> buffering amount.
>
> This patch introduces a per socket sk_pacing_rate, that approximates
> the current sending rate, and allows us to size the TSO packets so
> that we try to send one packet every ms.
>
> This field could be set by other transports.
>
> Patch has no impact for high speed flows, where having large TSO packets
> makes sense to reach line rate.
>
> For other flows, this helps better packet scheduling and ACK clocking.
>
> This patch increases performance of TCP flows in lossy environments.
>
> A new sysctl (tcp_min_tso_segs) is added, to specify the
> minimal size of a TSO packet (default being 2).
>
> A follow-up patch will provide a new packet scheduler (FQ), using
> sk_pacing_rate as an input to perform optional per flow pacing.
>
> This explains why we chose to set sk_pacing_rate to twice the current
> rate, allowing 'slow start' ramp up.
>
> sk_pacing_rate = 2 * cwnd * mss / srtt
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Van Jacobson <vanj@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---

I love this! Can't wait to play with it.

Rather than implicitly initializing sk_pacing_rate to 0, I'd suggest
maybe initializing sk_pacing_rate to a value just high enough
(TCP_INIT_CWND * mss / 1ms?) so that in the first transmit the
connection can (as it does today) construct a single TSO jumbogram of
TCP_INIT_CWND segments and send that in a single trip down through the
stack. Hopefully this should keep CPU usage advantages of TSO for
servers that spend most of their time sending replies that are 10MSS
or less, while not making the on-the-wire behavior much burstier than
it would be with the patch as it stands.

I am wondering about the aspect of the patch that sets sk_pacing_rate
to 2x the current rate in tcp_rtt_estimator and then just has to
divide by 2 again in tcp_xmit_size_goal(). It seems the 2x factor is
natural in the packet scheduler context, but at first glance it feels
to me like the multiplication by 2 should be an internal detail of the
optional scheduler, not part of the sk_pacing_rate interface between
the TCP and scheduling layer.

One thing I noticed: something about how the current patch shakes out
causes a basic 10-MSS transfer to take an extra RTT, due to the last
2-segment packet having to wait for an ACK:

# cat iw10-base-case.pkt
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4

0.200 write(4, ..., 14600) = 14600
0.300 < . 1:1(0) ack 11681 win 257

->

# ./packetdrill iw10-base-case.pkt
0.701287 cli > srv: S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
0.701367 srv > cli: S 2822928622:2822928622(0) ack 1 win 29200 <mss
1460,nop,nop,sackOK,nop,wscale 6>
0.801276 cli > srv: . ack 1 win 257
0.801365 srv > cli: . 1:2921(2920) ack 1 win 457
0.801376 srv > cli: . 2921:5841(2920) ack 1 win 457
0.801382 srv > cli: . 5841:8761(2920) ack 1 win 457
0.801386 srv > cli: . 8761:11681(2920) ack 1 win 457
0.901284 cli > srv: . ack 11681 win 257
0.901308 srv > cli: P 11681:14601(2920) ack 1 win 457

I'd try to isolate the exact cause, but it's a bit late in the evening
for me to track this down at this point, and I'll be offline tomorrow.

Thanks again. I love this...

cheers,
neal
