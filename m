From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: [REGRESSION, BISECTED] Broken networking with net/phy/marvell
Date: Thu, 26 Oct 2017 15:28:36 +0300
Message-ID: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh07.mail.saunalahti.fi ([62.142.5.117]:41911 "EHLO
        emh07.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932185AbdJZMeo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 08:34:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When upgrading from v4.13 to v4.14-rc6 on OpenRD Client, the box loses
network connectivity.

Bisection points to:

commit 5987feb38aa55e035ce5376c02aba88a604cc881
Author: Dan Carpenter <dan.carpenter@oracle.com>
Date:   Fri Aug 4 11:17:21 2017 +0300

    net: phy: marvell: logical vs bitwise OR typo
    
However, it seems this commit just unhides another issue in the original
commit 864dc729d528 ("net: phy: marvell: Refactor m88e1121 RGMII delay
configuration"): when we are configuring the MSCR delay bits, we are
probably clearing the bits with a wrong mask (i.e. we might be disabling
something else not intended)...

I have tested the below change and it seems to fix the networking. Any
comments?

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 15cbcdb..500d7c1 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -474,7 +474,7 @@ static int m88e1121_config_aneg_rgmii_delays(struct phy_device *phydev)
 		goto out;
 	}
 
-	mscr &= MII_88E1121_PHY_MSCR_DELAY_MASK;
+	mscr &= ~MII_88E1121_PHY_MSCR_DELAY_MASK;
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
 		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |

A.
