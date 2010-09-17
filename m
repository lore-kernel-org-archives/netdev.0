From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/4] stmmac: add CSR Clock range selection
Date: Fri, 17 Sep 2010 15:23:39 +0200
Message-ID: <1284729822-29176-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Johannes Stezenbach <js@sig21.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:57753 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350Ab0IQNYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 09:24:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the CSR Clock range selection.

Original patch from Johannes Stezenbach fixed the CSR
in the stmmac_mdio. We agreed to provide this through
the platform instead of.
Also thanks to Johannes for having tested it on ARM.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Johannes Stezenbach <js@sig21.net>
---
 drivers/net/stmmac/stmmac.h      |    1 +
 drivers/net/stmmac/stmmac_main.c |    1 +
 drivers/net/stmmac/stmmac_mdio.c |    5 +++--
 include/linux/stmmac.h           |    1 +
 4 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index d0ddab0..12d1cb0 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -78,6 +78,7 @@ struct stmmac_priv {
 	unsigned int flow_ctrl;
 	unsigned int pause;
 	struct mii_bus *mii;
+	int mii_clk_csr;
 
 	u32 msg_enable;
 	spinlock_t lock;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 03c160c..a169b14 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1704,6 +1704,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	plat_dat = pdev->dev.platform_data;
 	priv->bus_id = plat_dat->bus_id;
 	priv->pbl = plat_dat->pbl;	/* TLI */
+	priv->mii_clk_csr = plat_dat->clk_csr;
 	priv->is_gmac = plat_dat->has_gmac;	/* GMAC is on board */
 	priv->enh_desc = plat_dat->enh_desc;
 	priv->ioaddr = addr;
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index 03dea14..d744161 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -53,7 +53,7 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	int data;
 	u16 regValue = (((phyaddr << 11) & (0x0000F800)) |
 			((phyreg << 6) & (0x000007C0)));
-	regValue |= MII_BUSY;	/* in case of GMAC */
+	regValue |= MII_BUSY | ((priv->mii_clk_csr & 7) << 2);
 
 	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
 	writel(regValue, priv->ioaddr + mii_address);
@@ -85,7 +85,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	    (((phyaddr << 11) & (0x0000F800)) | ((phyreg << 6) & (0x000007C0)))
 	    | MII_WRITE;
 
-	value |= MII_BUSY;
+	value |= MII_BUSY | ((priv->mii_clk_csr & 7) << 2);
+
 
 	/* Wait until any existing MII operation is complete */
 	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index a4adf0d..c87c88c 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -32,6 +32,7 @@
 struct plat_stmmacenet_data {
 	int bus_id;
 	int pbl;
+	int clk_csr;
 	int has_gmac;
 	int enh_desc;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
-- 
1.7.0.4

