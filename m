From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/5] net: phy: Add Broadcom phy library for common
 interfaces
Date: Wed, 14 Oct 2015 10:38:28 -0700
Message-ID: <561E9314.4070203@gmail.com>
References: <1444159550-3432-1-git-send-email-arunp@broadcom.com> <1444159550-3432-4-git-send-email-arunp@broadcom.com> <561E91F6.5070505@mindchasers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Robert E Cochran <network-KHy0ndQbE3UswetKESUqMA@public.gmane.org>,
	Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <561E91F6.5070505-KHy0ndQbE3UswetKESUqMA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 14/10/15 10:33, Robert E Cochran wrote:
> 
> 
> On 10/06/2015 03:25 PM, Arun Parameswaran wrote:
>> This patch adds the Broadcom phy library to consolidate common
>> interfaces shared by Broadcom phy's.
> 
> The BCM54612E is included in the Broadcom Community part portfolio
> (https://community.broadcom.com).  However, I don't see this part
> explicitly supported by your phy library ( e.g., not included in
> broadcom_drivers[] in broadcom.c ).

These are external PHY products which have a different support channel
and engineering teams.

> 
> Can you please comment on whether this part is supported or the extent
> of changes required to establish and support a robust GigE connection
> between RGMII and CU?

This probably deserves a separate thread rather than hijacking an
existing one?

> 
> We're considering this part for a new embedded design, and we need an
> open source driver for it.
> 
> Thanks
> 
> Bob
> 
> 
> 
>>
>> Moved the common interfaces to the 'bcm-phy-lib.c' and updated
>> the Broadcom PHY drivers to use the new APIs.
>>
>> Signed-off-by: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> ---
>>   drivers/net/phy/Kconfig       |   6 ++
>>   drivers/net/phy/Makefile      |   1 +
>>   drivers/net/phy/bcm-phy-lib.c | 209
>> ++++++++++++++++++++++++++++++++++++++++++
>>   drivers/net/phy/bcm-phy-lib.h |  37 ++++++++
>>   drivers/net/phy/bcm63xx.c     |  38 +-------
>>   drivers/net/phy/bcm7xxx.c     | 127 ++++++-------------------
>>   drivers/net/phy/broadcom.c    | 149 +++++++++---------------------
>>   include/linux/brcmphy.h       |  22 +----
>>   8 files changed, 333 insertions(+), 256 deletions(-)
>>   create mode 100644 drivers/net/phy/bcm-phy-lib.c
>>   create mode 100644 drivers/net/phy/bcm-phy-lib.h
>>
>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>> index b57f6c2..606fdc9 100644
>> --- a/drivers/net/phy/Kconfig
>> +++ b/drivers/net/phy/Kconfig
>> @@ -69,8 +69,12 @@ config SMSC_PHY
>>       ---help---
>>         Currently supports the LAN83C185, LAN8187 and LAN8700 PHYs
>>   +config BCM_NET_PHYLIB
>> +    tristate
>> +
>>   config BROADCOM_PHY
>>       tristate "Drivers for Broadcom PHYs"
>> +    select BCM_NET_PHYLIB
>>       ---help---
>>         Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S,
>> BCM5464,
>>         BCM5481 and BCM5482 PHYs.
>> @@ -78,11 +82,13 @@ config BROADCOM_PHY
>>   config BCM63XX_PHY
>>       tristate "Drivers for Broadcom 63xx SOCs internal PHY"
>>       depends on BCM63XX
>> +    select BCM_NET_PHYLIB
>>       ---help---
>>         Currently supports the 6348 and 6358 PHYs.
>>     config BCM7XXX_PHY
>>       tristate "Drivers for Broadcom 7xxx SOCs internal PHYs"
>> +    select BCM_NET_PHYLIB
>>       ---help---
>>         Currently supports the BCM7366, BCM7439, BCM7445, and
>>         40nm and 65nm generation of BCM7xxx Set Top Box SoCs.
>> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
>> index f4e6eb9..6932475 100644
>> --- a/drivers/net/phy/Makefile
>> +++ b/drivers/net/phy/Makefile
>> @@ -12,6 +12,7 @@ obj-$(CONFIG_QSEMI_PHY)        += qsemi.o
>>   obj-$(CONFIG_SMSC_PHY)        += smsc.o
>>   obj-$(CONFIG_TERANETICS_PHY)    += teranetics.o
>>   obj-$(CONFIG_VITESSE_PHY)    += vitesse.o
>> +obj-$(CONFIG_BCM_NET_PHYLIB)    += bcm-phy-lib.o
>>   obj-$(CONFIG_BROADCOM_PHY)    += broadcom.o
>>   obj-$(CONFIG_BCM63XX_PHY)    += bcm63xx.o
>>   obj-$(CONFIG_BCM7XXX_PHY)    += bcm7xxx.o
>> diff --git a/drivers/net/phy/bcm-phy-lib.c
>> b/drivers/net/phy/bcm-phy-lib.c
>> new file mode 100644
>> index 0000000..13e161e
>> --- /dev/null
>> +++ b/drivers/net/phy/bcm-phy-lib.c
>> @@ -0,0 +1,209 @@
>> +/*
>> + * Copyright (C) 2015 Broadcom Corporation
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License as
>> + * published by the Free Software Foundation version 2.
>> + *
>> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
>> + * kind, whether express or implied; without even the implied warranty
>> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
>> + * GNU General Public License for more details.
>> + */
>> +
>> +#include "bcm-phy-lib.h"
>> +#include <linux/brcmphy.h>
>> +#include <linux/export.h>
>> +#include <linux/mdio.h>
>> +#include <linux/phy.h>
>> +
>> +#define MII_BCM_CHANNEL_WIDTH     0x2000
>> +#define BCM_CL45VEN_EEE_ADV       0x3c
>> +
>> +int bcm_phy_write_exp(struct phy_device *phydev, u16 reg, u16 val)
>> +{
>> +    int rc;
>> +
>> +    rc = phy_write(phydev, MII_BCM54XX_EXP_SEL, reg);
>> +    if (rc < 0)
>> +        return rc;
>> +
>> +    return phy_write(phydev, MII_BCM54XX_EXP_DATA, val);
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_write_exp);
>> +
>> +int bcm_phy_read_exp(struct phy_device *phydev, u16 reg)
>> +{
>> +    int val;
>> +
>> +    val = phy_write(phydev, MII_BCM54XX_EXP_SEL, reg);
>> +    if (val < 0)
>> +        return val;
>> +
>> +    val = phy_read(phydev, MII_BCM54XX_EXP_DATA);
>> +
>> +    /* Restore default value.  It's O.K. if this write fails. */
>> +    phy_write(phydev, MII_BCM54XX_EXP_SEL, 0);
>> +
>> +    return val;
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_read_exp);
>> +
>> +int bcm_phy_write_misc(struct phy_device *phydev,
>> +               u16 reg, u16 chl, u16 val)
>> +{
>> +    int rc;
>> +    int tmp;
>> +
>> +    rc = phy_write(phydev, MII_BCM54XX_AUX_CTL,
>> +               MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
>> +    if (rc < 0)
>> +        return rc;
>> +
>> +    tmp = phy_read(phydev, MII_BCM54XX_AUX_CTL);
>> +    tmp |= MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA;
>> +    rc = phy_write(phydev, MII_BCM54XX_AUX_CTL, tmp);
>> +    if (rc < 0)
>> +        return rc;
>> +
>> +    tmp = (chl * MII_BCM_CHANNEL_WIDTH) | reg;
>> +    rc = bcm_phy_write_exp(phydev, tmp, val);
>> +
>> +    return rc;
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_write_misc);
>> +
>> +int bcm_phy_read_misc(struct phy_device *phydev,
>> +              u16 reg, u16 chl)
>> +{
>> +    int rc;
>> +    int tmp;
>> +
>> +    rc = phy_write(phydev, MII_BCM54XX_AUX_CTL,
>> +               MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
>> +    if (rc < 0)
>> +        return rc;
>> +
>> +    tmp = phy_read(phydev, MII_BCM54XX_AUX_CTL);
>> +    tmp |= MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA;
>> +    rc = phy_write(phydev, MII_BCM54XX_AUX_CTL, tmp);
>> +    if (rc < 0)
>> +        return rc;
>> +
>> +    tmp = (chl * MII_BCM_CHANNEL_WIDTH) | reg;
>> +    rc = bcm_phy_read_exp(phydev, tmp);
>> +
>> +    return rc;
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_read_misc);
>> +
>> +int bcm_phy_ack_intr(struct phy_device *phydev)
>> +{
>> +    int reg;
>> +
>> +    /* Clear pending interrupts.  */
>> +    reg = phy_read(phydev, MII_BCM54XX_ISR);
>> +    if (reg < 0)
>> +        return reg;
>> +
>> +    return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_ack_intr);
>> +
>> +int bcm_phy_config_intr(struct phy_device *phydev)
>> +{
>> +    int reg;
>> +
>> +    reg = phy_read(phydev, MII_BCM54XX_ECR);
>> +    if (reg < 0)
>> +        return reg;
>> +
>> +    if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
>> +        reg &= ~MII_BCM54XX_ECR_IM;
>> +    else
>> +        reg |= MII_BCM54XX_ECR_IM;
>> +
>> +    return phy_write(phydev, MII_BCM54XX_ECR, reg);
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_config_intr);
>> +
>> +int bcm_phy_read_shadow(struct phy_device *phydev, u16 shadow)
>> +{
>> +    phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_VAL(shadow));
>> +    return MII_BCM54XX_SHD_DATA(phy_read(phydev, MII_BCM54XX_SHD));
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_read_shadow);
>> +
>> +int bcm_phy_write_shadow(struct phy_device *phydev, u16 shadow,
>> +             u16 val)
>> +{
>> +    return phy_write(phydev, MII_BCM54XX_SHD,
>> +             MII_BCM54XX_SHD_WRITE |
>> +             MII_BCM54XX_SHD_VAL(shadow) |
>> +             MII_BCM54XX_SHD_DATA(val));
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_write_shadow);
>> +
>> +int bcm_phy_enable_apd(struct phy_device *phydev, bool dll_pwr_down)
>> +{
>> +    int val;
>> +
>> +    if (dll_pwr_down) {
>> +        val = bcm_phy_read_shadow(phydev, BCM54XX_SHD_SCR3);
>> +        if (val < 0)
>> +            return val;
>> +
>> +        val |= BCM54XX_SHD_SCR3_DLLAPD_DIS;
>> +        bcm_phy_write_shadow(phydev, BCM54XX_SHD_SCR3, val);
>> +    }
>> +
>> +    val = bcm_phy_read_shadow(phydev, BCM54XX_SHD_APD);
>> +    if (val < 0)
>> +        return val;
>> +
>> +    /* Clear APD bits */
>> +    val &= BCM_APD_CLR_MASK;
>> +
>> +    if (phydev->autoneg == AUTONEG_ENABLE)
>> +        val |= BCM54XX_SHD_APD_EN;
>> +    else
>> +        val |= BCM_NO_ANEG_APD_EN;
>> +
>> +    /* Enable energy detect single link pulse for easy wakeup */
>> +    val |= BCM_APD_SINGLELP_EN;
>> +
>> +    /* Enable Auto Power-Down (APD) for the PHY */
>> +    return bcm_phy_write_shadow(phydev, BCM54XX_SHD_APD, val);
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_enable_apd);
>> +
>> +int bcm_phy_enable_eee(struct phy_device *phydev)
>> +{
>> +    int val;
>> +
>> +    /* Enable EEE at PHY level */
>> +    val = phy_read_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
>> +                    MDIO_MMD_AN, phydev->addr);
>> +    if (val < 0)
>> +        return val;
>> +
>> +    val |= LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X;
>> +
>> +    phy_write_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
>> +                   MDIO_MMD_AN,  phydev->addr, (u32)val);
>> +
>> +    /* Advertise EEE */
>> +    val = phy_read_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
>> +                    MDIO_MMD_AN, phydev->addr);
>> +    if (val < 0)
>> +        return val;
>> +
>> +    val |= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
>> +
>> +    phy_write_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
>> +                   MDIO_MMD_AN,  phydev->addr, (u32)val);
>> +
>> +    return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(bcm_phy_enable_eee);
>> +
>> diff --git a/drivers/net/phy/bcm-phy-lib.h
>> b/drivers/net/phy/bcm-phy-lib.h
>> new file mode 100644
>> index 0000000..b2091c8
>> --- /dev/null
>> +++ b/drivers/net/phy/bcm-phy-lib.h
>> @@ -0,0 +1,37 @@
>> +/*
>> + * Copyright (C) 2015 Broadcom Corporation
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License as
>> + * published by the Free Software Foundation version 2.
>> + *
>> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
>> + * kind, whether express or implied; without even the implied warranty
>> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
>> + * GNU General Public License for more details.
>> + */
>> +
>> +#ifndef _LINUX_BCM_PHY_LIB_H
>> +#define _LINUX_BCM_PHY_LIB_H
>> +
>> +#include <linux/phy.h>
>> +
>> +int bcm_phy_write_exp(struct phy_device *phydev, u16 reg, u16 val);
>> +int bcm_phy_read_exp(struct phy_device *phydev, u16 reg);
>> +
>> +int bcm_phy_write_misc(struct phy_device *phydev,
>> +               u16 reg, u16 chl, u16 value);
>> +int bcm_phy_read_misc(struct phy_device *phydev,
>> +              u16 reg, u16 chl);
>> +
>> +int bcm_phy_write_shadow(struct phy_device *phydev, u16 shadow,
>> +             u16 val);
>> +int bcm_phy_read_shadow(struct phy_device *phydev, u16 shadow);
>> +
>> +int bcm_phy_ack_intr(struct phy_device *phydev);
>> +int bcm_phy_config_intr(struct phy_device *phydev);
>> +
>> +int bcm_phy_enable_apd(struct phy_device *phydev, bool dll_pwr_down);
>> +
>> +int bcm_phy_enable_eee(struct phy_device *phydev);
>> +#endif /* _LINUX_BCM_PHY_LIB_H */
>> diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
>> index 830ec31..86b2805 100644
>> --- a/drivers/net/phy/bcm63xx.c
>> +++ b/drivers/net/phy/bcm63xx.c
>> @@ -6,6 +6,7 @@
>>    *    as published by the Free Software Foundation; either version
>>    *    2 of the License, or (at your option) any later version.
>>    */
>> +#include "bcm-phy-lib.h"
>>   #include <linux/module.h>
>>   #include <linux/phy.h>
>>   @@ -42,35 +43,6 @@ static int bcm63xx_config_init(struct phy_device
>> *phydev)
>>       return phy_write(phydev, MII_BCM63XX_IR, reg);
>>   }
>>   -static int bcm63xx_ack_interrupt(struct phy_device *phydev)
>> -{
>> -    int reg;
>> -
>> -    /* Clear pending interrupts.  */
>> -    reg = phy_read(phydev, MII_BCM63XX_IR);
>> -    if (reg < 0)
>> -        return reg;
>> -
>> -    return 0;
>> -}
>> -
>> -static int bcm63xx_config_intr(struct phy_device *phydev)
>> -{
>> -    int reg, err;
>> -
>> -    reg = phy_read(phydev, MII_BCM63XX_IR);
>> -    if (reg < 0)
>> -        return reg;
>> -
>> -    if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
>> -        reg &= ~MII_BCM63XX_IR_GMASK;
>> -    else
>> -        reg |= MII_BCM63XX_IR_GMASK;
>> -
>> -    err = phy_write(phydev, MII_BCM63XX_IR, reg);
>> -    return err;
>> -}
>> -
>>   static struct phy_driver bcm63xx_driver[] = {
>>   {
>>       .phy_id        = 0x00406000,
>> @@ -82,8 +54,8 @@ static struct phy_driver bcm63xx_driver[] = {
>>       .config_init    = bcm63xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm63xx_ack_interrupt,
>> -    .config_intr    = bcm63xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       /* same phy as above, with just a different OUI */
>> @@ -95,8 +67,8 @@ static struct phy_driver bcm63xx_driver[] = {
>>       .config_init    = bcm63xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm63xx_ack_interrupt,
>> -    .config_intr    = bcm63xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   } };
>>   diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
>> index 6b701b3..efa31a6 100644
>> --- a/drivers/net/phy/bcm7xxx.c
>> +++ b/drivers/net/phy/bcm7xxx.c
>> @@ -12,12 +12,12 @@
>>   #include <linux/module.h>
>>   #include <linux/phy.h>
>>   #include <linux/delay.h>
>> +#include "bcm-phy-lib.h"
>>   #include <linux/bitops.h>
>>   #include <linux/brcmphy.h>
>>   #include <linux/mdio.h>
>>     /* Broadcom BCM7xxx internal PHY registers */
>> -#define MII_BCM7XXX_CHANNEL_WIDTH    0x2000
>>     /* 40nm only register definitions */
>>   #define MII_BCM7XXX_100TX_AUX_CTL    0x10
>> @@ -48,37 +48,13 @@
>>     #define CORE_EXPB0            0xb0
>>   -static void phy_write_exp(struct phy_device *phydev,
>> -                    u16 reg, u16 value)
>> -{
>> -    phy_write(phydev, MII_BCM54XX_EXP_SEL, MII_BCM54XX_EXP_SEL_ER |
>> reg);
>> -    phy_write(phydev, MII_BCM54XX_EXP_DATA, value);
>> -}
>> -
>> -static void phy_write_misc(struct phy_device *phydev,
>> -                    u16 reg, u16 chl, u16 value)
>> -{
>> -    int tmp;
>> -
>> -    phy_write(phydev, MII_BCM54XX_AUX_CTL,
>> MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
>> -
>> -    tmp = phy_read(phydev, MII_BCM54XX_AUX_CTL);
>> -    tmp |= MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA;
>> -    phy_write(phydev, MII_BCM54XX_AUX_CTL, tmp);
>> -
>> -    tmp = (chl * MII_BCM7XXX_CHANNEL_WIDTH) | reg;
>> -    phy_write(phydev, MII_BCM54XX_EXP_SEL, tmp);
>> -
>> -    phy_write(phydev, MII_BCM54XX_EXP_DATA, value);
>> -}
>> -
>>   static void r_rc_cal_reset(struct phy_device *phydev)
>>   {
>>       /* Reset R_CAL/RC_CAL Engine */
>> -    phy_write_exp(phydev, 0x00b0, 0x0010);
>> +    bcm_phy_write_exp(phydev, 0x00b0, 0x0010);
>>         /* Disable Reset R_AL/RC_CAL Engine */
>> -    phy_write_exp(phydev, 0x00b0, 0x0000);
>> +    bcm_phy_write_exp(phydev, 0x00b0, 0x0000);
>>   }
>>     static int bcm7xxx_28nm_b0_afe_config_init(struct phy_device *phydev)
>> @@ -86,18 +62,18 @@ static int bcm7xxx_28nm_b0_afe_config_init(struct
>> phy_device *phydev)
>>       /* Increase VCO range to prevent unlocking problem of PLL at low
>>        * temp
>>        */
>> -    phy_write_misc(phydev, PLL_PLLCTRL_1, 0x0048);
>> +    bcm_phy_write_misc(phydev, PLL_PLLCTRL_1, 0x0048);
>>         /* Change Ki to 011 */
>> -    phy_write_misc(phydev, PLL_PLLCTRL_2, 0x021b);
>> +    bcm_phy_write_misc(phydev, PLL_PLLCTRL_2, 0x021b);
>>         /* Disable loading of TVCO buffer to bandgap, set bandgap trim
>>        * to 111
>>        */
>> -    phy_write_misc(phydev, PLL_PLLCTRL_4, 0x0e20);
>> +    bcm_phy_write_misc(phydev, PLL_PLLCTRL_4, 0x0e20);
>>         /* Adjust bias current trim by -3 */
>> -    phy_write_misc(phydev, DSP_TAP10, 0x690b);
>> +    bcm_phy_write_misc(phydev, DSP_TAP10, 0x690b);
>>         /* Switch to CORE_BASE1E */
>>       phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0xd);
>> @@ -105,19 +81,19 @@ static int bcm7xxx_28nm_b0_afe_config_init(struct
>> phy_device *phydev)
>>       r_rc_cal_reset(phydev);
>>         /* write AFE_RXCONFIG_0 */
>> -    phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb19);
>> +    bcm_phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb19);
>>         /* write AFE_RXCONFIG_1 */
>> -    phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9a3f);
>> +    bcm_phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9a3f);
>>         /* write AFE_RX_LP_COUNTER */
>> -    phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc0);
>> +    bcm_phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc0);
>>         /* write AFE_HPF_TRIM_OTHERS */
>> -    phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x000b);
>> +    bcm_phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x000b);
>>         /* write AFTE_TX_CONFIG */
>> -    phy_write_misc(phydev, AFE_TX_CONFIG, 0x0800);
>> +    bcm_phy_write_misc(phydev, AFE_TX_CONFIG, 0x0800);
>>         return 0;
>>   }
>> @@ -125,36 +101,36 @@ static int
>> bcm7xxx_28nm_b0_afe_config_init(struct phy_device *phydev)
>>   static int bcm7xxx_28nm_d0_afe_config_init(struct phy_device *phydev)
>>   {
>>       /* AFE_RXCONFIG_0 */
>> -    phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb15);
>> +    bcm_phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb15);
>>         /* AFE_RXCONFIG_1 */
>> -    phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9b2f);
>> +    bcm_phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9b2f);
>>         /* AFE_RXCONFIG_2, set rCal offset for HT=0 code and LT=-2
>> code */
>> -    phy_write_misc(phydev, AFE_RXCONFIG_2, 0x2003);
>> +    bcm_phy_write_misc(phydev, AFE_RXCONFIG_2, 0x2003);
>>         /* AFE_RX_LP_COUNTER, set RX bandwidth to maximum */
>> -    phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc0);
>> +    bcm_phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc0);
>>         /* AFE_TX_CONFIG, set 100BT Cfeed=011 to improve rise/fall
>> time */
>> -    phy_write_misc(phydev, AFE_TX_CONFIG, 0x431);
>> +    bcm_phy_write_misc(phydev, AFE_TX_CONFIG, 0x431);
>>         /* AFE_VDCA_ICTRL_0, set Iq=1101 instead of 0111 for AB
>> symmetry */
>> -    phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
>> +    bcm_phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
>>         /* AFE_VDAC_OTHERS_0, set 1000BT Cidac=010 for all ports */
>> -    phy_write_misc(phydev, AFE_VDAC_OTHERS_0, 0xa020);
>> +    bcm_phy_write_misc(phydev, AFE_VDAC_OTHERS_0, 0xa020);
>>         /* AFE_HPF_TRIM_OTHERS, set 100Tx/10BT to -4.5% swing and set
>> rCal
>>        * offset for HT=0 code
>>        */
>> -    phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x00e3);
>> +    bcm_phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x00e3);
>>         /* CORE_BASE1E, force trim to overwrite and set I_ext trim to
>> 0000 */
>>       phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0x0010);
>>         /* DSP_TAP10, adjust bias current trim (+0% swing, +0 tick) */
>> -    phy_write_misc(phydev, DSP_TAP10, 0x011b);
>> +    bcm_phy_write_misc(phydev, DSP_TAP10, 0x011b);
>>         /* Reset R_CAL/RC_CAL engine */
>>       r_rc_cal_reset(phydev);
>> @@ -165,24 +141,24 @@ static int
>> bcm7xxx_28nm_d0_afe_config_init(struct phy_device *phydev)
>>   static int bcm7xxx_28nm_e0_plus_afe_config_init(struct phy_device
>> *phydev)
>>   {
>>       /* AFE_RXCONFIG_1, provide more margin for INL/DNL measurement */
>> -    phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9b2f);
>> +    bcm_phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9b2f);
>>         /* AFE_TX_CONFIG, set 100BT Cfeed=011 to improve rise/fall
>> time */
>> -    phy_write_misc(phydev, AFE_TX_CONFIG, 0x431);
>> +    bcm_phy_write_misc(phydev, AFE_TX_CONFIG, 0x431);
>>         /* AFE_VDCA_ICTRL_0, set Iq=1101 instead of 0111 for AB
>> symmetry */
>> -    phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
>> +    bcm_phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
>>         /* AFE_HPF_TRIM_OTHERS, set 100Tx/10BT to -4.5% swing and set
>> rCal
>>        * offset for HT=0 code
>>        */
>> -    phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x00e3);
>> +    bcm_phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x00e3);
>>         /* CORE_BASE1E, force trim to overwrite and set I_ext trim to
>> 0000 */
>>       phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0x0010);
>>         /* DSP_TAP10, adjust bias current trim (+0% swing, +0 tick) */
>> -    phy_write_misc(phydev, DSP_TAP10, 0x011b);
>> +    bcm_phy_write_misc(phydev, DSP_TAP10, 0x011b);
>>         /* Reset R_CAL/RC_CAL engine */
>>       r_rc_cal_reset(phydev);
>> @@ -190,53 +166,6 @@ static int
>> bcm7xxx_28nm_e0_plus_afe_config_init(struct phy_device *phydev)
>>       return 0;
>>   }
>>   -static int bcm7xxx_apd_enable(struct phy_device *phydev)
>> -{
>> -    int val;
>> -
>> -    /* Enable powering down of the DLL during auto-power down */
>> -    val = bcm54xx_shadow_read(phydev, BCM54XX_SHD_SCR3);
>> -    if (val < 0)
>> -        return val;
>> -
>> -    val |= BCM54XX_SHD_SCR3_DLLAPD_DIS;
>> -    bcm54xx_shadow_write(phydev, BCM54XX_SHD_SCR3, val);
>> -
>> -    /* Enable auto-power down */
>> -    val = bcm54xx_shadow_read(phydev, BCM54XX_SHD_APD);
>> -    if (val < 0)
>> -        return val;
>> -
>> -    val |= BCM54XX_SHD_APD_EN;
>> -    return bcm54xx_shadow_write(phydev, BCM54XX_SHD_APD, val);
>> -}
>> -
>> -static int bcm7xxx_eee_enable(struct phy_device *phydev)
>> -{
>> -    int val;
>> -
>> -    val = phy_read_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
>> -                    MDIO_MMD_AN, phydev->addr);
>> -    if (val < 0)
>> -        return val;
>> -
>> -    /* Enable general EEE feature at the PHY level */
>> -    val |= LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X;
>> -
>> -    phy_write_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
>> -                   MDIO_MMD_AN, phydev->addr, val);
>> -
>> -    /* Advertise supported modes */
>> -    val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
>> -                    MDIO_MMD_AN, phydev->addr);
>> -
>> -    val |= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
>> -    phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
>> -                   MDIO_MMD_AN, phydev->addr, val);
>> -
>> -    return 0;
>> -}
>> -
>>   static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
>>   {
>>       u8 rev = PHY_BRCM_7XXX_REV(phydev->dev_flags);
>> @@ -273,11 +202,11 @@ static int bcm7xxx_28nm_config_init(struct
>> phy_device *phydev)
>>       if (ret)
>>           return ret;
>>   -    ret = bcm7xxx_eee_enable(phydev);
>> +    ret = bcm_phy_enable_eee(phydev);
>>       if (ret)
>>           return ret;
>>   -    return bcm7xxx_apd_enable(phydev);
>> +    return bcm_phy_enable_apd(phydev, true);
>>   }
>>     static int bcm7xxx_28nm_resume(struct phy_device *phydev)
>> diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
>> index 9c71295..07a6119 100644
>> --- a/drivers/net/phy/broadcom.c
>> +++ b/drivers/net/phy/broadcom.c
>> @@ -14,6 +14,7 @@
>>    *    2 of the License, or (at your option) any later version.
>>    */
>>   +#include "bcm-phy-lib.h"
>>   #include <linux/module.h>
>>   #include <linux/phy.h>
>>   #include <linux/brcmphy.h>
>> @@ -29,39 +30,6 @@ MODULE_DESCRIPTION("Broadcom PHY driver");
>>   MODULE_AUTHOR("Maciej W. Rozycki");
>>   MODULE_LICENSE("GPL");
>>   -/* Indirect register access functions for the Expansion Registers */
>> -static int bcm54xx_exp_read(struct phy_device *phydev, u16 regnum)
>> -{
>> -    int val;
>> -
>> -    val = phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
>> -    if (val < 0)
>> -        return val;
>> -
>> -    val = phy_read(phydev, MII_BCM54XX_EXP_DATA);
>> -
>> -    /* Restore default value.  It's O.K. if this write fails. */
>> -    phy_write(phydev, MII_BCM54XX_EXP_SEL, 0);
>> -
>> -    return val;
>> -}
>> -
>> -static int bcm54xx_exp_write(struct phy_device *phydev, u16 regnum,
>> u16 val)
>> -{
>> -    int ret;
>> -
>> -    ret = phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
>> -    if (ret < 0)
>> -        return ret;
>> -
>> -    ret = phy_write(phydev, MII_BCM54XX_EXP_DATA, val);
>> -
>> -    /* Restore default value.  It's O.K. if this write fails. */
>> -    phy_write(phydev, MII_BCM54XX_EXP_SEL, 0);
>> -
>> -    return ret;
>> -}
>> -
>>   static int bcm54xx_auxctl_write(struct phy_device *phydev, u16
>> regnum, u16 val)
>>   {
>>       return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
>> @@ -72,28 +40,28 @@ static int bcm50610_a0_workaround(struct
>> phy_device *phydev)
>>   {
>>       int err;
>>   -    err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_AADJ1CH0,
>> +    err = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_AADJ1CH0,
>>                   MII_BCM54XX_EXP_AADJ1CH0_SWP_ABCD_OEN |
>>                   MII_BCM54XX_EXP_AADJ1CH0_SWSEL_THPF);
>>       if (err < 0)
>>           return err;
>>   -    err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_AADJ1CH3,
>> -                    MII_BCM54XX_EXP_AADJ1CH3_ADCCKADJ);
>> +    err = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_AADJ1CH3,
>> +                MII_BCM54XX_EXP_AADJ1CH3_ADCCKADJ);
>>       if (err < 0)
>>           return err;
>>   -    err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP75,
>> +    err = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_EXP75,
>>                   MII_BCM54XX_EXP_EXP75_VDACCTRL);
>>       if (err < 0)
>>           return err;
>>   -    err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP96,
>> +    err = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_EXP96,
>>                   MII_BCM54XX_EXP_EXP96_MYST);
>>       if (err < 0)
>>           return err;
>>   -    err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP97,
>> +    err = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_EXP97,
>>                   MII_BCM54XX_EXP_EXP97_MYST);
>>         return err;
>> @@ -114,7 +82,7 @@ static int bcm54xx_phydsp_config(struct phy_device
>> *phydev)
>>       if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610 ||
>>           BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610M) {
>>           /* Clear bit 9 to fix a phy interop issue. */
>> -        err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP08,
>> +        err = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_EXP08,
>>                       MII_BCM54XX_EXP_EXP08_RJCT_2MHZ);
>>           if (err < 0)
>>               goto error;
>> @@ -129,12 +97,12 @@ static int bcm54xx_phydsp_config(struct
>> phy_device *phydev)
>>       if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM57780) {
>>           int val;
>>   -        val = bcm54xx_exp_read(phydev, MII_BCM54XX_EXP_EXP75);
>> +        val = bcm_phy_read_exp(phydev, MII_BCM54XX_EXP_EXP75);
>>           if (val < 0)
>>               goto error;
>>             val |= MII_BCM54XX_EXP_EXP75_CM_OSC;
>> -        err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP75, val);
>> +        err = bcm_phy_write_exp(phydev, MII_BCM54XX_EXP_EXP75, val);
>>       }
>>     error:
>> @@ -159,7 +127,7 @@ static void bcm54xx_adjust_rxrefclk(struct
>> phy_device *phydev)
>>           BRCM_PHY_MODEL(phydev) != PHY_ID_BCM50610M)
>>           return;
>>   -    val = bcm54xx_shadow_read(phydev, BCM54XX_SHD_SCR3);
>> +    val = bcm_phy_read_shadow(phydev, BCM54XX_SHD_SCR3);
>>       if (val < 0)
>>           return;
>>   @@ -190,9 +158,9 @@ static void bcm54xx_adjust_rxrefclk(struct
>> phy_device *phydev)
>>           val |= BCM54XX_SHD_SCR3_TRDDAPD;
>>         if (orig != val)
>> -        bcm54xx_shadow_write(phydev, BCM54XX_SHD_SCR3, val);
>> +        bcm_phy_write_shadow(phydev, BCM54XX_SHD_SCR3, val);
>>   -    val = bcm54xx_shadow_read(phydev, BCM54XX_SHD_APD);
>> +    val = bcm_phy_read_shadow(phydev, BCM54XX_SHD_APD);
>>       if (val < 0)
>>           return;
>>   @@ -204,7 +172,7 @@ static void bcm54xx_adjust_rxrefclk(struct
>> phy_device *phydev)
>>           val &= ~BCM54XX_SHD_APD_EN;
>>         if (orig != val)
>> -        bcm54xx_shadow_write(phydev, BCM54XX_SHD_APD, val);
>> +        bcm_phy_write_shadow(phydev, BCM54XX_SHD_APD, val);
>>   }
>>     static int bcm54xx_config_init(struct phy_device *phydev)
>> @@ -232,7 +200,7 @@ static int bcm54xx_config_init(struct phy_device
>> *phydev)
>>       if ((BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610 ||
>>            BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610M) &&
>>           (phydev->dev_flags & PHY_BRCM_CLEAR_RGMII_MODE))
>> -        bcm54xx_shadow_write(phydev, BCM54XX_SHD_RGMII_MODE, 0);
>> +        bcm_phy_write_shadow(phydev, BCM54XX_SHD_RGMII_MODE, 0);
>>         if ((phydev->dev_flags & PHY_BRCM_RX_REFCLK_UNUSED) ||
>>           (phydev->dev_flags & PHY_BRCM_DIS_TXCRXC_NOENRGY) ||
>> @@ -254,8 +222,8 @@ static int bcm5482_config_init(struct phy_device
>> *phydev)
>>           /*
>>            * Enable secondary SerDes and its use as an LED source
>>            */
>> -        reg = bcm54xx_shadow_read(phydev, BCM5482_SHD_SSD);
>> -        bcm54xx_shadow_write(phydev, BCM5482_SHD_SSD,
>> +        reg = bcm_phy_read_shadow(phydev, BCM5482_SHD_SSD);
>> +        bcm_phy_write_shadow(phydev, BCM5482_SHD_SSD,
>>                        reg |
>>                        BCM5482_SHD_SSD_LEDM |
>>                        BCM5482_SHD_SSD_EN);
>> @@ -264,10 +232,10 @@ static int bcm5482_config_init(struct phy_device
>> *phydev)
>>            * Enable SGMII slave mode and auto-detection
>>            */
>>           reg = BCM5482_SSD_SGMII_SLAVE | MII_BCM54XX_EXP_SEL_SSD;
>> -        err = bcm54xx_exp_read(phydev, reg);
>> +        err = bcm_phy_read_exp(phydev, reg);
>>           if (err < 0)
>>               return err;
>> -        err = bcm54xx_exp_write(phydev, reg, err |
>> +        err = bcm_phy_write_exp(phydev, reg, err |
>>                       BCM5482_SSD_SGMII_SLAVE_EN |
>>                       BCM5482_SSD_SGMII_SLAVE_AD);
>>           if (err < 0)
>> @@ -277,10 +245,10 @@ static int bcm5482_config_init(struct phy_device
>> *phydev)
>>            * Disable secondary SerDes powerdown
>>            */
>>           reg = BCM5482_SSD_1000BX_CTL | MII_BCM54XX_EXP_SEL_SSD;
>> -        err = bcm54xx_exp_read(phydev, reg);
>> +        err = bcm_phy_read_exp(phydev, reg);
>>           if (err < 0)
>>               return err;
>> -        err = bcm54xx_exp_write(phydev, reg,
>> +        err = bcm_phy_write_exp(phydev, reg,
>>                       err & ~BCM5482_SSD_1000BX_CTL_PWRDOWN);
>>           if (err < 0)
>>               return err;
>> @@ -288,15 +256,15 @@ static int bcm5482_config_init(struct phy_device
>> *phydev)
>>           /*
>>            * Select 1000BASE-X register set (primary SerDes)
>>            */
>> -        reg = bcm54xx_shadow_read(phydev, BCM5482_SHD_MODE);
>> -        bcm54xx_shadow_write(phydev, BCM5482_SHD_MODE,
>> +        reg = bcm_phy_read_shadow(phydev, BCM5482_SHD_MODE);
>> +        bcm_phy_write_shadow(phydev, BCM5482_SHD_MODE,
>>                        reg | BCM5482_SHD_MODE_1000BX);
>>             /*
>>            * LED1=ACTIVITYLED, LED3=LINKSPD[2]
>>            * (Use LED1 as secondary SerDes ACTIVITY LED)
>>            */
>> -        bcm54xx_shadow_write(phydev, BCM5482_SHD_LEDS1,
>> +        bcm_phy_write_shadow(phydev, BCM5482_SHD_LEDS1,
>>               BCM5482_SHD_LEDS1_LED1(BCM_LED_SRC_ACTIVITYLED) |
>>               BCM5482_SHD_LEDS1_LED3(BCM_LED_SRC_LINKSPD2));
>>   @@ -334,35 +302,6 @@ static int bcm5482_read_status(struct
>> phy_device *phydev)
>>       return err;
>>   }
>>   -static int bcm54xx_ack_interrupt(struct phy_device *phydev)
>> -{
>> -    int reg;
>> -
>> -    /* Clear pending interrupts.  */
>> -    reg = phy_read(phydev, MII_BCM54XX_ISR);
>> -    if (reg < 0)
>> -        return reg;
>> -
>> -    return 0;
>> -}
>> -
>> -static int bcm54xx_config_intr(struct phy_device *phydev)
>> -{
>> -    int reg, err;
>> -
>> -    reg = phy_read(phydev, MII_BCM54XX_ECR);
>> -    if (reg < 0)
>> -        return reg;
>> -
>> -    if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
>> -        reg &= ~MII_BCM54XX_ECR_IM;
>> -    else
>> -        reg |= MII_BCM54XX_ECR_IM;
>> -
>> -    err = phy_write(phydev, MII_BCM54XX_ECR, reg);
>> -    return err;
>> -}
>> -
>>   static int bcm5481_config_aneg(struct phy_device *phydev)
>>   {
>>       int ret;
>> @@ -519,8 +458,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM5421,
>> @@ -532,8 +471,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM5461,
>> @@ -545,8 +484,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM54616S,
>> @@ -558,8 +497,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM5464,
>> @@ -571,8 +510,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM5481,
>> @@ -584,8 +523,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = bcm5481_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM5482,
>> @@ -597,8 +536,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm5482_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = bcm5482_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM50610,
>> @@ -610,8 +549,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM50610M,
>> @@ -623,8 +562,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCM57780,
>> @@ -636,8 +575,8 @@ static struct phy_driver broadcom_drivers[] = {
>>       .config_init    = bcm54xx_config_init,
>>       .config_aneg    = genphy_config_aneg,
>>       .read_status    = genphy_read_status,
>> -    .ack_interrupt    = bcm54xx_ack_interrupt,
>> -    .config_intr    = bcm54xx_config_intr,
>> +    .ack_interrupt    = bcm_phy_ack_intr,
>> +    .config_intr    = bcm_phy_config_intr,
>>       .driver        = { .owner = THIS_MODULE },
>>   }, {
>>       .phy_id        = PHY_ID_BCMAC131,
>> diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
>> index 697ca77..6a53ab9 100644
>> --- a/include/linux/brcmphy.h
>> +++ b/include/linux/brcmphy.h
>> @@ -138,7 +138,10 @@
>>     /* 01010: Auto Power-Down */
>>   #define BCM54XX_SHD_APD            0x0a
>> +#define  BCM_APD_CLR_MASK        0xFE9F /* clear bits 5, 6 & 8 */
>>   #define  BCM54XX_SHD_APD_EN        0x0020
>> +#define  BCM_NO_ANEG_APD_EN        0x0060 /* bits 5 & 6 */
>> +#define  BCM_APD_SINGLELP_EN    0x0100 /* Bit 8 */
>>     #define BCM5482_SHD_LEDS1    0x0d    /* 01101: LED Selector 1 */
>>                       /* LED3 / ~LINKSPD[2] selector */
>> @@ -209,25 +212,6 @@
>>   #define MII_BRCM_FET_SHDW_AUXSTAT2    0x1b    /* Auxiliary status 2 */
>>   #define MII_BRCM_FET_SHDW_AS2_APDE    0x0020    /* Auto power down
>> enable */
>>   -/*
>> - * Indirect register access functions for the
>> 1000BASE-T/100BASE-TX/10BASE-T
>> - * 0x1c shadow registers.
>> - */
>> -static inline int bcm54xx_shadow_read(struct phy_device *phydev, u16
>> shadow)
>> -{
>> -    phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_VAL(shadow));
>> -    return MII_BCM54XX_SHD_DATA(phy_read(phydev, MII_BCM54XX_SHD));
>> -}
>> -
>> -static inline int bcm54xx_shadow_write(struct phy_device *phydev, u16
>> shadow,
>> -                       u16 val)
>> -{
>> -    return phy_write(phydev, MII_BCM54XX_SHD,
>> -             MII_BCM54XX_SHD_WRITE |
>> -             MII_BCM54XX_SHD_VAL(shadow) |
>> -             MII_BCM54XX_SHD_DATA(val));
>> -}
>> -
>>   #define BRCM_CL45VEN_EEE_CONTROL    0x803d
>>   #define LPI_FEATURE_EN            0x8000
>>   #define LPI_FEATURE_EN_DIG1000X        0x4000
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
