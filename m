From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [Stlinux-devel] [PATCH linux-stm 3/4] net/stmmac: Remove bus_id from mdio platform data.
Date: Thu, 30 Aug 2012 16:50:43 +0100
Message-ID: <1346341843-20169-1-git-send-email-srinivas.kandagatla@st.com>
Cc: peppe.cavallaro@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:58116 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751791Ab2H3Pve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 11:51:34 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7D84BF0
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 15:51:32 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5198A4E48
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 15:51:32 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch removes bus_id from mdio platform data, The reason to remove
bus_id is, stmmac mdio bus_id is always same as stmmac bus-id, so there
is no point in passing this in different variable.
Also stmmac ethernet driver connects to phy with bus_id passed its
platform data.
So, having single bus-id is much simpler.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 Documentation/networking/stmmac.txt               |    5 -----
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    8 +++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c  |    1 -
 include/linux/stmmac.h                            |    1 -
 4 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index c676b9c..ef9ee71 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -173,7 +173,6 @@ Where:
 For MDIO bus The we have:
 
  struct stmmac_mdio_bus_data {
-	int bus_id;
 	int (*phy_reset)(void *priv);
 	unsigned int phy_mask;
 	int *irqs;
@@ -181,7 +180,6 @@ For MDIO bus The we have:
  };
 
 Where:
- o bus_id: bus identifier;
  o phy_reset: hook to reset the phy device attached to the bus.
  o phy_mask: phy mask passed when register the MDIO bus within the driver.
  o irqs: list of IRQs, one per PHY.
@@ -230,9 +228,6 @@ there are two MAC cores: one MAC is for MDIO Bus/PHY emulation
 with fixed_link support.
 
 static struct stmmac_mdio_bus_data stmmac1_mdio_bus = {
-	.bus_id = 1,
-		|
-		|-> phy device on the bus_id 1
 	.phy_reset = phy_reset;
 		|
 		|-> function to provide the phy_reset on this board
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index e1f3d04..0376a5e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -177,7 +177,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	new_bus->write = &stmmac_mdio_write;
 	new_bus->reset = &stmmac_mdio_reset;
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		new_bus->name, mdio_bus_data->bus_id);
+		new_bus->name, priv->plat->bus_id);
 	new_bus->priv = ndev;
 	new_bus->irq = irqlist;
 	new_bus->phy_mask = mdio_bus_data->phy_mask;
@@ -213,12 +213,10 @@ int stmmac_mdio_register(struct net_device *ndev)
 			 * and no PHY number was provided to the MAC,
 			 * use the one probed here.
 			 */
-			if ((priv->plat->bus_id == mdio_bus_data->bus_id) &&
-			    (priv->plat->phy_addr == -1))
+			if (priv->plat->phy_addr == -1)
 				priv->plat->phy_addr = addr;
 
-			act = (priv->plat->bus_id == mdio_bus_data->bus_id) &&
-				(priv->plat->phy_addr == addr);
+			act = (priv->plat->phy_addr == addr);
 			switch (phydev->irq) {
 			case PHY_POLL:
 				irq_str = "POLL";
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 13afb8e..1f069b0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -40,7 +40,6 @@ static void stmmac_default_data(void)
 	plat_dat.has_gmac = 1;
 	plat_dat.force_sf_dma_mode = 1;
 
-	mdio_data.bus_id = 1;
 	mdio_data.phy_reset = NULL;
 	mdio_data.phy_mask = 0;
 	plat_dat.mdio_bus_data = &mdio_data;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index b69bdb1..a1547ea 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -76,7 +76,6 @@
 /* Platfrom data for platform device structure's platform_data field */
 
 struct stmmac_mdio_bus_data {
-	int bus_id;
 	int (*phy_reset)(void *priv);
 	unsigned int phy_mask;
 	int *irqs;
-- 
1.7.0.4
