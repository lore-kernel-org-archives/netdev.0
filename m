From: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2 01/14] clk: add helper functions clk_prepare_enable
 and clk_disable_unprepare
Date: Fri, 11 Nov 2011 22:20:48 +0800
Message-ID: <20111111142046.GA20556@b20223-02.ap.freescale.net>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
 <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
 <20111111084950.GH16886@pengutronix.de>
 <20111111090546.GC14617@b20223-02.ap.freescale.net>
 <20111111091556.GI16886@pengutronix.de>
 <20111111102727.GC12913@n2100.arm.linux.org.uk>
 <20111111115644.GT16886@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	<amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<eric.miao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>, <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111111115644.GT16886-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2011 at 12:56:44PM +0100, Sascha Hauer wrote:
> On Fri, Nov 11, 2011 at 10:27:27AM +0000, Russell King - ARM Linux wrote:
> > On Fri, Nov 11, 2011 at 10:15:56AM +0100, Sascha Hauer wrote:
> > > On Fri, Nov 11, 2011 at 05:05:47PM +0800, Richard Zhao wrote:
> > > > {
> > > > 	int ret;
> > > > 
> > > > 	ret = clk_prepare(clk);
> > > > 	if (ret)
> > > > 		return ret;
> > > > 	ret = clk_enable(clk);
> > > > 	if (ret)
> > > > 		clk_unprepare(clk);
> > > > 	return ret;
> > > 
> > > Yes, looks good.
> > 
> > While this looks like a nice easy solution for converting existing
> > drivers, I'd suggest thinking about this a little more...
> > 
> > I would suggest some thought is given to the placement of clk_enable()
> > and clk_disable() when adding clk_prepare(), especially if your existing
> > clk_enable() function can only be called from non-atomic contexts.
> > 
> > Obviously, the transition path needs to be along these lines:
> > 
> > 1. add clk_prepare() to drivers
> > 2. implement clk_prepare() and make clk_enable() callable from non-atomic
> >    contexts
> > 3. move clk_enable() in drivers to places it can be called from non-atomic
> >    contexts to achieve greater power savings (maybe via the runtime pm)
Hi Russell,

There are use cases calling clk_enable in atomic context, but there are even more
cases caling in non-atomic context. The patch meant to help the latter cases.
Tuning of driver power savings can be left to other contributers. Is it ok
if I add below comments:
/* clk_prepare_enable helps cases using clk_enable in non-atomic context. */
static inline int clk_prepare_enable(struct clk *clk)
...
/* clk_disable_unprepare helps cases using clk_disable in non-atomic context. */
static inline void clk_disable_unprepare(struct clk *clk)
...

Thanks
Richard
> > 
> > and where a driver is shared between different sub-architectures which
> > have non-atomic clk_enable()s, (3) can only happen when all those sub-
> > architectures have been updated to step (2).
> 
> The drivers changed here all do clk_prepare/enable in their probe
> function. I agree that this clk_prepare_enable patch gives kind of
> wrong motivation to just use this function and to forget about
> potential power savings with proper integration of clk_prepare/enable.
> I think though that it will take a long time until all drivers really
> do this no matter if we have such a helper or not. I think that in the
> meantime it's better to have a little helper than to clobber the probe
> code with additional error handling.
> 
> Sascha
> 
> -- 
> Pengutronix e.K.                           |                             |
> Industrial Linux Solutions                 | http://www.pengutronix.de/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
