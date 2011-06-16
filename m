From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net/r8169: update the new parser for the new firmware
Date: Fri, 17 Jun 2011 00:59:04 +0200
Message-ID: <20110616225904.GA2064@electric-eye.fr.zoreil.com>
References: <1308109531-31698-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33079 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab1FPXLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 19:11:42 -0400
Content-Disposition: inline
In-Reply-To: <1308109531-31698-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
> Update the parser for the new firmware which is embedded some information.

I have modified several things :
- s/u32/__le32/ in fw_info
- fix unsigned (size_t) comparisons
- more size checks before dereferencing fw_info

The new firmware format should be the same. The old r8168d-1.fw firmware
proved usable when prefixed with :

0000000: 0000 0000 3031 0000 0000 0000 0000 0000  ....01..........
0000010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000020: 0000 0000 3000 0000 7501 0000 a000 0000  ....0...u.......

I realized after testing that netif_err could be abused with non-string
fw_info.version. :o/

Comments ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7310824..5a0a7c3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1741,21 +1741,82 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DELAY_MS		0xe0000000
 #define PHY_WRITE_ERI_WORD	0xf0000000
 
+struct fw_info {
+	u32	magic;
+	char	version[32];
+	__le32	fw_start;
+	__le32	fw_len;
+	u8	chksum;
+} __packed;
+
+struct fw_phy_code {
+	__le32 *code;
+	size_t size;
+};
+
+#define FW_OPCODE_SIZE	sizeof(typeof(*((struct fw_phy_code *)0)->code))
+
+static bool rtl_fw_format_ok(struct rtl8169_private *tp, struct net_device *dev,
+			     const struct firmware *fw, struct fw_phy_code *pc)
+{
+	struct fw_info *fw_info = (struct fw_info *)fw->data;
+	bool rc = false;
+
+	if (fw->size < FW_OPCODE_SIZE)
+		goto out;
+
+	if (fw_info->magic == 0) {
+		size_t i, size, start;
+		u8 checksum = 0;
+
+		if (fw->size < sizeof(*fw_info))
+			goto out;
+
+		for (i = 0; i < fw->size; i++)
+			checksum += fw->data[i];
+		if (checksum != 0)
+			goto out;
+
+		start = le32_to_cpu(fw_info->fw_start);
+		if (start > fw->size)
+			goto out;
+
+		size = le32_to_cpu(fw_info->fw_len);
+		if (size > (fw->size - start) / FW_OPCODE_SIZE)
+			goto out;
+
+		netif_info(tp, probe, dev, "firmware: %s\n", fw_info->version);
+		pc->code = (__le32 *)(fw->data + start);
+		pc->size = size;
+	} else {
+		if (fw->size % FW_OPCODE_SIZE)
+			goto out;
+
+		netif_info(tp, probe, dev, "legacy firmware format detected\n");
+		pc->code = (__le32 *)fw->data;
+		pc->size = fw->size / FW_OPCODE_SIZE;
+	}
+
+	rc = true;
+out:
+	return rc;
+}
+
 static void
 rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 {
-	__le32 *phytable = (__le32 *)fw->data;
 	struct net_device *dev = tp->dev;
-	size_t index, fw_size = fw->size / sizeof(*phytable);
+	struct fw_phy_code phytable;
 	u32 predata, count;
+	size_t i;
 
-	if (fw->size % sizeof(*phytable)) {
-		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
+	if (!rtl_fw_format_ok(tp, dev, fw, &phytable)) {
+		netif_err(tp, probe, dev, "invalid firwmare\n");
 		return;
 	}
 
-	for (index = 0; index < fw_size; index++) {
-		u32 action = le32_to_cpu(phytable[index]);
+	for (i = 0; i < phytable.size; i++) {
+		u32 action = le32_to_cpu(phytable.code[i]);
 		u32 regno = (action & 0x0fff0000) >> 16;
 
 		switch(action & 0xf0000000) {
@@ -1770,14 +1831,14 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 			break;
 
 		case PHY_BJMPN:
-			if (regno > index) {
+			if (regno > i) {
 				netif_err(tp, probe, tp->dev,
 					  "Out of range of firmware\n");
 				return;
 			}
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
-			if (index + 2 >= fw_size) {
+			if (i + 2 >= phytable.size) {
 				netif_err(tp, probe, tp->dev,
 					  "Out of range of firmware\n");
 				return;
@@ -1786,7 +1847,7 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_COMP_EQ_SKIPN:
 		case PHY_COMP_NEQ_SKIPN:
 		case PHY_SKIPN:
-			if (index + 1 + regno >= fw_size) {
+			if (i + 1 + regno >= phytable.size) {
 				netif_err(tp, probe, tp->dev,
 					  "Out of range of firmware\n");
 				return;
@@ -1806,8 +1867,8 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 	predata = 0;
 	count = 0;
 
-	for (index = 0; index < fw_size; ) {
-		u32 action = le32_to_cpu(phytable[index]);
+	for (i = 0; i < phytable.size; ) {
+		u32 action = le32_to_cpu(phytable.code[i]);
 		u32 data = action & 0x0000ffff;
 		u32 regno = (action & 0x0fff0000) >> 16;
 
@@ -1818,54 +1879,54 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_READ:
 			predata = rtl_readphy(tp, regno);
 			count++;
-			index++;
+			i++;
 			break;
 		case PHY_DATA_OR:
 			predata |= data;
-			index++;
+			i++;
 			break;
 		case PHY_DATA_AND:
 			predata &= data;
-			index++;
+			i++;
 			break;
 		case PHY_BJMPN:
-			index -= regno;
+			i -= regno;
 			break;
 		case PHY_READ_EFUSE:
 			predata = rtl8168d_efuse_read(tp->mmio_addr, regno);
-			index++;
+			i++;
 			break;
 		case PHY_CLEAR_READCOUNT:
 			count = 0;
-			index++;
+			i++;
 			break;
 		case PHY_WRITE:
 			rtl_writephy(tp, regno, data);
-			index++;
+			i++;
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
-			index += (count == data) ? 2 : 1;
+			i += (count == data) ? 2 : 1;
 			break;
 		case PHY_COMP_EQ_SKIPN:
 			if (predata == data)
-				index += regno;
-			index++;
+				i += regno;
+			i++;
 			break;
 		case PHY_COMP_NEQ_SKIPN:
 			if (predata != data)
-				index += regno;
-			index++;
+				i += regno;
+			i++;
 			break;
 		case PHY_WRITE_PREVIOUS:
 			rtl_writephy(tp, regno, predata);
-			index++;
+			i++;
 			break;
 		case PHY_SKIPN:
-			index += regno + 1;
+			i += regno + 1;
 			break;
 		case PHY_DELAY_MS:
 			mdelay(data);
-			index++;
+			i++;
 			break;
 
 		case PHY_READ_MAC_BYTE:
