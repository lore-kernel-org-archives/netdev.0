From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/2] stmmac: mdio register has to fail if the phy is not found
Date: Thu,  7 Feb 2013 07:47:52 +0100
Message-ID: <1360219672-27980-2-git-send-email-peppe.cavallaro@st.com>
References: <1360219672-27980-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:56321 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750930Ab3BGGsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 01:48:15 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 39656F7
	for <netdev@vger.kernel.org>; Thu,  7 Feb 2013 06:48:05 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D3EEF24B6
	for <netdev@vger.kernel.org>; Thu,  7 Feb 2013 06:48:05 +0000 (GMT)
In-Reply-To: <1360219672-27980-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch the stmmac fails in case of the phy device
is not found; w/o this fix the mdio can be register twice when
do down/up the iface and this is not correct.

Reported-by: Stas <stsp@list.ru>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 0376a5e..0b9829f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -188,8 +188,6 @@ int stmmac_mdio_register(struct net_device *ndev)
 		goto bus_register_fail;
 	}
 
-	priv->mii = new_bus;
-
 	found = 0;
 	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
 		struct phy_device *phydev = new_bus->phy_map[addr];
@@ -237,8 +235,14 @@ int stmmac_mdio_register(struct net_device *ndev)
 		}
 	}
 
-	if (!found)
+	if (!found) {
 		pr_warning("%s: No PHY found\n", ndev->name);
+		mdiobus_unregister(new_bus);
+		mdiobus_free(new_bus);
+		return -ENODEV;
+	}
+
+	priv->mii = new_bus;
 
 	return 0;
 
-- 
1.7.4.4
