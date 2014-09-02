From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 1/2] net: ethernet: cpsw: don't claim IRQs with devm_request_irq()
Date: Tue,  2 Sep 2014 18:44:04 +0200
Message-ID: <1409676245-13897-1-git-send-email-zonque@gmail.com>
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org, mugunthanvnm@ti.com,
	george.cherian@ti.com, Daniel Mack <zonque@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:46717 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbaIBQoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:44:14 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so14688741wib.4
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 09:44:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall spotted a problem with aa1a15e ("net: ethernet: cpsw:
switch to devres allocations") which introduced a race condition in
cpsw_probe() by removing explicit interrupt disable calls before
calling free_netdev(). Hence, an interrupt can fire after free_netdev()
was called. The same problem exists in cpsw_remove().

Fix this by reverting the IRQ part of the aforementioned patch and
handle those resources explicitly.

Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 999fb72..cdbbb58 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2233,10 +2233,10 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
 		for (i = res->start; i <= res->end; i++) {
-			if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
-					     dev_name(&pdev->dev), priv)) {
+			if (request_irq(i, cpsw_interrupt, 0,
+					dev_name(&pdev->dev), priv)) {
 				dev_err(priv->dev, "error attaching irq\n");
-				goto clean_ale_ret;
+				goto clean_irq_ret;
 			}
 			priv->irqs_table[k] = i;
 			priv->num_irqs = k + 1;
@@ -2256,7 +2256,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (ret) {
 		dev_err(priv->dev, "error registering net device\n");
 		ret = -ENODEV;
-		goto clean_ale_ret;
+		goto clean_irq_ret;
 	}
 
 	cpsw_notice(priv, probe, "initialized device (regs %pa, irq %d)\n",
@@ -2266,12 +2266,15 @@ static int cpsw_probe(struct platform_device *pdev)
 		ret = cpsw_probe_dual_emac(pdev, priv);
 		if (ret) {
 			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
-			goto clean_ale_ret;
+			goto clean_irq_ret;
 		}
 	}
 
 	return 0;
 
+clean_irq_ret:
+	for (i = 0; i < priv->num_irqs; i++)
+		free_irq(priv->irqs_table[i], priv);
 clean_ale_ret:
 	cpsw_ale_destroy(priv->ale);
 clean_dma_ret:
@@ -2289,11 +2292,15 @@ static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	int i;
 
 	if (priv->data.dual_emac)
 		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
 	unregister_netdev(ndev);
 
+	for (i = 0; i < priv->num_irqs; i++)
+		free_irq(priv->irqs_table[i], priv);
+
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
 	cpdma_chan_destroy(priv->rxch);
-- 
2.1.0
