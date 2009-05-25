From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Mon, 25 May 2009 09:21:42 -0700
Message-ID: <20090525162142.GC7168@linux.vnet.ibm.com>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com> <20090524214433.GH24757@kvack.org> <4A19C50B.9040304@cosmosbay.com> <20090524221240.GI24757@kvack.org> <4A19CE8B.3070302@cosmosbay.com> <20090525000050.GJ24757@kvack.org> <4A1A2AFA.8020605@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org,
	linux kernel <linux-kernel@vger.kernel.org>,
	damien.wyart@free.fr
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754110AbZEYQVo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A1A2AFA.8020605@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 25, 2009 at 07:22:02AM +0200, Eric Dumazet wrote:
> Benjamin LaHaise a =E9crit :
> > On Mon, May 25, 2009 at 12:47:39AM +0200, Eric Dumazet wrote:
> >> There is a strong dependancy against HZ
> >> BTW, I am using TREE_RCU
> >=20
> > I'm using CLASSIC_RCU.  The bisect just completed, and it points to=
 RCU. =20
> > It makes some degree of sense since I'm testing on an otherwise idl=
e=20
> > machine.  That said, where is fixing it going to make sense?  I'm n=
ot=20
> > opposed to having device unregister take a few timer ticks, but the=
re=20
> > has to be some way of exposing parallelism to the system, and since=
 the=20
> > synchronize_net() calls are done under rntl_lock(), none is possibl=
e at=20
> > present.  Hrm.
>=20
> Thanks Ben, this bisection indeed confirms how nasty synchronize_rcu(=
) is :)

Yet another step in my learning what is required of RCU, it seems!  ;-)

> Time to include Paul and lkml in the discussion, and find a better so=
lution than=20
> one provided in February.

One approach would be to convert the offending synchronize_rcu() to
call_rcu(), but if this were straightforward, I would guess that you wo=
uld
have already done this.  But if the code following the synchronize_rcu(=
)
does nothing but free up old data structures, this is an easy fix.
If there are statistics or other state involved, then call_rcu() might
not be the right tool for the job.

Another approach is to apply the patch at:

	http://lkml.org/lkml/2009/5/22/332

Then replace the offending synchronize_rcu() with synchronize_rcu_exped=
ited().
This code is still a bit on the experimental side, but tests have been
going quite well, so, unlike a week or two ago, it is definitely worth
trying out.

Do either of these approaches work for you?

							Thanx, Paul

> > 		-ben
> >=20
> > bf51935f3e988e0ed6f34b55593e5912f990750a is first bad commit
> > commit bf51935f3e988e0ed6f34b55593e5912f990750a
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date:   Tue Feb 17 06:01:30 2009 -0800
> >=20
> >     x86, rcu: fix strange load average and ksoftirqd behavior
> >    =20
> >     Damien Wyart reported high ksoftirqd CPU usage (20%) on an
> >     otherwise idle system.
> >    =20
> >     The function-graph trace Damien provided:
> > ...
> > diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process=
_32.c
> >=20
> > index a546f55..bd4da2a 100644
> > --- a/arch/x86/kernel/process_32.c
> > +++ b/arch/x86/kernel/process_32.c
> > @@ -104,9 +104,6 @@ void cpu_idle(void)
> >  			check_pgt_cache();
> >  			rmb();
> > =20
> > -			if (rcu_pending(cpu))
> > -				rcu_check_callbacks(cpu, 0);
> > -
> >  			if (cpu_is_offline(cpu))
> >  				play_dead();
> > =20
> >=20
> > --
>=20
> Paul, this commit makes net device unregister very slow (more than 10=
0 ms
>  if CONFIG_NO_HZ is set), while it used to be pretty fast in previous=
 kernels.
>=20
> Quoting Ben :=20
> " I just ran a few L2TP tests against 2.6.30-rc7, and it looks like n=
etwork=20
>   device deletion has become unusably slow.  At least in 2.6.27.10, d=
eleting=20
>   1000 network interfaces takes less than 2 seconds of real time.  Th=
e same=20
>   test run under 2.6.30-rc7 is taking hundreds of seconds to delete 1=
000=20
>   interfaces at a rate of about 5 per second.  The interfaces all sha=
re the=20
>   same local ip address, but each have a single route to a unique cli=
ent=20
>   ip address."
>=20
> Device unregister is a synchronize_rcu() abuser (three calls to disma=
ntle
> a vlan...) so delaying rcu callbacks can be pretty expensive for it.
>=20
> I wonder if the real root of the problem was not discovered in the me=
antime,
> by commit 64ca5ab913f1594ef316556e65f5eae63ff50cee
> rcu: increment quiescent state counter in ksoftirqd()
>=20
> Maybe this commit solved Damien Wyart problem as well, and we can rev=
ert
> commit bf51935f3e988e0ed6f34b55593e5912f990750a ?
>=20
> Thank you
>=20
