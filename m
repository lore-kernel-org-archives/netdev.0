From: Benjamin Block <bebl@mageta.org>
Subject: Re: [PATCH] net: ipv6: fib: don't sleep inside atomic lock
Date: Thu, 21 Aug 2014 16:31:03 +0200
Message-ID: <20140821143103.GA25021@kalium.Speedport_W723_V_Typ_A_1_01_001>
References: <1408551366-24237-1-git-send-email-bebl@mageta.org>
 <1408625680.5817.9.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408625680.5817.9.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 14:54 Thu 21 Aug     , Hannes Frederic Sowa wrote:
> On Mi, 2014-08-20 at 18:16 +0200, Benjamin Block wrote:
> > The function fib6_commit_metrics() allocates a piece of memory in mode
> > GFP_KERNEL while holding an atomic lock from higher up in the stack, in
> > the function __ip6_ins_rt(). This produces the following BUG:
> >=20
> > > BUG: sleeping function called from invalid context at mm/slub.c:1250
> > > in_atomic(): 1, irqs_disabled(): 0, pid: 2909, name: dhcpcd
> > > 2 locks held by dhcpcd/2909:
> > >  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81978e67>] rtnl_lock+0x17/0=
x20
> > >  #1:  (&tb->tb6_lock){++--+.}, at: [<ffffffff81a6951a>] ip6_route_add=
+0x65a/0x800
> > > CPU: 1 PID: 2909 Comm: dhcpcd Not tainted 3.17.0-rc1 #1
> > > Hardware name: ASUS All Series/Q87T, BIOS 0216 10/16/2013
> > >  0000000000000008 ffff8800c8f13858 ffffffff81af135a 0000000000000000
> > >  ffff880212202430 ffff8800c8f13878 ffffffff810f8d3a ffff880212202c98
> > >  0000000000000010 ffff8800c8f138c8 ffffffff8121ad0e 0000000000000001
> > > Call Trace:
> > >  [<ffffffff81af135a>] dump_stack+0x4e/0x68
> > >  [<ffffffff810f8d3a>] __might_sleep+0x10a/0x120
> > >  [<ffffffff8121ad0e>] kmem_cache_alloc_trace+0x4e/0x190
> > >  [<ffffffff81a6bcd6>] ? fib6_commit_metrics+0x66/0x110
> > >  [<ffffffff81a6bcd6>] fib6_commit_metrics+0x66/0x110
> > >  [<ffffffff81a6cbf3>] fib6_add+0x883/0xa80
> > >  [<ffffffff81a6951a>] ? ip6_route_add+0x65a/0x800
> > >  [<ffffffff81a69535>] ip6_route_add+0x675/0x800
> > >  [<ffffffff81a68f2a>] ? ip6_route_add+0x6a/0x800
> > >  [<ffffffff81a6990c>] inet6_rtm_newroute+0x5c/0x80
> > >  [<ffffffff8197cf01>] rtnetlink_rcv_msg+0x211/0x260
> > >  [<ffffffff81978e67>] ? rtnl_lock+0x17/0x20
> > >  [<ffffffff81119708>] ? lock_release_holdtime+0x28/0x180
> > >  [<ffffffff81978e67>] ? rtnl_lock+0x17/0x20
> > >  [<ffffffff8197ccf0>] ? __rtnl_unlock+0x20/0x20
> > >  [<ffffffff819a989e>] netlink_rcv_skb+0x6e/0xd0
> > >  [<ffffffff81978ee5>] rtnetlink_rcv+0x25/0x40
> > >  [<ffffffff819a8e59>] netlink_unicast+0xd9/0x180
> > >  [<ffffffff819a9600>] netlink_sendmsg+0x700/0x770
> > >  [<ffffffff81103735>] ? local_clock+0x25/0x30
> > >  [<ffffffff8194e83c>] sock_sendmsg+0x6c/0x90
> > >  [<ffffffff811f98e3>] ? might_fault+0xa3/0xb0
> > >  [<ffffffff8195ca6d>] ? verify_iovec+0x7d/0xf0
> > >  [<ffffffff8194ec3e>] ___sys_sendmsg+0x37e/0x3b0
> > >  [<ffffffff8111ef15>] ? trace_hardirqs_on_caller+0x185/0x220
> > >  [<ffffffff81af979e>] ? mutex_unlock+0xe/0x10
> > >  [<ffffffff819a55ec>] ? netlink_insert+0xbc/0xe0
> > >  [<ffffffff819a65e5>] ? netlink_autobind.isra.30+0x125/0x150
> > >  [<ffffffff819a6520>] ? netlink_autobind.isra.30+0x60/0x150
> > >  [<ffffffff819a84f9>] ? netlink_bind+0x159/0x230
> > >  [<ffffffff811f989a>] ? might_fault+0x5a/0xb0
> > >  [<ffffffff8194f25e>] ? SYSC_bind+0x7e/0xd0
> > >  [<ffffffff8194f8cd>] __sys_sendmsg+0x4d/0x80
> > >  [<ffffffff8194f912>] SyS_sendmsg+0x12/0x20
> > >  [<ffffffff81afc692>] system_call_fastpath+0x16/0x1b
> >=20
> > Fixing this by replacing the mode GFP_KERNEL with GFP_NOWAIT.
> >=20
> > Signed-off-by: Benjamin Block <bebl@mageta.org>
> > ---
> >  net/ipv6/ip6_fib.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> > index cb4459b..7eef9fc 100644
> > --- a/net/ipv6/ip6_fib.c
> > +++ b/net/ipv6/ip6_fib.c
> > @@ -643,7 +643,7 @@ static int fib6_commit_metrics(struct dst_entry *ds=
t,
> >  	if (dst->flags & DST_HOST) {
> >  		mp =3D dst_metrics_write_ptr(dst);
> >  	} else {
> > -		mp =3D kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
> > +		mp =3D kzalloc(sizeof(u32) * RTAX_MAX, GFP_NOWAIT);
> >  		if (!mp)
> >  			return -ENOMEM;
> >  		dst_init_metrics(dst, mp, 0);
>=20
> I actually think we should go with GFP_ATOMIC like the rest of the
> stack. The code path we are talking about here mostly uses GFP_ATOMIC,
> so in case this one GFP_NOWAITit bails out via error path, all those
> GFP_ATOMIC allocations before were useless.
>=20

Fair enough, I was thinking about it and was more along the line, the
original author obviously wasn't concerned with any delay, and thus
GFP_NOWAIT would suffice as well.

--=20
BOFH Excuse #174:
Backbone adjustment
--
                                                          best regards,
                                                            - Benjamin Block

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAEBAgAGBQJT9gKnAAoJEEbgTgVnoy6eWekMAIRmilPdig2lOTrJip4R2euB
CVk5ZMmEgPThbncTTimYFVlEGGJAdXdz+cmsZA0mYOPWWx0A4DLt/H9+IK6afbDU
lkiwDThj0A7KI0HtDY3yKhWhvVLciI+GEOgQj5+yGYhsQyH8b0CJGwhNw43KmA9E
ccYFIZcGKXZ/w2NY+gYN/OEbwm6fFqNWJbPuB66hU82jp9pRG3QEwB5PiNVStB2v
RqrO9XI3hCA31P74BMjsZgDw8bEjAqMxY04hrOO4W07HSr47eBfRuhIjUi6tGpMc
ATYakQA3dRjtXz81+ziabjgJ2q7OJRgBOL0IUZb/SQ9fpao7jONFtYyp30zGUH9L
gBQxFuJmM/YS9qy/VOpICPtU84fWLsPob9YVqVAR2ZAKEtGUhsYuTjb1M1/Av0Gn
RJ1UfY0vLRFPoo7hN1PFKMK7rU/aakk5q2jm4pQdzSCQprwTCMyzGBfrGKNq/CM2
Dbj+q5NIez+RH8Uq1osrOUVLGFMHoSWXGQgXQINE3g==
=DxhV
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
