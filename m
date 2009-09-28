From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] get rid of read/write lock in gen_estimator
Date: Mon, 28 Sep 2009 20:50:28 +0200
Message-ID: <4AC10574.6070406@gmail.com>
References: <20090928113855.52eab44b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40597 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbZI1Su2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 14:50:28 -0400
In-Reply-To: <20090928113855.52eab44b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Don't need a read/write lock here sinc there already is a spin lock t=
hat
> is being acquired.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/net/core/gen_estimator.c	2009-09-24 16:27:01.239755070 -0700
> +++ b/net/core/gen_estimator.c	2009-09-24 16:41:09.290751273 -0700
> @@ -101,9 +101,6 @@ struct gen_estimator_head
> =20
>  static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
> =20
> -/* Protects against NULL dereference */
> -static DEFINE_RWLOCK(est_lock);
> -
>  /* Protects against soft lockup during large deletion */
>  static struct rb_root est_root =3D RB_ROOT;
> =20
> @@ -118,9 +115,8 @@ static void est_timer(unsigned long arg)
>  		u64 brate;
>  		u32 npackets;
>  		u32 rate;
> -
> +
>  		spin_lock(e->stats_lock);
> -		read_lock(&est_lock);
>  		if (e->bstats =3D=3D NULL)
>  			goto skip;
> =20
> @@ -136,7 +132,6 @@ static void est_timer(unsigned long arg)
>  		e->avpps +=3D (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
>  		e->rate_est->pps =3D (e->avpps+0x1FF)>>10;
>  skip:
> -		read_unlock(&est_lock);
>  		spin_unlock(e->stats_lock);
>  	}
> =20
> @@ -270,9 +265,9 @@ void gen_kill_estimator(struct gnet_stat
>  	while ((e =3D gen_find_node(bstats, rate_est))) {
>  		rb_erase(&e->node, &est_root);
> =20
> -		write_lock_bh(&est_lock);
> +		spin_lock(e->stats_lock);

Are you sure _bh() variant is not needed here ?

>  		e->bstats =3D NULL;
> -		write_unlock_bh(&est_lock);
> +		spin_unlock(e->stats_lock);
> =20
>  		list_del_rcu(&e->list);
>  		call_rcu(&e->e_rcu, __gen_kill_estimator);

