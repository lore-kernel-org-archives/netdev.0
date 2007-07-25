From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: [PATCH 1/2] [POWERPC] Add support of platforms without PHY to gianfar
	driver
Date: Wed, 25 Jul 2007 21:43:12 +0400
Message-ID: <20070725174312.5818.61155.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38842 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756989AbXGYRn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 13:43:29 -0400
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Gianfar driver is now able to work without real phy subnode,
that is necessary to cope with fixed-link situation, when
SoC is connected to the Ethernet inteface or embedded switch 
without any PHY. In this case, fixed-speed property will
describe such a situation for gianfar driver.

The property is in form <duplexity speed>

Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>

---

 arch/powerpc/sysdev/fsl_soc.c |   39 +++++++++++++++++++++++----------------
 drivers/net/gianfar.c         |   17 ++++++++++++++---
 2 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index cad1757..6864534 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -255,29 +255,36 @@ static int __init gfar_of_init(void)
 			    FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
 
 		ph = of_get_property(np, "phy-handle", NULL);
-		phy = of_find_node_by_phandle(*ph);
+		if (ph == NULL) {
+			unsigned int *bus_id;
 
-		if (phy == NULL) {
-			ret = -ENODEV;
-			goto unreg;
-		}
+			bus_id = of_get_property(np, "fixed_speed",NULL);
+			gfar_data.bus_id = (bus_id[0]<<16) | bus_id[1];
+		} else {
+			phy = of_find_node_by_phandle(*ph);
 
-		mdio = of_get_parent(phy);
+			if (phy == NULL) {
+				ret = -ENODEV;
+				goto unreg;
+			}
+
+			mdio = of_get_parent(phy);
+
+			id = of_get_property(phy, "reg", NULL);
+			ret = of_address_to_resource(mdio, 0, &res);
+			if (ret) {
+				of_node_put(phy);
+				of_node_put(mdio);
+				goto unreg;
+			}
+
+			gfar_data.phy_id = *id;
+			gfar_data.bus_id = res.start;
 
-		id = of_get_property(phy, "reg", NULL);
-		ret = of_address_to_resource(mdio, 0, &res);
-		if (ret) {
 			of_node_put(phy);
 			of_node_put(mdio);
-			goto unreg;
 		}
 
-		gfar_data.phy_id = *id;
-		gfar_data.bus_id = res.start;
-
-		of_node_put(phy);
-		of_node_put(mdio);
-
 		ret =
 		    platform_device_add_data(gfar_dev, &gfar_data,
 					     sizeof(struct
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1b854bf..cf08ced 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -93,6 +93,7 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #include "gianfar.h"
 #include "gianfar_mii.h"
@@ -445,11 +446,21 @@ static int init_phy(struct net_device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
-
 	interface = gfar_get_interface(dev);
 
-	phydev = phy_connect(dev, phy_id, &adjust_link, 0, interface);
+	if (priv->einfo->phy_id) {
+		snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
+		phydev = phy_connect(dev, phy_id, &adjust_link, 0, interface);
+	} else {
+		struct fixed_info *phyinfo;
+		int phy_addr = (priv->einfo->bus_id >> 16);
+		
+		phyinfo = fixed_mdio_get_phydev(phy_addr-1);
+		phydev = phyinfo->phydev;
+		snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT,
+			(priv->einfo->bus_id & 0xffff) , phy_addr);
+		memset(phyinfo->regs,0xff,sizeof(phyinfo->regs[0])*phyinfo->regs_num);
+	}
 
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);

