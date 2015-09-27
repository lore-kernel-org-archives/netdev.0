From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: Fix CWV being too strict on thin
 streams
Date: Sun, 27 Sep 2015 09:33:00 -0700
Message-ID: <1443371580.3273.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org,
	Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad
	<bro.devel+kernel@gmail.com>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34753 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbbI0QdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 12:33:03 -0400
Received: by padhy16 with SMTP id hy16so150904317pad.1
        for <netdev@vger.kernel.org>; Sun, 27 Sep 2015 09:33:03 -0700 (PDT)
In-Reply-To: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-23 at 18:49 +0200, Bendik R=C3=B8nning Opstad wrote:
> Application limited streams such as thin streams, that transmit small
> amounts of payload in relatively few packets per RTT, can be prevente=
d
> from growing the CWND when in congestion avoidance. This leads to
> increased sojourn times for data segments in streams that often trans=
mit
> time-dependent data.
>=20
> Currently, a connection is considered CWND limited only after having
> successfully transmitted at least one packet with new data, while at =
the
> same time failing to transmit some unsent data from the output queue
> because the CWND is full. Applications that produce small amounts of
> data may be left in a state where it is never considered to be CWND
> limited, because all unsent data is successfully transmitted each tim=
e
> an incoming ACK opens up for more data to be transmitted in the send
> window.
>=20
> Fix by always testing whether the CWND is fully used after successful
> packet transmissions, such that a connection is considered CWND limit=
ed
> whenever the CWND has been filled. This is the correct behavior as
> specified in RFC2861 (section 3.1).
>=20
> Cc: Andreas Petlund <apetlund@simula.no>
> Cc: Carsten Griwodz <griff@simula.no>
> Cc: Jonas Markussen <jonassm@ifi.uio.no>
> Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> Cc: Mads Johannessen <madsjoh@ifi.uio.no>
> Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com=
>
> ---
> Changes in v2:
>  - Instead of updating tp->is_cwnd_limited after failing to send
>    any packets, test whether CWND is full after successfull packet
>    transmissions.
>  - Updating commit message according to changes.
>=20
>  net/ipv4/tcp_output.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 4cd0b50..57a586f 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1827,7 +1827,7 @@ static bool tcp_tso_should_defer(struct sock *s=
k, struct sk_buff *skb,
> =20
>  	/* Ok, it looks like it is advisable to defer. */
> =20
> -	if (cong_win < send_win && cong_win < skb->len)
> +	if (cong_win < send_win && cong_win <=3D skb->len)
>  		*is_cwnd_limited =3D true;
> =20
>  	return true;
> @@ -2060,7 +2060,6 @@ static bool tcp_write_xmit(struct sock *sk, uns=
igned int mss_now, int nonagle,
> =20
>  		cwnd_quota =3D tcp_cwnd_test(tp, skb);
>  		if (!cwnd_quota) {
> -			is_cwnd_limited =3D true;
>  			if (push_one =3D=3D 2)
>  				/* Force out a loss probe pkt. */
>  				cwnd_quota =3D 1;
> @@ -2142,6 +2141,7 @@ repair:
>  		/* Send one loss probe per tail loss episode. */
>  		if (push_one !=3D 2)
>  			tcp_schedule_loss_probe(sk);
> +		is_cwnd_limited |=3D (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)=
;
>  		tcp_cwnd_validate(sk, is_cwnd_limited);
>  		return false;
>  	}

David, any idea of what happened to Bendik patch ?

https://patchwork.ozlabs.org/patch/521765

Do we need to re-submit or something ?

Thanks !
