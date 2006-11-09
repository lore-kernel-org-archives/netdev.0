From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [take23 0/5] kevent: Generic event handling mechanism.
Date: Thu, 9 Nov 2006 09:12:55 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611090834050.25262@alien.or.mcafeemobile.com>
References: <1154985aa0591036@2ka.mipt.ru> <20061107141718.f7414b31.akpm@osdl.org>
 <20061108082147.GA2447@2ka.mipt.ru> <200611081551.14671.dada1@cosmosbay.com>
 <20061108140307.da7d815f.akpm@osdl.org> <Pine.LNX.4.64.0611081442420.23154@alien.or.mcafeemobile.com>
 <45526339.3040506@cosmosbay.com> <Pine.LNX.4.64.0611081526350.23154@alien.or.mcafeemobile.com>
 <4552D7A6.4060505@cosmosbay.com> <4552DE4D.7000007@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Andrew Morton <akpm@osdl.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([69.30.125.51]:57834 "EHLO
	x35.xmailserver.org") by vger.kernel.org with ESMTP
	id S1424145AbWKIRNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 12:13:06 -0500
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.23 ESMTP Server]
	id <S1FC35A> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Thu, 9 Nov 2006 09:13:00 -0800
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4552DE4D.7000007@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Nov 2006, Eric Dumazet wrote:

> > > Lost forever means? If there are more processes watching some fd (external
> > > events), they all get their own copy of the events in their own private
> > > epoll fd. It's not that we "steal" things out of the kernel, is not a 1:1
> > > producer/consumer thing (one producer, 1 queue). It's one producer,
> > > broadcast to all listeners (consumers) thing. The only case where it'd
> > > matter is in the case of multiple threads sharing the same epoll fd.
> > 
> > In my particular epoll application, the producer is tcp stack, and I have
> > one consumer. If an network event is lost in the EFAULT handling, its lost
> > forever. In any case, my application do provide a correct user area, so this
> > problem is only theorical.
> 
> I realize I was not explicit, and dit not answer your question (Lost forever
> means ?)
> 
>                 if (epi->revents) {
>                         if (__put_user(epi->revents,
>                                        &events[eventcnt].events) ||
>                             __put_user(epi->event.data,
>                                        &events[eventcnt].data))
>                                 return -EFAULT;
> >>                        if (epi->event.events & EPOLLONESHOT)
> >>                                epi->event.events &= EP_PRIVATE_BITS;
>                         eventcnt++;
>                 }
> 
> If one EPOLLONESHOT event is correctly copied to user space, its status is
> updated.
> 
> If other ready events in the same epoll_wait() call cannot be transferred
> because of an EFAULT (we reach the real end of user provided area), this
> EPOLLONESHOT event is lost forever, because it wont be requeued in ready list.

Your application is feeding crap to the kernel, because of programming 
bugs. If that happens, I want an EFAULT and not a partially filled buffer. 
And which buffer then? This could have been scribbled in userspace memory 
(the pointer), and the try of the kernel to mask out bugs might create 
even more subtle problems. Such bug will *never* show up in the up in case 
the wrong buffer is partially valid (first part, that is the *only* case 
where your fix would make a difference compared to the status quo), since 
in case of no ready events we'll never hit it, and in case of some events 
we'll always return few of them and never EFAULT. No, the more I think 
about it, the more I personally disagree with the change.



> Please dont slow the hot path for a basically "User Error". It's already 
> tested in the transfert function, with two conditional 
> branches for each transfered event.

Ohh, if you think you can measure them from userspace, those can be turned 
in 'err |= __put_user();' with err tested only out of the loop.



- Davide


