From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/6] r8152: add power_cut_en for rtl_ops
Date: Mon, 27 Jun 2016 13:07:42 +0800
Message-ID: <1394712342-15778-187-Taiwan-albertk@realtek.com>
References: <1394712342-15778-184-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-184-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add power_cut_en() for rtl_ops.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f51d799..a4f8a01 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -622,6 +622,7 @@ struct r8152 {
 		void (*aldps_enable)(struct r8152 *tp, bool enable);
 		void (*u1u2_enable)(struct r8152 *tp, bool enable);
 		void (*hw_phy_cfg)(struct r8152 *);
+		void (*power_cut_en)(struct r8152 *tp, bool enable);
 	} rtl_ops;
 
 	int intr_interval;
@@ -2391,6 +2392,13 @@ static void r8153_power_cut_en(struct r8152 *tp, bool enable)
 	else
 		ocp_data &= ~(PWR_EN | PHASE2_EN);
 	ocp_write_word(tp, MCU_TYPE_USB, USB_POWER_CUT, ocp_data);
+}
+
+static void r8153A_power_cut_en(struct r8152 *tp, bool enable)
+{
+	u32 ocp_data;
+
+	r8153_power_cut_en(tp, enable);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
 	ocp_data &= ~PCUT_STATUS;
@@ -2941,7 +2949,7 @@ static void rtl8153_down(struct r8152 *tp)
 
 	tp->rtl_ops.u1u2_enable(tp, false);
 	r8153_u2p3en(tp, false);
-	r8153_power_cut_en(tp, false);
+	tp->rtl_ops.power_cut_en(tp, false);
 	tp->rtl_ops.aldps_enable(tp, false);
 	r8153_enter_oob(tp);
 	tp->rtl_ops.aldps_enable(tp, true);
@@ -3397,7 +3405,7 @@ static void r8153_init(struct r8152 *tp)
 
 	ocp_write_word(tp, MCU_TYPE_USB, USB_CONNECT_TIMER, 0x0001);
 
-	r8153_power_cut_en(tp, false);
+	r8153A_power_cut_en(tp, false);
 	r8153_u1u2en(tp, true);
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL, ALDPS_SPDWN_RATIO);
@@ -4122,7 +4130,7 @@ static void rtl8153_unload(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
-	r8153_power_cut_en(tp, false);
+	tp->rtl_ops.power_cut_en(tp, false);
 }
 
 static int rtl_ops_init(struct r8152 *tp)
@@ -4145,6 +4153,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->aldps_enable	= r8152_aldps_en;
 		ops->u1u2_enable	= r8153_u1u2en;
 		ops->hw_phy_cfg		= r8152b_hw_phy_cfg;
+		ops->power_cut_en	= r8152_power_cut_en;
 		break;
 
 	case RTL_VER_03:
@@ -4163,6 +4172,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->aldps_enable	= r8153_aldps_en;
 		ops->u1u2_enable	= r8153_u1u2en;
 		ops->hw_phy_cfg		= r8153_hw_phy_cfg;
+		ops->power_cut_en	= r8153A_power_cut_en;
 		break;
 
 	default:
-- 
2.4.11
