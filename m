From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 27/27] igb: Add new function to read part number from EEPROM in string format
Date: Fri, 10 Dec 2010 22:20:40 -0800
Message-ID: <1292048440-22125-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048440-22125-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:34345 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751914Ab0LKGUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:20:52 -0500
To: davem@davemloft.net
In-Reply-To: <1292048440-22125-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

New adapters will have part numbers stored in string format rather than
simple hex format. This function will read part number formats in either
hex or string.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_defines.h |    7 +++
 drivers/net/igb/e1000_nvm.c     |   93 ++++++++++++++++++++++++++++++++++++---
 drivers/net/igb/e1000_nvm.h     |    2 +
 drivers/net/igb/igb_main.c      |   11 +++--
 4 files changed, 102 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 6222279..6319ed9 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -419,6 +419,9 @@
 #define E1000_ERR_SWFW_SYNC 13
 #define E1000_NOT_IMPLEMENTED 14
 #define E1000_ERR_MBX      15
+#define E1000_ERR_INVALID_ARGUMENT  16
+#define E1000_ERR_NO_SPACE          17
+#define E1000_ERR_NVM_PBA_SECTION   18
 
 /* Loop limit on how long we wait for auto-negotiation to complete */
 #define COPPER_LINK_UP_LIMIT              10
@@ -580,11 +583,15 @@
 
 /* Mask bits for fields in Word 0x1a of the NVM */
 
+/* length of string needed to store part num */
+#define E1000_PBANUM_LENGTH         11
+
 /* For checksumming, the sum of all words in the NVM should equal 0xBABA. */
 #define NVM_SUM                    0xBABA
 
 #define NVM_PBA_OFFSET_0           8
 #define NVM_PBA_OFFSET_1           9
+#define NVM_PBA_PTR_GUARD          0xFAFA
 #define NVM_WORD_SIZE_BASE_SHIFT   6
 
 /* NVM Commands - Microwire */
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index d83b77fa..6b5cc2c 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -445,31 +445,112 @@ out:
 }
 
 /**
- *  igb_read_part_num - Read device part number
+ *  igb_read_part_string - Read device part number
  *  @hw: pointer to the HW structure
  *  @part_num: pointer to device part number
+ *  @part_num_size: size of part number buffer
  *
  *  Reads the product board assembly (PBA) number from the EEPROM and stores
  *  the value in part_num.
  **/
