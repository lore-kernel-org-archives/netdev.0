From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] Zero-length write() does not generate a datagram on
 connected socket
Date: Thu, 27 Sep 2007 15:41:44 -0700
Message-ID: <20070927154144.7de2a719@freepuppy.rosehill>
References: <bug-5731-100@http.bugzilla.kernel.org/>
	<20070922094432.E9BEA108010@picon.linux-foundation.org>
	<20070924153435.14249225@freepuppy.rosehill>
	<20070927.135334.56943477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43510 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757575AbXI0Wlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 18:41:49 -0400
In-Reply-To: <20070927.135334.56943477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Sep 2007 13:53:34 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 24 Sep 2007 15:34:35 -0700
> 
> > The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
> > describes an issue where write() can't be used to generate a zero-length
> > datagram (but send, and sendto do work).
> > 
> > I think the following is needed:
> > 
> > --- a/net/socket.c	2007-08-20 09:54:28.000000000 -0700
> > +++ b/net/socket.c	2007-09-24 15:31:25.000000000 -0700
> > @@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
> >  	if (pos != 0)
> >  		return -ESPIPE;
> >  
> > -	if (iocb->ki_left == 0)	/* Match SYS5 behaviour */
> > -		return 0;
> > +	if (unlikely(iocb->ki_left == 0)) {
> > +		struct socket *sock = iocb->ki_filp->private_data;
> > +		if (sock->type == SOCK_STREAM)
> > +			return 0;
> > +	}
> >  
> >  	x = alloc_sock_iocb(iocb, &siocb);
> >  	if (!x)
> 
> We should simply remove the check completely.
> 
> There is no need to add special code for different types of protocols
> and sockets.
> 
> As is hinted in the bugzilla, the exact same thing can happen with a
> suitably constructed sendto() or sendmsg() call.  write() on a socket
> is a sendmsg() with a NULL msg_control and a single entry iovec, plain
> and simple.
> 
> It's how BSD and many other systems behave, and I double checked
> Steven's Volume 2 just to make sure.
> 
> So I'm going to check in the following to fix this bugzilla.  There is
> a similarly ugly test for len==0 in sys_read() on sockets.  If someone
> would do some research on the validity of that thing I'd really
> appreciate it :-)

Read of zero length should be a no-op for SOCK_STREAM but
for SOCK_DATAGRAM or SOCK_SEQPACKET it might be useful as a 
remote wait for event.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
