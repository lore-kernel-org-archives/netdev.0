From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/7 NEXT] rtlwifi: rtl8192ce: rtl8192common: Update for latest version of Realtek drivers
Date: Fri, 26 Sep 2014 16:40:26 -0500
Message-ID: <1411767628-7965-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35732 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbaIZVkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:40:55 -0400
In-Reply-To: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Realtek released new drivers on 06/28/2014. These changes implement all their
changes into the kernel version of the driver. In addition, these modifications
are part of the process of unifying the Realtek and kernel code bases.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  | 421 ++++++-----
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |  27 +
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c | 815 +++++++--------------
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |  15 -
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |  64 --
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  16 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |   3 +
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       | 107 ---
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/def.h       |   3 -
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |  17 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |   3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   1 +
 18 files changed, 534 insertions(+), 973 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index eb78fd8..f6cb5ae 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -1771,7 +1771,7 @@ static void rtl92c_check_bt_change(struct ieee80211_hw *hw)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u8 tmp1byte = 0;
 
-	if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version) &&
+	if (IS_81XXC_VENDOR_UMC_B_CUT(rtlhal->version) &&
 	    rtlpcipriv->bt_coexist.bt_coexistence)
 		tmp1byte |= BIT(5);
 	if (rtlpcipriv->bt_coexist.bt_cur_state) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 04a4162..6a57e6d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -71,66 +67,31 @@ static void _rtl92c_enable_fw_download(struct ieee80211_hw *hw, bool enable)
 	}
 }
 
-static void rtl_block_fw_writeN(struct ieee80211_hw *hw, const u8 *buffer,
-				u32 size)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 blockSize = REALTEK_USB_VENQT_MAX_BUF_SIZE - 20;
-	u8 *bufferPtr = (u8 *) buffer;
-	u32 i, offset, blockCount, remainSize;
-
-	blockCount = size / blockSize;
-	remainSize = size % blockSize;
-
-	for (i = 0; i < blockCount; i++) {
-		offset = i * blockSize;
-		rtlpriv->io.writeN_sync(rtlpriv,
-					(FW_8192C_START_ADDRESS + offset),
-					(void *)(bufferPtr + offset),
-					blockSize);
-	}
-
-	if (remainSize) {
-		offset = blockCount * blockSize;
-		rtlpriv->io.writeN_sync(rtlpriv,
-					(FW_8192C_START_ADDRESS + offset),
-					(void *)(bufferPtr + offset),
-					remainSize);
-	}
-}
-
 static void _rtl92c_fw_block_write(struct ieee80211_hw *hw,
 				   const u8 *buffer, u32 size)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 blockSize = sizeof(u32);
-	u8 *bufferPtr = (u8 *) buffer;
-	u32 *pu4BytePtr = (u32 *) buffer;
-	u32 i, offset, blockCount, remainSize;
-	u32 data;
-
-	if (rtlpriv->io.writeN_sync) {
-		rtl_block_fw_writeN(hw, buffer, size);
-		return;
-	}
-	blockCount = size / blockSize;
-	remainSize = size % blockSize;
-	if (remainSize) {
-		/* the last word is < 4 bytes - pad it with zeros */
-		for (i = 0; i < 4 - remainSize; i++)
-			*(bufferPtr + size + i) = 0;
-		blockCount++;
-	}
+	u32 blocksize = sizeof(u32);
+	u8 *bufferptr = (u8 *)buffer;
+	u32 *pu4byteptr = (u32 *)buffer;
+	u32 i, offset, blockcount, remainsize;
 
-	for (i = 0; i < blockCount; i++) {
-		offset = i * blockSize;
-		/* for big-endian platforms, the firmware data need to be byte
-		 * swapped as it was read as a byte string and will be written
-		 * as 32-bit dwords and byte swapped when written
-		 */
-		data = le32_to_cpu(*(__le32 *)(pu4BytePtr + i));
+	blockcount = size / blocksize;
+	remainsize = size % blocksize;
+
+	for (i = 0; i < blockcount; i++) {
+		offset = i * blocksize;
 		rtl_write_dword(rtlpriv, (FW_8192C_START_ADDRESS + offset),
-				data);
+				*(pu4byteptr + i));
+	}
+
+	if (remainsize) {
+		offset = blockcount * blocksize;
+		bufferptr += offset;
+		for (i = 0; i < remainsize; i++) {
+			rtl_write_byte(rtlpriv, (FW_8192C_START_ADDRESS +
+						 offset + i), *(bufferptr + i));
+		}
 	}
 }
 
@@ -168,19 +129,20 @@ static void _rtl92c_write_fw(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u8 *bufferPtr = buffer;
-
-	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "FW size is %d bytes\n", size);
+	bool is_version_b;
+	u8 *bufferptr = (u8 *)buffer;
 
-	if (IS_CHIP_VER_B(version)) {
-		u32 pageNums, remainSize;
+	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "FW size is %d bytes,\n", size);
+	is_version_b = IS_NORMAL_CHIP(version);
+	if (is_version_b) {
+		u32 pageNums, remainsize;
 		u32 page, offset;
 
-		if (IS_HARDWARE_TYPE_8192CE(rtlhal))
-			_rtl92c_fill_dummy(bufferPtr, &size);
+		if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192CE)
+			_rtl92c_fill_dummy(bufferptr, &size);
 
 		pageNums = size / FW_8192C_PAGE_SIZE;
-		remainSize = size % FW_8192C_PAGE_SIZE;
+		remainsize = size % FW_8192C_PAGE_SIZE;
 
 		if (pageNums > 4) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
@@ -189,15 +151,15 @@ static void _rtl92c_write_fw(struct ieee80211_hw *hw,
 
 		for (page = 0; page < pageNums; page++) {
 			offset = page * FW_8192C_PAGE_SIZE;
-			_rtl92c_fw_page_write(hw, page, (bufferPtr + offset),
+			_rtl92c_fw_page_write(hw, page, (bufferptr + offset),
 					      FW_8192C_PAGE_SIZE);
 		}
 
-		if (remainSize) {
+		if (remainsize) {
 			offset = pageNums * FW_8192C_PAGE_SIZE;
 			page = pageNums;
-			_rtl92c_fw_page_write(hw, page, (bufferPtr + offset),
-					      remainSize);
+			_rtl92c_fw_page_write(hw, page, (bufferptr + offset),
+					      remainsize);
 		}
 	} else {
 		_rtl92c_fw_block_write(hw, buffer, size);
@@ -207,6 +169,7 @@ static void _rtl92c_write_fw(struct ieee80211_hw *hw,
 static int _rtl92c_fw_free_to_go(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	int err = -EIO;
 	u32 counter = 0;
 	u32 value32;
 
@@ -217,12 +180,13 @@ static int _rtl92c_fw_free_to_go(struct ieee80211_hw *hw)
 
 	if (counter >= FW_8192C_POLLING_TIMEOUT_COUNT) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "chksum report faill ! REG_MCUFWDL:0x%08x\n", value32);
-		return -EIO;
+			 "chksum report faill ! REG_MCUFWDL:0x%08x .\n",
+			  value32);
+		goto exit;
 	}
 
 	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-		 "Checksum report OK ! REG_MCUFWDL:0x%08x\n", value32);
+		 "Checksum report OK ! REG_MCUFWDL:0x%08x .\n", value32);
 
 	value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
 	value32 |= MCUFWDL_RDY;
@@ -235,9 +199,10 @@ static int _rtl92c_fw_free_to_go(struct ieee80211_hw *hw)
 		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
 		if (value32 & WINTINI_RDY) {
 			RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-				 "Polling FW ready success!! REG_MCUFWDL:0x%08x\n",
-				 value32);
-			return 0;
+				 "Polling FW ready success!! REG_MCUFWDL:0x%08x .\n",
+					value32);
+			err = 0;
+			goto exit;
 		}
 
 		mdelay(FW_8192C_POLLING_DELAY);
@@ -245,8 +210,10 @@ static int _rtl92c_fw_free_to_go(struct ieee80211_hw *hw)
 	} while (counter++ < FW_8192C_POLLING_TIMEOUT_COUNT);
 
 	RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-		 "Polling FW ready fail!! REG_MCUFWDL:0x%08x\n", value32);
-	return -EIO;
+		 "Polling FW ready fail!! REG_MCUFWDL:0x%08x .\n", value32);
+
+exit:
+	return err;
 }
 
 int rtl92c_download_fw(struct ieee80211_hw *hw)
@@ -256,21 +223,21 @@ int rtl92c_download_fw(struct ieee80211_hw *hw)
 	struct rtl92c_firmware_header *pfwheader;
 	u8 *pfwdata;
 	u32 fwsize;
+	int err;
 	enum version_8192c version = rtlhal->version;
 
-	if (rtlpriv->max_fw_size == 0 || !rtlhal->pfirmware)
+	if (!rtlhal->pfirmware)
 		return 1;
 
 	pfwheader = (struct rtl92c_firmware_header *)rtlhal->pfirmware;
-	pfwdata = rtlhal->pfirmware;
+	pfwdata = (u8 *)rtlhal->pfirmware;
 	fwsize = rtlhal->fwsize;
 
 	if (IS_FW_HEADER_EXIST(pfwheader)) {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
 			 "Firmware Version(%d), Signature(%#x),Size(%d)\n",
-			 le16_to_cpu(pfwheader->version),
-			 le16_to_cpu(pfwheader->signature),
-			 (uint)sizeof(struct rtl92c_firmware_header));
+			  pfwheader->version, pfwheader->signature,
+			  (int)sizeof(struct rtl92c_firmware_header));
 
 		pfwdata = pfwdata + sizeof(struct rtl92c_firmware_header);
 		fwsize = fwsize - sizeof(struct rtl92c_firmware_header);
@@ -280,7 +247,8 @@ int rtl92c_download_fw(struct ieee80211_hw *hw)
 	_rtl92c_write_fw(hw, version, pfwdata, fwsize);
 	_rtl92c_enable_fw_download(hw, false);
 
-	if (_rtl92c_fw_free_to_go(hw)) {
+	err = _rtl92c_fw_free_to_go(hw);
+	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Firmware is not ready to run!\n");
 	} else {
@@ -307,7 +275,7 @@ static bool _rtl92c_check_fw_read_last_h2c(struct ieee80211_hw *hw, u8 boxnum)
 }
 
 static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
-			      u8 element_id, u32 cmd_len, u8 *p_cmdbuffer)
+			      u8 element_id, u32 cmd_len, u8 *cmdbuffer)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
@@ -315,7 +283,8 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 	u16 box_reg = 0, box_extreg = 0;
 	u8 u1b_tmp;
 	bool isfw_read = false;
-	bool bwrite_success = false;
+	u8 buf_index = 0;
+	bool bwrite_sucess = false;
 	u8 wait_h2c_limmit = 100;
 	u8 wait_writeh2c_limmit = 100;
 	u8 boxcontent[4], boxextcontent[2];
@@ -329,16 +298,15 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 		spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 		if (rtlhal->h2c_setinprogress) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "H2C set in progress! Wait to set..element_id(%d)\n",
+				 "H2C set in progress! Wait to set..element_id(%d).\n",
 				 element_id);
-
 			while (rtlhal->h2c_setinprogress) {
 				spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock,
 						       flag);
 				h2c_waitcounter++;
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 					 "Wait 100 us (%d times)...\n",
-					 h2c_waitcounter);
+					  h2c_waitcounter);
 				udelay(100);
 
 				if (h2c_waitcounter > 1000)
@@ -354,7 +322,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 		}
 	}
 
-	while (!bwrite_success) {
+	while (!bwrite_sucess) {
 		wait_writeh2c_limmit--;
 		if (wait_writeh2c_limmit == 0) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
@@ -381,14 +349,13 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			box_extreg = REG_HMEBOX_EXT_3;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			break;
 		}
 
 		isfw_read = _rtl92c_check_fw_read_last_h2c(hw, boxnum);
 		while (!isfw_read) {
-
 			wait_h2c_limmit--;
 			if (wait_h2c_limmit == 0) {
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
@@ -408,7 +375,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 
 		if (!isfw_read) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "Write H2C register BOX[%d] fail!!!!! Fw do not read\n",
+				 "Write H2C register BOX[%d] fail!!!!! Fw do not read.\n",
 				 boxnum);
 			break;
 		}
@@ -418,13 +385,13 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 		boxcontent[0] = element_id;
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 			 "Write element_id box_reg(%4x) = %2x\n",
-			 box_reg, element_id);
+			  box_reg, element_id);
 
 		switch (cmd_len) {
 		case 1:
 			boxcontent[0] &= ~(BIT(7));
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer, 1);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, 1);
 
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
@@ -433,8 +400,8 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 2:
 			boxcontent[0] &= ~(BIT(7));
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer, 2);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, 2);
 
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
@@ -443,8 +410,8 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 3:
 			boxcontent[0] &= ~(BIT(7));
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer, 3);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, 3);
 
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
@@ -453,10 +420,10 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 4:
 			boxcontent[0] |= (BIT(7));
