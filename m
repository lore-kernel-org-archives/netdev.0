From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 19/26] et131x: eeprom remove features
Date: Tue, 25 Aug 2009 16:00:33 +0100
Message-ID: <20090825150028.16176.61990.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47815 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755359AbZHYPFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:05:55 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only read eeprom id 0, in byte mode - so the rest can go away

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_eeprom.c  |   20 ++------------------
 drivers/staging/et131x/et1310_eeprom.h  |   16 ++--------------
 drivers/staging/et131x/et131x_config.c  |    0 
 drivers/staging/et131x/et131x_initpci.c |    7 +++----
 4 files changed, 7 insertions(+), 36 deletions(-)
 delete mode 100644 drivers/staging/et131x/et131x_config.c


diff --git a/drivers/staging/et131x/et1310_eeprom.c b/drivers/staging/et131x/et1310_eeprom.c
index 9453862..7b2e4ea 100644
--- a/drivers/staging/et131x/et1310_eeprom.c
+++ b/drivers/staging/et131x/et1310_eeprom.c
@@ -146,14 +146,10 @@
  * @etdev: pointer to our private adapter structure
  * @addr: the address to write
  * @data: the value to write
- * @eeprom_id: the ID of the EEPROM
- * @addrmode: how the EEPROM is to be accessed
  *
  * Returns SUCCESS or FAILURE
  */
-int EepromWriteByte(struct et131x_adapter *etdev, u32 addr,
-			u8 data, u32 eeprom_id,
-			u32 addrmode)
+int EepromWriteByte(struct et131x_adapter *etdev, u32 addr, u8 data)
 {
 	struct pci_dev *pdev = etdev->pdev;
 	int index;
@@ -238,9 +234,6 @@ int EepromWriteByte(struct et131x_adapter *etdev, u32 addr,
 	control = 0;
 	control |= LBCIF_CONTROL_LBCIF_ENABLE | LBCIF_CONTROL_I2C_WRITE;
 
-	if (addrmode == DUAL_BYTE)
-		control |= LBCIF_CONTROL_TWO_BYTE_ADDR;
-
 	if (pci_write_config_byte(pdev, LBCIF_CONTROL_REGISTER_OFFSET,
 				  control)) {
 		return FAILURE;
@@ -249,8 +242,6 @@ int EepromWriteByte(struct et131x_adapter *etdev, u32 addr,
 	i2c_wack = 1;
 
 	/* Prepare EEPROM address for Step 3 */
-	addr |= (addrmode == DUAL_BYTE) ?
-	    (eeprom_id << 16) : (eeprom_id << 8);
 
 	for (retries = 0; retries < MAX_NUM_WRITE_RETRIES; retries++) {
 		/* Step 3:*/
@@ -357,9 +348,7 @@ int EepromWriteByte(struct et131x_adapter *etdev, u32 addr,
  *
  * Returns SUCCESS or FAILURE
  */
-int EepromReadByte(struct et131x_adapter *etdev, u32 addr,
-		       u8 *pdata, u32 eeprom_id,
-		       u32 addrmode)
+int EepromReadByte(struct et131x_adapter *etdev, u32 addr, u8 *pdata)
 {
 	struct pci_dev *pdev = etdev->pdev;
 	int index;
@@ -427,17 +416,12 @@ int EepromReadByte(struct et131x_adapter *etdev, u32 addr,
 	control = 0;
 	control |= LBCIF_CONTROL_LBCIF_ENABLE;
 
-	if (addrmode == DUAL_BYTE)
-		control |= LBCIF_CONTROL_TWO_BYTE_ADDR;
-
 	if (pci_write_config_byte(pdev, LBCIF_CONTROL_REGISTER_OFFSET,
 				  control)) {
 		return FAILURE;
 	}
 
 	/* Step 3: */
-	addr |= (addrmode == DUAL_BYTE) ?
-	    (eeprom_id << 16) : (eeprom_id << 8);
 
 	if (pci_write_config_dword(pdev, LBCIF_ADDRESS_REGISTER_OFFSET,
 				   addr)) {
diff --git a/drivers/staging/et131x/et1310_eeprom.h b/drivers/staging/et131x/et1310_eeprom.h
index 8033743..d8ac9a0 100644
--- a/drivers/staging/et131x/et1310_eeprom.h
+++ b/drivers/staging/et131x/et1310_eeprom.h
@@ -66,24 +66,12 @@
 #define FAILURE		1
 #endif
 
-#ifndef READ
-#define READ		0
-#define WRITE		1
-#endif
-
-#ifndef SINGLE_BYTE
-#define SINGLE_BYTE	0
-#define DUAL_BYTE	1
-#endif
-
 /* Forward declaration of the private adapter structure */
 struct et131x_adapter;
 
 int32_t EepromWriteByte(struct et131x_adapter *adapter, u32 unAddress,
-			u8 bData, u32 unEepromId,
-			u32 unAddressingMode);
+			u8 bData);
 int32_t EepromReadByte(struct et131x_adapter *adapter, u32 unAddress,
-		       u8 *pbData, u32 unEepromId,
-		       u32 unAddressingMode);
+			u8 *pbData);
 
 #endif /* _ET1310_EEPROM_H_ */
diff --git a/drivers/staging/et131x/et131x_config.c b/drivers/staging/et131x/et131x_config.c
deleted file mode 100644
index e69de29..0000000
diff --git a/drivers/staging/et131x/et131x_initpci.c b/drivers/staging/et131x/et131x_initpci.c
index a719e90..bea9918 100644
--- a/drivers/staging/et131x/et131x_initpci.c
+++ b/drivers/staging/et131x/et131x_initpci.c
@@ -337,8 +337,7 @@ int et131x_find_adapter(struct et131x_adapter *adapter, struct pci_dev *pdev)
 			 * corruption seen with 1310 B Silicon
 			 */
 			for (nLoop = 0; nLoop < 3; nLoop++) {
-				EepromWriteByte(adapter, nLoop, temp[nLoop],
-						0, SINGLE_BYTE);
+				EepromWriteByte(adapter, nLoop, temp[nLoop]);
 			}
 		}
 
@@ -364,8 +363,8 @@ int et131x_find_adapter(struct et131x_adapter *adapter, struct pci_dev *pdev)
 	/* Read the EEPROM for information regarding LED behavior. Refer to
 	 * ET1310_phy.c, et131x_xcvr_init(), for its use.
 	 */
-	EepromReadByte(adapter, 0x70, &adapter->eepromData[0], 0, SINGLE_BYTE);
-	EepromReadByte(adapter, 0x71, &adapter->eepromData[1], 0, SINGLE_BYTE);
+	EepromReadByte(adapter, 0x70, &adapter->eepromData[0]);
+	EepromReadByte(adapter, 0x71, &adapter->eepromData[1]);
 
 	if (adapter->eepromData[0] != 0xcd)
 		/* Disable all optional features */

