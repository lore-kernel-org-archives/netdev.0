From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 3/5] r8169: Modify the method for setting firmware
Date: Wed, 6 Feb 2013 22:46:25 +0800
Message-ID: <1360161987-3268-3-git-send-email-hayeswang@realtek.com>
References: <1360161987-3268-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:59446 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226Ab3BFOrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 09:47:03 -0500
In-Reply-To: <1360161987-3268-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove useless action PHY_READ_EFUSE, and define the new action
PHY_MDIO_CHG.

PHY_MDIO_CHG is used to modify the mdio operation. By the way, the
firmware could support setting mac ocp.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 36 ++++++++++++++++++++++++++++++++----
 1 file changed, 32 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d1bee4c..55a7fb5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1074,6 +1074,21 @@ static int r8168g_mdio_read(struct rtl8169_private *tp, int reg)
 	return r8168_phy_ocp_read(tp, tp->ocp_base + reg * 2);
 }
 
+static void mac_mcu_write(struct rtl8169_private *tp, int reg, int value)
+{
+	if (reg == 0x1f) {
+		tp->ocp_base = value << 4;
+		return;
+	}
+
+	r8168_mac_ocp_write(tp, tp->ocp_base + reg, value);
+}
+
+static int mac_mcu_read(struct rtl8169_private *tp, int reg)
+{
+	return r8168_mac_ocp_read(tp, tp->ocp_base + reg);
+}
+
 DECLARE_RTL_COND(rtl_phyar_cond)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -2139,7 +2154,7 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DATA_OR		0x10000000
 #define PHY_DATA_AND		0x20000000
 #define PHY_BJMPN		0x30000000
-#define PHY_READ_EFUSE		0x40000000
+#define PHY_MDIO_CHG		0x40000000
 #define PHY_READ_MAC_BYTE	0x50000000
 #define PHY_WRITE_MAC_BYTE	0x60000000
 #define PHY_CLEAR_READCOUNT	0x70000000
@@ -2227,7 +2242,7 @@ static bool rtl_fw_data_ok(struct rtl8169_private *tp, struct net_device *dev,
 		case PHY_READ:
 		case PHY_DATA_OR:
 		case PHY_DATA_AND:
-		case PHY_READ_EFUSE:
+		case PHY_MDIO_CHG:
 		case PHY_CLEAR_READCOUNT:
 		case PHY_WRITE:
 		case PHY_WRITE_PREVIOUS:
@@ -2291,10 +2306,13 @@ out:
 static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 {
 	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
+	struct mdio_ops org, *ops = &tp->mdio_ops;
 	u32 predata, count;
 	size_t index;
 
 	predata = count = 0;
+	org.write = ops->write;
+	org.read = ops->read;
 
 	for (index = 0; index < pa->size; ) {
 		u32 action = le32_to_cpu(pa->code[index]);
@@ -2321,8 +2339,15 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 		case PHY_BJMPN:
 			index -= regno;
 			break;
-		case PHY_READ_EFUSE:
-			predata = rtl8168d_efuse_read(tp, regno);
+		case PHY_MDIO_CHG:
+			if (data == 0) {
+				ops->write = org.write;
+				ops->read = org.read;
+			} else if (data == 1) {
+				ops->write = mac_mcu_write;
+				ops->read = mac_mcu_read;
+			}
+
 			index++;
 			break;
 		case PHY_CLEAR_READCOUNT:
@@ -2365,6 +2390,9 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 			BUG();
 		}
 	}
+
+	ops->write = org.write;
+	ops->read = org.read;
 }
 
 static void rtl_release_firmware(struct rtl8169_private *tp)
-- 
1.8.1
