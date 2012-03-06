From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: Allow stmmac to work with other PHY buses(v2).
Date: Tue,  6 Mar 2012 06:42:00 +0100
Message-ID: <1331012520-19574-1-git-send-email-peppe.cavallaro@st.com>
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:38259 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751151Ab2CFFmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 00:42:12 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BB5BF1A1
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 05:42:10 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 528A814FF
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 05:42:10 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

After commit "db8857b stmmac: use an unique MDIO bus name" and "90b9a54
stmmac: fix phy naming inconsistency" stmmac cant work with other MDIO
buses, because mdio_bus name is fixed in the dirver.

This patch adds new variable phy_bus_name to plat_stmmacenet_data
struct to let the BSP decide which phy bus to be used by stmmac driver.
A typical use-case is to have generic MDIO buses like mdio-gpio on top
of stmmac.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    8 +++++++-
 include/linux/stmmac.h                            |    1 +
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6ee593a..da891ef9b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -307,7 +307,13 @@ static int stmmac_init_phy(struct net_device *dev)
 	priv->speed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x", priv->plat->bus_id);
+	if (priv->plat->phy_bus_name)
+		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
+				priv->plat->phy_bus_name, priv->plat->bus_id);
+	else
+		snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
+				priv->plat->bus_id);
+
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 0dddc9e..172b5e1 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -39,6 +39,7 @@ struct stmmac_mdio_bus_data {
 };
 
 struct plat_stmmacenet_data {
+	char *phy_bus_name;
 	int bus_id;
 	int phy_addr;
 	int interface;
-- 
1.7.4.4