-			memcpy((u8 *) (boxextcontent),
-			       p_cmdbuffer, 2);
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer + 2, 2);
+			memcpy((u8 *)(boxextcontent),
+			       cmdbuffer + buf_index, 2);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index + 2, 2);
 
 			for (idx = 0; idx < 2; idx++) {
 				rtl_write_byte(rtlpriv, box_extreg + idx,
@@ -470,10 +437,10 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 5:
 			boxcontent[0] |= (BIT(7));
-			memcpy((u8 *) (boxextcontent),
-			       p_cmdbuffer, 2);
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer + 2, 3);
+			memcpy((u8 *)(boxextcontent),
+			       cmdbuffer + buf_index, 2);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index + 2, 3);
 
 			for (idx = 0; idx < 2; idx++) {
 				rtl_write_byte(rtlpriv, box_extreg + idx,
@@ -486,12 +453,12 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			}
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			break;
 		}
 
-		bwrite_success = true;
+		bwrite_sucess = true;
 
 		rtlhal->last_hmeboxnum = boxnum + 1;
 		if (rtlhal->last_hmeboxnum == 4)
@@ -499,7 +466,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 			 "pHalData->last_hmeboxnum  = %d\n",
-			 rtlhal->last_hmeboxnum);
+			  rtlhal->last_hmeboxnum);
 	}
 
 	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
@@ -510,12 +477,19 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 }
 
 void rtl92c_fill_h2c_cmd(struct ieee80211_hw *hw,
-			 u8 element_id, u32 cmd_len, u8 *p_cmdbuffer)
+			 u8 element_id, u32 cmd_len, u8 *cmdbuffer)
 {
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u32 tmp_cmdbuf[2];
 
+	if (!rtlhal->fw_ready) {
+		RT_ASSERT(false,
+			  "return H2C cmd because of Fw download fail!!!\n");
+		return;
+	}
+
 	memset(tmp_cmdbuf, 0, 8);
-	memcpy(tmp_cmdbuf, p_cmdbuffer, cmd_len);
+	memcpy(tmp_cmdbuf, cmdbuffer, cmd_len);
 	_rtl92c_fill_h2c_command(hw, element_id, cmd_len, (u8 *)&tmp_cmdbuf);
 
 	return;
@@ -534,7 +508,7 @@ void rtl92c_firmware_selfreset(struct ieee80211_hw *hw)
 	while (u1b_tmp & BIT(2)) {
 		delay--;
 		if (delay == 0) {
-			RT_ASSERT(false, "8051 reset fail\n");
+			RT_ASSERT(false, "8051 reset fail.\n");
 			break;
 		}
 		udelay(50);
@@ -546,23 +520,21 @@ EXPORT_SYMBOL(rtl92c_firmware_selfreset);
 void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 u1_h2c_set_pwrmode[3] = {0};
+	u8 u1_h2c_set_pwrmode[3] = { 0 };
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 
 	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, mode);
 	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
-					 (rtlpriv->mac80211.p2p) ?
-					 ppsc->smart_ps : 1);
+		(rtlpriv->mac80211.p2p) ? ppsc->smart_ps : 1);
 	SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(u1_h2c_set_pwrmode,
 					      ppsc->reg_max_lps_awakeintvl);
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl92c_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode",
+		      "rtl92c_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode\n",
 		      u1_h2c_set_pwrmode, 3);
 	rtl92c_fill_h2c_cmd(hw, H2C_SETPWRMODE, 3, u1_h2c_set_pwrmode);
-
 }
 EXPORT_SYMBOL(rtl92c_set_fw_pwrmode_cmd);
 
@@ -573,19 +545,22 @@ static bool _rtl92c_cmd_send_packet(struct ieee80211_hw *hw,
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring;
 	struct rtl_tx_desc *pdesc;
+	u8 own;
 	unsigned long flags;
 	struct sk_buff *pskb = NULL;
 
 	ring = &rtlpci->tx_ring[BEACON_QUEUE];
 
 	pskb = __skb_dequeue(&ring->queue);
-	kfree_skb(pskb);
+	if (pskb)
+		kfree_skb(pskb);
 
 	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 
 	pdesc = &ring->desc[0];
+	own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
 
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *) pdesc, 1, 1, skb);
+	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
 
 	__skb_queue_tail(&ring->queue, skb);
 
@@ -713,7 +688,7 @@ static u8 reserved_page_packet[TOTAL_RESERVED_PKT_LEN] = {
 	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 };
 
-void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
+void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -721,13 +696,13 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 
 	u32 totalpacketlen;
 	bool rtstatus;
-	u8 u1RsvdPageLoc[3] = {0};
-	bool dlok = false;
+	u8 u1rsvdpageloc[3] = { 0 };
+	bool b_dlok = false;
 
 	u8 *beacon;
-	u8 *pspoll;
+	u8 *p_pspoll;
 	u8 *nullfunc;
-	u8 *probersp;
+	u8 *p_probersp;
 	/*---------------------------------------------------------
 				(1) beacon
 	---------------------------------------------------------*/
@@ -738,12 +713,12 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 	/*-------------------------------------------------------
 				(2) ps-poll
 	--------------------------------------------------------*/
-	pspoll = &reserved_page_packet[PSPOLL_PG * 128];
-	SET_80211_PS_POLL_AID(pspoll, (mac->assoc_id | 0xc000));
-	SET_80211_PS_POLL_BSSID(pspoll, mac->bssid);
-	SET_80211_PS_POLL_TA(pspoll, mac->mac_addr);
+	p_pspoll = &reserved_page_packet[PSPOLL_PG * 128];
+	SET_80211_PS_POLL_AID(p_pspoll, (mac->assoc_id | 0xc000));
+	SET_80211_PS_POLL_BSSID(p_pspoll, mac->bssid);
+	SET_80211_PS_POLL_TA(p_pspoll, mac->mac_addr);
 
-	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1RsvdPageLoc, PSPOLL_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1rsvdpageloc, PSPOLL_PG);
 
 	/*--------------------------------------------------------
 				(3) null data
@@ -753,57 +728,54 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 	SET_80211_HDR_ADDRESS2(nullfunc, mac->mac_addr);
 	SET_80211_HDR_ADDRESS3(nullfunc, mac->bssid);
 
-	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1RsvdPageLoc, NULL_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1rsvdpageloc, NULL_PG);
 
 	/*---------------------------------------------------------
 				(4) probe response
 	----------------------------------------------------------*/
-	probersp = &reserved_page_packet[PROBERSP_PG * 128];
-	SET_80211_HDR_ADDRESS1(probersp, mac->bssid);
-	SET_80211_HDR_ADDRESS2(probersp, mac->mac_addr);
-	SET_80211_HDR_ADDRESS3(probersp, mac->bssid);
+	p_probersp = &reserved_page_packet[PROBERSP_PG * 128];
+	SET_80211_HDR_ADDRESS1(p_probersp, mac->bssid);
+	SET_80211_HDR_ADDRESS2(p_probersp, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(p_probersp, mac->bssid);
 
-	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1RsvdPageLoc, PROBERSP_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1rsvdpageloc, PROBERSP_PG);
 
 	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
-		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL",
+		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
 		      &reserved_page_packet[0], totalpacketlen);
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL",
-		      u1RsvdPageLoc, 3);
+		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      u1rsvdpageloc, 3);
 
 
 	skb = dev_alloc_skb(totalpacketlen);
-	if (!skb)
-		return;
-	kmemleak_not_leak(skb);
-
-	memcpy((u8 *) skb_put(skb, totalpacketlen),
+	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
 	rtstatus = _rtl92c_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
-		dlok = true;
+		b_dlok = true;
 
-	if (dlok) {
+	if (b_dlok) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 "Set RSVD page location to Fw\n");
+			 "Set RSVD page location to Fw.\n");
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-			      "H2C_RSVDPAGE", u1RsvdPageLoc, 3);
+				"H2C_RSVDPAGE:\n",
+				u1rsvdpageloc, 3);
 		rtl92c_fill_h2c_cmd(hw, H2C_RSVDPAGE,
-				    sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
+				    sizeof(u1rsvdpageloc), u1rsvdpageloc);
 	} else
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "Set RSVD page location to Fw FAIL!!!!!!\n");
+			 "Set RSVD page location to Fw FAIL!!!!!!.\n");
 }
 EXPORT_SYMBOL(rtl92c_set_fw_rsvdpagepkt);
 
 void rtl92c_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
 {
-	u8 u1_joinbssrpt_parm[1] = {0};
+	u8 u1_joinbssrpt_parm[1] = { 0 };
 
 	SET_H2CCMD_JOINBSSRPT_PARM_OPMODE(u1_joinbssrpt_parm, mstatus);
 
@@ -813,11 +785,51 @@ EXPORT_SYMBOL(rtl92c_set_fw_joinbss_report_cmd);
 
 static void rtl92c_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw, u8 ctwindow)
 {
-	u8 u1_ctwindow_period[1] = {ctwindow};
+	u8 u1_ctwindow_period[1] = { ctwindow};
 
 	rtl92c_fill_h2c_cmd(hw, H2C_P2P_PS_CTW_CMD, 1, u1_ctwindow_period);
 }
 
+/* refactored routine */
+static void set_noa_data(struct rtl_priv *rtlpriv,
+			 struct rtl_p2p_ps_info *p2pinfo,
+			 struct p2p_ps_offload_t *p2p_ps_offload)
+{
+	int i;
+	u32	start_time, tsf_low;
+
+	/* hw only support 2 set of NoA */
+	for (i = 0 ; i < p2pinfo->noa_num ; i++) {
+		/* To control the reg setting for which NOA*/
+		rtl_write_byte(rtlpriv, 0x5cf, (i << 4));
+		if (i == 0)
+			p2p_ps_offload->noa0_en = 1;
+		else
+			p2p_ps_offload->noa1_en = 1;
+
+		/* config P2P NoA Descriptor Register */
+		rtl_write_dword(rtlpriv, 0x5E0,
+				p2pinfo->noa_duration[i]);
+		rtl_write_dword(rtlpriv, 0x5E4,
+				p2pinfo->noa_interval[i]);
+
+		/*Get Current TSF value */
+		tsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
+
+		start_time = p2pinfo->noa_start_time[i];
+		if (p2pinfo->noa_count_type[i] != 1) {
+			while (start_time <= (tsf_low+(50*1024))) {
+				start_time += p2pinfo->noa_interval[i];
+				if (p2pinfo->noa_count_type[i] != 255)
+					p2pinfo->noa_count_type[i]--;
+			}
+		}
+		rtl_write_dword(rtlpriv, 0x5E8, start_time);
+		rtl_write_dword(rtlpriv, 0x5EC,
+				p2pinfo->noa_count_type[i]);
+	}
+}
+
 void rtl92c_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -825,83 +837,58 @@ void rtl92c_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_p2p_ps_info *p2pinfo = &(rtlps->p2p_ps_info);
 	struct p2p_ps_offload_t *p2p_ps_offload = &rtlhal->p2p_ps_offload;
-	u8	i;
 	u16	ctwindow;
-	u32	start_time, tsf_low;
 
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
-		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
-		memset(p2p_ps_offload, 0, sizeof(struct p2p_ps_offload_t));
-		break;
+			RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+				 "P2P_PS_DISABLE\n");
+			memset(p2p_ps_offload, 0, sizeof(*p2p_ps_offload));
+			break;
 	case P2P_PS_ENABLE:
