From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH] net/r8169: Update the new parser for the new firmware
Date: Mon, 13 Jun 2011 17:16:34 +0800
Message-ID: <1307956594-1248-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the parser for the new firmware which is embedded some information.
The paser cannot be used for the old firmware. It is only for the new type one.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   59 ++++++++++++++++++++++++++++----------------------
 1 files changed, 33 insertions(+), 26 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ef1ce2e..87b684f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -36,11 +36,11 @@
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
 
-#define FIRMWARE_8168D_1	"rtl_nic/rtl8168d-1.fw"
-#define FIRMWARE_8168D_2	"rtl_nic/rtl8168d-2.fw"
-#define FIRMWARE_8168E_1	"rtl_nic/rtl8168e-1.fw"
-#define FIRMWARE_8168E_2	"rtl_nic/rtl8168e-2.fw"
-#define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
+#define FIRMWARE_8168D_1	"rtl_nic/rtl8168d-3.fw"
+#define FIRMWARE_8168D_2	"rtl_nic/rtl8168d-4.fw"
+#define FIRMWARE_8168E_1	"rtl_nic/rtl8168e-3.fw"
+#define FIRMWARE_8168E_2	"rtl_nic/rtl8168e-4.fw"
+#define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-2.fw"
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -594,6 +594,13 @@ struct ring_info {
 	u8		__pad[sizeof(void *) - sizeof(u32)];
 };
 
+struct fw_info {
+	char	version[32];
+	u32	fw_start;
+	u32	fw_len;
+	u8	chksum;
+};
+
 enum features {
 	RTL_FEATURE_WOL		= (1 << 0),
 	RTL_FEATURE_MSI		= (1 << 1),
@@ -1226,7 +1233,7 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
 	strcpy(info->version, RTL8169_VERSION);
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
 	strncpy(info->fw_version, IS_ERR_OR_NULL(tp->fw) ? "N/A" :
-		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
+		(char *)tp->fw->data, sizeof(info->fw_version) - 1);
 }
 
 static int rtl8169_get_regs_len(struct net_device *dev)
@@ -1743,16 +1750,30 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 static void
 rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 {
-	__le32 *phytable = (__le32 *)fw->data;
+	__le32 *phytable;
 	struct net_device *dev = tp->dev;
-	size_t index, fw_size = fw->size / sizeof(*phytable);
+	struct fw_info *f_info;
+	size_t index, fw_size;
 	u32 predata, count;
+	u8 checksum;
+
+	f_info = (struct fw_info *)fw->data;
+
+	checksum = 0;
+	for (index = 0; index < fw->size; index++) {
+		checksum += fw->data[index];
+	}
 
-	if (fw->size % sizeof(*phytable)) {
-		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
+	if (checksum != 0) {
+		netif_err(tp, probe, dev, "none zero checksum(%u)\n", checksum);
 		return;
 	}
 
+	netif_info(tp, probe, dev, "firmware: %s\n", f_info->version);
+
+	phytable = (__le32 *)(fw->data + f_info->fw_start);
+	fw_size = f_info->fw_len;
+
 	for (index = 0; index < fw_size; index++) {
 		u32 action = le32_to_cpu(phytable[index]);
 		u32 regno = (action & 0x0fff0000) >> 16;
@@ -1892,14 +1913,6 @@ static void rtl_apply_firmware(struct rtl8169_private *tp)
 		rtl_phy_write_fw(tp, fw);
 }
 
-static void rtl_apply_firmware_cond(struct rtl8169_private *tp, u8 reg, u16 val)
-{
-	if (rtl_readphy(tp, reg) != val)
-		netif_warn(tp, hw, tp->dev, "chipset not ready for firmware\n");
-	else
-		rtl_apply_firmware(tp);
-}
-
 static void rtl8169s_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -2334,10 +2347,7 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x02, 0x0100, 0x0600);
 	rtl_w1w0_phy(tp, 0x03, 0x0000, 0xe000);
 
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x001b);
-
-	rtl_apply_firmware_cond(tp, MII_EXPANSION, 0xbf00);
+	rtl_apply_firmware(tp);
 
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
@@ -2437,10 +2447,7 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0002);
 	rtl_patchphy(tp, 0x0f, 0x0017);
 
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x001b);
-
-	rtl_apply_firmware_cond(tp, MII_EXPANSION, 0xb300);
+	rtl_apply_firmware(tp);
 
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
-- 
1.7.3.2
