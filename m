From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 2/8] drivers: net: phy: at803x: seperate wol specific code to wol standard apis
Date: Tue, 4 Jun 2013 11:40:05 +0530
Message-ID: <1370326212-17580-3-git-send-email-mugunthanvnm@ti.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42903 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383Ab3FDGJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 02:09:43 -0400
In-Reply-To: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WOL is initilized in phy config_init, but there are standard apis
(set_wol/get_wol) for WOL in phy frame work. So this patch moves
WOL specific code from config_init to wol standard apis.

Cc: Matus Ujhelyi <ujhelyi.m@gmail.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/phy/at803x.c |   64 ++++++++++++++++++++++++++++++++++------------
 1 file changed, 48 insertions(+), 16 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index a1063e1..63444b7 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -32,10 +32,13 @@ MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
 MODULE_LICENSE("GPL");
 
-static void at803x_set_wol_mac_addr(struct phy_device *phydev)
+static int at803x_set_wol(struct phy_device *phydev,
+			  struct ethtool_wolinfo *wol)
 {
 	struct net_device *ndev = phydev->attached_dev;
 	const u8 *mac;
+	int ret;
+	u32 value;
 	unsigned int i, offsets[] = {
 		AT803X_LOC_MAC_ADDR_32_47_OFFSET,
 		AT803X_LOC_MAC_ADDR_16_31_OFFSET,
@@ -43,30 +46,60 @@ static void at803x_set_wol_mac_addr(struct phy_device *phydev)
 	};
 
 	if (!ndev)
-		return;
+		return -ENODEV;
 
-	mac = (const u8 *) ndev->dev_addr;
+	if (wol->wolopts & WAKE_MAGIC) {
+		mac = (const u8 *) ndev->dev_addr;
 
-	if (!is_valid_ether_addr(mac))
-		return;
+		if (!is_valid_ether_addr(mac))
+			return -EFAULT;
 
-	for (i = 0; i < 3; i++) {
-		phy_write(phydev, AT803X_MMD_ACCESS_CONTROL,
+		for (i = 0; i < 3; i++) {
+			phy_write(phydev, AT803X_MMD_ACCESS_CONTROL,
 				  AT803X_DEVICE_ADDR);
-		phy_write(phydev, AT803X_MMD_ACCESS_CONTROL_DATA,
+			phy_write(phydev, AT803X_MMD_ACCESS_CONTROL_DATA,
 				  offsets[i]);
-		phy_write(phydev, AT803X_MMD_ACCESS_CONTROL,
+			phy_write(phydev, AT803X_MMD_ACCESS_CONTROL,
 				  AT803X_FUNC_DATA);
-		phy_write(phydev, AT803X_MMD_ACCESS_CONTROL_DATA,
+			phy_write(phydev, AT803X_MMD_ACCESS_CONTROL_DATA,
 				  mac[(i * 2) + 1] | (mac[(i * 2)] << 8));
+		}
+
+		value = phy_read(phydev, AT803X_INTR_ENABLE);
+		value |= AT803X_WOL_ENABLE;
+		ret = phy_write(phydev, AT803X_INTR_ENABLE, value);
+		if (ret)
+			return ret;
+		value = phy_read(phydev, AT803X_INTR_STATUS);
+	} else {
+		value = phy_read(phydev, AT803X_INTR_ENABLE);
+		value &= (~AT803X_WOL_ENABLE);
+		ret = phy_write(phydev, AT803X_INTR_ENABLE, value);
+		if (ret)
+			return ret;
+		value = phy_read(phydev, AT803X_INTR_STATUS);
 	}
+
+	return ret;
+}
+
+static void at803x_get_wol(struct phy_device *phydev,
+			   struct ethtool_wolinfo *wol)
+{
+	u32 value;
+
+	wol->supported = WAKE_MAGIC;
+	wol->wolopts = 0;
+
+	value = phy_read(phydev, AT803X_INTR_ENABLE);
+	if (value & AT803X_WOL_ENABLE)
+		wol->wolopts |= WAKE_MAGIC;
 }
 
 static int at803x_config_init(struct phy_device *phydev)
 {
 	int val;
 	u32 features;
-	int status;
 
 	features = SUPPORTED_TP | SUPPORTED_MII | SUPPORTED_AUI |
 		   SUPPORTED_FIBRE | SUPPORTED_BNC;
@@ -100,11 +133,6 @@ static int at803x_config_init(struct phy_device *phydev)
 	phydev->supported = features;
 	phydev->advertising = features;
 
-	/* enable WOL */
-	at803x_set_wol_mac_addr(phydev);
-	status = phy_write(phydev, AT803X_INTR_ENABLE, AT803X_WOL_ENABLE);
-	status = phy_read(phydev, AT803X_INTR_STATUS);
-
 	return 0;
 }
 
@@ -115,6 +143,8 @@ static struct phy_driver at803x_driver[] = {
 	.name		= "Atheros 8035 ethernet",
 	.phy_id_mask	= 0xffffffef,
 	.config_init	= at803x_config_init,
+	.set_wol	= at803x_set_wol,
+	.get_wol	= at803x_get_wol,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= &genphy_config_aneg,
@@ -128,6 +158,8 @@ static struct phy_driver at803x_driver[] = {
 	.name		= "Atheros 8030 ethernet",
 	.phy_id_mask	= 0xffffffef,
 	.config_init	= at803x_config_init,
+	.set_wol	= at803x_set_wol,
+	.get_wol	= at803x_get_wol,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= &genphy_config_aneg,
-- 
1.7.9.5
