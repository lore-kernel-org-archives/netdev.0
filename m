From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/2] net: stmmac: unify mdio functions
Date: Thu,  1 Dec 2016 16:19:41 +0100
Message-ID: <1480605581-13350-2-git-send-email-clabbe.montjoie@gmail.com>
References: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

stmmac_mdio_{read|write} and stmmac_mdio_{read|write}_gmac4 are not
enought different for being split.
The only differences between thoses two functions are shift/mask for
addr/reg/clk_csr.

This patch introduce a per platform set of variable for setting thoses
shift/mask and unify mdio read and write functions.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   6 +
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   6 +
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   7 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |   6 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 121 ++++-----------------
 5 files changed, 48 insertions(+), 98 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 5bd4c05..3ced2e1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -507,6 +507,12 @@ struct mac_link {
 struct mii_regs {
 	unsigned int addr;	/* MII Address */
 	unsigned int data;	/* MII Data */
+	unsigned int addr_shift;	/* MII address shift */
+	unsigned int reg_shift;		/* MII reg shift */
+	unsigned int addr_mask;		/* MII address mask */
+	unsigned int reg_mask;		/* MII reg mask */
+	unsigned int clk_csr_shift;
+	unsigned int clk_csr_mask;
 };
 
 /* Helpers to manage the descriptors for chain and ring modes */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 7df4ff1..b21d03f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -534,6 +534,12 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
 	mac->link.speed = GMAC_CONTROL_FES;
 	mac->mii.addr = GMAC_MII_ADDR;
 	mac->mii.data = GMAC_MII_DATA;
+	mac->mii.addr_shift = 11;
+	mac->mii.addr_mask = 0x0000F800;
+	mac->mii.reg_shift = 6;
+	mac->mii.reg_mask = 0x000007C0;
+	mac->mii.clk_csr_shift = 2;
+	mac->mii.clk_csr_mask = 0xF;
 
 	/* Get and dump the chip ID */
 	*synopsys_id = stmmac_get_synopsys_id(hwid);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 6418b2e..a1d582f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -192,6 +192,13 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr, int *synopsys_id)
 	mac->link.speed = 0;
 	mac->mii.addr = MAC_MII_ADDR;
 	mac->mii.data = MAC_MII_DATA;
+	mac->mii.addr_shift = 11;
+	mac->mii.addr_mask = 0x0000F800;
+	mac->mii.reg_shift = 6;
+	mac->mii.reg_mask = 0x000007C0;
+	mac->mii.clk_csr_shift = 2;
+	mac->mii.clk_csr_mask = 0xF;
+
 	/* Synopsys Id is not available on old chips */
 	*synopsys_id = 0;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 51019b7..eaed7cb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -430,6 +430,12 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	mac->link.speed = GMAC_CONFIG_FES;
 	mac->mii.addr = GMAC_MDIO_ADDR;
 	mac->mii.data = GMAC_MDIO_DATA;
+	mac->mii.addr_shift = 21;
+	mac->mii.addr_mask = GENMASK(25, 21);
+	mac->mii.reg_shift = 16;
+	mac->mii.reg_mask = GENMASK(20, 16);
+	mac->mii.clk_csr_shift = 8;
+	mac->mii.clk_csr_mask = GENMASK(11, 8);
 
 	/* Get and dump the chip ID */
 	*synopsys_id = stmmac_get_synopsys_id(hwid);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 6796c28..23322fd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -42,13 +42,6 @@
 #define MII_GMAC4_WRITE			(1 << MII_GMAC4_GOC_SHIFT)
 #define MII_GMAC4_READ			(3 << MII_GMAC4_GOC_SHIFT)
 
-#define MII_PHY_ADDR_GMAC4_SHIFT	21
-#define MII_PHY_ADDR_GMAC4_MASK		GENMASK(25, 21)
-#define MII_PHY_REG_GMAC4_SHIFT		16
-#define MII_PHY_REG_GMAC4_MASK		GENMASK(20, 16)
-#define MII_CSR_CLK_GMAC4_SHIFT		8
-#define MII_CSR_CLK_GMAC4_MASK		GENMASK(11, 8)
-
 static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_addr)
 {
 	unsigned long curr;
@@ -68,8 +61,8 @@ static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_addr)
 /**
  * stmmac_mdio_read
  * @bus: points to the mii_bus structure
- * @phyaddr: MII addr reg bits 15-11
- * @phyreg: MII addr reg bits 10-6
+ * @phyaddr: MII addr
+ * @phyreg: MII reg
  * Description: it reads data from the MII register from within the phy device.
  * For the 7111 GMAC, we must set the bit 0 in the MII address register while
  * accessing the PHY registers.
@@ -83,9 +76,15 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	unsigned int mii_data = priv->hw->mii.data;
 
 	int data;
-	u16 value = (((phyaddr << 11) & (0x0000F800)) |
-			((phyreg << 6) & (0x000007C0)));
-	value |= MII_BUSY | ((priv->clk_csr & 0xF) << 2);
+	u32 value = MII_BUSY;
+
+	value |= (phyaddr << priv->hw->mii.addr_shift)
+		& priv->hw->mii.addr_mask;
+	value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
+	value |= (priv->clk_csr & priv->hw->mii.clk_csr_mask)
+		<< priv->hw->mii.clk_csr_shift;
+	if (priv->plat->has_gmac4)
+		value |= MII_GMAC4_READ;
 
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
 		return -EBUSY;
@@ -104,8 +103,8 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 /**
  * stmmac_mdio_write
  * @bus: points to the mii_bus structure
- * @phyaddr: MII addr reg bits 15-11
- * @phyreg: MII addr reg bits 10-6
+ * @phyaddr: MII addr
+ * @phyreg: MII reg
  * @phydata: phy data
  * Description: it writes the data into the MII register from within the device.
  */
