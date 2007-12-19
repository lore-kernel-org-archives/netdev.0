From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] net: neighbor timer power saving
Date: Wed, 19 Dec 2007 08:23:43 +0100
Message-ID: <4768C6FF.2090909@cosmosbay.com>
References: <Pine.LNX.4.64.0712181956180.3616@mini.warudkars.net> <20071218174120.4b0ef6dd@shemminger-laptop> <20071218181845.2f1b539a@shemminger-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: parag.warudkar@gmail.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:45509 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbXLSHY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 02:24:27 -0500
In-Reply-To: <20071218181845.2f1b539a@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> The neighbor GC timer runs once a second, but it doesn't need to wake
> up the machine.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/net/core/neighbour.c	2007-12-18 07:46:07.000000000 -0800
> +++ b/net/core/neighbour.c	2007-12-18 07:47:36.000000000 -0800
> @@ -270,7 +270,7 @@ static struct neighbour *neigh_alloc(str
>  	n->nud_state	  =3D NUD_NONE;
>  	n->output	  =3D neigh_blackhole;
>  	n->parms	  =3D neigh_parms_clone(&tbl->parms);
> -	init_timer(&n->timer);
> +	init_timer_deferrable(&n->timer);
>  	n->timer.function =3D neigh_timer_handler;
>  	n->timer.data	  =3D (unsigned long)n;
> =20
> @@ -740,7 +740,7 @@ static void neigh_timer_handler(unsigned
> =20
>  	state =3D neigh->nud_state;
>  	now =3D jiffies;
> -	next =3D now + HZ;
> +	next =3D round_jiffies(now + HZ);
> =20
>  	if (!(state & NUD_IN_TIMER)) {
>  #ifndef CONFIG_SMP
> @@ -1372,7 +1372,7 @@ void neigh_table_init_no_netlink(struct=20
>  	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
> =20
>  	rwlock_init(&tbl->lock);
> -	init_timer(&tbl->gc_timer);
> +	init_timer_deferrable(&tbl->gc_timer);
>  	tbl->gc_timer.data     =3D (unsigned long)tbl;
>  	tbl->gc_timer.function =3D neigh_periodic_timer;
>  	tbl->gc_timer.expires  =3D now + 1;

I wonder if this deferrable timer thing is the right way to go.

(like read_mostly thing if you want :) )

We are going to convert 99% timers to deferrable.

Maybe the right move should be to have the reverse attribute, to mark a=
 timer=20
as non deferrable...

Also, why use round_jiffies() on a deferrable timer ? That sounds unece=
ssary ?

