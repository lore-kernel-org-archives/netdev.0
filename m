From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [take24 3/6] kevent: poll/select() notifications.
Date: Thu, 9 Nov 2006 11:42:49 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611091137290.25481@alien.or.mcafeemobile.com>
References: <11630606373650@2ka.mipt.ru> <Pine.LNX.4.64.0611091047120.25481@alien.or.mcafeemobile.com>
 <20061109191036.GA30138@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
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
Received: from x35.xmailserver.org ([69.30.125.51]:19436 "EHLO
	x35.xmailserver.org") by vger.kernel.org with ESMTP
	id S1161783AbWKITmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 14:42:52 -0500
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.23 ESMTP Server]
	id <S1FC3DA> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Thu, 9 Nov 2006 11:42:49 -0800
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061109191036.GA30138@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Nov 2006, Evgeniy Polyakov wrote:

> On Thu, Nov 09, 2006 at 10:51:56AM -0800, Davide Libenzi (davidel@xmailserver.org) wrote:
> > On Thu, 9 Nov 2006, Evgeniy Polyakov wrote:
> > 
> > > +static int kevent_poll_callback(struct kevent *k)
> > > +{
> > > +	if (k->event.req_flags & KEVENT_REQ_LAST_CHECK) {
> > > +		return 1;
> > > +	} else {
> > > +		struct file *file = k->st->origin;
> > > +		unsigned int revents = file->f_op->poll(file, NULL);
> > > +
> > > +		k->event.ret_data[0] = revents & k->event.event;
> > > +		
> > > +		return (revents & k->event.event);
> > > +	}
> > > +}
> > 
> > You need to be careful that file->f_op->poll is not called inside the 
> > spin_lock_irqsave/spin_lock_irqrestore pair, since (even this came up 
> > during epoll developemtn days) file->f_op->poll might do a simple 
> > spin_lock_irq/spin_unlock_irq. This unfortunate constrain forced epoll to 
> > have a suboptimal double O(R) loop to handle LT events.
>  
> It is tricky - users call wake_up() from any context, which in turn ends
> up calling kevent_storage_ready(), which calls kevent_poll_callback() with
> KEVENT_REQ_LAST_CHECK bit set, which becomes almost empty call in fast
> path. Since callback returns 1, kevent will be queued into ready queue,
> which is processed on behalf of syscalls - in that case kevent will
> check the flag and since KEVENT_REQ_LAST_CHECK is set, will call
> callback again to check if kevent is correctly marked, but already
> without that flag (it happens in syscall context, i.e. process context
> without any locks held), so callback calls ->poll(), which can sleep,
> but it is safe. If ->poll() returns 'ready' value, kevent is transfers
> data into userspace, otherwise it is 'requeued' (just removed from
> ready queue).

Oh, mine was only a general warn. I hadn't looked at the generic code 
before. But now that I poke on it, I see:

void kevent_requeue(struct kevent *k)
{
       unsigned long flags;

       spin_lock_irqsave(&k->st->lock, flags);
       __kevent_requeue(k, 0);
       spin_unlock_irqrestore(&k->st->lock, flags);
}

and then:

static int __kevent_requeue(struct kevent *k, u32 event)
{
       int ret, rem;
       unsigned long flags;

       ret = k->callbacks.callback(k);

Isn't the k->callbacks.callback() possibly end up calling f_op->poll?



- Davide


