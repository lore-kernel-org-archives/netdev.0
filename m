From: Sven Joachim <svenjoac@gmx.de>
Subject: sky2 driver breaks reboot/shutdown
Date: Wed, 16 Nov 2011 22:14:13 +0100
Message-ID: <878vnfpy6y.fsf@turtle.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Resending since my first attempt apparently did not make it to the
  mailing lists.  Apologies to anyone who receives duplicates. ]

Hi,

after upgrading from Linux 3.1 to 3.2-rc2 I noticed that the kernel
would no longer reboot or shutdown properly, hanging instead.  Removing
the sky2 driver works around this.  According to "lspci -v", I have the
following network card:

,----
| 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 13)
| 	Subsystem: ABIT Computer Corp. Device 108f
| 	Flags: bus master, fast devsel, latency 0, IRQ 17
| 	Memory at fdefc000 (64-bit, non-prefetchable) [size=16K]
| 	I/O ports at ce00 [size=256]
| 	[virtual] Expansion ROM at fdd00000 [disabled] [size=128K]
| 	Capabilities: <access denied>
| 	Kernel driver in use: sky2
`----

Bisecting shows 0bdb0bd01 as the first bad commit:


commit 0bdb0bd0139f3b6afa252de1487e3ce82a494db9
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Fri Sep 23 11:13:40 2011 +0000

    sky2: manage irq better on single port card
    
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
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index ef2dc02..338b10c 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -148,6 +148,7 @@ static const unsigned rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };
 
 static void sky2_set_multicast(struct net_device *dev);
+static irqreturn_t sky2_intr(int irq, void *dev_id);
 
 /* Access to PHY via serial interconnect */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
@@ -1715,6 +1716,27 @@ static void sky2_hw_up(struct sky2_port *sky2)
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
@@ -1730,6 +1752,10 @@ static int sky2_up(struct net_device *dev)
 	if (err)
 		goto err_out;
 
+	/* With single port, IRQ is setup when device is brought up */
+	if (hw->ports == 1 && (err = sky2_setup_irq(hw, dev->name)))
+		goto err_out;
+
 	sky2_hw_up(sky2);
 
 	/* Enable interrupts from phy/mac for port */
@@ -2091,8 +2117,13 @@ static int sky2_down(struct net_device *dev)
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
 
@@ -4798,7 +4829,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
-	struct net_device *dev;
+	struct net_device *dev, *dev1;
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
 	u32 reg;
@@ -4924,33 +4955,26 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
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
@@ -4961,6 +4985,10 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	return 0;
 
+err_out_unregister_dev1:
+	unregister_netdev(dev1);
+err_out_free_dev1:
+	free_netdev(dev1);
 err_out_unregister:
 	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
@@ -5000,13 +5028,18 @@ static void __devexit sky2_remove(struct pci_dev *pdev)
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


Kind Regards,
Sven
