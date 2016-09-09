From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH v2 net-next 1/2] net: phy: Add Edge-rate driver for
 Microsemi PHYs.
Date: Fri, 9 Sep 2016 11:10:12 +0530
Message-ID: <20160909054009.GA26767@microsemi.com>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1473326242-4198-2-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160908131415.GG26445@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0075.outbound.protection.outlook.com ([104.47.33.75]:64029
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750949AbcIIFzl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 01:55:41 -0400
Content-Disposition: inline
In-Reply-To: <20160908131415.GG26445@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review the code and valuable comments.

On Thu, Sep 08, 2016 at 03:14:15PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Thu, Sep 08, 2016 at 02:47:21PM +0530, Raju Lakkaraju wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > Used Device Tree to configure the Edge-rate as per review comments and
> > re-sending code for review
> >
> > Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > ---
> >  drivers/net/phy/mscc.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++
> 
> Hi Raju
> 
> You need to also document the new property in the device tree binding
> documentation.
> 
Sure. I will do.
I created device tree binding header file. i will submit in different patch.

> > +static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
> > +                                   u8     edge_rate)
> 
> No spaces place.
> 
I ran the checkpatch. I did not find any error. I created another workspace and
applied the same patch. It shows the correct alignement. I have used tabs (8 space width).
then some spaces to align braces.

> > +#ifdef CONFIG_OF_MDIO
> > +static int vsc8531_of_init(struct phy_device *phydev)
> > +{
> > +     int rc;
> > +     struct vsc8531_private *vsc8531 = phydev->priv;
> > +     struct device *dev = &phydev->mdio.dev;
> > +     struct device_node *of_node = dev->of_node;
> > +
> > +     if (!of_node)
> > +             return -ENODEV;
> > +
> > +     rc = of_property_read_u8(of_node, "vsc8531,edge-rate",
> > +                              &vsc8531->edge_rate);
> 
> Until you have written the Documentation, it is hard for me to tell,
> but device tree bindings should use real units, like seconds, Ohms,
> Farads, etc. Is the edge rate in nS? Or is it some magic value which
> just gets written into the register?
> 

This is some magic value which just gets written into the register.

In device tree file, defined in davinci_mdio structure:

        vsc8531_0: ethernet-phy@0 {
                compatible = "ethernet-phy-id0007.0570";
                reg = <0>;
                vsc8531,edge-rate = /bits/ 8 <MSCC_EDGE_RATE_CNTL_FASTEST>;
        };

In device tree binding header file, MACRO has defined as
i.e. include/dt-bindings/net/mscc-vsc8531.h

/* MAC interface Edge rate control pad */
#define MSCC_EDGE_RATE_CNTL_SLOWEST      0x0
#define MSCC_EDGE_RATE_CNTL_PLUS_1       0x1
#define MSCC_EDGE_RATE_CNTL_PLUS_2       0x2
#define MSCC_EDGE_RATE_CNTL_PLUS_3       0x3
#define MSCC_EDGE_RATE_CNTL_PLUS_4       0x4
#define MSCC_EDGE_RATE_CNTL_PLUS_5       0x5
#define MSCC_EDGE_RATE_CNTL_PLUS_6       0x6
#define MSCC_EDGE_RATE_CNTL_FASTEST      0x7

> > +
> > +     return rc;
> > +}
> > +#else
> > +static int vsc8531_of_init(struct phy_device *phydev)
> > +{
> > +     return 0;
> > +}
> > +#endif /* CONFIG_OF_MDIO */
> > +
> >  static int vsc85xx_config_init(struct phy_device *phydev)
> >  {
> >       int rc;
> > +     struct vsc8531_private *vsc8531;
> > +
> > +     if (!phydev->priv) {
> 
> How can this happen?
> 

VSC 8531 driver don't have any private structure assigned initially.
Allways priv points to NULL. 
Allocate vsc8531 private structure and initialize by calling vsc8531_of_init( )
function.

> > +             vsc8531 = devm_kzalloc(&phydev->mdio.dev, sizeof(*vsc8531),
> > +                                    GFP_KERNEL);
> > +             if (!vsc8531)
> > +                     return -ENOMEM;
> > +
> > +             phydev->priv = vsc8531;
> > +             rc = vsc8531_of_init(phydev);
> > +             if (rc)
> > +                     return rc;
> > +     } else {
> > +             vsc8531 = (struct vsc8531_private *)phydev->priv;
> > +     }
> >
> >       rc = vsc85xx_default_config(phydev);
> >       if (rc)
> >               return rc;
> > +
> > +     rc = vsc85xx_edge_rate_cntl_set(phydev, vsc8531->edge_rate);
> 
> If there is no vsc8531,edge-rate property in device tree, is the phy
> going to work O.K, if you configure it for 0nS edges? Or should there
> be some default value assigned?
> 
Yes. Default values configured as Fast Edge rate control (i.e.0b111).
Edge rate control has defined 3 bits (Bit 7:5) in register.
Hardware default value is 3 (i.e. 0b111)


> Thanks
>         Andrew

Thanks
Raju.
