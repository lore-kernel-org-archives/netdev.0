From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] xfrm: do not leak ESRCH to user space
Date: Tue, 28 Oct 2008 15:58:17 -0700 (PDT)
Message-ID: <20081028.155817.216873568.davem@davemloft.net>
References: <1224772039.4404.56.camel@sebastian.kern.oss.ntt.co.jp>
	<20081023.141158.179712309.davem@davemloft.net>
	<1224810300.8667.26.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: fernando@oss.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752457AbYJ1W6j convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 18:58:39 -0400
In-Reply-To: <1224810300.8667.26.camel@sebastian.kern.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp>
Date: Fri, 24 Oct 2008 10:05:00 +0900

> On Thu, 2008-10-23 at 14:11 -0700, David Miller wrote:
> > From: Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp>
> > Date: Thu, 23 Oct 2008 23:27:19 +0900
> >=20
> > > I noticed that, under certain conditions, ESRCH can be leaked fro=
m the
> > > xfrm layer to user space through sys_connect. In particular, this=
 seems
> > > to happen reliably when the kernel fails to resolve a template ei=
ther
> > > because the AF_KEY receive buffer being used by racoon is full or
> > > because the SA entry we are trying to use is in XFRM_STATE_EXPIRE=
D
> > > state.
> > >=20
> > > However, since this could be a transient issue it could be argued=
 that
> > > EAGAIN would be more appropriate. Besides this error code is not =
even
> > > documented in the man page for sys_connect (as of man-pages 3.07)=
=2E
> > >=20
> > > What is the expected behavior (I could not find anything in the R=
=46Cs)?
> > > Should we just fix the connect(2) man page instead?
> >=20
> > I think this case requires some care.
> >=20
> > -EAGAIN tells the caller that it is a temporary failure and that
> > retrying can be expected to succeed eventually (some resource is no=
t
> > available at the moment).  So applications loop when they see this
> > error returned, they will try again.
> >=20
> > But that's not what is happening when ESRCH is signalled.  We found
> > no matching policy, and we've done nothing to make such a policy
> > be found in the (near) future.  It is more of a hard failure, which
> > should not necessarily be retried over and over again.
> >=20
> > So converting this to -EAGAIN doesn't seem correct at all.
>=20
> That would be so if -ESRCH did not happen to be a transient error.

It is not set in transient conditions as far as I can see.

Look at xfrm_state_find() which is where this error is generated and
then propagates down to xfrm_tmpl_resolve_one().

In xfrm_state_find() if an acquire is in progress to resolve the
entry, the code explicitly converts all errors into -EAGAIN.

> Looking at the code, the window during which an entry is in
> XFRM_STATE_EXPIRED state seems to be about 2 seconds in the worst cas=
e.
> Connection attempts before and after that window would most likely
> result in a successful connection or -EAGAIN, respectively. Would not=
 it
> make sense to return -EAGAIN also during that 2 seconds window?

Only if an acquire has been triggered and is in progress, which as
explained above the code already seems to handle.
