From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Mon, 12 Mar 2007 22:12:43 +0300
Message-ID: <45F5A62B.4050205@ru.mvista.com>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk> <45F5502C.1000905@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:61988 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752215AbXCLTMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 15:12:55 -0400
In-Reply-To: <45F5502C.1000905@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, I wrote:

>> Subject: natsemi: Fix NAPI for interrupt sharing
>> To: Jeff Garzik <jeff@garzik.org>
>> Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, Simon Blake 
>> <simon@citylink.co.nz>, John Philips <johnphilips42@yahoo.com>, 
>> netdev@vger.kernel.org

>> The interrupt status register for the natsemi chips is clear on read and
>> was read unconditionally from both the interrupt and from the NAPI poll
>> routine, meaning that if the interrupt service routine was called (for 
>> example, due to a shared interrupt) while a NAPI poll was scheduled
>> interrupts could be missed.  This patch fixes that by ensuring that the
>> interrupt status register is only read when there is no poll scheduled.

>> It also reverts a workaround for this problem from the netpoll hook.

>> Thanks to Sergei Shtylyov <sshtylyov@ru.mvista.com> for spotting the

    Well, I've blithely overlooked it, and it's you who did spot it. :-)

>> issue and Simon Blake <simon@citylink.co.nz> for testing resources.

>    Thanks for the patch!
>    (If I only knew somebody else was working on that issue, it could 
> have saved my cycles, sigh... but well, I should have said  that I was 
> going to recast the patch. :-)

>> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

