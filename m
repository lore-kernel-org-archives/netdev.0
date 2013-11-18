From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 1/9] net: stmmac: support max-speed device tree property
Date: Mon, 18 Nov 2013 11:31:42 +0000
Message-ID: <1384774302-10095-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds support to "max-speed" property which is a standard
ethernet device tree property. max-speed specifies maximum speed
(specified in megabits per second) supported the device.

Depending on the clocking schemes some of the boards can only support
few link speeds, so having a way to limit the link speed in the mac
driver would allow such setups to work reliably.

Without this patch there is no way to tell the driver to limit the
link speed.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 +++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    4 ++++
 include/linux/stmmac.h                             |    1 +
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8d4ccd3..f72c6a2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -784,6 +784,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	char phy_id_fmt[MII_BUS_ID_SIZE + 3];
 	char bus_id[MII_BUS_ID_SIZE];
 	int interface = priv->plat->interface;
+	int max_speed = priv->plat->max_speed;
 	priv->oldlink = 0;
 	priv->speed = 0;
 	priv->oldduplex = -1;
@@ -808,7 +809,8 @@ static int stmmac_init_phy(struct net_device *dev)
 
 	/* Stop Advertising 1000BASE Capability if interface is not GMII */
 	if ((interface == PHY_INTERFACE_MODE_MII) ||
-	    (interface == PHY_INTERFACE_MODE_RMII))
+	    (interface == PHY_INTERFACE_MODE_RMII) ||
+		(max_speed < 1000 &&  max_speed > 0))
 		phydev->advertising &= ~(SUPPORTED_1000baseT_Half |
 					 SUPPORTED_1000baseT_Full);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 51c9069..3073c50 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -42,6 +42,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	*mac = of_get_mac_address(np);
 	plat->interface = of_get_phy_mode(np);
 
+	/* Get max speed of operation from device tree */
+	if (of_property_read_u32(np, "max-speed", &plat->max_speed))
+		plat->max_speed = -1;
+
 	plat->bus_id = of_alias_get_id(np, "ethernet");
 	if (plat->bus_id < 0)
 		plat->bus_id = 0;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index bb5deb0..33ace71 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -110,6 +110,7 @@ struct plat_stmmacenet_data {
 	int force_sf_dma_mode;
 	int force_thresh_dma_mode;
 	int riwt_off;
+	int max_speed;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev);
-- 
1.7.6.5
