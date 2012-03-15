From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 13/34] 8139cp: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:10 +0100
Message-ID: <bbff887735ffa951d9172c17b860ef7d4d79ca47.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51841 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760869Ab2CON7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:44 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/8139cp.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index abc7907..69c7d69 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -635,9 +635,12 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
  */
 static void cp_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	cp_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	struct cp_private *cp = netdev_priv(dev);
+	const int irq = cp->pdev->irq;
+
+	disable_irq(irq);
+	cp_interrupt(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
@@ -1114,6 +1117,7 @@ static void cp_free_rings (struct cp_private *cp)
 static int cp_open (struct net_device *dev)
 {
 	struct cp_private *cp = netdev_priv(dev);
+	const int irq = cp->pdev->irq;
 	int rc;
 
 	netif_dbg(cp, ifup, dev, "enabling interface\n");
@@ -1126,7 +1130,7 @@ static int cp_open (struct net_device *dev)
 
 	cp_init_hw(cp);
 
-	rc = request_irq(dev->irq, cp_interrupt, IRQF_SHARED, dev->name, dev);
+	rc = request_irq(irq, cp_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc)
 		goto err_out_hw;
 
@@ -1161,7 +1165,7 @@ static int cp_close (struct net_device *dev)
 
 	spin_unlock_irqrestore(&cp->lock, flags);
 
-	free_irq(dev->irq, dev);
+	free_irq(cp->pdev->irq, dev);
 
 	cp_free_rings(cp);
 	return 0;
@@ -1909,7 +1913,6 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 		       (unsigned long long)pciaddr);
 		goto err_out_res;
 	}
-	dev->base_addr = (unsigned long) regs;
 	cp->regs = regs;
 
 	cp_stop_hw(cp);
@@ -1937,14 +1940,12 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_HIGHDMA;
 
-	dev->irq = pdev->irq;
-
 	rc = register_netdev(dev);
 	if (rc)
 		goto err_out_iomap;
 
-	netdev_info(dev, "RTL-8139C+ at 0x%lx, %pM, IRQ %d\n",
-		    dev->base_addr, dev->dev_addr, dev->irq);
+	netdev_info(dev, "RTL-8139C+ at 0x%p, %pM, IRQ %d\n",
+		    regs, dev->dev_addr, pdev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
-- 
1.7.7.6