-		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
-		/* update CTWindow value. */
-		if (p2pinfo->ctwindow > 0) {
-			p2p_ps_offload->ctwindow_en = 1;
-			ctwindow = p2pinfo->ctwindow;
-			rtl92c_set_p2p_ctw_period_cmd(hw, ctwindow);
-		}
-		/* hw only support 2 set of NoA */
-		for (i = 0; i < p2pinfo->noa_num; i++) {
-			/* To control the register setting for which NOA*/
-			rtl_write_byte(rtlpriv, 0x5cf, (i << 4));
-			if (i == 0)
-				p2p_ps_offload->noa0_en = 1;
-			else
-				p2p_ps_offload->noa1_en = 1;
-
-			/* config P2P NoA Descriptor Register */
-			rtl_write_dword(rtlpriv, 0x5E0,
-					p2pinfo->noa_duration[i]);
-			rtl_write_dword(rtlpriv, 0x5E4,
-					p2pinfo->noa_interval[i]);
-
-			/*Get Current TSF value */
-			tsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
-
-			start_time = p2pinfo->noa_start_time[i];
-			if (p2pinfo->noa_count_type[i] != 1) {
-				while (start_time <= (tsf_low+(50*1024))) {
-					start_time += p2pinfo->noa_interval[i];
-					if (p2pinfo->noa_count_type[i] != 255)
-						p2pinfo->noa_count_type[i]--;
-				}
+			RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+				 "P2P_PS_ENABLE\n");
+			/* update CTWindow value. */
+			if (p2pinfo->ctwindow > 0) {
+				p2p_ps_offload->ctwindow_en = 1;
+				ctwindow = p2pinfo->ctwindow;
+				rtl92c_set_p2p_ctw_period_cmd(hw, ctwindow);
 			}
-			rtl_write_dword(rtlpriv, 0x5E8, start_time);
-			rtl_write_dword(rtlpriv, 0x5EC,
-					p2pinfo->noa_count_type[i]);
-		}
+			/* call refactored routine */
+			set_noa_data(rtlpriv, p2pinfo, p2p_ps_offload);
 
-		if ((p2pinfo->opp_ps == 1) || (p2pinfo->noa_num > 0)) {
-			/* rst p2p circuit */
-			rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, BIT(4));
+			if ((p2pinfo->opp_ps == 1) || (p2pinfo->noa_num > 0)) {
+				/* rst p2p circuit */
+				rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST,
+					       BIT(4));
 
-			p2p_ps_offload->offload_en = 1;
+				p2p_ps_offload->offload_en = 1;
 
-			if (P2P_ROLE_GO == rtlpriv->mac80211.p2p) {
-				p2p_ps_offload->role = 1;
-				p2p_ps_offload->allstasleep = 0;
-			} else {
-				p2p_ps_offload->role = 0;
-			}
+				if (P2P_ROLE_GO == rtlpriv->mac80211.p2p) {
+					p2p_ps_offload->role = 1;
+					p2p_ps_offload->allstasleep = 0;
+				} else {
+					p2p_ps_offload->role = 0;
+				}
 
-			p2p_ps_offload->discovery = 0;
-		}
-		break;
+				p2p_ps_offload->discovery = 0;
+			}
+			break;
 	case P2P_PS_SCAN:
-		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_SCAN\n");
-		p2p_ps_offload->discovery = 1;
-		break;
+			RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_SCAN\n");
+			p2p_ps_offload->discovery = 1;
+			break;
 	case P2P_PS_SCAN_DONE:
-		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_SCAN_DONE\n");
-		p2p_ps_offload->discovery = 0;
-		p2pinfo->p2p_ps_state = P2P_PS_ENABLE;
-		break;
+			RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+				 "P2P_PS_SCAN_DONE\n");
+			p2p_ps_offload->discovery = 0;
+			p2pinfo->p2p_ps_state = P2P_PS_ENABLE;
+			break;
 	default:
-		break;
+			break;
 	}
 
 	rtl92c_fill_h2c_cmd(hw, H2C_P2P_PS_OFFLOAD, 1, (u8 *)p2p_ps_offload);
+
 }
 EXPORT_SYMBOL_GPL(rtl92c_set_p2p_ps_offload_cmd);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
index 695a3bd..a815bd6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
@@ -36,11 +36,38 @@
 #define FW_8192C_PAGE_SIZE			4096
 #define FW_8192C_POLLING_DELAY			5
 #define FW_8192C_POLLING_TIMEOUT_COUNT		100
+#define NORMAL_CHIP				BIT(4)
 
 #define IS_FW_HEADER_EXIST(_pfwhdr)	\
 	((le16_to_cpu(_pfwhdr->signature)&0xFFF0) == 0x92C0 ||\
 	(le16_to_cpu(_pfwhdr->signature)&0xFFF0) == 0x88C0)
 
+#define CUT_VERSION_MASK		(BIT(6)|BIT(7))
+#define CHIP_VENDOR_UMC			BIT(5)
+#define CHIP_VENDOR_UMC_B_CUT		BIT(6) /* Chip version for ECO */
+#define IS_CHIP_VER_B(version)  ((version & CHIP_VER_B) ? true : false)
+#define RF_TYPE_MASK			(BIT(0)|BIT(1))
+#define GET_CVID_RF_TYPE(version)	\
+	((version) & RF_TYPE_MASK)
+#define GET_CVID_CUT_VERSION(version) \
+	((version) & CUT_VERSION_MASK)
+#define IS_NORMAL_CHIP(version)	\
+	((version & NORMAL_CHIP) ? true : false)
+#define IS_2T2R(version) \
+	(((GET_CVID_RF_TYPE(version)) == \
+	CHIP_92C_BITMASK) ? true : false)
+#define IS_92C_SERIAL(version) \
+	((IS_2T2R(version)) ? true : false)
+#define IS_CHIP_VENDOR_UMC(version)	\
+	((version & CHIP_VENDOR_UMC) ? true : false)
+#define IS_VENDOR_UMC_A_CUT(version) \
+	((IS_CHIP_VENDOR_UMC(version)) ? \
+	((GET_CVID_CUT_VERSION(version)) ? false : true) : false)
+#define IS_81XXC_VENDOR_UMC_B_CUT(version)	\
+	((IS_CHIP_VENDOR_UMC(version)) ? \
+	((GET_CVID_CUT_VERSION(version) == \
+		CHIP_VENDOR_UMC_B_CUT) ? true : false) : false)
+
 struct rtl92c_firmware_header {
 	__le16 signature;
 	u8 category;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
index 9e32ac8..77e61b1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -27,12 +27,13 @@
  *
  *****************************************************************************/
 
-#include <linux/export.h>
 #include "../wifi.h"
 #include "../rtl8192ce/reg.h"
 #include "../rtl8192ce/def.h"
 #include "dm_common.h"
+#include "fw_common.h"
 #include "phy_common.h"
+#include <linux/export.h>
 
 u32 rtl92c_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 {
@@ -50,7 +51,6 @@ u32 rtl92c_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 		 bitmask, regaddr, originalvalue);
 
 	return returnvalue;
-
 }
 EXPORT_SYMBOL(rtl92c_phy_query_bb_reg);
 
@@ -75,7 +75,6 @@ void rtl92c_phy_set_bb_reg(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
 		 regaddr, bitmask, data);
-
 }
 EXPORT_SYMBOL(rtl92c_phy_set_bb_reg);
 
@@ -84,7 +83,6 @@ u32 _rtl92c_phy_fw_rf_serial_read(struct ieee80211_hw *hw,
 {
 	RT_ASSERT(false, "deprecated!\n");
 	return 0;
-
 }
 EXPORT_SYMBOL(_rtl92c_phy_fw_rf_serial_read);
 
@@ -129,10 +127,10 @@ u32 _rtl92c_phy_rf_serial_read(struct ieee80211_hw *hw,
 		      tmplong | BLSSIREADEDGE);
 	mdelay(1);
 	if (rfpath == RF90_PATH_A)
-		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1,
+		rfpi_enable = (u8)rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1,
 						 BIT(8));
 	else if (rfpath == RF90_PATH_B)
-		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XB_HSSIPARAMETER1,
+		rfpi_enable = (u8)rtl_get_bbreg(hw, RFPGA0_XB_HSSIPARAMETER1,
 						 BIT(8));
 	if (rfpi_enable)
 		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rbpi,
@@ -141,7 +139,8 @@ u32 _rtl92c_phy_rf_serial_read(struct ieee80211_hw *hw,
 		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rb,
 					 BLSSIREADBACKDATA);
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x]=0x%x\n",
-		 rfpath, pphyreg->rf_rb, retvalue);
+					       rfpath, pphyreg->rf_rb,
+					       retvalue);
 	return retvalue;
 }
 EXPORT_SYMBOL(_rtl92c_phy_rf_serial_read);
@@ -165,7 +164,8 @@ void _rtl92c_phy_rf_serial_write(struct ieee80211_hw *hw,
 	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
 	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFW-%d Addr[0x%x]=0x%x\n",
-		 rfpath, pphyreg->rf3wire_offset, data_and_addr);
+					       rfpath, pphyreg->rf3wire_offset,
+					       data_and_addr);
 }
 EXPORT_SYMBOL(_rtl92c_phy_rf_serial_write);
 
@@ -174,7 +174,7 @@ u32 _rtl92c_phy_calculate_bit_shift(u32 bitmask)
 	u32 i;
 
 	for (i = 0; i <= 31; i++) {
-		if ((bitmask >> i) & 0x1)
+		if (((bitmask >> i) & 0x1) == 1)
 			break;
 	}
 	return i;
@@ -210,11 +210,10 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	bool rtstatus;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "==>\n");
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
 						 BASEBAND_CONFIG_PHY_REG);
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
 		return false;
 	}
 	if (rtlphy->rf_type == RF_1T2R) {
@@ -227,7 +226,7 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 						   BASEBAND_CONFIG_PHY_REG);
 	}
 	if (!rtstatus) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
 		return false;
 	}
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
@@ -236,12 +235,12 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
 		return false;
 	}
-	rtlphy->cck_high_power = (bool) (rtl_get_bbreg(hw,
-						RFPGA0_XA_HSSIPARAMETER2,
-						0x200));
+	rtlphy->cck_high_power =
+		(bool)(rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, 0x200));
 
 	return true;
 }
+
 EXPORT_SYMBOL(_rtl92c_phy_bb8192c_config_parafile);
 
 void _rtl92c_store_pwrIndex_diffrate_offset(struct ieee80211_hw *hw,
@@ -250,51 +249,153 @@ void _rtl92c_store_pwrIndex_diffrate_offset(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	int index;
-
-	if (regaddr == RTXAGC_A_RATE18_06)
-		index = 0;
-	else if (regaddr == RTXAGC_A_RATE54_24)
-		index = 1;
-	else if (regaddr == RTXAGC_A_CCK1_MCS32)
-		index = 6;
-	else if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0xffffff00)
-		index = 7;
-	else if (regaddr == RTXAGC_A_MCS03_MCS00)
-		index = 2;
-	else if (regaddr == RTXAGC_A_MCS07_MCS04)
-		index = 3;
-	else if (regaddr == RTXAGC_A_MCS11_MCS08)
-		index = 4;
-	else if (regaddr == RTXAGC_A_MCS15_MCS12)
-		index = 5;
-	else if (regaddr == RTXAGC_B_RATE18_06)
-		index = 8;
-	else if (regaddr == RTXAGC_B_RATE54_24)
-		index = 9;
-	else if (regaddr == RTXAGC_B_CCK1_55_MCS32)
-		index = 14;
-	else if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0x000000ff)
-		index = 15;
-	else if (regaddr == RTXAGC_B_MCS03_MCS00)
-		index = 10;
-	else if (regaddr == RTXAGC_B_MCS07_MCS04)
-		index = 11;
-	else if (regaddr == RTXAGC_B_MCS11_MCS08)
-		index = 12;
-	else if (regaddr == RTXAGC_B_MCS15_MCS12)
-		index = 13;
-	else
-		return;
 
-	rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][index] = data;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 "MCSTxPowerLevelOriginalOffset[%d][%d] = 0x%x\n",
-		 rtlphy->pwrgroup_cnt, index,
-		 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][index]);
+	if (regaddr == RTXAGC_A_RATE18_06) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][0] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][0] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][0]);
+	}
+	if (regaddr == RTXAGC_A_RATE54_24) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][1] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][1] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][1]);
+	}
+	if (regaddr == RTXAGC_A_CCK1_MCS32) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][6] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][6] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][6]);
+	}
+	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0xffffff00) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][7] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][7] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][7]);
+	}
+	if (regaddr == RTXAGC_A_MCS03_MCS00) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][2] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][2] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][2]);
+	}
+	if (regaddr == RTXAGC_A_MCS07_MCS04) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][3] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][3] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][3]);
+	}
+	if (regaddr == RTXAGC_A_MCS11_MCS08) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][4] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][4] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][4]);
+	}
+	if (regaddr == RTXAGC_A_MCS15_MCS12) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][5] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][5] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][5]);
+	}
+	if (regaddr == RTXAGC_B_RATE18_06) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][8] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][8] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][8]);
+	}
+	if (regaddr == RTXAGC_B_RATE54_24) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][9] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][9] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][9]);
+	}
+	if (regaddr == RTXAGC_B_CCK1_55_MCS32) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][14] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][14] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][14]);
+	}
+	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0x000000ff) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][15] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][15] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][15]);
+	}
+	if (regaddr == RTXAGC_B_MCS03_MCS00) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][10] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][10] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][10]);
+	}
+	if (regaddr == RTXAGC_B_MCS07_MCS04) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][11] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][11] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][11]);
+	}
+	if (regaddr == RTXAGC_B_MCS11_MCS08) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][12] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][12] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][12]);
+	}
+	if (regaddr == RTXAGC_B_MCS15_MCS12) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][13] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][13] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][13]);
 
