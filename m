From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 2/3] net: ibm_newemac: convert it to use of_get_phy_mode
Date: Tue, 5 Jul 2011 23:13:58 +0800
Message-ID: <1309878839-25743-3-git-send-email-shawn.guo@linaro.org>
References: <1309878839-25743-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<devicetree-discuss@lists.ozlabs.org>, <patches@linaro.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:49329 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755251Ab1GEPHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 11:07:45 -0400
In-Reply-To: <1309878839-25743-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch extends 'enum phy_interface_t' and of_get_phy_mode a little
bit with PHY_INTERFACE_MODE_NA and PHY_INTERFACE_MODE_SMII added,
and then converts ibm_newemac net driver to use of_get_phy_mode
getting phy mode from device tree.

It also resolves the namespace conflict on phy_read/write between
common mdiobus interface and ibm_newemac private one.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/ibm_newemac/core.c |   33 ++++-----------------------------
 drivers/net/ibm_newemac/emac.h |   19 ++++++++++---------
 drivers/net/ibm_newemac/phy.c  |    7 +++++--
 drivers/of/of_net.c            |    2 ++
 include/linux/phy.h            |    4 +++-
 5 files changed, 24 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 725399e..70cb7d8 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -39,6 +39,7 @@
 #include <linux/bitops.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
+#include <linux/of_net.h>
 #include <linux/slab.h>
 
 #include <asm/processor.h>
