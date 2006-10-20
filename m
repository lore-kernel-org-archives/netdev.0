From: Andy Fleming <afleming@freescale.com>
Subject: Re: [patch 3/6] 2.6.18: sb1250-mac: Phylib IRQ handling fixes
Date: Fri, 20 Oct 2006 16:40:20 -0500
Message-ID: <E2ACBAE3-B0E1-4D90-BF25-6981543090C4@freescale.com>
References: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org


On Oct 3, 2006, at 10:18, Maciej W. Rozycki wrote:

> Hello,
>
>  This patch fixes a couple of problems discovered with interrupt  
> handling
> in the phylib core, namely:
>
> 1. The driver uses timer and workqueue calls, but does not include
>    <linux/timer.h> nor <linux/workqueue.h>.


Good catch.


>
> 2. The driver uses schedule_work() for handling interrupts, but  
> does not
>    make sure any pending work scheduled thus has been completed before
>    driver's structures get freed from memory.  This is especially
>    important as interrupts may keep arriving if the line is shared  
> with
>    another PHY.
>
>    The solution is to ignore phy_interrupt() calls if the reported  
> device
>    has already been halted and calling flush_scheduled_work() from
>    phy_stop_interrupts() (but guarded with current_is_keventd() in  
> case
>    the function has been called through keventd from the MAC device's
>    close call to avoid a deadlock on the netlink lock).


I've been trying to figure out this problem since you posted this,  
and I'm not sure I understand it fully (And I apologize profusely for  
the horror that is the PHY interrupt handling code.  I'd love to  
rewrite it if there's some cleaner way.).  But let me see if I can  
follow the chain of reasoning that led to this patch, and see if we  
can figure out a solution that doesn't involve creating a work queue  
just for bringing down the PHY.

1) Invoking phy_stop is meant to stop the system from looking for PHY  
status updates.  Currently, another PHY sharing the interrupt can  
cause the HALTED PHY to reenable interrupts.  Checking for HALTED in  
the interrupt handler fixes this, but it's incorrect.  The  
phy_interrupt handler does not grab the lock, and so you could get this:

phy_stop
	lock
	clear any pending interrupts
	disable interrupts on this PHY
---> interrupt from another PHY causes this PHY's interrupt handler  
to be invoked
	HALTED isn't set, so phy_change is scheduled
<--- set HALTED, unlock

scheduled work is done:
	interrupt is reenabled

Sadly, I think the only way to fix this problem is to have phy_change  
check for HALTED, and react appropriately.

2) The PHY lib doesn't clear out remaining work in the work queue  
when it's bringing down a PHY.  This is clearly wrong, but I'm  
confused how *any* driver does this?  It seems to me that any network  
driver which has a work queue is going to be unable to flush the  
pending work when it is brought down.  So what's the solution to this?

I'm not too enthusiastic about requiring the ethernet drivers to call  
phy_disconnect in a separate thread after "close" is called.   
Assuming there's not some sort of "squash work queue" function that  
can be invoked with rtnl_lock held, I think phy_disconnect should  
schedule itself to flush the queue.  This would also require that  
mdiobus_unregister hold off on freeing phydevs if any of the phys  
were still waiting for pending flush_pending calls to finish.  Which  
would, in turn, require mdiobus_unregister to schedule cleaning up  
memory for some later time.

I'm not enthusiastic about that implementation, either, but it  
maintains the abstractions I consider important for this code.  The  
ethernet driver should not need to know what structures the PHY lib  
uses to implement its interrupt handling, and how to work around  
their failings, IMHO.

And now, to be more specific, a few comments on the patch, directly:

