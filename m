From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 3/3] atl1: Do not use legacy PCI power management
Date: Thu, 10 Feb 2011 17:55:19 +0100
Message-ID: <201102101755.19464.rjw@sisk.pl>
References: <201102101751.56508.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Linux PM mailing list <linux-pm@lists.linux-foundation.org>,
	Thomas Fjellstrom <thomas@fjellstrom.ca>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:33488 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756603Ab1BJQ4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 11:56:55 -0500
In-Reply-To: <201102101751.56508.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

The atl1 driver uses the legacy PCI power management, so it has to
do some PCI-specific things in its ->suspend() and ->resume()
callbacks, which isn't necessary and should better be done by the PCI
subsystem-level power management code.

Convert atl1 to the new PCI power management framework and make it
let the PCI subsystem take care of all the PCI-specific aspects of
device handling during system power transitions.

Tested-by: Thomas Fjellstrom <thomas@fjellstrom.ca>
Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/atlx/atl1.c |   77 +++++++++++++++++++-----------------------------
 1 file changed, 31 insertions(+), 46 deletions(-)

Index: linux-2.6/drivers/net/atlx/atl1.c
===================================================================
--- linux-2.6.orig/drivers/net/atlx/atl1.c
+++ linux-2.6/drivers/net/atlx/atl1.c
@@ -950,6 +950,7 @@ static int __devinit atl1_sw_init(struct
 	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	adapter->wol = 0;
+	device_set_wakeup_enable(&adapter->pdev->dev, false);
 	adapter->rx_buffer_len = (hw->max_frame_size + 7) & ~7;
 	adapter->ict = 50000;		/* 100ms */
 	adapter->link_speed = SPEED_0;	/* hardware init */
@@ -2735,15 +2736,15 @@ static int atl1_close(struct net_device
 }
 
 #ifdef CONFIG_PM
-static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
+static int atl1_suspend(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_hw *hw = &adapter->hw;
 	u32 ctrl = 0;
 	u32 wufc = adapter->wol;
 	u32 val;
-	int retval;
 	u16 speed;
 	u16 duplex;
 
@@ -2751,17 +2752,15 @@ static int atl1_suspend(struct pci_dev *
 	if (netif_running(netdev))
 		atl1_down(adapter);
 
-	retval = pci_save_state(pdev);
-	if (retval)
-		return retval;
-
 	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
 	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
 	val = ctrl & BMSR_LSTATUS;
 	if (val)
 		wufc &= ~ATLX_WUFC_LNKC;
+	if (!wufc)
+		goto disable_wol;
 
-	if (val && wufc) {
+	if (val) {
 		val = atl1_get_speed_and_duplex(hw, &speed, &duplex);
 		if (val) {
 			if (netif_msg_ifdown(adapter))
@@ -2798,23 +2797,18 @@ static int atl1_suspend(struct pci_dev *
 		ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
 		iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHYMISC);
 		ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
-
-		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
-		goto exit;
-	}
-
-	if (!val && wufc) {
+	} else {
 		ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
 		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
 		ioread32(hw->hw_addr + REG_WOL_CTRL);
 		iowrite32(0, hw->hw_addr + REG_MAC_CTRL);
 		ioread32(hw->hw_addr + REG_MAC_CTRL);
 		hw->phy_configured = false;
-		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
-		goto exit;
 	}
 
-disable_wol:
+	return 0;
+
+ disable_wol:
 	iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
 	ioread32(hw->hw_addr + REG_WOL_CTRL);
 	ctrl = ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
@@ -2822,37 +2816,17 @@ disable_wol:
 	iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHYMISC);
 	ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
 	hw->phy_configured = false;
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
-exit:
-	if (netif_running(netdev))
-		pci_disable_msi(adapter->pdev);
-	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
 }
 
-static int atl1_resume(struct pci_dev *pdev)
+static int atl1_resume(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter = netdev_priv(netdev);
-	u32 err;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-
-	err = pci_enable_device(pdev);
-	if (err) {
-		if (netif_msg_ifup(adapter))
-			dev_printk(KERN_DEBUG, &pdev->dev,
-				"error enabling pci device\n");
-		return err;
-	}
-
-	pci_set_master(pdev);
 	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	atl1_reset_hw(&adapter->hw);
 
@@ -2864,16 +2838,25 @@ static int atl1_resume(struct pci_dev *p
 
 	return 0;
 }
+
+static SIMPLE_DEV_PM_OPS(atl1_pm_ops, atl1_suspend, atl1_resume);
+#define ATL1_PM_OPS	(&atl1_pm_ops)
+
 #else
-#define atl1_suspend NULL
-#define atl1_resume NULL
+
+static int atl1_suspend(struct device *dev) { return 0; }
+
+#define ATL1_PM_OPS	NULL
 #endif
 
 static void atl1_shutdown(struct pci_dev *pdev)
 {
-#ifdef CONFIG_PM
-	atl1_suspend(pdev, PMSG_SUSPEND);
-#endif
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+
+	atl1_suspend(&pdev->dev);
+	pci_wake_from_d3(pdev, adapter->wol);
+	pci_set_power_state(pdev, PCI_D3hot);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3117,9 +3100,8 @@ static struct pci_driver atl1_driver = {
 	.id_table = atl1_pci_tbl,
 	.probe = atl1_probe,
 	.remove = __devexit_p(atl1_remove),
-	.suspend = atl1_suspend,
-	.resume = atl1_resume,
-	.shutdown = atl1_shutdown
+	.shutdown = atl1_shutdown,
+	.driver.pm = ATL1_PM_OPS,
 };
 
 /*
@@ -3409,6 +3391,9 @@ static int atl1_set_wol(struct net_devic
 	adapter->wol = 0;
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= ATLX_WUFC_MAG;
+
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+
 	return 0;
 }
 

