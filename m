From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: add support for new format of PBA numbers
Date: Fri, 03 Dec 2010 05:32:58 -0800
Message-ID: <20101203133258.21637.5904.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:35980
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751669Ab0LCNdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 08:33:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The new PBA format is stored as a string.  This patch allows the
driver to support both the old and new format.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |   94 +++++++++++++++++++++++++++++++++++---
 drivers/net/ixgbe/ixgbe_common.h |    3 +
 drivers/net/ixgbe/ixgbe_main.c   |   18 ++++---
 drivers/net/ixgbe/ixgbe_type.h   |    6 ++
 4 files changed, 105 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 5605257..cc11e42 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -196,30 +196,110 @@ s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_read_pba_num_generic - Reads part number from EEPROM
+ *  ixgbe_read_pba_string_generic - Reads part number string from EEPROM
  *  @hw: pointer to hardware structure
- *  @pba_num: stores the part number from the EEPROM
+ *  @pba_num: stores the part number string from the EEPROM
+ *  @pba_num_size: part number string buffer length
  *
- *  Reads the part number from the EEPROM.
+ *  Reads the part number string from the EEPROM.
  **/
-s32 ixgbe_read_pba_num_generic(struct ixgbe_hw *hw, u32 *pba_num)
+s32 ixgbe_read_pba_string_generic(struct ixgbe_hw *hw, u8 *pba_num,
+                                  u32 pba_num_size)
 {
 	s32 ret_val;
 	u16 data;
+	u16 pba_ptr;
+	u16 offset;
+	u16 length;
+
+	if (pba_num == NULL) {
+		hw_dbg(hw, "PBA string buffer was null\n");
+		return IXGBE_ERR_INVALID_ARGUMENT;
+	}
 
 	ret_val = hw->eeprom.ops.read(hw, IXGBE_PBANUM0_PTR, &data);
 	if (ret_val) {
 		hw_dbg(hw, "NVM Read Error\n");
 		return ret_val;
 	}
-	*pba_num = (u32)(data << 16);
 
-	ret_val = hw->eeprom.ops.read(hw, IXGBE_PBANUM1_PTR, &data);
+	ret_val = hw->eeprom.ops.read(hw, IXGBE_PBANUM1_PTR, &pba_ptr);
 	if (ret_val) {
 		hw_dbg(hw, "NVM Read Error\n");
 		return ret_val;
 	}
-	*pba_num |= data;
+
+	/*
+	 * if data is not ptr guard the PBA must be in legacy format which
+	 * means pba_ptr is actually our second data word for the PBA number
+	 * and we can decode it into an ascii string
+	 */
+	if (data != IXGBE_PBANUM_PTR_GUARD) {
+		hw_dbg(hw, "NVM PBA number is not stored as string\n");
+
+		/* we will need 11 characters to store the PBA */
+		if (pba_num_size < 11) {
+			hw_dbg(hw, "PBA string buffer too small\n");
+			return IXGBE_ERR_NO_SPACE;
+		}
+
+		/* extract hex string from data and pba_ptr */
+		pba_num[0] = (data >> 12) & 0xF;
+		pba_num[1] = (data >> 8) & 0xF;
+		pba_num[2] = (data >> 4) & 0xF;
+		pba_num[3] = data & 0xF;
+		pba_num[4] = (pba_ptr >> 12) & 0xF;
+		pba_num[5] = (pba_ptr >> 8) & 0xF;
+		pba_num[6] = '-';
+		pba_num[7] = 0;
+		pba_num[8] = (pba_ptr >> 4) & 0xF;
+		pba_num[9] = pba_ptr & 0xF;
+
+		/* put a null character on the end of our string */
+		pba_num[10] = '\0';
+
+		/* switch all the data but the '-' to hex char */
+		for (offset = 0; offset < 10; offset++) {
+			if (pba_num[offset] < 0xA)
+				pba_num[offset] += '0';
+			else if (pba_num[offset] < 0x10)
+				pba_num[offset] += 'A' - 0xA;
+		}
+
+		return 0;
+	}
+
+	ret_val = hw->eeprom.ops.read(hw, pba_ptr, &length);
+	if (ret_val) {
+		hw_dbg(hw, "NVM Read Error\n");
+		return ret_val;
+	}
+
+	if (length == 0xFFFF || length == 0) {
+		hw_dbg(hw, "NVM PBA number section invalid length\n");
+		return IXGBE_ERR_PBA_SECTION;
+	}
+
+	/* check if pba_num buffer is big enough */
+	if (pba_num_size  < (((u32)length * 2) - 1)) {
+		hw_dbg(hw, "PBA string buffer too small\n");
+		return IXGBE_ERR_NO_SPACE;
+	}
+
+	/* trim pba length from start of string */
+	pba_ptr++;
+	length--;
+
+	for (offset = 0; offset < length; offset++) {
+		ret_val = hw->eeprom.ops.read(hw, pba_ptr + offset, &data);
+		if (ret_val) {
+			hw_dbg(hw, "NVM Read Error\n");
+			return ret_val;
+		}
+		pba_num[offset * 2] = (u8)(data >> 8);
+		pba_num[(offset * 2) + 1] = (u8)(data & 0xFF);
+	}
+	pba_num[offset * 2] = '\0';
 
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 341ca51..e1f980a 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -35,7 +35,8 @@ s32 ixgbe_init_ops_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw);
 s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw);
 s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw);
