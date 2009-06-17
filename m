From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 1/2] Revert "net/ucc_geth: Add SGMII support for UEC GETH
	driver"
Date: Wed, 17 Jun 2009 17:16:04 -0600
Message-ID: <20090617231604.7051.86872.stgit@localhost.localdomain>
References: <20090617231306.7051.56146.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>, Nathan Lynch <ntl@pobox.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Tony Breeds <tony@bakeyournoodle.com>, michael@ellerman.id.au,
	Haiying Wang <Haiying.Wang@freescale.com>, davem@davemloft.net
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	subrata@linux.vnet.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:61911 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762061AbZFQXQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 19:16:04 -0400
In-Reply-To: <20090617231306.7051.56146.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This reverts commit 047584ce94108012288554a5f84585d792cc7f8f.

This patch meshes badly with "net: Rework ucc_geth driver to use
of_mdio infrastructure" (0b9da337dca972e7a4144e298ec3adb8f244d4a4).
Since most of the patch needs to be reworked, it is clearer to revert
the patch and then apply the corrected version

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/powerpc/include/asm/qe.h |    2 -
 drivers/net/ucc_geth.c        |   79 +----------------------------------------
 drivers/net/ucc_geth.h        |   28 +--------------
 3 files changed, 2 insertions(+), 107 deletions(-)


diff --git a/arch/powerpc/include/asm/qe.h b/arch/powerpc/include/asm/qe.h
index 157c5ca..e0faf33 100644
--- a/arch/powerpc/include/asm/qe.h
+++ b/arch/powerpc/include/asm/qe.h
@@ -675,8 +675,6 @@ struct ucc_slow_pram {
 #define UCC_GETH_UPSMR_RMM      0x00001000
 #define UCC_GETH_UPSMR_CAM      0x00000400
 #define UCC_GETH_UPSMR_BRO      0x00000200
-#define UCC_GETH_UPSMR_SMM	0x00000080
-#define UCC_GETH_UPSMR_SGMM	0x00000020
 
 /* UCC Transmit On Demand Register (UTODR) */
 #define UCC_SLOW_TOD	0x8000
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e2f2e91..5118993 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2009 Freescale Semicondutor, Inc. All rights reserved.
+ * Copyright (C) 2006-2007 Freescale Semicondutor, Inc. All rights reserved.
  *
  * Author: Shlomi Gridish <gridish@freescale.com>
  *	   Li Yang <leoli@freescale.com>
@@ -65,8 +65,6 @@
 
 static DEFINE_SPINLOCK(ugeth_lock);
 
-static void uec_configure_serdes(struct net_device *dev);
-
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -1412,9 +1410,6 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 		upsmr |= UCC_GETH_UPSMR_TBIM;
 	}
-	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_SGMII))
-		upsmr |= UCC_GETH_UPSMR_SGMM;
-
 	out_be32(&uf_regs->upsmr, upsmr);
 
 	/* Disable autonegotiation in tbi mode, because by default it
@@ -1559,9 +1554,6 @@ static int init_phy(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	if (priv->phy_interface == PHY_INTERFACE_MODE_SGMII)
-		uec_configure_serdes(dev);
-
 	phydev->supported &= (ADVERTISED_10baseT_Half |
 				 ADVERTISED_10baseT_Full |
 				 ADVERTISED_100baseT_Half |
@@ -1577,41 +1569,7 @@ static int init_phy(struct net_device *dev)
 	return 0;
 }
 
-/* Initialize TBI PHY interface for communicating with the
- * SERDES lynx PHY on the chip.  We communicate with this PHY
- * through the MDIO bus on each controller, treating it as a
- * "normal" PHY at the address found in the UTBIPA register.  We assume
- * that the UTBIPA register is valid.  Either the MDIO bus code will set
- * it to a value that doesn't conflict with other PHYs on the bus, or the
- * value doesn't matter, as there are no other PHYs on the bus.
- */
-static void uec_configure_serdes(struct net_device *dev)
-{
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-
-	if (!ugeth->tbiphy) {
-		printk(KERN_WARNING "SGMII mode requires that the device "
-			"tree specify a tbi-handle\n");
-	return;
-	}
-
-	/*
-	 * If the link is already up, we must already be ok, and don't need to
-	 * configure and reset the TBI<->SerDes link.  Maybe U-Boot configured
-	 * everything for us?  Resetting it takes the link down and requires
-	 * several seconds for it to come back.
-	 */
-	if (phy_read(ugeth->tbiphy, ENET_TBI_MII_SR) & TBISR_LSTATUS)
-		return;
-
-	/* Single clk mode, mii mode off(for serdes communication) */
-	phy_write(ugeth->tbiphy, ENET_TBI_MII_ANA, TBIANA_SETTINGS);
 
-	phy_write(ugeth->tbiphy, ENET_TBI_MII_TBICON, TBICON_CLK_SELECT);
-
-	phy_write(ugeth->tbiphy, ENET_TBI_MII_CR, TBICR_SETTINGS);
-
-}
 
 static int ugeth_graceful_stop_tx(struct ucc_geth_private *ugeth)
 {
@@ -3573,8 +3531,6 @@ static phy_interface_t to_phy_interface(const char *phy_connection_type)
 		return PHY_INTERFACE_MODE_RGMII_RXID;
 	if (strcasecmp(phy_connection_type, "rtbi") == 0)
 		return PHY_INTERFACE_MODE_RTBI;
-	if (strcasecmp(phy_connection_type, "sgmii") == 0)
-		return PHY_INTERFACE_MODE_SGMII;
 
 	return PHY_INTERFACE_MODE_MII;
 }
