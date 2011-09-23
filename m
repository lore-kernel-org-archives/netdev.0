From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] sky2: manage irq better on single port card
Date: Fri, 23 Sep 2011 14:13:40 -0700
Message-ID: <20110923141340.39a8de91@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41903 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112Ab1IWVNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 17:13:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most sky2 hardware only has a single port, although some variations of the
chip support two interfaces.  For the single port case, use the standard
Ethernet driver convention of allocating IRQ when device is brought up
rather than at probe time.

Also, change the error handling of dual port cards so that if second
port can not be brought up, then just fail. No point in continuing, since
the failure is most certainly because of out of memory.

The dual port sky2 device has a single irq and a single status ring,
therefore it has a single NAPI object shared by both ports.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2011-09-22 21:59:11.371091630 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-09-23 13:40:42.627132176 -0700
@@ -148,6 +148,7 @@ static const unsigned rxqaddr[] = { Q_R1
 static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };
 
 static void sky2_set_multicast(struct net_device *dev);
+static irqreturn_t sky2_intr(int irq, void *dev_id);
 
 /* Access to PHY via serial interconnect */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
@@ -1715,6 +1716,27 @@ static void sky2_hw_up(struct sky2_port
 	sky2_rx_start(sky2);
 }
 
+/* Setup device IRQ and enable napi to process */
+static int sky2_setup_irq(struct sky2_hw *hw, const char *name)
+{
+	struct pci_dev *pdev = hw->pdev;
+	int err;
+
+	err = request_irq(pdev->irq, sky2_intr,
+			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
+			  name, hw);
+	if (err)
+		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
+	else {
+		napi_enable(&hw->napi);
+		sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+		sky2_read32(hw, B0_IMSK);
+	}
+
+	return err;
+}
+
+
 /* Bring up network interface. */
 static int sky2_up(struct net_device *dev)
 {
@@ -1730,6 +1752,10 @@ static int sky2_up(struct net_device *de
 	if (err)
 		goto err_out;
 
+	/* With single port, IRQ is setup when device is brought up */
+	if (hw->ports == 1 && (err = sky2_setup_irq(hw, dev->name)))
+		goto err_out;
+
 	sky2_hw_up(sky2);
 
 	/* Enable interrupts from phy/mac for port */
@@ -2091,8 +2117,13 @@ static int sky2_down(struct net_device *
 		     sky2_read32(hw, B0_IMSK) & ~portirq_msk[sky2->port]);
 	sky2_read32(hw, B0_IMSK);
 
-	synchronize_irq(hw->pdev->irq);
-	napi_synchronize(&hw->napi);
+	if (hw->ports == 1) {
+		napi_disable(&hw->napi);
+		free_irq(hw->pdev->irq, hw);
+	} else {
+		synchronize_irq(hw->pdev->irq);
+		napi_synchronize(&hw->napi);
+	}
 
 	sky2_hw_down(sky2);
 
@@ -4798,7 +4829,7 @@ static const char *sky2_name(u8 chipid,
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
-	struct net_device *dev;
+	struct net_device *dev, *dev1;
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
 	u32 reg;
@@ -4924,33 +4955,26 @@ static int __devinit sky2_probe(struct p
 
 	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
 
-	err = request_irq(pdev->irq, sky2_intr,
-			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
-			  hw->irq_name, hw);
-	if (err) {
-		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
-		goto err_out_unregister;
-	}
-	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
-	napi_enable(&hw->napi);
-
 	sky2_show_addr(dev);
 
 	if (hw->ports > 1) {
-		struct net_device *dev1;
-
-		err = -ENOMEM;
 		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
-		if (dev1 && (err = register_netdev(dev1)) == 0)
-			sky2_show_addr(dev1);
-		else {
-			dev_warn(&pdev->dev,
-				 "register of second port failed (%d)\n", err);
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
+		err = sky2_setup_irq(hw, hw->irq_name);
+		if (err)
+			goto err_out_unregister_dev1;
+
+		sky2_show_addr(dev1);
 	}
 
 	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
@@ -4961,6 +4985,10 @@ static int __devinit sky2_probe(struct p
 
 	return 0;
 
+err_out_unregister_dev1:
+	unregister_netdev(dev1);
+err_out_free_dev1:
+	free_netdev(dev1);
 err_out_unregister:
 	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
@@ -5000,13 +5028,18 @@ static void __devexit sky2_remove(struct
 		unregister_netdev(hw->dev[i]);
 
 	sky2_write32(hw, B0_IMSK, 0);
+	sky2_read32(hw, B0_IMSK);
 
 	sky2_power_aux(hw);
 
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
 	sky2_read8(hw, B0_CTST);
 
-	free_irq(pdev->irq, hw);
+	if (hw->ports > 1) {
+		napi_disable(&hw->napi);
+		free_irq(pdev->irq, hw);
+	}
+
 	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
 	pci_free_consistent(pdev, hw->st_size * sizeof(struct sky2_status_le),
