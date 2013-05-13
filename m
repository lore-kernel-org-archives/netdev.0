From: Laurent Navet <laurent.navet@gmail.com>
Subject: [PATCH] net: ethernet: freescale: use devm_ioremap_resource()
Date: Mon, 13 May 2013 21:37:54 +0200
Message-ID: <1368473874-9569-1-git-send-email-laurent.navet@gmail.com>
Cc: Frank.Li@freescale.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Laurent Navet <laurent.navet@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace a call to deprecated devm_request_and_ioremap by devm_ioremap_resource.
also remove tests on 'r' since devm_ioremap_resource() checks for it
in a better way.

Found with coccicheck and this semantic patch:
 scripts/coccinelle/api/devm_ioremap_resource.cocci

Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index aff0310..0afc7ff 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1843,8 +1843,6 @@ fec_probe(struct platform_device *pdev)
 		pdev->id_entry = of_id->data;
 
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!r)
-		return -ENXIO;
 
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof(struct fec_enet_private));
@@ -1861,17 +1859,16 @@ fec_probe(struct platform_device *pdev)
 	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
 		fep->pause_flag |= FEC_PAUSE_FLAG_AUTONEG;
 
-	fep->hwp = devm_request_and_ioremap(&pdev->dev, r);
+	fep->hwp = devm_ioremap_resource(&pdev->dev, r);
+	if (IS_ERR(fep->hwp)) {
+		ret = PTR_ERR(fep->hwp);
+		goto failed_ioremap;
+	}
 	fep->pdev = pdev;
 	fep->dev_id = dev_id++;
 
 	fep->bufdesc_ex = 0;
 
-	if (!fep->hwp) {
-		ret = -ENOMEM;
-		goto failed_ioremap;
-	}
-
 	platform_set_drvdata(pdev, ndev);
 
 	ret = of_get_phy_mode(pdev->dev.of_node);
-- 
1.7.10.4
