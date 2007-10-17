From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] sky2: shutdown cleanup
Date: Wed, 17 Oct 2007 13:26:42 -0700
Message-ID: <20071017202653.340049500@linux-foundation.org>
References: <20071017202640.171902388@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39397 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278AbXJQU3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 16:29:06 -0400
Content-Disposition: inline; filename=sky2-shutdown-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Solve issues with dual port devices due to shared NAPI.
 * shutting down one device shouldn't kill other one.
 * suspend shouldn't hang.
Also fix potential race between restart and shutdown.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-10-17 10:17:56.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-17 13:12:06.000000000 -0700
@@ -1384,13 +1384,9 @@ static int sky2_up(struct net_device *de
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
 
-	napi_enable(&hw->napi);
-
 	err = sky2_rx_start(sky2);
-	if (err) {
-		napi_disable(&hw->napi);
+	if (err)
 		goto err_out;
-	}
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -1679,13 +1675,13 @@ static int sky2_down(struct net_device *
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
-	napi_disable(&hw->napi);
-
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
+	synchronize_irq(hw->pdev->irq);
+
 	sky2_gmac_reset(hw, port);
 
 	/* Stop transmitter */
@@ -1699,6 +1695,9 @@ static int sky2_down(struct net_device *
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
 
+	/* Make sure no packets are pending */
+	napi_synchronize(&hw->napi);
+
 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
 
 	/* Workaround shared GMAC reset */
@@ -1736,8 +1735,6 @@ static int sky2_down(struct net_device *
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
-	synchronize_irq(hw->pdev->irq);
-
 	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);
 
@@ -2048,9 +2045,6 @@ static int sky2_change_mtu(struct net_de
 	err = sky2_rx_start(sky2);
 	sky2_write32(hw, B0_IMSK, imask);
 
-	/* Unconditionally re-enable NAPI because even if we
-	 * call dev_close() that will do a napi_disable().
-	 */
 	napi_enable(&hw->napi);
 
 	if (err)
@@ -2915,6 +2909,7 @@ static void sky2_restart(struct work_str
 	rtnl_lock();
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
+	napi_disable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -2924,6 +2919,7 @@ static void sky2_restart(struct work_str
 
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+	napi_enable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -4191,7 +4187,6 @@ static int __devinit sky2_probe(struct p
 		err = -ENOMEM;
 		goto err_out_free_pci;
 	}
-	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
 
 	if (!disable_msi && pci_enable_msi(pdev) == 0) {
 		err = sky2_test_msi(hw);
@@ -4207,6 +4202,8 @@ static int __devinit sky2_probe(struct p
 		goto err_out_free_netdev;
 	}
 
+	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
+
 	err = request_irq(pdev->irq, sky2_intr,
 			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
 			  dev->name, hw);
@@ -4215,6 +4212,7 @@ static int __devinit sky2_probe(struct p
 		goto err_out_unregister;
 	}
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+	napi_enable(&hw->napi);
 
 	sky2_show_addr(dev);
 
@@ -4265,23 +4263,18 @@ err_out:
 static void __devexit sky2_remove(struct pci_dev *pdev)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	struct net_device *dev0, *dev1;
+	int i;
 
 	if (!hw)
 		return;
 
 	del_timer_sync(&hw->watchdog_timer);
+	cancel_work_sync(&hw->restart_work);
 
-	flush_scheduled_work();
+	for (i = hw->ports; i >= 0; --i)
+		unregister_netdev(hw->dev[i]);
 
 	sky2_write32(hw, B0_IMSK, 0);
-	synchronize_irq(hw->pdev->irq);
-
-	dev0 = hw->dev[0];
-	dev1 = hw->dev[1];
-	if (dev1)
-		unregister_netdev(dev1);
-	unregister_netdev(dev0);
 
 	sky2_power_aux(hw);
 
@@ -4296,9 +4289,9 @@ static void __devexit sky2_remove(struct
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 
-	if (dev1)
-		free_netdev(dev1);
-	free_netdev(dev0);
+	for (i = hw->ports; i >= 0; --i)
+		free_netdev(hw->dev[i]);
+
 	iounmap(hw->regs);
 	kfree(hw);
 
@@ -4328,6 +4321,7 @@ static int sky2_suspend(struct pci_dev *
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
+	napi_disable(&hw->napi);
 	sky2_power_aux(hw);
 
 	pci_save_state(pdev);
@@ -4362,8 +4356,8 @@ static int sky2_resume(struct pci_dev *p
 		pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
-
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+	napi_enable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

