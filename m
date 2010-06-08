From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 2.6.35-rc2-git1 - lib/idr.c:605 invoked rcu_dereference_check()
	without protection!
Date: Tue, 8 Jun 2010 00:28:15 -0400
Message-ID: <AANLkTikPcIzd_gQ3XVT8zdy2Gyxibx3wx_twlaxJA3cz@mail.gmail.com>
References: <AANLkTim06fRB-Kvm12v2umq8MxRxbcl3gdbNsiRTDmia@mail.gmail.com>
	<20100608001234.GE2387@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100608001234.GE2387@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 7, 2010 at 8:12 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Mon, Jun 07, 2010 at 02:23:17PM -0400, Miles Lane wrote:
>> [ =A0 =A02.677955] [ INFO: suspicious rcu_dereference_check() usage.=
 ]
>> [ =A0 =A02.679089] -------------------------------------------------=
--
>> [ =A0 =A02.680276] lib/idr.c:605 invoked rcu_dereference_check() wit=
hout protection!
>> [ =A0 =A02.681499]
>> [ =A0 =A02.681500] other info that might help us debug this:
>> [ =A0 =A02.681501]
>> [ =A0 =A02.685509]
>> [ =A0 =A02.685510] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> [ =A0 =A02.688221] 1 lock held by swapper/1:
>> [ =A0 =A02.689587] =A0#0: =A0(mtd_table_mutex){+.+...}, at:
>> [<ffffffff812bea45>] register_mtd_user+0x1a/0x69
>> [ =A0 =A02.691096]
>> [ =A0 =A02.691098] stack backtrace:
>> [ =A0 =A02.694059] Pid: 1, comm: swapper Not tainted 2.6.35-rc2-git1=
 #8
>> [ =A0 =A02.695601] Call Trace:
>> [ =A0 =A02.697243] =A0[<ffffffff81064e9c>] lockdep_rcu_dereference+0=
x9d/0xa5
>> [ =A0 =A02.698868] =A0[<ffffffff811b9c86>] idr_get_next+0x60/0x124
>> [ =A0 =A02.700556] =A0[<ffffffff812be779>] __mtd_next_device+0x1b/0x=
1d
>> [ =A0 =A02.702238] =A0[<ffffffff812bea7c>] register_mtd_user+0x51/0x=
69
>> [ =A0 =A02.703964] =A0[<ffffffff816cca45>] init_mtdchar+0xb3/0xd3
>> [ =A0 =A02.705686] =A0[<ffffffff816cc992>] ? init_mtdchar+0x0/0xd3
>> [ =A0 =A02.707470] =A0[<ffffffff810001ef>] do_one_initcall+0x59/0x14=
e
>> [ =A0 =A02.709255] =A0[<ffffffff816a768a>] kernel_init+0x144/0x1ce
>> [ =A0 =A02.711082] =A0[<ffffffff81003054>] kernel_thread_helper+0x4/=
0x10
>> [ =A0 =A02.712862] =A0[<ffffffff813ca480>] ? restore_args+0x0/0x30
>> [ =A0 =A02.714647] =A0[<ffffffff816a7546>] ? kernel_init+0x0/0x1ce
>> [ =A0 =A02.716415] =A0[<ffffffff81003050>] ? kernel_thread_helper+0x=
0/0x10
>
> This looks like a new one! =A0Does the following patch take care of i=
t?
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Thanx, Paul
>
> ---------------------------------------------------------------------=
---
>
> commit 2d54a6c31b72c902b09d365e9c66205a5c07e549
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date: =A0 Mon Jun 7 17:09:45 2010 -0700
>
> =A0 =A0idr: fix RCU lockdep splat in idr_get_next()
>
> =A0 =A0Convert to rcu_dereference_raw() given that many callers may h=
ave many
> =A0 =A0different locking models.
>
> =A0 =A0Located-by: Miles Lane <miles.lane@gmail.com>
> =A0 =A0Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>
> diff --git a/lib/idr.c b/lib/idr.c
> index 2eb1dca..f099f25 100644
> --- a/lib/idr.c
> +++ b/lib/idr.c
> @@ -599,7 +599,7 @@ void *idr_get_next(struct idr *idp, int *nextidp)
> =A0 =A0 =A0 =A0/* find first ent */
> =A0 =A0 =A0 =A0n =3D idp->layers * IDR_BITS;
> =A0 =A0 =A0 =A0max =3D 1 << n;
> - =A0 =A0 =A0 p =3D rcu_dereference(idp->top);
> + =A0 =A0 =A0 p =3D rcu_dereference_raw(idp->top);
> =A0 =A0 =A0 =A0if (!p)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> @@ -607,7 +607,7 @@ void *idr_get_next(struct idr *idp, int *nextidp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (n > 0 && p) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0n -=3D IDR_BITS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*paa++ =3D p;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D rcu_dereference(p=
->ary[(id >> n) & IDR_MASK]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D rcu_dereference_r=
aw(p->ary[(id >> n) & IDR_MASK]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (p) {
>

Tested.  Looks good!
