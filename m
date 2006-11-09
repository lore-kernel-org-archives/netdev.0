From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 3/6] kevent: poll/select() notifications.
Date: Thu, 9 Nov 2006 22:10:36 +0300
Message-ID: <20061109191036.GA30138@2ka.mipt.ru>
References: <11630606373650@2ka.mipt.ru> <Pine.LNX.4.64.0611091047120.25481@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:6368 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1754363AbWKITOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 14:14:17 -0500
To: Davide Libenzi <davidel@xmailserver.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611091047120.25481@alien.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 09, 2006 at 10:51:56AM -0800, Davide Libenzi (davidel@xmailserver.org) wrote:
> On Thu, 9 Nov 2006, Evgeniy Polyakov wrote:
> 
> > +static int kevent_poll_callback(struct kevent *k)
> > +{
> > +	if (k->event.req_flags & KEVENT_REQ_LAST_CHECK) {
> > +		return 1;
> > +	} else {
> > +		struct file *file = k->st->origin;
> > +		unsigned int revents = file->f_op->poll(file, NULL);
> > +
> > +		k->event.ret_data[0] = revents & k->event.event;
> > +		
> > +		return (revents & k->event.event);
> > +	}
> > +}
> 
> You need to be careful that file->f_op->poll is not called inside the 
> spin_lock_irqsave/spin_lock_irqrestore pair, since (even this came up 
> during epoll developemtn days) file->f_op->poll might do a simple 
> spin_lock_irq/spin_unlock_irq. This unfortunate constrain forced epoll to 
> have a suboptimal double O(R) loop to handle LT events.
 
It is tricky - users call wake_up() from any context, which in turn ends
up calling kevent_storage_ready(), which calls kevent_poll_callback() with
KEVENT_REQ_LAST_CHECK bit set, which becomes almost empty call in fast
path. Since callback returns 1, kevent will be queued into ready queue,
which is processed on behalf of syscalls - in that case kevent will
check the flag and since KEVENT_REQ_LAST_CHECK is set, will call
callback again to check if kevent is correctly marked, but already
without that flag (it happens in syscall context, i.e. process context
without any locks held), so callback calls ->poll(), which can sleep,
but it is safe. If ->poll() returns 'ready' value, kevent is transfers
data into userspace, otherwise it is 'requeued' (just removed from
ready queue).
 
> - Davide
> 

-- 
	Evgeniy Polyakov
