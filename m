From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] flush_work_sync vs. flush_scheduled_work Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Mon, 22 Oct 2007 22:02:59 +0400
Message-ID: <20071022180259.GA967@tv-sign.ru>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local> <20071018063157.GA1694@ff.dom.local> <20071018070531.GA2065@ff.dom.local> <20071018154819.GA425@tv-sign.ru> <20071019075014.GA1765@ff.dom.local> <20071022061143.GA973@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x346.tv-sign.ru ([89.108.83.215]:57159 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903AbXJVR6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 13:58:15 -0400
Content-Disposition: inline
In-Reply-To: <20071022061143.GA973@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22, Jarek Poplawski wrote:
>
> On Fri, Oct 19, 2007 at 09:50:14AM +0200, Jarek Poplawski wrote:
> > On Thu, Oct 18, 2007 at 07:48:19PM +0400, Oleg Nesterov wrote:
> > > On 10/18, Jarek Poplawski wrote:
> > > >
> > > > +/**
> > > > + * flush_work_sync - block until a work_struct's callback has terminated
> > >                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > > Hmm...
> > > 
> > > > + * Similar to cancel_work_sync() but will only busy wait (without cancel)
> > > > + * if the work is queued.
> > > 
> > > Yes, it won't block, but will spin in busy-wait loop until all other works
> > > scheduled before this work are finished. Not good. After that it really
> > > blocks waiting for this work to complete.
> > > 
> > > And I am a bit confused. We can't use flush_workqueue() because some of the
> > > queued work_structs may take rtnl_lock, yes? But in that case we can't use
> > > the new flush_work_sync() helper as well, no?
> 
> OK, I know I'm dumber and dumber everyday,

You are not alone. I have the same feeling about myself!

> these all flushes are
> rtnl lockup vulnerable wrt. other work functions, but cancel_work_sync
> looks perfectly fine

Yes,

> Then, if by any chance I'm right, something like flush_work_sync
> (or changed flush_scheduled_work, if there is no problem with such
> a change of implementation) could be safely (if it's called without
> locks used by flushed work only) done cancel_work_sync() way, by
> running a work function after try_to_grab_pending() returns 1

If this work doesn't rearm itself - yes. (otherwise, the same ->func
can run twice _at the same time_)

But again, in this case wait_on_work() after try_to_grab_pending() == 1
doesn't block, so we can just do

	if (cancel_work_sync(w))
		w->func();

Oleg.