-	if (index == 13)
 		rtlphy->pwrgroup_cnt++;
+	}
 }
 EXPORT_SYMBOL(_rtl92c_store_pwrIndex_diffrate_offset);
 
@@ -304,29 +405,29 @@ void rtl92c_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 
 	rtlphy->default_initialgain[0] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
 	rtlphy->default_initialgain[1] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
 	rtlphy->default_initialgain[2] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1, MASKBYTE0);
 	rtlphy->default_initialgain[3] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 		 "Default initial gain (c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x\n",
-		 rtlphy->default_initialgain[0],
-		 rtlphy->default_initialgain[1],
-		 rtlphy->default_initialgain[2],
-		 rtlphy->default_initialgain[3]);
+		  rtlphy->default_initialgain[0],
+		  rtlphy->default_initialgain[1],
+		  rtlphy->default_initialgain[2],
+		  rtlphy->default_initialgain[3]);
 
-	rtlphy->framesync = (u8) rtl_get_bbreg(hw,
+	rtlphy->framesync = (u8)rtl_get_bbreg(hw,
 					       ROFDM0_RXDETECTOR3, MASKBYTE0);
 	rtlphy->framesync_c34 = rtl_get_bbreg(hw,
 					      ROFDM0_RXDETECTOR2, MASKDWORD);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 		 "Default framesync (0x%x) = 0x%x\n",
-		 ROFDM0_RXDETECTOR3, rtlphy->framesync);
+		  ROFDM0_RXDETECTOR3, rtlphy->framesync);
 }
 
 void _rtl92c_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
@@ -426,19 +527,17 @@ void rtl92c_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
 	long txpwr_dbm;
 
 	txpwr_level = rtlphy->cur_cck_txpwridx;
-	txpwr_dbm = _rtl92c_phy_txpwr_idx_to_dbm(hw,
-						 WIRELESS_MODE_B, txpwr_level);
+	txpwr_dbm = _rtl92c_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_B,
+						 txpwr_level);
 	txpwr_level = rtlphy->cur_ofdm24g_txpwridx +
 	    rtlefuse->legacy_ht_txpowerdiff;
-	if (_rtl92c_phy_txpwr_idx_to_dbm(hw,
-					 WIRELESS_MODE_G,
+	if (_rtl92c_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
 					 txpwr_level) > txpwr_dbm)
 		txpwr_dbm =
 		    _rtl92c_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
 						 txpwr_level);
 	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
-	if (_rtl92c_phy_txpwr_idx_to_dbm(hw,
-					 WIRELESS_MODE_N_24G,
+	if (_rtl92c_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
 					 txpwr_level) > txpwr_dbm)
 		txpwr_dbm =
 		    _rtl92c_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
@@ -480,21 +579,19 @@ static void _rtl92c_ccxpower_index_check(struct ieee80211_hw *hw,
 
 	rtlphy->cur_cck_txpwridx = cckpowerlevel[0];
 	rtlphy->cur_ofdm24g_txpwridx = ofdmpowerlevel[0];
-
 }
 
 void rtl92c_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_efuse *rtlefuse = rtl_efuse(rtlpriv);
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 cckpowerlevel[2], ofdmpowerlevel[2];
 
 	if (!rtlefuse->txpwr_fromeprom)
 		return;
 	_rtl92c_get_txpower_index(hw, channel,
 				  &cckpowerlevel[0], &ofdmpowerlevel[0]);
-	_rtl92c_ccxpower_index_check(hw,
-				     channel, &cckpowerlevel[0],
+	_rtl92c_ccxpower_index_check(hw, channel, &cckpowerlevel[0],
 				     &ofdmpowerlevel[0]);
 	rtlpriv->cfg->ops->phy_rf6052_set_cck_txpower(hw, &cckpowerlevel[0]);
 	rtlpriv->cfg->ops->phy_rf6052_set_ofdm_txpower(hw, &ofdmpowerlevel[0],
@@ -509,11 +606,9 @@ bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 idx;
 	u8 rf_path;
-	u8 ccktxpwridx = _rtl92c_phy_dbm_to_txpwr_Idx(hw,
-						      WIRELESS_MODE_B,
+	u8 ccktxpwridx = _rtl92c_phy_dbm_to_txpwr_idx(hw, WIRELESS_MODE_B,
 						      power_indbm);
-	u8 ofdmtxpwridx = _rtl92c_phy_dbm_to_txpwr_Idx(hw,
-						       WIRELESS_MODE_N_24G,
+	u8 ofdmtxpwridx = _rtl92c_phy_dbm_to_txpwr_idx(hw, WIRELESS_MODE_N_24G,
 						       power_indbm);
 	if (ofdmtxpwridx - rtlefuse->legacy_ht_txpowerdiff > 0)
 		ofdmtxpwridx -= rtlefuse->legacy_ht_txpowerdiff;
@@ -521,7 +616,7 @@ bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm)
 		ofdmtxpwridx = 0;
 	RT_TRACE(rtlpriv, COMP_TXAGC, DBG_TRACE,
 		 "%lx dBm, ccktxpwridx = %d, ofdmtxpwridx = %d\n",
-		 power_indbm, ccktxpwridx, ofdmtxpwridx);
+		  power_indbm, ccktxpwridx, ofdmtxpwridx);
 	for (idx = 0; idx < 14; idx++) {
 		for (rf_path = 0; rf_path < 2; rf_path++) {
 			rtlefuse->txpwrlevel_cck[rf_path][idx] = ccktxpwridx;
@@ -536,7 +631,7 @@ bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm)
 }
 EXPORT_SYMBOL(rtl92c_phy_update_txpower_dbm);
 
-u8 _rtl92c_phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
+u8 _rtl92c_phy_dbm_to_txpwr_idx(struct ieee80211_hw *hw,
 				enum wireless_mode wirelessmode,
 				long power_indbm)
 {
@@ -557,7 +652,7 @@ u8 _rtl92c_phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
 	}
 
 	if ((power_indbm - offset) > 0)
-		txpwridx = (u8) ((power_indbm - offset) * 2);
+		txpwridx = (u8)((power_indbm - offset) * 2);
 	else
 		txpwridx = 0;
 
@@ -566,7 +661,7 @@ u8 _rtl92c_phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
 
 	return txpwridx;
 }
-EXPORT_SYMBOL(_rtl92c_phy_dbm_to_txpwr_Idx);
+EXPORT_SYMBOL(_rtl92c_phy_dbm_to_txpwr_idx);
 
 long _rtl92c_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
 				  enum wireless_mode wirelessmode,
@@ -607,7 +702,7 @@ void rtl92c_phy_set_bw_mode(struct ieee80211_hw *hw,
 		rtlpriv->cfg->ops->phy_set_bw_mode_callback(hw);
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "FALSE driver sleep or unload\n");
+			 "false driver sleep or unload\n");
 		rtlphy->set_bwmode_inprogress = false;
 		rtlphy->current_chan_bw = tmp_bw;
 	}
@@ -640,7 +735,7 @@ void rtl92c_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 		}
 		break;
 	} while (true);
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "\n");
 }
 EXPORT_SYMBOL(rtl92c_phy_sw_chnl_callback);
 
@@ -655,14 +750,14 @@ u8 rtl92c_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (rtlphy->set_bwmode_inprogress)
 		return 0;
 	RT_ASSERT((rtlphy->current_channel <= 14),
-		  "WIRELESS_MODE_G but channel>14\n");
+		  "WIRELESS_MODE_G but channel>14");
 	rtlphy->sw_chnl_inprogress = true;
 	rtlphy->sw_chnl_stage = 0;
 	rtlphy->sw_chnl_step = 0;
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl92c_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schedule workitem\n");
+			 "sw_chnl_inprogress false schdule workitem\n");
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
@@ -673,22 +768,22 @@ u8 rtl92c_phy_sw_chnl(struct ieee80211_hw *hw)
 }
 EXPORT_SYMBOL(rtl92c_phy_sw_chnl);
 
-static void _rtl92c_phy_sw_rf_setting(struct ieee80211_hw *hw, u8 channel)
+static void _rtl92c_phy_sw_rf_seting(struct ieee80211_hw *hw, u8 channel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-
-	if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
-		if (channel == 6 && rtlphy->current_chan_bw ==
-		    HT_CHANNEL_WIDTH_20)
-			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD,
-				      0x00255);
-		else{
-			u32 backupRF0x1A = (u32)rtl_get_rfreg(hw, RF90_PATH_A,
-					    RF_RX_G1, RFREG_OFFSET_MASK);
+	if (IS_81XXC_VENDOR_UMC_B_CUT(rtlhal->version)) {
+		if (channel == 6 &&
+		    rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20) {
+			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1,
+				      MASKDWORD, 0x00255);
+		} else {
+			u32 backuprf0x1A =
+			  (u32)rtl_get_rfreg(hw, RF90_PATH_A, RF_RX_G1,
+					     RFREG_OFFSET_MASK);
 			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD,
-				      backupRF0x1A);
+				      backuprf0x1A);
 		}
 	}
 }
@@ -701,7 +796,7 @@ static bool _rtl92c_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
 	struct swchnlcmd *pcmd;
 
 	if (cmdtable == NULL) {
-		RT_ASSERT(false, "cmdtable cannot be NULL\n");
+		RT_ASSERT(false, "cmdtable cannot be NULL.\n");
 		return false;
 	}
 
@@ -747,7 +842,7 @@ bool _rtl92c_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 	rfdependcmdcnt = 0;
 
 	RT_ASSERT((channel >= 1 && channel <= 14),
-		  "invalid channel for Zebra: %d\n", channel);
+		  "illegal channel for Zebra: %d\n", channel);
 
 	_rtl92c_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
 					 MAX_RFDEPENDCMD_CNT, CMDID_RF_WRITEREG,
@@ -768,6 +863,10 @@ bool _rtl92c_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 		case 2:
 			currentcmd = &postcommoncmd[*step];
 			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Invalid 'stage' = %d, Check it!\n", *stage);
+			return true;
 		}
 
 		if (currentcmd->cmdid == CMDID_END) {
@@ -794,7 +893,7 @@ bool _rtl92c_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		case CMDID_WRITEPORT_UCHAR:
 			rtl_write_byte(rtlpriv, currentcmd->para1,
-				       (u8) currentcmd->para2);
+				       (u8)currentcmd->para2);
 			break;
 		case CMDID_RF_WRITEREG:
 			for (rfpath = 0; rfpath < num_total_rfpath; rfpath++) {
@@ -806,12 +905,12 @@ bool _rtl92c_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 					      currentcmd->para1,
 					      RFREG_OFFSET_MASK,
 					      rtlphy->rfreg_chnlval[rfpath]);
-			_rtl92c_phy_sw_rf_setting(hw, channel);
 			}
+			_rtl92c_phy_sw_rf_seting(hw, channel);
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			break;
 		}
 
