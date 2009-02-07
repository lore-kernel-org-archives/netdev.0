From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 09/26] igb: rename nvm ops
Date: Sat, 07 Feb 2009 01:17:47 -0800
Message-ID: <20090207091747.15697.41063.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:47186 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752559AbZBGJSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:18:06 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

All of the nvm ops have the tag _nvm added to the end which is redundant
since all of the calls to the ops have to go through the nvm ops struct
anyway.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    8 ++++----
 drivers/net/igb/e1000_hw.h    |    8 ++++----
 drivers/net/igb/e1000_mac.c   |    9 ++++-----
 drivers/net/igb/e1000_nvm.c   |   14 +++++++-------
 drivers/net/igb/igb_ethtool.c |   14 +++++++-------
 drivers/net/igb/igb_main.c    |    3 +--
 6 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 9a66e34..527d4c8 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1429,10 +1429,10 @@ static struct e1000_phy_operations e1000_phy_ops_82575 = {
 };
 
 static struct e1000_nvm_operations e1000_nvm_ops_82575 = {
-	.acquire_nvm          = igb_acquire_nvm_82575,
-	.read_nvm             = igb_read_nvm_eerd,
-	.release_nvm          = igb_release_nvm_82575,
-	.write_nvm            = igb_write_nvm_spi,
+	.acquire              = igb_acquire_nvm_82575,
+	.read                 = igb_read_nvm_eerd,
+	.release              = igb_release_nvm_82575,
+	.write                = igb_write_nvm_spi,
 };
 
 const struct e1000_info e1000_82575_info = {
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 5acb849..acb42a2 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -437,10 +437,10 @@ struct e1000_phy_operations {
 };
 
 struct e1000_nvm_operations {
-	s32  (*acquire_nvm)(struct e1000_hw *);
-	s32  (*read_nvm)(struct e1000_hw *, u16, u16, u16 *);
-	void (*release_nvm)(struct e1000_hw *);
-	s32  (*write_nvm)(struct e1000_hw *, u16, u16, u16 *);
+	s32  (*acquire)(struct e1000_hw *);
+	s32  (*read)(struct e1000_hw *, u16, u16, u16 *);
+	void (*release)(struct e1000_hw *);
+	s32  (*write)(struct e1000_hw *, u16, u16, u16 *);
 };
 
 struct e1000_info {
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index d0b695c..6682206 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -135,7 +135,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	u16 offset, nvm_alt_mac_addr_offset, nvm_data;
 	u8 alt_mac_addr[ETH_ALEN];
 
-	ret_val = hw->nvm.ops.read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
+	ret_val = hw->nvm.ops.read(hw, NVM_ALT_MAC_ADDR_PTR, 1,
 				 &nvm_alt_mac_addr_offset);
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
@@ -152,7 +152,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 
 	for (i = 0; i < ETH_ALEN; i += 2) {
 		offset = nvm_alt_mac_addr_offset + (i >> 1);
-		ret_val = hw->nvm.ops.read_nvm(hw, offset, 1, &nvm_data);
+		ret_val = hw->nvm.ops.read(hw, offset, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg("NVM Read Error\n");
 			goto out;
@@ -575,8 +575,7 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
 	 * control setting, then the variable hw->fc will
 	 * be initialized based on a value in the EEPROM.
 	 */
-	ret_val = hw->nvm.ops.read_nvm(hw, NVM_INIT_CONTROL2_REG, 1,
-				       &nvm_data);
+	ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG, 1, &nvm_data);
 
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
@@ -1028,7 +1027,7 @@ static s32 igb_valid_led_default(struct e1000_hw *hw, u16 *data)
 {
 	s32 ret_val;
 
-	ret_val = hw->nvm.ops.read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
+	ret_val = hw->nvm.ops.read(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
 		goto out;
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 5942da1..3379864 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -419,7 +419,7 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		goto out;
 	}
 
-	ret_val = hw->nvm.ops.acquire_nvm(hw);
+	ret_val = hw->nvm.ops.acquire(hw);
 	if (ret_val)
 		goto out;
 
@@ -468,7 +468,7 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 
 	msleep(10);
 release:
-	hw->nvm.ops.release_nvm(hw);
+	hw->nvm.ops.release(hw);
 
 out:
 	return ret_val;
@@ -487,14 +487,14 @@ s32 igb_read_part_num(struct e1000_hw *hw, u32 *part_num)
 	s32  ret_val;
 	u16 nvm_data;
 
-	ret_val = hw->nvm.ops.read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
+	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 	*part_num = (u32)(nvm_data << 16);
 
-	ret_val = hw->nvm.ops.read_nvm(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
+	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
 		goto out;
@@ -548,7 +548,7 @@ s32 igb_validate_nvm_checksum(struct e1000_hw *hw)
 	u16 i, nvm_data;
 
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
-		ret_val = hw->nvm.ops.read_nvm(hw, i, 1, &nvm_data);
+		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg("NVM Read Error\n");
 			goto out;
@@ -581,7 +581,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 	u16 i, nvm_data;
 
 	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
-		ret_val = hw->nvm.ops.read_nvm(hw, i, 1, &nvm_data);
+		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg("NVM Read Error while updating checksum.\n");
 			goto out;
@@ -589,7 +589,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 		checksum += nvm_data;
 	}
 	checksum = (u16) NVM_SUM - checksum;
-	ret_val = hw->nvm.ops.write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
+	ret_val = hw->nvm.ops.write(hw, NVM_CHECKSUM_REG, 1, &checksum);
 	if (ret_val)
 		hw_dbg("NVM Write Error while updating checksum.\n");
 
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 4606e63..a5bf8ef 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -593,12 +593,12 @@ static int igb_get_eeprom(struct net_device *netdev,
 		return -ENOMEM;
 
 	if (hw->nvm.type == e1000_nvm_eeprom_spi)
-		ret_val = hw->nvm.ops.read_nvm(hw, first_word,
+		ret_val = hw->nvm.ops.read(hw, first_word,
 					    last_word - first_word + 1,
 					    eeprom_buff);
 	else {
 		for (i = 0; i < last_word - first_word + 1; i++) {
-			ret_val = hw->nvm.ops.read_nvm(hw, first_word + i, 1,
+			ret_val = hw->nvm.ops.read(hw, first_word + i, 1,
 						    &eeprom_buff[i]);
 			if (ret_val)
 				break;
@@ -645,14 +645,14 @@ static int igb_set_eeprom(struct net_device *netdev,
 	if (eeprom->offset & 1) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
-		ret_val = hw->nvm.ops.read_nvm(hw, first_word, 1,
+		ret_val = hw->nvm.ops.read(hw, first_word, 1,
 					    &eeprom_buff[0]);
 		ptr++;
 	}
 	if (((eeprom->offset + eeprom->len) & 1) && (ret_val == 0)) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		ret_val = hw->nvm.ops.read_nvm(hw, last_word, 1,
+		ret_val = hw->nvm.ops.read(hw, last_word, 1,
 				   &eeprom_buff[last_word - first_word]);
 	}
 
@@ -665,7 +665,7 @@ static int igb_set_eeprom(struct net_device *netdev,
 	for (i = 0; i < last_word - first_word + 1; i++)
 		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
 
-	ret_val = hw->nvm.ops.write_nvm(hw, first_word,
+	ret_val = hw->nvm.ops.write(hw, first_word,
 				     last_word - first_word + 1, eeprom_buff);
 
 	/* Update the checksum over the first part of the EEPROM if needed
@@ -689,7 +689,7 @@ static void igb_get_drvinfo(struct net_device *netdev,
 
 	/* EEPROM image version # is reported as firmware version # for
 	 * 82575 controllers */
-	adapter->hw.nvm.ops.read_nvm(&adapter->hw, 5, 1, &eeprom_data);
+	adapter->hw.nvm.ops.read(&adapter->hw, 5, 1, &eeprom_data);
 	sprintf(firmware_version, "%d.%d-%d",
 		(eeprom_data & 0xF000) >> 12,
 		(eeprom_data & 0x0FF0) >> 4,
@@ -1056,7 +1056,7 @@ static int igb_eeprom_test(struct igb_adapter *adapter, u64 *data)
 	*data = 0;
 	/* Read and add up the contents of the EEPROM */
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
-		if ((adapter->hw.nvm.ops.read_nvm(&adapter->hw, i, 1, &temp))
+		if ((adapter->hw.nvm.ops.read(&adapter->hw, i, 1, &temp))
 		    < 0) {
 			*data = 1;
 			break;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cb3ac34..e3a3582 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1243,8 +1243,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	if (hw->bus.func == 0 ||
 	    hw->device_id == E1000_DEV_ID_82575EB_COPPER)
-		hw->nvm.ops.read_nvm(hw, NVM_INIT_CONTROL3_PORT_A, 1,
-				     &eeprom_data);
+		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
 
 	if (eeprom_data & eeprom_apme_mask)
 		adapter->eeprom_wol |= E1000_WUFC_MAG;

