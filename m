From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH] ucc_geth: eliminate max-speed, change interface-type to
 phy-connection-type
Date: Wed, 2 May 2007 14:21:49 -0500
Message-ID: <20070502142149.08720051.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Kumar Gala <galak@kernel.crashing.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:35119 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993136AbXEBTWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 15:22:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was agreed that phy-connection-type was a better name for
the interface-type property, so this patch renames it.

Also, the max-speed property name was determined too generic,
and is therefore eliminated in favour of phy-connection-type
derivation logic.

includes corrections to copyright text.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
Jeff, this patch depends on Stephen Rothwell's 
  "[PATCH 2/2] Rename get_property to of_get_property: drivers"
patch dated Tue, 1 May 2007 13:54:02 +1000

 drivers/net/ucc_geth.c     |   40 ++++++++++++++++------------------------
 drivers/net/ucc_geth_mii.c |    9 +++++----
 drivers/net/ucc_geth_mii.h |   10 +++++-----
 3 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index d7aff81..361eca0 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) Freescale Semicondutor, Inc. 2006. All rights reserved.
+ * Copyright (C) 2006-2007 Freescale Semicondutor, Inc. All rights reserved.
  *
  * Author: Shlomi Gridish <gridish@freescale.com>
  *	   Li Yang <leoli@freescale.com>
@@ -3737,21 +3737,21 @@ static int ucc_geth_close(struct net_device *dev)
 
 const struct ethtool_ops ucc_geth_ethtool_ops = { };
 
-static phy_interface_t to_phy_interface(const char *interface_type)
+static phy_interface_t to_phy_interface(const char *phy_connection_type)
 {
-	if (strcasecmp(interface_type, "mii") == 0)
+	if (strcasecmp(phy_connection_type, "mii") == 0)
 		return PHY_INTERFACE_MODE_MII;
-	if (strcasecmp(interface_type, "gmii") == 0)
+	if (strcasecmp(phy_connection_type, "gmii") == 0)
 		return PHY_INTERFACE_MODE_GMII;
-	if (strcasecmp(interface_type, "tbi") == 0)
+	if (strcasecmp(phy_connection_type, "tbi") == 0)
 		return PHY_INTERFACE_MODE_TBI;
-	if (strcasecmp(interface_type, "rmii") == 0)
+	if (strcasecmp(phy_connection_type, "rmii") == 0)
 		return PHY_INTERFACE_MODE_RMII;
-	if (strcasecmp(interface_type, "rgmii") == 0)
+	if (strcasecmp(phy_connection_type, "rgmii") == 0)
 		return PHY_INTERFACE_MODE_RGMII;
-	if (strcasecmp(interface_type, "rgmii-id") == 0)
+	if (strcasecmp(phy_connection_type, "rgmii-id") == 0)
 		return PHY_INTERFACE_MODE_RGMII_ID;
-	if (strcasecmp(interface_type, "rtbi") == 0)
+	if (strcasecmp(phy_connection_type, "rtbi") == 0)
 		return PHY_INTERFACE_MODE_RTBI;
 
 	return PHY_INTERFACE_MODE_MII;
@@ -3819,29 +3819,21 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ug_info->phy_address = *prop;
 
 	/* get the phy interface type, or default to MII */
-	prop = of_get_property(np, "interface-type", NULL);
+	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
 		prop = of_get_property(phy, "interface", NULL);
-		if (prop != NULL)
+		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];
-		else
+			max_speed = enet_to_speed[*prop];
+		} else
 			phy_interface = PHY_INTERFACE_MODE_MII;
 	} else {
 		phy_interface = to_phy_interface((const char *)prop);
 	}
 
-	/* get speed, or derive from interface */
-	prop = of_get_property(np, "max-speed", NULL);
-	if (!prop) {
-		/* handle interface property present in old trees */
-		prop = of_get_property(phy, "interface", NULL);
-		if (prop != NULL)
-			max_speed = enet_to_speed[*prop];
-	} else {
-		max_speed = *prop;
-	}
-	if (!max_speed) {
+	/* get speed, or derive from PHY interface */
+	if (max_speed == 0)
 		switch (phy_interface) {
 		case PHY_INTERFACE_MODE_GMII:
 		case PHY_INTERFACE_MODE_RGMII:
@@ -3854,9 +3846,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 			max_speed = SPEED_100;
 			break;
 		}
-	}
 
 	if (max_speed == SPEED_1000) {
+		/* configure muram FIFOs for gigabit operation */
 		ug_info->uf_info.urfs = UCC_GETH_URFS_GIGA_INIT;
 		ug_info->uf_info.urfet = UCC_GETH_URFET_GIGA_INIT;
 		ug_info->uf_info.urfset = UCC_GETH_URFSET_GIGA_INIT;
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 27a1ef3..f96966d 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -1,12 +1,13 @@
 /*
  * drivers/net/ucc_geth_mii.c
  *
- * Gianfar Ethernet Driver -- MIIM bus implementation
- * Provides Bus interface for MIIM regs
+ * QE UCC Gigabit Ethernet Driver -- MII Management Bus Implementation
+ * Provides Bus interface for MII Management regs in the UCC register space
  *
- * Author: Li Yang
+ * Copyright (C) 2007 Freescale Semiconductor, Inc.
  *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ * Authors: Li Yang <leoli@freescale.com>
+ *	    Kim Phillips <kim.phillips@freescale.com>
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
diff --git a/drivers/net/ucc_geth_mii.h b/drivers/net/ucc_geth_mii.h
index 98430fe..d834370 100644
--- a/drivers/net/ucc_geth_mii.h
+++ b/drivers/net/ucc_geth_mii.h
@@ -1,13 +1,13 @@
 /*
  * drivers/net/ucc_geth_mii.h
  *
- * Gianfar Ethernet Driver -- MII Management Bus Implementation
- * Driver for the MDIO bus controller in the Gianfar register space
+ * QE UCC Gigabit Ethernet Driver -- MII Management Bus Implementation
+ * Provides Bus interface for MII Management regs in the UCC register space
  *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala
+ * Copyright (C) 2007 Freescale Semiconductor, Inc.
  *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ * Authors: Li Yang <leoli@freescale.com>
+ *	    Kim Phillips <kim.phillips@freescale.com>
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
-- 
1.5.0.3

