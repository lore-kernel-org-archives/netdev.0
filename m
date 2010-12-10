From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 22/27] e1000e: support new PBA format from EEPROM
Date: Fri, 10 Dec 2010 02:03:29 -0800
Message-ID: <1291975414-30487-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:60703
	"EHLO qmta15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753680Ab0LJKEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:04:23 -0500
To: davem@davemloft.net
In-Reply-To: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Provide support to e1000e for displaying the new format of the PBA found
in the EEPROM.  The unique PBA identifier is no longer restricted to
hexadecimal numbers and must now be read and displayed as a string.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/defines.h |    8 ++-
 drivers/net/e1000e/e1000.h   |    3 +-
 drivers/net/e1000e/lib.c     |  135 +++++++++++++++++++++++++++++++++++-------
 drivers/net/e1000e/netdev.c  |   12 +++-
 4 files changed, 130 insertions(+), 28 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 016ea38..7245dc2 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -488,6 +488,9 @@
 #define E1000_BLK_PHY_RESET   12
 #define E1000_ERR_SWFW_SYNC 13
 #define E1000_NOT_IMPLEMENTED 14
+#define E1000_ERR_INVALID_ARGUMENT  16
+#define E1000_ERR_NO_SPACE          17
+#define E1000_ERR_NVM_PBA_SECTION   18
 
 /* Loop limit on how long we wait for auto-negotiation to complete */
 #define FIBER_LINK_UP_LIMIT               50
@@ -650,13 +653,16 @@
 /* Mask bits for fields in Word 0x03 of the EEPROM */
 #define NVM_COMPAT_LOM    0x0800
 
+/* length of string needed to store PBA number */
+#define E1000_PBANUM_LENGTH             11
+
 /* For checksumming, the sum of all words in the NVM should equal 0xBABA. */
 #define NVM_SUM                    0xBABA
 
 /* PBA (printed board assembly) number words */
 #define NVM_PBA_OFFSET_0           8
 #define NVM_PBA_OFFSET_1           9
-
+#define NVM_PBA_PTR_GUARD          0xFAFA
 #define NVM_WORD_SIZE_BASE_SHIFT   6
 
 /* NVM Commands - SPI */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 3d9366f..2c913b8 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -514,7 +514,8 @@ extern struct e1000_info e1000_pch_info;
 extern struct e1000_info e1000_pch2_info;
 extern struct e1000_info e1000_es2_info;
 
