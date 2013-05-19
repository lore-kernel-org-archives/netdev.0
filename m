From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net: dm9000: Allow instantiation using device tree
Date: Sun, 19 May 2013 12:35:44 +0200
Message-ID: <20130519103544.GZ32299@pengutronix.de>
References: <1368918194-24030-1-git-send-email-tomasz.figa@gmail.com>
 <20130519070538.GX32299@pengutronix.de>
 <2763249.7aFBh8NOHl@flatron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>
To: Tomasz Figa <tomasz.figa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55262 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205Ab3ESKfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 06:35:48 -0400
Content-Disposition: inline
In-Reply-To: <2763249.7aFBh8NOHl@flatron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 19, 2013 at 10:54:53AM +0200, Tomasz Figa wrote:
> Hi Sascha,
> 
> On Sunday 19 of May 2013 09:05:38 Sascha Hauer wrote:
> > Hi Tomasz,
> > 
> > On Sun, May 19, 2013 at 01:03:14AM +0200, Tomasz Figa wrote:
> > > This patch adds Device Tree support to dm9000 driver.
> > > 
> > > Signed-off-by: Tomasz Figa <tomasz.figa@gmail.com>
> > > ---
> > > 
> > >  .../devicetree/bindings/net/davicom-dm9000.txt     | 27 ++++++++++
> > >  .../devicetree/bindings/vendor-prefixes.txt        |  1 +
> > >  drivers/net/ethernet/davicom/dm9000.c              | 60
> > >  ++++++++++++++++++++++ 3 files changed, 88 insertions(+)
> > >  create mode 100644
> > >  Documentation/devicetree/bindings/net/davicom-dm9000.txt> 
> > > diff --git a/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> > > b/Documentation/devicetree/bindings/net/davicom-dm9000.txt new file
> > > mode 100644
> > > index 0000000..d2902db
> > > --- /dev/null
> > > +++ b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> > > @@ -0,0 +1,27 @@
> > > +Davicom DM9000 Fast Ethernet controller
> > > +
> > > +Required properties:
> > > +- compatible = "davicom,dm9000";
> > > +- reg : physical addresses and sizes of registers, must contain 2
> > > entries: +    first entry : address register,
> > > +    second entry : address register.
> > > +- interrupt-parent : interrupt controller to which the device is
> > > connected +- interrupts : interrupt specifier specific to interrupt
> > > controller +
> > > +Optional properties:
> > > +- local-mac-address : A bytestring of 6 bytes specifying Ethernet MAC
> > > address +    to use (from firmware or bootloader)
> > > +- davicom,no-eeprom : Configuration EEPROM is not available
> > > +- davicom,ext-phy : Use external PHY
> > > +- davicom,simple-phy : Use NSR to find LinkStatus
> > 
> > Do we really need to expose this simple-phy property? Looking at the
> > drvier code this more looks like a work around shortcomings of the
> > driver code rather than something really necessary.
> 
> Well, depending on this property it can use two different methods of 
> checking carrier status and it seems to depend on hardware, which one 
> should be used. I don't see any driver shortcomings here, but maybe I'm 
> missing something.

It's not hardware dependent, at least not from the original commit log.

The driver doesn't use mdiobus_register which you normally would do
today. If someone ports the driver over to mdiobus we would still have
to support this legacy flag as a special case.

Since no mainline user makes use of this flag I suggest to skip it from
the devicetree, at least until someone really asks for this specific
flag (and has good reasons to use it)

> 
> > > +#ifdef CONFIG_OF
> > > +static struct dm9000_plat_data *dm9000_parse_dt(struct device *dev)
> > > +{
> > > +	struct dm9000_plat_data *pdata;
> > > +	struct device_node *np = dev->of_node;
> > > +	const void *prop;
> > > +	int len;
> > > +
> > > +	if (!np)
> > > +		return NULL;
> > 
> > You should be able to kill the ifdef around this function by doing
> 
> Basically this would be a kill with a double-edged sword.
> 
> I could completely drop the #ifdef without any additional check, as it is 
> not possible that np is not NULL with !CONFIG_OF,

Yes, but the compiler doesn't know this.

> but I decided to keep 
> the code conditional to reduce driver code a bit on platforms that don't 
> need OF.

IS_ENABLED(CONFIG_OF) will expand to 0 without OF and the compiler will
through the unused code away. You won't find differences in the binary
size.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
