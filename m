From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] net/fsl_pq_mdio: add support for the Fman 1G MDIO controller
Date: Thu, 23 Aug 2012 16:24:07 -0500
Message-ID: <1345757047-14657-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:53177
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758315Ab2HWVYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 17:24:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO controller on the Frame Manager (Fman) is compatible with the
QE and Gianfar MDIO controllers, but we don't care about the TBI because
the Ethernet drivers (FMD) take care of programming it.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   36 ++++++++++++++++----------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 9527b28..3af87cb 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -264,7 +264,7 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 	struct fsl_pq_mdio_priv *priv;
 	struct fsl_pq_mdio __iomem *regs = NULL;
 	void __iomem *map;
-	u32 __iomem *tbipa;
+	u32 __iomem *tbipa = NULL;
 	struct mii_bus *new_bus;
 	int tbiaddr = -1;
 	const u32 *addrp;
@@ -310,6 +310,7 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 
 	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
 			of_device_is_compatible(np, "fsl,gianfar-tbi") ||
+			of_device_is_compatible(np, "fsl,fman-mdio") ||
 			of_device_is_compatible(np, "fsl,ucc-mdio") ||
 			of_device_is_compatible(np, "ucc_geth_phy"))
 		map -= offsetof(struct fsl_pq_mdio, miimcfg);
@@ -350,27 +351,31 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 			mii_mng_master = id;
 			ucc_set_qe_mux_mii_mng(id - 1);
 		}
+	} else if (of_device_is_compatible(np, "fsl,fman-mdio")) {
+		/* No TBI operations needed for Fman, but don't fail either */
 	} else {
 		err = -ENODEV;
 		goto err_free_irqs;
 	}
 
-	for_each_child_of_node(np, tbi) {
-		if (!strncmp(tbi->type, "tbi-phy", 8))
-			break;
-	}
+	if (tbipa) {
+		for_each_child_of_node(np, tbi) {
+			if (!strncmp(tbi->type, "tbi-phy", 8))
+				break;
+		}
 
-	if (tbi) {
-		const u32 *prop = of_get_property(tbi, "reg", NULL);
+		if (tbi) {
+			const u32 *prop = of_get_property(tbi, "reg", NULL);
 
-		if (prop)
-			tbiaddr = *prop;
+			if (prop)
+				tbiaddr = be32_to_cpup(prop);
 
-		if (tbiaddr == -1) {
-			err = -EBUSY;
-			goto err_free_irqs;
-		} else {
-			out_be32(tbipa, tbiaddr);
+			if (tbiaddr == -1) {
+				err = -EBUSY;
+				goto err_free_irqs;
+			} else {
+				out_be32(tbipa, tbiaddr);
+			}
 		}
 	}
 
@@ -437,6 +442,9 @@ static struct of_device_id fsl_pq_mdio_match[] = {
 	{
 		.compatible = "fsl,etsec2-mdio",
 	},
+	{
+		.compatible = "fsl,fman-mdio",
+	},
 	{},
 };
 MODULE_DEVICE_TABLE(of, fsl_pq_mdio_match);
-- 
1.7.3.4
