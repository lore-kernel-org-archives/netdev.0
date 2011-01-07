From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH] net/r8169: Update the function of parsing firmware
Date: Fri, 7 Jan 2011 17:45:09 +0800
Message-ID: <1294393509-3492-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update rtl_phy_write_fw function. The new function could
parse the complex firmware which is used by RTL8111E and later.
The new firmware may read data and do some operations, not just
do writing only.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |  112 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 97 insertions(+), 15 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 27a7c20..2115424 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1632,39 +1632,121 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 {
 	__le32 *phytable = (__le32 *)fw->data;
 	struct net_device *dev = tp->dev;
-	size_t i;
+	size_t index;
+	u32 predata, count;
 
 	if (fw->size % sizeof(*phytable)) {
-		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
+		netif_err(tp, probe, dev, "odd sized firmware %zd\n",
+			  fw->size);
 		return;
 	}
 
-	for (i = 0; i < fw->size / sizeof(*phytable); i++) {
-		u32 action = le32_to_cpu(phytable[i]);
+	for (index = 0; index < fw->size / sizeof(*phytable); index++) {
+		u32 action = le32_to_cpu(phytable[index]);
 
-		if (!action)
+		switch(action & 0xF0000000) {
+		case PHY_READ:
+		case PHY_DATA_OR:
+		case PHY_DATA_AND:
+		case PHY_BJMPN:
+		case PHY_READ_EFUSE:
+		case PHY_CLEAR_READCOUNT:
+		case PHY_WRITE:
+		case PHY_READCOUNT_EQ_SKIP:
+		case PHY_COMP_EQ_SKIPN:
+		case PHY_COMP_NEQ_SKIPN:
+		case PHY_WRITE_PREVIOUS:
+		case PHY_SKIPN:
+		case PHY_DELAY_MS:
 			break;
 
-		if ((action & 0xf0000000) != PHY_WRITE) {
-			netif_err(tp, probe, dev,
-				  "unknown action 0x%08x\n", action);
+		case PHY_READ_MAC_BYTE:
+		case PHY_WRITE_MAC_BYTE:
+		case PHY_WRITE_ERI_WORD:
+		default:
+			netif_err(tp, probe, tp->dev,
+				  "Invalid action 0x%08x\n", action);
 			return;
 		}
 	}
 
-	while (i-- != 0) {
-		u32 action = le32_to_cpu(*phytable);
-		u32 data = action & 0x0000ffff;
-		u32 reg = (action & 0x0fff0000) >> 16;
+	predata = 0;
+	count = 0;
+
+	for (index = 0; index < fw->size / sizeof(*phytable); ) {
+		u32 action = le32_to_cpu(phytable[index]);
+		u32 data = action & 0x0000FFFF;
+		u32 regno = (action & 0x0FFF0000) >> 16;
+
+		if (!action)
+			break;
 
-		switch(action & 0xf0000000) {
+		switch(action & 0xF0000000) {
+		case PHY_READ:
+			predata = rtl_readphy(tp, regno);
+			count++;
+			index++;
+			break;
+		case PHY_DATA_OR:
+			predata |= data;
+			index++;
+			break;
+		case PHY_DATA_AND:
+			predata &= data;
+			index++;
+			break;
+		case PHY_BJMPN:
+			index -= regno;
+			break;
+		case PHY_READ_EFUSE:
+			predata = rtl8168d_efuse_read(tp->mmio_addr, regno);
+			index++;
+			break;
+		case PHY_CLEAR_READCOUNT:
+			count = 0;
+			index++;
+			break;
 		case PHY_WRITE:
-			rtl_writephy(tp, reg, data);
-			phytable++;
+			rtl_writephy(tp, regno, data);
+			index++;
+			break;
+		case PHY_READCOUNT_EQ_SKIP:
+			if (count == data)
+				index += 2;
+			else
+				index += 1;
+			break;
+		case PHY_COMP_EQ_SKIPN:
+			if (predata == data)
+				index += regno;
+			index++;
+			break;
+		case PHY_COMP_NEQ_SKIPN:
+			if (predata != data)
+				index += regno;
+			index++;
+			break;
+		case PHY_WRITE_PREVIOUS:
+			rtl_writephy(tp, regno, predata);
+			index++;
 			break;
+		case PHY_SKIPN:
+			index += regno + 1;
+			break;
+		case PHY_DELAY_MS:
+			mdelay(data);
+			index++;
+			break;
+
+		case PHY_READ_MAC_BYTE:
+		case PHY_WRITE_MAC_BYTE:
+		case PHY_WRITE_ERI_WORD:
 		default:
 			BUG();
 		}
+
+		if (index < 0)
+			BUG();
 	}
 }
 
-- 
1.7.3.2
