From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/16] i40e: update Shadow RAM read/write functions
Date: Mon, 23 Feb 2015 18:11:09 -0800
Message-ID: <1424743881-30485-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52541 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752387AbbBXCL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 21:11:28 -0500
In-Reply-To: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

This change is to refactor the read/write functions to support
future work.

Change-ID: I13150d5e3042f2c617362c0140dc7e6473ebcdee
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c       | 96 ++++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  2 -
 2 files changed, 71 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 3e70f2e..28429c8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -164,15 +164,15 @@ static i40e_status i40e_poll_sr_srctl_done_bit(struct i40e_hw *hw)
 }
 
 /**
- * i40e_read_nvm_word - Reads Shadow RAM
+ * i40e_read_nvm_word_srctl - Reads Shadow RAM via SRCTL register
  * @hw: pointer to the HW structure
  * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF)
  * @data: word read from the Shadow RAM
  *
  * Reads one 16 bit word from the Shadow RAM using the GLNVM_SRCTL register.
  **/
-i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
-					 u16 *data)
+i40e_status i40e_read_nvm_word_srctl(struct i40e_hw *hw, u16 offset,
+				     u16 *data)
 {
 	i40e_status ret_code = I40E_ERR_TIMEOUT;
 	u32 sr_reg;
@@ -200,6 +200,7 @@ i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 			*data = (u16)((sr_reg &
 				       I40E_GLNVM_SRDATA_RDDATA_MASK)
 				    >> I40E_GLNVM_SRDATA_RDDATA_SHIFT);
+			*data = le16_to_cpu(*data);
 		}
 	}
 	if (ret_code)
@@ -212,7 +213,21 @@ read_nvm_exit:
 }
 
 /**
- * i40e_read_nvm_buffer - Reads Shadow RAM buffer
+ * i40e_read_nvm_word - Reads Shadow RAM
+ * @hw: pointer to the HW structure
+ * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF)
+ * @data: word read from the Shadow RAM
+ *
+ * Reads one 16 bit word from the Shadow RAM using the GLNVM_SRCTL register.
+ **/
+i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
+			       u16 *data)
+{
+	return i40e_read_nvm_word_srctl(hw, offset, data);
+}
+
+/**
+ * i40e_read_nvm_buffer_srctl - Reads Shadow RAM buffer via SRCTL register
  * @hw: pointer to the HW structure
  * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF).
  * @words: (in) number of words to read; (out) number of words actually read
@@ -222,8 +237,8 @@ read_nvm_exit:
  * method. The buffer read is preceded by the NVM ownership take
  * and followed by the release.
  **/
-i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
-					   u16 *words, u16 *data)
+i40e_status i40e_read_nvm_buffer_srctl(struct i40e_hw *hw, u16 offset,
+				       u16 *words, u16 *data)
 {
 	i40e_status ret_code = 0;
 	u16 index, word;
@@ -231,7 +246,7 @@ i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
 	/* Loop thru the selected region */
 	for (word = 0; word < *words; word++) {
 		index = offset + word;
-		ret_code = i40e_read_nvm_word(hw, index, &data[word]);
+		ret_code = i40e_read_nvm_word_srctl(hw, index, &data[word]);
 		if (ret_code)
 			break;
 	}
@@ -243,6 +258,23 @@ i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
 }
 
 /**
+ * i40e_read_nvm_buffer - Reads Shadow RAM buffer
+ * @hw: pointer to the HW structure
+ * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF).
+ * @words: (in) number of words to read; (out) number of words actually read
+ * @data: words read from the Shadow RAM
+ *
+ * Reads 16 bit words (data buffer) from the SR using the i40e_read_nvm_srrd()
+ * method. The buffer read is preceded by the NVM ownership take
+ * and followed by the release.
+ **/
+i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
+				 u16 *words, u16 *data)
+{
+	return i40e_read_nvm_buffer_srctl(hw, offset, words, data);
+}
+
+/**
  * i40e_write_nvm_aq - Writes Shadow RAM.
  * @hw: pointer to the HW structure.
  * @module_pointer: module pointer location in words from the NVM beginning
@@ -302,11 +334,18 @@ static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw,
 						    u16 *checksum)
 {
 	i40e_status ret_code = 0;
+	struct i40e_virt_mem vmem;
 	u16 pcie_alt_module = 0;
 	u16 checksum_local = 0;
 	u16 vpd_module = 0;
-	u16 word = 0;
-	u32 i = 0;
+	u16 *data;
+	u16 i = 0;
+
+	ret_code = i40e_allocate_virt_mem(hw, &vmem,
+				    I40E_SR_SECTOR_SIZE_IN_WORDS * sizeof(u16));
+	if (ret_code)
+		goto i40e_calc_nvm_checksum_exit;
+	data = (u16 *)vmem.va;
 
 	/* read pointer to VPD area */
 	ret_code = i40e_read_nvm_word(hw, I40E_SR_VPD_PTR, &vpd_module);
