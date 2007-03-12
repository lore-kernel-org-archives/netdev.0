From: Mark Huth <mhuth@mvista.com>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Mon, 12 Mar 2007 12:05:46 -0700
Message-ID: <45F5A48A.8040903@mvista.com>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:4614 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbXCLTG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 15:06:27 -0400
In-Reply-To: <20070311121615.GF8133@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> On Sat, Mar 10, 2007 at 11:25:05PM +0300, Sergei Shtylyov wrote:
>
>   
>>    Oops, I was going to recast the patch but my attention switched 
>>    elsewhere for couple of days, and it "slipped" into mainline. I'm now 
>> preparing a better patch to also protect...
>>     
>
> Ah, I was also looking at it.  I enclose my current patch which appears
> to work although I have not finished testing it yet.
>
>   
>>> interrupt handler, check the dev->state __LINK_STATE_SCHED flag - if 
>>> it's set, leave immediately, it can't be our interrupt. If it's clear, 
>>> read the irq enable hardware register.  If enabled, do the rest of the 
>>> interrupt handler.
>>>       
>
>   
>>    It seems that there's no need to read it, as it gets set to 0 
>> "synchronously" with setting the 'hands_off' flag (except in NAPI 
>> callback)...
>>     
>
> hands_off is stronger than that - it's used for sync with some of the
> other code paths like suspend/resume and means "don't touch the chip".
> I've added a new driver local flag instead.
>
>   
>>    Yeah, it seems currently unjustified.  However IntrEnable would have 
>>    been an ultimate criterion on taking or ignoring an interrupt otherwise...
>>     
>
>   
>>> I guess the tradeoff depends on the probability 
>>> of getting the isr called when NAPI is active for the device.
>>>       
>
>   
>>    Didn't get it... :-/
>>     
>
> Some systems can provoke this fairly easily - Sokeris have some boards
> where at least three natsemis share a single interrupt line, for example
> (the model I'm looking at has three, they look to have another
> configuration where 5 would end up on the line).
>
>   
>>    BTW, it seems I've found another interrupt lossage path in the driver:
>>     
>
>   
>> netdev_poll() -> netdev_rx() -> reset_rx()
>>     
>
>   
>> If the netdev_rx() detects an oversized packet, it will call reset_rx() 
>> which will spin in a loop "collecting" interrupt status until it sees 
>> RxResetDone there.  The issue is 'intr_status' field will get overwritten 
>> and interrupt status lost after netdev_rx() returns to netdev_poll().  How 
>> do you think, is this corner case worth fixing (by moving netdev_rx() call
>> to the top of a do/while loop)?
>>     
>
> Moving netdev_rx() would fix that one but there's some others too -
> there's one in the timer routine if the chip crashes.  In the case you
> describe above the consequences shouldn't be too bad since it tends to
> only occur at high volume so further traffic will tend to occur and
> cause things to recover - all the testing of that patch was done with
> the bug present and no ill effects.
>   
The proposed patch would seem to be way overkill.  The problem, as 
solved in this patch, at least is just the prevention of the ISR from 
reading the intr_status while another context (NAPI) is still active.  
The simplest fix is to revert the netpoll attempted fix and then modify 
the isr etnry criteria as follows:

--- natsemi.c   2006-09-19 20:42:06.000000000 -0700
+++ natsemi.c.new       2007-03-12 11:35:28.000000000 -0700
@@ -2094,7 +2094,7 @@
        struct netdev_private *np = netdev_priv(dev);
        void __iomem * ioaddr = ns_ioaddr(dev);

-        if (np->hands_off)
+       if (np->hands_off || !readl(ioaddr + IntrEnable))
                return IRQ_NONE;

        /* Reading automatically acknowledges. */

Since the interrupts are enabled as the NAPI-callback exits, and the 
interrupts are disabled in the isr after the callback is scheduled, this 
fully avoids the potential race conditions, and requires no locking.  If 
we want to avoid the ioaccess, then this could be augmented with a flag 
in the device private area which would be tested first, short-circuiting 
the ioaccess most of the time when the callback is already scheduled.  
But the IntrEnable still would need to be check to avoid the race on the 
enable/disable condition between the callback and the isr.

