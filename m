From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 07/26] et131x: kill copied PCI fields
Date: Tue, 25 Aug 2009 15:58:38 +0100
Message-ID: <20090825145825.16176.65849.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42589 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755089AbZHYPEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:04:00 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are all in the pcidev anyway plus are not used by the code

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_eeprom.c  |    2 +-
 drivers/staging/et131x/et1310_phy.c     |    2 +-
 drivers/staging/et131x/et131x_adapter.h |   13 -------------
 drivers/staging/et131x/et131x_config.c  |    3 ++-
 drivers/staging/et131x/et131x_initpci.c |   20 ++++----------------
 5 files changed, 8 insertions(+), 32 deletions(-)


diff --git a/drivers/staging/et131x/et1310_eeprom.c b/drivers/staging/et131x/et1310_eeprom.c
index 9a6dbd6..29d1c0e 100644
--- a/drivers/staging/et131x/et1310_eeprom.c
+++ b/drivers/staging/et131x/et1310_eeprom.c
@@ -292,7 +292,7 @@ int32_t EepromWriteByte(struct et131x_adapter *etdev, uint32_t unAddress,
 		 *	   so we do a blind write for load bug.
 		 */
 		if (bStatus & LBCIF_STATUS_GENERAL_ERROR
-		    && etdev->RevisionID == 0) {
+		    && etdev->pdev->revision == 0) {
 			break;
 		}
 
diff --git a/drivers/staging/et131x/et1310_phy.c b/drivers/staging/et131x/et1310_phy.c
index d9c7a44..63a23b9 100644
--- a/drivers/staging/et131x/et1310_phy.c
+++ b/drivers/staging/et131x/et1310_phy.c
@@ -841,7 +841,7 @@ void TPAL_SetPhyAutoNeg(struct et131x_adapter *etdev)
 
 	ET1310_PhyAdvertise100BaseT(etdev, TRUEPHY_ADV_DUPLEX_BOTH);
 
-	if (etdev->DeviceID != ET131X_PCI_DEVICE_ID_FAST)
+	if (etdev->pdev->device != ET131X_PCI_DEVICE_ID_FAST)
 		ET1310_PhyAdvertise1000BaseT(etdev, TRUEPHY_ADV_DUPLEX_FULL);
 	else
 		ET1310_PhyAdvertise1000BaseT(etdev, TRUEPHY_ADV_DUPLEX_NONE);
diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index df4a625..69509d7 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -250,19 +250,6 @@ struct et131x_adapter {
 	/* Pointer to the device's PCI register space */
 	ADDRESS_MAP_t __iomem *CSRAddress;
 
-	/* PCI config space info, for debug purposes only. */
-	u8 RevisionID;
-	u16 VendorID;
-	u16 DeviceID;
-	u16 SubVendorID;
-	u16 SubSystemID;
-	u32 CacheFillSize;
-	u16 PciXDevCtl;
-	u8 pci_lat_timer;
-	u8 pci_hdr_type;
-	u8 pci_bist;
-	u32 pci_cfg_state[64 / sizeof(u32)];
-
 	/* Registry parameters */
 	u8 SpeedDuplex;		/* speed/duplex */
 	eFLOW_CONTROL_t RegistryFlowControl;	/* for 802.3x flow control */
diff --git a/drivers/staging/et131x/et131x_config.c b/drivers/staging/et131x/et131x_config.c
index 148672b..499cf75 100644
--- a/drivers/staging/et131x/et131x_config.c
+++ b/drivers/staging/et131x/et131x_config.c
@@ -76,6 +76,7 @@
 #include <linux/delay.h>
 #include <linux/io.h>
 #include <linux/bitops.h>
+#include <linux/pci.h>
 #include <asm/system.h>
 
 #include <linux/netdevice.h>
@@ -288,7 +289,7 @@ void et131x_config_parse(struct et131x_adapter *etdev)
 	/* If we are the 10/100 device, and gigabit is somehow requested then
 	 * knock it down to 100 full.
 	 */
-	if (etdev->DeviceID == ET131X_PCI_DEVICE_ID_FAST &&
+	if (etdev->pdev->device == ET131X_PCI_DEVICE_ID_FAST &&
 	    etdev->SpeedDuplex == 5)
 		etdev->SpeedDuplex = 4;
 
diff --git a/drivers/staging/et131x/et131x_initpci.c b/drivers/staging/et131x/et131x_initpci.c
index d84b654..86bd55d 100644
--- a/drivers/staging/et131x/et131x_initpci.c
+++ b/drivers/staging/et131x/et131x_initpci.c
@@ -240,6 +240,7 @@ int et131x_find_adapter(struct et131x_adapter *adapter, struct pci_dev *pdev)
 	uint8_t eepromStat;
 	uint8_t maxPayload = 0;
 	uint8_t read_size_reg;
+	u8 rev;
 
 	DBG_ENTER(et131x_dbginfo);
 
@@ -283,15 +284,14 @@ int et131x_find_adapter(struct et131x_adapter *adapter, struct pci_dev *pdev)
 	 * present, we need to fail.
 	 */
 	if (eepromStat & 0x4C) {
-		result = pci_read_config_byte(pdev, PCI_REVISION_ID,
-					      &adapter->RevisionID);
+		result = pci_read_config_byte(pdev, PCI_REVISION_ID, &rev);
 		if (result != PCIBIOS_SUCCESSFUL) {
 			DBG_ERROR(et131x_dbginfo,
 				  "Could not read PCI config space for "
 				  "Revision ID\n");
 			DBG_LEAVE(et131x_dbginfo);
 			return -EIO;
-		} else if (adapter->RevisionID == 0x01) {
+		} else if (rev == 0x01) {
 			int32_t nLoop;
 			uint8_t ucTemp[4] = { 0xFE, 0x13, 0x10, 0xFF };
 
@@ -405,16 +405,6 @@ int et131x_find_adapter(struct et131x_adapter *adapter, struct pci_dev *pdev)
 		return -EIO;
 	}
 
-	/* PCI Express Configuration registers 0x48-0x5B (Device Control) */
-	result = pci_read_config_word(pdev, ET1310_PCI_DEV_CTRL,
-				      &adapter->PciXDevCtl);
-	if (result != PCIBIOS_SUCCESSFUL) {
-		DBG_ERROR(et131x_dbginfo,
-		  "Could not read PCI config space for PCI Express Dev Ctl\n");
-		DBG_LEAVE(et131x_dbginfo);
-		return -EIO;
-	}
-
 	/* Get MAC address from config space if an eeprom exists, otherwise
 	 * the MAC address there will not be valid
 	 */
@@ -556,7 +546,7 @@ int et131x_adapter_setup(struct et131x_adapter *etdev)
 	 * We need to turn off 1000 base half dulplex, the mac does not
 	 * support it. For the 10/100 part, turn off all gig advertisement
 	 */
-	if (etdev->DeviceID != ET131X_PCI_DEVICE_ID_FAST)
+	if (etdev->pdev->device != ET131X_PCI_DEVICE_ID_FAST)
 		ET1310_PhyAdvertise1000BaseT(etdev, TRUEPHY_ADV_DUPLEX_FULL);
 	else
 		ET1310_PhyAdvertise1000BaseT(etdev, TRUEPHY_ADV_DUPLEX_NONE);
@@ -890,8 +880,6 @@ int __devinit et131x_pci_setup(struct pci_dev *pdev,
 	adapter = netdev_priv(netdev);
 	adapter->pdev = pdev;
 	adapter->netdev = netdev;
-	adapter->VendorID = pdev->vendor;
-	adapter->DeviceID = pdev->device;
 
 	/* Do the same for the netdev struct */
 	netdev->irq = pdev->irq;

