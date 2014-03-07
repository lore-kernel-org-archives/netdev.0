From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH RFC] net: davinci_emac: Fix rollback of emac_dev_open()
Date: Fri, 7 Mar 2014 15:07:37 +0100
Message-ID: <130fa9cb-7e94-4698-ac3f-f987a03c0604@mary.at.omicron.at>
References: <35CC5396F7326DBE44C9C624@[172.22.2.41]>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jon Ringle <jon@ringle.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:43873 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930AbaCGOI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 09:08:58 -0500
In-Reply-To: <35CC5396F7326DBE44C9C624@[172.22.2.41]>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
Cc: Prabhakar Lad <prabhakar.csengg@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
---

Hi again,

How about this solution for fixing the rollback of emac_dev_open()?
Especially the change in davinci_cpdma.c, would this break anything?

The patch applies on top of 
[PATCH] net: davinci_emac: Replace devm_request_irq with request_irq

Regards,
Christian

 drivers/net/ethernet/ti/davinci_cpdma.c |    4 +--
 drivers/net/ethernet/ti/davinci_emac.c  |   44 ++++++++++++++++++++-----------
 2 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 364d0c7..88ef270 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -355,7 +355,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
 	int i;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
-	if (ctlr->state != CPDMA_STATE_ACTIVE) {
+	if (ctlr->state == CPDMA_STATE_TEARDOWN) {
 		spin_unlock_irqrestore(&ctlr->lock, flags);
 		return -EINVAL;
 	}
@@ -891,7 +891,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	unsigned		timeout;
 
 	spin_lock_irqsave(&chan->lock, flags);
-	if (chan->state != CPDMA_STATE_ACTIVE) {
+	if (chan->state == CPDMA_STATE_TEARDOWN) {
 		spin_unlock_irqrestore(&chan->lock, flags);
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 2514304..8f0e69c 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1533,8 +1533,8 @@ static int emac_dev_open(struct net_device *ndev)
 	u32 cnt;
 	struct resource *res;
 	int q, m, ret;
+	int res_num = 0, irq_num = 0;
 	int i = 0;
-	int k = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
 
 	pm_runtime_get(&priv->pdev->dev);
@@ -1564,14 +1564,24 @@ static int emac_dev_open(struct net_device *ndev)
 	}
 
 	/* Request IRQ */
+	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ,
+					    res_num))) {
+		for (irq_num = res->start; irq_num <= res->end; irq_num++) {
+			dev_err(emac_dev, "Request IRQ %d\n", irq_num);
+			if (request_irq(irq_num, emac_irq, 0, ndev->name,
+					ndev)) {
+				dev_err(emac_dev,
+					"DaVinci EMAC: request_irq() failed\n");
+				ret = -EBUSY;
 
-	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
-		for (i = res->start; i <= res->end; i++) {
-			if (request_irq(i, emac_irq, 0, ndev->name, ndev))
 				goto rollback;
+			}
 		}
-		k++;
+		res_num++;
 	}
+	/* prepare counters for rollback in case of an error */
+	res_num--;
+	irq_num--;
 
 	/* Start/Enable EMAC hardware */
 	emac_hw_enable(priv);
@@ -1638,19 +1648,23 @@ static int emac_dev_open(struct net_device *ndev)
 
 	return 0;
 
-rollback:
-
-	dev_err(emac_dev, "DaVinci EMAC: request_irq() failed");
+err:
+	emac_int_disable(priv);
+	napi_disable(&priv->napi);
 
-	for (q = k; k >= 0; k--) {
-		for (m = i; m >= res->start; m--)
+rollback:
+	for (q = res_num; q >= 0; q--) {
+		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, q);
+		/* at the first iteration, irq_num is already set to the
+		 * right value
+		 */
+		if (q != res_num)
+			irq_num = res->end;
+
+		for (m = irq_num; m >= res->start; m--)
 			free_irq(m, ndev);
-		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
-		m = res->end;
 	}
-
-	ret = -EBUSY;
-err:
+	cpdma_ctlr_stop(priv->dma);
 	pm_runtime_put(&priv->pdev->dev);
 	return ret;
 }
-- 
1.7.9.5