It is possible to entirely avoid the IntrEnable access and use only a 
flag, but that requires a local_irqsave/restore around the calback's 
enabling of the interrupt and and clearing of the poll_active flag.  
That is fully up-safe, but may have a theoretical possibility of an 
unserviced (spurious) interrupt on SMP systems.  Such a possibility 
would only exist if an architecture is able to accept an interrupt on a 
second processor and get to the natsemi isr before the the first 
proccesor can clear the poll_active flag.  That can be further minimized 
by omitting the readback of the IntrEnable register, or deferring it 
until after the flag is cleared.

If you would like me to prepare formal patches based on any of these 
concepts, let me know.

Mark Huth
> Subject: natsemi: Fix NAPI for interrupt sharing
> To: Jeff Garzik <jeff@garzik.org>
> Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, Simon Blake <simon@citylink.co.nz>, John Philips <johnphilips42@yahoo.com>, netdev@vger.kernel.org
>
> The interrupt status register for the natsemi chips is clear on read and
> was read unconditionally from both the interrupt and from the NAPI poll
> routine, meaning that if the interrupt service routine was called (for 
> example, due to a shared interrupt) while a NAPI poll was scheduled
> interrupts could be missed.  This patch fixes that by ensuring that the
> interrupt status register is only read when there is no poll scheduled.
>
> It also reverts a workaround for this problem from the netpoll hook.
>
> Thanks to Sergei Shtylyov <sshtylyov@ru.mvista.com> for spotting the
> issue and Simon Blake <simon@citylink.co.nz> for testing resources.
>
> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>
>
> Index: linux-2.6/drivers/net/natsemi.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/natsemi.c	2007-03-11 02:32:43.000000000 +0000
> +++ linux-2.6/drivers/net/natsemi.c	2007-03-11 12:09:14.000000000 +0000
> @@ -571,6 +571,8 @@
>  	int oom;
>  	/* Interrupt status */
>  	u32 intr_status;
> +	int poll_active;
> +	spinlock_t intr_lock;
>  	/* Do not touch the nic registers */
>  	int hands_off;
>  	/* Don't pay attention to the reported link state. */
> @@ -812,9 +814,11 @@
>  	pci_set_drvdata(pdev, dev);
>  	np->iosize = iosize;
>  	spin_lock_init(&np->lock);
> +	spin_lock_init(&np->intr_lock);
>  	np->msg_enable = (debug >= 0) ? (1<<debug)-1 : NATSEMI_DEF_MSG;
>  	np->hands_off = 0;
>  	np->intr_status = 0;
> +	np->poll_active = 0;
>  	np->eeprom_size = natsemi_pci_info[chip_idx].eeprom_size;
>  	if (natsemi_pci_info[chip_idx].flags & NATSEMI_FLAG_IGNORE_PHY)
>  		np->ignore_phy = 1;
> @@ -1406,6 +1410,8 @@
>  	writel(rfcr, ioaddr + RxFilterAddr);
>  }
>  
> +/* MUST be called so that both NAPI poll and ISR are excluded due to
> + * use of intr_status. */
>  static void reset_rx(struct net_device *dev)
>  {
>  	int i;
> @@ -2118,30 +2124,45 @@
>  	struct net_device *dev = dev_instance;
>  	struct netdev_private *np = netdev_priv(dev);
>  	void __iomem * ioaddr = ns_ioaddr(dev);
> +	unsigned long flags;
> +	irqreturn_t status = IRQ_NONE;
>  
>  	if (np->hands_off)
>  		return IRQ_NONE;
>  
> -	/* Reading automatically acknowledges. */
> -	np->intr_status = readl(ioaddr + IntrStatus);
> -
> -	if (netif_msg_intr(np))
> -		printk(KERN_DEBUG
> -		       "%s: Interrupt, status %#08x, mask %#08x.\n",
> -		       dev->name, np->intr_status,
> -		       readl(ioaddr + IntrMask));
> +	spin_lock_irqsave(&np->intr_lock, flags);
>  
> -	if (!np->intr_status)
> -		return IRQ_NONE;
> +	/* Reading IntrStatus automatically acknowledges so don't do
> +	 * that while a poll is scheduled.  */
> +	if (!np->poll_active) {
> +		np->intr_status = readl(ioaddr + IntrStatus);
>  
> -	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
> +		if (netif_msg_intr(np))
> +			printk(KERN_DEBUG
> +			       "%s: Interrupt, status %#08x, mask %#08x.\n",
> +			       dev->name, np->intr_status,
> +			       readl(ioaddr + IntrMask));
> +
> +		if (np->intr_status) {
> +			prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
> +
> +			/* Disable interrupts and register for poll */
> +			if (netif_rx_schedule_prep(dev)) {
> +				natsemi_irq_disable(dev);
> +				__netif_rx_schedule(dev);
> +				np->poll_active = 1;
> +			} else
> +				printk(KERN_WARNING
> +			       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
> +				       dev->name, np->intr_status,
> +				       readl(ioaddr + IntrMask));
>  
> -	if (netif_rx_schedule_prep(dev)) {
> -		/* Disable interrupts and register for poll */
> -		natsemi_irq_disable(dev);
> -		__netif_rx_schedule(dev);
> +			status = IRQ_HANDLED;
> +		}
>  	}
> -	return IRQ_HANDLED;
> +
> +	spin_unlock_irqrestore(&np->intr_lock, flags);
> +	return status;
>  }
>  
>  /* This is the NAPI poll routine.  As well as the standard RX handling
> @@ -2154,8 +2175,15 @@
>  
>  	int work_to_do = min(*budget, dev->quota);
>  	int work_done = 0;
> +	unsigned long flags;
>  
>  	do {
> +		if (netif_msg_intr(np))
> +			printk(KERN_DEBUG
> +			       "%s: Poll, status %#08x, mask %#08x.\n",
> +			       dev->name, np->intr_status,
> +			       readl(ioaddr + IntrMask));
> +
>  		if (np->intr_status &
>  		    (IntrTxDone | IntrTxIntr | IntrTxIdle | IntrTxErr)) {
>  			spin_lock(&np->lock);
> @@ -2182,14 +2210,19 @@
>  		np->intr_status = readl(ioaddr + IntrStatus);
>  	} while (np->intr_status);
>  
> +	/* We need to ensure that the ISR doesn't run between telling
> +	 * NAPI we're done and enabling the interrupt. */
> +	spin_lock_irqsave(&np->intr_lock, flags);
> +
>  	netif_rx_complete(dev);
> +	np->poll_active = 0;
>  
>  	/* Reenable interrupts providing nothing is trying to shut
>  	 * the chip down. */
> -	spin_lock(&np->lock);
> -	if (!np->hands_off && netif_running(dev))
> +	if (!np->hands_off)
>  		natsemi_irq_enable(dev);
> -	spin_unlock(&np->lock);
> +
> +	spin_unlock_irqrestore(&np->intr_lock, flags);
>  
>  	return 0;
>  }
> @@ -2399,19 +2432,8 @@
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void natsemi_poll_controller(struct net_device *dev)
>  {
> -	struct netdev_private *np = netdev_priv(dev);
> -
>  	disable_irq(dev->irq);
> -
> -	/*
> -	 * A real interrupt might have already reached us at this point
> -	 * but NAPI might still haven't called us back.  As the interrupt
> -	 * status register is cleared by reading, we should prevent an
> -	 * interrupt loss in this case...
> -	 */
> -	if (!np->intr_status)
> -		intr_handler(dev->irq, dev);
> -
> +	intr_handler(dev->irq, dev);
>  	enable_irq(dev->irq);
>  }
>  #endif
>
>   

