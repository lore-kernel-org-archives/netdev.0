From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 00:52:33 +0300
Message-ID: <200807180052.33918.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807171747.27775.opurdila@ixiacom.com> <20080717174150.GA24002@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3771 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761089AbYGQVyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 17:54:45 -0400
In-Reply-To: <20080717174150.GA24002@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 17 July 2008, Evgeniy Polyakov wrote:
> >
> > I am probably missing some usecases here, but usually if you want to use
> > non-blocking I/O you need to use special approach anyway (e.g. code the
> > poll/epoll/select bits) so then you could open the socket with
> > O_NONBLOCK.
>
> It depends. Splice clearly states that it tries to be nonblocking with 
> given flag being set, and its reading will be non-blocking indeed.
>
> > > This is a quite serious break of the
> > > overall idea behind SPLICE_F_NONBLOCK.
> >
> > I don't know... the man page explicitly says that even when you use
> > SPLICE_F_NONBLOCK splice may block because of the underlying fd blocking.
>
> Yes, but reading from the network will not.
>

You lost me here :)

The way I interpret the man page text is that it is ok for splice to block, 
even if SPLICE_F_NONBLOCK is set. The comments near SPLICE_F_NONBLOCK says 
the same thing:

#define SPLICE_F_NONBLOCK (0x02) /* don't block on the pipe splicing (but */
                                 /* we may still block on the fd we splice */
                                 /* from/to, of course */

Am I missing something?

> > But more importantly, how can we solve the deadlock issue described in
> > the patch? Do we need all of the complications of async I/O for such a
> > simple and common usecase?
>
> I'm not sure I understand how it can deadlock, please explain it in more
> details.

For this "program":

x=splice(socket, pipe, size, flags=0); 
if (x > 0)
	splice(pipe, file, x, flags=0);

it is hard to come up with a non tiny value for size that does not deadlock 
the program, because the pipe size is measured in packets and not bytes and 
we have no control over the packet sizes.

For example, if we set size=17 and we are unlucky and get 16 packets of 1 byte 
in a row, at the right time, the first splice call will block - and the 
program will deadlock since we can't reach the consumer. 

Thanks,
tavi
