From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take23 0/5] kevent: Generic event handling mechanism.
Date: Wed, 8 Nov 2006 14:03:07 -0800
Message-ID: <20061108140307.da7d815f.akpm@osdl.org>
References: <1154985aa0591036@2ka.mipt.ru>
	<20061107141718.f7414b31.akpm@osdl.org>
	<20061108082147.GA2447@2ka.mipt.ru>
	<200611081551.14671.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52886 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161726AbWKHWId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 17:08:33 -0500
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <200611081551.14671.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Nov 2006 15:51:13 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> [PATCH] eventpoll : In case a fault occurs during copy_to_user(), we should 
> report the count of events that were successfully copied into user space, 
> instead of EFAULT. That would be consistent with behavior of read/write() 
> syscalls for example.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> 
> 
> [eventpoll.patch  text/plain (424B)]
> --- linux/fs/eventpoll.c	2006-11-08 15:37:36.000000000 +0100
> +++ linux/fs/eventpoll.c	2006-11-08 15:38:31.000000000 +0100
> @@ -1447,7 +1447,7 @@
>  				       &events[eventcnt].events) ||
>  			    __put_user(epi->event.data,
>  				       &events[eventcnt].data))
> -				return -EFAULT;
> +				return eventcnt ? eventcnt : -EFAULT;
>  			if (epi->event.events & EPOLLONESHOT)
>  				epi->event.events &= EP_PRIVATE_BITS;
>  			eventcnt++;
> 

Definitely a better interface, but I wonder if it's too late to change it.

An app which does

	if (epoll_wait(...) == -1)
		barf(errno);
	else
		assume_all_events_were_received();

will now do the wrong thing.

otoh, such an applciation basically _has_ to use the epoll_wait()
return value to work out how many events it received, so maybe it's OK...
