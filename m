From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] xfrm: do not leak ESRCH to user space
Date: Thu, 23 Oct 2008 14:11:58 -0700 (PDT)
Message-ID: <20081023.141158.179712309.davem@davemloft.net>
References: <1224772039.4404.56.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: fernando@oss.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbYJWVMU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 17:12:20 -0400
In-Reply-To: <1224772039.4404.56.camel@sebastian.kern.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp>
Date: Thu, 23 Oct 2008 23:27:19 +0900

> I noticed that, under certain conditions, ESRCH can be leaked from th=
e
> xfrm layer to user space through sys_connect. In particular, this see=
ms
> to happen reliably when the kernel fails to resolve a template either
> because the AF_KEY receive buffer being used by racoon is full or
> because the SA entry we are trying to use is in XFRM_STATE_EXPIRED
> state.
>=20
> However, since this could be a transient issue it could be argued tha=
t
> EAGAIN would be more appropriate. Besides this error code is not even
> documented in the man page for sys_connect (as of man-pages 3.07).
>=20
> What is the expected behavior (I could not find anything in the RFCs)=
?
> Should we just fix the connect(2) man page instead?

I think this case requires some care.

-EAGAIN tells the caller that it is a temporary failure and that
retrying can be expected to succeed eventually (some resource is not
available at the moment).  So applications loop when they see this
error returned, they will try again.

But that's not what is happening when ESRCH is signalled.  We found
no matching policy, and we've done nothing to make such a policy
be found in the (near) future.  It is more of a hard failure, which
should not necessarily be retried over and over again.

So converting this to -EAGAIN doesn't seem correct at all.
