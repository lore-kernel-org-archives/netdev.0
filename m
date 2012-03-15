From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 27/34] smsc9420: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:24 +0100
Message-ID: <4aba570ae9594788bffa6ad3b1f043e6f4fd1b9c.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51878 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761209Ab2CON7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:51 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device private data pointer can not be NULL in smsc9420_open().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/ethernet/smsc/smsc9420.c |   36 ++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 3838647..fa1489e 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -720,9 +720,12 @@ static irqreturn_t smsc9420_isr(int irq, void *dev_id)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void smsc9420_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	const int irq = pd->pdev->irq;
+
+	disable_irq(irq);
 	smsc9420_isr(0, dev);
-	enable_irq(dev->irq);
+	enable_irq(irq);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
@@ -759,7 +762,7 @@ static int smsc9420_stop(struct net_device *dev)
 	smsc9420_stop_rx(pd);
 	smsc9420_free_rx_ring(pd);
 
-	free_irq(dev->irq, pd);
+	free_irq(pd->pdev->irq, pd);
 
 	smsc9420_dmac_soft_reset(pd);
 
@@ -1331,15 +1334,12 @@ out:
 
 static int smsc9420_open(struct net_device *dev)
 {
-	struct smsc9420_pdata *pd;
+	struct smsc9420_pdata *pd = netdev_priv(dev);
 	u32 bus_mode, mac_cr, dmac_control, int_cfg, dma_intr_ena, int_ctl;
+	const int irq = pd->pdev->irq;
 	unsigned long flags;
 	int result = 0, timeout;
 
-	BUG_ON(!dev);
-	pd = netdev_priv(dev);
-	BUG_ON(!pd);
-
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		smsc_warn(IFUP, "dev_addr is not a valid MAC address");
 		result = -EADDRNOTAVAIL;
@@ -1358,10 +1358,10 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_reg_write(pd, INT_STAT, 0xFFFFFFFF);
 	smsc9420_pci_flush_write(pd);
 
-	if (request_irq(dev->irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
-			DRV_NAME, pd)) {
-		smsc_warn(IFUP, "Unable to use IRQ = %d", dev->irq);
-		result = -ENODEV;
+	result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
+			     DRV_NAME, pd);
+	if (result < 0) {
+		smsc_warn(IFUP, "Unable to use IRQ = %d", irq);
 		goto out_0;
 	}
 
@@ -1395,7 +1395,7 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_pci_flush_write(pd);
 
 	/* test the IRQ connection to the ISR */
-	smsc_dbg(IFUP, "Testing ISR using IRQ %d", dev->irq);
+	smsc_dbg(IFUP, "Testing ISR using IRQ %d", irq);
 	pd->software_irq_signal = false;
 
 	spin_lock_irqsave(&pd->int_lock, flags);
@@ -1430,7 +1430,7 @@ static int smsc9420_open(struct net_device *dev)
 		goto out_free_irq_1;
 	}
 
-	smsc_dbg(IFUP, "ISR passed test using IRQ %d", dev->irq);
+	smsc_dbg(IFUP, "ISR passed test using IRQ %d", irq);
 
 	result = smsc9420_alloc_tx_ring(pd);
 	if (result) {
@@ -1490,7 +1490,7 @@ out_free_rx_ring_3:
 out_free_tx_ring_2:
 	smsc9420_free_tx_ring(pd);
 out_free_irq_1:
-	free_irq(dev->irq, pd);
+	free_irq(irq, pd);
 out_0:
 	return result;
 }
@@ -1519,7 +1519,7 @@ static int smsc9420_suspend(struct pci_dev *pdev, pm_message_t state)
 		smsc9420_stop_rx(pd);
 		smsc9420_free_rx_ring(pd);
 
-		free_irq(dev->irq, pd);
+		free_irq(pd->pdev->irq, pd);
 
 		netif_device_detach(dev);
 	}
@@ -1552,6 +1552,7 @@ static int smsc9420_resume(struct pci_dev *pdev)
 		smsc_warn(IFUP, "pci_enable_wake failed: %d", err);
 
 	if (netif_running(dev)) {
+		/* FIXME: gross. It looks like ancient PM relic.*/
 		err = smsc9420_open(dev);
 		netif_device_attach(dev);
 	}
@@ -1625,8 +1626,6 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	/* registers are double mapped with 0 offset for LE and 0x200 for BE */
 	virt_addr += LAN9420_CPSR_ENDIAN_OFFSET;
 
-	dev->base_addr = (ulong)virt_addr;
-
 	pd = netdev_priv(dev);
 
 	/* pci descriptors are created in the PCI consistent area */
@@ -1669,7 +1668,6 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	dev->netdev_ops = &smsc9420_netdev_ops;
 	dev->ethtool_ops = &smsc9420_ethtool_ops;
-	dev->irq = pdev->irq;
 
 	netif_napi_add(dev, &pd->napi, smsc9420_rx_poll, NAPI_WEIGHT);
 
-- 
1.7.7.6
