From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [patch 3/6] 2.6.18: sb1250-mac: Phylib IRQ handling fixes
Date: Mon, 23 Oct 2006 19:02:12 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610231752440.4426@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
 <E2ACBAE3-B0E1-4D90-BF25-6981543090C4@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:51212 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S964983AbWJWSCP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 14:02:15 -0400
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <E2ACBAE3-B0E1-4D90-BF25-6981543090C4@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Oct 2006, Andy Fleming wrote:

> I've been trying to figure out this problem since you posted this, and I'm not
> sure I understand it fully (And I apologize profusely for the horror that is
> the PHY interrupt handling code.  I'd love to rewrite it if there's some

 First of all I don't see much of the need to use soft timers with an 
interrupt-driven PHY.  Most of the state changes could be invoked straight 
from phy_change(), perhaps with an exception for the autonegotiation 
timeout.

> cleaner way.).  But let me see if I can follow the chain of reasoning that led
> to this patch, and see if we can figure out a solution that doesn't involve
> creating a work queue just for bringing down the PHY.

 Avoiding a separate work queue was my intent as well.

> 1) Invoking phy_stop is meant to stop the system from looking for PHY status
> updates.  Currently, another PHY sharing the interrupt can cause the HALTED
> PHY to reenable interrupts.  Checking for HALTED in the interrupt handler
> fixes this, but it's incorrect.  The phy_interrupt handler does not grab the
> lock, and so you could get this:
> 
> phy_stop
> 	lock
> 	clear any pending interrupts
> 	disable interrupts on this PHY
> ---> interrupt from another PHY causes this PHY's interrupt handler to be
> invoked
> 	HALTED isn't set, so phy_change is scheduled
> <--- set HALTED, unlock
> 
> scheduled work is done:
> 	interrupt is reenabled
> 
> Sadly, I think the only way to fix this problem is to have phy_change check
> for HALTED, and react appropriately.

 Please have a look at how I have rewritten phy_stop() to avoid this 
problem with no need for a lock -- HALTED is set first and only then 
interrupts are masked and cleared for this PHY.  It can be done without 
locking because the interrupt handler is strictly a consumer and 
phy_stop() is strictly a producer and we do not care about any other 
transitions [1].

> 2) The PHY lib doesn't clear out remaining work in the work queue when it's
> bringing down a PHY.  This is clearly wrong, but I'm confused how *any* driver
> does this?  It seems to me that any network driver which has a work queue is
> going to be unable to flush the pending work when it is brought down.  So
> what's the solution to this?

 The only driver that seems to care is tg3.c and it gets away by other 
means.  Note that network drivers can quite easily handle and ignore 
deferred interrupt work as long as it arrives before they are removed from 
memory.  All that is required is calling flush_scheduled_work() from their 
module_exit() call at the very latest.

> I'm not too enthusiastic about requiring the ethernet drivers to call
> phy_disconnect in a separate thread after "close" is called.  Assuming there's
> not some sort of "squash work queue" function that can be invoked with
> rtnl_lock held, I think phy_disconnect should schedule itself to flush the
> queue.  This would also require that mdiobus_unregister hold off on freeing
> phydevs if any of the phys were still waiting for pending flush_pending calls
> to finish.  Which would, in turn, require mdiobus_unregister to schedule
> cleaning up memory for some later time.

 This could work, indeed.

> I'm not enthusiastic about that implementation, either, but it maintains the
> abstractions I consider important for this code.  The ethernet driver should
> not need to know what structures the PHY lib uses to implement its interrupt
> handling, and how to work around their failings, IMHO.

 Agreed.

> >@@ -484,6 +487,9 @@ static irqreturn_t phy_interrupt(int irq
> > {
> >  struct phy_device *phydev = phy_dat;
> >
> >+	if (PHY_HALTED == phydev->state)
> >+		return IRQ_NONE;		/* It can't be ours.  */
> >+
> 
> 
> As I mentioned, this doesn't protect it, since it doesn't grab the lock.  And
> it can't grab the lock, or we'd have to disable interrupts while doing phy
> transactions.  And we can't do that, because one design goal is to allow some
> bus drivers to use interrupts to signal that the transaction has completed.
> Admittedly, this is still quite broken right now.  I'm looking into using
> semaphores, on the theory that I can sleep when I grab them.  But that would
> still prevent taking the semaphore in the interrupt controller.  This needs to
> be moved to phy_change (which you have done, anyway), and we just have to let
> the actual handler figure out whether it's safe to do anything.

 There is no problem with accessing the state here -- see above[1] and
below[2].

> >@@ -577,6 +583,13 @@ int phy_stop_interrupts(struct phy_devic
> >  if (err)
> >   phy_error(phydev);
> >
> >+	/*
> >+	 * Finish any pending work; we might have been scheduled
> >+	 * to be called from keventd ourselves, though.
> >+	 */
> >+	if (!current_is_keventd())
> >+		flush_scheduled_work();
> >+
> 
> 
> And this is what is making you move your call to phy_disconnect to a work
> queue function, right?  Does this make it so phy_stop_interrupts (and anything
> that calls it) can't be called with rtnl_lock held?  I'd like to avoid that
> requirement, if at all possible.

 Yes.  I would like just to call flush_scheduled_work() here.  But as you 
have noticed, this will most likely lock up if called with rtnl_lock held.  
So the *assumption* here is the caller took care of scheduling this call 
through keventd if rtnl_lock was held at the point phy_stop_interrupts() 
should have been called *or* if the lock was not held and the caller 
decided to call this function directly for simplicity, then the 
flush_scheduled_work() indeed has to be called.

> >@@ -603,7 +616,8 @@ static void phy_change(void *data)
> >  enable_irq(phydev->irq);
> >
> >	/* Reenable interrupts */
> >-	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
> >+	if (PHY_HALTED != phydev->state)
> >+		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
> 
> 
> Eek!  You're checking the phydev->state outside of a lock.  That's very
> unsafe.

 Hmm, it could just be an omission -- I'll try to recall whether I did it 
for any specific reason or not.

> >@@ -624,18 +638,24 @@ void phy_stop(struct phy_device *phydev)
> >  if (PHY_HALTED == phydev->state)
> >   goto out_unlock;
> >
> >-	if (phydev->irq != PHY_POLL) {
> >-		/* Clear any pending interrupts */
> >-		phy_clear_interrupt(phydev);
> >+	phydev->state = PHY_HALTED;
> >
> >+	if (phydev->irq != PHY_POLL) {
> >   /* Disable PHY Interrupts */
> >   phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
> >-	}
> >
> >-	phydev->state = PHY_HALTED;
> >+		/* Clear any pending interrupts */
> >+		phy_clear_interrupt(phydev);
> >+	}
> 
> 
> This all seems good.  I was just thinking a few minutes ago that disabling the
> interrupts should be done before clearing the interrupts.  And setting HALTED
> first should mean that we can move the unlock call up.

 HALTED is set first, so no race with the interrupt handler[2].

> > out_unlock:
> >	spin_unlock(&phydev->lock);
> >+
> >+	/*
> >+	 * Cannot call flush_scheduled_work() here as desired because
> >+	 * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
> >+	 * will not reenable interrupts.
> >+	 */
> 
> 
> Yeah, I don't think we need the comment, necessarily; phy_change will be
> protected (as long as the HALTED check is moved inside a lock).

 As you prefer. ;-)

  Maciej
