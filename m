From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC] net:phy:phylib: phy shares the same interrupt with mac
Date: Tue, 24 Jul 2012 12:59:24 +0200
Message-ID: <1570176.1a4Y6dlht4@flexo>
References: <CAGCDX1nndpdGHZzhh_Y+2OMLZvvUmAqkAsmgHu9hdUXTJFE--Q@mail.gmail.com> <CAGCDX1=Y_UWpmo0RiexYh-MJ8v6wwXZ=14h+NS5cmi5Nboytow@mail.gmail.com> <CAGCDX1nLbVKRYp-LQXv0DiYng2P1C8i_xBY+kdAemoKhyWe7Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Andy Fleming <afleming@gmail.com>, netdev@vger.kernel.org
To: Jason Lin <kernel.jason@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:37650 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752502Ab2GXLC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 07:02:26 -0400
Received: by lahd3 with SMTP id d3so781066lah.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 04:02:25 -0700 (PDT)
In-Reply-To: <CAGCDX1nLbVKRYp-LQXv0DiYng2P1C8i_xBY+kdAemoKhyWe7Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tuesday 24 July 2012 09:58:53 Jason Lin wrote:
> Any comments will be appreciated.
> Thanks.

If you phy shares thee interrupt line with the MAC, then proceed with the 
following:

- set your PHY address irq to PHY_IGNORE_INTERRUPT
- in your MAC interrupt handler, differentiate the PHY interrupt status bit 
from the other status bits
- call the adjust_link function that you have defined for phylib in your 
interrupt handler and make sure that nothing sleeps inside this adjust_link 
callback.