@@ -900,7 +999,7 @@ static u8 _rtl92c_phy_path_b_iqk(struct ieee80211_hw *hw)
 }
 
 static void _rtl92c_phy_path_a_fill_iqk_matrix(struct ieee80211_hw *hw,
-					       bool iqk_ok, long result[][8],
+					       bool b_iqk_ok, long result[][8],
 					       u8 final_candidate, bool btxonly)
 {
 	u32 oldval_0, x, tx0_a, reg;
@@ -908,7 +1007,7 @@ static void _rtl92c_phy_path_a_fill_iqk_matrix(struct ieee80211_hw *hw,
 
 	if (final_candidate == 0xFF) {
 		return;
-	} else if (iqk_ok) {
+	} else if (b_iqk_ok) {
 		oldval_0 = (rtl_get_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
 					  MASKDWORD) >> 22) & 0x3FF;
 		x = result[final_candidate][0];
@@ -940,7 +1039,7 @@ static void _rtl92c_phy_path_a_fill_iqk_matrix(struct ieee80211_hw *hw,
 }
 
 static void _rtl92c_phy_path_b_fill_iqk_matrix(struct ieee80211_hw *hw,
-					       bool iqk_ok, long result[][8],
+					       bool b_iqk_ok, long result[][8],
 					       u8 final_candidate, bool btxonly)
 {
 	u32 oldval_1, x, tx1_a, reg;
@@ -948,7 +1047,7 @@ static void _rtl92c_phy_path_b_fill_iqk_matrix(struct ieee80211_hw *hw,
 
 	if (final_candidate == 0xFF) {
 		return;
-	} else if (iqk_ok) {
+	} else if (b_iqk_ok) {
 		oldval_1 = (rtl_get_bbreg(hw, ROFDM0_XBTXIQIMBALANCE,
 					  MASKDWORD) >> 22) & 0x3FF;
 		x = result[final_candidate][4];
@@ -1017,7 +1116,7 @@ static void _rtl92c_phy_reload_mac_registers(struct ieee80211_hw *hw,
 	u32 i;
 
 	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++)
-		rtl_write_byte(rtlpriv, macreg[i], (u8) macbackup[i]);
+		rtl_write_byte(rtlpriv, macreg[i], (u8)macbackup[i]);
 	rtl_write_dword(rtlpriv, macreg[i], macbackup[i]);
 }
 
@@ -1043,14 +1142,14 @@ static void _rtl92c_phy_mac_setting_calibration(struct ieee80211_hw *hw,
 						u32 *macreg, u32 *macbackup)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 i;
+	u32 i = 0;
 
-	rtl_write_byte(rtlpriv, macreg[0], 0x3F);
+	rtl_write_byte(rtlpriv, macreg[i], 0x3F);
 
 	for (i = 1; i < (IQK_MAC_REG_NUM - 1); i++)
 		rtl_write_byte(rtlpriv, macreg[i],
-			       (u8) (macbackup[i] & (~BIT(3))));
-	rtl_write_byte(rtlpriv, macreg[i], (u8) (macbackup[i] & (~BIT(5))));
+			       (u8)(macbackup[i] & (~BIT(3))));
+	rtl_write_byte(rtlpriv, macreg[i], (u8)(macbackup[i] & (~BIT(5))));
 }
 
 static void _rtl92c_phy_path_a_standby(struct ieee80211_hw *hw)
@@ -1126,7 +1225,6 @@ static bool _rtl92c_phy_simularity_compare(struct ieee80211_hw *hw,
 	} else {
 		return false;
 	}
-
 }
 
 static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
@@ -1142,51 +1240,37 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 		0xe88, 0xe8c, 0xed0, 0xed4,
 		0xed8, 0xedc, 0xee0, 0xeec
 	};
-
 	u32 iqk_mac_reg[IQK_MAC_REG_NUM] = {
 		0x522, 0x550, 0x551, 0x040
 	};
-
-	u32 iqk_bb_reg_92C[9] = {
-		0xc04, 0xc08, 0x874, 0xb68,
-		0xb6c, 0x870, 0x860, 0x864,
-		0x800
-	};
-
 	const u32 retrycount = 2;
+	u32 bbvalue;
 
 	if (t == 0) {
-		/* dummy read */
-		rtl_get_bbreg(hw, 0x800, MASKDWORD);
+		bbvalue = rtl_get_bbreg(hw, 0x800, MASKDWORD);
 
 		_rtl92c_phy_save_adda_registers(hw, adda_reg,
 						rtlphy->adda_backup, 16);
 		_rtl92c_phy_save_mac_registers(hw, iqk_mac_reg,
 					       rtlphy->iqk_mac_backup);
-		_rtl92c_phy_save_adda_registers(hw, iqk_bb_reg_92C,
-						rtlphy->iqk_bb_backup, 9);
 	}
 	_rtl92c_phy_path_adda_on(hw, adda_reg, true, is2t);
 	if (t == 0) {
-		rtlphy->rfpi_enable = (u8) rtl_get_bbreg(hw,
-						   RFPGA0_XA_HSSIPARAMETER1,
-						   BIT(8));
+		rtlphy->rfpi_enable =
+		   (u8)rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1,
+				     BIT(8));
 	}
 
 	if (!rtlphy->rfpi_enable)
 		_rtl92c_phy_pi_mode_switch(hw, true);
-
-	rtl_set_bbreg(hw, 0x800, BIT(24), 0x0);
-
+	if (t == 0) {
+		rtlphy->reg_c04 = rtl_get_bbreg(hw, 0xc04, MASKDWORD);
+		rtlphy->reg_c08 = rtl_get_bbreg(hw, 0xc08, MASKDWORD);
+		rtlphy->reg_874 = rtl_get_bbreg(hw, 0x874, MASKDWORD);
+	}
 	rtl_set_bbreg(hw, 0xc04, MASKDWORD, 0x03a05600);
 	rtl_set_bbreg(hw, 0xc08, MASKDWORD, 0x000800e4);
 	rtl_set_bbreg(hw, 0x874, MASKDWORD, 0x22204000);
-
-	rtl_set_bbreg(hw, 0x870, BIT(10), 0x1);
-	rtl_set_bbreg(hw, 0x870, BIT(26), 0x1);
-	rtl_set_bbreg(hw, 0x860, BIT(10), 0x0);
-	rtl_set_bbreg(hw, 0x864, BIT(10), 0x0);
-
 	if (is2t) {
 		rtl_set_bbreg(hw, 0x840, MASKDWORD, 0x00010000);
 		rtl_set_bbreg(hw, 0x844, MASKDWORD, 0x00010000);
@@ -1228,8 +1312,8 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 			pathb_ok = _rtl92c_phy_path_b_iqk(hw);
 			if (pathb_ok == 0x03) {
 				result[t][4] = (rtl_get_bbreg(hw,
-						      0xeb4,
-						      MASKDWORD) &
+							      0xeb4,
+							      MASKDWORD) &
 						0x3FF0000) >> 16;
 				result[t][5] =
 				    (rtl_get_bbreg(hw, 0xebc, MASKDWORD) &
@@ -1243,17 +1327,21 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 				break;
 			} else if (i == (retrycount - 1) && pathb_ok == 0x01) {
 				result[t][4] = (rtl_get_bbreg(hw,
-						      0xeb4,
-						      MASKDWORD) &
+							      0xeb4,
+							      MASKDWORD) &
 						0x3FF0000) >> 16;
 			}
 			result[t][5] = (rtl_get_bbreg(hw, 0xebc, MASKDWORD) &
 					0x3FF0000) >> 16;
 		}
 	}
-
+	rtl_set_bbreg(hw, 0xc04, MASKDWORD, rtlphy->reg_c04);
+	rtl_set_bbreg(hw, 0x874, MASKDWORD, rtlphy->reg_874);
+	rtl_set_bbreg(hw, 0xc08, MASKDWORD, rtlphy->reg_c08);
 	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0);
-
+	rtl_set_bbreg(hw, 0x840, MASKDWORD, 0x00032ed3);
+	if (is2t)
+		rtl_set_bbreg(hw, 0x844, MASKDWORD, 0x00032ed3);
 	if (t != 0) {
 		if (!rtlphy->rfpi_enable)
 			_rtl92c_phy_pi_mode_switch(hw, false);
@@ -1261,379 +1349,12 @@ static void _rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw,
 						  rtlphy->adda_backup, 16);
 		_rtl92c_phy_reload_mac_registers(hw, iqk_mac_reg,
 						 rtlphy->iqk_mac_backup);
