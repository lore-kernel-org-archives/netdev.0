From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: modify rtl_ops_init
Date: Thu, 6 Nov 2014 12:47:39 +0800
Message-ID: <1394712342-15778-86-Taiwan-albertk@realtek.com>
References: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-84-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace using VID/PID with using tp->version to initialize the ops.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 79 ++++++++++++++++++-------------------------------
 1 file changed, 28 insertions(+), 51 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4b6db8a..cf1b8a7 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3742,66 +3742,43 @@ static void rtl8153_unload(struct r8152 *tp)
 	r8153_power_cut_en(tp, false);
 }
 
-static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
+static int rtl_ops_init(struct r8152 *tp)
 {
 	struct rtl_ops *ops = &tp->rtl_ops;
-	int ret = -ENODEV;
-
-	switch (id->idVendor) {
-	case VENDOR_ID_REALTEK:
-		switch (id->idProduct) {
-		case PRODUCT_ID_RTL8152:
-			ops->init		= r8152b_init;
-			ops->enable		= rtl8152_enable;
-			ops->disable		= rtl8152_disable;
-			ops->up			= rtl8152_up;
-			ops->down		= rtl8152_down;
-			ops->unload		= rtl8152_unload;
-			ops->eee_get		= r8152_get_eee;
-			ops->eee_set		= r8152_set_eee;
-			ret = 0;
-			break;
-		case PRODUCT_ID_RTL8153:
-			ops->init		= r8153_init;
-			ops->enable		= rtl8153_enable;
-			ops->disable		= rtl8153_disable;
-			ops->up			= rtl8153_up;
-			ops->down		= rtl8153_down;
-			ops->unload		= rtl8153_unload;
-			ops->eee_get		= r8153_get_eee;
-			ops->eee_set		= r8153_set_eee;
-			ret = 0;
-			break;
-		default:
-			break;
-		}
+	int ret = 0;
+
+	switch (tp->version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		ops->init		= r8152b_init;
+		ops->enable		= rtl8152_enable;
+		ops->disable		= rtl8152_disable;
+		ops->up			= rtl8152_up;
+		ops->down		= rtl8152_down;
+		ops->unload		= rtl8152_unload;
+		ops->eee_get		= r8152_get_eee;
+		ops->eee_set		= r8152_set_eee;
 		break;
 
-	case VENDOR_ID_SAMSUNG:
-		switch (id->idProduct) {
-		case PRODUCT_ID_SAMSUNG:
-			ops->init		= r8153_init;
-			ops->enable		= rtl8153_enable;
-			ops->disable		= rtl8153_disable;
-			ops->up			= rtl8153_up;
-			ops->down		= rtl8153_down;
-			ops->unload		= rtl8153_unload;
-			ops->eee_get		= r8153_get_eee;
-			ops->eee_set		= r8153_set_eee;
-			ret = 0;
-			break;
-		default:
-			break;
-		}
+	case RTL_VER_03:
+	case RTL_VER_04:
+	case RTL_VER_05:
+		ops->init		= r8153_init;
+		ops->enable		= rtl8153_enable;
+		ops->disable		= rtl8153_disable;
+		ops->up			= rtl8153_up;
+		ops->down		= rtl8153_down;
+		ops->unload		= rtl8153_unload;
+		ops->eee_get		= r8153_get_eee;
+		ops->eee_set		= r8153_set_eee;
 		break;
 
 	default:
+		ret = -ENODEV;
+		netif_err(tp, probe, tp->netdev, "Unknown Device\n");
 		break;
 	}
 
-	if (ret)
-		netif_err(tp, probe, tp->netdev, "Unknown Device\n");
-
 	return ret;
 }
 
@@ -3834,7 +3811,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->intf = intf;
 
 	r8152b_get_version(tp);
-	ret = rtl_ops_init(tp, id);
+	ret = rtl_ops_init(tp);
 	if (ret)
 		goto out;
 
-- 
1.9.3
