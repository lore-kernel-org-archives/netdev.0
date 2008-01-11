From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] sky2: remove check for PCI wakeup setting from BIOS
Date: Thu, 10 Jan 2008 16:14:13 -0800
Message-ID: <20080111001550.839028510@linux-foundation.org>
References: <20080111001411.158113585@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52653 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756190AbYAKDPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 22:15:33 -0500
Content-Disposition: inline; filename=sky2-remove-pci-check.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver checks status of PCI power management to mark 
default setting of Wake On Lan. On some systems this works, but often
it reports a that WOL is disabled when it isn't.

This patch gets rid of that check and just reports the wake on
lan status based on the hardware capablity.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please apply for 2.6.24.

--- a/drivers/net/sky2.c	2008-01-10 15:49:12.000000000 -0800
+++ b/drivers/net/sky2.c	2008-01-10 15:49:20.000000000 -0800
@@ -3946,7 +3946,7 @@ static __exit void sky2_debug_cleanup(vo
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port,
-						     int highmem, int wol)
+						     int highmem)
 {
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
@@ -3986,7 +3986,7 @@ static __devinit struct net_device *sky2
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
 	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
-	sky2->wol = wol;
+	sky2->wol = sky2_wol_supported(hw) & WAKE_MAGIC;
 
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
@@ -4083,24 +4083,12 @@ static int __devinit sky2_test_msi(struc
 	return err;
 }
 
-static int __devinit pci_wake_enabled(struct pci_dev *dev)
-{
-	int pm  = pci_find_capability(dev, PCI_CAP_ID_PM);
-	u16 value;
-
-	if (!pm)
-		return 0;
-	if (pci_read_config_word(dev, pm + PCI_PM_CTRL, &value))
-		return 0;
-	return value & PCI_PM_CTRL_PME_ENABLE;
-}
-
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct sky2_hw *hw;
-	int err, using_dac = 0, wol_default;
+	int err, using_dac = 0;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -4133,8 +4121,6 @@ static int __devinit sky2_probe(struct p
 		}
 	}
 
-	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
-
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
 	if (!hw) {
@@ -4178,7 +4164,7 @@ static int __devinit sky2_probe(struct p
 
 	sky2_reset(hw);
 
-	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
+	dev = sky2_init_netdev(hw, 0, using_dac);
 	if (!dev) {
 		err = -ENOMEM;
 		goto err_out_free_pci;
@@ -4215,7 +4201,7 @@ static int __devinit sky2_probe(struct p
 	if (hw->ports > 1) {
 		struct net_device *dev1;
 
-		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
+		dev1 = sky2_init_netdev(hw, 1, using_dac);
 		if (!dev1)
 			dev_warn(&pdev->dev, "allocation for second device failed\n");
 		else if ((err = register_netdev(dev1))) {

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

