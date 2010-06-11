From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 1/7] ethoc: calculate number of buffers in ethoc_probe
Date: Fri, 11 Jun 2010 14:47:34 +0200
Message-ID: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:49424 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756059Ab0FKMrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:47:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the calculation of the number of transmission buffers to
ethoc_probe where it more logically fits with the rest of the memory
allocation code.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6ed2df1..68093cf 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -658,8 +658,6 @@ static int ethoc_mdio_probe(struct net_device *dev)
 static int ethoc_open(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
-	unsigned int min_tx = 2;
-	unsigned int num_bd;
 	int ret;
 
 	ret = request_irq(dev->irq, ethoc_interrupt, IRQF_SHARED,
@@ -667,11 +665,6 @@ static int ethoc_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	/* calculate the number of TX/RX buffers, maximum 128 supported */
-	num_bd = min_t(unsigned int,
-		128, (dev->mem_end - dev->mem_start + 1) / ETHOC_BUFSIZ);
-	priv->num_tx = max(min_tx, num_bd / 4);
-	priv->num_rx = num_bd - priv->num_tx;
 	ethoc_write(priv, TX_BD_NUM, priv->num_tx);
 
 	ethoc_init_ring(priv);
@@ -884,6 +877,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	struct resource *mem = NULL;
 	struct ethoc *priv = NULL;
 	unsigned int phy;
+	int num_bd;
 	int ret = 0;
 
 	/* allocate networking device */
@@ -978,6 +972,12 @@ static int ethoc_probe(struct platform_device *pdev)
 		priv->dma_alloc = buffer_size;
 	}
 
+	/* calculate the number of TX/RX buffers, maximum 128 supported */
+	num_bd = min_t(unsigned int,
+		128, (netdev->mem_end - netdev->mem_start + 1) / ETHOC_BUFSIZ);
+	priv->num_tx = max(2, num_bd / 4);
+	priv->num_rx = num_bd - priv->num_tx;
+
 	/* Allow the platform setup code to pass in a MAC address. */
 	if (pdev->dev.platform_data) {
 		struct ethoc_platform_data *pdata =
-- 
1.7.0.4

