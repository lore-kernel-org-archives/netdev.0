From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: RE: Microsemi VSC 8531/41 PHY Driver
Date: Thu, 28 Jul 2016 06:44:37 +0000
Message-ID: <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
 <20160726124347.GD11538@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0052.outbound.protection.outlook.com ([104.47.32.52]:30249
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1162284AbcG1HAE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 03:00:04 -0400
In-Reply-To: <20160726124347.GD11538@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andrew,

Thank you for given valuable comments.
Please see the my responses inline.

Thanks,
Raju

-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Tuesday, July 26, 2016 6:14 PM
To: Raju Lakkaraju
Cc: netdev@vger.kernel.org; f.fainelli@gmail.com; Allan Nielsen
Subject: Re: Microsemi VSC 8531/41 PHY Driver

EXTERNAL EMAIL


> +/* RGMII Rx Clock delay value change with board lay-out */ static u8 
> +rgmii_rx_clk_delay = RGMII_RX_CLK_DELAY_1_1_NS;

Doesn't this stop you from having a board with two PHYs with different layouts? You should be getting this value from the device tree.

Raju: As of now, RGMII Rx clock delay value should be 1.1 nsec as optimized/recommended value. 
We tested on Beaglebone Black with VSC 8531 PHY.
We would like to provide new function to configure correct/require value based on PHY layouts 
alone with other RGMII configuration parameters as part of our next implementation.

> +     phydev->supported = (SUPPORTED_1000baseT_Full |
> +                          SUPPORTED_1000baseT_Half |
> +                          SUPPORTED_100baseT_Full  |
> +                          SUPPORTED_100baseT_Half  |
> +                          SUPPORTED_10baseT_Full   |
> +                          SUPPORTED_10baseT_Half   |
> +                          SUPPORTED_Autoneg        |
> +                          SUPPORTED_Pause          |
> +                          SUPPORTED_Asym_Pause     |
> +                          SUPPORTED_TP);
> +
> +     phydev->speed = SPEED_1000;
> +     phydev->duplex = DUPLEX_FULL;
> +     phydev->pause = 0;
> +     phydev->asym_pause = 0;
> +     phydev->interface = PHY_INTERFACE_MODE_RGMII;
> +     phydev->mdix = ETH_TP_MDI_AUTO;

Why are you setting all these? This is not normal, if you look at other drivers.

Raju: I would like to update the default values in software data structure (phydev). 
Our PHY is 1G speed support device and RGMII supported device.

> +
> +     mutex_lock(&phydev->lock);

What are you locking against?

Raju: VSC 8531 has different PAGEs. Whenever MDC/MDIO access the PHY control registers, 
first set the page number then read/write the register address. Default page should be Page 0.
When I want to access not default page register, I have to lock phy device access and change 
the page number and register access as atomic operation. 

> +     rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
> +     if (rc != 0) {
> +             rc = -EINVAL;

Why do you overwrite the error code vsc85xx_phy_page_set gives you?

Raju: initially I would like to create new type of Error code. Then, I decided to use existing one. 
I accept your comment. I will remove the code.

> +             goto out_unlock;
> +     }
> +     reg_val = phy_read(phydev, MSCC_PHY_RGMII_CNTL);
> +     reg_val &= ~(RGMII_RX_CLK_DELAY_MASK);
> +     reg_val |= (rgmii_rx_clk_delay << RGMII_RX_CLK_DELAY_POS);
> +     phy_write(phydev, MSCC_PHY_RGMII_CNTL, reg_val);
> +     rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
> +     if (rc != 0)
> +             rc = -EINVAL;

Same here.

Raju: I accept your comment. I will remove the code.

> +
> +out_unlock:
> +     mutex_unlock(&phydev->lock);
> +
> +     return rc;
> +}
> +
> +static int vsc85xx_config_init(struct phy_device *phydev) {
> +     int rc = 0;

No need to initialise rc.

Raju: I accept your comment. I will remove the code.

> +     rc = vsc85xx_default_config(phydev);

        if (rc)
                return rc;

> +     rc = genphy_config_init(phydev);
> +
> +     return rc;

Or just
        return genphy_config_init(phydev);

Raju: I accept your comment. I will remove the code.

> +}
> +
> +static int vsc85xx_ack_interrupt(struct phy_device *phydev) {
> +     int rc = 0;
> +
> +     if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
> +             rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
> +
> +     return (rc < 0) ? rc : 0;
> +}
> +
> +static int vsc85xx_config_intr(struct phy_device *phydev) {
> +     int rc;
> +
> +     if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
> +             rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
> +                            MII_VSC85XX_INT_MASK_MASK);
> +     } else {
> +             rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
> +             if (rc < 0)
> +                     return rc;

And the purpose of this read is? I assume it clears an outstanding interrupt? If so, shouldn't you do it after disabling interrupts, not before? Otherwise you have a race condition.

Raju: The Interrupt status register is read on clean. When, PHY_INTERRUPT_DISABLE case, 
I should make sure that status should be clear. If I read the Interrupt status registers, it clears all preexisting interrupts.

> +             rc = phy_write(phydev, MII_VSC85XX_INT_MASK, 0);
> +     }
> +
> +     return rc;

  Andrew