-		_rtl92c_phy_reload_adda_registers(hw, iqk_bb_reg_92C,
-						  rtlphy->iqk_bb_backup, 9);
-
-		rtl_set_bbreg(hw, 0x840, MASKDWORD, 0x00032ed3);
-		if (is2t)
-			rtl_set_bbreg(hw, 0x844, MASKDWORD, 0x00032ed3);
-
-		rtl_set_bbreg(hw, 0xe30, MASKDWORD, 0x01008c00);
-		rtl_set_bbreg(hw, 0xe34, MASKDWORD, 0x01008c00);
 	}
 }
 
 static void _rtl92c_phy_ap_calibrate(struct ieee80211_hw *hw,
 				     char delta, bool is2t)
 {
-#if 0 /* This routine is deliberately dummied out for later fixes */
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-
-	u32 reg_d[PATH_NUM];
-	u32 tmpreg, index, offset, path, i, pathbound = PATH_NUM, apkbound;
-
-	u32 bb_backup[APK_BB_REG_NUM];
-	u32 bb_reg[APK_BB_REG_NUM] = {
-		0x904, 0xc04, 0x800, 0xc08, 0x874
-	};
-	u32 bb_ap_mode[APK_BB_REG_NUM] = {
-		0x00000020, 0x00a05430, 0x02040000,
-		0x000800e4, 0x00204000
-	};
-	u32 bb_normal_ap_mode[APK_BB_REG_NUM] = {
-		0x00000020, 0x00a05430, 0x02040000,
-		0x000800e4, 0x22204000
-	};
-
-	u32 afe_backup[APK_AFE_REG_NUM];
-	u32 afe_reg[APK_AFE_REG_NUM] = {
-		0x85c, 0xe6c, 0xe70, 0xe74, 0xe78,
-		0xe7c, 0xe80, 0xe84, 0xe88, 0xe8c,
-		0xed0, 0xed4, 0xed8, 0xedc, 0xee0,
-		0xeec
-	};
-
-	u32 mac_backup[IQK_MAC_REG_NUM];
-	u32 mac_reg[IQK_MAC_REG_NUM] = {
-		0x522, 0x550, 0x551, 0x040
-	};
-
-	u32 apk_rf_init_value[PATH_NUM][APK_BB_REG_NUM] = {
-		{0x0852c, 0x1852c, 0x5852c, 0x1852c, 0x5852c},
-		{0x2852e, 0x0852e, 0x3852e, 0x0852e, 0x0852e}
-	};
-
-	u32 apk_normal_rf_init_value[PATH_NUM][APK_BB_REG_NUM] = {
-		{0x0852c, 0x0a52c, 0x3a52c, 0x5a52c, 0x5a52c},
-		{0x0852c, 0x0a52c, 0x5a52c, 0x5a52c, 0x5a52c}
-	};
-
-	u32 apk_rf_value_0[PATH_NUM][APK_BB_REG_NUM] = {
-		{0x52019, 0x52014, 0x52013, 0x5200f, 0x5208d},
-		{0x5201a, 0x52019, 0x52016, 0x52033, 0x52050}
-	};
-
-	u32 apk_normal_rf_value_0[PATH_NUM][APK_BB_REG_NUM] = {
-		{0x52019, 0x52017, 0x52010, 0x5200d, 0x5206a},
-		{0x52019, 0x52017, 0x52010, 0x5200d, 0x5206a}
-	};
-
-	u32 afe_on_off[PATH_NUM] = {
-		0x04db25a4, 0x0b1b25a4
-	};
-
-	const u32 apk_offset[PATH_NUM] = { 0xb68, 0xb6c };
-
-	u32 apk_normal_offset[PATH_NUM] = { 0xb28, 0xb98 };
-
-	u32 apk_value[PATH_NUM] = { 0x92fc0000, 0x12fc0000 };
-
-	u32 apk_normal_value[PATH_NUM] = { 0x92680000, 0x12680000 };
-
-	const char apk_delta_mapping[APK_BB_REG_NUM][13] = {
-		{-4, -3, -2, -2, -1, -1, 0, 1, 2, 3, 4, 5, 6},
-		{-4, -3, -2, -2, -1, -1, 0, 1, 2, 3, 4, 5, 6},
-		{-6, -4, -2, -2, -1, -1, 0, 1, 2, 3, 4, 5, 6},
-		{-1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6},
-		{-11, -9, -7, -5, -3, -1, 0, 0, 0, 0, 0, 0, 0}
-	};
-
-	const u32 apk_normal_setting_value_1[13] = {
-		0x01017018, 0xf7ed8f84, 0x1b1a1816, 0x2522201e, 0x322e2b28,
-		0x433f3a36, 0x5b544e49, 0x7b726a62, 0xa69a8f84, 0xdfcfc0b3,
-		0x12680000, 0x00880000, 0x00880000
-	};
-
-	const u32 apk_normal_setting_value_2[16] = {
-		0x01c7021d, 0x01670183, 0x01000123, 0x00bf00e2, 0x008d00a3,
-		0x0068007b, 0x004d0059, 0x003a0042, 0x002b0031, 0x001f0025,
-		0x0017001b, 0x00110014, 0x000c000f, 0x0009000b, 0x00070008,
-		0x00050006
-	};
-
-	u32 apk_result[PATH_NUM][APK_BB_REG_NUM];
-
-	long bb_offset, delta_v, delta_offset;
-
-	if (!is2t)
-		pathbound = 1;
-
-	return;
-
-	for (index = 0; index < PATH_NUM; index++) {
-		apk_offset[index] = apk_normal_offset[index];
-		apk_value[index] = apk_normal_value[index];
-		afe_on_off[index] = 0x6fdb25a4;
-	}
-
-	for (index = 0; index < APK_BB_REG_NUM; index++) {
-		for (path = 0; path < pathbound; path++) {
-			apk_rf_init_value[path][index] =
-			    apk_normal_rf_init_value[path][index];
-			apk_rf_value_0[path][index] =
-			    apk_normal_rf_value_0[path][index];
-		}
-		bb_ap_mode[index] = bb_normal_ap_mode[index];
-
-		apkbound = 6;
-	}
-
-	for (index = 0; index < APK_BB_REG_NUM; index++) {
-		if (index == 0)
-			continue;
-		bb_backup[index] = rtl_get_bbreg(hw, bb_reg[index], MASKDWORD);
-	}
-
-	_rtl92c_phy_save_mac_registers(hw, mac_reg, mac_backup);
-
-	_rtl92c_phy_save_adda_registers(hw, afe_reg, afe_backup, 16);
-
-	for (path = 0; path < pathbound; path++) {
-		if (path == RF90_PATH_A) {
-			offset = 0xb00;
-			for (index = 0; index < 11; index++) {
-				rtl_set_bbreg(hw, offset, MASKDWORD,
-					      apk_normal_setting_value_1
-					      [index]);
-
-				offset += 0x04;
-			}
-
-			rtl_set_bbreg(hw, 0xb98, MASKDWORD, 0x12680000);
-
-			offset = 0xb68;
-			for (; index < 13; index++) {
-				rtl_set_bbreg(hw, offset, MASKDWORD,
-					      apk_normal_setting_value_1
-					      [index]);
-
-				offset += 0x04;
-			}
-
-			rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x40000000);
-
-			offset = 0xb00;
-			for (index = 0; index < 16; index++) {
-				rtl_set_bbreg(hw, offset, MASKDWORD,
-					      apk_normal_setting_value_2
-					      [index]);
-
-				offset += 0x04;
-			}
-			rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x00000000);
-		} else if (path == RF90_PATH_B) {
-			offset = 0xb70;
-			for (index = 0; index < 10; index++) {
-				rtl_set_bbreg(hw, offset, MASKDWORD,
-					      apk_normal_setting_value_1
-					      [index]);
-
-				offset += 0x04;
-			}
-			rtl_set_bbreg(hw, 0xb28, MASKDWORD, 0x12680000);
-			rtl_set_bbreg(hw, 0xb98, MASKDWORD, 0x12680000);
-
-			offset = 0xb68;
-			index = 11;
-			for (; index < 13; index++) {
-				rtl_set_bbreg(hw, offset, MASKDWORD,
-					      apk_normal_setting_value_1
-					      [index]);
-
-				offset += 0x04;
-			}
-
-			rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x40000000);
-
-			offset = 0xb60;
-			for (index = 0; index < 16; index++) {
-				rtl_set_bbreg(hw, offset, MASKDWORD,
-					      apk_normal_setting_value_2
-					      [index]);
-
-				offset += 0x04;
-			}
-			rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x00000000);
-		}
-
-		reg_d[path] = rtl_get_rfreg(hw, (enum radio_path)path,
-					    0xd, MASKDWORD);
-
-		for (index = 0; index < APK_AFE_REG_NUM; index++)
-			rtl_set_bbreg(hw, afe_reg[index], MASKDWORD,
-				      afe_on_off[path]);
-
-		if (path == RF90_PATH_A) {
-			for (index = 0; index < APK_BB_REG_NUM; index++) {
-				if (index == 0)
-					continue;
-				rtl_set_bbreg(hw, bb_reg[index], MASKDWORD,
-					      bb_ap_mode[index]);
-			}
-		}
-
-		_rtl92c_phy_mac_setting_calibration(hw, mac_reg, mac_backup);
-
-		if (path == 0) {
-			rtl_set_rfreg(hw, RF90_PATH_B, 0x0, MASKDWORD, 0x10000);
-		} else {
-			rtl_set_rfreg(hw, RF90_PATH_A, 0x00, MASKDWORD,
-				      0x10000);
-			rtl_set_rfreg(hw, RF90_PATH_A, 0x10, MASKDWORD,
-				      0x1000f);
-			rtl_set_rfreg(hw, RF90_PATH_A, 0x11, MASKDWORD,
-				      0x20103);
-		}
-
-		delta_offset = ((delta + 14) / 2);
-		if (delta_offset < 0)
-			delta_offset = 0;
-		else if (delta_offset > 12)
-			delta_offset = 12;
-
-		for (index = 0; index < APK_BB_REG_NUM; index++) {
-			if (index != 1)
-				continue;
-
-			tmpreg = apk_rf_init_value[path][index];
-
-			if (!rtlefuse->apk_thermalmeterignore) {
-				bb_offset = (tmpreg & 0xF0000) >> 16;
-
-				if (!(tmpreg & BIT(15)))
-					bb_offset = -bb_offset;
-
-				delta_v =
-				    apk_delta_mapping[index][delta_offset];
-
-				bb_offset += delta_v;
-
-				if (bb_offset < 0) {
-					tmpreg = tmpreg & (~BIT(15));
-					bb_offset = -bb_offset;
-				} else {
-					tmpreg = tmpreg | BIT(15);
-				}
-
-				tmpreg =
-				    (tmpreg & 0xFFF0FFFF) | (bb_offset << 16);
-			}
-
-			rtl_set_rfreg(hw, (enum radio_path)path, 0xc,
-				      MASKDWORD, 0x8992e);
-			rtl_set_rfreg(hw, (enum radio_path)path, 0x0,
-				      MASKDWORD, apk_rf_value_0[path][index]);
-			rtl_set_rfreg(hw, (enum radio_path)path, 0xd,
-				      MASKDWORD, tmpreg);
-
-			i = 0;
-			do {
-				rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x80000000);
-				rtl_set_bbreg(hw, apk_offset[path],
-					      MASKDWORD, apk_value[0]);
-				RTPRINT(rtlpriv, FINIT, INIT_IQK,
-					("PHY_APCalibrate() offset 0x%x "
-					 "value 0x%x\n",
-					 apk_offset[path],
-					 rtl_get_bbreg(hw, apk_offset[path],
-						       MASKDWORD)));
-
-				mdelay(3);
-
-				rtl_set_bbreg(hw, apk_offset[path],
-					      MASKDWORD, apk_value[1]);
-				RTPRINT(rtlpriv, FINIT, INIT_IQK,
-					("PHY_APCalibrate() offset 0x%x "
-					 "value 0x%x\n",
-					 apk_offset[path],
-					 rtl_get_bbreg(hw, apk_offset[path],
-						       MASKDWORD)));
-
-				mdelay(20);
-
-				rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x00000000);
-
-				if (path == RF90_PATH_A)
-					tmpreg = rtl_get_bbreg(hw, 0xbd8,
-							       0x03E00000);
-				else
-					tmpreg = rtl_get_bbreg(hw, 0xbd8,
-							       0xF8000000);
-
-				RTPRINT(rtlpriv, FINIT, INIT_IQK,
-					("PHY_APCalibrate() offset "
-					 "0xbd8[25:21] %x\n", tmpreg));
-
-				i++;
-
-			} while (tmpreg > apkbound && i < 4);
-
-			apk_result[path][index] = tmpreg;
-		}
-	}
-
-	_rtl92c_phy_reload_mac_registers(hw, mac_reg, mac_backup);
-
-	for (index = 0; index < APK_BB_REG_NUM; index++) {
-		if (index == 0)
-			continue;
-		rtl_set_bbreg(hw, bb_reg[index], MASKDWORD, bb_backup[index]);
-	}
-
-	_rtl92c_phy_reload_adda_registers(hw, afe_reg, afe_backup, 16);
-
-	for (path = 0; path < pathbound; path++) {
-		rtl_set_rfreg(hw, (enum radio_path)path, 0xd,
-			      MASKDWORD, reg_d[path]);
-
-		if (path == RF90_PATH_B) {
-			rtl_set_rfreg(hw, RF90_PATH_A, 0x10, MASKDWORD,
-				      0x1000f);
-			rtl_set_rfreg(hw, RF90_PATH_A, 0x11, MASKDWORD,
-				      0x20101);
-		}
-
-		if (apk_result[path][1] > 6)
-			apk_result[path][1] = 6;
-	}
-
-	for (path = 0; path < pathbound; path++) {
-		rtl_set_rfreg(hw, (enum radio_path)path, 0x3, MASKDWORD,
-			      ((apk_result[path][1] << 15) |
-			       (apk_result[path][1] << 10) |
-			       (apk_result[path][1] << 5) |
-			       apk_result[path][1]));
-
-		if (path == RF90_PATH_A)
-			rtl_set_rfreg(hw, (enum radio_path)path, 0x4, MASKDWORD,
-				      ((apk_result[path][1] << 15) |
-				       (apk_result[path][1] << 10) |
-				       (0x00 << 5) | 0x05));
-		else
-			rtl_set_rfreg(hw, (enum radio_path)path, 0x4, MASKDWORD,
-				      ((apk_result[path][1] << 15) |
-				       (apk_result[path][1] << 10) |
-				       (0x02 << 5) | 0x05));
-
-		rtl_set_rfreg(hw, (enum radio_path)path, 0xe, MASKDWORD,
-			      ((0x08 << 15) | (0x08 << 10) | (0x08 << 5) |
-			       0x08));
-
-	}
-	rtlphy->b_apk_done = true;
-#endif
 }
 
 static void _rtl92c_phy_set_rfpath_switch(struct ieee80211_hw *hw,
@@ -1657,15 +1378,13 @@ static void _rtl92c_phy_set_rfpath_switch(struct ieee80211_hw *hw,
 			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE, 0x300, 0x2);
 		else
 			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE, 0x300, 0x1);
-
 	}
-
 }
 
 #undef IQK_ADDA_REG_NUM
 #undef IQK_DELAY_TIME
 
-void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
+void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
@@ -1673,10 +1392,10 @@ void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 
 	long result[4][8];
 	u8 i, final_candidate;
-	bool patha_ok, pathb_ok;
-	long reg_e94, reg_e9c, reg_ea4, reg_eb4, reg_ebc, reg_ec4, reg_tmp = 0;
+	bool b_patha_ok, b_pathb_ok;
+	long reg_e94, reg_e9c, reg_ea4, reg_eac, reg_eb4, reg_ebc, reg_ec4,
+	    reg_ecc, reg_tmp = 0;
 	bool is12simular, is13simular, is23simular;
-	bool start_conttx = false, singletone = false;
 	u32 iqk_bb_reg[10] = {
 		ROFDM0_XARXIQIMBALANCE,
 		ROFDM0_XBRXIQIMBALANCE,
@@ -1690,14 +1409,12 @@ void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		ROFDM0_RXIQEXTANTA
 	};
 
