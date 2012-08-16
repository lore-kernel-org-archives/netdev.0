From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: suspicious RCU usage in xfrm_net_init()
Date: Thu, 16 Aug 2012 23:19:49 +0800
Message-ID: <20120816151949.GA18681@localhost>
References: <20120816073724.GA10660@localhost>
 <502CBF23.4070805@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Priyanka Jain <Priyanka.Jain@freescale.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <502CBF23.4070805@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fan,

On Thu, Aug 16, 2012 at 05:36:35PM +0800, Fan Du wrote:
>=20
> Hi, Fengguang
>=20
> Could you please try the below patch, see if spewing still there?
> thanks

Yes, it worked, thank you very much!

btw, your email client wraps long lines..

Thanks,
=46engguang

> From a3f86ecc3ee16ff81d49416bbf791780422988b3 Mon Sep 17 00:00:00 200=
1
> From: Fan Du <fan.du@windriver.com>
> Date: Thu, 16 Aug 2012 17:31:25 +0800
> Subject: [PATCH] Use rcu_dereference_bh to deference pointer
> protected by rcu_read_lock_bh
>=20
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/xfrm/xfrm_policy.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 5ad4d2c..75a9d6a 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2501,7 +2501,7 @@ static void __net_init
> xfrm_dst_ops_init(struct net *net)
>  	struct xfrm_policy_afinfo *afinfo;
>=20
>  	rcu_read_lock_bh();
> -	afinfo =3D rcu_dereference(xfrm_policy_afinfo[AF_INET]);
> +	afinfo =3D rcu_dereference_bh(xfrm_policy_afinfo[AF_INET]);
>  	if (afinfo)
>  		net->xfrm.xfrm4_dst_ops =3D *afinfo->dst_ops;
>  #if IS_ENABLED(CONFIG_IPV6)
> --=20
> 1.7.1
>=20
>=20
>=20
>=20
> On 2012=E5=B9=B408=E6=9C=8816=E6=97=A5 15:37, Fengguang Wu wrote:
> >Hi Priyanka,
> >
> >The below warning shows up, probably related to this commit:
> >
> >418a99ac6ad487dc9c42e6b0e85f941af56330f2 Replace rwlock on xfrm_poli=
cy_afinfo with rcu
> >
> >[    0.921216]
> >[    0.921645] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >[    0.922766] [ INFO: suspicious RCU usage. ]
> >[    0.923887] 3.5.0-01540-g1669891 #64 Not tainted
> >[    0.925123] -------------------------------
> >[    0.932860] /c/kernel-tests/src/tip/net/xfrm/xfrm_policy.c:2504 s=
uspicious rcu_dereference_check() usage!
> >[    0.935361]
> >[    0.935361] other info that might help us debug this:
> >[    0.935361]
> >[    0.937472]
> >[    0.937472] rcu_scheduler_active =3D 1, debug_locks =3D 0
> >[    0.939182] 2 locks held by swapper/1:
> >[    0.940171]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff814e1ad0>] r=
egister_pernet_subsys+0x21/0x57
> >[    0.942705]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff822c7=
329>] xfrm_net_init+0x1e4/0x437
> >[    0.951507]
> >[    0.951507] stack backtrace:
> >[    0.952660] Pid: 1, comm: swapper Not tainted 3.5.0-01540-g166989=
1 #64
> >[    0.954364] Call Trace:
> >[    0.955074]  [<ffffffff8108b375>] lockdep_rcu_suspicious+0x174/0x=
187
> >[    0.956736]  [<ffffffff822c7453>] xfrm_net_init+0x30e/0x437
> >[    0.958205]  [<ffffffff822c7329>] ? xfrm_net_init+0x1e4/0x437
> >[    0.959712]  [<ffffffff814e134a>] ops_init+0x1bb/0x1ff
> >[    0.961067]  [<ffffffff810861f9>] ? trace_hardirqs_on+0x1b/0x24
> >[    0.962644]  [<ffffffff814e17cd>] register_pernet_operations.isra=
=2E5+0x9d/0xfe
> >[    0.971376]  [<ffffffff814e1adf>] register_pernet_subsys+0x30/0x5=
7
> >[    0.972992]  [<ffffffff822c7130>] xfrm_init+0x17/0x2c
> >[    0.974316]  [<ffffffff822c2f8c>] ip_rt_init+0x82/0xe7
> >[    0.975668]  [<ffffffff822c31dc>] ip_init+0x10/0x25
> >[    0.976952]  [<ffffffff822c3f77>] inet_init+0x235/0x360
> >[    0.978352]  [<ffffffff822c3d42>] ? devinet_init+0xf2/0xf2
> >[    0.979808]  [<ffffffff82283252>] do_one_initcall+0xb4/0x203
> >[    0.981313]  [<ffffffff8228354a>] kernel_init+0x1a9/0x29a
> >[    0.982732]  [<ffffffff822826d9>] ? loglevel+0x46/0x46
> >[    0.990889]  [<ffffffff816d3d84>] kernel_thread_helper+0x4/0x10
> >[    0.992472]  [<ffffffff816d262c>] ? retint_restore_args+0x13/0x13
> >[    0.994076]  [<ffffffff822833a1>] ? do_one_initcall+0x203/0x203
> >[    0.995636]  [<ffffffff816d3d80>] ? gs_change+0x13/0x13
> >[    0.997197] TCP established hash table entries: 8192 (order: 5, 1=
31072 bytes)
> >[    1.000074] TCP bind hash table entries: 8192 (order: 7, 655360 b=
ytes)
> >
> >Thanks,
> >Fengguang
>=20
> --=20
>=20
> Love each day!
> --fan
