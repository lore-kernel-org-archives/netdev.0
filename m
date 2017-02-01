From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Wed, 1 Feb 2017 14:55:55 +0100
Message-ID: <20170201135555.GE4967@lunn.ch>
References: <1485953626-25780-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1485953626-25780-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52424 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750932AbdBANz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 08:55:59 -0500
Content-Disposition: inline
In-Reply-To: <1485953626-25780-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 01, 2017 at 06:23:46PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> LED Mode:
> Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
> status information that can be selected by setting LED mode.
> 
> LED Mode parameter (vsc8531, led-0-mode) and (vsc8531, led-1-mode) get
> from Device Tree.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> ---
>  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 10 +++
>  drivers/net/phy/mscc.c                             | 85 +++++++++++++++++++++-
>  include/dt-bindings/net/mscc-phy-vsc8531.h         | 29 ++++++++
>  3 files changed, 123 insertions(+), 1 deletion(-)
>  create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h
> 
> diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> index bdefefc6..bb7450c 100644
> --- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> @@ -27,6 +27,14 @@ Optional properties:
>  			  'vddmac'.
>  			  Default value is 0%.
>  			  Ref: Table:1 - Edge rate change (below).
> +- vsc8531,led-0-mode	: LED mode. Specify how the LED[0] should behave.
> +			  Allowed values are define in
> +			  "include/dt-bindings/net/mscc-phy-vsc8531.h".
> +			  Default value is 1.

1 is not very useful. What does it mean? How about:

			Default value is LINK_1000_ACTIVITY (1)     	      	      	   