-extern s32 e1000e_read_pba_num(struct e1000_hw *hw, u32 *pba_num);
+extern s32 e1000_read_pba_string_generic(struct e1000_hw *hw, u8 *pba_num,
+					 u32 pba_num_size);
 
 extern s32  e1000e_commit_phy(struct e1000_hw *hw);
 
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 0fd4eb5..8377523 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2139,6 +2139,119 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 }
 
 /**
+ *  e1000_read_pba_string_generic - Read device part number
+ *  @hw: pointer to the HW structure
+ *  @pba_num: pointer to device part number
+ *  @pba_num_size: size of part number buffer
+ *
+ *  Reads the product board assembly (PBA) number from the EEPROM and stores
+ *  the value in pba_num.
+ **/
+s32 e1000_read_pba_string_generic(struct e1000_hw *hw, u8 *pba_num,
+				  u32 pba_num_size)
+{
+	s32 ret_val;
+	u16 nvm_data;
+	u16 pba_ptr;
+	u16 offset;
+	u16 length;
+
+	if (pba_num == NULL) {
+		e_dbg("PBA string buffer was null\n");
+		ret_val = E1000_ERR_INVALID_ARGUMENT;
+		goto out;
+	}
+
+	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
+	if (ret_val) {
+		e_dbg("NVM Read Error\n");
+		goto out;
+	}
+
+	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_1, 1, &pba_ptr);
+	if (ret_val) {
+		e_dbg("NVM Read Error\n");
+		goto out;
+	}
+
+	/*
+	 * if nvm_data is not ptr guard the PBA must be in legacy format which
+	 * means pba_ptr is actually our second data word for the PBA number
+	 * and we can decode it into an ascii string
+	 */
+	if (nvm_data != NVM_PBA_PTR_GUARD) {
+		e_dbg("NVM PBA number is not stored as string\n");
+
+		/* we will need 11 characters to store the PBA */
+		if (pba_num_size < 11) {
+			e_dbg("PBA string buffer too small\n");
+			return E1000_ERR_NO_SPACE;
+		}
+
+		/* extract hex string from data and pba_ptr */
+		pba_num[0] = (nvm_data >> 12) & 0xF;
+		pba_num[1] = (nvm_data >> 8) & 0xF;
+		pba_num[2] = (nvm_data >> 4) & 0xF;
+		pba_num[3] = nvm_data & 0xF;
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
+		goto out;
+	}
+
+	ret_val = e1000_read_nvm(hw, pba_ptr, 1, &length);
+	if (ret_val) {
+		e_dbg("NVM Read Error\n");
+		goto out;
+	}
+
+	if (length == 0xFFFF || length == 0) {
+		e_dbg("NVM PBA number section invalid length\n");
+		ret_val = E1000_ERR_NVM_PBA_SECTION;
+		goto out;
+	}
+	/* check if pba_num buffer is big enough */
+	if (pba_num_size < (((u32)length * 2) - 1)) {
+		e_dbg("PBA string buffer too small\n");
+		ret_val = E1000_ERR_NO_SPACE;
+		goto out;
+	}
+
+	/* trim pba length from start of string */
+	pba_ptr++;
+	length--;
+
+	for (offset = 0; offset < length; offset++) {
+		ret_val = e1000_read_nvm(hw, pba_ptr + offset, 1, &nvm_data);
+		if (ret_val) {
+			e_dbg("NVM Read Error\n");
+			goto out;
+		}
+		pba_num[offset * 2] = (u8)(nvm_data >> 8);
+		pba_num[(offset * 2) + 1] = (u8)(nvm_data & 0xFF);
+	}
+	pba_num[offset * 2] = '\0';
+
+out:
+	return ret_val;
+}
+
+/**
  *  e1000_read_mac_addr_generic - Read device MAC address
  *  @hw: pointer to the HW structure
  *
@@ -2579,25 +2692,3 @@ bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
 out:
 	return ret_val;
 }
-
-s32 e1000e_read_pba_num(struct e1000_hw *hw, u32 *pba_num)
-{
-	s32 ret_val;
-	u16 nvm_data;
-
-	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
-	if (ret_val) {
-		e_dbg("NVM Read Error\n");
-		return ret_val;
-	}
-	*pba_num = (u32)(nvm_data << 16);
-
-	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
-	if (ret_val) {
-		e_dbg("NVM Read Error\n");
-		return ret_val;
-	}
-	*pba_num |= nvm_data;
-
-	return 0;
-}
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f8efbbb..393b76d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5626,7 +5626,8 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	u32 pba_num;
+	u32 ret_val;
+	u8 pba_str[E1000_PBANUM_LENGTH];
 
 	/* print bus type/speed/width info */
 	e_info("(PCI Express:2.5GB/s:%s) %pM\n",
@@ -5637,9 +5638,12 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	       netdev->dev_addr);
 	e_info("Intel(R) PRO/%s Network Connection\n",
 	       (hw->phy.type == e1000_phy_ife) ? "10/100" : "1000");
-	e1000e_read_pba_num(hw, &pba_num);
-	e_info("MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
-	       hw->mac.type, hw->phy.type, (pba_num >> 8), (pba_num & 0xff));
+	ret_val = e1000_read_pba_string_generic(hw, pba_str,
+						E1000_PBANUM_LENGTH);
+	if (ret_val)
+		strcpy(pba_str, "Unknown");
+	e_info("MAC: %d, PHY: %d, PBA No: %s\n",
+	       hw->mac.type, hw->phy.type, pba_str);
 }
 
 static void e1000_eeprom_checks(struct e1000_adapter *adapter)
-- 
1.7.3.2

