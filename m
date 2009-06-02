From: Haiying Wang <Haiying.Wang@freescale.com>
Subject: [PATCH 3/4 v2] net/ucc_geth: Add SGMII support for UEC GETH driver
Date: Tue,  2 Jun 2009 10:04:15 -0400
Message-ID: <1243951456-4685-3-git-send-email-Haiying.Wang@freescale.com>
References: <1243951456-4685-1-git-send-email-Haiying.Wang@freescale.com>
 <1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com>
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Haiying Wang <Haiying.Wang@freescale.com>
To: davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44590 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756743AbZFBODu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 10:03:50 -0400
In-Reply-To: <1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
---
 arch/powerpc/include/asm/qe.h |    2 +
 drivers/net/ucc_geth.c        |   79 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/ucc_geth.h        |   28 ++++++++++++++-
 3 files changed, 107 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/qe.h b/arch/powerpc/include/asm/qe.h
index 2701753..4459d20 100644
--- a/arch/powerpc/include/asm/qe.h
+++ b/arch/powerpc/include/asm/qe.h
@@ -668,6 +668,8 @@ struct ucc_slow_pram {
 #define UCC_GETH_UPSMR_RMM      0x00001000
 #define UCC_GETH_UPSMR_CAM      0x00000400
 #define UCC_GETH_UPSMR_BRO      0x00000200
+#define UCC_GETH_UPSMR_SMM	0x00000080
+#define UCC_GETH_UPSMR_SGMM	0x00000020
 
 /* UCC Transmit On Demand Register (UTODR) */
 #define UCC_SLOW_TOD	0x8000
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 0cf22c4..fd6140b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2007 Freescale Semicondutor, Inc. All rights reserved.
+ * Copyright (C) 2006-2009 Freescale Semicondutor, Inc. All rights reserved.
  *
  * Author: Shlomi Gridish <gridish@freescale.com>
  *	   Li Yang <leoli@freescale.com>
@@ -65,6 +65,8 @@
 
 static DEFINE_SPINLOCK(ugeth_lock);
 
+static void uec_configure_serdes(struct net_device *dev);
+
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -1410,6 +1412,9 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 		upsmr |= UCC_GETH_UPSMR_TBIM;
 	}
+	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_SGMII))
+		upsmr |= UCC_GETH_UPSMR_SGMM;
+
 	out_be32(&uf_regs->upsmr, upsmr);
 
 	/* Disable autonegotiation in tbi mode, because by default it
@@ -1554,6 +1559,9 @@ static int init_phy(struct net_device *dev)
 		return -ENODEV;
 	}
 
+	if (priv->phy_interface == PHY_INTERFACE_MODE_SGMII)
+		uec_configure_serdes(dev);
+
 	phydev->supported &= (ADVERTISED_10baseT_Half |
 				 ADVERTISED_10baseT_Full |
 				 ADVERTISED_100baseT_Half |
@@ -1569,7 +1577,41 @@ static int init_phy(struct net_device *dev)
 	return 0;
 }
 
+/* Initialize TBI PHY interface for communicating with the
+ * SERDES lynx PHY on the chip.  We communicate with this PHY
+ * through the MDIO bus on each controller, treating it as a
+ * "normal" PHY at the address found in the UTBIPA register.  We assume
+ * that the UTBIPA register is valid.  Either the MDIO bus code will set
+ * it to a value that doesn't conflict with other PHYs on the bus, or the
+ * value doesn't matter, as there are no other PHYs on the bus.
+ */
+static void uec_configure_serdes(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+
+	if (!ugeth->tbiphy) {
+		printk(KERN_WARNING "SGMII mode requires that the device "
+			"tree specify a tbi-handle\n");
+	return;
+	}
+
+	/*
+	 * If the link is already up, we must already be ok, and don't need to
+	 * configure and reset the TBI<->SerDes link.  Maybe U-Boot configured
+	 * everything for us?  Resetting it takes the link down and requires
+	 * several seconds for it to come back.
+	 */
+	if (phy_read(ugeth->tbiphy, ENET_TBI_MII_SR) & TBISR_LSTATUS)
+		return;
+
+	/* Single clk mode, mii mode off(for serdes communication) */
+	phy_write(ugeth->tbiphy, ENET_TBI_MII_ANA, TBIANA_SETTINGS);
 
+	phy_write(ugeth->tbiphy, ENET_TBI_MII_TBICON, TBICON_CLK_SELECT);
+
+	phy_write(ugeth->tbiphy, ENET_TBI_MII_CR, TBICR_SETTINGS);
+
+}
 
 static int ugeth_graceful_stop_tx(struct ucc_geth_private *ugeth)
 {
@@ -3523,6 +3565,8 @@ static phy_interface_t to_phy_interface(const char *phy_connection_type)
 		return PHY_INTERFACE_MODE_RGMII_RXID;
 	if (strcasecmp(phy_connection_type, "rtbi") == 0)
 		return PHY_INTERFACE_MODE_RTBI;
+	if (strcasecmp(phy_connection_type, "sgmii") == 0)
+		return PHY_INTERFACE_MODE_SGMII;
 
 	return PHY_INTERFACE_MODE_MII;
 }
