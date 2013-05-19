From: Tomasz Figa <tomasz.figa@gmail.com>
Subject: Re: [PATCH] net: dm9000: Allow instantiation using device tree
Date: Sun, 19 May 2013 10:54:53 +0200
Message-ID: <2763249.7aFBh8NOHl@flatron>
References: <1368918194-24030-1-git-send-email-tomasz.figa@gmail.com> <20130519070538.GX32299@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:38868 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998Ab3ESIy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 04:54:58 -0400
Received: by mail-ea0-f177.google.com with SMTP id q14so3173434eaj.22
        for <netdev@vger.kernel.org>; Sun, 19 May 2013 01:54:57 -0700 (PDT)
In-Reply-To: <20130519070538.GX32299@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

On Sunday 19 of May 2013 09:05:38 Sascha Hauer wrote:
> Hi Tomasz,
> 
> On Sun, May 19, 2013 at 01:03:14AM +0200, Tomasz Figa wrote:
> > This patch adds Device Tree support to dm9000 driver.
> > 
> > Signed-off-by: Tomasz Figa <tomasz.figa@gmail.com>
> > ---
> > 
> >  .../devicetree/bindings/net/davicom-dm9000.txt     | 27 ++++++++++
> >  .../devicetree/bindings/vendor-prefixes.txt        |  1 +
> >  drivers/net/ethernet/davicom/dm9000.c              | 60
> >  ++++++++++++++++++++++ 3 files changed, 88 insertions(+)
> >  create mode 100644
> >  Documentation/devicetree/bindings/net/davicom-dm9000.txt> 
> > diff --git a/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> > b/Documentation/devicetree/bindings/net/davicom-dm9000.txt new file
> > mode 100644
> > index 0000000..d2902db
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> > @@ -0,0 +1,27 @@
> > +Davicom DM9000 Fast Ethernet controller
> > +
> > +Required properties:
> > +- compatible = "davicom,dm9000";
> > +- reg : physical addresses and sizes of registers, must contain 2
> > entries: +    first entry : address register,
> > +    second entry : address register.
> > +- interrupt-parent : interrupt controller to which the device is
> > connected +- interrupts : interrupt specifier specific to interrupt
> > controller +
> > +Optional properties:
> > +- local-mac-address : A bytestring of 6 bytes specifying Ethernet MAC
> > address +    to use (from firmware or bootloader)
> > +- davicom,no-eeprom : Configuration EEPROM is not available
> > +- davicom,ext-phy : Use external PHY
> > +- davicom,simple-phy : Use NSR to find LinkStatus
> 
> Do we really need to expose this simple-phy property? Looking at the
> drvier code this more looks like a work around shortcomings of the
> driver code rather than something really necessary.

Well, depending on this property it can use two different methods of 
checking carrier status and it seems to depend on hardware, which one 
should be used. I don't see any driver shortcomings here, but maybe I'm 
missing something.

> > +#ifdef CONFIG_OF
> > +static struct dm9000_plat_data *dm9000_parse_dt(struct device *dev)
> > +{
> > +	struct dm9000_plat_data *pdata;
> > +	struct device_node *np = dev->of_node;
> > +	const void *prop;
> > +	int len;
> > +
> > +	if (!np)
> > +		return NULL;
> 
> You should be able to kill the ifdef around this function by doing

Basically this would be a kill with a double-edged sword.

I could completely drop the #ifdef without any additional check, as it is 
not possible that np is not NULL with !CONFIG_OF, but I decided to keep 
the code conditional to reduce driver code a bit on platforms that don't 
need OF.

Maybe this single driver wouldn't give any significant difference, but if 
you make all the drivers used on the platform this way, you will save some 
kilobytes.

> 	if (!IS_ENABLED(CONFIG_OF) || !np)
> 		return NULL;
> 
> > +
> > +	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
> > +	if (!pdata) {
> > +		dev_err(dev, "failed to allocate platform data struct\n");
> > +		return ERR_PTR(-ENOMEM);
> > +	}
> > +
> > +	if (of_find_property(np, "davicom,ext-phy", NULL))
> > +		pdata->flags |= DM9000_PLATF_EXT_PHY;
> > +	if (of_find_property(np, "davicom,no-eeprom", NULL))
> > +		pdata->flags |= DM9000_PLATF_NO_EEPROM;
> > +	if (of_find_property(np, "davicom,simple-phy", NULL))
> > +		pdata->flags |= DM9000_PLATF_SIMPLE_PHY;
> > +
> > +	prop = of_get_property(np, "local-mac-address", &len);
> > +	if (!prop)
> > +		return pdata;
> 
> I think you should use of_get_mac_address() here.

Oops. Right, this is what I was looking for, but somehow I failed. Will 
change this in next version. Thanks.

Best regards,
Tomasz
