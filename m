From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Tue, 5 Feb 2013 14:49:04 -0500
Message-ID: <CADVnQymufg8YFCg3cBQzTW-WbYRYpG=FVqtd-A5tLUU=Uex_eg@mail.gmail.com>
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
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-1?Q?Pasi_K=E4rkk=E4inen?= <pasik@iki.fi>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:47054 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756282Ab3BETtG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:49:06 -0500
Received: by mail-we0-f181.google.com with SMTP id t44so481556wey.40
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 11:49:05 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1302041327210.4561@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 4, 2013 at 7:14 AM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
> [PATCH 1/1] tcp: fix for zero packets_in_flight was too broad
>
> There are transients during normal FRTO procedure during which
> the packets_in_flight can go to zero between write_queue state
> updates and firing the resulting segments out. As FRTO processing
> occurs during that window the check must be more precise to
> not match "spuriously" :-). More specificly, e.g., when
> packets_in_flight is zero but FLAG_DATA_ACKED is true the problematic
> branch that set cwnd into zero would not be taken and new segments
> might be sent out later.
>
> Only compile tested.
>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Pasi K=E4rkk=E4inen <pasik@iki.fi>
> ---
>  net/ipv4/tcp_input.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 680c422..500c2da 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3484,8 +3484,7 @@ static bool tcp_process_frto(struct sock *sk, i=
nt flag)
>             ((tp->frto_counter >=3D 2) && (flag & FLAG_RETRANS_DATA_A=
CKED)))
>                 tp->undo_marker =3D 0;
>
> -       if (!before(tp->snd_una, tp->frto_highmark) ||
> -           !tcp_packets_in_flight(tp)) {
> +       if (!before(tp->snd_una, tp->frto_highmark)) {
>                 tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? =
2 : 3), flag);
>                 return true;
>         }
> @@ -3505,6 +3504,11 @@ static bool tcp_process_frto(struct sock *sk, =
int flag)
>                 }
>         } else {
>                 if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter =3D=
=3D 1)) {
> +                       if (!tcp_packets_in_flight(tp)) {
> +                               tcp_enter_frto_loss(sk, 2, flag);
> +                               return true;
> +                       }
> +
>                         /* Prevent sending of new data. */
>                         tp->snd_cwnd =3D min(tp->snd_cwnd,
>                                            tcp_packets_in_flight(tp))=
;
> --

Acked-by: Neal Cardwell <ncardwell@google.com>
