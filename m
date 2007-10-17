From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Wed, 17 Oct 2007 10:58:09 +0200
Message-ID: <20071017085809.GA1658@ff.dom.local>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W\. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:41484 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757207AbXJQIzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 04:55:09 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 16, 2007 at 06:19:32PM +0100, Maciej W. Rozycki wrote:
...
>  Well, enable_irq() and disable_irq() themselves are nesting, so they are 
> not a problem.  OTOH, free_irq() does not seem to maintain the depth count 
> correctly, which looks like a bug to me and which could trigger regardless 
> of whether flush_scheduled_work() or cancel_work_sync() was called.

I'm not sure free_irq() should maintain the depth count - rather warn
on not zero. But, IMHO, any activity on freed irq seems suspicious to
me (and doesn't look like very common), even if it's safe with current
implementation.

>  The reason is CONFIG_DEBUG_SHIRQ which makes a simulated interrupt event 
> be sent at the end of free_irq().  It looks like a problem that is 
> complementary to one I signalled here:
> 
> http://lkml.org/lkml/2007/9/12/82
> 
> with respect to request_irq(), where, similarly, such an interrupt event 
> is sent at the beginning.  It looks like nobody was concerned back then, 
> but perhaps it is time to do a better investigation now and propose a 
> solution.

Yes, these DEBUG_SHIRQ checks are suspicious to me too, but they seem
to be reasonable only in the case of possible resent irqs (so not for
all irqs). On the other hand, it seems, proper irq handler with proper
hardware shouldn't have any problems with such a check.

>  I'll think about it and thanks for your inquisitiveness that has led to 
> these conclusions.

Btw., since, because of this patch, I've had a one more look at phy.c
and there are a few more doubts, so this time I'll try to bother you
for real:

1) phy_change() checks PHY_HALTED flag without lock; I think it's
racy: eg. if it's done during phy_stop() it can check just before
the flag is set and reenable interrupts just after phy_stop() ends.

2) phy_change() doesn't reenable irq line after it sees returns
with errors; IMHO it should at least write some warning, but maybe
try some safety plan, so enable_irq() and try to disable interrupts
and free_irq() on the next call (if it happens). (But, I can be very
wrong with this - maybe it's OK and official way.)

3) phy_interrupt() checks PHY_HALTED flag without lock too, but I'm
not sure now if it could be dangerous after fixing #1; on the other
hand even if we know it's not our regular interrupt, with current
DEBUG_SHIRQ it could be easier to call schedule_work() anyway since
we are sure it's before/in free_irq() yet.

4) phy_interrupt() should check return value from schedule_work() and
enable irq on 0.

5) phy_stop_interrupts(): maybe I miss something, but it seems
phy_stop() is required before this, so maybe there should be a
comment on this?

6) phy_stop_interrupts(): if I'm not wrong with #3 calling
phy_disable_interrupts() looks like we are not sure this phy_stop()
really works; than maybe a WARN_ON?

7) phy_stop_interrupts(): after above mentioned changes in
phy_interrupt(), and phy_changes() (always enable_irq()) I can't see
any reason why there should be more than one skipped enable_irq(),
so checking return from cancel_work_sync() shouldn't be enough
instead of this atomic counter.

8) phy_stop_interrupts(): I'm not sure this additional call from
DEBUG_SHIRQ should be so dangerous, eg.:

	/*
	 * status == PHY_HALTED &&
	 * interrupts are stopped after phy_stop()
	 */
	if (cancel_work_sync(...))
		enable_irq();

	free_irq(...);
	/*
	 * possible schedule_work() from DEBUG_SHIRQ only,
	 * but proper check for PHY_HALTED is done;
	 * so, let's flush after this too:
	 */
	cancel_work_sync();


Of course, I don't know phy.c enough, so most of this can be terribly
wrong, then feel free to forget about this - I don't expect you should
waste any time for explaining me these things - after all they are
doubts only.

Regards,
Jarek P.
