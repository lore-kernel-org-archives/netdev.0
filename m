From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2] net/r8169: update the new parser for the new firmware
Date: Wed, 15 Jun 2011 11:45:31 +0800
Message-ID: <1308109531-31698-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the parser for the new firmware which is embedded some information.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   96 +++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 70 insertions(+), 26 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ef1ce2e..bd9e78f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -594,6 +594,14 @@ struct ring_info {
 	u8		__pad[sizeof(void *) - sizeof(u32)];
 };
 
+struct fw_info {
+	u32	magic;
+	char	version[32];
+	u32	fw_start;
+	u32	fw_len;
+	u8	chksum;
+};
+
 enum features {
 	RTL_FEATURE_WOL		= (1 << 0),
 	RTL_FEATURE_MSI		= (1 << 1),
@@ -1740,21 +1748,57 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DELAY_MS		0xe0000000
 #define PHY_WRITE_ERI_WORD	0xf0000000
 
+static int is_firmware_valid(const struct firmware *fw)
+{
+	struct fw_info *f_info = (struct fw_info *)fw->data;
+
+	if (f_info->magic == 0) {
+		size_t i, fw_size;
+		u8 checksum = 0;
+
+		for (i = 0; i < fw->size; i++) {
+			checksum += fw->data[i];
+		}
+
+		if (checksum != 0)
+			return 0;
+
+		fw_size = (fw->size - le32_to_cpu(f_info->fw_start)) / 4;
+		if (fw_size < le32_to_cpu(f_info->fw_len))
+			return 0;
+	} else if (fw->size % 4) {
+		return 0;
+	}
+
+	return 1;
+}
+
 static void
 rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 {
-	__le32 *phytable = (__le32 *)fw->data;
+	struct fw_info *f_info = (struct fw_info *)fw->data;
 	struct net_device *dev = tp->dev;
-	size_t index, fw_size = fw->size / sizeof(*phytable);
+	__le32 *phytable;
+	size_t i, fw_size;
 	u32 predata, count;
 
-	if (fw->size % sizeof(*phytable)) {
-		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
+	if (!is_firmware_valid(fw)) {
+		netif_err(tp, probe, dev, "Invalid firwmare\n");
 		return;
 	}
 
-	for (index = 0; index < fw_size; index++) {
-		u32 action = le32_to_cpu(phytable[index]);
+	if (f_info->magic == 0) {
+		netif_info(tp, probe, dev, "firmware: %s\n", f_info->version);
+
+		phytable = (__le32 *)(fw->data + le32_to_cpu(f_info->fw_start));
+		fw_size = le32_to_cpu(f_info->fw_len);
+	} else {
+		phytable = (__le32 *)fw->data;
+		fw_size = fw->size / sizeof(*phytable);
+	}
+
+	for (i = 0; i < fw_size; i++) {
+		u32 action = le32_to_cpu(phytable[i]);
 		u32 regno = (action & 0x0fff0000) >> 16;
 
 		switch(action & 0xf0000000) {
@@ -1769,14 +1813,14 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
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
+			if (i + 2 >= fw_size) {
 				netif_err(tp, probe, tp->dev,
 					  "Out of range of firmware\n");
 				return;
@@ -1785,7 +1829,7 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_COMP_EQ_SKIPN:
 		case PHY_COMP_NEQ_SKIPN:
 		case PHY_SKIPN:
-			if (index + 1 + regno >= fw_size) {
+			if (i + 1 + regno >= fw_size) {
 				netif_err(tp, probe, tp->dev,
 					  "Out of range of firmware\n");
 				return;
@@ -1805,8 +1849,8 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 	predata = 0;
 	count = 0;
 
-	for (index = 0; index < fw_size; ) {
-		u32 action = le32_to_cpu(phytable[index]);
+	for (i = 0; i < fw_size; ) {
+		u32 action = le32_to_cpu(phytable[i]);
 		u32 data = action & 0x0000ffff;
 		u32 regno = (action & 0x0fff0000) >> 16;
 
@@ -1817,54 +1861,54 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
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
-- 
1.7.3.2