@@ -317,7 +356,7 @@ static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw,
 
 	/* read pointer to PCIe Alt Auto-load module */
 	ret_code = i40e_read_nvm_word(hw, I40E_SR_PCIE_ALT_AUTO_LOAD_PTR,
-				       &pcie_alt_module);
+				      &pcie_alt_module);
 	if (ret_code) {
 		ret_code = I40E_ERR_NVM_CHECKSUM;
 		goto i40e_calc_nvm_checksum_exit;
@@ -327,33 +366,40 @@ static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw,
 	 * except the VPD and PCIe ALT Auto-load modules
 	 */
 	for (i = 0; i < hw->nvm.sr_size; i++) {
+		/* Read SR page */
+		if ((i % I40E_SR_SECTOR_SIZE_IN_WORDS) == 0) {
+			u16 words = I40E_SR_SECTOR_SIZE_IN_WORDS;
+
+			ret_code = i40e_read_nvm_buffer(hw, i, &words, data);
+			if (ret_code) {
+				ret_code = I40E_ERR_NVM_CHECKSUM;
+				goto i40e_calc_nvm_checksum_exit;
+			}
+		}
+
 		/* Skip Checksum word */
 		if (i == I40E_SR_SW_CHECKSUM_WORD)
-			i++;
+			continue;
 		/* Skip VPD module (convert byte size to word count) */
-		if (i == (u32)vpd_module) {
-			i += (I40E_SR_VPD_MODULE_MAX_SIZE / 2);
-			if (i >= hw->nvm.sr_size)
-				break;
+		if ((i >= (u32)vpd_module) &&
+		    (i < ((u32)vpd_module +
+		     (I40E_SR_VPD_MODULE_MAX_SIZE / 2)))) {
+			continue;
 		}
 		/* Skip PCIe ALT module (convert byte size to word count) */
-		if (i == (u32)pcie_alt_module) {
-			i += (I40E_SR_PCIE_ALT_MODULE_MAX_SIZE / 2);
-			if (i >= hw->nvm.sr_size)
-				break;
+		if ((i >= (u32)pcie_alt_module) &&
+		    (i < ((u32)pcie_alt_module +
+		     (I40E_SR_PCIE_ALT_MODULE_MAX_SIZE / 2)))) {
+			continue;
 		}
 
-		ret_code = i40e_read_nvm_word(hw, (u16)i, &word);
-		if (ret_code) {
-			ret_code = I40E_ERR_NVM_CHECKSUM;
-			goto i40e_calc_nvm_checksum_exit;
-		}
-		checksum_local += word;
+		checksum_local += data[i % I40E_SR_SECTOR_SIZE_IN_WORDS];
 	}
 
 	*checksum = (u16)I40E_SR_SW_CHECKSUM_BASE - checksum_local;
 
 i40e_calc_nvm_checksum_exit:
+	i40e_free_virt_mem(hw, &vmem);
 	return ret_code;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 68e852a..de80cb2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -260,8 +260,6 @@ i40e_status i40e_init_nvm(struct i40e_hw *hw);
 i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 				      enum i40e_aq_resource_access_type access);
 void i40e_release_nvm(struct i40e_hw *hw);
-i40e_status i40e_read_nvm_srrd(struct i40e_hw *hw, u16 offset,
-					 u16 *data);
 i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 					 u16 *data);
 i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
-- 
1.9.3
