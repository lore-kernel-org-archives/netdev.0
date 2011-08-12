From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix RCU warning in rt_cache_seq_show
Date: Fri, 12 Aug 2011 09:23:50 +0200
Message-ID: <1313133830.2669.34.camel@edumazet-laptop>
References: <1312909360-2675-1-git-send-email-mark.rutland@arm.com>
	 <1312910336.2371.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4e424f6c.12cde30a.131e.ffffec9bSMTPIN_ADDED@mx.google.com>
	 <1313081901.3261.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110812023237.GA2372@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Gergely Kalman <synapse@hippy.csoma.elte.hu>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38565 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218Ab1HLHX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 03:23:56 -0400
Received: by wyg24 with SMTP id 24so1915316wyg.19
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2011 00:23:55 -0700 (PDT)
In-Reply-To: <20110812023237.GA2372@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 ao=C3=BBt 2011 =C3=A0 19:32 -0700, Paul E. McKenney a =C3=A9=
crit :
> On Thu, Aug 11, 2011 at 06:58:21PM +0200, Eric Dumazet wrote:
> > Le mercredi 10 ao=C3=BBt 2011 =C3=A0 10:28 +0100, Mark Rutland a =C3=
=A9crit :
> > > > -----Original Message-----
> > > > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > > > Sent: 09 August 2011 18:19
> > > > To: Mark Rutland; Paul E. McKenney
> > > > Cc: netdev@vger.kernel.org; David S. Miller; Gergely Kalman
> > > > Subject: Re: [PATCH] Fix RCU warning in rt_cache_seq_show
> > > >=20
> > > > Le mardi 09 ao=C3=BBt 2011 =C3=A0 18:02 +0100, Mark Rutland a =C3=
=A9crit :
> > > > > Commit f2c31e32 ("net: fix NULL dereferences in check_peer_re=
dir()")
> > > > > added rcu protection to dst neighbour, and updated callsites =
for
> > > > > dst_{get,set}_neighbour. Unfortunately, it missed rt_cache_se=
q_show.
> > > > >
> > > > > This produces a warning on v3.1-rc1 (on a preemptible kernel,=
 on an
> > > > > ARM Vexpress A9x4):
> > > > >
> > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> > > > > [ INFO: suspicious rcu_dereference_check() usage. ]
> > > > > ---------------------------------------------------
> > > > > include/net/dst.h:91 invoked rcu_dereference_check() without
> > > > protection!
> > > > >
> > > > > other info that might help us debug this:
> > > > >
> > > > > rcu_scheduler_active =3D 1, debug_locks =3D 0
> > > > > 2 locks held by proc01/32159:
> > > > >
> > > > > stack backtrace:
> > > > > [<80014880>] (unwind_backtrace+0x0/0xf8) from [<802e5c78>]
> > > > (rt_cache_seq_show+0x18c/0x1c4)
> > > > > [<802e5c78>] (rt_cache_seq_show+0x18c/0x1c4) from [<800e0c5c>=
]
> > > > (seq_read+0x324/0x4a4)
> > > > > [<800e0c5c>] (seq_read+0x324/0x4a4) from [<8010786c>]
> > > > (proc_reg_read+0x70/0x94)
> > > > > [<8010786c>] (proc_reg_read+0x70/0x94) from [<800c0ba8>]
> > > > (vfs_read+0xb0/0x144)
> > > > > [<800c0ba8>] (vfs_read+0xb0/0x144) from [<800c0ea8>]
> > > > (sys_read+0x40/0x70)
> > > > > [<800c0ea8>] (sys_read+0x40/0x70) from [<8000e0c0>]
> > > > (ret_fast_syscall+0x0/0x3c)
> > > > >
> > > > > This patch adds calls to rcu_read_{lock,unlock} in rt_cache_s=
eq_show,
> > > > > protecting the dereferenced variable, and clearing the warnin=
g.
> > > > >
> > > > > Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> > > > > Cc: David S. Miller <davem@davemloft.net>
> > > > > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > > > > Cc: Gergely Kalman <synapse@hippy.csoma.elte.hu>
> > > > > ---
> > > > >  net/ipv4/route.c |    2 ++
> > > > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > > > >
> > > > > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > > > > index e3dec1c..6699ef7 100644
> > > > > --- a/net/ipv4/route.c
> > > > > +++ b/net/ipv4/route.c
> > > > > @@ -419,6 +419,7 @@ static int rt_cache_seq_show(struct seq_f=
ile
> > > > *seq, void *v)
> > > > >  		struct neighbour *n;
> > > > >  		int len;
> > > > >
> > > > > +		rcu_read_lock();
> > > > >  		n =3D dst_get_neighbour(&r->dst);
> > > > >  		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
> > > > >  			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
> > > > > @@ -435,6 +436,7 @@ static int rt_cache_seq_show(struct seq_f=
ile
> > > > *seq, void *v)
> > > > >  			-1,
> > > > >  			(n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0,
> > > > >  			r->rt_spec_dst, &len);
> > > > > +		rcu_read_unlock();
> > > > >
> > > > >  		seq_printf(seq, "%*s\n", 127 - len, "");
> > > > >  	}
> > > >=20
> > > >=20
> > > > Hmm, I though rcu_read_lock_bh() (done by caller of this functi=
on) was
> > > > protecting us here.
> > >=20
> > > Aha. Being a bit trigger-happy, I'd had a quick look at the funct=
ions
> > > mentioned in the backtrace, and not looked at any possible inlini=
ng.
> > >=20
> > > This being my first real exposure to RCU, I wasn't aware of the *=
_bh
> > > variants. Looking at the documentation (Documentation/RCU/checkli=
st.txt),
> > > I think the real problem is that we should be using rcu_dereferen=
ce_bh in
> > > this case:
> > >=20
> > >   > read-side critical sections are delimited by rcu_read_lock()
> > >   > and rcu_read_unlock(), or by similar primitives such as
> > >   > rcu_read_lock_bh() and rcu_read_unlock_bh(), in which case
> > >   > the matching rcu_dereference() primitive must be used in orde=
r
> > >   > to keep lockdep happy, in this case, rcu_dereference_bh().
> >=20
> > Hmm.
> >=20
> > I do think dst_get_neighbour() should use rcu_dereference(), becaus=
e
> > dst->_neighbour are freed by call_rcu().
> >=20
> > The question is : Is following construct [A] safe or not ?
> >=20
> > {
> > rcu_read_lock_bh();
> > 	/* BH are now disabled, and we are not allowed to sleep */
> > 	...
> >=20
> > 	ptr =3D rcu_dereference();
>=20
> This should be:
>=20
> 	ptr =3D rcu_dereference_bh();
>=20
> As you say below.  Never mind!  ;-)
>=20
> > 	...
> > rcu_read_unlock_bh();
> > }
> >=20
> >=20
> > I dont really understand why lockdep wants [B] instead :
> >=20
> > {
> > rcu_read_lock_bh();
> > 	...
> >=20
> > 	{
> > 	rcu_read_lock();
> > 	ptr =3D rcu_dereference();
>=20
> Here you are protected by both RCU and RCU-bh, so you should be able
> to use either rcu_dereference() or rcu_dereference_bh().  A bit
> strange to use rcu_dereference_bh(), though.  Except perhaps if a
> pointer to a function was passed in from the outer RCU-bh read-side
> critical section or something.
>=20
> > 	rcu_read_unlock();
> > 	}
> > 	...
> > rcu_read_unlock_bh();
> > }
> >=20
> >=20
> >=20
> > However, I can understand the other way [C], this is really needed =
:
> >=20
> > {
> > rcu_read_lock();
> > 	...
> >=20
> > 	{
> > 	rcu_read_lock_bh();
> > 	ptr =3D rcu_dereference_bh();
> > 	rcu_read_unlock_bh();
> > 	}
> > 	...
> > rcu_read_unlock();
> > }
> >=20
> > I believe [A] should be allowed by lockdep.
>=20
> OK, I'll bite.  Why?
>=20

Oh well, I assumed local_bh_disable() disables preemption.

It does since day-0
add_preempt_count(SOFTIRQ_DISABLE_OFFSET);

So following should be safe :

local_bh_disable();
{
ptr =3D rcu_dereference(...);
use(ptr);
}
local_bh_enable();

Maybe they are longterm plans to break this assumption, I dont know.



