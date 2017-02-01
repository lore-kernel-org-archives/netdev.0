From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Wed, 1 Feb 2017 15:02:18 +0530
Message-ID: <20170201093217.GA29715@microsemi.com>
References: <1485841561-32056-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1485841561-32056-2-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20170131133009.GA6894@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0088.outbound.protection.outlook.com ([104.47.33.88]:10304
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751482AbdBAJcm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 04:32:42 -0500
Content-Disposition: inline
In-Reply-To: <20170131133009.GA6894@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review and valuable comments.

On Tue, Jan 31, 2017 at 02:30:09PM +0100, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Tue, Jan 31, 2017 at 11:16:01AM +0530, Raju Lakkaraju wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> >
> > LED Mode:
> > Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
> > status information that can be selected by setting LED mode.
> >
> > LED Mode parameter (vddmac, led-0-mode) and (vddmac, led-1-mode) get
> > from Device Tree.
> 
> Hi Raju
> 
> How is vddmac an LED mode parameter?
> 

Typo. I will correct.
It should be "vsc8531, led-0-mode".

> > Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > ---
> >  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 39 ++++++++++++
> >  drivers/net/phy/mscc.c                             | 72 ++++++++++++++++++++++
> >  2 files changed, 111 insertions(+)
> >
> > diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> > index bdefefc6..1abf4b6 100644
> > --- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> > +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> > @@ -27,6 +27,12 @@ Optional properties:
> >                         'vddmac'.
> >                         Default value is 0%.
> >                         Ref: Table:1 - Edge rate change (below).
> > +- vsc8531,led-0-mode : LED mode. Specify how the LED[0] should behave.
> > +                       Allowed values is listed in the 'PHY LED Mode' -
> > +                       Table 2 (below).  Default value is 1.
> > +- vsc8531,led-1-mode : LED mode. Specify how the LED[1] should behave.
> > +                       Allowed values is listed in the 'PHY LED Mode' -
> > +                       Table 2 (below).  Default value is 2.
> >
> >  Table: 1 - Edge rate change
> >  ----------------------------------------------------------------|
> > @@ -54,10 +60,43 @@ Table: 1 - Edge rate change
> >  | (slowest)                                                  |
> >  |---------------------------------------------------------------|
> >
> > +Table: 2 - PHY LED Mode
> > +|-----------------------------------------------|
> > +| LINK_ACTIVITY                      | 0             |
> > +|-----------------------------------------------|
> > +| LINK_1000_ACTIVITY         | 1             |
> > +|-----------------------------------------------|
> > +| LINK_100_ACTIVITY          | 2             |
> > +|-----------------------------------------------|
> > +| LINK_10_ACTIVITY           | 3             |
> > +|-----------------------------------------------|
> > +| LINK_100_1000_ACTIVITY     | 4             |
> > +|-----------------------------------------------|
> > +| LINK_10_1000_ACTIVITY              | 5             |
> > +|-----------------------------------------------|
> > +| LINK_10_100_ACTIVITY               | 6             |
> > +|-----------------------------------------------|
> > +| DUPLEX_COLLISION           | 8             |
> > +|-----------------------------------------------|
> > +| COLLISION                  | 9             |
> > +|-----------------------------------------------|
> > +| ACTIVITY                   | 10            |
> > +|-----------------------------------------------|
> > +| AUTONEG_FAULT                      | 12            |
> > +|-----------------------------------------------|
> > +| SERIAL_MODE                        | 13            |
> > +|-----------------------------------------------|
> > +| FORCE_LED_OFF                      | 14            |
> > +|-----------------------------------------------|
> > +| FORCE_LED_ON                       | 15            |
> > +|-----------------------------------------------|
> > +
> >  Example:
> >
> >          vsc8531_0: ethernet-phy@0 {
> >                  compatible = "ethernet-phy-id0007.0570";
> >                  vsc8531,vddmac               = <3300>;
> >                  vsc8531,edge-slowdown        = <7>;
> > +                vsc8531,led-0-mode   = <1>;
> > +                vsc8531,led-1-mode   = <2>;
> 
> Numbers like this are pretty unreadable. I would suggest adding a header file in
> include/dt-bindings/net/
> 

Accpeted. I will create new header file for DT Macros.

> > +static int vsc85xx_led_cntl_set(struct phy_device *phydev,
> > +                             u8 led_num,
> > +                             u8 mode)
> > +{
> > +     int rc;
> > +     u16 reg_val;
> > +
> > +     mutex_lock(&phydev->lock);
> > +     reg_val = phy_read(phydev, MSCC_PHY_LED_MODE_SEL);
> > +     if (led_num) {
> > +             reg_val &= ~LED_1_MODE_SEL_MASK;
> > +             reg_val |= (((u16)mode << LED_1_MODE_SEL_POS) &
> > +                         LED_1_MODE_SEL_MASK);
> > +     } else {
> > +             reg_val |= ((u16)mode & LED_0_MODE_SEL_MASK);
> > +     }
> 
> The asymmetry here makes me think this is wrong.
> 

Yes. You are correct.
I missed following line in else part:
"reg_val &= ~LED_0_MODE_SEL_MASK;"

> > +     rc = phy_write(phydev, MSCC_PHY_LED_MODE_SEL, reg_val);
> > +     mutex_unlock(&phydev->lock);
> > +
> > +     return rc;
> > +}
> > +
> >  static int vsc85xx_mdix_get(struct phy_device *phydev, u8 *mdix)
> >  {
> >       u16 reg_val;
> > @@ -499,6 +547,13 @@ static int vsc85xx_config_init(struct phy_device *phydev)
> >       if (rc)
> >               return rc;
> >
> > +     rc = vsc85xx_led_cntl_set(phydev, 1, vsc8531->led_1_mode);
> > +     if (rc)
> > +             return rc;
> > +     rc = vsc85xx_led_cntl_set(phydev, 0, vsc8531->led_0_mode);
> > +     if (rc)
> > +             return rc;
> > +
> >       rc = genphy_config_init(phydev);
> >
> >       return rc;
> > @@ -555,8 +610,13 @@ static int vsc85xx_read_status(struct phy_device *phydev)
> >
> >  static int vsc85xx_probe(struct phy_device *phydev)
> >  {
> > +     int rc;
> >       int rate_magic;
> > +     u8 led_0_mode;
> > +     u8 led_1_mode;
> >       struct vsc8531_private *vsc8531;
> > +     struct device *dev = &phydev->mdio.dev;
> > +     struct device_node *of_node = dev->of_node;
> 
> declarations are supposed to be reverse Christmas tree. i.e. longest
> lines first.
> 

Accpeted.

> >
> >       rate_magic = vsc85xx_edge_rate_magic_get(phydev);
> >       if (rate_magic < 0)
> > @@ -570,6 +630,18 @@ static int vsc85xx_probe(struct phy_device *phydev)
> >
> >       vsc8531->rate_magic = rate_magic;
> >
> > +     /* LED[0] and LED[1] mode */
> > +     rc = of_property_read_u8(of_node, "vsc8531,led-0-mode", &led_0_mode);
> > +     if (rc != 0)
> 
> Please simplify this to just if (rc). Actually, it can be even
> simpler.  of_property_read_u8 guarantees not to modify the return
> value unless it has a value to return. So
> 
>         vsc8531->led_0_mode = LINK_1000_ACTIVITY;
>         err = of_property_read_u8(of_node, "vsc8531,led-0-mode", &led_0_mode);
>         if (err != EINVAL)
>                 return err;
> 
>         vsc8531->led_1_mode = LINK_100_ACTIVITY;
>         err = of_property_read_u8(of_node, "vsc8531,led-1-mode", &led_1_mode);
>         if (err != EINVAL)
>                 return err;
> 
> What about range checking? I could put 42 in the device tree for led
> 0, and it would set led 1 as well i think?
> 

Accpeted. I will add range check and error condition.
If DT don't have LED parameters define, driver should program with default values.

>    Andrew

---
Thanks,
Raju.
