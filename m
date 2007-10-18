From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Thu, 18 Oct 2007 12:30:35 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0710171221510.28993@blysk.ds.pg.gda.pl>
References: <20071015125301.GC3015@ff.dom.local>
 <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local>
 <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:56728 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759929AbXJRLap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 07:30:45 -0400
In-Reply-To: <20071017085809.GA1658@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Oct 2007, Jarek Poplawski wrote:

> I'm not sure free_irq() should maintain the depth count - rather warn
> on not zero. But, IMHO, any activity on freed irq seems suspicious to
> me (and doesn't look like very common), even if it's safe with current
> implementation.

 No way to avoid it with DEBUG_SHIRQ.

> Yes, these DEBUG_SHIRQ checks are suspicious to me too, but they seem
> to be reasonable only in the case of possible resent irqs (so not for
> all irqs). On the other hand, it seems, proper irq handler with proper
> hardware shouldn't have any problems with such a check.

 What do you mean by "proper irq handler with proper hardware"?  Using
softirqs (they used to be called bottom-halves) is actually a natural way 
of handling any interrupt which requires extensive processing.

> 1) phy_change() checks PHY_HALTED flag without lock; I think it's
> racy: eg. if it's done during phy_stop() it can check just before
> the flag is set and reenable interrupts just after phy_stop() ends.

 I remember having a look into it, but it was long ago and I cannot 
immediately recall the conclusion.  Which means it is either broken or 
deserves a comment as non-obvious.  I will have a look into it again, but 
I am resource-starved a little at the moment, sorry.

> 2) phy_change() doesn't reenable irq line after it sees returns
> with errors; IMHO it should at least write some warning, but maybe
> try some safety plan, so enable_irq() and try to disable interrupts
> and free_irq() on the next call (if it happens). (But, I can be very
> wrong with this - maybe it's OK and official way.)

 No way to do this safely -- at this point the device probably still has 
its interrupt output asserted and the register to clear it is 
inaccessible, so enabling the line will enter an infinite loop.  At this 
point the system is no longer stable, so it is better to keep at least 
some functionality, so that it may be attempted to be shut down cleanly, 
rather than make it completely irresponsive.  The alternative is panic().

> 3) phy_interrupt() checks PHY_HALTED flag without lock too, but I'm
> not sure now if it could be dangerous after fixing #1; on the other
> hand even if we know it's not our regular interrupt, with current
> DEBUG_SHIRQ it could be easier to call schedule_work() anyway since
> we are sure it's before/in free_irq() yet.

  See #1 above.

> 4) phy_interrupt() should check return value from schedule_work() and
> enable irq on 0.

 No -- the work already pending will do that.

> 5) phy_stop_interrupts(): maybe I miss something, but it seems
> phy_stop() is required before this, so maybe there should be a
> comment on this?

 The API is documented in: Documentation/networking/phy.txt -- you are 
welcome to improve.  If you do not want to get into the gory details, just 
use the cooked interface and phy_disconnect() will do the dirty work for 
you.

> 6) phy_stop_interrupts(): if I'm not wrong with #3 calling
> phy_disable_interrupts() looks like we are not sure this phy_stop()
> really works; than maybe a WARN_ON?

 WARN_ON what?

> 7) phy_stop_interrupts(): after above mentioned changes in
> phy_interrupt(), and phy_changes() (always enable_irq()) I can't see
> any reason why there should be more than one skipped enable_irq(),
> so checking return from cancel_work_sync() shouldn't be enough
> instead of this atomic counter.

 CONFIG_DEBUG_SHIRQ.  Barring this option, cancel_work_sync() could have 
been moved to the front of free_irq().  I think I have seen this in 
reality, with the interrupt line left stuck disabled afterwards, but I 
will double check when I have an opportunity.  The approach implemented 
with this patch does work, which is the important bit, and if 
simplification is possible, then it may be applied later.

> 8) phy_stop_interrupts(): I'm not sure this additional call from
> DEBUG_SHIRQ should be so dangerous, eg.:
> 
> 	/*
> 	 * status == PHY_HALTED &&
> 	 * interrupts are stopped after phy_stop()
> 	 */
> 	if (cancel_work_sync(...))
> 		enable_irq();
> 
> 	free_irq(...);
> 	/*
> 	 * possible schedule_work() from DEBUG_SHIRQ only,
> 	 * but proper check for PHY_HALTED is done;
> 	 * so, let's flush after this too:
> 	 */
> 	cancel_work_sync();

 Well, if there is another handler registered on this line, you'll get 
your interrupt line stuck disabled.

> Of course, I don't know phy.c enough, so most of this can be terribly
> wrong, then feel free to forget about this - I don't expect you should
> waste any time for explaining me these things - after all they are
> doubts only.

 I am not sure I know phy.c well enough either, ;-) and your concerns are 
appreciated as interesting conclusions may develop.  If someone disagrees 
with what I have written here, they are welcome to speak out too.

  Maciej
