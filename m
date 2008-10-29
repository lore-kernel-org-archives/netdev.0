From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: Re: [RFC][PATCH] xfrm: do not leak ESRCH to user space
Date: Wed, 29 Oct 2008 11:58:23 +0900
Message-ID: <1225249103.7276.56.camel@sebastian.kern.oss.ntt.co.jp>
References: <1224772039.4404.56.camel@sebastian.kern.oss.ntt.co.jp>
	 <20081023.141158.179712309.davem@davemloft.net>
	 <1224810300.8667.26.camel@sebastian.kern.oss.ntt.co.jp>
	 <20081028.155817.216873568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:36511 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbYJ2C6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 22:58:25 -0400
In-Reply-To: <20081028.155817.216873568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-28 at 15:58 -0700, David Miller wrote:
> From: Fernando Luis V=C3=A1zquez Cao <fernando@oss.ntt.co.jp>
> Date: Fri, 24 Oct 2008 10:05:00 +0900
>=20
> > On Thu, 2008-10-23 at 14:11 -0700, David Miller wrote:
> > > From: Fernando Luis V=C3=A1zquez Cao <fernando@oss.ntt.co.jp>
> > > Date: Thu, 23 Oct 2008 23:27:19 +0900
> > >=20
> > > > I noticed that, under certain conditions, ESRCH can be leaked f=
rom the
> > > > xfrm layer to user space through sys_connect. In particular, th=
is seems
> > > > to happen reliably when the kernel fails to resolve a template =
either
> > > > because the AF_KEY receive buffer being used by racoon is full =
or
> > > > because the SA entry we are trying to use is in XFRM_STATE_EXPI=
RED
> > > > state.
> > > >=20
> > > > However, since this could be a transient issue it could be argu=
ed that
> > > > EAGAIN would be more appropriate. Besides this error code is no=
t even
> > > > documented in the man page for sys_connect (as of man-pages 3.0=
7).
> > > >=20
> > > > What is the expected behavior (I could not find anything in the=
 RFCs)?
> > > > Should we just fix the connect(2) man page instead?
> > >=20
> > > I think this case requires some care.
> > >=20
> > > -EAGAIN tells the caller that it is a temporary failure and that
> > > retrying can be expected to succeed eventually (some resource is =
not
> > > available at the moment).  So applications loop when they see thi=
s
> > > error returned, they will try again.
> > >=20
> > > But that's not what is happening when ESRCH is signalled.  We fou=
nd
> > > no matching policy, and we've done nothing to make such a policy
> > > be found in the (near) future.  It is more of a hard failure, whi=
ch
> > > should not necessarily be retried over and over again.
> > >=20
> > > So converting this to -EAGAIN doesn't seem correct at all.
> >=20
> > That would be so if -ESRCH did not happen to be a transient error.
>=20
> It is not set in transient conditions as far as I can see.
>=20
> Look at xfrm_state_find() which is where this error is generated and
> then propagates down to xfrm_tmpl_resolve_one().
>=20
> In xfrm_state_find() if an acquire is in progress to resolve the
> entry, the code explicitly converts all errors into -EAGAIN.

Let me quote the problematic part of that function:
    ....
    } else if (x->km.state =3D=3D XFRM_STATE_ACQ) {
            acquire_in_progress =3D 1;
    } else if (x->km.state =3D=3D XFRM_STATE_ERROR ||
               x->km.state =3D=3D XFRM_STATE_EXPIRED) {
            if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
                security_xfrm_state_pol_flow_match(x, pol, fl))
                    error =3D -ESRCH;
    }
    ....

If the kernel enters the last branch acquire_in_progress will not be se=
t
and it could propagate down to xfrm_tmpl_resolve_one(). The reason is
that in xfrm_timer_handler() we put any entry that expired when acquire
is in progress in XFRM_STATE_EXPIRED state __before__ sleeping for two
seconds, which means the kernel will not set acquire_in_progress to 1 i=
n
the code above.

> > Looking at the code, the window during which an entry is in
> > XFRM_STATE_EXPIRED state seems to be about 2 seconds in the worst c=
ase.
> > Connection attempts before and after that window would most likely
> > result in a successful connection or -EAGAIN, respectively. Would n=
ot it
> > make sense to return -EAGAIN also during that 2 seconds window?
>=20
> Only if an acquire has been triggered and is in progress, which as
> explained above the code already seems to handle.
As explained above that does not seem to be the case.

Besides, there is also the case that km_query() in xfrm_state_find()
fails in which we would leak -ESRCH to user space too. As mentioned in =
a
previous email, returning -EAGAIN is arguably more appropriate if the
cause of km_query failing was that racoon's receive buffer was full
(could happen under heavy load), because as racoon reads from it the
problem will go away.