-	if (recovery) {
+	if (b_recovery) {
 		_rtl92c_phy_reload_adda_registers(hw,
 						  iqk_bb_reg,
 						  rtlphy->iqk_bb_backup, 10);
 		return;
 	}
-	if (start_conttx || singletone)
-		return;
 	for (i = 0; i < 8; i++) {
 		result[0][i] = 0;
 		result[1][i] = 0;
@@ -1705,8 +1422,8 @@ void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		result[3][i] = 0;
 	}
 	final_candidate = 0xff;
-	patha_ok = false;
-	pathb_ok = false;
+	b_patha_ok = false;
+	b_pathb_ok = false;
 	is12simular = false;
 	is23simular = false;
 	is13simular = false;
@@ -1752,29 +1469,34 @@ void rtl92c_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		reg_e94 = result[i][0];
 		reg_e9c = result[i][1];
 		reg_ea4 = result[i][2];
+		reg_eac = result[i][3];
 		reg_eb4 = result[i][4];
 		reg_ebc = result[i][5];
 		reg_ec4 = result[i][6];
+		reg_ecc = result[i][7];
 	}
 	if (final_candidate != 0xff) {
 		rtlphy->reg_e94 = reg_e94 = result[final_candidate][0];
 		rtlphy->reg_e9c = reg_e9c = result[final_candidate][1];
 		reg_ea4 = result[final_candidate][2];
+		reg_eac = result[final_candidate][3];
 		rtlphy->reg_eb4 = reg_eb4 = result[final_candidate][4];
 		rtlphy->reg_ebc = reg_ebc = result[final_candidate][5];
 		reg_ec4 = result[final_candidate][6];
-		patha_ok = pathb_ok = true;
+		reg_ecc = result[final_candidate][7];
+		b_patha_ok = true;
+		b_pathb_ok = true;
 	} else {
 		rtlphy->reg_e94 = rtlphy->reg_eb4 = 0x100;
 		rtlphy->reg_e9c = rtlphy->reg_ebc = 0x0;
 	}
 	if (reg_e94 != 0) /*&&(reg_ea4 != 0) */
-		_rtl92c_phy_path_a_fill_iqk_matrix(hw, patha_ok, result,
+		_rtl92c_phy_path_a_fill_iqk_matrix(hw, b_patha_ok, result,
 						   final_candidate,
 						   (reg_ea4 == 0));
 	if (IS_92C_SERIAL(rtlhal->version)) {
 		if (reg_eb4 != 0) /*&&(reg_ec4 != 0) */
-			_rtl92c_phy_path_b_fill_iqk_matrix(hw, pathb_ok,
+			_rtl92c_phy_path_b_fill_iqk_matrix(hw, b_pathb_ok,
 							   result,
 							   final_candidate,
 							   (reg_ec4 == 0));
@@ -1788,10 +1510,7 @@ void rtl92c_phy_lc_calibrate(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	bool start_conttx = false, singletone = false;
 
-	if (start_conttx || singletone)
-		return;
 	if (IS_92C_SERIAL(rtlhal->version))
 		rtlpriv->cfg->ops->phy_lc_calibrate(hw, true);
 	else
@@ -1833,22 +1552,22 @@ bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 		 "-->IO Cmd(%#x), set_io_inprogress(%d)\n",
-		 iotype, rtlphy->set_io_inprogress);
+		  iotype, rtlphy->set_io_inprogress);
 	do {
 		switch (iotype) {
 		case IO_CMD_RESUME_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-				 "[IO CMD] Resume DM after scan\n");
+				 "[IO CMD] Resume DM after scan.\n");
 			postprocessing = true;
 			break;
-		case IO_CMD_PAUSE_DM_BY_SCAN:
+		case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-				 "[IO CMD] Pause DM before scan\n");
+				 "[IO CMD] Pause DM before scan.\n");
 			postprocessing = true;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			break;
 		}
 	} while (false);
@@ -1859,7 +1578,7 @@ bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 		return false;
 	}
 	rtl92c_phy_set_io(hw);
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "<--IO Type(%#x)\n", iotype);
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "IO Type(%#x)\n", iotype);
 	return true;
 }
 EXPORT_SYMBOL(rtl92c_phy_set_io_cmd);
@@ -1868,30 +1587,30 @@ void rtl92c_phy_set_io(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct dig_t dm_digtable = rtlpriv->dm_digtable;
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
-		 rtlphy->current_io_type, rtlphy->set_io_inprogress);
+		  rtlphy->current_io_type, rtlphy->set_io_inprogress);
 	switch (rtlphy->current_io_type) {
 	case IO_CMD_RESUME_DM_BY_SCAN:
-		dm_digtable.cur_igvalue = rtlphy->initgain_backup.xaagccore1;
+		dm_digtable->cur_igvalue = rtlphy->initgain_backup.xaagccore1;
 		rtl92c_dm_write_dig(hw);
 		rtl92c_phy_set_txpower_level(hw, rtlphy->current_channel);
 		break;
-	case IO_CMD_PAUSE_DM_BY_SCAN:
-		rtlphy->initgain_backup.xaagccore1 = dm_digtable.cur_igvalue;
-		dm_digtable.cur_igvalue = 0x37;
+	case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
+		rtlphy->initgain_backup.xaagccore1 = dm_digtable->cur_igvalue;
+		dm_digtable->cur_igvalue = 0x17;
 		rtl92c_dm_write_dig(hw);
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "<---(%#x)\n",
-		 rtlphy->current_io_type);
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+		 "(%#x)\n", rtlphy->current_io_type);
 }
 EXPORT_SYMBOL(rtl92c_phy_set_io);
 
@@ -1931,7 +1650,7 @@ void _rtl92c_phy_set_rf_sleep(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
 		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 "Switch RF timeout !!!\n");
+			 "Switch RF timeout !!!.\n");
 		return;
 	}
 	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE2);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h
index e79dabe..64bc49f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.h
@@ -226,7 +226,7 @@ u32 _rtl92c_phy_calculate_bit_shift(u32 bitmask);
 long _rtl92c_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
 				  enum wireless_mode wirelessmode,
 				  u8 txpwridx);
-u8 _rtl92c_phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
+u8 _rtl92c_phy_dbm_to_txpwr_idx(struct ieee80211_hw *hw,
 				enum wireless_mode wirelessmode,
 				long power_indbm);
 void _rtl92c_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
index fa24de4..831df10 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
@@ -146,21 +146,6 @@ enum version_8192c {
 	VERSION_UNKNOWN = 0x88,
 };
 
-#define CUT_VERSION_MASK		(BIT(6)|BIT(7))
-#define CHIP_VENDOR_UMC			BIT(5)
-#define CHIP_VENDOR_UMC_B_CUT		BIT(6) /* Chip version for ECO */
-#define IS_VENDOR_UMC_A_CUT(version)	((IS_CHIP_VENDOR_UMC(version)) ? \
-	((GET_CVID_CUT_VERSION(version)) ? false : true) : false)
-#define IS_CHIP_VER_B(version)  ((version & CHIP_VER_B) ? true : false)
-#define IS_92C_SERIAL(version)  ((version & CHIP_92C_BITMASK) ? true : false)
-#define IS_CHIP_VENDOR_UMC(version)		\
-	((version & CHIP_VENDOR_UMC) ? true : false)
-#define GET_CVID_CUT_VERSION(version)	((version) & CUT_VERSION_MASK)
-#define IS_81xxC_VENDOR_UMC_B_CUT(version)		\
-	((IS_CHIP_VENDOR_UMC(version)) ? \
-	((GET_CVID_CUT_VERSION(version) == CHIP_VENDOR_UMC_B_CUT) ?	\
-	true : false) : false)
-
 enum rtl819x_loopback_e {
 	RTL819X_NO_LOOPBACK = 0,
 	RTL819X_MAC_LOOPBACK = 1,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h
index d4a3d03..9c5311c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.h
@@ -86,70 +86,6 @@
 #define TX_POWER_NEAR_FIELD_THRESH_LVL2		74
 #define TX_POWER_NEAR_FIELD_THRESH_LVL1		67
 
-struct swat_t {
-	u8 failure_cnt;
-	u8 try_flag;
-	u8 stop_trying;
-	long pre_rssi;
-	long trying_threshold;
-	u8 cur_antenna;
-	u8 pre_antenna;
-};
-
-enum tag_dynamic_init_gain_operation_type_definition {
-	DIG_TYPE_THRESH_HIGH = 0,
-	DIG_TYPE_THRESH_LOW = 1,
-	DIG_TYPE_BACKOFF = 2,
-	DIG_TYPE_RX_GAIN_MIN = 3,
-	DIG_TYPE_RX_GAIN_MAX = 4,
-	DIG_TYPE_ENABLE = 5,
-	DIG_TYPE_DISABLE = 6,
-	DIG_OP_TYPE_MAX
-};
-
-enum tag_cck_packet_detection_threshold_type_definition {
-	CCK_PD_STAGE_LowRssi = 0,
-	CCK_PD_STAGE_HighRssi = 1,
-	CCK_FA_STAGE_Low = 2,
-	CCK_FA_STAGE_High = 3,
-	CCK_PD_STAGE_MAX = 4,
-};
-
-enum dm_1r_cca_e {
-	CCA_1R = 0,
-	CCA_2R = 1,
-	CCA_MAX = 2,
-};
-
-enum dm_rf_e {
-	RF_SAVE = 0,
-	RF_NORMAL = 1,
-	RF_MAX = 2,
-};
-
-enum dm_sw_ant_switch_e {
-	ANS_ANTENNA_B = 1,
-	ANS_ANTENNA_A = 2,
-	ANS_ANTENNA_MAX = 3,
-};
-
-enum dm_dig_ext_port_alg_e {
-	DIG_EXT_PORT_STAGE_0 = 0,
-	DIG_EXT_PORT_STAGE_1 = 1,
-	DIG_EXT_PORT_STAGE_2 = 2,
-	DIG_EXT_PORT_STAGE_3 = 3,
-	DIG_EXT_PORT_STAGE_MAX = 4,
-};
-
-enum dm_dig_connect_e {
-	DIG_STA_DISCONNECT = 0,
-	DIG_STA_CONNECT = 1,
-	DIG_STA_BEFORE_CONNECT = 2,
-	DIG_MULTISTA_DISCONNECT = 3,
-	DIG_MULTISTA_CONNECT = 4,
-	DIG_CONNECT_MAX
-};
-
 void rtl92c_dm_init(struct ieee80211_hw *hw);
 void rtl92c_dm_watchdog(struct ieee80211_hw *hw);
 void rtl92c_dm_write_dig(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index df98a5e..8ec0f03 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -37,7 +37,9 @@
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
+#include "../rtl8192c/dm_common.h"
 #include "../rtl8192c/fw_common.h"
+#include "../rtl8192c/phy_common.h"
 #include "dm.h"
 #include "led.h"
 #include "hw.h"
@@ -53,7 +55,7 @@ static void _rtl92ce_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
 	rtlpci->reg_bcn_ctrl_val |= set_bits;
 	rtlpci->reg_bcn_ctrl_val &= ~clear_bits;
 
-	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8) rtlpci->reg_bcn_ctrl_val);
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8)rtlpci->reg_bcn_ctrl_val);
 }
 
 static void _rtl92ce_stop_tx_beacon(struct ieee80211_hw *hw)
@@ -985,7 +987,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	    !IS_92C_SERIAL(rtlhal->version)) {
 		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD, 0x30255);
 		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G2, MASKDWORD, 0x50a00);
