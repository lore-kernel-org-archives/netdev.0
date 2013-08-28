From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3 net-next] tcp: TSO packets automatic sizing
Date: Tue, 27 Aug 2013 20:21:57 -0400
Message-ID: <CADVnQynTEFReoQE9vX-6ipbtC37gAe++N4KduxNdY6FfH=zgFw@mail.gmail.com>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	<1377491162.8828.116.camel@edumazet-glaptop>
	<1377607592.8828.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:37688 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051Ab3H1AV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 20:21:58 -0400
Received: by mail-ea0-f174.google.com with SMTP id z15so2607929ead.33
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 17:21:57 -0700 (PDT)
In-Reply-To: <1377607592.8828.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 8:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
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
> v2: Neal Cardwell reported a suspect deferring of last two segments on
> initial write of 10 MSS, I had to change tcp_tso_should_defer() to take
> into account tp->xmit_size_goal_segs
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Van Jacobson <vanj@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
> v3: The change Yuchung suggested added a possibility of a divide by 0:
>     On some (retransmits) case, srtt can be 0 because
>     tcp_rtt_estimator() has not yet been called.
>     Change the computation to remove this, and do not yet use usec
>     as the units, but HZ. [ Its interesting to see jiffies_to_usecs()
>     being an out of line function :( ]
>
> This version passed all our tests.
>
>  Documentation/networking/ip-sysctl.txt |    9 ++++++
>  include/net/sock.h                     |    2 +
>  include/net/tcp.h                      |    1
>  net/ipv4/sysctl_net_ipv4.c             |   10 +++++++
>  net/ipv4/tcp.c                         |   28 ++++++++++++++++----
>  net/ipv4/tcp_input.c                   |   32 ++++++++++++++++++++++-
>  net/ipv4/tcp_output.c                  |    2 -
>  7 files changed, 77 insertions(+), 7 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
