From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: remove pcie workaround
Date: Wed, 11 Feb 2009 11:29:33 -0800
Message-ID: <1234380573-16903-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:53192 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757036AbZBKT3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 14:29:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove workaround for pcie bug in early revisions of NX3031
(rev 41 or earlier). This is taken care of during firmware init.

The workaround required writing pcie config reg of every
pcie function on a card, not all of which are enabled.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   64 ----------------------------------
 1 files changed, 0 insertions(+), 64 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 3b17a79..e02fe5a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -372,67 +372,6 @@ static void netxen_set_port_mode(struct netxen_adapter *adapter)
 	}
 }
 
-#define PCI_CAP_ID_GEN  0x10
-
-static void netxen_pcie_strap_init(struct netxen_adapter *adapter)
-{
-	u32 pdevfuncsave;
-	u32 c8c9value = 0;
-	u32 chicken = 0;
-	u32 control = 0;
-	int i, pos;
-	struct pci_dev *pdev;
-
-	pdev = adapter->pdev;
-
-	adapter->hw_read_wx(adapter,
-		NETXEN_PCIE_REG(PCIE_CHICKEN3), &chicken, 4);
-	/* clear chicken3.25:24 */
-	chicken &= 0xFCFFFFFF;
-	/*
-	 * if gen1 and B0, set F1020 - if gen 2, do nothing
-	 * if gen2 set to F1000
-	 */
-	pos = pci_find_capability(pdev, PCI_CAP_ID_GEN);
-	if (pos == 0xC0) {
-		pci_read_config_dword(pdev, pos + 0x10, &control);
-		if ((control & 0x000F0000) != 0x00020000) {
-			/*  set chicken3.24 if gen1 */
-			chicken |= 0x01000000;
-		}
-		printk(KERN_INFO "%s Gen2 strapping detected\n",
-				netxen_nic_driver_name);
-		c8c9value = 0xF1000;
-	} else {
-		/* set chicken3.24 if gen1 */
-		chicken |= 0x01000000;
-		printk(KERN_INFO "%s Gen1 strapping detected\n",
-				netxen_nic_driver_name);
-		if (adapter->ahw.revision_id == NX_P3_B0)
-			c8c9value = 0xF1020;
-		else
-			c8c9value = 0;
-
-	}
-	adapter->hw_write_wx(adapter,
-		NETXEN_PCIE_REG(PCIE_CHICKEN3), &chicken, 4);
-
-	if (!c8c9value)
-		return;
-
-	pdevfuncsave = pdev->devfn;
-	if (pdevfuncsave & 0x07)
-		return;
-
-	for (i = 0; i < 8; i++) {
-		pci_read_config_dword(pdev, pos + 8, &control);
-		pci_read_config_dword(pdev, pos + 8, &control);
-		pci_write_config_dword(pdev, pos + 8, c8c9value);
-		pdev->devfn++;
-	}
-	pdev->devfn = pdevfuncsave;
-}
-
 static void netxen_set_msix_bit(struct pci_dev *pdev, int enable)
 {
 	u32 control;
@@ -812,9 +751,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 		netxen_load_firmware(adapter);
 
-		if (NX_IS_REVISION_P3(revision_id))
-			netxen_pcie_strap_init(adapter);
-
 		if (NX_IS_REVISION_P2(revision_id)) {
 
 			/* Initialize multicast addr pool owners */
-- 
1.6.0.2

