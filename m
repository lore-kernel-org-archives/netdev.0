From: Simon Horman <horms@verge.net.au>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Tue, 22 Mar 2011 07:13:58 +0900
Message-ID: <20110321221357.GF22625@verge.net.au>
References: <20110320.195156.226769634.davem@davemloft.net>
 <20110321125320.GA23490@elte.hu>
 <1300714346.2884.284.camel@edumazet-laptop>
 <20110321161528.GA28580@elte.hu>
 <20110321164238.GA5303@elte.hu>
 <20110321173941.GB3892@elte.hu>
 <1300730838.2884.578.camel@edumazet-laptop>
 <1300738540.2837.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48379 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601Ab1CUWOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 18:14:08 -0400
Content-Disposition: inline
In-Reply-To: <1300738540.2837.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2011 at 09:15:40PM +0100, Eric Dumazet wrote:
> Le lundi 21 mars 2011 =C3=A0 19:07 +0100, Eric Dumazet a =C3=A9crit :
> > Le lundi 21 mars 2011 =C3=A0 18:39 +0100, Ingo Molnar a =C3=A9crit =
:
> > > here's the same but with kallsyms enabled.
> > >=20
> > > Thanks,
> > >=20
> > > 	Ingo
> > >=20
> > > [    9.585627] initcall 0xffffffff81d5b806 returned 0 after 0 use=
cs
> > > [    9.588960] calling  0xffffffff81d5b9da @ 1
> > > [    9.592303] IPVS: Creating netns size=3D1272 id=3D0
> > > [    9.595646] IPVS: __ip_vs_control_init(): alloc_percpu.
> > > [    9.602298] IPVS: cannot register namespace.
> > > [    9.605627] IPVS: can't setup control
> >=20
> > It seems IPVS is busted in case of memory allocation error in=20
> > __ip_vs_control_init()
> >=20
> > IPVS deinits its "struct netns_ipvs" space, but something (in IPVS)=
 uses
> > it after free.
> >=20
> > __ip_vs_init() seems to be called before ip_vs_init() completes
> > correctly. We then keep in net->ipvs a pointer to some freed memory=
=2E
> >=20
> > Commit 14e405461e664b7 did some changes in this area
> >=20
> > Simon, any idea ?
> >=20
> >=20
>=20
> For the time being, we can avoid the false memory allocation error (a=
nd
> leak)

Sorry, that typo is my work.

> Thanks
>=20
> [PATCH] ipvs: fix a typo in __ip_vs_control_init()
>=20
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_v=
s_ctl.c
> index b799cea..33733c8 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3605,7 +3605,7 @@ int __net_init __ip_vs_control_init(struct net =
*net)
> =20
>  	/* procfs stats */
>  	ipvs->tot_stats.cpustats =3D alloc_percpu(struct ip_vs_cpu_stats);
> -	if (ipvs->tot_stats.cpustats) {
> +	if (!ipvs->tot_stats.cpustats) {
>  		pr_err("%s(): alloc_percpu.\n", __func__);
>  		return -ENOMEM;
>  	}
>=20
>=20
