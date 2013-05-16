From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH 3/5] net: davinci: emac: Convert to devm_* api
Date: Thu, 16 May 2013 13:00:36 +0530
Message-ID: <1368689438-23889-4-git-send-email-prabhakar.csengg@gmail.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Use devm_ioremap_resource instead of devm_request_mem_region()/devm_ioremap()
and devm_request_irq() instead of request_irq().

This ensures more consistent error values and simplifies error paths.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   50 ++++++--------------------------
 1 files changed, 9 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 609f6d1..a8b5c6b 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1508,7 +1508,7 @@ static int emac_dev_open(struct net_device *ndev)
 	struct device *emac_dev = &ndev->dev;
 	u32 cnt;
 	struct resource *res;
-	int q, m, ret;
+	int ret;
 	int i = 0;
 	int k = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
@@ -1543,8 +1543,9 @@ static int emac_dev_open(struct net_device *ndev)
 
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
 		for (i = res->start; i <= res->end; i++) {
-			if (request_irq(i, emac_irq, IRQF_DISABLED,
-					ndev->name, ndev))
+			if (devm_request_irq(&priv->pdev->dev, i, emac_irq,
+					     IRQF_DISABLED,
+					     ndev->name, ndev))
 				goto rollback;
 		}
 		k++;
@@ -1617,15 +1618,7 @@ static int emac_dev_open(struct net_device *ndev)
 
 rollback:
 
-	dev_err(emac_dev, "DaVinci EMAC: request_irq() failed");
-
-	for (q = k; k >= 0; k--) {
-		for (m = i; m >= res->start; m--)
-			free_irq(m, ndev);
-		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
-		m = res->end;
-	}
-
+	dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
 	ret = -EBUSY;
 err:
 	pm_runtime_put(&priv->pdev->dev);
@@ -1643,9 +1636,6 @@ err:
  */
 static int emac_dev_stop(struct net_device *ndev)
 {
-	struct resource *res;
-	int i = 0;
-	int irq_num;
 	struct emac_priv *priv = netdev_priv(ndev);
 	struct device *emac_dev = &ndev->dev;
 
@@ -1661,13 +1651,6 @@ static int emac_dev_stop(struct net_device *ndev)
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
 
-	/* Free IRQ */
-	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, i))) {
-		for (irq_num = res->start; irq_num <= res->end; irq_num++)
-			free_irq(irq_num, priv->ndev);
-		i++;
-	}
-
 	if (netif_msg_drv(priv))
 		dev_notice(emac_dev, "DaVinci EMAC: %s stopped\n", ndev->name);
 
@@ -1832,7 +1815,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	struct resource *res;
 	struct net_device *ndev;
 	struct emac_priv *priv;
-	unsigned long size, hw_ram_addr;
+	unsigned long hw_ram_addr;
 	struct emac_platform_data *pdata;
 	struct device *emac_dev;
 	struct cpdma_params dma_params;
@@ -1883,25 +1866,10 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	emac_dev = &ndev->dev;
 	/* Get EMAC platform data */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res) {
-		dev_err(&pdev->dev,"error getting res\n");
-		rc = -ENOENT;
-		goto no_pdata;
-	}
-
-	priv->emac_base_phys = res->start + pdata->ctrl_reg_offset;
-	size = resource_size(res);
-	if (!devm_request_mem_region(&pdev->dev, res->start,
-				     size, ndev->name)) {
-		dev_err(&pdev->dev, "failed request_mem_region() for regs\n");
-		rc = -ENXIO;
-		goto no_pdata;
-	}
-
-	priv->remap_addr = devm_ioremap(&pdev->dev, res->start, size);
-	if (!priv->remap_addr) {
+	priv->remap_addr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(priv->remap_addr)) {
 		dev_err(&pdev->dev, "unable to map IO\n");
-		rc = -ENOMEM;
+		rc = PTR_ERR(priv->remap_addr);
 		goto no_pdata;
 	}
 	priv->emac_base = priv->remap_addr + pdata->ctrl_reg_offset;
-- 
1.7.4.1
