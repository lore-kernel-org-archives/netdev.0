From: Andy Fleming <afleming@gmail.com>
Subject: Re: [RFC] net:phy:phylib: phy shares the same interrupt with mac
Date: Thu, 12 Jul 2012 15:05:53 -0500
Message-ID: <CAKWjMd7dXeZ8jj-LXkaNWr62fEc1+D1jZkmW0fKsYcOGoxnCaA@mail.gmail.com>
References: <CAGCDX1nndpdGHZzhh_Y+2OMLZvvUmAqkAsmgHu9hdUXTJFE--Q@mail.gmail.com>
	<4F7AB9AC.8000708@openwrt.org>
	<CAGCDX1=EHJY1C=-w_YazeC9ByP=4T+hj8bjvZ=cizziSfa1J3g@mail.gmail.com>
	<CAGCDX1kZo5f8_BpMgq75o0EoTRh9X=VbH2-rXDBYoKdCosO+VQ@mail.gmail.com>
	<CAGCDX1mVk-4JpjDhWxJdsssmXCM+NM8sPOPyjKBZwbqMj-UTvA@mail.gmail.com>
	<CAGCDX1nqBEWbAMNPeUZyf3KdtmhjnVKesV6TXZ-QDtb83R7LBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
To: Jason Lin <kernel.jason@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45222 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573Ab2GLUOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 16:14:07 -0400
Received: by weyx8 with SMTP id x8so1981118wey.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 13:14:06 -0700 (PDT)
In-Reply-To: <CAGCDX1nqBEWbAMNPeUZyf3KdtmhjnVKesV6TXZ-QDtb83R7LBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 10, 2012 at 8:32 PM, Jason Lin <kernel.jason@gmail.com> wrote:
> Dear :
> I describe my situation again.
> In my hardware design, the interrupt (INT) pin of phy is connected to
> the INT input pin of MAC.
> In other words, one of triggering interrupt condition of MAC is
> related to phy's interrupt.
> So the phy will share the same "IRQ pin" with MAC.
> As described above, the best solution is the INT pin of phy is
> connected to architecture independently.
> But, the hardware architecture cannot modify easily.
> So I think
> 1. We can assign dummy IRQ number (which is a empty IRQ number but
> large than zero) to phy.
> phydev->irq = PHY_DUMMY_IRQ (this value is depend on architecture)
> 2. Change to do the soft IRQ in phy's ISR.
>     To schedule workqueue in this soft IRQ.
> In this way, the MAC can schedule phy's soft IRQ to do phy's work
> queue (to do ack phy's interrupt ... etc).
>
> Dose it make sense?
>

If PHY_IGNORE_INTERRUPT doesn't currently work to allow a MAC's driver
to manage PHY interrupts, then we need to fix PHY Lib to support this
correctly. PHY_IGNORE_INTERRUPT was meant for this purpose. We don't
want to start defining interrupt numbers which may conflict with real
numbers, and have to be constantly re-defined by various systems to
avoid that.

Your notion of making the phy_enable_interrupts() and
phy_disable_interrupts() code available to the MAC drivers sounds like
the right approach to me. But you might want to implement your own
version. The biggest problem with PHY interrupts is that masking them
requires an MDIO transaction, which is *slow*. If you can mask the
interrupt by writing a bit in a memory-mapped register, it's far
better to do it that way, at interrupt time, and *then* schedule the
PHY code to be run from a work queue. However, your driver probably
already *does* have a workqueue of some sort. If so, what you should
probably do is implement a new version of phy_change(), that doesn't
have to deal with the weird PHY interrupt masking issues. Something
like this:

mydriver_phy_change(struct mydriver_priv *priv)
{
        int err;
        struct phy_device *phydev = priv->phydev;

        if (phydev->drv->did_interrupt &&
            !phydev->drv->did_interrupt(phydev))
                goto ignore;

        err = phy_disable_interrupts(phydev);

        if (err)
                goto phy_err;

        mutex_lock(&phydev->lock);
        if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
                phydev->state = PHY_CHANGELINK;
        mutex_unlock(&phydev->lock);

        /* Reenable interrupts */
        if (PHY_HALTED != phydev->state)
                err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);

        if (err)
                goto irq_enable_err;

        /* reschedule state queue work to run as soon as possible */
        cancel_delayed_work_sync(&phydev->state_queue);
        schedule_delayed_work(&phydev->state_queue, 0);

        return;

ignore:
        return;

irq_enable_err:
phy_err:
        phy_error(phydev);
}


Of course, now I re-read your question, and I'm not sure I've
interpreted it correctly. Are you saying your MAC has control of the
PHY interrupt (ie - the interrupt sets a bit in some event register in
your MAC, and you can MASK/ACK it from your driver), or that the PHY
shares the same interrupt pin?

If it's the second one, you don't need to do anything, but allow your
MAC driver to register its interrupt as a shared interrupt, and allow
the PHY to manage its own interrupts, as usual.

Andy
