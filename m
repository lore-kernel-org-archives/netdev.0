From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 5/5] net-next: stmmac: rework the speed selection
Date: Wed, 24 May 2017 09:16:47 +0200
Message-ID: <20170524071647.7921-6-clabbe.montjoie@gmail.com>
References: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current stmmac_adjust_link() part which handle speed have
some if (has_platform) code and my dwmac-sun8i will add more of them.

So we need to handle better speed selection.
Moreover the struct link member speed and port are hard to guess their
purpose. And their unique usage are to be combined for writing speed.

So this patch replace speed/port by simpler
speed10/speed100/speed1000/speed_mask variables.

In dwmac4_core_init and dwmac1000_core_init, port/speed value was used
directly without using the struct link. This patch convert also their
usage to speedxxx.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  8 ++++---
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 26 +++++++++++++---------
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  6 +++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 26 +++++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 21 ++++-------------
 5 files changed, 43 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index b7ce3fbb5375..e82b4b70b7be 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -549,9 +549,11 @@ extern const struct stmmac_hwtimestamp stmmac_ptp;
 extern const struct stmmac_mode_ops dwmac4_ring_mode_ops;
 
 struct mac_link {
-	int port;
-	int duplex;
-	int speed;
+	u32 speed_mask;
+	u32 speed10;
+	u32 speed100;
+	u32 speed1000;
+	u32 duplex;
 };
 
 struct mii_regs {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index f3d9305e5f70..8a86340ff2d3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -45,15 +45,17 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
 	if (hw->ps) {
 		value |= GMAC_CONTROL_TE;
 
-		if (hw->ps == SPEED_1000) {
-			value &= ~GMAC_CONTROL_PS;
-		} else {
-			value |= GMAC_CONTROL_PS;
-
-			if (hw->ps == SPEED_10)
-				value &= ~GMAC_CONTROL_FES;
-			else
-				value |= GMAC_CONTROL_FES;
+		value &= ~hw->link.speed_mask;
+		switch (hw->ps) {
+		case SPEED_1000:
+			value |= hw->link.speed1000;
+			break;
+		case SPEED_100:
+			value |= hw->link.speed100;
+			break;
+		case SPEED_10:
+			value |= hw->link.speed10;
+			break;
 		}
 	}
 
@@ -531,9 +533,11 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
 	mac->mac = &dwmac1000_ops;
 	mac->dma = &dwmac1000_dma_ops;
 
-	mac->link.port = GMAC_CONTROL_PS;
 	mac->link.duplex = GMAC_CONTROL_DM;
-	mac->link.speed = GMAC_CONTROL_FES;
+	mac->link.speed10 = GMAC_CONTROL_PS;
+	mac->link.speed100 = GMAC_CONTROL_PS | GMAC_CONTROL_FES;
+	mac->link.speed1000 = 0;
+	mac->link.speed_mask = GMAC_CONTROL_PS | GMAC_CONTROL_FES;
 	mac->mii.addr = GMAC_MII_ADDR;
 	mac->mii.data = GMAC_MII_DATA;
 	mac->mii.addr_shift = 11;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 1b3609105484..8ef517356313 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -175,9 +175,11 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr, int *synopsys_id)
 	mac->mac = &dwmac100_ops;
 	mac->dma = &dwmac100_dma_ops;
 
-	mac->link.port = MAC_CONTROL_PS;
 	mac->link.duplex = MAC_CONTROL_F;
-	mac->link.speed = 0;
+	mac->link.speed10 = 0;
+	mac->link.speed100 = 0;
+	mac->link.speed1000 = 0;
+	mac->link.speed_mask = MAC_CONTROL_PS;
 	mac->mii.addr = MAC_MII_ADDR;
 	mac->mii.data = MAC_MII_DATA;
 	mac->mii.addr_shift = 11;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 48793f2e9307..f233bf8b4ebb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -35,15 +35,17 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
 	if (hw->ps) {
 		value |= GMAC_CONFIG_TE;
 
-		if (hw->ps == SPEED_1000) {
-			value &= ~GMAC_CONFIG_PS;
-		} else {
-			value |= GMAC_CONFIG_PS;
-
-			if (hw->ps == SPEED_10)
-				value &= ~GMAC_CONFIG_FES;
-			else
-				value |= GMAC_CONFIG_FES;
+		value &= hw->link.speed_mask;
+		switch (hw->ps) {
+		case SPEED_1000:
+			value |= hw->link.speed1000;
+			break;
+		case SPEED_100:
+			value |= hw->link.speed100;
+			break;
+		case SPEED_10:
+			value |= hw->link.speed10;
+			break;
 		}
 	}
 
@@ -747,9 +749,11 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	if (mac->multicast_filter_bins)
 		mac->mcast_bits_log2 = ilog2(mac->multicast_filter_bins);
 
-	mac->link.port = GMAC_CONFIG_PS;
 	mac->link.duplex = GMAC_CONFIG_DM;
-	mac->link.speed = GMAC_CONFIG_FES;
+	mac->link.speed10 = GMAC_CONFIG_PS;
+	mac->link.speed100 = GMAC_CONFIG_FES | GMAC_CONFIG_PS;
+	mac->link.speed1000 = 0;
+	mac->link.speed_mask = GMAC_CONFIG_FES | GMAC_CONFIG_PS;
 	mac->mii.addr = GMAC_MDIO_ADDR;
 	mac->mii.data = GMAC_MDIO_DATA;
 	mac->mii.addr_shift = 21;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4bd83a29cbd5..68a188e74c54 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -812,29 +812,16 @@ static void stmmac_adjust_link(struct net_device *dev)
 
 		if (phydev->speed != priv->speed) {
 			new_state = true;
+			ctrl &= ~priv->hw->link.speed_mask;
 			switch (phydev->speed) {
 			case SPEED_1000:
-				if (priv->plat->has_gmac ||
-				    priv->plat->has_gmac4)
-					ctrl &= ~priv->hw->link.port;
+				ctrl |= priv->hw->link.speed1000;
 				break;
 			case SPEED_100:
-				if (priv->plat->has_gmac ||
-				    priv->plat->has_gmac4) {
-					ctrl |= priv->hw->link.port;
-					ctrl |= priv->hw->link.speed;
-				} else {
-					ctrl &= ~priv->hw->link.port;
-				}
+				ctrl |= priv->hw->link.speed100;
 				break;
 			case SPEED_10:
-				if (priv->plat->has_gmac ||
-				    priv->plat->has_gmac4) {
-					ctrl |= priv->hw->link.port;
-					ctrl &= ~(priv->hw->link.speed);
-				} else {
-					ctrl &= ~priv->hw->link.port;
-				}
+				ctrl |= priv->hw->link.speed10;
 				break;
 			default:
 				netif_warn(priv, link, priv->dev,
-- 
2.13.0
