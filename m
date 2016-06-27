From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/6] r8152: add u1u2_enable for rtl_ops
Date: Mon, 27 Jun 2016 13:07:41 +0800
Message-ID: <1394712342-15778-186-Taiwan-albertk@realtek.com>
References: <1394712342-15778-184-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60914 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbcF0GHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 02:07:02 -0400
In-Reply-To: <1394712342-15778-184-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add u1u2_enable() for rtl_ops.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b253003..f51d799 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -620,6 +620,7 @@ struct r8152 {
 		int (*eee_set)(struct r8152 *, struct ethtool_eee *);
 		bool (*in_nway)(struct r8152 *);
 		void (*aldps_enable)(struct r8152 *tp, bool enable);
+		void (*u1u2_enable)(struct r8152 *tp, bool enable);
 		void (*hw_phy_cfg)(struct r8152 *);
 	} rtl_ops;
 
@@ -2408,7 +2409,7 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 	if (enable) {
 		u32 ocp_data;
 
-		r8153_u1u2en(tp, false);
+		tp->rtl_ops.u1u2_enable(tp, false);
 		r8153_u2p3en(tp, false);
 
 		__rtl_set_wol(tp, WAKE_ANY);
@@ -2423,7 +2424,7 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 	} else {
 		__rtl_set_wol(tp, tp->saved_wolopts);
 		r8153_u2p3en(tp, true);
-		r8153_u1u2en(tp, true);
+		tp->rtl_ops.u1u2_enable(tp, true);
 	}
 }
 
@@ -2922,12 +2923,12 @@ static void rtl8153_up(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
-	r8153_u1u2en(tp, false);
+	tp->rtl_ops.u1u2_enable(tp, false);
 	tp->rtl_ops.aldps_enable(tp, false);
 	r8153_first_init(tp);
 	tp->rtl_ops.aldps_enable(tp, true);
 	r8153_u2p3en(tp, true);
-	r8153_u1u2en(tp, true);
+	tp->rtl_ops.u1u2_enable(tp, true);
 	usb_enable_lpm(tp->udev);
 }
 
@@ -2938,7 +2939,7 @@ static void rtl8153_down(struct r8152 *tp)
 		return;
 	}
 
-	r8153_u1u2en(tp, false);
+	tp->rtl_ops.u1u2_enable(tp, false);
 	r8153_u2p3en(tp, false);
 	r8153_power_cut_en(tp, false);
 	tp->rtl_ops.aldps_enable(tp, false);
@@ -4142,6 +4143,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_set		= r8152_set_eee;
 		ops->in_nway		= rtl8152_in_nway;
 		ops->aldps_enable	= r8152_aldps_en;
+		ops->u1u2_enable	= r8153_u1u2en;
 		ops->hw_phy_cfg		= r8152b_hw_phy_cfg;
 		break;
 
@@ -4159,6 +4161,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_set		= r8153_set_eee;
 		ops->in_nway		= rtl8153_in_nway;
 		ops->aldps_enable	= r8153_aldps_en;
+		ops->u1u2_enable	= r8153_u1u2en;
 		ops->hw_phy_cfg		= r8153_hw_phy_cfg;
 		break;
 
-- 
2.4.11
