From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH v2 1/1] drivers: net : cpsw: pass proper device name while requesting irq
Date: Fri, 13 Dec 2013 14:35:27 +0530
Message-ID: <1386925527-6706-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	George Cherian <george.cherian@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:54733 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab3LMJFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 04:05:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: George Cherian <george.cherian@ti.com>

During checking the interrupts with "cat /proc/interrupts", it is showing
device name as (null), this change was done with commit id aa1a15e2d where
request_irq is changed to devm_request_irq also changing the irq name from
platform device name to net device name, but the net device is not
registered at this point with the network frame work, so devm_request_irq
is called with device name as NULL, by which it is showed as "(null)" in
"cat /proc/interrupts". So this patch moved the devm_request_irq after
the net device register so that the device name shows as eth*.

Previous to this patch
root@am335x-evm:~# cat /proc/interrupts
           CPU0
 28:       2265      INTC  12  edma
 30:         80      INTC  14  edma_error
 44:        345      INTC  28  mmc1
 56:          0      INTC  40  (null)
 57:       1794      INTC  41  (null)
 58:          7      INTC  42  (null)
 59:          0      INTC  43  (null)

With this patch
root@am335x-evm:~# cat /proc/interrupts
           CPU0
 28:       2254      INTC  12  edma
 30:         69      INTC  14  edma_error
 44:        324      INTC  28  mmc1
 56:          0      INTC  40  eth0
 57:        271      INTC  41  eth0
 58:          7      INTC  42  eth0
 59:          0      INTC  43  eth0

Signed-off-by: George Cherian <george.cherian@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
Changes from Initial version
* Changed the commit message to hold more details of the commit changes
---
 drivers/net/ethernet/ti/cpsw.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5120d9c..d80dfce 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2103,19 +2103,6 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
-		for (i = res->start; i <= res->end; i++) {
-			if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
-					     dev_name(priv->dev), priv)) {
-				dev_err(priv->dev, "error attaching irq\n");
-				goto clean_ale_ret;
-			}
-			priv->irqs_table[k] = i;
-			priv->num_irqs = k + 1;
-		}
-		k++;
-	}
-
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
@@ -2131,6 +2118,19 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
+	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
+		for (i = res->start; i <= res->end; i++) {
+			if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
+					     dev_name(priv->dev), priv)) {
+				dev_err(priv->dev, "error attaching irq\n");
+				goto clean_ale_ret;
+			}
+			priv->irqs_table[k] = i;
+			priv->num_irqs = k + 1;
+		}
+		k++;
+	}
+
 	if (cpts_register(&pdev->dev, priv->cpts,
 			  data->cpts_clock_mult, data->cpts_clock_shift))
 		dev_err(priv->dev, "error registering cpts device\n");
-- 
1.8.5.1.93.g077f434
