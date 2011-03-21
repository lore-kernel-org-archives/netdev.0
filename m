From: Simon Horman <horms@verge.net.au>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Tue, 22 Mar 2011 08:29:21 +0900
Message-ID: <20110321232921.GG22625@verge.net.au>
References: <20110320.195156.226769634.davem@davemloft.net>
 <20110321125320.GA23490@elte.hu>
 <1300714346.2884.284.camel@edumazet-laptop>
 <20110321161528.GA28580@elte.hu>
 <20110321164238.GA5303@elte.hu>
 <20110321173941.GB3892@elte.hu>
 <1300730838.2884.578.camel@edumazet-laptop>
 <1300738540.2837.5.camel@edumazet-laptop>
 <20110321221357.GF22625@verge.net.au>
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
Received: from kirsty.vergenet.net ([202.4.237.240]:46466 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293Ab1CUX32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 19:29:28 -0400
Content-Disposition: inline
In-Reply-To: <20110321221357.GF22625@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 07:13:58AM +0900, Simon Horman wrote:
> On Mon, Mar 21, 2011 at 09:15:40PM +0100, Eric Dumazet wrote:
> > Le lundi 21 mars 2011 =C3=A0 19:07 +0100, Eric Dumazet a =C3=A9crit=
 :
> > > Le lundi 21 mars 2011 =C3=A0 18:39 +0100, Ingo Molnar a =C3=A9cri=
t :
> > > > here's the same but with kallsyms enabled.
> > > >=20
> > > > Thanks,
> > > >=20
> > > > 	Ingo
> > > >=20
> > > > [    9.585627] initcall 0xffffffff81d5b806 returned 0 after 0 u=
secs
> > > > [    9.588960] calling  0xffffffff81d5b9da @ 1
> > > > [    9.592303] IPVS: Creating netns size=3D1272 id=3D0
> > > > [    9.595646] IPVS: __ip_vs_control_init(): alloc_percpu.
> > > > [    9.602298] IPVS: cannot register namespace.
> > > > [    9.605627] IPVS: can't setup control
> > >=20
> > > It seems IPVS is busted in case of memory allocation error in=20
> > > __ip_vs_control_init()
> > >=20
> > > IPVS deinits its "struct netns_ipvs" space, but something (in IPV=
S) uses
> > > it after free.
> > >=20
> > > __ip_vs_init() seems to be called before ip_vs_init() completes
> > > correctly. We then keep in net->ipvs a pointer to some freed memo=
ry.
> > >=20
> > > Commit 14e405461e664b7 did some changes in this area
> > >=20
> > > Simon, any idea ?
> > >=20
> > >=20
> >=20
> > For the time being, we can avoid the false memory allocation error =
(and
> > leak)
>=20
> Sorry, that typo is my work.

With your patch applied I now see the following

ffff880003bbf1a0 corresponds to &ipvs->app_key in __ip_vs_app_init().
I'll continue looking into this.

[   12.610000] IPVS: Creating netns size=3D2456 id=3D0
[   12.630000] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   12.640000] BUG: key ffff880003bbf1a0 not in .data!
[   12.640000] ------------[ cut here ]------------
[   12.640000] WARNING: at kernel/lockdep.c:2701
lockdep_init_map+0x37b/0x570()
[   12.640000] Hardware name: Bochs
[   12.640000] Pid: 1, comm: swapper Tainted: G        W
2.6.38-kexec-06330-g69b7efe-dirty #122
[   12.650000] Call Trace:
[   12.650000]  [<ffffffff8102e685>] warn_slowpath_common+0x75/0xb0
[   12.650000]  [<ffffffff8102e6d5>] warn_slowpath_null+0x15/0x20
[   12.650000]  [<ffffffff8105967b>] lockdep_init_map+0x37b/0x570
[   12.650000]  [<ffffffff8105829d>] ? trace_hardirqs_on+0xd/0x10
[   12.650000]  [<ffffffff81055ad8>] debug_mutex_init+0x38/0x50
[   12.650000]  [<ffffffff8104bc4c>] __mutex_init+0x5c/0x70
[   12.650000]  [<ffffffff81685ee7>] __ip_vs_app_init+0x64/0x86
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.660000]  [<ffffffff811b1c33>] T.620+0x43/0x170
[   12.660000]  [<ffffffff811b1e9a>] ? register_pernet_subsys+0x1a/0x40
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.660000]  [<ffffffff811b1db7>] register_pernet_operations+0x57/0x=
b0
[   12.660000]  [<ffffffff81685a3b>] ? ip_vs_init+0x0/0xff
[   12.670000]  [<ffffffff811b1ea9>] register_pernet_subsys+0x29/0x40
[   12.670000]  [<ffffffff81685f19>] ip_vs_app_init+0x10/0x12
[   12.670000]  [<ffffffff81685a87>] ip_vs_init+0x4c/0xff
[   12.670000]  [<ffffffff8166562c>] do_one_initcall+0x7a/0x12e
[   12.670000]  [<ffffffff8166583e>] kernel_init+0x13e/0x1c2
[   12.670000]  [<ffffffff8128c134>] kernel_thread_helper+0x4/0x10
[   12.670000]  [<ffffffff8128ad40>] ? restore_args+0x0/0x30
[   12.680000]  [<ffffffff81665700>] ? kernel_init+0x0/0x1c2
[   12.680000]  [<ffffffff8128c130>] ? kernel_thread_helper+0x0/0x10
[   12.680000] ---[ end trace 4eaa2a86a8e2da23 ]---

