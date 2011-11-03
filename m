From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Thu, 3 Nov 2011 16:54:11 -0500
Message-ID: <1320357251-15335-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:33816
	"EHLO VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442Ab1KCVyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 17:54:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for setting the address of the internal TBI PHY was
convoluted enough without a maze of ifdefs. Clean it up a bit
so we allow the logic to fail down to -ENODEV at the end of
the if/else ladder, rather than using ifdefs to repeat the same
failure code over and over.

Also, remove the support for the auto-configuration. I'm not aware of
anyone using it, and it ends up using the bus mutex before it's been
initialized.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   53 ++++----------------------
 1 files changed, 8 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 52f4e8a..4d9f84b 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -183,28 +183,10 @@ void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
 }
 EXPORT_SYMBOL_GPL(fsl_pq_mdio_bus_name);
 
-/* Scan the bus in reverse, looking for an empty spot */
-static int fsl_pq_mdio_find_free(struct mii_bus *new_bus)
-{
-	int i;
-
-	for (i = PHY_MAX_ADDR; i > 0; i--) {
-		u32 phy_id;
-
-		if (get_phy_id(new_bus, i, &phy_id))
-			return -1;
-
-		if (phy_id == 0xffffffff)
-			break;
-	}
-
-	return i;
-}
-
 
-#if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
 static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs, struct device_node *np)
 {
+#if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
 	struct gfar __iomem *enet_regs;
 
 	/*
@@ -220,15 +202,15 @@ static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs, struct devi
 	} else if (of_device_is_compatible(np, "fsl,etsec2-mdio") ||
 			of_device_is_compatible(np, "fsl,etsec2-tbi")) {
 		return of_iomap(np, 1);
-	} else
-		return NULL;
-}
+	}
 #endif
+	return NULL;
+}
 
 
-#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
 static int get_ucc_id_for_range(u64 start, u64 end, u32 *ucc_id)
 {
+#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
 	struct device_node *np = NULL;
 	int err = 0;
 
@@ -261,9 +243,10 @@ static int get_ucc_id_for_range(u64 start, u64 end, u32 *ucc_id)
 		return err;
 	else
 		return -EINVAL;
-}
+#else
+	return -ENODEV;
 #endif
-
+}
 
 static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 {
@@ -339,19 +322,13 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 			of_device_is_compatible(np, "fsl,etsec2-mdio") ||
 			of_device_is_compatible(np, "fsl,etsec2-tbi") ||
 			of_device_is_compatible(np, "gianfar")) {
-#if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
 		tbipa = get_gfar_tbipa(regs, np);
 		if (!tbipa) {
 			err = -EINVAL;
 			goto err_free_irqs;
 		}
-#else
-		err = -ENODEV;
-		goto err_free_irqs;
-#endif
 	} else if (of_device_is_compatible(np, "fsl,ucc-mdio") ||
 			of_device_is_compatible(np, "ucc_geth_phy")) {
-#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
 		u32 id;
 		static u32 mii_mng_master;
 
@@ -364,10 +341,6 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 			mii_mng_master = id;
 			ucc_set_qe_mux_mii_mng(id - 1);
 		}
-#else
-		err = -ENODEV;
-		goto err_free_irqs;
-#endif
 	} else {
 		err = -ENODEV;
 		goto err_free_irqs;
@@ -386,16 +359,6 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 	}
 
 	if (tbiaddr == -1) {
-		out_be32(tbipa, 0);
-
-		tbiaddr = fsl_pq_mdio_find_free(new_bus);
-	}
-
-	/*
-	 * We define TBIPA at 0 to be illegal, opting to fail for boards that
-	 * have PHYs at 1-31, rather than change tbipa and rescan.
-	 */
-	if (tbiaddr == 0) {
 		err = -EBUSY;
 
 		goto err_free_irqs;
-- 
1.7.3.4
