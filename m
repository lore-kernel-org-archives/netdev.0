From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Mon, 12 Mar 2007 16:05:48 +0300
Message-ID: <45F5502C.1000905@ru.mvista.com>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:59609 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S965828AbXCLNGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 09:06:01 -0400
In-Reply-To: <20070311121615.GF8133@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Mark Brown wrote:

>>   Oops, I was going to recast the patch but my attention switched 
>>   elsewhere for couple of days, and it "slipped" into mainline. I'm now 
>>preparing a better patch to also protect...

> Ah, I was also looking at it.  I enclose my current patch which appears
> to work although I have not finished testing it yet.

>>>interrupt handler, check the dev->state __LINK_STATE_SCHED flag - if 
>>>it's set, leave immediately, it can't be our interrupt. If it's clear, 
>>>read the irq enable hardware register.  If enabled, do the rest of the 
>>>interrupt handler.

>>   It seems that there's no need to read it, as it gets set to 0 
>>"synchronously" with setting the 'hands_off' flag (except in NAPI 
>>callback)...

> hands_off is stronger than that - it's used for sync with some of the
> other code paths like suspend/resume and means "don't touch the chip".
> I've added a new driver local flag instead.

    I'm not sure it was worth it -- we already had __LINK_STATE_RX_SCHED...

>>   Yeah, it seems currently unjustified.  However IntrEnable would have 
>>   been an ultimate criterion on taking or ignoring an interrupt otherwise...

>>>I guess the tradeoff depends on the probability 
>>>of getting the isr called when NAPI is active for the device.

>>   Didn't get it... :-/

    I mean I didn't understand why there's tradeoff and how it depends on the 
probability...

> Some systems can provoke this fairly easily - Sokeris have some boards
> where at least three natsemis share a single interrupt line, for example
> (the model I'm looking at has three, they look to have another
> configuration where 5 would end up on the line).

    PCI means IRQ sharing, generally. So, it should have been fixed anyway. :-)

>>   BTW, it seems I've found another interrupt lossage path in the driver:

>>netdev_poll() -> netdev_rx() -> reset_rx()

>>If the netdev_rx() detects an oversized packet, it will call reset_rx() 
>>which will spin in a loop "collecting" interrupt status until it sees 
>>RxResetDone there.  The issue is 'intr_status' field will get overwritten 
>>and interrupt status lost after netdev_rx() returns to netdev_poll().  How 
>>do you think, is this corner case worth fixing (by moving netdev_rx() call
>>to the top of a do/while loop)?

> Moving netdev_rx() would fix that one but there's some others too -
> there's one in the timer routine if the chip crashes.  In the case you

    Erm, sorry, I'm not seeing it -- could you "point with finger" please? :-)

> describe above the consequences shouldn't be too bad since it tends to
> only occur at high volume so further traffic will tend to occur and
> cause things to recover - all the testing of that patch was done with
> the bug present and no ill effects.

    Oversized packets occur only at high volume? Is it some errata?

> Subject: natsemi: Fix NAPI for interrupt sharing
> To: Jeff Garzik <jeff@garzik.org>
> Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, Simon Blake <simon@citylink.co.nz>, John Philips <johnphilips42@yahoo.com>, netdev@vger.kernel.org

> The interrupt status register for the natsemi chips is clear on read and
> was read unconditionally from both the interrupt and from the NAPI poll
> routine, meaning that if the interrupt service routine was called (for 
> example, due to a shared interrupt) while a NAPI poll was scheduled
> interrupts could be missed.  This patch fixes that by ensuring that the
> interrupt status register is only read when there is no poll scheduled.

> It also reverts a workaround for this problem from the netpoll hook.

> Thanks to Sergei Shtylyov <sshtylyov@ru.mvista.com> for spotting the
> issue and Simon Blake <simon@citylink.co.nz> for testing resources.

    Thanks for the patch!
    (If I only knew somebody else was working on that issue, it could have 
saved my cycles, sigh... but well, I should have said  that I was going to 
recast the patch. :-)

> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

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

    Yeah, I've suspected that we need to grab np->lock here... but does that 
separate spinlock actually protect us from anything?

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

    Why? :-O

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

WBR, Sergei
