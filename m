From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 5/8] netdev: cleanup unused davinci mdio emac code
Date: Tue,  3 Aug 2010 09:31:50 -0400
Message-ID: <1280842313-3743-6-git-send-email-cyril@ti.com>
References: <1280842313-3743-1-git-send-email-cyril@ti.com>
Cc: nsekhar@ti.com, srk@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1280842313-3743-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes code that has been rendered useless by the previous patches
in this series.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 drivers/net/davinci_emac.c   |  107 ------------------------------------------
 include/linux/davinci_emac.h |    3 -
 2 files changed, 0 insertions(+), 110 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 8e21a42..33dc8b5 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -113,7 +113,6 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define EMAC_DEF_MAX_FRAME_SIZE		(1500 + 14 + 4 + 4)
 #define EMAC_DEF_TX_CH			(0) /* Default 0th channel */
 #define EMAC_DEF_RX_CH			(0) /* Default 0th channel */
-#define EMAC_DEF_MDIO_TICK_MS		(10) /* typically 1 tick=1 ms) */
 #define EMAC_DEF_MAX_TX_CH		(1) /* Max TX channels configured */
 #define EMAC_DEF_MAX_RX_CH		(1) /* Max RX channels configured */
 #define EMAC_POLL_WEIGHT		(64) /* Default NAPI poll weight */
@@ -298,25 +297,6 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define EMAC_CTRL_EWCTL		(0x4)
 #define EMAC_CTRL_EWINTTCNT	(0x8)
 
-/* EMAC MDIO related */
-/* Mask & Control defines */
-#define MDIO_CONTROL_CLKDIV	(0xFF)
-#define MDIO_CONTROL_ENABLE	BIT(30)
-#define MDIO_USERACCESS_GO	BIT(31)
-#define MDIO_USERACCESS_WRITE	BIT(30)
-#define MDIO_USERACCESS_READ	(0)
-#define MDIO_USERACCESS_REGADR	(0x1F << 21)
-#define MDIO_USERACCESS_PHYADR	(0x1F << 16)
-#define MDIO_USERACCESS_DATA	(0xFFFF)
-#define MDIO_USERPHYSEL_LINKSEL	BIT(7)
-#define MDIO_VER_MODID		(0xFFFF << 16)
-#define MDIO_VER_REVMAJ		(0xFF   << 8)
-#define MDIO_VER_REVMIN		(0xFF)
-
-#define MDIO_USERACCESS(inst)	(0x80 + (inst * 8))
-#define MDIO_USERPHYSEL(inst)	(0x84 + (inst * 8))
-#define MDIO_CONTROL		(0x04)
-
 /* EMAC DM646X control module registers */
 #define EMAC_DM646X_CMRXINTEN	(0x14)
 #define EMAC_DM646X_CMTXINTEN	(0x18)
