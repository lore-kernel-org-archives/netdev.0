From: "Michael Kerrisk" <mtk.linux.lists@gmail.com>
Subject: Re: [RFC] Zero-length write() does not generate a datagram on connected socket
Date: Fri, 28 Sep 2007 10:49:10 +0200
Message-ID: <517f3f820709280149h761c15bfw582c6784498e64d7@mail.gmail.com>
References: <bug-5731-100@http.bugzilla.kernel.org/>
	 <20070922094432.E9BEA108010@picon.linux-foundation.org>
	 <20070924153435.14249225@freepuppy.rosehill>
	 <20070927.135334.56943477.davem@davemloft.net>
	 <20070927154144.7de2a719@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	mtk-manpages@gmx.net
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:6441 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758009AbXI1ItL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 04:49:11 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1445790ugc
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 01:49:10 -0700 (PDT)
In-Reply-To: <20070927154144.7de2a719@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/28/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Thu, 27 Sep 2007 13:53:34 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
>
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Mon, 24 Sep 2007 15:34:35 -0700
> >
> > > The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
> > > describes an issue where write() can't be used to generate a zero-length
> > > datagram (but send, and sendto do work).
> > >
> > > I think the following is needed:
> > >
> > > --- a/net/socket.c  2007-08-20 09:54:28.000000000 -0700
> > > +++ b/net/socket.c  2007-09-24 15:31:25.000000000 -0700
> > > @@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
> > >     if (pos != 0)
> > >             return -ESPIPE;
> > >
> > > -   if (iocb->ki_left == 0) /* Match SYS5 behaviour */
> > > -           return 0;
> > > +   if (unlikely(iocb->ki_left == 0)) {
> > > +           struct socket *sock = iocb->ki_filp->private_data;
> > > +           if (sock->type == SOCK_STREAM)
> > > +                   return 0;
> > > +   }
> > >
> > >     x = alloc_sock_iocb(iocb, &siocb);
> > >     if (!x)
> >
> > We should simply remove the check completely.
> >
> > There is no need to add special code for different types of protocols
> > and sockets.
> >
> > As is hinted in the bugzilla, the exact same thing can happen with a
> > suitably constructed sendto() or sendmsg() call.  write() on a socket
> > is a sendmsg() with a NULL msg_control and a single entry iovec, plain
> > and simple.
> >
> > It's how BSD and many other systems behave, and I double checked
> > Steven's Volume 2 just to make sure.
> >
> > So I'm going to check in the following to fix this bugzilla.  There is
> > a similarly ugly test for len==0 in sys_read() on sockets.  If someone
> > would do some research on the validity of that thing I'd really
> > appreciate it :-)
>
> Read of zero length should be a no-op for SOCK_STREAM but
> for SOCK_DATAGRAM or SOCK_SEQPACKET it might be useful as a
> remote wait for event.

Hmm -- I hadn't checked the behavior for zero-length read() on other
systems.  i will try to do that soonish (probably only Minday or so).

Cheers,

Michael
