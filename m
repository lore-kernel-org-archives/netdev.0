From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [take24 3/6] kevent: poll/select() notifications.
Date: Thu, 9 Nov 2006 10:51:56 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611091047120.25481@alien.or.mcafeemobile.com>
References: <11630606373650@2ka.mipt.ru>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754300AbWKISwG@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11630606373650@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Nov 2006, Evgeniy Polyakov wrote:

> +static int kevent_poll_callback(struct kevent *k)
> +{
> +	if (k->event.req_flags & KEVENT_REQ_LAST_CHECK) {
> +		return 1;
> +	} else {
> +		struct file *file = k->st->origin;
> +		unsigned int revents = file->f_op->poll(file, NULL);
> +
> +		k->event.ret_data[0] = revents & k->event.event;
> +		
> +		return (revents & k->event.event);
> +	}
> +}

You need to be careful that file->f_op->poll is not called inside the 
spin_lock_irqsave/spin_lock_irqrestore pair, since (even this came up 
during epoll developemtn days) file->f_op->poll might do a simple 
spin_lock_irq/spin_unlock_irq. This unfortunate constrain forced epoll to 
have a suboptimal double O(R) loop to handle LT events.



- Davide
