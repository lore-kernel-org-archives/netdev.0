From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: systemport: Dynamically allocate number of TX rings
Date: Fri, 20 Jan 2017 11:08:26 -0800
Message-ID: <20170120190827.26444-2-f.fainelli@gmail.com>
References: <20170120190827.26444-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34061 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752590AbdATTIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:08:34 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so5947271pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 11:08:34 -0800 (PST)
In-Reply-To: <20170120190827.26444-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for adding SYSTEMPORT Lite, which has twice as less transmit
queues than SYSTEMPORT make sure we do allocate TX rings based on the
systemport,txq property to get an appropriate memory footprint.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 11 +++++++++++
 drivers/net/ethernet/broadcom/bcmsysport.h |  2 +-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 744ed6ddaf37..31bb2c3696ec 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1752,6 +1752,10 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	if (of_property_read_u32(dn, "systemport,num-rxq", &rxq))
 		rxq = 1;
 
+	/* Sanity check the number of transmit queues */
+	if (!txq || txq > TDMA_NUM_RINGS)
+		return -EINVAL;
+
 	dev = alloc_etherdev_mqs(sizeof(*priv), txq, rxq);
 	if (!dev)
 		return -ENOMEM;
@@ -1759,6 +1763,13 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	/* Initialize private members */
 	priv = netdev_priv(dev);
 
+	/* Allocate number of TX rings */
+	priv->tx_rings = devm_kcalloc(&pdev->dev, txq,
+				      sizeof(struct bcm_sysport_tx_ring),
+				      GFP_KERNEL);
+	if (!priv->tx_rings)
+		return -ENOMEM;
+
 	priv->irq0 = platform_get_irq(pdev, 0);
 	priv->irq1 = platform_get_irq(pdev, 1);
 	priv->wol_irq = platform_get_irq(pdev, 2);
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 1c82e3da69a7..f051356b0274 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -659,7 +659,7 @@ struct bcm_sysport_priv {
 	int			wol_irq;
 
 	/* Transmit rings */
-	struct bcm_sysport_tx_ring tx_rings[TDMA_NUM_RINGS];
+	struct bcm_sysport_tx_ring *tx_rings;
 
 	/* Receive queue */
 	void __iomem		*rx_bds;
-- 
2.11.0
