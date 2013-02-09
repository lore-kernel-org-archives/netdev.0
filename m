From: Stefan Roese <sr@denx.de>
Subject: [PATCH RESEND] net: fec_mpc52xx: Read MAC address from device-tree
Date: Sat,  9 Feb 2013 10:49:12 +0100
Message-ID: <1360403352-24237-1-git-send-email-sr@denx.de>
Cc: linuxppc-dev@ozlabs.org, Anatolij Gustschin <agust@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:9136 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab3BIJt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 04:49:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, the MPC5200 FEC ethernet driver relied upon the bootloader
(U-Boot) to write the MAC address into the ethernet controller
registers. The Linux driver should not rely on such a thing. So
lets read the MAC address from the DT as it should be done here.

This fixes a problem with a MPC5200 board that uses the SPL U-Boot
version without FEC initialization before Linux booting for
boot speedup.

Additionally a status line will now be printed upon successful
driver probing, also displaying this MAC address.

Signed-off-by: Stefan Roese <sr@denx.de>
Cc: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/ethernet/freescale/fec_mpc52xx.c | 30 +++++++++++++++++-----------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 2933d08..f4c3897 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -110,15 +110,6 @@ static void mpc52xx_fec_set_paddr(struct net_device *dev, u8 *mac)
 	out_be32(&fec->paddr2, (*(u16 *)(&mac[4]) << 16) | FEC_PADDR2_TYPE);
 }
 
-static void mpc52xx_fec_get_paddr(struct net_device *dev, u8 *mac)
-{
-	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
-	struct mpc52xx_fec __iomem *fec = priv->fec;
-
-	*(u32 *)(&mac[0]) = in_be32(&fec->paddr1);
-	*(u16 *)(&mac[4]) = in_be32(&fec->paddr2) >> 16;
-}
-
 static int mpc52xx_fec_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sock = addr;
@@ -928,10 +919,22 @@ static int __devinit mpc52xx_fec_probe(struct platform_device *op)
 	priv->t_irq = bcom_get_task_irq(priv->tx_dmatsk);
 
 	/* MAC address init */
-	if (!is_zero_ether_addr(mpc52xx_fec_mac_addr))
+	if (!is_zero_ether_addr(mpc52xx_fec_mac_addr)) {
 		memcpy(ndev->dev_addr, mpc52xx_fec_mac_addr, 6);
-	else
-		mpc52xx_fec_get_paddr(ndev, ndev->dev_addr);
+	} else {
+		struct device_node *np = op->dev.of_node;
+		const void *p;
+
+		/* Read MAC-address */
+		p = of_get_property(np, "local-mac-address", NULL);
+		if (p == NULL) {
+			dev_err(&ndev->dev, "%s: Can't find local-mac-address property\n",
+				np->full_name);
+			rv = -ENXIO;
+			goto err_irq_dispose;
+		}
+		memcpy(ndev->dev_addr, p, 6);
+	}
 
 	priv->msg_enable = netif_msg_init(debug, MPC52xx_MESSAGES_DEFAULT);
 
@@ -970,11 +973,14 @@ static int __devinit mpc52xx_fec_probe(struct platform_device *op)
 
 	/* We're done ! */
 	dev_set_drvdata(&op->dev, ndev);
+	printk(KERN_INFO "%s: %s MAC %pM\n",
+	       ndev->name, op->dev.of_node->full_name, ndev->dev_addr);
 
 	return 0;
 
 err_node:
 	of_node_put(priv->phy_node);
+err_irq_dispose:
 	irq_dispose_mapping(ndev->irq);
 err_rx_tx_dmatsk:
 	if (priv->rx_dmatsk)
-- 
1.8.1.2
