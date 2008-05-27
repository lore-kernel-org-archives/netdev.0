From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 12:08:41 +0100
Message-ID: <20080527110840.GH28241@solarflare.com>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527110144.GA15141@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:52156 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756402AbYE0LJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 07:09:56 -0400
Content-Disposition: inline
In-Reply-To: <20080527110144.GA15141@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> On Tue, May 27, 2008 at 03:25:23AM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> >
> > Hi,
> >
> > The following socket lock dropping in skb_splice_bits seems to open a race
> > condition which causes an invalid kernel access:
> >
> > >        if (spd.nr_pages) {
> > >                int ret;
> > >
> > >                /*
> > >                 * Drop the socket lock, otherwise we have reverse
> > >                 * locking dependencies between sk_lock and i_mutex
> > >                 * here as compared to sendfile(). We enter here
> > >                 * with the socket lock held, and splice_to_pipe() will
> > >                 * grab the pipe inode lock. For sendfile() emulation,
> > >                 * we call into ->sendpage() with the i_mutex lock held
> > >                 * and networking will grab the socket lock.
> > >                 */
>
> What about sock_hold() here?
> It will prevent from socket freeing and read/write to it will
> immediately return with error if socket was closed by another thread.
<snip>

We know the socket isn't going to go away because somewhere up the call
stack someone has to be holding the socket in order to lock it.  However,
the skb may (and evidently sometimes does) go away during splice_to_pipe()
so we can't look up the socket through it.

However, from Octavian's later mail it seems we can't let the skb go away
at all.  So some wider changes seem to be required.

Ben.

--
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
