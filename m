From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: Add 405EX support to new EMAC driver
Date: Fri, 2 Nov 2007 08:14:43 +0100
Message-ID: <200711020814.43524.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:61353 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbXKBHQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 03:16:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the 405EX to the new EMAC driver. Some as on
AXON, the 405EX handles the MDIO via the RGMII bridge.

Tested on AMCC Kilauea.

Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/core.c  |    3 ++-
 drivers/net/ibm_newemac/rgmii.c |   16 +++++++++++-----
 drivers/net/ibm_newemac/rgmii.h |    2 +-
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 0de3aa2..fd0a585 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2466,7 +2466,8 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	if (of_device_is_compatible(np, "ibm,emac4"))
 		dev->features |= EMAC_FTR_EMAC4;
 	if (of_device_is_compatible(np, "ibm,emac-axon")
-	    || of_device_is_compatible(np, "ibm,emac-440epx"))
+	    || of_device_is_compatible(np, "ibm,emac-440epx")
+	    || of_device_is_compatible(np, "ibm,emac-405ex"))
 		dev->features |= EMAC_FTR_HAS_AXON_STACR
 			| EMAC_FTR_STACR_OC_INVERT;
 	if (of_device_is_compatible(np, "ibm,emac-440spe"))
diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
index de41695..b9a4ce7 100644
--- a/drivers/net/ibm_newemac/rgmii.c
+++ b/drivers/net/ibm_newemac/rgmii.c
@@ -140,7 +140,12 @@ void rgmii_get_mdio(struct of_device *ofdev, int input)
 
 	RGMII_DBG2(dev, "get_mdio(%d)" NL, input);
 
-	if (dev->type != RGMII_AXON)
+	/*
+	 * Some platforms (e.g. 440GX) have RGMII support but don't use it for
+	 * MDIO access. Only continue if platforms is using MDIO over the RGMII
+	 * interface (e.g. AXON, 405EX).
+	 */
+	if (dev->type != RGMII_HAS_MDIO)
 		return;
 
 	mutex_lock(&dev->lock);
@@ -161,7 +166,7 @@ void rgmii_put_mdio(struct of_device *ofdev, int input)
 
 	RGMII_DBG2(dev, "put_mdio(%d)" NL, input);
 
-	if (dev->type != RGMII_AXON)
+	if (dev->type != RGMII_HAS_MDIO)
 		return;
 
 	fer = in_be32(&p->fer);
@@ -251,8 +256,9 @@ static int __devinit rgmii_probe(struct of_device *ofdev,
 	}
 
 	/* Check for RGMII type */
-	if (of_device_is_compatible(ofdev->node, "ibm,rgmii-axon"))
-		dev->type = RGMII_AXON;
+	if (of_device_is_compatible(ofdev->node, "ibm,rgmii-axon") ||
+	    of_device_is_compatible(ofdev->node, "ibm,rgmii-405ex"))
+		dev->type = RGMII_HAS_MDIO;
 	else
 		dev->type = RGMII_STANDARD;
 
@@ -264,7 +270,7 @@ static int __devinit rgmii_probe(struct of_device *ofdev,
 
 	printk(KERN_INFO
 	       "RGMII %s %s initialized\n",
-	       dev->type == RGMII_STANDARD ? "standard" : "axon",
+	       dev->type == RGMII_STANDARD ? "standard" : "has-mdio",
 	       ofdev->node->full_name);
 
 	wmb();
diff --git a/drivers/net/ibm_newemac/rgmii.h b/drivers/net/ibm_newemac/rgmii.h
index 5780683..f1b0ef5 100644
--- a/drivers/net/ibm_newemac/rgmii.h
+++ b/drivers/net/ibm_newemac/rgmii.h
@@ -23,7 +23,7 @@
 
 /* RGMII bridge type */
 #define RGMII_STANDARD		0
-#define RGMII_AXON		1
+#define RGMII_HAS_MDIO		1
 
 /* RGMII bridge */
 struct rgmii_regs {
-- 
1.5.3.4.498.g9c514

