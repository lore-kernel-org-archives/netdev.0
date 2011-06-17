From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/4] r8169: explicit firmware format check.
Date: Fri, 17 Jun 2011 21:31:05 +0200
Message-ID: <20110617193105.GB2287@electric-eye.fr.zoreil.com>
References: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55797 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab1FQTnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:43:49 -0400
Content-Disposition: inline
In-Reply-To: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   54 +++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 42 insertions(+), 12 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3eeefe4..452db86 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -669,6 +669,15 @@ struct rtl8169_private {
 
 	struct rtl_fw {
 		const struct firmware *fw;
+
+#define RTL_VER_SIZE		32
+
+		char version[RTL_VER_SIZE];
+
+		struct rtl_fw_phy_action {
+			__le32 *code;
+			size_t size;
+		} phy_action;
 	} *rtl_fw;
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
 };
@@ -1230,7 +1239,7 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
 	strcpy(info->version, RTL8169_VERSION);
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
 	strncpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
-		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
+		rtl_fw->version, RTL_VER_SIZE);
 }
 
 static int rtl8169_get_regs_len(struct net_device *dev)
@@ -1744,21 +1753,42 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DELAY_MS		0xe0000000
 #define PHY_WRITE_ERI_WORD	0xf0000000
 
-static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+#define FW_OPCODE_SIZE	sizeof(typeof(*((struct rtl_fw_phy_action *)0)->code))
+
+static bool rtl_fw_format_ok(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 {
 	const struct firmware *fw = rtl_fw->fw;
-	__le32 *phytable = (__le32 *)fw->data;
+	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
+	bool rc = false;
+
+	if (!(fw->size % FW_OPCODE_SIZE)) {
+		snprintf(rtl_fw->version, RTL_VER_SIZE, "%s",
+			 rtl_lookup_firmware_name(tp));
+
+		pa->code = (__le32 *)fw->data;
+		pa->size = fw->size / FW_OPCODE_SIZE;
+	}
+	rtl_fw->version[RTL_VER_SIZE - 1] = 0;
+
+	rc = true;
+
+	return rc;
+}
+
+static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
+{
+	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
 	struct net_device *dev = tp->dev;
-	size_t index, fw_size = fw->size / sizeof(*phytable);
 	u32 predata, count;
+	size_t index;
 
-	if (fw->size % sizeof(*phytable)) {
-		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
+	if (!rtl_fw_format_ok(tp, rtl_fw)) {
+		netif_err(tp, probe, dev, "invalid firwmare\n");
 		return;
 	}
 
-	for (index = 0; index < fw_size; index++) {
-		u32 action = le32_to_cpu(phytable[index]);
+	for (index = 0; index < pa->size; index++) {
+		u32 action = le32_to_cpu(pa->code[index]);
 		u32 regno = (action & 0x0fff0000) >> 16;
 
 		switch(action & 0xf0000000) {
@@ -1780,7 +1810,7 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 			}
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
-			if (index + 2 >= fw_size) {
+			if (index + 2 >= pa->size) {
 				netif_err(tp, probe, tp->dev,
 					  "Out of range of firmware\n");
 				return;
@@ -1789,7 +1819,7 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 		case PHY_COMP_EQ_SKIPN:
 		case PHY_COMP_NEQ_SKIPN:
 		case PHY_SKIPN:
-			if (index + 1 + regno >= fw_size) {
+			if (index + 1 + regno >= pa->size) {
 				netif_err(tp, probe, tp->dev,
 					  "Out of range of firmware\n");
 				return;
@@ -1809,8 +1839,8 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 	predata = 0;
 	count = 0;
 
-	for (index = 0; index < fw_size; ) {
-		u32 action = le32_to_cpu(phytable[index]);
+	for (index = 0; index < pa->size; ) {
+		u32 action = le32_to_cpu(pa->code[index]);
 		u32 data = action & 0x0000ffff;
 		u32 regno = (action & 0x0fff0000) >> 16;
 
-- 
1.7.4.4

