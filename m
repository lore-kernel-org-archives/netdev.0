From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 14:53:44 +0400
Message-ID: <20080718105344.GA481@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com> <200807171747.27775.opurdila@ixiacom.com> <20080717174150.GA24002@2ka.mipt.ru> <200807180052.33918.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:43322 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754675AbYGRKxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 06:53:52 -0400
Content-Disposition: inline
In-Reply-To: <200807180052.33918.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Jul 18, 2008 at 12:52:33AM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> You lost me here :)
> 
> The way I interpret the man page text is that it is ok for splice to block, 
> even if SPLICE_F_NONBLOCK is set. The comments near SPLICE_F_NONBLOCK says 
> the same thing:
> 
> #define SPLICE_F_NONBLOCK (0x02) /* don't block on the pipe splicing (but */
>                                  /* we may still block on the fd we splice */
>                                  /* from/to, of course */
> 
> Am I missing something?

tcp_splice_read:

timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);

So, if you set SPLICE_F_NONBLOCK, then reading from the network will not
block. Splice can block in reading from other descriptors though. It can
also block during writing.

> > > But more importantly, how can we solve the deadlock issue described in
> > > the patch? Do we need all of the complications of async I/O for such a
> > > simple and common usecase?
> >
> > I'm not sure I understand how it can deadlock, please explain it in more
> > details.
> 
> For this "program":
> 
> x=splice(socket, pipe, size, flags=0); 
> if (x > 0)
> 	splice(pipe, file, x, flags=0);
> 
> it is hard to come up with a non tiny value for size that does not deadlock 
> the program, because the pipe size is measured in packets and not bytes and 
> we have no control over the packet sizes.
> 
> For example, if we set size=17 and we are unlucky and get 16 packets of 1 byte 
> in a row, at the right time, the first splice call will block - and the 
> program will deadlock since we can't reach the consumer. 

It is not a deadlock. recv() on blocking socket with the same parameters
will behave exactly the same. Application designer should think about
how it is supposed to handle cases, when not enough data is available in
the receiving queue - either return or wait.

-- 
	Evgeniy Polyakov