> 
> 2012/7/13 Jason Lin <kernel.jason@gmail.com>:
> > Dear:
> > But I think there have some performance issues.
> > Because the phy should execute its own ISR only when the interrupt is
> > issued by phy.
> > This will cause some unnecessary MDIO access.
> >
> > By the way, PHY_DUMMY_IRQ is defined in the platform definition file.
> > One should get PHY_DUMMY_IRQ by platform_get_irq function.
> > So the driver will look like this:
> >
> > /*** platform related file ***************/
> > static struct resource mac_0_resources[] = {
> >     {
> >         .start  = MAC_PA_BASE,
> >         .end    = MAC_PA_BASE + SZ_4K - 1,
> >         .flags  = IORESOURCE_MEM,
> >     }, {
> >         .start  = IRQ_MAC,
> >         .flags  = IORESOURCE_IRQ,
> >     }, {
> >         .start  = IRQ_PHY,
> >         .flags  = IORESOURCE_IRQ,
> >     },
> > };
> >
> >
> > /*** driver file ***************/
> > mydriver_probe(struct platform_device *pdev)
> > {
> >     int mac_irq, phy_irq, i;
> >
> >     mac_irq = platform_get_irq(pdev, 0);
> >     if (mac_irq < 0)
> >         return mac_irq;
> >
> >     phy_irq = platform_get_irq(pdev, 1);
> >     if (phy_irq < 0)
> >         phy_irq = PHY_POLL;
> >
> >     for (i = 0; i < PHY_MAX_ADDR; i++)
> >         priv->mii_bus->irq[i] = phy_irq;
> > }
> >
> > mydriver_napi_poll(struct napi_struct *napi, int budget)
> > {
> >     struct mydriver_priv *priv = = container_of(napi, struct
> > mydriver_priv, napi);
> >     struct phy_device *phydev = priv->phydev;
> >     unsigned int status = get_int_status();
> >
> > #ifdef CONFIG_MAC_CONTROL_PHY_INT
> >     if (status & PHY_INT) {
> >         tasklet_schedule(&phydev->phy_task);
> >     }
> > #endif
> >
> > }
> >
> > /**** phy lib modification ***************/
> > diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> > index 3cbda08..482f7e5 100644
> > --- a/drivers/net/phy/phy.c
> > +++ b/drivers/net/phy/phy.c
> > @@ -416,7 +416,7 @@ out_unlock:
> >  }
> >  EXPORT_SYMBOL(phy_start_aneg);
> >
> > -
> > +static void phy_tasklet(unsigned long data);
> >  static void phy_change(struct work_struct *work);
> >
> >  /**
> > @@ -523,10 +523,12 @@ static irqreturn_t phy_interrupt(int irq, void 
*phy_dat)
> >      * context, so we need to disable the irq here.  A work
> >      * queue will write the PHY to disable and clear the
> >      * interrupt, and then reenable the irq line. */
> > -   disable_irq_nosync(irq);
> > +/* disable_irq_nosync(irq);
> >     atomic_inc(&phydev->irq_disable);
> >
> > -   schedule_work(&phydev->phy_queue);
> > +   schedule_work(&phydev->phy_queue);*/
> > +
> > +   tasklet_schedule(&phydev->phy_task);
> >
> >     return IRQ_HANDLED;
> >  }
> > @@ -591,6 +593,7 @@ int phy_start_interrupts(struct phy_device *phydev)
> >  {
> >     int err = 0;
> >
> > +   tasklet_init(&phydev->phy_task, phy_tasklet, (unsigned long)phydev);
> >     INIT_WORK(&phydev->phy_queue, phy_change);
> >
> >     atomic_set(&phydev->irq_disable, 0);
> > @@ -633,6 +636,7 @@ int phy_stop_interrupts(struct phy_device *phydev)
> >      * possibly pending and take care of the matter below.
> >      */
> >     cancel_work_sync(&phydev->phy_queue);
> > +   tasklet_kill(&phydev->phy_task);
> >     /*
> >      * If work indeed has been cancelled, disable_irq() will have
> >      * been left unbalanced from phy_interrupt() and enable_irq()
> > @@ -645,7 +649,13 @@ int phy_stop_interrupts(struct phy_device *phydev)
> >  }
> >  EXPORT_SYMBOL(phy_stop_interrupts);
> >
> >
> > -
> > +static void phy_tasklet(unsigned long data)
> > +{
> > +   struct phy_device *phydev = (struct phy_device *)data;
> > +   disable_irq_nosync(phydev->irq);
> > +   atomic_inc(&phydev->irq_disable);
> > +   schedule_work(&phydev->phy_queue);
> > +}
> >  /**
> >   * phy_change - Scheduled by the phy_interrupt/timer to handle PHY 
changes
> >   * @work: work_struct that describes the work to be done
> > diff --git a/include/linux/phy.h b/include/linux/phy.h
> > index c599f7e..04203a7 100644
> > --- a/include/linux/phy.h
> > +++ b/include/linux/phy.h
> > @@ -330,6 +330,7 @@ struct phy_device {
> >     /* Interrupt and Polling infrastructure */
> >     struct work_struct phy_queue;
> >     struct delayed_work state_queue;
> > +   struct tasklet_struct phy_task;
> >     atomic_t irq_disable;
> >
> >     struct mutex lock;
> >
> > /*** end modification **********************************/
> >
> > how about this modification?
> > F.Y.I.
> > Thanks.
> >
> > 2012/7/13 Jason Lin <kernel.jason@gmail.com>:
> >> Thank for your reply.
> >> My case is the second one.
> >> change request_irq with IRQF_SHARED, and assign the same MAC irq number 
to phy
> >> (mii_bus->irq[i] = mac_irq)
> >> This way can fix my issue.
> >>
> >> Thanks again.
> >>
> >> 2012/7/13 Andy Fleming <afleming@gmail.com>:
> >>> On Tue, Jul 10, 2012 at 8:32 PM, Jason Lin <kernel.jason@gmail.com> 
wrote:
> >>>> Dear :
> >>>> I describe my situation again.
> >>>> In my hardware design, the interrupt (INT) pin of phy is connected to
> >>>> the INT input pin of MAC.
> >>>> In other words, one of triggering interrupt condition of MAC is
> >>>> related to phy's interrupt.
> >>>> So the phy will share the same "IRQ pin" with MAC.
> >>>> As described above, the best solution is the INT pin of phy is
> >>>> connected to architecture independently.
> >>>> But, the hardware architecture cannot modify easily.
> >>>> So I think
> >>>> 1. We can assign dummy IRQ number (which is a empty IRQ number but
> >>>> large than zero) to phy.
> >>>> phydev->irq = PHY_DUMMY_IRQ (this value is depend on architecture)
> >>>> 2. Change to do the soft IRQ in phy's ISR.
> >>>>     To schedule workqueue in this soft IRQ.
> >>>> In this way, the MAC can schedule phy's soft IRQ to do phy's work
> >>>> queue (to do ack phy's interrupt ... etc).
> >>>>
> >>>> Dose it make sense?
> >>>>
> >>>
> >>> If PHY_IGNORE_INTERRUPT doesn't currently work to allow a MAC's driver
> >>> to manage PHY interrupts, then we need to fix PHY Lib to support this
> >>> correctly. PHY_IGNORE_INTERRUPT was meant for this purpose. We don't
> >>> want to start defining interrupt numbers which may conflict with real
> >>> numbers, and have to be constantly re-defined by various systems to
> >>> avoid that.
> >>>
> >>> Your notion of making the phy_enable_interrupts() and
> >>> phy_disable_interrupts() code available to the MAC drivers sounds like
> >>> the right approach to me. But you might want to implement your own
> >>> version. The biggest problem with PHY interrupts is that masking them
> >>> requires an MDIO transaction, which is *slow*. If you can mask the
> >>> interrupt by writing a bit in a memory-mapped register, it's far
> >>> better to do it that way, at interrupt time, and *then* schedule the
> >>> PHY code to be run from a work queue. However, your driver probably
> >>> already *does* have a workqueue of some sort. If so, what you should
> >>> probably do is implement a new version of phy_change(), that doesn't
> >>> have to deal with the weird PHY interrupt masking issues. Something
> >>> like this:
> >>>
> >>> mydriver_phy_change(struct mydriver_priv *priv)
> >>> {
> >>>         int err;
> >>>         struct phy_device *phydev = priv->phydev;
> >>>
> >>>         if (phydev->drv->did_interrupt &&
> >>>             !phydev->drv->did_interrupt(phydev))
> >>>                 goto ignore;
> >>>
> >>>         err = phy_disable_interrupts(phydev);
> >>>
> >>>         if (err)
> >>>                 goto phy_err;
> >>>
> >>>         mutex_lock(&phydev->lock);
> >>>         if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev-
>state))
> >>>                 phydev->state = PHY_CHANGELINK;
> >>>         mutex_unlock(&phydev->lock);
> >>>
> >>>         /* Reenable interrupts */
> >>>         if (PHY_HALTED != phydev->state)
> >>>                 err = phy_config_interrupt(phydev, 
PHY_INTERRUPT_ENABLED);
> >>>
> >>>         if (err)
> >>>                 goto irq_enable_err;
> >>>
> >>>         /* reschedule state queue work to run as soon as possible */
> >>>         cancel_delayed_work_sync(&phydev->state_queue);
> >>>         schedule_delayed_work(&phydev->state_queue, 0);
> >>>
> >>>         return;
> >>>
> >>> ignore:
> >>>         return;
> >>>
> >>> irq_enable_err:
> >>> phy_err:
> >>>         phy_error(phydev);
> >>> }
> >>>
> >>>
> >>> Of course, now I re-read your question, and I'm not sure I've
> >>> interpreted it correctly. Are you saying your MAC has control of the
> >>> PHY interrupt (ie - the interrupt sets a bit in some event register in
> >>> your MAC, and you can MASK/ACK it from your driver), or that the PHY
> >>> shares the same interrupt pin?
> >>>
> >>> If it's the second one, you don't need to do anything, but allow your
> >>> MAC driver to register its interrupt as a shared interrupt, and allow
> >>> the PHY to manage its own interrupts, as usual.
> >>>
> >>> Andy
