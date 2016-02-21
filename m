From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 3/5] bnx2x: Correct 84858 PHY fw version
Date: Sun, 21 Feb 2016 15:07:27 +0200
Message-ID: <1456060049-10678-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:51162 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751652AbcBURp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:45:29 -0500
In-Reply-To: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy's firmware version isn't being parsed properly as it's
currently parsed like the rest of the 848xx phys.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 92 ++++++++++++++++++++----
 1 file changed, 79 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index b496e4a..0c7b1c7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6185,26 +6185,80 @@ static int bnx2x_format_ver(u32 num, u8 *str, u16 *len)
 		shift -= 4;
 		digit = ((num & mask) >> shift);
 		if (digit == 0 && remove_leading_zeros) {
-			mask = mask >> 4;
-			continue;
-		} else if (digit < 0xa)
-			*str_ptr = digit + '0';
-		else
-			*str_ptr = digit - 0xa + 'a';
-		remove_leading_zeros = 0;
-		str_ptr++;
-		(*len)--;
+			*str_ptr = '0';
+		} else {
+			if (digit < 0xa)
+				*str_ptr = digit + '0';
+			else
+				*str_ptr = digit - 0xa + 'a';
+
+			remove_leading_zeros = 0;
+			str_ptr++;
+			(*len)--;
+		}
 		mask = mask >> 4;
 		if (shift == 4*4) {
+			if (remove_leading_zeros) {
+				str_ptr++;
+				(*len)--;
+			}
 			*str_ptr = '.';
 			str_ptr++;
 			(*len)--;
 			remove_leading_zeros = 1;
 		}
 	}
+	if (remove_leading_zeros)
+		(*len)--;
 	return 0;
 }
 
+static int bnx2x_3_seq_format_ver(u32 num, u8 *str, u16 *len)
+{
+	u8 *str_ptr = str;
+	u32 mask = 0x00f00000;
+	u8 shift = 8*3;
+	u8 digit;
+	u8 remove_leading_zeros = 1;
+
+	if (*len < 10) {
+		/* Need more than 10chars for this format */
+		*str_ptr = '\0';
+		(*len)--;
+		return -EINVAL;
+	}
+
+	while (shift > 0) {
+		shift -= 4;
+		digit = ((num & mask) >> shift);
+		if (digit == 0 && remove_leading_zeros) {
+			*str_ptr = '0';
+		} else {
+			if (digit < 0xa)
+				*str_ptr = digit + '0';
+			else
+				*str_ptr = digit - 0xa + 'a';
+
+			remove_leading_zeros = 0;
+			str_ptr++;
+			(*len)--;
+		}
+		mask = mask >> 4;
+		if ((shift == 4*4) || (shift == 4*2)) {
+			if (remove_leading_zeros) {
+				str_ptr++;
+				(*len)--;
+			}
+			*str_ptr = '.';
+			str_ptr++;
+			(*len)--;
+			remove_leading_zeros = 1;
+		}
+	}
+	if (remove_leading_zeros)
+		(*len)--;
+	return 0;
+}
 
 static int bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
 {
@@ -9677,8 +9731,9 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 
 	if (bnx2x_is_8483x_8485x(phy)) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD, 0x400f, &fw_ver1);
-		bnx2x_save_spirom_version(bp, port, fw_ver1 & 0xfff,
-				phy->ver_addr);
+		if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858)
+			fw_ver1 &= 0xfff;
+		bnx2x_save_spirom_version(bp, port, fw_ver1, phy->ver_addr);
 	} else {
 		/* For 32-bit registers in 848xx, access via MDIO2ARM i/f. */
 		/* (1) set reg 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
@@ -9775,7 +9830,7 @@ static void bnx2x_848xx_specific_func(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	switch (action) {
 	case PHY_INIT:
-		if (!bnx2x_is_8483x_8485x(phy)) {
+		if (bnx2x_is_8483x_8485x(phy)) {
 			/* Save spirom version */
 			bnx2x_save_848xx_spirom_version(phy, bp, params->port);
 		}
@@ -10581,6 +10636,17 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 	return link_up;
 }
 
+static int bnx2x_8485x_format_ver(u32 raw_ver, u8 *str, u16 *len)
+{
+	int status = 0;
+	u32 num;
+
+	num = ((raw_ver & 0xF80) >> 7) << 16 | ((raw_ver & 0x7F) << 8) |
+	      ((raw_ver & 0xF000) >> 12);
+	status = bnx2x_3_seq_format_ver(num, str, len);
+	return status;
+}
+
 static int bnx2x_848xx_format_ver(u32 raw_ver, u8 *str, u16 *len)
 {
 	int status = 0;
@@ -12008,7 +12074,7 @@ static const struct bnx2x_phy phy_84858 = {
 	.read_status	= (read_status_t)bnx2x_848xx_read_status,
 	.link_reset	= (link_reset_t)bnx2x_848x3_link_reset,
 	.config_loopback = (config_loopback_t)NULL,
-	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_8485x_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_84833_hw_reset_phy,
 	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)bnx2x_848xx_specific_func
-- 
1.9.3
