From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: Re: [RFC][PATCH] xfrm: do not leak ESRCH to user space
Date: Fri, 24 Oct 2008 10:05:00 +0900
Message-ID: <1224810300.8667.26.camel@sebastian.kern.oss.ntt.co.jp>
References: <1224772039.4404.56.camel@sebastian.kern.oss.ntt.co.jp>
	 <20081023.141158.179712309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:58999 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182AbYJXBFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 21:05:02 -0400
In-Reply-To: <20081023.141158.179712309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-23 at 14:11 -0700, David Miller wrote:
> From: Fernando Luis V=C3=A1zquez Cao <fernando@oss.ntt.co.jp>
> Date: Thu, 23 Oct 2008 23:27:19 +0900
>=20
> > I noticed that, under certain conditions, ESRCH can be leaked from =
the
> > xfrm layer to user space through sys_connect. In particular, this s=
eems
> > to happen reliably when the kernel fails to resolve a template eith=
er
> > because the AF_KEY receive buffer being used by racoon is full or
> > because the SA entry we are trying to use is in XFRM_STATE_EXPIRED
> > state.
> >=20
> > However, since this could be a transient issue it could be argued t=
hat
> > EAGAIN would be more appropriate. Besides this error code is not ev=
en
> > documented in the man page for sys_connect (as of man-pages 3.07).
> >=20
> > What is the expected behavior (I could not find anything in the RFC=
s)?
> > Should we just fix the connect(2) man page instead?
>=20
> I think this case requires some care.
>=20
> -EAGAIN tells the caller that it is a temporary failure and that
> retrying can be expected to succeed eventually (some resource is not
> available at the moment).  So applications loop when they see this
> error returned, they will try again.
>=20
> But that's not what is happening when ESRCH is signalled.  We found
> no matching policy, and we've done nothing to make such a policy
> be found in the (near) future.  It is more of a hard failure, which
> should not necessarily be retried over and over again.
>=20
> So converting this to -EAGAIN doesn't seem correct at all.

That would be so if -ESRCH did not happen to be a transient error.
Looking at the code, the window during which an entry is in
XFRM_STATE_EXPIRED state seems to be about 2 seconds in the worst case.
Connection attempts before and after that window would most likely
result in a successful connection or -EAGAIN, respectively. Would not i=
t
make sense to return -EAGAIN also during that 2 seconds window?

Regarding the case when the kernel does not initiate a SA resolution
because the the AF_KEY receive buffer is full, I think it fits into the
"some resource is not available at the moment" definition for -EAGAIN.
As the buffer gets emptied chances are the future attempts will succeed=
=2E

This behavior is kind of confusing, but if deemed correct I think it
deserves to be properly documented in the respective man page. Do you
want me to do that or should the error code we return to user space be
changed in any of the two cases mentioned above?

