From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: support the new RTL8153 chip
Date: Wed, 22 Jul 2015 15:27:41 +0800
Message-ID: <1394712342-15778-147-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support the new USB gigabit ethernet.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 7f6419e..57b72ec 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -622,6 +622,7 @@ enum rtl_version {
 	RTL_VER_03,
 	RTL_VER_04,
 	RTL_VER_05,
+	RTL_VER_06,
 	RTL_VER_MAX
 };
 
@@ -2560,7 +2561,10 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	u32 ocp_data;
 	u16 data;
 
-	ocp_reg_write(tp, OCP_ADC_CFG, CKADSEL_L | ADC_EN | EN_EMI_L);
+	if (tp->version == RTL_VER_03 || tp->version == RTL_VER_04 ||
+	    tp->version == RTL_VER_05)
+		ocp_reg_write(tp, OCP_ADC_CFG, CKADSEL_L | ADC_EN | EN_EMI_L);
+
 	data = r8152_mdio_read(tp, MII_BMCR);
 	if (data & BMCR_PDOWN) {
 		data &= ~BMCR_PDOWN;
@@ -3274,6 +3278,13 @@ static void r8153_init(struct r8152 *tp)
 		else
 			ocp_data |= DYNAMIC_BURST;
 		ocp_write_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY1, ocp_data);
+	} else if (tp->version == RTL_VER_06) {
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY1);
+		if (ocp_read_word(tp, MCU_TYPE_USB, USB_BURST_SIZE) == 0)
+			ocp_data &= ~DYNAMIC_BURST;
+		else
+			ocp_data |= DYNAMIC_BURST;
+		ocp_write_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY1, ocp_data);
 	}
 
 	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY2);
@@ -3908,6 +3919,10 @@ static void r8152b_get_version(struct r8152 *tp)
 		tp->version = RTL_VER_05;
 		tp->mii.supports_gmii = 1;
 		break;
+	case 0x5c30:
+		tp->version = RTL_VER_06;
+		tp->mii.supports_gmii = 1;
+		break;
 	default:
 		netif_info(tp, probe, tp->netdev,
 			   "Unknown version 0x%04x\n", version);
@@ -3953,6 +3968,7 @@ static int rtl_ops_init(struct r8152 *tp)
 	case RTL_VER_03:
 	case RTL_VER_04:
 	case RTL_VER_05:
+	case RTL_VER_06:
 		ops->init		= r8153_init;
 		ops->enable		= rtl8153_enable;
 		ops->disable		= rtl8153_disable;
-- 
2.4.2
