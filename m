From: Laurent Navet <laurent.navet@gmail.com>
Subject: [PATCH] drivers: net: ethernet: broadcom: bcm63xx: use devm_ioremap_resource()
Date: Mon, 13 May 2013 15:53:01 +0200
Message-ID: <1368453181-6637-1-git-send-email-laurent.navet@gmail.com>
Cc: cernekee@gmail.com, sergei.shtylyov@cogentembedded.com,
	jogo@openwrt.org, joe@perches.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Laurent Navet <laurent.navet@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace calls to deprecated devm_request_and_ioremap by devm_ioremap_resource.
also remove tests on 'res' since devm_ioremap_resource() checks for it
in a better form.

Found with coccicheck and this semantic patch:
 scripts/coccinelle/api/devm_ioremap_resource.cocci

Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 0b3e23e..0497d0a 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1628,7 +1628,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	res_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	res_irq_rx = platform_get_resource(pdev, IORESOURCE_IRQ, 1);
 	res_irq_tx = platform_get_resource(pdev, IORESOURCE_IRQ, 2);
-	if (!res_mem || !res_irq || !res_irq_rx || !res_irq_tx)
+	if (!res_irq || !res_irq_rx || !res_irq_tx)
 		return -ENODEV;
 
 	ret = 0;
@@ -1641,9 +1641,9 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	if (ret)
 		goto out;
 
-	priv->base = devm_request_and_ioremap(&pdev->dev, res_mem);
-	if (priv->base == NULL) {
-		ret = -ENOMEM;
+	priv->base = devm_ioremap_resource(&pdev->dev, res_mem);
+	if (IS_ERR(priv->base)) {
+		ret = PTR_ERR(priv->base);
 		goto out;
 	}
 
@@ -1869,12 +1869,10 @@ static int bcm_enet_shared_probe(struct platform_device *pdev)
 	struct resource *res;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res)
-		return -ENODEV;
 
-	bcm_enet_shared_base = devm_request_and_ioremap(&pdev->dev, res);
-	if (!bcm_enet_shared_base)
-		return -ENOMEM;
+	bcm_enet_shared_base = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(bcm_enet_shared_base))
+		return PTR_ERR(bcm_enet_shared_base);
 
 	return 0;
 }
-- 
1.7.10.4
