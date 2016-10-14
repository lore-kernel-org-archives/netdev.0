From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 11:57:29 -0500
Message-ID: <58010E79.2030607@codeaurora.org>
References: <5800159B.3080708@codeaurora.org> <20161014040641.GE5822@lunn.ch>
 <5800C3C7.60705@codeaurora.org> <20161014120624.GG5822@lunn.ch>
 <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44707 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932418AbcJNQ5b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 12:57:31 -0400
In-Reply-To: <20161014131852.GM5822@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn wrote:
> That is a basic assumption of the code. If you cannot read the IDs how
> are you supposed to know what device it is, and what quirks you need
> to work around its broken features...
>
> Does the datasheet say anything about this?
>
> I would say for this device, suspend() is too aggressive.

This change in my driver makes the problem go away (I'm not sure if it's 
a "fix"):

@@ -992,7 +992,7 @@ int emac_mac_up(struct emac_adapter *adpt)
         emac_mac_rx_descs_refill(adpt, &adpt->rx_q);

         ret = phy_connect_direct(netdev, adpt->phydev, emac_adjust_link,
-                                PHY_INTERFACE_MODE_SGMII);
+                                PHY_INTERFACE_MODE_NA);

With the interface not set as SGMII, the following code in 
at803x_suspend() is not executed:

/* also power-down SGMII interface */
ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_PDOWN);
phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);

I don't see any other driver issue BMCR_PDOWN in their functions.  I 
added some printks for the PHYSID1 and PHYSID2 registers before and 
after BMCR_PDOWN:

at803x_suspend:235 MII_PHYSID1=004d MII_PHYSID2=d074
at803x_suspend:242 MII_PHYSID1=ffff MII_PHYSID2=ffff

So after calling BMCR_PDOWN, the PHYSID1 and PHYSID2 registers are no 
longer readable.  Is that expected?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