@@ -475,13 +455,6 @@ struct emac_priv {
 	u32 mac_hash2;
 	u32 multicast_hash_cnt[EMAC_NUM_MULTICAST_BITS];
 	u32 rx_addr_type;
-	/* periodic timer required for MDIO polling */
-	struct timer_list periodic_timer;
-	u32 periodic_ticks;
-	u32 timer_active;
-	u32 phy_mask;
-	/* mii_bus,phy members */
-	struct mii_bus *mii_bus;
 	const char *phy_id;
 	struct phy_device *phydev;
 	spinlock_t lock;
@@ -493,7 +466,6 @@ struct emac_priv {
 /* clock frequency for EMAC */
 static struct clk *emac_clk;
 static unsigned long emac_bus_frequency;
-static unsigned long mdio_max_freq;
 
 #define emac_virt_to_phys(addr, priv) \
 	(((u32 __force)(addr) - (u32 __force)(priv->emac_ctrl_ram)) \
@@ -531,9 +503,6 @@ static char *emac_rxhost_errcodes[16] = {
 #define emac_ctrl_read(reg)	  ioread32((priv->ctrl_base + (reg)))
 #define emac_ctrl_write(reg, val) iowrite32(val, (priv->ctrl_base + (reg)))
 
-#define emac_mdio_read(reg)	  ioread32(bus->priv + (reg))
-#define emac_mdio_write(reg, val) iowrite32(val, (bus->priv + (reg)))
-
 /**
  * emac_dump_regs: Dump important EMAC registers to debug terminal
  * @priv: The DaVinci EMAC private adapter structure
@@ -637,9 +606,6 @@ static void emac_dump_regs(struct emac_priv *priv)
 		emac_read(EMAC_RXDMAOVERRUNS));
 }
 
-/*************************************************************************
- *  EMAC MDIO/Phy Functionality
- *************************************************************************/
 /**
  * emac_get_drvinfo: Get EMAC driver information
  * @ndev: The DaVinci EMAC network adapter
@@ -2234,79 +2200,6 @@ void emac_poll_controller(struct net_device *ndev)
 }
 #endif
 
-/* PHY/MII bus related */
-
-/* Wait until mdio is ready for next command */
-#define MDIO_WAIT_FOR_USER_ACCESS\
-		while ((emac_mdio_read((MDIO_USERACCESS(0))) &\
-			MDIO_USERACCESS_GO) != 0)
-
-static int emac_mii_read(struct mii_bus *bus, int phy_id, int phy_reg)
-{
-	unsigned int phy_data = 0;
-	unsigned int phy_control;
-
-	/* Wait until mdio is ready for next command */
-	MDIO_WAIT_FOR_USER_ACCESS;
-
-	phy_control = (MDIO_USERACCESS_GO |
-		       MDIO_USERACCESS_READ |
-		       ((phy_reg << 21) & MDIO_USERACCESS_REGADR) |
-		       ((phy_id << 16) & MDIO_USERACCESS_PHYADR) |
-		       (phy_data & MDIO_USERACCESS_DATA));
-	emac_mdio_write(MDIO_USERACCESS(0), phy_control);
-
-	/* Wait until mdio is ready for next command */
-	MDIO_WAIT_FOR_USER_ACCESS;
-
-	return emac_mdio_read(MDIO_USERACCESS(0)) & MDIO_USERACCESS_DATA;
-
-}
-
-static int emac_mii_write(struct mii_bus *bus, int phy_id,
-			  int phy_reg, u16 phy_data)
-{
-
-	unsigned int control;
-
-	/*  until mdio is ready for next command */
-	MDIO_WAIT_FOR_USER_ACCESS;
-
-	control = (MDIO_USERACCESS_GO |
-		   MDIO_USERACCESS_WRITE |
-		   ((phy_reg << 21) & MDIO_USERACCESS_REGADR) |
-		   ((phy_id << 16) & MDIO_USERACCESS_PHYADR) |
-		   (phy_data & MDIO_USERACCESS_DATA));
-	emac_mdio_write(MDIO_USERACCESS(0), control);
-
-	return 0;
-}
-
-static int emac_mii_reset(struct mii_bus *bus)
-{
-	unsigned int clk_div;
-	int mdio_bus_freq = emac_bus_frequency;
-
-	if (mdio_max_freq && mdio_bus_freq)
-		clk_div = ((mdio_bus_freq / mdio_max_freq) - 1);
-	else
-		clk_div = 0xFF;
-
-	clk_div &= MDIO_CONTROL_CLKDIV;
-
-	/* Set enable and clock divider in MDIOControl */
-	emac_mdio_write(MDIO_CONTROL, (clk_div | MDIO_CONTROL_ENABLE));
-
-	return 0;
-
-}
-
-static int mii_irqs[PHY_MAX_ADDR] = { PHY_POLL, PHY_POLL };
-
-/* emac_driver: EMAC MII bus structure */
-
-static struct mii_bus *emac_mii;
-
 static void emac_adjust_link(struct net_device *ndev)
 {
 	struct emac_priv *priv = netdev_priv(ndev);
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
index 6bcd247..7508e49 100644
--- a/include/linux/davinci_emac.h
+++ b/include/linux/davinci_emac.h
@@ -24,10 +24,7 @@ struct emac_platform_data {
 	u32 ctrl_mod_reg_offset;
 	u32 ctrl_ram_offset;
 	u32 hw_ram_addr;
-	u32 mdio_reg_offset;
 	u32 ctrl_ram_size;
-	u32 phy_mask;
-	u32 mdio_max_freq;
 	const char *phy_id;
 	u8 rmii_en;
 	u8 version;
-- 
1.7.0.4