>> Index: linux-2.6/drivers/net/natsemi.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/net/natsemi.c    2007-03-11 
>> 02:32:43.000000000 +0000
>> +++ linux-2.6/drivers/net/natsemi.c    2007-03-11 12:09:14.000000000 
>> +0000
>> @@ -571,6 +571,8 @@
>>      int oom;
>>      /* Interrupt status */
>>      u32 intr_status;
>> +    int poll_active;
>> +    spinlock_t intr_lock;
>>      /* Do not touch the nic registers */
>>      int hands_off;
>>      /* Don't pay attention to the reported link state. */
>> @@ -812,9 +814,11 @@
>>      pci_set_drvdata(pdev, dev);
>>      np->iosize = iosize;
>>      spin_lock_init(&np->lock);
>> +    spin_lock_init(&np->intr_lock);
>>      np->msg_enable = (debug >= 0) ? (1<<debug)-1 : NATSEMI_DEF_MSG;
>>      np->hands_off = 0;
>>      np->intr_status = 0;
>> +    np->poll_active = 0;
>>      np->eeprom_size = natsemi_pci_info[chip_idx].eeprom_size;
>>      if (natsemi_pci_info[chip_idx].flags & NATSEMI_FLAG_IGNORE_PHY)
>>          np->ignore_phy = 1;
>> @@ -1406,6 +1410,8 @@
>>      writel(rfcr, ioaddr + RxFilterAddr);
>>  }
>>  
>> +/* MUST be called so that both NAPI poll and ISR are excluded due to
>> + * use of intr_status. */
>>  static void reset_rx(struct net_device *dev)
>>  {
>>      int i;
>> @@ -2118,30 +2124,45 @@
>>      struct net_device *dev = dev_instance;
>>      struct netdev_private *np = netdev_priv(dev);
>>      void __iomem * ioaddr = ns_ioaddr(dev);
>> +    unsigned long flags;
>> +    irqreturn_t status = IRQ_NONE;
>>  
>>      if (np->hands_off)
>>          return IRQ_NONE;
>>  
>> -    /* Reading automatically acknowledges. */
>> -    np->intr_status = readl(ioaddr + IntrStatus);
>> -
>> -    if (netif_msg_intr(np))
>> -        printk(KERN_DEBUG
>> -               "%s: Interrupt, status %#08x, mask %#08x.\n",
>> -               dev->name, np->intr_status,
>> -               readl(ioaddr + IntrMask));
>> +    spin_lock_irqsave(&np->intr_lock, flags);

>    Yeah, I've suspected that we need to grab np->lock here... but does 
> that separate spinlock actually protect us from anything?

    I'm also not sure that we need to disable interrupts here.

>> -    if (!np->intr_status)
>> -        return IRQ_NONE;
>> +    /* Reading IntrStatus automatically acknowledges so don't do
>> +     * that while a poll is scheduled.  */
>> +    if (!np->poll_active) {
>> +        np->intr_status = readl(ioaddr + IntrStatus);
>>  
>> -    prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
>> +        if (netif_msg_intr(np))
>> +            printk(KERN_DEBUG
>> +                   "%s: Interrupt, status %#08x, mask %#08x.\n",
>> +                   dev->name, np->intr_status,
>> +                   readl(ioaddr + IntrMask));
>> +
>> +        if (np->intr_status) {
>> +            prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
>> +
>> +            /* Disable interrupts and register for poll */
>> +            if (netif_rx_schedule_prep(dev)) {
>> +                natsemi_irq_disable(dev);
>> +                __netif_rx_schedule(dev);
>> +                np->poll_active = 1;
>> +            } else
>> +                printk(KERN_WARNING
>> +                              "%s: Ignoring interrupt, status %#08x, 
>> mask %#08x.\n",
>> +                       dev->name, np->intr_status,
>> +                       readl(ioaddr + IntrMask));
>>  
>> -    if (netif_rx_schedule_prep(dev)) {
>> -        /* Disable interrupts and register for poll */
>> -        natsemi_irq_disable(dev);
>> -        __netif_rx_schedule(dev);
>> +            status = IRQ_HANDLED;
>> +        }
>>      }
>> -    return IRQ_HANDLED;
>> +
>> +    spin_unlock_irqrestore(&np->intr_lock, flags);
>> +    return status;
>>  }
>>  
>>  /* This is the NAPI poll routine.  As well as the standard RX handling
>> @@ -2154,8 +2175,15 @@
>>  
>>      int work_to_do = min(*budget, dev->quota);
>>      int work_done = 0;
>> +    unsigned long flags;
>>  
>>      do {
>> +        if (netif_msg_intr(np))
>> +            printk(KERN_DEBUG
>> +                   "%s: Poll, status %#08x, mask %#08x.\n",
>> +                   dev->name, np->intr_status,
>> +                   readl(ioaddr + IntrMask));
>> +
>>          if (np->intr_status &
>>              (IntrTxDone | IntrTxIntr | IntrTxIdle | IntrTxErr)) {
>>              spin_lock(&np->lock);
>> @@ -2182,14 +2210,19 @@
>>          np->intr_status = readl(ioaddr + IntrStatus);
>>      } while (np->intr_status);
>>  
>> +    /* We need to ensure that the ISR doesn't run between telling
>> +     * NAPI we're done and enabling the interrupt. */

>    Why? :-O

    Ah, got it: intr_handler() may disable interrupts (if some have appeared 
since the last IntrStatus read) and upon return poll() will erroneously 
re-enable them again...  Good catch! :-)
    Could also been dealt with by checking if the interrupt is actually 
enabled in intr_handler() -- so, this would now seem a better solution to me 
as we don't have to introduce flags/spinlocks, and avoid interrupt-off latency...

>> +    spin_lock_irqsave(&np->intr_lock, flags);
>> +
>>      netif_rx_complete(dev);
>> +    np->poll_active = 0;
>>  
>>      /* Reenable interrupts providing nothing is trying to shut
>>       * the chip down. */
>> -    spin_lock(&np->lock);
>> -    if (!np->hands_off && netif_running(dev))
>> +    if (!np->hands_off)
>>          natsemi_irq_enable(dev);
>> -    spin_unlock(&np->lock);
>> +
>> +    spin_unlock_irqrestore(&np->intr_lock, flags);

    Not really sure we can replace one spinlock with another...

>>      return 0;
>>  }

WBR, Sergei
