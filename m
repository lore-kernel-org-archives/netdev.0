From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/3] r8152: save the speed
Date: Mon, 13 Jun 2016 17:49:38 +0800
Message-ID: <1394712342-15778-178-Taiwan-albertk@realtek.com>
References: <1394712342-15778-175-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-175-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The user may change the speed. Use it to replace the default one.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index dcdc4fa..69d1bbfd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -628,8 +628,11 @@ struct r8152 {
 	u32 tx_qlen;
 	u32 coalesce;
 	u16 ocp_base;
+	u16 speed;
 	u8 *intr_buff;
 	u8 version;
+	u8 duplex;
+	u8 autoneg;
 };
 
 enum rtl_version {
@@ -3051,9 +3054,7 @@ static void rtl_hw_phy_work_func_t(struct work_struct *work)
 
 	tp->rtl_ops.hw_phy_cfg(tp);
 
-	rtl8152_set_speed(tp, AUTONEG_ENABLE,
-			  tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
-			  DUPLEX_FULL);
+	rtl8152_set_speed(tp, tp->autoneg, tp->speed, tp->duplex);
 
 	mutex_unlock(&tp->control);
 
@@ -3679,6 +3680,11 @@ static int rtl8152_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	mutex_lock(&tp->control);
 
 	ret = rtl8152_set_speed(tp, cmd->autoneg, cmd->speed, cmd->duplex);
+	if (!ret) {
+		tp->autoneg = cmd->autoneg;
+		tp->speed = cmd->speed;
+		tp->duplex = cmd->duplex;
+	}
 
 	mutex_unlock(&tp->control);
 
@@ -4239,6 +4245,10 @@ static int rtl8152_probe(struct usb_interface *intf,
 		break;
 	}
 
+	tp->autoneg = AUTONEG_ENABLE;
+	tp->speed = tp->mii.supports_gmii ? SPEED_1000 : SPEED_100;
+	tp->duplex = DUPLEX_FULL;
+
 	intf->needs_remote_wakeup = 1;
 
 	tp->rtl_ops.init(tp);
-- 
2.4.11
