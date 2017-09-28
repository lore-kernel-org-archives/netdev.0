From: Bernd Edlinger <bernd.edlinger@hotmail.de>
Subject: Re: [PATCH] Add a driver for Renesas uPD60620 and uPD60620A PHYs
Date: Thu, 28 Sep 2017 18:12:17 +0000
Message-ID: <ca1763c4-fb7b-cf49-6bcf-d9e2c29c7363@hotmail.de>
References: <AM5PR0701MB26574EBBE4E7CACC9173B345E4670@AM5PR0701MB2657.eurprd07.prod.outlook.com>
 <20170922175918.GD3470@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oln040092066091.outbound.protection.outlook.com ([40.92.66.91]:37952
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750819AbdI1SMT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 14:12:19 -0400
In-Reply-To: <20170922175918.GD3470@lunn.ch>
Content-Language: de-DE
Content-ID: <253AC3540F68A94E9F7BA2F7EEB81B57@sct-15-1-1199-6-msonline-outlook-20107.templateTenant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/17 19:59, Andrew Lunn wrote:
> On Fri, Sep 22, 2017 at 05:08:45PM +0000, Bernd Edlinger wrote:
>>
>> +config RENESAS_PHY
>> +	tristate "Driver for Renesas PHYs"
>> +	---help---
>> +	  Supports the uPD60620 and uPD60620A PHYs.
>> +
> 
> Hi Bernd
> 
> Please call this "Reneseas PHYs" and place in it alphabetical order.
> 

Done.

>> +
>> +/* Extended Registers and values */
>> +/* PHY Special Control/Status    */
>> +#define PHY_PHYSCR         0x1F      /* PHY.31 */
>> +#define PHY_PHYSCR_10MB    0x0004    /* PHY speed = 10mb */
>> +#define PHY_PHYSCR_100MB   0x0008    /* PHY speed = 100mb */
>> +#define PHY_PHYSCR_DUPLEX  0x0010    /* PHY Duplex */
>> +#define PHY_PHYSCR_RSVD5   0x0020    /* Reserved Bit 5 */
>> +#define PHY_PHYSCR_MIIMOD  0x0040    /* Enable 4B5B MII mode */
> 
> Are any of these comments actually useful. It seems like the defines
> are pretty obvious.
> 
>> +#define PHY_PHYSCR_RSVD7   0x0080    /* Reserved Bit 7 */
>> +#define PHY_PHYSCR_RSVD8   0x0100    /* Reserved Bit 8 */
>> +#define PHY_PHYSCR_RSVD9   0x0200    /* Reserved Bit 9 */
>> +#define PHY_PHYSCR_RSVD10  0x0400    /* Reserved Bit 10 */
>> +#define PHY_PHYSCR_RSVD11  0x0800    /* Reserved Bit 11 */
>> +#define PHY_PHYSCR_ANDONE  0x1000    /* Auto negotiation done */
>> +#define PHY_PHYSCR_RSVD13  0x2000    /* Reserved Bit 13 */
>> +#define PHY_PHYSCR_RSVD14  0x4000    /* Reserved Bit 14 */
>> +#define PHY_PHYSCR_RSVD15  0x8000    /* Reserved Bit 15 */
> 
> It looks like the only register you use is SCR and SPM. Maybe delete
> all the rest? Or do you plan to add more features making use of these
> registers?
> 

No, I removed all unused defines for now.

>> +	phydev->link = 0;
>> +	phydev->lp_advertising = 0;
>> +	phydev->pause = 0;
>> +	phydev->asym_pause = 0;
>> +
>> +	if (phy_state & BMSR_ANEGCOMPLETE) {
> 
> It is worth comparing this against genphy_read_status() which is the
> reference implementation. You would normally check if auto negotiation
> is enabled, not if it has completed. If it is enabled you read the
> current negotiated state, even if it is not completed.
> 

Do you suggest that there are cases where auto negotiation does not
reach completion, and still provides a usable link status?

I have tried to connect to link partners with fixed configuration
but even then the auto negotiation always competes normally.
 

>> +		phy_state = phy_read(phydev, PHY_PHYSCR);
>> +		if (phy_state < 0)
>> +			return phy_state;
>> +
>> +		if (phy_state & (PHY_PHYSCR_10MB | PHY_PHYSCR_100MB)) {
>> +			phydev->link = 1;
>> +			phydev->speed = SPEED_10;
>> +			phydev->duplex = DUPLEX_HALF;
>> +
>> +			if (phy_state & PHY_PHYSCR_100MB)
>> +				phydev->speed = SPEED_100;
>> +			if (phy_state & PHY_PHYSCR_DUPLEX)
>> +				phydev->duplex = DUPLEX_FULL;
>> +
>> +			phy_state = phy_read(phydev, MII_LPA);
>> +			if (phy_state < 0)
>> +				return phy_state;
>> +
>> +			phydev->lp_advertising
>> +				= mii_lpa_to_ethtool_lpa_t(phy_state);
>> +
>> +			if (phydev->duplex == DUPLEX_FULL) {
>> +				if (phy_state & LPA_PAUSE_CAP)
>> +					phydev->pause = 1;
>> +				if (phy_state & LPA_PAUSE_ASYM)
>> +					phydev->asym_pause = 1;
>> +			}
>> +		}
>> +	} else if (phy_state & BMSR_LSTATUS) {
> 
> The else clause is then for a fixed configuration. Since all you are
> looking at is BMCR, you can probably just cut/paste from
> genphy_read_status().
> 

I think I can fold the fixed speed case in the auto negotiation case:
The PHYSCR has always the correct values for fixed settings.
I was initially unsure if I should look at it while autonegotiation is
not complete, but as you pointed out, that is the generally accepted
practice.


Thanks
Bernd.


>From 2e101aed8466b314251972d1eaccfb43cf177078 Mon Sep 17 00:00:00 2001
From: Bernd Edlinger <bernd.edlinger@hotmail.de>
Date: Thu, 21 Sep 2017 15:46:16 +0200
Subject: [PATCH 2/5] Add a driver for Renesas uPD60620 and uPD60620A PHYs.

Signed-off-by: Bernd Edlinger <bernd.edlinger@hotmail.de>
---
 drivers/net/phy/Kconfig    |   5 +++
 drivers/net/phy/Makefile   |   1 +
 drivers/net/phy/uPD60620.c | 109 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+)
 create mode 100644 drivers/net/phy/uPD60620.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index a9d16a3..f67943b 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -366,6 +366,11 @@ config REALTEK_PHY
 	---help---
 	  Supports the Realtek 821x PHY.
 
+config RENESAS_PHY
+	tristate "Driver for Renesas PHYs"
+	---help---
+	  Supports the Renesas PHYs uPD60620 and uPD60620A.
+
 config ROCKCHIP_PHY
         tristate "Driver for Rockchip Ethernet PHYs"
         ---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 416df92..1404ad3 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -72,6 +72,7 @@ obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
+obj-$(CONFIG_RENESAS_PHY)	+= uPD60620.o
 obj-$(CONFIG_ROCKCHIP_PHY)	+= rockchip.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
diff --git a/drivers/net/phy/uPD60620.c b/drivers/net/phy/uPD60620.c
new file mode 100644
index 0000000..96b3347
--- /dev/null
+++ b/drivers/net/phy/uPD60620.c
@@ -0,0 +1,109 @@
+/*
+ * Driver for the Renesas PHY uPD60620.
+ *
+ * Copyright (C) 2015 Softing Industrial Automation GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+
+#define UPD60620_PHY_ID    0xb8242824
+
+/* Extended Registers and values */
+/* PHY Special Control/Status    */
+#define PHY_PHYSCR         0x1F      /* PHY.31 */
+#define PHY_PHYSCR_10MB    0x0004    /* PHY speed = 10mb */
+#define PHY_PHYSCR_100MB   0x0008    /* PHY speed = 100mb */
+#define PHY_PHYSCR_DUPLEX  0x0010    /* PHY Duplex */
+
+/* PHY Special Modes */
+#define PHY_SPM            0x12      /* PHY.18 */
+
+/* Init PHY */
+
+static int upd60620_config_init(struct phy_device *phydev)
+{
+	/* Enable support for passive HUBs (could be a strap option) */
+	/* PHYMODE: All speeds, HD in parallel detect */
+	return phy_write(phydev, PHY_SPM, 0x0180 | phydev->mdio.addr);
+}
+
+/* Get PHY status from common registers */
+
+static int upd60620_read_status(struct phy_device *phydev)
+{
+	int phy_state;
+
+	/* Read negotiated state */
+	phy_state = phy_read(phydev, MII_BMSR);
+	if (phy_state < 0)
+		return phy_state;
+
+	phydev->link = 0;
+	phydev->lp_advertising = 0;
+	phydev->pause = 0;
+	phydev->asym_pause = 0;
+
+	if (phy_state & (BMSR_ANEGCOMPLETE | BMSR_LSTATUS)) {
+		phy_state = phy_read(phydev, PHY_PHYSCR);
+		if (phy_state < 0)
+			return phy_state;
+
+		if (phy_state & (PHY_PHYSCR_10MB | PHY_PHYSCR_100MB)) {
+			phydev->link = 1;
+			phydev->speed = SPEED_10;
+			phydev->duplex = DUPLEX_HALF;
+
+			if (phy_state & PHY_PHYSCR_100MB)
+				phydev->speed = SPEED_100;
+			if (phy_state & PHY_PHYSCR_DUPLEX)
+				phydev->duplex = DUPLEX_FULL;
+
+			phy_state = phy_read(phydev, MII_LPA);
+			if (phy_state < 0)
+				return phy_state;
+
+			phydev->lp_advertising
+				= mii_lpa_to_ethtool_lpa_t(phy_state);
+
+			if (phydev->duplex == DUPLEX_FULL) {
+				if (phy_state & LPA_PAUSE_CAP)
+					phydev->pause = 1;
+				if (phy_state & LPA_PAUSE_ASYM)
+					phydev->asym_pause = 1;
+			}
+		}
+	}
+	return 0;
+}
+
+MODULE_DESCRIPTION("Renesas uPD60620 PHY driver");
+MODULE_AUTHOR("Bernd Edlinger <bernd.edlinger@hotmail.de>");
+MODULE_LICENSE("GPL");
+
+static struct phy_driver upd60620_driver[1] = { {
+	.phy_id         = UPD60620_PHY_ID,
+	.phy_id_mask    = 0xfffffffe,
+	.name           = "Renesas uPD60620",
+	.features       = PHY_BASIC_FEATURES,
+	.flags          = 0,
+	.config_init    = upd60620_config_init,
+	.config_aneg    = genphy_config_aneg,
+	.read_status    = upd60620_read_status,
+} };
+
+module_phy_driver(upd60620_driver);
+
+static struct mdio_device_id __maybe_unused upd60620_tbl[] = {
+	{ UPD60620_PHY_ID, 0xfffffffe },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, upd60620_tbl);
-- 
2.7.4
