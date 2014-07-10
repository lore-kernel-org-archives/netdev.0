From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 05/11] net: bcmgenet: request Wake-on-LAN interrupt
Date: Thu, 10 Jul 2014 15:46:18 -0700
Message-ID: <1405032384-24006-6-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39651 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbaGJWqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:33 -0400
Received: by mail-ie0-f174.google.com with SMTP id rd18so234497iec.33
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:32 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attempt to the request the Wake-on-LAN interrupt bit, and if successful,
advertise wakeup capability instead of doing this unconditionnally.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 19 +++++++++++++++++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  2 ++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f810cddbcf58..d913139bf5f3 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1925,6 +1925,15 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t bcmgenet_wol_isr(int irq, void *dev_id)
+{
+	struct bcmgenet_priv *priv = dev_id;
+
+	pm_wakeup_event(&priv->pdev->dev, 0);
+
+	return IRQ_HANDLED;
+}
+
 static void bcmgenet_umac_reset(struct bcmgenet_priv *priv)
 {
 	u32 reg;
@@ -2059,8 +2068,6 @@ static int bcmgenet_open(struct net_device *dev)
 		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
 	}
 
-	device_set_wakeup_capable(&dev->dev, 1);
-
 	/* Disable RX/TX DMA and flush TX queues */
 	dma_ctrl = bcmgenet_dma_disable(priv);
 
@@ -2486,6 +2493,7 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	priv = netdev_priv(dev);
 	priv->irq0 = platform_get_irq(pdev, 0);
 	priv->irq1 = platform_get_irq(pdev, 1);
+	priv->wol_irq = platform_get_irq(pdev, 2);
 	if (!priv->irq0 || !priv->irq1) {
 		dev_err(&pdev->dev, "can't find IRQs\n");
 		err = -EINVAL;
@@ -2520,6 +2528,13 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	dev->hw_features |= NETIF_F_SG | NETIF_F_IP_CSUM |
 		NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
 
+	/* Request the WOL interrupt and advertise suspend if available */
+	priv->wol_irq_disabled = 1;
+	err = devm_request_irq(&pdev->dev, priv->wol_irq, bcmgenet_wol_isr, 0,
+			       dev->name, priv);
+	if (!err)
+		device_set_wakeup_capable(&pdev->dev, 1);
+
 	/* Set the needed headroom to account for any possible
 	 * features enabling/disabling at runtime
 	 */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index b3a5b49a7610..00a5e27ce0e5 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -569,6 +569,8 @@ struct bcmgenet_priv {
 	int irq1;
 	unsigned int irq0_stat;
 	unsigned int irq1_stat;
+	int wol_irq;
+	unsigned int wol_irq_disabled;
 
 	/* HW descriptors/checksum variables */
 	bool desc_64b_en;
-- 
1.9.1
