From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] Zero-length write() does not generate a datagram on
 connected socket
Date: Tue, 25 Sep 2007 22:36:09 -0700
Message-ID: <20070925223609.0e89a6a7@freepuppy.rosehill>
References: <20070924153435.14249225@freepuppy.rosehill>
	<E1IaNQ7-0004DX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36810 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751835AbXIZFhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 01:37:03 -0400
In-Reply-To: <E1IaNQ7-0004DX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Sep 2007 11:18:39 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
> > describes an issue where write() can't be used to generate a zero-length
> > datagram (but send, and sendto do work).
> > 
> > I think the following is needed:
> > 
> > --- a/net/socket.c      2007-08-20 09:54:28.000000000 -0700
> > +++ b/net/socket.c      2007-09-24 15:31:25.000000000 -0700
> > @@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
> >        if (pos != 0)
> >                return -ESPIPE;
> > 
> > -       if (iocb->ki_left == 0) /* Match SYS5 behaviour */
> > -               return 0;
> > +       if (unlikely(iocb->ki_left == 0)) {
> > +               struct socket *sock = iocb->ki_filp->private_data;
> > +               if (sock->type == SOCK_STREAM)
> > +                       return 0;
> > +       }
> 
> I'm not sure whether all STREAM protocols treat zero-length
> sends as no-ops.  What about SCTP?
> 
> Put it another way, do we really need to keep the short-circuit
> for SOCK_STREAM?
> 
> Cheers,

Stream is defined as sequence of bytes. So short circuit makes sense
If the application wants message boundaries it needs to use SOCK_SEQPACKET.
I was paranoid about possible breakage in TCP or SCTP. But since
send(s, buf, 0, 0) already filters through, I guess it doesn't matter.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
