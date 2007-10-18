From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] flush_work_sync vs. flush_scheduled_work Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Thu, 18 Oct 2007 19:48:19 +0400
Message-ID: <20071018154819.GA425@tv-sign.ru>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local> <20071018063157.GA1694@ff.dom.local> <20071018070531.GA2065@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x346.tv-sign.ru ([89.108.83.215]:49796 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757153AbXJRPnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 11:43:52 -0400
Content-Disposition: inline
In-Reply-To: <20071018070531.GA2065@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/18, Jarek Poplawski wrote:
>
> +/**
> + * flush_work_sync - block until a work_struct's callback has terminated
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Hmm...

> + * Similar to cancel_work_sync() but will only busy wait (without cancel)
> + * if the work is queued.

Yes, it won't block, but will spin in busy-wait loop until all other works
scheduled before this work are finished. Not good. After that it really
blocks waiting for this work to complete.

And I am a bit confused. We can't use flush_workqueue() because some of the
queued work_structs may take rtnl_lock, yes? But in that case we can't use
the new flush_work_sync() helper as well, no?

If we can't just cancel the work, can't we do something like

	if (cancel_work_sync(w))
		w->func(w);

instead?

> +void flush_work_sync(struct work_struct *work)
> +{
> +	int ret;
> +
> +	do {
> +		ret = work_pending(work);
> +		wait_on_work(work);
> +		if (ret)
> +			cpu_relax();
> +	} while (ret);
> +}

If we really the new helper, perhaps we can make it a bit better?

1. Modify insert_work() to take the "struct list_head *at" parameter instead
   of "int tail". I think this patch will also cleanup the code a bit, and
   shrink a couple of bytes from .text

2. flush_work_sync() inserts a barrier right after this work and blocks.
   We still need some retry logic to handle the queueing is in progress
   of course, but we won't spin waiting for the other works.

What do you think?

Oleg.

