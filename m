From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH RFC 2/2] fsl_fman: use fixed_phy_status for MEMAC
Date: Wed, 5 Aug 2015 17:42:25 +0300
Message-ID: <1438785745-15517-3-git-send-email-madalin.bucur@freescale.com>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<Igal.Liberman@freescale.com>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <grant.likely@linaro.org>,
	<robh+dt@kernel.org>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0145.outbound.protection.outlook.com ([65.55.169.145]:44056
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751657AbbHEO6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 10:58:54 -0400
In-Reply-To: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the speed and duplex information from the device tree fixed link
node accessing the status structure parsed by of_phy_parse_fixed_link().

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  6 ++--
 drivers/net/ethernet/freescale/fman/inc/mac.h      |  2 +-
 drivers/net/ethernet/freescale/fman/mac/fm_memac.c | 42 ++++++++++++++++------
 drivers/net/ethernet/freescale/fman/mac/fm_memac.h |  3 +-
 drivers/net/ethernet/freescale/fman/mac/mac.c      | 18 +++++++---
 5 files changed, 52 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h
index ebf7989..50bed14 100644
--- a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_memac.h
@@ -33,8 +33,10 @@
 #define __FSL_FMAN_MEMAC_H
 
 #include <linux/io.h>
-
+#include <linux/netdevice.h>
+#include <linux/phy_fixed.h>
 #include "fsl_enet.h"
+
 /* Num of additional exact match MAC adr regs */
 #define MEMAC_NUM_OF_PADDRS 7
 
@@ -373,7 +375,7 @@ struct memac_cfg {
 	bool tx_pbl_fwd;
 	bool debug_mode;
 	bool wake_on_lan;
-	bool fixed_link;
+	struct fixed_phy_status *fixed_link;
 	u16 max_frame_length;
 	u16 pause_quanta;
 	u32 tx_ipg_length;
diff --git a/drivers/net/ethernet/freescale/fman/inc/mac.h b/drivers/net/ethernet/freescale/fman/inc/mac.h
index f86d0bc..fbeb957 100644
--- a/drivers/net/ethernet/freescale/fman/inc/mac.h
+++ b/drivers/net/ethernet/freescale/fman/inc/mac.h
@@ -62,7 +62,7 @@ struct mac_device {
 	phy_interface_t		 phy_if;
 	u32			 if_support;
 	bool			 link;
-	bool			 fixed_link;
+	struct fixed_phy_status	*fixed_link;
 	u16		 speed;
 	u16		 max_speed;
 	struct device_node	*phy_node;
diff --git a/drivers/net/ethernet/freescale/fman/mac/fm_memac.c b/drivers/net/ethernet/freescale/fman/mac/fm_memac.c
index becbb88..3d5ede3 100644
--- a/drivers/net/ethernet/freescale/fman/mac/fm_memac.c
+++ b/drivers/net/ethernet/freescale/fman/mac/fm_memac.c
@@ -71,9 +71,10 @@ static int memac_mii_write_phy_reg(struct memac_t *memac, u8 phy_addr,
 }
 
 static void setup_sgmii_internal_phy(struct memac_t *memac, u8 phy_addr,
-				     bool fixed_link)
+				     struct fixed_phy_status *fixed_link)
 {
 	u16 tmp_reg16;
+	enum ethernet_interface enet_if;
 	enum e_enet_mode enet_mode;
 
 	/* In case the higher MACs are used (i.e. the MACs that should
@@ -81,20 +82,37 @@ static void setup_sgmii_internal_phy(struct memac_t *memac, u8 phy_addr,
 	 * Temporary modify enet mode to 1G one, so MII functions can
 	 * work correctly.
 	 */
+	enet_if = ENET_INTERFACE_FROM_MODE(memac->enet_mode);
 	enet_mode = memac->enet_mode;
-	memac->enet_mode =
-	    MAKE_ENET_MODE(ENET_INTERFACE_FROM_MODE(memac->enet_mode),
-			   ENET_SPEED_1000);
+	memac->enet_mode = MAKE_ENET_MODE(enet_if, ENET_SPEED_1000);
 
 	/* SGMII mode */
 	tmp_reg16 = PHY_SGMII_IF_MODE_SGMII;
 	if (!fixed_link)
 		/* AN enable */
 		tmp_reg16 |= PHY_SGMII_IF_MODE_AN;
-	else
-		/* Fixed link 1Gb FD */
-		tmp_reg16 |= PHY_SGMII_IF_MODE_SPEED_GB |
-			     PHY_SGMII_IF_MODE_DUPLEX_FULL;
+	else {
+		switch (fixed_link->speed) {
+		case 10:
+			tmp_reg16 |= PHY_SGMII_IF_MODE_SPEED_10M;
+			memac->enet_mode = MAKE_ENET_MODE(enet_if,
+							  ENET_SPEED_10);
+		break;
+		case 100:
+			tmp_reg16 |= PHY_SGMII_IF_MODE_SPEED_100M;
+			memac->enet_mode = MAKE_ENET_MODE(enet_if,
+							  ENET_SPEED_100);
+		break;
+		case 1000: /* fallthrough */
+		default:
+			tmp_reg16 |= PHY_SGMII_IF_MODE_SPEED_GB;
+		break;
+		}
+		if (fixed_link->duplex)
+			tmp_reg16 |= PHY_SGMII_IF_MODE_DUPLEX_FULL;
+		else
+			tmp_reg16 |= PHY_SGMII_IF_MODE_DUPLEX_HALF;
+	}
 	memac_mii_write_phy_reg(memac, phy_addr, 0x14, tmp_reg16);
 
 	/* Device ability according to SGMII specification */
@@ -120,6 +138,7 @@ static void setup_sgmii_internal_phy(struct memac_t *memac, u8 phy_addr,
 		/* Restart AN */
 		tmp_reg16 = PHY_SGMII_CR_DEF_VAL | PHY_SGMII_CR_RESET_AN;
 	else
+		/* AN disabled */
 		tmp_reg16 = PHY_SGMII_CR_DEF_VAL & ~PHY_SGMII_CR_AN_ENABLE;
 	memac_mii_write_phy_reg(memac, phy_addr, 0x0, tmp_reg16);
 
@@ -370,14 +389,15 @@ int memac_cfg_reset_on_init(struct fm_mac_dev *fm_mac_dev, bool enable)
 	return 0;
 }
 
-int memac_cfg_fixed_link(struct fm_mac_dev *fm_mac_dev, bool enable)
+int memac_cfg_fixed_link(struct fm_mac_dev *fm_mac_dev,
+			 struct fixed_phy_status *fixed_link)
 {
 	struct memac_t *memac = (struct memac_t *)fm_mac_dev;
 
 	if (is_init_done(memac->memac_drv_param))
 		return -EINVAL;
 
-	memac->memac_drv_param->fixed_link = enable;
+	memac->memac_drv_param->fixed_link = fixed_link;
 
 	return 0;
 }
@@ -524,7 +544,7 @@ int memac_init(struct fm_mac_dev *fm_mac_dev)
 	enet_addr_t eth_addr;
 	enum fm_mac_type port_type;
 	bool slow_10g_if = false;
-	bool fixed_link;
+	struct fixed_phy_status *fixed_link;
 	int err;
 	u32 reg32 = 0;
 
diff --git a/drivers/net/ethernet/freescale/fman/mac/fm_memac.h b/drivers/net/ethernet/freescale/fman/mac/fm_memac.h
index 8fcbd64..7c13706 100644
--- a/drivers/net/ethernet/freescale/fman/mac/fm_memac.h
+++ b/drivers/net/ethernet/freescale/fman/mac/fm_memac.h
@@ -104,7 +104,8 @@ int memac_adjust_link(struct fm_mac_dev *fm_mac_dev,
 		      enum ethernet_speed speed);
 int memac_cfg_max_frame_len(struct fm_mac_dev *fm_mac_dev, u16 new_val);
 int memac_cfg_reset_on_init(struct fm_mac_dev *fm_mac_dev, bool enable);
-int memac_cfg_fixed_link(struct fm_mac_dev *fm_mac_dev, bool enable);
+int memac_cfg_fixed_link(struct fm_mac_dev *fm_mac_dev,
+			 struct fixed_phy_status *fixed_link);
 int memac_enable(struct fm_mac_dev *fm_mac_dev, enum comm_mode mode);
 int memac_disable(struct fm_mac_dev *fm_mac_dev, enum comm_mode mode);
 int memac_init(struct fm_mac_dev *fm_mac_dev);
diff --git a/drivers/net/ethernet/freescale/fman/mac/mac.c b/drivers/net/ethernet/freescale/fman/mac/mac.c
index c44544b..4a0ab7e 100644
--- a/drivers/net/ethernet/freescale/fman/mac/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac/mac.c
@@ -39,6 +39,8 @@
 #include <linux/of_mdio.h>
 #include <linux/device.h>
 #include <linux/phy.h>
+#include <linux/netdevice.h>
+#include <linux/phy_fixed.h>
 
 #include "mac.h"
 
@@ -363,7 +365,6 @@ static int mac_probe(struct platform_device *_of_dev)
 	}
 
 	mac_dev->link		= false;
-	mac_dev->fixed_link	= false;
 	mac_dev->speed		= phy2speed[mac_dev->phy_if];
 	mac_dev->max_speed	= mac_dev->speed;
 	mac_dev->if_support = DTSEC_SUPPORTED;
@@ -383,10 +384,18 @@ static int mac_probe(struct platform_device *_of_dev)
 	/* Get the rest of the PHY information */
 	mac_dev->phy_node = of_parse_phandle(mac_node, "phy-handle", 0);
 	if (!mac_dev->phy_node && of_phy_is_fixed_link(mac_node)) {
-		err = of_phy_register_fixed_link(mac_node);
-		if (err)
+		struct phy_device *phy;
+
+		mac_dev->fixed_link = kzalloc(sizeof(*mac_dev->fixed_link),
+					      GFP_KERNEL);
+		if (of_phy_parse_fixed_link(mac_node, mac_dev->fixed_link))
+			goto _return_dev_set_drvdata;
+
+		phy = fixed_phy_register(PHY_POLL, mac_dev->fixed_link,
+					 mac_node);
+		if (IS_ERR(phy))
 			goto _return_dev_set_drvdata;
-		mac_dev->fixed_link = true;
+
 		mac_dev->phy_node = of_node_get(mac_node);
 	}
 
@@ -429,6 +438,7 @@ static int mac_probe(struct platform_device *_of_dev)
 _return_of_node_put:
 	of_node_put(dev_node);
 _return_dev_set_drvdata:
+	kfree(mac_dev->fixed_link);
 	dev_set_drvdata(dev, NULL);
 _return:
 	return err;
-- 
1.7.11.7