-s32 ixgbe_read_pba_num_generic(struct ixgbe_hw *hw, u32 *pba_num);
+s32 ixgbe_read_pba_string_generic(struct ixgbe_hw *hw, u8 *pba_num,
+                                  u32 pba_num_size);
 s32 ixgbe_get_mac_addr_generic(struct ixgbe_hw *hw, u8 *mac_addr);
 s32 ixgbe_get_bus_info_generic(struct ixgbe_hw *hw);
 void ixgbe_set_lan_id_multi_port_pcie(struct ixgbe_hw *hw);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c3338b5..c5998ca 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6955,11 +6955,12 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
 	int i, err, pci_using_dac;
+	u8 part_str[IXGBE_PBANUM_LENGTH];
 	unsigned int indices = num_possible_cpus();
 #ifdef IXGBE_FCOE
 	u16 device_caps;
 #endif
-	u32 part_num, eec;
+	u32 eec;
 
 	/* Catch broken hardware that put the wrong VF device ID in
 	 * the PCIe SR-IOV capability.
@@ -7265,16 +7266,17 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		    hw->bus.width == ixgbe_bus_width_pcie_x1 ? "Width x1" :
 		    "Unknown"),
 		   netdev->dev_addr);
-	ixgbe_read_pba_num_generic(hw, &part_num);
+
+	err = ixgbe_read_pba_string_generic(hw, part_str, IXGBE_PBANUM_LENGTH);
+	if (err)
+		strcpy(part_str, "Unknown");
 	if (ixgbe_is_sfp(hw) && hw->phy.sfp_type != ixgbe_sfp_type_not_present)
-		e_dev_info("MAC: %d, PHY: %d, SFP+: %d, "
-			   "PBA No: %06x-%03x\n",
+		e_dev_info("MAC: %d, PHY: %d, SFP+: %d, PBA No: %s\n",
 			   hw->mac.type, hw->phy.type, hw->phy.sfp_type,
-			   (part_num >> 8), (part_num & 0xff));
+		           part_str);
 	else
-		e_dev_info("MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
-			   hw->mac.type, hw->phy.type,
-			   (part_num >> 8), (part_num & 0xff));
+		e_dev_info("MAC: %d, PHY: %d, PBA No: %s\n",
+			   hw->mac.type, hw->phy.type, part_str);
 
 	if (hw->bus.width <= ixgbe_bus_width_pcie_x4) {
 		e_dev_warn("PCI-Express bandwidth available for this card is "
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 44bcabb..0f80893 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1510,7 +1510,11 @@
 #define IXGBE_EEPROM_WORD_SIZE_SHIFT  6
 #define IXGBE_EEPROM_OPCODE_BITS      8
 
+/* Part Number String Length */
+#define IXGBE_PBANUM_LENGTH 11
+
 /* Checksum and EEPROM pointers */
+#define IXGBE_PBANUM_PTR_GUARD  0xFAFA
 #define IXGBE_EEPROM_CHECKSUM   0x3F
 #define IXGBE_EEPROM_SUM        0xBABA
 #define IXGBE_PCIE_ANALOG_PTR   0x03
@@ -2640,6 +2644,8 @@ struct ixgbe_info {
 #define IXGBE_ERR_OVERTEMP                      -26
 #define IXGBE_ERR_RAR_INDEX                     -27
 #define IXGBE_ERR_SFP_SETUP_NOT_COMPLETE        -30
+#define IXGBE_ERR_PBA_SECTION                   -31
+#define IXGBE_ERR_INVALID_ARGUMENT              -32
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF
 
 #endif /* _IXGBE_TYPE_H_ */

