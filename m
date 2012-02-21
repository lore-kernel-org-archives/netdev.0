From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] neighbour: Fixed race condition at tbl->nht
Date: Tue, 21 Feb 2012 22:25:22 +0100
Message-ID: <1329859522.18384.57.camel@edumazet-laptop>
References: <1329858253.2563.51.camel@Thor>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Michel Machado <michel@digirati.com.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57071 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245Ab2BUVZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:25:27 -0500
Received: by wgbdt10 with SMTP id dt10so6070277wgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 13:25:26 -0800 (PST)
In-Reply-To: <1329858253.2563.51.camel@Thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 16:04 -0500, Michel Machado a =C3=A9=
crit :
> When the fixed race condition happens:
>=20
> 1. While function neigh_periodic_work scans the neighbor hash table
> pointed by field tbl->nht, it unlocks and locks tbl->lock between
> buckets in order to call cond_resched.
>=20
> 2. Assume that function neigh_periodic_work calls cond_resched, that =
is,
> the lock tbl->lock is available, and function neigh_hash_grow runs.
>=20
> 3. Once function neigh_hash_grow finishes, and RCU calls
> neigh_hash_free_rcu, the original struct neigh_hash_table that functi=
on
> neigh_periodic_work was using doesn't exist anymore.
>=20
> 4. Once back at neigh_periodic_work, whenever the old struct
> neigh_hash_table is accessed, things can go badly.
>=20
> Signed-off-by: Michel Machado <michel@digirati.com.br>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index e287346..2a83914 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -826,6 +826,8 @@ next_elt:
>  		write_unlock_bh(&tbl->lock);
>  		cond_resched();
>  		write_lock_bh(&tbl->lock);
> +		nht =3D rcu_dereference_protected(tbl->nht,
> +						lockdep_is_held(&tbl->lock));
>  	}
>  	/* Cycle through all hash buckets every base_reachable_time/2 ticks=
=2E
>  	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
>=20

Nice catch !

Bug introduced in 2.6.37 in commit d6bf781712a (net neigh: RCU
conversion of neigh hash table)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
