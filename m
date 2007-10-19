From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] flush_work_sync vs. flush_scheduled_work Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Fri, 19 Oct 2007 09:50:14 +0200
Message-ID: <20071019075014.GA1765@ff.dom.local>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local> <20071018063157.GA1694@ff.dom.local> <20071018070531.GA2065@ff.dom.local> <20071018154819.GA425@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Maciej W\. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934670AbXJSHrU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071018154819.GA425@tv-sign.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 18, 2007 at 07:48:19PM +0400, Oleg Nesterov wrote:
> On 10/18, Jarek Poplawski wrote:
> >
> > +/**
> > + * flush_work_sync - block until a work_struct's callback has terminated
>                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Hmm...
> 
> > + * Similar to cancel_work_sync() but will only busy wait (without cancel)
> > + * if the work is queued.
> 
> Yes, it won't block, but will spin in busy-wait loop until all other works
> scheduled before this work are finished. Not good. After that it really
> blocks waiting for this work to complete.
> 
> And I am a bit confused. We can't use flush_workqueue() because some of the
> queued work_structs may take rtnl_lock, yes? But in that case we can't use
> the new flush_work_sync() helper as well, no?

OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPS!

Of course, we can't!!! I remembered there was this issue long time
ago, but then I've had some break in tracking net & workqueue. So,
while reading this patch I was alarmed at first, and self-misled
later. I think, there is definitely needed some warning about
locking (or unlocking) during these flush_ & cancel_ functions.
(Btw, I've very much wondered now, why I didn't notice at that 'old'
time, that you added such a great feature (wrt. locking) and I even
didn't notice this...). 

So, Maciej (and other readers of this thread) - I withdraw my false
opinion from my second message here: it's very wrong to call this
sched_work_sync() with rtnl_lock(). It's only less probable to lockup
with this than with flush_schedule_work().

> 
> If we can't just cancel the work, can't we do something like
> 
> 	if (cancel_work_sync(w))
> 		w->func(w);
> 
> instead?
> 
> > +void flush_work_sync(struct work_struct *work)
> > +{
> > +	int ret;
> > +
> > +	do {
> > +		ret = work_pending(work);
> > +		wait_on_work(work);
> > +		if (ret)
> > +			cpu_relax();
> > +	} while (ret);
> > +}
> 
> If we really the new helper, perhaps we can make it a bit better?
> 
> 1. Modify insert_work() to take the "struct list_head *at" parameter instead
>    of "int tail". I think this patch will also cleanup the code a bit, and
>    shrink a couple of bytes from .text

Looks like a very good idea, but I need more time to rethink this.
Probably some code example should be helpful.

> 
> 2. flush_work_sync() inserts a barrier right after this work and blocks.
>    We still need some retry logic to handle the queueing is in progress
>    of course, but we won't spin waiting for the other works.

Until monday I should have an opinion on that (today a bit under
fire...).

> 
> What do you think?

Since there is no gain wrt. locking with my current proposal, I
withdraw this patch of course.

It looks like my wrong patch was great idea because we got this very
precious Oleg's opinion! (I know I'm a genius sometimes...)

Thanks very much,
Jarek P.
