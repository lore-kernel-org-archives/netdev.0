From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Tue, 15 Dec 2015 15:50:59 +0100
Message-ID: <1594472.ixZvj6PYdz@wuerfel>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org> <566F6F3D.5050004@gmail.com> <567023F8.80302@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
To: Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <567023F8.80302-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 December 2015 09:30:16 Christopher Covington wrote:
> 
> On 12/14/2015 08:39 PM, Florian Fainelli wrote:
> > On 14/12/15 16:19, Gilad Avidov wrote:
> 
> >> +static void emac_mac_irq_enable(struct emac_adapter *adpt)
> >> +{
> >> +    int i;
> >> +
> >> +    for (i = 0; i < EMAC_NUM_CORE_IRQ; i++) {
> >> +            struct emac_irq                 *irq = &adpt->irq[i];
> >> +            const struct emac_irq_config    *irq_cfg = &emac_irq_cfg_tbl[i];
> >> +
> >> +            writel_relaxed(~DIS_INT, adpt->base + irq_cfg->status_reg);
> >> +            writel_relaxed(irq->mask, adpt->base + irq_cfg->mask_reg);
> >> +    }
> >> +
> >> +    wmb(); /* ensure that irq and ptp setting are flushed to HW */
> > 
> > Would not using writel() make the appropriate thing here instead of
> > using _relaxed which has no barrier?
> 
> It appears to me that the barrier in writel() comes before the access
> [1]. The barrier in this code comes after the accesses. In addition to
> the ordering, if you're suggesting all writel_relaxed be switched out,
> that would seem to add 7 unnecessary barriers, which could adversely
> affect performance.
> 
> 1. http://lxr.free-electrons.com/source/arch/arm64/include/asm/io.h#L130

You are right, the writel does not flush the write out to hardware,
and generally that is not needed, in particular since most buses do
not actually wait for a write to complete when a barrier is issued.

I'm missing two explanations here:

a) How performance-critical is the emac_mac_irq_enable() function?
   Is this only called when configuring the device, or each time
   you call napi_complete()?

b) What other code relies on the write being flushed out first?
   Can you move the barrier to the other side? If emac_mac_irq_enable()
   is called a lot, you might be able to avoid that barrier altogether
   if you instead put it whereever you access the device that requires
   the interrupts to be enabled.

> >> +    mta = readl_relaxed(adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
> >> +    mta |= (0x1 << bit);
> >> +    writel_relaxed(mta, adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
> >> +    wmb(); /* ensure that the mac address is flushed to HW */
> > 
> > This is getting too much here, just use the correct I/O accessor for
> > your platform, period.
> 
> Based on your previous comment, I'm guessing you're suggesting using
> readl() and writel() here instead of *_relaxed and an explicit wmb().
> Again it's not clear to me why swapping the barrier-access ordering and
> adding an additional barrier would result in more correct code.

We generally want to use readl/writel rather than the relaxed versions,
unless it is in performance-critical code.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