@@ -3619,7 +3575,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		PHY_INTERFACE_MODE_RMII, PHY_INTERFACE_MODE_RGMII,
 		PHY_INTERFACE_MODE_GMII, PHY_INTERFACE_MODE_RGMII,
 		PHY_INTERFACE_MODE_TBI, PHY_INTERFACE_MODE_RTBI,
-		PHY_INTERFACE_MODE_SGMII,
 	};
 
 	ugeth_vdbg("%s: IN", __func__);
@@ -3735,7 +3690,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		case PHY_INTERFACE_MODE_RGMII_TXID:
 		case PHY_INTERFACE_MODE_TBI:
 		case PHY_INTERFACE_MODE_RTBI:
-		case PHY_INTERFACE_MODE_SGMII:
 			max_speed = SPEED_1000;
 			break;
 		default:
@@ -3818,37 +3772,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ugeth->ndev = dev;
 	ugeth->node = np;
 
-	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
-	ph = of_get_property(np, "tbi-handle", NULL);
-	if (ph) {
-		struct device_node *tbi = of_find_node_by_phandle(*ph);
-		struct of_device *ofdev;
-		struct mii_bus *bus;
-		const unsigned int *id;
-
-		if (!tbi)
-			return 0;
-
-		mdio = of_get_parent(tbi);
-		if (!mdio)
-			return 0;
-
-		ofdev = of_find_device_by_node(mdio);
-
-		of_node_put(mdio);
-
-		id = of_get_property(tbi, "reg", NULL);
-		if (!id)
-			return 0;
-		of_node_put(tbi);
-
-		bus = dev_get_drvdata(&ofdev->dev);
-		if (!bus)
-			return 0;
-
-		ugeth->tbiphy = bus->phy_map[*id];
-	}
-
 	return 0;
 }
 
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 5beba4c..8160276 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) Freescale Semicondutor, Inc. 2006-2009. All rights reserved.
+ * Copyright (C) Freescale Semicondutor, Inc. 2006. All rights reserved.
  *
  * Author: Shlomi Gridish <gridish@freescale.com>
  *
@@ -193,31 +193,6 @@ struct ucc_geth {
 #define	ENET_TBI_MII_JD		0x10	/* Jitter diagnostics */
 #define	ENET_TBI_MII_TBICON	0x11	/* TBI control */
 
-/* TBI MDIO register bit fields*/
-#define TBISR_LSTATUS          0x0004
-#define TBICON_CLK_SELECT       0x0020
-#define TBIANA_ASYMMETRIC_PAUSE 0x0100
-#define TBIANA_SYMMETRIC_PAUSE  0x0080
-#define TBIANA_HALF_DUPLEX      0x0040
-#define TBIANA_FULL_DUPLEX      0x0020
-#define TBICR_PHY_RESET         0x8000
-#define TBICR_ANEG_ENABLE       0x1000
-#define TBICR_RESTART_ANEG      0x0200
-#define TBICR_FULL_DUPLEX       0x0100
-#define TBICR_SPEED1_SET        0x0040
-
-#define TBIANA_SETTINGS ( \
-		TBIANA_ASYMMETRIC_PAUSE \
-		| TBIANA_SYMMETRIC_PAUSE \
-		| TBIANA_FULL_DUPLEX \
-		)
-#define TBICR_SETTINGS ( \
-		TBICR_PHY_RESET \
-		| TBICR_ANEG_ENABLE \
-		| TBICR_FULL_DUPLEX \
-		| TBICR_SPEED1_SET \
-		)
-
 /* UCC GETH MACCFG1 (MAC Configuration 1 Register) */
 #define MACCFG1_FLOW_RX                         0x00000020	/* Flow Control
 								   Rx */
@@ -1213,7 +1188,6 @@ struct ucc_geth_private {
 
 	struct ugeth_mii_info *mii_info;
 	struct phy_device *phydev;
-	struct phy_device *tbiphy;
 	phy_interface_t phy_interface;
 	int max_speed;
 	uint32_t msg_enable;

