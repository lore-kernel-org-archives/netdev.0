From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/7] r8169: Modify the method for setting firmware
Date: Mon, 1 Apr 2013 21:55:35 +0800
Message-ID: <1364824539-4156-3-git-send-email-hayeswang@realtek.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove useless action PHY_READ_EFUSE, PHY_READ_MAC_BYTE, PHY_WRITE_MAC_BYTE,
PHY_WRITE_ERI_WORD. And define the new action PHY_MDIO_CHG.

PHY_MDIO_CHG is used to modify the mdio operation. By the way, the
firmware could support setting mac ocp.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 45 +++++++++++++++++++++++++-----------
 1 file changed, 32 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b8b59a9..e7e7d37 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1069,6 +1069,21 @@ static int r8168g_mdio_read(struct rtl8169_private *tp, int reg)
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
@@ -2134,9 +2149,7 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DATA_OR		0x10000000
 #define PHY_DATA_AND		0x20000000
 #define PHY_BJMPN		0x30000000
-#define PHY_READ_EFUSE		0x40000000
-#define PHY_READ_MAC_BYTE	0x50000000
-#define PHY_WRITE_MAC_BYTE	0x60000000
+#define PHY_MDIO_CHG		0x40000000
 #define PHY_CLEAR_READCOUNT	0x70000000
 #define PHY_WRITE		0x80000000
 #define PHY_READCOUNT_EQ_SKIP	0x90000000
@@ -2145,7 +2158,6 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_WRITE_PREVIOUS	0xc0000000
 #define PHY_SKIPN		0xd0000000
 #define PHY_DELAY_MS		0xe0000000
-#define PHY_WRITE_ERI_WORD	0xf0000000
 
 struct fw_info {
 	u32	magic;
@@ -2222,7 +2234,7 @@ static bool rtl_fw_data_ok(struct rtl8169_private *tp, struct net_device *dev,
 		case PHY_READ:
 		case PHY_DATA_OR:
 		case PHY_DATA_AND:
-		case PHY_READ_EFUSE:
+		case PHY_MDIO_CHG:
 		case PHY_CLEAR_READCOUNT:
 		case PHY_WRITE:
 		case PHY_WRITE_PREVIOUS:
@@ -2253,9 +2265,6 @@ static bool rtl_fw_data_ok(struct rtl8169_private *tp, struct net_device *dev,
 			}
 			break;
 
-		case PHY_READ_MAC_BYTE:
-		case PHY_WRITE_MAC_BYTE:
-		case PHY_WRITE_ERI_WORD:
 		default:
 			netif_err(tp, ifup, tp->dev,
 				  "Invalid action 0x%08x\n", action);
@@ -2286,10 +2295,13 @@ out:
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
@@ -2316,8 +2328,15 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
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
@@ -2353,13 +2372,13 @@ static void rtl_phy_write_fw(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 			index++;
 			break;
 
-		case PHY_READ_MAC_BYTE:
-		case PHY_WRITE_MAC_BYTE:
-		case PHY_WRITE_ERI_WORD:
 		default:
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