>
>  Please consider.
>
>   Maciej
>
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
>
> patch-mips-2.6.18-20060920-phy-irq-16
> diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/ 
> drivers/net/phy/phy.c linux-mips-2.6.18-20060920/drivers/net/phy/phy.c
> --- linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c	 
> 2006-08-05 04:58:46.000000000 +0000
> +++ linux-mips-2.6.18-20060920/drivers/net/phy/phy.c	2006-10-03  
> 14:19:21.000000000 +0000
> @@ -7,6 +7,7 @@
>   * Author: Andy Fleming
>   *
>   * Copyright (c) 2004 Freescale Semiconductor, Inc.
> + * Copyright (c) 2006  Maciej W. Rozycki
>   *
>   * This program is free software; you can redistribute  it and/or  
> modify it
>   * under  the terms of  the GNU General  Public License as  
> published by the
> @@ -32,6 +33,8 @@
>  #include <linux/mii.h>
>  #include <linux/ethtool.h>
>  #include <linux/phy.h>
> +#include <linux/timer.h>
> +#include <linux/workqueue.h>
>
>  #include <asm/io.h>
>  #include <asm/irq.h>
> @@ -484,6 +487,9 @@ static irqreturn_t phy_interrupt(int irq
>  {
>  	struct phy_device *phydev = phy_dat;
>
> +	if (PHY_HALTED == phydev->state)
> +		return IRQ_NONE;		/* It can't be ours.  */
> +


As I mentioned, this doesn't protect it, since it doesn't grab the  
lock.  And it can't grab the lock, or we'd have to disable interrupts  
while doing phy transactions.  And we can't do that, because one  
design goal is to allow some bus drivers to use interrupts to signal  
that the transaction has completed.  Admittedly, this is still quite  
broken right now.  I'm looking into using semaphores, on the theory  
that I can sleep when I grab them.  But that would still prevent  
taking the semaphore in the interrupt controller.  This needs to be  
moved to phy_change (which you have done, anyway), and we just have  
to let the actual handler figure out whether it's safe to do anything.


>  	/* The MDIO bus is not allowed to be written in interrupt
>  	 * context, so we need to disable the irq here.  A work
>  	 * queue will write the PHY to disable and clear the
> @@ -577,6 +583,13 @@ int phy_stop_interrupts(struct phy_devic
>  	if (err)
>  		phy_error(phydev);
>
> +	/*
> +	 * Finish any pending work; we might have been scheduled
> +	 * to be called from keventd ourselves, though.
> +	 */
> +	if (!current_is_keventd())
> +		flush_scheduled_work();
> +


And this is what is making you move your call to phy_disconnect to a  
work queue function, right?  Does this make it so phy_stop_interrupts  
(and anything that calls it) can't be called with rtnl_lock held?   
I'd like to avoid that requirement, if at all possible.


>  	free_irq(phydev->irq, phydev);
>
>  	return err;
> @@ -603,7 +616,8 @@ static void phy_change(void *data)
>  	enable_irq(phydev->irq);
>
>  	/* Reenable interrupts */
> -	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
> +	if (PHY_HALTED != phydev->state)
> +		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);


Eek!  You're checking the phydev->state outside of a lock.  That's  
very unsafe.


>
>  	if (err)
>  		goto irq_enable_err;
> @@ -624,18 +638,24 @@ void phy_stop(struct phy_device *phydev)
>  	if (PHY_HALTED == phydev->state)
>  		goto out_unlock;
>
> -	if (phydev->irq != PHY_POLL) {
> -		/* Clear any pending interrupts */
> -		phy_clear_interrupt(phydev);
> +	phydev->state = PHY_HALTED;
>
> +	if (phydev->irq != PHY_POLL) {
>  		/* Disable PHY Interrupts */
>  		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
> -	}
>
> -	phydev->state = PHY_HALTED;
> +		/* Clear any pending interrupts */
> +		phy_clear_interrupt(phydev);
> +	}


This all seems good.  I was just thinking a few minutes ago that  
disabling the interrupts should be done before clearing the  
interrupts.  And setting HALTED first should mean that we can move  
the unlock call up.


>
>  out_unlock:
>  	spin_unlock(&phydev->lock);
> +
> +	/*
> +	 * Cannot call flush_scheduled_work() here as desired because
> +	 * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
> +	 * will not reenable interrupts.
> +	 */


Yeah, I don't think we need the comment, necessarily; phy_change will  
be protected (as long as the HALTED check is moved inside a lock).

Andy
