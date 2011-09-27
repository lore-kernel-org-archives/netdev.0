From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] skge: handle irq better on single port card
Date: Tue, 27 Sep 2011 10:25:23 -0700
Message-ID: <20110927102523.5f8b7f2a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49092 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928Ab1I0RZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 13:25:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most boards with SysKonnect/Marvell Ethernet have only a single port.
For the single port case, use the standard Ethernet driver convention
of allocating IRQ when device is brought up rather than at probe time.

This patch also adds some additional read after writes to avoid any
PCI posting problems when setting the IRQ mask.

The error handling of dual port cards is also changed.  If second port
can not be brought up, then just fail. No point in continuing, since
the failure is most certainly because of out of memory.

It is worth noting that the dual port skge device has a single irq but two
seperate status rings and therefore has two NAPI objects, one for
each port.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/skge.c	2011-09-27 08:46:08.893778800 -0700
+++ b/drivers/net/ethernet/marvell/skge.c	2011-09-27 10:23:37.557144935 -0700
@@ -113,6 +113,7 @@ static void yukon_init(struct skge_hw *h
 static void genesis_mac_init(struct skge_hw *hw, int port);
 static void genesis_link_up(struct skge_port *skge);
 static void skge_set_multicast(struct net_device *dev);
+static irqreturn_t skge_intr(int irq, void *dev_id);
 
 /* Avoid conditionals by using array */
 static const int txqaddr[] = { Q_XA1, Q_XA2 };
@@ -2568,6 +2569,16 @@ static int skge_up(struct net_device *de
 	if (err)
 		goto free_rx_ring;
 
+	if (hw->ports == 1) {
+		err = request_irq(hw->pdev->irq, skge_intr, IRQF_SHARED,
+				  dev->name, hw);
+		if (err) {
+			netdev_err(dev, "Unable to allocate interrupt %d error: %d\n",
+				   hw->pdev->irq, err);
+			goto free_tx_ring;
+		}
+	}
+
 	/* Initialize MAC */
 	spin_lock_bh(&hw->phy_lock);
 	if (is_genesis(hw))
@@ -2595,11 +2606,14 @@ static int skge_up(struct net_device *de
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= portmask[port];
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
 
 	napi_enable(&skge->napi);
 	return 0;
 
+ free_tx_ring:
+	kfree(skge->tx_ring.start);
  free_rx_ring:
 	skge_rx_clean(skge);
 	kfree(skge->rx_ring.start);
@@ -2640,9 +2654,13 @@ static int skge_down(struct net_device *
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask &= ~portmask[port];
-	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	skge_write32(hw, B0_IMSK, (hw->ports == 1) ? 0 : hw->intr_mask);
+	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
 
+	if (hw->ports == 1)
+		free_irq(hw->pdev->irq, hw);
+
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	if (is_genesis(hw))
 		genesis_stop(skge);
@@ -3603,7 +3621,8 @@ static int skge_reset(struct skge_hw *hw
 	skge_write32(hw, B2_IRQM_INI, skge_usecs2clk(hw, 100));
 	skge_write32(hw, B2_IRQM_CTRL, TIM_START);
 
-	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	/* Leave irq disabled until first port is brought up. */
+	skge_write32(hw, B0_IMSK, 0);
 
 	for (i = 0; i < hw->ports; i++) {
 		if (is_genesis(hw))
@@ -3930,31 +3949,39 @@ static int __devinit skge_probe(struct p
 		goto err_out_free_netdev;
 	}
 
-	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, hw->irq_name, hw);
-	if (err) {
-		dev_err(&pdev->dev, "%s: cannot assign irq %d\n",
-		       dev->name, pdev->irq);
-		goto err_out_unregister;
-	}
 	skge_show_addr(dev);
 
 	if (hw->ports > 1) {
 		dev1 = skge_devinit(hw, 1, using_dac);
-		if (dev1 && register_netdev(dev1) == 0)
-			skge_show_addr(dev1);
-		else {
-			/* Failure to register second port need not be fatal */
-			dev_warn(&pdev->dev, "register of second port failed\n");
-			hw->dev[1] = NULL;
-			hw->ports = 1;
-			if (dev1)
-				free_netdev(dev1);
+		if (!dev1) {
+			err = -ENOMEM;
+			goto err_out_unregister;
 		}
+
+		err = register_netdev(dev1);
+		if (err) {
+			dev_err(&pdev->dev, "cannot register second net device\n");
+			goto err_out_free_dev1;
+		}
+
+		err = request_irq(pdev->irq, skge_intr, IRQF_SHARED,
+				  hw->irq_name, hw);
+		if (err) {
+			dev_err(&pdev->dev, "cannot assign irq %d\n",
+				pdev->irq);
+			goto err_out_unregister_dev1;
+		}
+
+		skge_show_addr(dev1);
 	}
 	pci_set_drvdata(pdev, hw);
 
 	return 0;
 
+err_out_unregister_dev1:
+	unregister_netdev(dev1);
+err_out_free_dev1:
+	free_netdev(dev1);
 err_out_unregister:
 	unregister_netdev(dev);
 err_out_free_netdev:
@@ -3992,14 +4019,19 @@ static void __devexit skge_remove(struct
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask = 0;
-	skge_write32(hw, B0_IMSK, 0);
-	skge_read32(hw, B0_IMSK);
+
+	if (hw->ports > 1) {
+		skge_write32(hw, B0_IMSK, 0);
+		skge_read32(hw, B0_IMSK);
+		free_irq(pdev->irq, hw);
+	}
 	spin_unlock_irq(&hw->hw_lock);
 
 	skge_write16(hw, B0_LED, LED_STAT_OFF);
 	skge_write8(hw, B0_CTST, CS_RST_SET);
 
-	free_irq(pdev->irq, hw);
+	if (hw->ports > 1)
+		free_irq(pdev->irq, hw);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	if (dev1)
