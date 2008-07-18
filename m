From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 14:18:59 +0300
Message-ID: <200807181418.59493.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807180052.33918.opurdila@ixiacom.com> <20080718105344.GA481@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1068 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755024AbYGRLVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 07:21:52 -0400
In-Reply-To: <20080718105344.GA481@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 July 2008, Evgeniy Polyakov wrote:

> tcp_splice_read:
>
> timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
>
> So, if you set SPLICE_F_NONBLOCK, then reading from the network will not
> block. Splice can block in reading from other descriptors though. It can
> also block during writing.
>

I know that. But I am arguing that splice API does not required not to block 
even when the SPLICE_F_NONBLOCK is used. So changing this behavior the way I 
suggested will still be conformant with the splice API requirements.

> > > > But more importantly, how can we solve the deadlock issue described
> > > > in the patch? Do we need all of the complications of async I/O for
> > > > such a simple and common usecase?
> > >
> > > I'm not sure I understand how it can deadlock, please explain it in
> > > more details.
> >
> > For this "program":
> >
> > x=splice(socket, pipe, size, flags=0);
> > if (x > 0)
> > 	splice(pipe, file, x, flags=0);
> >
> > it is hard to come up with a non tiny value for size that does not
> > deadlock the program, because the pipe size is measured in packets and
> > not bytes and we have no control over the packet sizes.
> >
> > For example, if we set size=17 and we are unlucky and get 16 packets of 1
> > byte in a row, at the right time, the first splice call will block - and
> > the program will deadlock since we can't reach the consumer.
>
> It is not a deadlock. recv() on blocking socket with the same parameters
> will behave exactly the same. Application designer should think about 
> how it is supposed to handle cases, when not enough data is available in
> the receiving queue - either return or wait.

Sorry, it was an unfortunate example :) This is not about not enough data 
being available. Lets change the number of packets in the example with 20 
instead of 16 (and keep the size to 17) - the splice call will still block 
because of the pipe being full. The pipe can only hold PIPE_BUFFERS packets 
(which is 16 currently).

Thanks,
tavi