> +- vsc8531,led-1-mode	: LED mode. Specify how the LED[1] should behave.
> +			  Allowed values are define in
> +			  "include/dt-bindings/net/mscc-phy-vsc8531.h".
> +			  Default value is 2.
>  
>  Table: 1 - Edge rate change
>  ----------------------------------------------------------------|
> @@ -60,4 +68,6 @@ Example:
>                  compatible = "ethernet-phy-id0007.0570";
>                  vsc8531,vddmac		= <3300>;
>                  vsc8531,edge-slowdown	= <7>;
> +                vsc8531,led-0-mode	= <LINK_1000_ACTIVITY>;
> +                vsc8531,led-1-mode	= <LINK_100_ACTIVITY>;
>          };
> diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
> index e03ead8..f0cb7cc 100644
> --- a/drivers/net/phy/mscc.c
> +++ b/drivers/net/phy/mscc.c
> @@ -13,6 +13,7 @@
>  #include <linux/phy.h>
>  #include <linux/of.h>
>  #include <linux/netdevice.h>
> +#include <dt-bindings/net/mscc-phy-vsc8531.h>
>  
>  enum rgmii_rx_clock_delay {
>  	RGMII_RX_CLK_DELAY_0_2_NS = 0,
> @@ -52,6 +53,11 @@ enum rgmii_rx_clock_delay {
>  #define MSCC_PHY_DEV_AUX_CNTL		  28
>  #define HP_AUTO_MDIX_X_OVER_IND_MASK	  0x2000
>  
> +#define MSCC_PHY_LED_MODE_SEL		  29
> +#define LED_1_MODE_SEL_MASK		  0x00F0
> +#define LED_0_MODE_SEL_MASK		  0x000F
> +#define LED_1_MODE_SEL_POS		  4
> +
>  #define MSCC_EXT_PAGE_ACCESS		  31
>  #define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
>  #define MSCC_PHY_PAGE_EXTENDED		  0x0001 /* Extended registers */
> @@ -99,6 +105,8 @@ enum rgmii_rx_clock_delay {
>  
>  struct vsc8531_private {
>  	int rate_magic;
> +	u8 led_0_mode;
> +	u8 led_1_mode;
>  };
>  
>  #ifdef CONFIG_OF_MDIO
> @@ -123,6 +131,29 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
>  	return rc;
>  }
>  
> +static int vsc85xx_led_cntl_set(struct phy_device *phydev,
> +				u8 led_num,
> +				u8 mode)
> +{
> +	int rc;
> +	u16 reg_val;
> +
> +	mutex_lock(&phydev->lock);
> +	reg_val = phy_read(phydev, MSCC_PHY_LED_MODE_SEL);
> +	if (led_num) {
> +		reg_val &= ~LED_1_MODE_SEL_MASK;
> +		reg_val |= (((u16)mode << LED_1_MODE_SEL_POS) &
> +			    LED_1_MODE_SEL_MASK);
> +	} else {
> +		reg_val &= ~LED_0_MODE_SEL_MASK;
> +		reg_val |= ((u16)mode & LED_0_MODE_SEL_MASK);
> +	}
> +	rc = phy_write(phydev, MSCC_PHY_LED_MODE_SEL, reg_val);
> +	mutex_unlock(&phydev->lock);
> +
> +	return rc;
> +}
> +
>  static int vsc85xx_mdix_get(struct phy_device *phydev, u8 *mdix)
>  {
>  	u16 reg_val;
> @@ -370,11 +401,43 @@ static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
>  
>  	return -EINVAL;
>  }
> +
> +static int vsc85xx_dt_led_mode_get(struct phy_device *phydev,
> +				   char *led,
> +				   u8 default_mode)
> +{
> +	struct device *dev = &phydev->mdio.dev;
> +	struct device_node *of_node = dev->of_node;
> +	u8 led_mode;
> +	int rc;
> +
> +	if (!of_node)
> +		return -ENODEV;
> +
> +	rc = of_property_read_u8(of_node, led, &led_mode);
> +	if ((rc == 0) &&
> +	    ((led_mode > 15) || (led_mode == 7) || (led_mode == 11))) {
> +		phydev_err(phydev, "DT %s invalid\n", led);
> +		return -EINVAL;
> +	} else if (rc == -EINVAL) {
> +		return default_mode;
> +	}

I don't think you understood my comment about of_property_read_u8()
not modifying &led_mode on error. Please read the comment again, and
simplify this.

> +
> +	return led_mode;
> +}
> +
>  #else
>  static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
>  {
>  	return 0;
>  }
> +
> +static int vsc85xx_dt_led_mode_get(struct phy_device *phydev,
> +				   char *led,
> +				   u8 default_mode)
> +{
> +	return default_mode;
> +}
>  #endif /* CONFIG_OF_MDIO */
>  
>  static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev, u8 edge_rate)
> @@ -499,6 +562,13 @@ static int vsc85xx_config_init(struct phy_device *phydev)
>  	if (rc)
>  		return rc;
>  
> +	rc = vsc85xx_led_cntl_set(phydev, 1, vsc8531->led_1_mode);
> +	if (rc)
> +		return rc;

Blank line please.

> +	rc = vsc85xx_led_cntl_set(phydev, 0, vsc8531->led_0_mode);
> +	if (rc)
> +		return rc;
> +
>  	rc = genphy_config_init(phydev);
>  
>  	return rc;
> @@ -555,8 +625,9 @@ static int vsc85xx_read_status(struct phy_device *phydev)
>  
>  static int vsc85xx_probe(struct phy_device *phydev)
>  {
> -	int rate_magic;
>  	struct vsc8531_private *vsc8531;
> +	int rate_magic;
> +	int led_mode;
>  
>  	rate_magic = vsc85xx_edge_rate_magic_get(phydev);
>  	if (rate_magic < 0)
> @@ -570,6 +641,18 @@ static int vsc85xx_probe(struct phy_device *phydev)
>  
>  	vsc8531->rate_magic = rate_magic;
>  
> +	/* LED[0] and LED[1] mode */
> +	led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-0-mode",
> +					   LINK_1000_ACTIVITY);
> +	if (led_mode < 0)
> +		return led_mode;
> +	vsc8531->led_0_mode = led_mode;

Blank line.

> +	led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-1-mode",
> +					   LINK_100_ACTIVITY);
> +	if (led_mode < 0)
> +		return led_mode;
> +	vsc8531->led_1_mode = led_mode;
> +
>  	return 0;
>  }
>  
> diff --git a/include/dt-bindings/net/mscc-phy-vsc8531.h b/include/dt-bindings/net/mscc-phy-vsc8531.h
> new file mode 100644
> index 0000000..af6af98
> --- /dev/null
> +++ b/include/dt-bindings/net/mscc-phy-vsc8531.h
> @@ -0,0 +1,29 @@
> +/*
> + * Device Tree constants for Microsemi VSC8531 PHY
> + *
> + * Author: Nagaraju Lakkaraju
> + *
> + * License: Dual MIT/GPL
> + * Copyright (c) 2017 Microsemi Corporation
> + */
> +
> +#ifndef _DT_BINDINGS_MSCC_VSC8531_H
> +#define _DT_BINDINGS_MSCC_VSC8531_H
> +
> +/* PHY LED Modes */
> +#define LINK_ACTIVITY           0
> +#define LINK_1000_ACTIVITY      1
> +#define LINK_100_ACTIVITY       2
> +#define LINK_10_ACTIVITY        3
> +#define LINK_100_1000_ACTIVITY  4
> +#define LINK_10_1000_ACTIVITY   5
> +#define LINK_10_100_ACTIVITY    6
> +#define DUPLEX_COLLISION        8
> +#define COLLISION               9
> +#define ACTIVITY                10
> +#define AUTONEG_FAULT           12
> +#define SERIAL_MODE             13
> +#define FORCE_LED_OFF           14
> +#define FORCE_LED_ON            15

You should prefix these with VSC8531_. Otherwise there is potential to
have issues with two different PHYs defining some of these frequently
used macros.

     Andrew
