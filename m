From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 07:17:42 +0200
Message-ID: <49F53FF6.2040603@cosmosbay.com>
References: <20090427030433.GA17454@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41618 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbZD0FSK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 01:18:10 -0400
In-Reply-To: <20090427030433.GA17454@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Blanchard a =E9crit :
> Right now we have no upper limit on the size of the route cache hash =
table.
> On a 128GB POWER6 box it ends up as 32MB:
>=20
>     IP route cache hash table entries: 4194304 (order: 9, 33554432 by=
tes)
>=20
> It would be nice to cap this just for memory consumption reasons, but=
 this
> massive hashtable also causes a significant spike when measuring OS
> jitter.
>=20
> With a 32MB hashtable and 4 million entries, rt_worker_func is taking
> 5 ms to complete. On another system with more memory it's taking 14 m=
s.
> Even though rt_worker_func does call cond_sched() to limit its impact=
,
> in an HPC environment we want to keep all sources of OS jitter to a m=
inimum.

Then boot with rhash_entries =3D 8000 ?
or=20
echo 1 >/proc/sys/net/ipv4/route/gc_interval
>=20
> With the patch applied we limit the number of entries to 64k which
> can still be overriden by using the rt_entries boot option:
>=20
>     IP route cache hash table entries: 65536 (order: 3, 524288 bytes)
>=20
> With this patch rt_worker_func takes 0.060 ms on the same system.
>=20
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
>=20
> Is 64k a reasonable default for the limit?
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index c40debe..5064c26 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -3397,7 +3397,7 @@ int __init ip_rt_init(void)
>  					0,
>  					&rt_hash_log,
>  					&rt_hash_mask,
> -					0);
> +					rhash_entries ? 0 : 64 * 1024);
>  	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash=
_bucket));
>  	rt_hash_lock_init();
> =20
>=20


Sorry this limit is too small. Many of my customer machines would colla=
pse.

It would be smart to eventually change ip_rt_gc_interval from 60=20
to 1 second for such machines ? Dividing 5 ms per 60 gives 83 us, which
is correct.=20


