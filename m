From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] tcp: limit GSO packets to half cwnd
Date: Thu, 13 Nov 2014 10:16:49 -0800
Message-ID: <CAA93jw5PiV+zvodgQRbrHMR4FJzTFeHScntxPFt7Owx8eLJrxw@mail.gmail.com>
References: <1415900722.17262.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:49782 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932648AbaKMSQu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 13:16:50 -0500
Received: by mail-ob0-f172.google.com with SMTP id vb8so1306573obc.3
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 10:16:50 -0800 (PST)
In-Reply-To: <1415900722.17262.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 9:45 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In DC world, GSO packets initially cooked by tcp_sendmsg() are usuall=
y
> big, as sk_pacing_rate is high.
>
> When network is congested, cwnd can be smaller than the GSO packets
> found in socket write queue. tcp_write_xmit() splits GSO packets
> using the available cwnd, and we end up sending a single GSO packet,
> consuming all available cwnd.

My take on this is that this will also help reduce inter-flow latency
on devices that are running GSO at 100Mbit or lower speeds.  (?)

I have really liked many of the patches entering netdev in this cycle!
(could this be a tunable instead to split on 1/4th for example?)

That does not prevent me from wishing, abstractly, to strand all the
tcp development orgs of the world on a tropic island with a 10mbit
uplink, or on a gbus, endlessly circling san francisco... until more
low bandwidth with high latency problems are resolved.

:)

> With GRO aggregation on the receiver, we might handle a single GRO
> packet, sending back a single ACK.
>
> 1) This single ACK might be lost
>    TLP or RTO are forced to attempt a retransmit.
> 2) This ACK releases a full cwnd, sender sends another big GSO packet=
,
>    in a ping pong mode.
>
> This behavior does not fill the pipes in the best way, because of
> scheduling artifacts.
>
> Make sure we always have at least two GSO packets in flight.
>
> This allows us to safely increase GRO efficiency without risking
> spurious retransmits.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_output.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 0b88158dd4a70d5007e79f0d8251fee2f7c6c7f8..eb73a1dccf56b823a45c0=
ca034e40dc50fc48068 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1562,7 +1562,7 @@ static unsigned int tcp_mss_split_point(const s=
truct sock *sk,
>  static inline unsigned int tcp_cwnd_test(const struct tcp_sock *tp,
>                                          const struct sk_buff *skb)
>  {
> -       u32 in_flight, cwnd;
> +       u32 in_flight, cwnd, halfcwnd;
>
>         /* Don't be strict about the congestion window for the final =
=46IN.  */
>         if ((TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) &&
> @@ -1571,10 +1571,14 @@ static inline unsigned int tcp_cwnd_test(cons=
t struct tcp_sock *tp,
>
>         in_flight =3D tcp_packets_in_flight(tp);
>         cwnd =3D tp->snd_cwnd;
> -       if (in_flight < cwnd)
> -               return (cwnd - in_flight);
> +       if (in_flight >=3D cwnd)
> +               return 0;
>
> -       return 0;
> +       /* For better scheduling, ensure we have at least
> +        * 2 GSO packets in flight.
> +        */
> +       halfcwnd =3D max(cwnd >> 1, 1U);
> +       return min(halfcwnd, cwnd - in_flight);
>  }
>
>  /* Initialize TSO state of a skb.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