@@ -3567,6 +3611,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		PHY_INTERFACE_MODE_RMII, PHY_INTERFACE_MODE_RGMII,
 		PHY_INTERFACE_MODE_GMII, PHY_INTERFACE_MODE_RGMII,
 		PHY_INTERFACE_MODE_TBI, PHY_INTERFACE_MODE_RTBI,
+		PHY_INTERFACE_MODE_SGMII,
 	};
 
 	ugeth_vdbg("%s: IN", __func__);
@@ -3682,6 +3727,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		case PHY_INTERFACE_MODE_RGMII_TXID:
 		case PHY_INTERFACE_MODE_TBI:
 		case PHY_INTERFACE_MODE_RTBI:
+		case PHY_INTERFACE_MODE_SGMII:
 			max_speed = SPEED_1000;
 			break;
 		default:
@@ -3756,6 +3802,37 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ugeth->ndev = dev;
 	ugeth->node = np;
 
+	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
+	ph = of_get_property(np, "tbi-handle", NULL);
+	if (ph) {
+		struct device_node *tbi = of_find_node_by_phandle(*ph);
+		struct of_device *ofdev;
+		struct mii_bus *bus;
+		const unsigned int *id;
+
+		if (!tbi)
+			return 0;
+
+		mdio = of_get_parent(tbi);
+		if (!mdio)
+			return 0;
+
+		ofdev = of_find_device_by_node(mdio);
+
+		of_node_put(mdio);
+
+		id = of_get_property(tbi, "reg", NULL);
+		if (!id)
+			return 0;
+		of_node_put(tbi);
+
+		bus = dev_get_drvdata(&ofdev->dev);
+		if (!bus)
+			return 0;
+
+		ugeth->tbiphy = bus->phy_map[*id];
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index dca628a..deb962b 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) Freescale Semicondutor, Inc. 2006. All rights reserved.
+ * Copyright (C) Freescale Semicondutor, Inc. 2006-2009. All rights reserved.
  *
  * Author: Shlomi Gridish <gridish@freescale.com>
  *
@@ -193,6 +193,31 @@ struct ucc_geth {
 #define	ENET_TBI_MII_JD		0x10	/* Jitter diagnostics */
 #define	ENET_TBI_MII_TBICON	0x11	/* TBI control */
 
+/* TBI MDIO register bit fields*/
+#define TBISR_LSTATUS          0x0004
+#define TBICON_CLK_SELECT       0x0020
+#define TBIANA_ASYMMETRIC_PAUSE 0x0100
+#define TBIANA_SYMMETRIC_PAUSE  0x0080
+#define TBIANA_HALF_DUPLEX      0x0040
+#define TBIANA_FULL_DUPLEX      0x0020
+#define TBICR_PHY_RESET         0x8000
+#define TBICR_ANEG_ENABLE       0x1000
+#define TBICR_RESTART_ANEG      0x0200
+#define TBICR_FULL_DUPLEX       0x0100
+#define TBICR_SPEED1_SET        0x0040
+
+#define TBIANA_SETTINGS ( \
+		TBIANA_ASYMMETRIC_PAUSE \
+		| TBIANA_SYMMETRIC_PAUSE \
+		| TBIANA_FULL_DUPLEX \
+		)
+#define TBICR_SETTINGS ( \
+		TBICR_PHY_RESET \
+		| TBICR_ANEG_ENABLE \
+		| TBICR_FULL_DUPLEX \
+		| TBICR_SPEED1_SET \
+		)
+
 /* UCC GETH MACCFG1 (MAC Configuration 1 Register) */
 #define MACCFG1_FLOW_RX                         0x00000020	/* Flow Control
 								   Rx */
@@ -1188,6 +1213,7 @@ struct ucc_geth_private {
 
 	struct ugeth_mii_info *mii_info;
 	struct phy_device *phydev;
+	struct phy_device *tbiphy;
 	phy_interface_t phy_interface;
 	int max_speed;
 	uint32_t msg_enable;
-- 
1.6.0.2

