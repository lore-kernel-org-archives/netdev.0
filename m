From: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Wed, 23 Sep 2015 16:46:56 +0200
Message-ID: <1895025.gntjczfsS0@garfield>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com> <CADVnQy=PPe+-HP2Sm7qK6BUxbp-iKjERq7eXvR29+3R1yas7LA@mail.gmail.com> <CADVnQyn7683PoCo=PaP4CUF6CCNf+V7kCA8RdeZgZwk2SSddig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:36015 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbbIWOrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 10:47:11 -0400
Received: by lacao8 with SMTP id ao8so30324533lac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 07:47:08 -0700 (PDT)
In-Reply-To: <CADVnQyn7683PoCo=PaP4CUF6CCNf+V7kCA8RdeZgZwk2SSddig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Neal, Eric, sorry for the late replies, but keeping up with your speedy replies
is a full time job :-)

The packetdrill scripts are certainly useful to test this, so thanks for
supplying those!

On Tuesday, September 22, 2015 04:04:37 PM you wrote:
> On Tue, Sep 22, 2015 at 2:02 PM, Neal Cardwell <ncardwell@google.com> wrote:
> > More generally, my sense is that we should tweak the is_cwnd_limited code to
> > shift from saying "set is_cwnd_limited to true iff the cwnd is known to be
> > limiting transmits" to saying "set is_cwnd_limited to true iff the packets in
> > flight fill the cwnd".

A fully agree. This ensures that a failed attempt at transmitting a packet
is not required for the connection to be considered CWND limited.

> Here is a proposed patch, and a packetdrill test case based on Eric's,
> trying to capture the flavor of your Scenario 1. The test shows how
> this proposed variant allows the sender (Reno in this case, for
> simplicity) to increase cwnd each RTT in congestion avoidance, since
> the cwnd is fully utilized, even though we run out of packets to send
> and available cwnd at exactly the same moment.

This is actually very close to a variation of the patch we experimented with,
where we added a test before the call to tcp_cwnd_validate() to set
is_cwnd_limited. However, to avoid the extra procedure for every time one or
more packets are transmitted (which we presumed would be preferable for
performance) we ended up with updating the value only when no packets were sent.
If this is not a problem, then updating the value before the call to
tcp_cwnd_validate() will be better and also more correct according to RFC2861 as
you mentioned.

> Bendik, does this fix your scenario? How does this strike you as a
> potential fix?

This fixes the identified problem and is a good fix as far as our tests show.

Should I resend this as PATCH v2?

> -------------------------------------
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 4cd0b50..57a586f 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1827,7 +1827,7 @@ static bool tcp_tso_should_defer(struct sock
> *sk, struct sk_buff *skb,
> 
>         /* Ok, it looks like it is advisable to defer. */
> 
> -       if (cong_win < send_win && cong_win < skb->len)
> +       if (cong_win < send_win && cong_win <= skb->len)
>                 *is_cwnd_limited = true;
> 
>         return true;
> @@ -2060,7 +2060,6 @@ static bool tcp_write_xmit(struct sock *sk,
> unsigned int mss_now, int nonagle,
> 
>                 cwnd_quota = tcp_cwnd_test(tp, skb);
>                 if (!cwnd_quota) {
> -                       is_cwnd_limited = true;
>                         if (push_one == 2)
>                                 /* Force out a loss probe pkt. */
>                                 cwnd_quota = 1;
> @@ -2142,6 +2141,7 @@ repair:
>                 /* Send one loss probe per tail loss episode. */
>                 if (push_one != 2)
>                         tcp_schedule_loss_probe(sk);
> +               is_cwnd_limited |= (tcp_packets_in_flight(tp) >= tp->snd_cwnd);
>                 tcp_cwnd_validate(sk, is_cwnd_limited);
>                 return false;
>         }
> 
