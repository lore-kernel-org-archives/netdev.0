From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Mon, 04 Feb 2013 07:07:41 -0800
Message-ID: <1359990461.30177.142.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	  <20130123214445.GA16641@order.stressinduktion.org>
	  <20130123215151.GF8912@reaktio.net>
	  <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	  <20130123234116.GC16641@order.stressinduktion.org>
	 <1358984831.12374.1227.camel@edumazet-glaptop>
	  <20130124135120.GD16641@order.stressinduktion.org>
	  <1359777110.30177.58.camel@edumazet-glaptop>
	  <20130202142832.GP8912@reaktio.net>
	  <1359818075.30177.78.camel@edumazet-glaptop>
	 <CADVnQykbufy-kQrEnJm0bbt=n7C8OfE1=Kr-2KfP7Mbu5Eq58w@mail.gmail.com>
	  <1359826377.30177.86.camel@edumazet-glaptop>
	 <1359918785.30177.111.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1302041327210.4561@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:53128 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab3BDPHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 10:07:44 -0500
Received: by mail-da0-f50.google.com with SMTP id h15so2717710dan.23
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 07:07:43 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1302041327210.4561@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-04 at 14:14 +0200, Ilpo J=C3=A4rvinen wrote:
> On Sun, 3 Feb 2013, Eric Dumazet wrote:
>=20
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > Commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start())
> > uncovered a bug in FRTO code :
> > tcp_process_frto() is setting snd_cwnd to 0 if the number
> > of in flight packets is 0.
> >=20
> > As Neal pointed out, if no packet is in flight we lost our
> > chance to disambiguate whether a loss timeout was spurious.
> >=20
> > We should assume it was a proper loss.
> >=20
> > Reported-by: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>
> > Signed-off-by: Neal Cardwell <ncardwell@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > ---
> >  net/ipv4/tcp_input.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 8aca4ee..680c422 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -3484,7 +3484,8 @@ static bool tcp_process_frto(struct sock *sk,=
 int flag)
> >  	    ((tp->frto_counter >=3D 2) && (flag & FLAG_RETRANS_DATA_ACKED=
)))
> >  		tp->undo_marker =3D 0;
> > =20
> > -	if (!before(tp->snd_una, tp->frto_highmark)) {
> > +	if (!before(tp->snd_una, tp->frto_highmark) ||
> > +	    !tcp_packets_in_flight(tp)) {
>=20
> I think this condition becomes now too broad because there is transie=
nt
> during FRTO. I think the patch below would be enough to resolve this,
> what do you think?
>=20
> --
> [PATCH 1/1] tcp: fix for zero packets_in_flight was too broad
>=20
> There are transients during normal FRTO procedure during which
> the packets_in_flight can go to zero between write_queue state
> updates and firing the resulting segments out. As FRTO processing
> occurs during that window the check must be more precise to
> not match "spuriously" :-). More specificly, e.g., when
> packets_in_flight is zero but FLAG_DATA_ACKED is true the problematic
> branch that set cwnd into zero would not be taken and new segments
> might be sent out later.
>=20
> Only compile tested.
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi>
> ---
>  net/ipv4/tcp_input.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 680c422..500c2da 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3484,8 +3484,7 @@ static bool tcp_process_frto(struct sock *sk, i=
nt flag)
>  	    ((tp->frto_counter >=3D 2) && (flag & FLAG_RETRANS_DATA_ACKED))=
)
>  		tp->undo_marker =3D 0;
> =20
> -	if (!before(tp->snd_una, tp->frto_highmark) ||
> -	    !tcp_packets_in_flight(tp)) {
> +	if (!before(tp->snd_una, tp->frto_highmark)) {
>  		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 2 : 3), flag)=
;
>  		return true;
>  	}
> @@ -3505,6 +3504,11 @@ static bool tcp_process_frto(struct sock *sk, =
int flag)
>  		}
>  	} else {
>  		if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter =3D=3D 1)) {
> +			if (!tcp_packets_in_flight(tp)) {
> +				tcp_enter_frto_loss(sk, 2, flag);
> +				return true;
> +			}
> +			=09
>  			/* Prevent sending of new data. */
>  			tp->snd_cwnd =3D min(tp->snd_cwnd,
>  					   tcp_packets_in_flight(tp));

Thanks Ilpo.

I'll be able to test your patch under load only in ~8 hours.
