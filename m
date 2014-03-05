From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH] net: davinci_emac: Replace devm_request_irq with request_irq
Date: Wed, 5 Mar 2014 11:25:28 +0100
Message-ID: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jon Ringle <jon@ringle.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:57844 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaCEK0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 05:26:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 6892b41d9701283085b655c6086fb57a5d63fa47

Author: Lad, Prabhakar <prabhakar.csengg@gmail.com>
Date:   Tue Jun 25 21:24:51 2013 +0530
net: davinci: emac: Convert to devm_* api

the call of request_irq is replaced by devm_request_irq and the call
of free_irq is removed. But since interrupts are requested in
emac_dev_open, doing ifconfig up/down on the board requests the
interrupts again each time, causing devm_request_irq to fail.

This patch reverts said commit partially: It changes the driver back
to use request_irq instead of devm_request_irq, puts free_irq back in
place, but keeps the remaining changes of the original patch.

Reported-by: Jon Ringle <jon@ringle.org>
Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
Cc: Lad, Prabhakar <prabhakar.csengg@gmail.com>
Cc: <stable@vger.kernel.org>
---
 drivers/net/ethernet/ti/davinci_emac.c |   25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index cd9b164..2514304 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1532,7 +1532,7 @@ static int emac_dev_open(struct net_device *ndev)
 	struct device *emac_dev = &ndev->dev;
 	u32 cnt;
 	struct resource *res;
-	int ret;
+	int q, m, ret;
 	int i = 0;
 	int k = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
@@ -1567,8 +1567,7 @@ static int emac_dev_open(struct net_device *ndev)
 
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
 		for (i = res->start; i <= res->end; i++) {
-			if (devm_request_irq(&priv->pdev->dev, i, emac_irq,
-					     0, ndev->name, ndev))
+			if (request_irq(i, emac_irq, 0, ndev->name, ndev))
 				goto rollback;
 		}
 		k++;
@@ -1641,7 +1640,15 @@ static int emac_dev_open(struct net_device *ndev)
 
 rollback:
 
-	dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
+	dev_err(emac_dev, "DaVinci EMAC: request_irq() failed");
+
+	for (q = k; k >= 0; k--) {
+		for (m = i; m >= res->start; m--)
+			free_irq(m, ndev);
+		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
+		m = res->end;
+	}
+
 	ret = -EBUSY;
 err:
 	pm_runtime_put(&priv->pdev->dev);
@@ -1659,6 +1666,9 @@ err:
  */
 static int emac_dev_stop(struct net_device *ndev)
 {
+	struct resource *res;
+	int i = 0;
+	int irq_num;
 	struct emac_priv *priv = netdev_priv(ndev);
 	struct device *emac_dev = &ndev->dev;
 
@@ -1674,6 +1684,13 @@ static int emac_dev_stop(struct net_device *ndev)
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
 
+	/* Free IRQ */
+	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, i))) {
+		for (irq_num = res->start; irq_num <= res->end; irq_num++)
+			free_irq(irq_num, priv->ndev);
+		i++;
+	}
+
 	if (netif_msg_drv(priv))
 		dev_notice(emac_dev, "DaVinci EMAC: %s stopped\n", ndev->name);
 
-- 
1.7.9.5