@@ -117,85 +116,16 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	unsigned int mii_address = priv->hw->mii.addr;
 	unsigned int mii_data = priv->hw->mii.data;
 
-	u16 value =
-	    (((phyaddr << 11) & (0x0000F800)) | ((phyreg << 6) & (0x000007C0)))
-	    | MII_WRITE;
+	u32 value = MII_WRITE | MII_BUSY;
 
-	value |= MII_BUSY | ((priv->clk_csr & 0xF) << 2);
+	value |= (phyaddr << priv->hw->mii.addr_shift)
+		& priv->hw->mii.addr_mask;
+	value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
 
-	/* Wait until any existing MII operation is complete */
-	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
-		return -EBUSY;
-
-	/* Set the MII address register to write */
-	writel(phydata, priv->ioaddr + mii_data);
-	writel(value, priv->ioaddr + mii_address);
-
-	/* Wait until any existing MII operation is complete */
-	return stmmac_mdio_busy_wait(priv->ioaddr, mii_address);
-}
-
-/**
- * stmmac_mdio_read_gmac4
- * @bus: points to the mii_bus structure
- * @phyaddr: MII addr reg bits 25-21
- * @phyreg: MII addr reg bits 20-16
- * Description: it reads data from the MII register of GMAC4 from within
- * the phy device.
- */
-static int stmmac_mdio_read_gmac4(struct mii_bus *bus, int phyaddr, int phyreg)
-{
-	struct net_device *ndev = bus->priv;
-	struct stmmac_priv *priv = netdev_priv(ndev);
-	unsigned int mii_address = priv->hw->mii.addr;
-	unsigned int mii_data = priv->hw->mii.data;
-	int data;
-	u32 value = (((phyaddr << MII_PHY_ADDR_GMAC4_SHIFT) &
-		     (MII_PHY_ADDR_GMAC4_MASK)) |
-		     ((phyreg << MII_PHY_REG_GMAC4_SHIFT) &
-		     (MII_PHY_REG_GMAC4_MASK))) | MII_GMAC4_READ;
-
-	value |= MII_BUSY | ((priv->clk_csr & MII_CSR_CLK_GMAC4_MASK)
-		 << MII_CSR_CLK_GMAC4_SHIFT);
-
-	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
-		return -EBUSY;
-
-	writel(value, priv->ioaddr + mii_address);
-
-	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
-		return -EBUSY;
-
-	/* Read the data from the MII data register */
-	data = (int)readl(priv->ioaddr + mii_data);
-
-	return data;
-}
-
-/**
- * stmmac_mdio_write_gmac4
- * @bus: points to the mii_bus structure
- * @phyaddr: MII addr reg bits 25-21
- * @phyreg: MII addr reg bits 20-16
- * @phydata: phy data
- * Description: it writes the data into the MII register of GMAC4 from within
- * the device.
- */
-static int stmmac_mdio_write_gmac4(struct mii_bus *bus, int phyaddr, int phyreg,
-				   u16 phydata)
-{
-	struct net_device *ndev = bus->priv;
-	struct stmmac_priv *priv = netdev_priv(ndev);
-	unsigned int mii_address = priv->hw->mii.addr;
-	unsigned int mii_data = priv->hw->mii.data;
-
-	u32 value = (((phyaddr << MII_PHY_ADDR_GMAC4_SHIFT) &
-		     (MII_PHY_ADDR_GMAC4_MASK)) |
-		     ((phyreg << MII_PHY_REG_GMAC4_SHIFT) &
-		     (MII_PHY_REG_GMAC4_MASK))) | MII_GMAC4_WRITE;
-
-	value |= MII_BUSY | ((priv->clk_csr & MII_CSR_CLK_GMAC4_MASK)
-		 << MII_CSR_CLK_GMAC4_SHIFT);
+	value |= ((priv->clk_csr & priv->hw->mii.clk_csr_mask)
+		<< priv->hw->mii.clk_csr_shift);
+	if (priv->plat->has_gmac4)
+		value |= MII_GMAC4_WRITE;
 
 	/* Wait until any existing MII operation is complete */
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
@@ -305,13 +235,8 @@ int stmmac_mdio_register(struct net_device *ndev)
 #endif
 
 	new_bus->name = "stmmac";
-	if (priv->plat->has_gmac4) {
-		new_bus->read = &stmmac_mdio_read_gmac4;
-		new_bus->write = &stmmac_mdio_write_gmac4;
-	} else {
-		new_bus->read = &stmmac_mdio_read;
-		new_bus->write = &stmmac_mdio_write;
-	}
+	new_bus->read = &stmmac_mdio_read;
+	new_bus->write = &stmmac_mdio_write;
 
 	new_bus->reset = &stmmac_mdio_reset;
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-- 
2.7.3
