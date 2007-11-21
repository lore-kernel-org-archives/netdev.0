From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 6/8] ibm_newemac: Cleanup/Fix RGMII MDIO support detection
Date: Wed, 21 Nov 2007 17:06:44 +1100
Message-ID: <20071121060735.0D7E2DDDF7@ozlabs.org>
References: <1195625198.76200.922309668615.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38867 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116AbXKUGHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 01:07:37 -0500
In-Reply-To: <1195625198.76200.922309668615.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More than just "AXON" version of EMAC RGMII supports MDIO, so replace
the current test with a generic property in the device-tree that
indicates such support.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Acked-by: Stefan Roese <sr@denx.de>
---

 arch/powerpc/boot/dts/sequoia.dts |    1 +
 drivers/net/ibm_newemac/rgmii.c   |   20 +++++++++++---------
 drivers/net/ibm_newemac/rgmii.h   |    5 +++--
 3 files changed, 15 insertions(+), 11 deletions(-)

Index: linux-work/drivers/net/ibm_newemac/rgmii.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/rgmii.c	2007-11-12 10:55:54.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/rgmii.c	2007-11-12 10:56:56.000000000 +1100
@@ -140,7 +140,7 @@ void rgmii_get_mdio(struct of_device *of
 
 	RGMII_DBG2(dev, "get_mdio(%d)" NL, input);
 
-	if (dev->type != RGMII_AXON)
+	if (!(dev->flags & EMAC_RGMII_FLAG_HAS_MDIO))
 		return;
 
 	mutex_lock(&dev->lock);
@@ -161,7 +161,7 @@ void rgmii_put_mdio(struct of_device *of
 
 	RGMII_DBG2(dev, "put_mdio(%d)" NL, input);
 
-	if (dev->type != RGMII_AXON)
+	if (!(dev->flags & EMAC_RGMII_FLAG_HAS_MDIO))
 		return;
 
 	fer = in_be32(&p->fer);
@@ -250,11 +250,13 @@ static int __devinit rgmii_probe(struct 
 		goto err_free;
 	}
 
-	/* Check for RGMII type */
+	/* Check for RGMII flags */
+	if (of_get_property(ofdev->node, "has-mdio", NULL))
+		dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
+
+	/* CAB lacks the right properties, fix this up */
 	if (of_device_is_compatible(ofdev->node, "ibm,rgmii-axon"))
-		dev->type = RGMII_AXON;
-	else
-		dev->type = RGMII_STANDARD;
+		dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
 
 	DBG2(dev, " Boot FER = 0x%08x, SSR = 0x%08x\n",
 	     in_be32(&dev->base->fer), in_be32(&dev->base->ssr));
@@ -263,9 +265,9 @@ static int __devinit rgmii_probe(struct 
 	out_be32(&dev->base->fer, 0);
 
 	printk(KERN_INFO
-	       "RGMII %s %s initialized\n",
-	       dev->type == RGMII_STANDARD ? "standard" : "axon",
-	       ofdev->node->full_name);
+	       "RGMII %s initialized with%s MDIO support\n",
+	       ofdev->node->full_name,
+	       (dev->flags & EMAC_RGMII_FLAG_HAS_MDIO) ? "" : "out");
 
 	wmb();
 	dev_set_drvdata(&ofdev->dev, dev);
Index: linux-work/drivers/net/ibm_newemac/rgmii.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/rgmii.h	2007-11-12 10:55:54.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/rgmii.h	2007-11-12 10:56:56.000000000 +1100
@@ -35,8 +35,9 @@ struct rgmii_regs {
 struct rgmii_instance {
 	struct rgmii_regs __iomem	*base;
 
-	/* Type of RGMII bridge */
-	int				type;
+	/* RGMII bridge flags */
+	int				flags;
+#define EMAC_RGMII_FLAG_HAS_MDIO	0x00000001
 
 	/* Only one EMAC whacks us at a time */
 	struct mutex			lock;
Index: linux-work/arch/powerpc/boot/dts/sequoia.dts
===================================================================
--- linux-work.orig/arch/powerpc/boot/dts/sequoia.dts	2007-11-12 10:58:38.000000000 +1100
+++ linux-work/arch/powerpc/boot/dts/sequoia.dts	2007-11-12 10:58:47.000000000 +1100
@@ -245,6 +245,7 @@
 				device_type = "rgmii-interface";
 				compatible = "ibm,rgmii-440epx", "ibm,rgmii";
 				reg = <ef601000 8>;
+				has-mdio;
 			};
 
 			EMAC0: ethernet@ef600e00 {