-s32 igb_read_part_num(struct e1000_hw *hw, u32 *part_num)
+s32 igb_read_part_string(struct e1000_hw *hw, u8 *part_num, u32 part_num_size)
 {
-	s32  ret_val;
+	s32 ret_val;
 	u16 nvm_data;
+	u16 pointer;
+	u16 offset;
+	u16 length;
+
+	if (part_num == NULL) {
+		hw_dbg("PBA string buffer was null\n");
+		ret_val = E1000_ERR_INVALID_ARGUMENT;
+		goto out;
+	}
 
 	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
-	*part_num = (u32)(nvm_data << 16);
 
-	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
+	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_1, 1, &pointer);
+	if (ret_val) {
+		hw_dbg("NVM Read Error\n");
+		goto out;
+	}
+
+	/*
+	 * if nvm_data is not ptr guard the PBA must be in legacy format which
+	 * means pointer is actually our second data word for the PBA number
+	 * and we can decode it into an ascii string
+	 */
+	if (nvm_data != NVM_PBA_PTR_GUARD) {
+		hw_dbg("NVM PBA number is not stored as string\n");
+
+		/* we will need 11 characters to store the PBA */
+		if (part_num_size < 11) {
+			hw_dbg("PBA string buffer too small\n");
+			return E1000_ERR_NO_SPACE;
+		}
+
+		/* extract hex string from data and pointer */
+		part_num[0] = (nvm_data >> 12) & 0xF;
+		part_num[1] = (nvm_data >> 8) & 0xF;
+		part_num[2] = (nvm_data >> 4) & 0xF;
+		part_num[3] = nvm_data & 0xF;
+		part_num[4] = (pointer >> 12) & 0xF;
+		part_num[5] = (pointer >> 8) & 0xF;
+		part_num[6] = '-';
+		part_num[7] = 0;
+		part_num[8] = (pointer >> 4) & 0xF;
+		part_num[9] = pointer & 0xF;
+
+		/* put a null character on the end of our string */
+		part_num[10] = '\0';
+
+		/* switch all the data but the '-' to hex char */
+		for (offset = 0; offset < 10; offset++) {
+			if (part_num[offset] < 0xA)
+				part_num[offset] += '0';
+			else if (part_num[offset] < 0x10)
+				part_num[offset] += 'A' - 0xA;
+		}
+
+		goto out;
+	}
+
+	ret_val = hw->nvm.ops.read(hw, pointer, 1, &length);
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
-	*part_num |= nvm_data;
+
+	if (length == 0xFFFF || length == 0) {
+		hw_dbg("NVM PBA number section invalid length\n");
+		ret_val = E1000_ERR_NVM_PBA_SECTION;
+		goto out;
+	}
+	/* check if part_num buffer is big enough */
+	if (part_num_size < (((u32)length * 2) - 1)) {
+		hw_dbg("PBA string buffer too small\n");
+		ret_val = E1000_ERR_NO_SPACE;
+		goto out;
+	}
+
+	/* trim pba length from start of string */
+	pointer++;
+	length--;
+
+	for (offset = 0; offset < length; offset++) {
+		ret_val = hw->nvm.ops.read(hw, pointer + offset, 1, &nvm_data);
+		if (ret_val) {
+			hw_dbg("NVM Read Error\n");
+			goto out;
+		}
+		part_num[offset * 2] = (u8)(nvm_data >> 8);
+		part_num[(offset * 2) + 1] = (u8)(nvm_data & 0xFF);
+	}
+	part_num[offset * 2] = '\0';
 
 out:
 	return ret_val;
diff --git a/drivers/net/igb/e1000_nvm.h b/drivers/net/igb/e1000_nvm.h
index 1041c34..29c956a 100644
--- a/drivers/net/igb/e1000_nvm.h
+++ b/drivers/net/igb/e1000_nvm.h
@@ -32,6 +32,8 @@ s32  igb_acquire_nvm(struct e1000_hw *hw);
 void igb_release_nvm(struct e1000_hw *hw);
 s32  igb_read_mac_addr(struct e1000_hw *hw);
 s32  igb_read_part_num(struct e1000_hw *hw, u32 *part_num);
+s32  igb_read_part_string(struct e1000_hw *hw, u8 *part_num,
+                          u32 part_num_size);
 s32  igb_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 s32  igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 s32  igb_validate_nvm_checksum(struct e1000_hw *hw);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 67ea262..041f8e6 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1729,12 +1729,13 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct igb_adapter *adapter;
 	struct e1000_hw *hw;
 	u16 eeprom_data = 0;
+	s32 ret_val;
 	static int global_quad_port_a; /* global quad port a indication */
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
 	int err, pci_using_dac;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
-	u32 part_num;
+	u8 part_str[E1000_PBANUM_LENGTH];
 
 	/* Catch broken hardware that put the wrong VF device ID in
 	 * the PCIe SR-IOV capability.
@@ -2000,10 +2001,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		   "unknown"),
 		 netdev->dev_addr);
 
-	igb_read_part_num(hw, &part_num);
-	dev_info(&pdev->dev, "%s: PBA No: %06x-%03x\n", netdev->name,
-		(part_num >> 8), (part_num & 0xff));
-
+	ret_val = igb_read_part_string(hw, part_str, E1000_PBANUM_LENGTH);
+	if (ret_val)
+		strcpy(part_str, "Unknown");
+	dev_info(&pdev->dev, "%s: PBA No: %s\n", netdev->name, part_str);
 	dev_info(&pdev->dev,
 		"Using %s interrupts. %d rx queue(s), %d tx queue(s)\n",
 		adapter->msix_entries ? "MSI-X" :
-- 
1.7.3.2

