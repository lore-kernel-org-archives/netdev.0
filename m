From: Scott Wood <oss@buserror.net>
Subject: Re: [PATCH 2/4] soc: fsl: add GUTS driver for QorIQ platforms
Date: Fri, 10 Jun 2016 20:50:53 -0500
Message-ID: <1465609853.22191.151.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	 <5339448.D8rpq4ofAC@wuerfel> <1464832042.22191.23.camel@buserror.net>
	 <3435609.s5m1DCsoNb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
	Ulf Hansson <ulf.hansson@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	Yang-Leo Li <leoyang.li@nxp.com>,
	"i
To: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.buserror.net ([209.198.135.123]:49564 "EHLO
	host.buserror.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbcFKBvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 21:51:17 -0400
In-Reply-To: <3435609.s5m1DCsoNb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-02 at 10:43 +0200, Arnd Bergmann wrote:
> On Wednesday, June 1, 2016 8:47:22 PM CEST Scott Wood wrote:
> > On Mon, 2016-05-30 at 15:15 +0200, Arnd Bergmann wrote:
> > > diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
> > > new file mode 100644
> > > index 000000000000..2f30698f5bcf
> > > --- /dev/null
> > > +++ b/drivers/soc/fsl/guts.c
> > > @@ -0,0 +1,130 @@
> > > +/*
> > > + * Freescale QorIQ Platforms GUTS Driver
> > > + *
> > > + * Copyright (C) 2016 Freescale Semiconductor, Inc.
> > > + *
> > > + * This program is free software; you can redistribute it and/or modify
> > > + * it under the terms of the GNU General Public License as published by
> > > + * the Free Software Foundation; either version 2 of the License, or
> > > + * (at your option) any later version.
> > > + */
> > > +
> > > +#include <linux/io.h>
> > > +#include <linux/platform_device.h>
> > > +#include <linux/module.h>
> > > +#include <linux/slab.h>
> > > +#include <linux/of_address.h>
> > > +#include <linux/of_platform.h>
> > > +#include <linux/sys_soc.h>
> > > +
> > > +#define GUTS_PVR	0x0a0
> > > +#define GUTS_SVR	0x0a4
> > > +
> > > +struct guts {
> > > +	void __iomem *regs;
> > 
> > We already have a struct to define guts.  Why are you not using it?  Why
> > do
> > you consider using it to be "abuse"?  What if we want to move more guts
> > functionality into this driver?
> 
> This structure was in the original patch, I left it in there, only
> removed the inclusion of the powerpc header file, which seemed to
> be misplaced.

I'm not refering "struct guts".  I'm referring to changing
"struct ccsr_guts __iomem *regs" into "void __iomem *regs".

And it's not a powerpc header file.

> > > +/*
> > > + * Table for matching compatible strings, for device tree
> > > + * guts node, for Freescale QorIQ SOCs.
> > > + */
> > > +static const struct of_device_id fsl_guts_of_match[] = {
> > > +	/* For T4 & B4 Series SOCs */
> > > +	{ .compatible = "fsl,qoriq-device-config-1.0", .data = "T4/B4
> > > series" },
> > [snip]
> > > +	{ .compatible = "fsl,qoriq-device-config-2.0", .data = "P
> > > series"
> > 
> > As noted in my comment on patch 3/4, these descriptions are reversed.
> > 
> > They're also incomplete.  t2080 has device config 2.0.  t1040 is described
> > as
> > 2.0 though it should probably be 2.1 (or better, drop the generic
> > compatible
> > altogether).
> 
> Ok. Ideally I think we'd even look up the specific SoC names from the
> SVC rather than the compatible string. I just didn't have a good list
> for those to put in the driver.

The list is in arch/powerpc/include/asm/mpc85xx.h but I don't know why we need
to convert it to a string in the first place.

> 
> > > +	/*
> > > +	 * syscon devices default to little-endian, but on powerpc we
> > > have
> > > +	 * existing device trees with big-endian maps and an absent
> > > endianess
> > > +	 * "big-property"
> > > +	 */
> > > +	if (!IS_ENABLED(CONFIG_POWERPC) &&
> > > +	    !of_property_read_bool(dev->of_node, "big-endian"))
> > > +		guts->little_endian = true;
> > 
> > This is not a syscon device (Yangbo's patch to add a guts node on ls2080
> > is
> > the only guts node that says "syscon", and that was a leftover from
> > earlier
> > revisions and should probably be removed).  Even if it were, where is it
> > documented that syscon defaults to little-endian?
> 
> Documentation/devicetree/bindings/regmap/regmap.txt
> 
> We had a little screwup here, basically regmap (and by consequence, syscon)
> always defaulted to little-endian way before that was documented, so it's
> too late to change it, 

What causes a device node to fall under the jurisdiction of regmap.txt? 
 Again, these nodes do not claim "syscon" compatibility.

> although I agree it would have made sense to document
> regmap to default to big-endian on powerpc.

Please don't.  It's enough of a mess as is; no need to start throwing in
architecture ifdefs.

> > Documentation/devicetree/bindings/common-properties.txt says that the
> > individual binding specifies the default.  The default for this node
> > should be
> > big-endian because that's what existed before there was a need to describe
> > the
> > endianness.  And we need an update to the guts binding to specify that.
> 
> Good point. This proably means that specifying both the "guts" and "syscon"
> compatible strings implies having to also specify the endianess explicitly
> both ways, because otherwise we break one of the two bindings.

Yes, but the node should only specify "guts".

> 
> > > +
> > > +	guts->regs = devm_ioremap_resource(dev, 0);
> > > +	if (!guts->regs) {
> > > +		ret = -ENOMEM;
> > > +		kfree(guts);
> > > +		goto out;
> > > +	}
> > > +
> > > +	fsl_guts_init(dev, guts);
> > > +	ret = 0;
> > > +out:
> > > +	return ret;
> > > +}
> > > +
> > > +static struct platform_driver fsl_soc_guts = {
> > > +	.probe = fsl_guts_probe,
> > > +	.driver.of_match_table = fsl_guts_of_match,
> > > +};
> > > +
> > > +module_platform_driver(fsl_soc_guts);
> > 
> > Again, this means that the information is not available during early boot,
> > such as in the clock driver.  Thus we would not be able to convert clk
> > -qoriq's
> > direct mfspr(SPRN_SVR) into an soc_device_match() (or anything else that
> > makes
> > use of this file), nor would we be able to move its access of the guts RCW
> > registers into this driver.
> 
> Correct. Do we have a reason to convert the mfspr() though? I don't really
> see an improvement over the current state if we do that, 

Then should we drop this patchset and put a similar PPC ifdef in
 drivers/mmc/host/sdhci-of-esdhc.c?

There's also the RCW access.  You said in the patch 4/4 discussion that you di
dn't like any random driver ioremapping the registers...

> and for new devices
> that might need the erratum workaround, we could add a DT property that
> would
> be preferred to both.

It's unlikely that we would know the erratum exists at the time the device
tree is created.  We also generally don't have separate device trees for each
revision of a chip (and if we did, we'd have users that use the wrong one).

-Scott
