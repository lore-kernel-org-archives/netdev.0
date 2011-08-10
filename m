From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Fix RCU warning in rt_cache_seq_show
Date: Tue, 9 Aug 2011 18:11:06 -0700
Message-ID: <20110810011106.GD2737@linux.vnet.ibm.com>
References: <1312909360-2675-1-git-send-email-mark.rutland@arm.com>
 <1312910336.2371.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Gergely Kalman <synapse@hippy.csoma.elte.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44791 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526Ab1HJBLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 21:11:08 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7A0fZSa029661
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2011 20:41:35 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7A1B7rh271550
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2011 21:11:07 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7A1B6CX006719
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2011 21:11:07 -0400
Content-Disposition: inline
In-Reply-To: <1312910336.2371.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2011 at 07:18:56PM +0200, Eric Dumazet wrote:
> Le mardi 09 ao=FBt 2011 =E0 18:02 +0100, Mark Rutland a =E9crit :
> > Commit f2c31e32 ("net: fix NULL dereferences in check_peer_redir()"=
)
> > added rcu protection to dst neighbour, and updated callsites for
> > dst_{get,set}_neighbour. Unfortunately, it missed rt_cache_seq_show=
=2E
> >=20
> > This produces a warning on v3.1-rc1 (on a preemptible kernel, on an
> > ARM Vexpress A9x4):
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> > [ INFO: suspicious rcu_dereference_check() usage. ]
> > ---------------------------------------------------
> > include/net/dst.h:91 invoked rcu_dereference_check() without protec=
tion!
> >=20
> > other info that might help us debug this:
> >=20
> > rcu_scheduler_active =3D 1, debug_locks =3D 0
> > 2 locks held by proc01/32159:

This is very strange.  It says that there are two locks held by the
task, but refuses to list them.  Maybe something stomped on the list
of held locks?

							Thanx, Paul

> > stack backtrace:
> > [<80014880>] (unwind_backtrace+0x0/0xf8) from [<802e5c78>] (rt_cach=
e_seq_show+0x18c/0x1c4)
> > [<802e5c78>] (rt_cache_seq_show+0x18c/0x1c4) from [<800e0c5c>] (seq=
_read+0x324/0x4a4)
> > [<800e0c5c>] (seq_read+0x324/0x4a4) from [<8010786c>] (proc_reg_rea=
d+0x70/0x94)
> > [<8010786c>] (proc_reg_read+0x70/0x94) from [<800c0ba8>] (vfs_read+=
0xb0/0x144)
> > [<800c0ba8>] (vfs_read+0xb0/0x144) from [<800c0ea8>] (sys_read+0x40=
/0x70)
> > [<800c0ea8>] (sys_read+0x40/0x70) from [<8000e0c0>] (ret_fast_sysca=
ll+0x0/0x3c)
> >=20
> > This patch adds calls to rcu_read_{lock,unlock} in rt_cache_seq_sho=
w,
> > protecting the dereferenced variable, and clearing the warning.
> >=20
> > Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Gergely Kalman <synapse@hippy.csoma.elte.hu>
> > ---
> >  net/ipv4/route.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index e3dec1c..6699ef7 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -419,6 +419,7 @@ static int rt_cache_seq_show(struct seq_file *s=
eq, void *v)
> >  		struct neighbour *n;
> >  		int len;
> > =20
> > +		rcu_read_lock();
> >  		n =3D dst_get_neighbour(&r->dst);
> >  		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
> >  			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
> > @@ -435,6 +436,7 @@ static int rt_cache_seq_show(struct seq_file *s=
eq, void *v)
> >  			-1,
> >  			(n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0,
> >  			r->rt_spec_dst, &len);
> > +		rcu_read_unlock();
> > =20
> >  		seq_printf(seq, "%*s\n", 127 - len, "");
> >  	}
>=20
>=20
> Hmm, I though rcu_read_lock_bh() (done by caller of this function) wa=
s
> protecting us here.
>=20
>=20
> Paul, is it really needed, or is it a lockdep artifact ?
>=20
>=20
>=20
>=20
>=20
