From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Thu, 13 Jun 2013 23:52:22 +0200
Message-ID: <1371160342.8335.22.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130612230257.GB21234@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:47968 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755565Ab3FMVwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 17:52:34 -0400
In-Reply-To: <20130612230257.GB21234@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks again :-)

> > +int alx_read_phy_reg(struct alx_hw *hw, u16 reg, u16 *phy_data)
> > +{
> > +	int err;
> > +
> > +	spin_lock(&hw->mdio_lock);
> > +	err = __alx_read_phy_reg(hw, reg, phy_data);
> > +	spin_unlock(&hw->mdio_lock);
> 
> Isn't it possible to remove the phy ops from any irq / napi / tasklet
> context ?

I don't think they're actually called there.

> If you only need it in user / workqueue context you'll be able to trade
> the spinlock for a mutex (and push it in the common core methods ?).

Yes, I suppose I could, but is it worth it? It's held only for a very
short amount of time to get the indirect register access correct. I
don't really see any reason to prefer a mutex here?

Not sure what you mean by "push it in the common core methods"? I
actually suspect that this lock can't ever be contended because the
callers hold the RTNL anyway, but I don't really want to rely on just
that.


> > +		for (i = 0; i < ALX_SLD_MAX_TO; i++) {
> > +			mdelay(1);
> > +			val = alx_read_mem32(hw, ALX_SLD);
> > +			if ((val & ALX_SLD_START) == 0)
> > +				break;
> > +		}
> 
> You may add an helper for the loops above.
> 
> > +		if (i == ALX_SLD_MAX_TO)
> > +			return -EIO;
> > +		loaded_intn = true;
> > +		goto read_mcadr;
> 
> (I don't dislike it but it verges on goto fetishismi :o) )

It is pretty ugly ... I've now rewritten it using two helper functions.

> > +static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
> > +{
> > +	struct alx_hw *hw = &alx->hw;
> > +	bool write_int_mask = false;
> > +
> > +	spin_lock(&alx->irq_lock);
> 
> Do yourself a favor: avoid any work in the irq handler.
> 
> Forget the lock. Mask irqs, insert mmiowb and memory barrier, then
> schedule napi if there is any event.
> 
> In the napi handler, enable napi polling then irq.

Hmm, yeah, I'll have to think about that. I don't really care about the
performance all that much ... just want the device to work :-)

Would I really want to rely on NAPI for error interrupts and the like
though? I thought NAPI could potentially be deferred due to budget etc.

johannes
