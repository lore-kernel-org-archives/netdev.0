From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: Need help with mdiobus_register and phy
Date: Mon, 17 Oct 2016 11:05:47 +0200
Message-ID: <7dced72e-c441-06d1-161d-3bccad34f2cd@neratec.com>
References: <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org> <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
 <58023F90.5070302@codeaurora.org> <20161015180219.GB6918@lunn.ch>
 <58027540.6080604@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:10139 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933584AbcJQJOA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 05:14:00 -0400
In-Reply-To: <58027540.6080604@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2016 08:28 PM, Timur Tabi wrote:
> Andrew Lunn wrote:
>> 1) Take the SerDes power down out of the suspend code for the at803x.
>>
>> 2) Assume MII_PHYID1/2 registers are not guaranteed to be available
>> when the PHY is powered down. So get_phy_id should first read
>> MII_BMCR. If it gets 0xffff, assume there is no PHY there. If the
>> PDOWN bit is set, power up the PHY. Then reading the ID registers.
> 
> Before we take approach #1, I'd like to hear from the developer of that patch,
> Zefir.  According to him, that patch is necessary to fix a bug. I don't know if
> that bug exists only on his system, though.
> 

Hi,

the problem we observed was that in SGMII mode after a suspend/resume cycle the
PHY link states get out of sync (e.g. gianfar reports link up, at803x down) and
power cycling the SerDes was a reliable way to get them re-synchronized again.

This obviously worked for some time after March 2016 and must have stopped only
recently (maybe additional PHY suspends were added).

Anyway, since the SGMII reset is required, instead of reverting the patch in full
I suggest to move the SGMII power down from at803x_suspend() and do a SerDes power
cycle in at803x_resume(). Could you please test if the patch below fixes the problem?


Thanks,
Zefir
---



Subject: [PATCH] at803x: don't power down SerDes on suspend

Powering down SerDes renders registers inaccessible
and with that re-initializing a suspended PHY fails.

Instead of powering down SerDes at suspend(), leave
it as is and power-cycle it on resume().

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/phy/at803x.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f279a89..282ffbb 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -225,16 +225,6 @@ static int at803x_suspend(struct phy_device *phydev)

 	phy_write(phydev, MII_BMCR, value);

-	if (phydev->interface != PHY_INTERFACE_MODE_SGMII)
-		goto done;
-
-	/* also power-down SGMII interface */
-	ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
-	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
-	phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_PDOWN);
-	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
-
-done:
 	mutex_unlock(&phydev->lock);

 	return 0;
@@ -254,9 +244,11 @@ static int at803x_resume(struct phy_device *phydev)
 	if (phydev->interface != PHY_INTERFACE_MODE_SGMII)
 		goto done;

-	/* also power-up SGMII interface */
+	/* reset SGMII interface for re-synchronization */
 	ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
 	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
+	phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_PDOWN);
+
 	value = phy_read(phydev, MII_BMCR) & ~(BMCR_PDOWN | BMCR_ISOLATE);
 	phy_write(phydev, MII_BMCR, value);
 	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
-- 
2.7.4
