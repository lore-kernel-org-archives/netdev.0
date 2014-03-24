From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH v2 2/2] net: davinci_emac: Fix rollback of emac_dev_open()
Date: Mon, 24 Mar 2014 13:46:27 +0100
Message-ID: <7c06cd07-529f-431c-96ef-f1cf925e21c1@mary.at.omicron.at>
References: <1395665187-24650-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	David Miller <davem@davemloft.net>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Jon Ringle <jon@ringle.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:41759 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154AbaCXMsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 08:48:02 -0400
In-Reply-To: <1395665187-24650-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an error occurs during the initialization in emac_dev_open() (the
driver's ndo_open function), interrupts, DMA descriptors etc. must be freed.
The current rollback code is buggy in several ways.

  1) Freeing the interrupts. The current code will not free all interrupts
     that were requested by the driver. Furthermore,  the code tries to do a
     platform_get_resource(priv->pdev, IORESOURCE_IRQ, -1) in its last
     iteration.

     This patch fixes these bugs.

  2) Wrong order of err: and rollback: labels. If the setup of the PHY in
     the code fails, the interrupts that have been requested before are
     not freed:

        request irq
                if requesting irqs fails, goto rollback
        setup phy
                if phy setup fails, goto err
        return 0

     rollback:
        free irqs
     err:

     This patch brings the code into the correct order.

  3) The code calls napi_enable() and emac_int_enable(), but does not
     undo both in case of an error.

     This patch adds calls of emac_int_disable() and napi_disable() to the
     rollback code.

  4) RX DMA descriptors are not freed in case of an error: Right before
     requesting the irqs, the function creates DMA descriptors for the
     RX channel. These RX descriptors are never freed when we jump to either
     rollback or err.

     This patch adds code for freeing the DMA descriptors in the case of
     an initialization error. This required a modification of
     cpdma_ctrl_stop() in davinci_cpdma.c: We must be able to call this
     function to free the DMA descriptors while the DMA channels are
     in IDLE state (before cpdma_ctlr_start() was called).

Tested on a custom board with the Texas Instruments AM1808.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
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