-	} else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
+	} else if (IS_81XXC_VENDOR_UMC_B_CUT(rtlhal->version)) {
 		rtl_set_rfreg(hw, RF90_PATH_A, 0x0C, MASKDWORD, 0x894AE);
 		rtl_set_rfreg(hw, RF90_PATH_A, 0x0A, MASKDWORD, 0x1AF31);
 		rtl_set_rfreg(hw, RF90_PATH_A, RF_IPA, MASKDWORD, 0x8F425);
@@ -1330,7 +1332,7 @@ static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
 	rtl_write_word(rtlpriv, REG_GPIO_IO_SEL, 0x0790);
 	rtl_write_word(rtlpriv, REG_LEDCFG0, 0x8080);
 	rtl_write_byte(rtlpriv, REG_AFE_PLL_CTRL, 0x80);
-	if (!IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
+	if (!IS_81XXC_VENDOR_UMC_B_CUT(rtlhal->version))
 		rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
 	if (rtlpcipriv->bt_coexist.bt_coexistence) {
 		u4b_tmp = rtl_read_dword(rtlpriv, REG_AFE_XTAL_CTRL);
@@ -1494,7 +1496,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
-			index = _rtl92c_get_chnl_group((u8) i);
+			index = rtl92c_get_chnl_group((u8)i);
 
 			rtlefuse->txpwrlevel_cck[rf_path][i] =
 			    rtlefuse->eeprom_chnlarea_txpwr_cck[rf_path][index];
@@ -1543,7 +1545,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
-			index = _rtl92c_get_chnl_group((u8) i);
+			index = rtl92c_get_chnl_group((u8)i);
 
 			if (rf_path == RF90_PATH_A) {
 				rtlefuse->pwrgroup_ht20[rf_path][i] =
@@ -1573,7 +1575,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	}
 
 	for (i = 0; i < 14; i++) {
-		index = _rtl92c_get_chnl_group((u8) i);
+		index = rtl92c_get_chnl_group((u8)i);
 
 		if (!autoload_fail)
 			tempval = hwinfo[EEPROM_TXPOWERHT20DIFF + index];
@@ -1590,7 +1592,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		if (rtlefuse->txpwr_ht20diff[RF90_PATH_B][i] & BIT(3))
 			rtlefuse->txpwr_ht20diff[RF90_PATH_B][i] |= 0xF0;
 
-		index = _rtl92c_get_chnl_group((u8) i);
+		index = rtl92c_get_chnl_group((u8)i);
 
 		if (!autoload_fail)
 			tempval = hwinfo[EEPROM_TXPOWER_OFDMDIFF + index];
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h
index 5533070..98a0868 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.h
@@ -30,7 +30,7 @@
 #ifndef __RTL92CE_HW_H__
 #define __RTL92CE_HW_H__
 
-static inline u8 _rtl92c_get_chnl_group(u8 chnl)
+static inline u8 rtl92c_get_chnl_group(u8 chnl)
 {
 	u8 group;
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
index 98b2230..bc5ca98 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
@@ -35,8 +35,11 @@
 #include "def.h"
 #include "hw.h"
 #include "phy.h"
+#include "../rtl8192c/phy_common.h"
 #include "rf.h"
 #include "dm.h"
+#include "../rtl8192c/dm_common.h"
+#include "../rtl8192c/fw_common.h"
 #include "table.h"
 
 static bool _rtl92c_phy_config_mac_with_headerfile(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
index 94486cc..e5e1353 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
@@ -78,113 +78,6 @@
 
 #define RTL92C_MAX_PATH_NUM		2
 
-enum swchnlcmd_id {
-	CMDID_END,
-	CMDID_SET_TXPOWEROWER_LEVEL,
-	CMDID_BBREGWRITE10,
-	CMDID_WRITEPORT_ULONG,
-	CMDID_WRITEPORT_USHORT,
-	CMDID_WRITEPORT_UCHAR,
-	CMDID_RF_WRITEREG,
-};
-
-struct swchnlcmd {
-	enum swchnlcmd_id cmdid;
-	u32 para1;
-	u32 para2;
-	u32 msdelay;
-};
-
-enum hw90_block_e {
-	HW90_BLOCK_MAC = 0,
-	HW90_BLOCK_PHY0 = 1,
-	HW90_BLOCK_PHY1 = 2,
-	HW90_BLOCK_RF = 3,
-	HW90_BLOCK_MAXIMUM = 4,
-};
-
-enum baseband_config_type {
-	BASEBAND_CONFIG_PHY_REG = 0,
-	BASEBAND_CONFIG_AGC_TAB = 1,
-};
-
-enum ra_offset_area {
-	RA_OFFSET_LEGACY_OFDM1,
-	RA_OFFSET_LEGACY_OFDM2,
-	RA_OFFSET_HT_OFDM1,
-	RA_OFFSET_HT_OFDM2,
-	RA_OFFSET_HT_OFDM3,
-	RA_OFFSET_HT_OFDM4,
-	RA_OFFSET_HT_CCK,
-};
-
-enum antenna_path {
-	ANTENNA_NONE,
-	ANTENNA_D,
-	ANTENNA_C,
-	ANTENNA_CD,
-	ANTENNA_B,
-	ANTENNA_BD,
-	ANTENNA_BC,
-	ANTENNA_BCD,
-	ANTENNA_A,
-	ANTENNA_AD,
-	ANTENNA_AC,
-	ANTENNA_ACD,
-	ANTENNA_AB,
-	ANTENNA_ABD,
-	ANTENNA_ABC,
-	ANTENNA_ABCD
-};
-
-struct r_antenna_select_ofdm {
-	u32 r_tx_antenna:4;
-	u32 r_ant_l:4;
-	u32 r_ant_non_ht:4;
-	u32 r_ant_ht1:4;
-	u32 r_ant_ht2:4;
-	u32 r_ant_ht_s1:4;
-	u32 r_ant_non_ht_s1:4;
-	u32 ofdm_txsc:2;
-	u32 reserved:2;
-};
-
-struct r_antenna_select_cck {
-	u8 r_cckrx_enable_2:2;
-	u8 r_cckrx_enable:2;
-	u8 r_ccktx_enable:4;
-};
-
-struct efuse_contents {
-	u8 mac_addr[ETH_ALEN];
-	u8 cck_tx_power_idx[6];
-	u8 ht40_1s_tx_power_idx[6];
-	u8 ht40_2s_tx_power_idx_diff[3];
-	u8 ht20_tx_power_idx_diff[3];
-	u8 ofdm_tx_power_idx_diff[3];
-	u8 ht40_max_power_offset[3];
-	u8 ht20_max_power_offset[3];
-	u8 channel_plan;
-	u8 thermal_meter;
-	u8 rf_option[5];
-	u8 version;
-	u8 oem_id;
-	u8 regulatory;
-};
-
-struct tx_power_struct {
-	u8 cck[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 ht40_1s[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 ht40_2s[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 ht20_diff[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 legacy_ht_diff[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 legacy_ht_txpowerdiff;
-	u8 groupht20[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 groupht40[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 pwrgroup_cnt;
-	u32 mcs_original_offset[4][16];
-};
-
 bool rtl92c_phy_bb_config(struct ieee80211_hw *hw);
 u32 rtl92c_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask);
 void rtl92c_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 4bbdfb2..d86b5b5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -35,6 +35,9 @@
 #include "def.h"
 #include "phy.h"
 #include "dm.h"
+#include "../rtl8192c/dm_common.h"
+#include "../rtl8192c/fw_common.h"
+#include "../rtl8192c/phy_common.h"
 #include "hw.h"
 #include "rf.h"
 #include "sw.h"
@@ -165,7 +168,7 @@ int rtl92c_init_sw_vars(struct ieee80211_hw *hw)
 	if (IS_VENDOR_UMC_A_CUT(rtlhal->version) &&
 	    !IS_92C_SERIAL(rtlhal->version))
 		rtlpriv->cfg->fw_name = "rtlwifi/rtl8192cfwU.bin";
-	else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
+	else if (IS_81XXC_VENDOR_UMC_B_CUT(rtlhal->version))
 		rtlpriv->cfg->fw_name = "rtlwifi/rtl8192cfwU_B.bin";
 
 	rtlpriv->max_fw_size = 0x4000;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/def.h b/drivers/net/wireless/rtlwifi/rtl8192cu/def.h
index f916555..c940a87 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/def.h
@@ -38,9 +38,6 @@
 #define CHIP_VENDOR_UMC			BIT(5)
 #define CHIP_VENDOR_UMC_B_CUT		BIT(6)
 
-#define IS_NORMAL_CHIP(version)		\
-	(((version) & NORMAL_CHIP) ? true : false)
-
 #define IS_8723_SERIES(version)		\
 	(((version) & CHIP_8723) ? true : false)
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 270cbff..04aa0b5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -36,8 +36,11 @@
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
+#include "../rtl8192c/phy_common.h"
 #include "mac.h"
 #include "dm.h"
+#include "../rtl8192c/dm_common.h"
+#include "../rtl8192c/fw_common.h"
 #include "hw.h"
 #include "../rtl8192ce/hw.h"
 #include "trx.h"
@@ -180,7 +183,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				eprom_chnl_txpwr_ht40_2sdf[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
-			index = _rtl92c_get_chnl_group((u8) i);
+			index = rtl92c_get_chnl_group((u8)i);
 			rtlefuse->txpwrlevel_cck[rf_path][i] =
 			    rtlefuse->eeprom_chnlarea_txpwr_cck[rf_path][index];
 			rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
@@ -222,7 +225,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	}
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
-			index = _rtl92c_get_chnl_group((u8) i);
+			index = rtl92c_get_chnl_group((u8)i);
 			if (rf_path == RF90_PATH_A) {
 				rtlefuse->pwrgroup_ht20[rf_path][i] =
 				    (rtlefuse->eeprom_pwrlimit_ht20[index]
@@ -249,7 +252,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		}
 	}
 	for (i = 0; i < 14; i++) {
-		index = _rtl92c_get_chnl_group((u8) i);
+		index = rtl92c_get_chnl_group((u8)i);
 		if (!autoload_fail)
 			tempval = hwinfo[EEPROM_TXPOWERHT20DIFF + index];
 		else
@@ -261,7 +264,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			rtlefuse->txpwr_ht20diff[RF90_PATH_A][i] |= 0xF0;
 		if (rtlefuse->txpwr_ht20diff[RF90_PATH_B][i] & BIT(3))
 			rtlefuse->txpwr_ht20diff[RF90_PATH_B][i] |= 0xF0;
-		index = _rtl92c_get_chnl_group((u8) i);
+		index = rtl92c_get_chnl_group((u8)i);
 		if (!autoload_fail)
 			tempval = hwinfo[EEPROM_TXPOWER_OFDMDIFF + index];
 		else
@@ -1169,13 +1172,13 @@ n. LEDCFG 0x4C[15:0] = 0x8080
 	/* 1. Disable GPIO[7:0] */
 	rtl_write_word(rtlpriv, REG_GPIO_PIN_CTRL+2, 0x0000);
 	value32 = rtl_read_dword(rtlpriv, REG_GPIO_PIN_CTRL) & 0xFFFF00FF;
-	value8 = (u8) (value32&0x000000FF);
+	value8 = (u8)(value32&0x000000FF);
 	value32 |= ((value8<<8) | 0x00FF0000);
 	rtl_write_dword(rtlpriv, REG_GPIO_PIN_CTRL, value32);
 	/* 2. Disable GPIO[10:8] */
 	rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG+3, 0x00);
 	value16 = rtl_read_word(rtlpriv, REG_GPIO_MUXCFG+2) & 0xFF0F;
-	value8 = (u8) (value16&0x000F);
+	value8 = (u8)(value16&0x000F);
 	value16 |= ((value8<<4) | 0x0780);
 	rtl_write_word(rtlpriv, REG_GPIO_PIN_CTRL+2, value16);
 	/* 3. Disable LED0 & 1 */
@@ -1245,7 +1248,7 @@ static void _rtl92cu_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
 
 	rtlusb->reg_bcn_ctrl_val |= set_bits;
 	rtlusb->reg_bcn_ctrl_val &= ~clear_bits;
-	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8) rtlusb->reg_bcn_ctrl_val);
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8)rtlusb->reg_bcn_ctrl_val);
 }
 
 static void _rtl92cu_stop_tx_beacon(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 4da4008..c2d8ec6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -40,6 +40,7 @@
 #include "dm.h"
 #include "mac.h"
 #include "trx.h"
+#include "../rtl8192c/fw_common.h"
 
 #include <linux/module.h>
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
index 9831ff1..12f6d47 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
@@ -34,8 +34,11 @@
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
+#include "../rtl8192c/phy_common.h"
 #include "rf.h"
 #include "dm.h"
+#include "../rtl8192c/dm_common.h"
+#include "../rtl8192c/fw_common.h"
 #include "table.h"
 
 u32 rtl92cu_phy_query_rf_reg(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index 1ac6383..f72f0db 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -42,6 +42,7 @@
 #include "trx.h"
 #include "led.h"
 #include "hw.h"
+#include "../rtl8192c/fw_common.h"
 #include <linux/module.h>
 
 MODULE_AUTHOR("Georgia		<georgia@realtek.com>");
@@ -75,7 +76,7 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 	if (IS_VENDOR_UMC_A_CUT(rtlpriv->rtlhal.version) &&
 	    !IS_92C_SERIAL(rtlpriv->rtlhal.version)) {
 		rtlpriv->cfg->fw_name = "rtlwifi/rtl8192cufw_A.bin";
-	} else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlpriv->rtlhal.version)) {
+	} else if (IS_81XXC_VENDOR_UMC_B_CUT(rtlpriv->rtlhal.version)) {
 		rtlpriv->cfg->fw_name = "rtlwifi/rtl8192cufw_B.bin";
 	} else {
 		rtlpriv->cfg->fw_name = "rtlwifi/rtl8192cufw_TMSC.bin";
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 035e0dc..f383d5f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -38,6 +38,7 @@
 #include "dm.h"
 #include "mac.h"
 #include "trx.h"
+#include "../rtl8192c/fw_common.h"
 
 static int _ConfigVerTOutEP(struct ieee80211_hw *hw)
 {
-- 
1.8.4.5
