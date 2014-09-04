From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH] net: ethernet: cpsw: improve interrupt lookup logic in cpsw_probe()
Date: Thu,  4 Sep 2014 09:00:23 +0200
Message-ID: <1409814023-10189-1-git-send-email-daniel@zonque.org>
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org, mugunthanvnm@ti.com,
	george.cherian@ti.com, Daniel Mack <zonque@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:59776 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbaIDHAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 03:00:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>

Simplify the interrupt resource lookup code in cpsw_probe() by the
following:

 * Only look at the first member of the resource. As the driver only
   works for DT-enabled platforms anyway, a resource of type
   IORESOURCE_IRQ will only contain one single entry
   (res->start == res->end), so there is no need for the iteration.

 * Add a bounds check to avoid overflows if we are passed more than
   ARRAY_SIZE(priv->irqs_table) resources.

 * Assign 'ret' with the return value of devm_request_irq() so that
   cpsw_probe() returns the appropriate error code.

 * If devm_request_irq() fails, report the error code in the log
   message.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 999fb72..03b4099 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2232,18 +2232,24 @@ static int cpsw_probe(struct platform_device *pdev)
 	}
 
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
-		for (i = res->start; i <= res->end; i++) {
-			if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
-					     dev_name(&pdev->dev), priv)) {
-				dev_err(priv->dev, "error attaching irq\n");
-				goto clean_ale_ret;
-			}
-			priv->irqs_table[k] = i;
-			priv->num_irqs = k + 1;
+		if (k >= ARRAY_SIZE(priv->irqs_table)) {
+			ret = -EINVAL;
+			goto clean_ale_ret;
 		}
+
+		ret = devm_request_irq(&pdev->dev, res->start, cpsw_interrupt,
+				       0, dev_name(&pdev->dev), priv);
+		if (ret < 0) {
+			dev_err(priv->dev, "error attaching irq (%d)\n", ret);
+			goto clean_ale_ret;
+		}
+
+		priv->irqs_table[k] = res->start;
 		k++;
 	}
 
+	priv->num_irqs = k;
+
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
-- 
2.1.0
