From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] atl1c: Do not use legacy PCI power management
Date: Wed, 22 Dec 2010 14:07:52 +0100
Message-ID: <201012221407.52615.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:45872 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323Ab0LVNIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 08:08:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

The atl1c driver uses the legacy PCI power management, so it has to
do some PCI-specific things in its ->suspend() and ->resume()
callbacks and they are not done correctly.

Convert atl1c to the new PCI power management framework and make it
let the PCI subsystem handle all of the PCI-specific aspects of
device handling during system power transitions.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/atl1c/atl1c_main.c |   39 +++++++++++++++------------------------
 1 file changed, 15 insertions(+), 24 deletions(-)

Index: linux-2.6/drivers/net/atl1c/atl1c_main.c
===================================================================
--- linux-2.6.orig/drivers/net/atl1c/atl1c_main.c
+++ linux-2.6/drivers/net/atl1c/atl1c_main.c
@@ -702,6 +702,7 @@ static int __devinit atl1c_sw_init(struc
 
 
 	adapter->wol = 0;
+	device_set_wakeup_enable(&pdev->dev, false);
 	adapter->link_speed = SPEED_0;
 	adapter->link_duplex = FULL_DUPLEX;
 	adapter->num_rx_queues = AT_DEF_RECEIVE_QUEUE;
@@ -2444,8 +2445,9 @@ static int atl1c_close(struct net_device
 	return 0;
 }
 
-static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
+static int atl1c_suspend(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct atl1c_hw *hw = &adapter->hw;
@@ -2454,7 +2456,6 @@ static int atl1c_suspend(struct pci_dev
 	u32 wol_ctrl_data = 0;
 	u16 mii_intr_status_data = 0;
 	u32 wufc = adapter->wol;
-	int retval = 0;
 
 	atl1c_disable_l0s_l1(hw);
 	if (netif_running(netdev)) {
@@ -2462,9 +2463,6 @@ static int atl1c_suspend(struct pci_dev
 		atl1c_down(adapter);
 	}
 	netif_device_detach(netdev);
-	retval = pci_save_state(pdev);
-	if (retval)
-		return retval;
 
 	if (wufc)
 		if (atl1c_phy_power_saving(hw) != 0)
@@ -2525,12 +2523,8 @@ static int atl1c_suspend(struct pci_dev
 		AT_WRITE_REG(hw, REG_WOL_CTRL, wol_ctrl_data);
 		AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
 
-		/* pcie patch */
-		device_set_wakeup_enable(&pdev->dev, 1);
-
 		AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_DEFAULT |
 			GPHY_CTRL_EXT_RESET);
-		pci_prepare_to_sleep(pdev);
 	} else {
 		AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_POWER_SAVING);
 		master_ctrl_data |= MASTER_CTRL_CLK_SEL_DIS;
@@ -2540,25 +2534,17 @@ static int atl1c_suspend(struct pci_dev
 		AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
 		AT_WRITE_REG(hw, REG_WOL_CTRL, 0);
 		hw->phy_configured = false; /* re-init PHY when resume */
-		pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
 	}
 
-	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
 	return 0;
 }
 
-static int atl1c_resume(struct pci_dev *pdev)
+static int atl1c_resume(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
 	AT_WRITE_REG(&adapter->hw, REG_WOL_CTRL, 0);
 	atl1c_reset_pcie(&adapter->hw, ATL1C_PCIE_L0S_L1_DISABLE |
 			ATL1C_PCIE_PHY_RESET);
@@ -2582,7 +2568,12 @@ static int atl1c_resume(struct pci_dev *
 
 static void atl1c_shutdown(struct pci_dev *pdev)
 {
-	atl1c_suspend(pdev, PMSG_SUSPEND);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct atl1c_adapter *adapter = netdev_priv(netdev);
+
+	atl1c_suspend(&pdev->dev);
+	pci_wake_from_d3(pdev, adapter->wol);
+	pci_set_power_state(pdev, PCI_D3hot);
 }
 
 static const struct net_device_ops atl1c_netdev_ops = {
@@ -2886,16 +2877,16 @@ static struct pci_error_handlers atl1c_e
 	.resume = atl1c_io_resume,
 };
 
+static SIMPLE_DEV_PM_OPS(atl1c_pm_ops, atl1c_suspend, atl1c_resume);
+
 static struct pci_driver atl1c_driver = {
 	.name     = atl1c_driver_name,
 	.id_table = atl1c_pci_tbl,
 	.probe    = atl1c_probe,
 	.remove   = __devexit_p(atl1c_remove),
-	/* Power Managment Hooks */
-	.suspend  = atl1c_suspend,
-	.resume   = atl1c_resume,
 	.shutdown = atl1c_shutdown,
-	.err_handler = &atl1c_err_handler
+	.err_handler = &atl1c_err_handler,
+	.driver.pm = &atl1c_pm_ops,
 };
 
 /*