@@ -2506,18 +2507,6 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 {
 	struct device_node *np = dev->ofdev->dev.of_node;
 	const void *p;
-	unsigned int plen;
-	const char *pm, *phy_modes[] = {
-		[PHY_MODE_NA] = "",
-		[PHY_MODE_MII] = "mii",
-		[PHY_MODE_RMII] = "rmii",
-		[PHY_MODE_SMII] = "smii",
-		[PHY_MODE_RGMII] = "rgmii",
-		[PHY_MODE_TBI] = "tbi",
-		[PHY_MODE_GMII] = "gmii",
-		[PHY_MODE_RTBI] = "rtbi",
-		[PHY_MODE_SGMII] = "sgmii",
-	};
 
 	/* Read config from device-tree */
 	if (emac_read_uint_prop(np, "mal-device", &dev->mal_ph, 1))
@@ -2566,23 +2555,9 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 		dev->mal_burst_size = 256;
 
 	/* PHY mode needs some decoding */
-	dev->phy_mode = PHY_MODE_NA;
-	pm = of_get_property(np, "phy-mode", &plen);
-	if (pm != NULL) {
-		int i;
-		for (i = 0; i < ARRAY_SIZE(phy_modes); i++)
-			if (!strcasecmp(pm, phy_modes[i])) {
-				dev->phy_mode = i;
-				break;
-			}
-	}
-
-	/* Backward compat with non-final DT */
-	if (dev->phy_mode == PHY_MODE_NA && pm != NULL && plen == 4) {
-		u32 nmode = *(const u32 *)pm;
-		if (nmode > PHY_MODE_NA && nmode <= PHY_MODE_SGMII)
-			dev->phy_mode = nmode;
-	}
+	dev->phy_mode = of_get_phy_mode(np);
+	if (dev->phy_mode < 0)
+		dev->phy_mode = PHY_MODE_NA;
 
 	/* Check EMAC version */
 	if (of_device_is_compatible(np, "ibm,emac4sync")) {
diff --git a/drivers/net/ibm_newemac/emac.h b/drivers/net/ibm_newemac/emac.h
index 8a61b597..1568278 100644
--- a/drivers/net/ibm_newemac/emac.h
+++ b/drivers/net/ibm_newemac/emac.h
@@ -26,6 +26,7 @@
 #define __IBM_NEWEMAC_H
 
 #include <linux/types.h>
+#include <linux/phy.h>
 
 /* EMAC registers 			Write Access rules */
 struct emac_regs {
@@ -106,15 +107,15 @@ struct emac_regs {
 /*
  * PHY mode settings (EMAC <-> ZMII/RGMII bridge <-> PHY)
  */
-#define PHY_MODE_NA	0
-#define PHY_MODE_MII	1
-#define PHY_MODE_RMII	2
-#define PHY_MODE_SMII	3
-#define PHY_MODE_RGMII	4
-#define PHY_MODE_TBI	5
-#define PHY_MODE_GMII	6
-#define PHY_MODE_RTBI	7
-#define PHY_MODE_SGMII	8
+#define PHY_MODE_NA	PHY_INTERFACE_MODE_NA
+#define PHY_MODE_MII	PHY_INTERFACE_MODE_MII
+#define PHY_MODE_RMII	PHY_INTERFACE_MODE_RMII
+#define PHY_MODE_SMII	PHY_INTERFACE_MODE_SMII
+#define PHY_MODE_RGMII	PHY_INTERFACE_MODE_RGMII
+#define PHY_MODE_TBI	PHY_INTERFACE_MODE_TBI
+#define PHY_MODE_GMII	PHY_INTERFACE_MODE_GMII
+#define PHY_MODE_RTBI	PHY_INTERFACE_MODE_RTBI
+#define PHY_MODE_SGMII	PHY_INTERFACE_MODE_SGMII
 
 /* EMACx_MR0 */
 #define EMAC_MR0_RXI			0x80000000
diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/phy.c
index ac9d964..ab4e596 100644
--- a/drivers/net/ibm_newemac/phy.c
+++ b/drivers/net/ibm_newemac/phy.c
@@ -28,12 +28,15 @@
 #include "emac.h"
 #include "phy.h"
 
-static inline int phy_read(struct mii_phy *phy, int reg)
+#define phy_read _phy_read
+#define phy_write _phy_write
+
+static inline int _phy_read(struct mii_phy *phy, int reg)
 {
 	return phy->mdio_read(phy->dev, phy->address, reg);
 }
 
-static inline void phy_write(struct mii_phy *phy, int reg, int val)
+static inline void _phy_write(struct mii_phy *phy, int reg, int val)
 {
 	phy->mdio_write(phy->dev, phy->address, reg, val);
 }
diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index cc117db..bb18471 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -16,6 +16,7 @@
  * device driver can get phy interface from device tree.
  */
 static const char *phy_modes[] = {
+	[PHY_INTERFACE_MODE_NA]		= "",
 	[PHY_INTERFACE_MODE_MII]	= "mii",
 	[PHY_INTERFACE_MODE_GMII]	= "gmii",
 	[PHY_INTERFACE_MODE_SGMII]	= "sgmii",
@@ -26,6 +27,7 @@ static const char *phy_modes[] = {
 	[PHY_INTERFACE_MODE_RGMII_RXID]	= "rgmii-rxid",
 	[PHY_INTERFACE_MODE_RGMII_TXID] = "rgmii-txid",
 	[PHY_INTERFACE_MODE_RTBI]	= "rtbi",
+	[PHY_INTERFACE_MODE_SMII]	= "smii",
 };
 
 /**
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7da5fa8..1622081 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -53,6 +53,7 @@
 
 /* Interface Mode definitions */
 typedef enum {
+	PHY_INTERFACE_MODE_NA,
 	PHY_INTERFACE_MODE_MII,
 	PHY_INTERFACE_MODE_GMII,
 	PHY_INTERFACE_MODE_SGMII,
@@ -62,7 +63,8 @@ typedef enum {
 	PHY_INTERFACE_MODE_RGMII_ID,
 	PHY_INTERFACE_MODE_RGMII_RXID,
 	PHY_INTERFACE_MODE_RGMII_TXID,
-	PHY_INTERFACE_MODE_RTBI
+	PHY_INTERFACE_MODE_RTBI,
+	PHY_INTERFACE_MODE_SMII,
 } phy_interface_t;
 
 
-- 
1.7.4.1


