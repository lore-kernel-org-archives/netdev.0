From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH net-next] net: ethernet: stmmac: update MDIO support for GMAC4
Date: Thu, 28 Apr 2016 15:56:45 +0200
Message-ID: <1461851805-15201-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:18042 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbcD1N45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 09:56:57 -0400
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3SDsqWQ008017
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 15:56:56 +0200
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by m0046037.ppops.net with ESMTP id 22fxttdcun-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 15:56:55 +0200
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id BACE222
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 13:56:51 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 2226729A
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 13:56:50 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On new GMAC4 IP, MAC_MDIO_address register has been updated, and bitmaps
changed. This patch takes into account those changes.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 06704ca..3f83c36 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -37,6 +37,18 @@
 #define MII_BUSY 0x00000001
 #define MII_WRITE 0x00000002
 
+/* GMAC4 defines */
+#define MII_GMAC4_GOC_SHIFT		2
+#define MII_GMAC4_WRITE			(1 << MII_GMAC4_GOC_SHIFT)
+#define MII_GMAC4_READ			(3 << MII_GMAC4_GOC_SHIFT)
+
+#define MII_PHY_ADDR_GMAC4_SHIFT	21
+#define MII_PHY_ADDR_GMAC4_MASK		GENMASK(25, 21)
+#define MII_PHY_REG_GMAC4_SHIFT		16
+#define MII_PHY_REG_GMAC4_MASK		GENMASK(20, 16)
+#define MII_CSR_CLK_GMAC4_SHIFT		8
+#define MII_CSR_CLK_GMAC4_MASK		GENMASK(11, 8)
+
 static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_addr)
 {
 	unsigned long curr;
@@ -124,6 +136,80 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 }
 
 /**
+ * stmmac_mdio_read_gmac4
+ * @bus: points to the mii_bus structure
+ * @phyaddr: MII addr reg bits 25-21
+ * @phyreg: MII addr reg bits 20-16
+ * Description: it reads data from the MII register of GMAC4 from within
+ * the phy device.
+ */
+static int stmmac_mdio_read_gmac4(struct mii_bus *bus, int phyaddr, int phyreg)
+{
+	struct net_device *ndev = bus->priv;
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	unsigned int mii_address = priv->hw->mii.addr;
+	unsigned int mii_data = priv->hw->mii.data;
+	int data;
+	u32 value = (((phyaddr << MII_PHY_ADDR_GMAC4_SHIFT) &
+		     (MII_PHY_ADDR_GMAC4_MASK)) |
+		     ((phyreg << MII_PHY_REG_GMAC4_SHIFT) &
+		     (MII_PHY_REG_GMAC4_MASK))) | MII_GMAC4_READ;
+
+	value |= MII_BUSY | ((priv->clk_csr & MII_CSR_CLK_GMAC4_MASK)
+		 << MII_CSR_CLK_GMAC4_SHIFT);
+
+	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
+		return -EBUSY;
+
+	writel(value, priv->ioaddr + mii_address);
+
+	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
+		return -EBUSY;
+
+	/* Read the data from the MII data register */
+	data = (int)readl(priv->ioaddr + mii_data);
+
+	return data;
+}
+
+/**
+ * stmmac_mdio_write_gmac4
+ * @bus: points to the mii_bus structure
+ * @phyaddr: MII addr reg bits 25-21
+ * @phyreg: MII addr reg bits 20-16
+ * @phydata: phy data
+ * Description: it writes the data into the MII register of GMAC4 from within
+ * the device.
+ */
+static int stmmac_mdio_write_gmac4(struct mii_bus *bus, int phyaddr, int phyreg,
+				   u16 phydata)
+{
+	struct net_device *ndev = bus->priv;
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	unsigned int mii_address = priv->hw->mii.addr;
+	unsigned int mii_data = priv->hw->mii.data;
+
+	u32 value = (((phyaddr << MII_PHY_ADDR_GMAC4_SHIFT) &
+		     (MII_PHY_ADDR_GMAC4_MASK)) |
+		     ((phyreg << MII_PHY_REG_GMAC4_SHIFT) &
+		     (MII_PHY_REG_GMAC4_MASK))) | MII_GMAC4_WRITE;
+
+	value |= MII_BUSY | ((priv->clk_csr & MII_CSR_CLK_GMAC4_MASK)
+		 << MII_CSR_CLK_GMAC4_SHIFT);
+
+	/* Wait until any existing MII operation is complete */
+	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
+		return -EBUSY;
+
+	/* Set the MII address register to write */
+	writel(phydata, priv->ioaddr + mii_data);
+	writel(value, priv->ioaddr + mii_address);
+
+	/* Wait until any existing MII operation is complete */
+	return stmmac_mdio_busy_wait(priv->ioaddr, mii_address);
+}
+
+/**
  * stmmac_mdio_reset
  * @bus: points to the mii_bus structure
  * Description: reset the MII bus
@@ -180,9 +266,11 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 
 	/* This is a workaround for problems with the STE101P PHY.
 	 * It doesn't complete its reset until at least one clock cycle
-	 * on MDC, so perform a dummy mdio read.
+	 * on MDC, so perform a dummy mdio read. To be upadted for GMAC4
+	 * if needed.
 	 */
-	writel(0, priv->ioaddr + mii_address);
+	if (!priv->plat->has_gmac4)
+		writel(0, priv->ioaddr + mii_address);
 #endif
 	return 0;
 }
@@ -217,8 +305,14 @@ int stmmac_mdio_register(struct net_device *ndev)
 #endif
 
 	new_bus->name = "stmmac";
-	new_bus->read = &stmmac_mdio_read;
-	new_bus->write = &stmmac_mdio_write;
+	if (priv->plat->has_gmac4) {
+		new_bus->read = &stmmac_mdio_read_gmac4;
+		new_bus->write = &stmmac_mdio_write_gmac4;
+	} else {
+		new_bus->read = &stmmac_mdio_read;
+		new_bus->write = &stmmac_mdio_write;
+	}
+
 	new_bus->reset = &stmmac_mdio_reset;
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		 new_bus->name, priv->plat->bus_id);
-- 
1.9.1
