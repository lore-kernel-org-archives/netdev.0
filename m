From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 21:15:40 +0100
Message-ID: <1300738540.2837.5.camel@edumazet-laptop>
References: <20110320.195156.226769634.davem@davemloft.net>
	 <20110321125320.GA23490@elte.hu>
	 <1300714346.2884.284.camel@edumazet-laptop>
	 <20110321161528.GA28580@elte.hu> <20110321164238.GA5303@elte.hu>
	 <20110321173941.GB3892@elte.hu> <1300730838.2884.578.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56739 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384Ab1CUUQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 16:16:36 -0400
In-Reply-To: <1300730838.2884.578.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 mars 2011 =C3=A0 19:07 +0100, Eric Dumazet a =C3=A9crit :
> Le lundi 21 mars 2011 =C3=A0 18:39 +0100, Ingo Molnar a =C3=A9crit :
> > here's the same but with kallsyms enabled.
> >=20
> > Thanks,
> >=20
> > 	Ingo
> >=20
> > [    9.585627] initcall 0xffffffff81d5b806 returned 0 after 0 usecs
> > [    9.588960] calling  0xffffffff81d5b9da @ 1
> > [    9.592303] IPVS: Creating netns size=3D1272 id=3D0
> > [    9.595646] IPVS: __ip_vs_control_init(): alloc_percpu.
> > [    9.602298] IPVS: cannot register namespace.
> > [    9.605627] IPVS: can't setup control
>=20
> It seems IPVS is busted in case of memory allocation error in=20
> __ip_vs_control_init()
>=20
> IPVS deinits its "struct netns_ipvs" space, but something (in IPVS) u=
ses
> it after free.
>=20
> __ip_vs_init() seems to be called before ip_vs_init() completes
> correctly. We then keep in net->ipvs a pointer to some freed memory.
>=20
> Commit 14e405461e664b7 did some changes in this area
>=20
> Simon, any idea ?
>=20
>=20

=46or the time being, we can avoid the false memory allocation error (a=
nd
leak)

Thanks

[PATCH] ipvs: fix a typo in __ip_vs_control_init()

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
index b799cea..33733c8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3605,7 +3605,7 @@ int __net_init __ip_vs_control_init(struct net *n=
et)
=20
 	/* procfs stats */
 	ipvs->tot_stats.cpustats =3D alloc_percpu(struct ip_vs_cpu_stats);
-	if (ipvs->tot_stats.cpustats) {
+	if (!ipvs->tot_stats.cpustats) {
 		pr_err("%s(): alloc_percpu.\n", __func__);
 		return -ENOMEM;
 	}


