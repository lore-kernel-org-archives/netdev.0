From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: ethernet: ibm-emac: Add 5482 PHY init for
 OpenBlocks 600
Date: Sat, 02 Sep 2017 11:22:03 +1000
Message-ID: <1504315323.4974.98.camel@kernel.crashing.org>
References: <1504241089.4974.67.camel@kernel.crashing.org>
         <816adc32-9df6-3433-b30c-79490a6328d1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58255 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750941AbdIBBWI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 21:22:08 -0400
In-Reply-To: <816adc32-9df6-3433-b30c-79490a6328d1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-01 at 17:35 -0700, Florian Fainelli wrote:
> On 08/31/2017 09:44 PM, Benjamin Herrenschmidt wrote:
> > The vendor patches initialize those registers to get the
> > PHY working properly.
> > 
> > Sadly I don't have that PHY spec and whatever Broadcom PHY
> > code we already have don't seem to document these two shadow
> > registers (unless I miscalculated the address) so I'm keeping
> > this as "vendor magic for that board". The vendor has long
> > abandoned that product, but I find it handy to test ppc405
> > kernels and so would like to keep it alive upstream :-)
> > 
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > ---
> > 
> > Note: Ideally, the whole driver should switch over to the
> > generic PHY layer. However this is a much bigger undertaking
> > which requires access to a bunch of HW to test, and for which
> > I have neither the time nor the HW available these days.
> 
> Yes it sure does and the function names are so close, it is almost
> irresistible not to do it.

I think there's some common ancestry :-)

That said, I'm weary of doing it without proper testing, especially
those old cell blades which I'm not sure I still have a functional
one, and whatever is using gpcs...

Cheers,
Ben.

> 
> > 
> > (Some of the HW could prove hard to find ...)
> > ---
> >  drivers/net/ethernet/ibm/emac/phy.c | 30 ++++++++++++++++++++++++++++++
> >  1 file changed, 30 insertions(+)
> > 
> > diff --git a/drivers/net/ethernet/ibm/emac/phy.c b/drivers/net/ethernet/ibm/emac/phy.c
> > index 35865d05fccd..daa10de542fb 100644
> > --- a/drivers/net/ethernet/ibm/emac/phy.c
> > +++ b/drivers/net/ethernet/ibm/emac/phy.c
> > @@ -24,6 +24,7 @@
> >  #include <linux/mii.h>
> >  #include <linux/ethtool.h>
> >  #include <linux/delay.h>
> > +#include <linux/of.h>
> >  
> >  #include "emac.h"
> >  #include "phy.h"
> > @@ -363,6 +364,34 @@ static struct mii_phy_def bcm5248_phy_def = {
> >  	.ops		= &generic_phy_ops
> >  };
> >  
> > +static int bcm5482_init(struct mii_phy *phy)
> > +{
> > +	if (!of_machine_is_compatible("plathome,obs600"))
> > +		return 0;
> 
> You can probably include brcmphy.h and pull the definition for at least
> 0x1c: MII_BCM54XX_SHD

Yup.

> > +
> > +	/* Magic inits from vendor original patches */
> > +	phy_write(phy, 0x1c, 0xa410);
> 
> What you are doing here is write to shadow register 9 (9 << 10) which is
> the LED control register, and making the activity LED be driven on
> activity/link as opposed to just activity. So this can probably be
> written as:

Ok so I really don't *need* that in fact.


> 	phy_write(phy, MII_BCM54XX_SHD, MII_BCM54XX_SHD_WRITE |
> 		  MII_BCM54XX_SHD_VAL(9) | MII_BCM54XX_SHD_DATA(BIT(4));
> 
> > +	phy_write(phy, 0x1c, 0x8804);
> 
> And here you are writing to the spare control 1 register and setting bit
> 2 (which appears reserved but this is not clear) which would be enabling
> the activity LED for 10BaseT or no link which can be written as:
> 
> 	phy_write(phy, MII_BCM54XX_SHD, MII_BCM54XX_SHD_WRITE |
> 		  MII_BCM54XX_SHD_VAL(2) | MII_BCM4XX_SHD_DATA(BIT(2));
> 
> So basically you are touching registers that only affect LED
> configuration and should not be doing anything else...

I wonder if I need to bother at all then. I was worried it was related
to actual function of the device, but if it's just LEDs, I think I may
as well just drop it.

> > +
> > +	return 0;
> > +}
> > +
> > +static const struct mii_phy_ops bcm5482_phy_ops = {
> > +	.init		= bcm5482_init,
> > +	.setup_aneg	= genmii_setup_aneg,
> > +	.setup_forced	= genmii_setup_forced,
> > +	.poll_link	= genmii_poll_link,
> > +	.read_link	= genmii_read_link
> > +};
> > +
> > +static struct mii_phy_def bcm5482_phy_def = {
> > +
> > +	.phy_id		= 0x0143bcb0,
> > +	.phy_id_mask	= 0x0ffffff0,
> > +	.name		= "BCM5482 Gigabit Ethernet",
> > +	.ops		= &bcm5482_phy_ops
> > +};
> > +
> >  static int m88e1111_init(struct mii_phy *phy)
> >  {
> >  	pr_debug("%s: Marvell 88E1111 Ethernet\n", __func__);
> > @@ -499,6 +528,7 @@ static struct mii_phy_def *mii_phy_table[] = {
> >  	&et1011c_phy_def,
> >  	&cis8201_phy_def,
> >  	&bcm5248_phy_def,
> > +	&bcm5482_phy_def,
> >  	&m88e1111_phy_def,
> >  	&m88e1112_phy_def,
> >  	&ar8035_phy_def,
> > 
> 
> 
