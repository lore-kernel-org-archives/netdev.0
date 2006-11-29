From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [patch sungem] improved locking
Date: Wed, 29 Nov 2006 11:56:30 +0100
Message-ID: <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
References: <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
	 <20061113.234456.78492515.davem@davemloft.net>
	 <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	 <20061128.144911.55733883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:49357 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S967116AbWK2K4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 05:56:32 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1748880uga
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 02:56:31 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061128.144911.55733883.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/28/06, David Miller <davem@davemloft.net> wrote:
> From: "Eric Lemoine" <eric.lemoine@gmail.com>
> Date: Tue, 14 Nov 2006 22:54:40 +0100
>
> > On 11/14/06, David Miller <davem@davemloft.net> wrote:
> > > From: "Eric Lemoine" <eric.lemoine@gmail.com>
> > > Date: Tue, 14 Nov 2006 08:28:42 +0100
> > >
> > > > because it makes it explicit that only bits 0 through 6 are taken into
> > > > account when writing the IACK register.
> > >
> > > The phrase "bits 0 through 6" doesn't make any sense when bit 3 DOES
> > > NOT EXIST in the hardware, it's reserved, it's not there, so including
> > > it only confuses people and obfuscates the code.
> > >
> > > Please use the explicit bit mask composed of existing macros, which
> > > not only makes sure that the mask has meaning, but it also makes sure
> > > that reserved and non-existing bits are never referenced.
> >
> > Patch attached.
> >
> > Remember, the GEM_INTERRUPT_LOCKLESS isn't there to stay. It's
> > currently there because I'm not sure the lockless implementation of
> > gem_interrupt() will work with poll_net_controller.
> >
> > Thanks,
> >
> > Signed-off-by: Eric Lemoine <eric.lemoine@gmail.com>
>
> This looks mostly fine.
>
> I was thinking about the lockless stuff, and I wonder if there
> is a clever way you can get it back down to one PIO on the
> GREG_STAT register.
>
> I think you'd need to have the ->poll() clear gp->status, then
> do a smp_wb(), right before it re-enables interrupts.
>
> Then in the interrupt handler, you need to find a way to safely
> OR-in any unset bits in gp->status in a race-free manner.

I don't understand why we'd need all this.

I think the following code for gem_interrupt should do the trick:

static irqreturn_t gem_interrupt(int irq, void *dev_id)
{
    struct net_device *dev = dev_id;
    struct gem *gp = dev->priv;
    unsigned int handled = 1;

    if (!gp->running)
        goto out;

    if (netif_rx_schedule_prep(dev)) {
        u32 gem_status = gem_read_status(gp);
        gem_disable_ints();

        if (unlikely(!gem_status))
            handled = 0;

        if (gem_irq_sync(gp)) {
            netif_poll_enable(dev);
            goto out;
        }

        gp->status = gem_status;
        __netif_rx_schedule(dev);
    }

out:
    return IRQ_RETVAL(handled);
}

The important thing is: we __netif_rx_schedule even if gem_status is 0
(shared irq case) because we don't want to miss events should the
following scenario occur:

CPU0                                                     CPU1
gem interrupt
prepare rx schedule
                                                             gem_interrupt
                                                             rx is
already scheduled
shared irq -> (we can miss NIC events
if we don't __netif_rx_schedule before
returning)

Thanks,
-- 
Eric
