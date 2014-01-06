From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 3/3] r8152: replace the return value of rtl_ops_init
Date: Mon, 6 Jan 2014 17:08:43 +0800
Message-ID: <1388999323-9059-4-git-send-email-hayeswang@realtek.com>
References: <1388990366-8508-1-git-send-email-hayeswang@realtek.com>
 <1388999323-9059-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388999323-9059-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the boolean value with the error code for the return value
of the rtl_ops_init().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8615681..881475f 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2685,10 +2685,10 @@ static void rtl8153_unload(struct r8152 *tp)
 	r8153_power_cut_en(tp, 1);
 }
 
-static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
+static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 {
 	struct rtl_ops *ops = &tp->rtl_ops;
-	bool ret = true;
+	int ret = -ENODEV;
 
 	switch (id->idVendor) {
 	case VENDOR_ID_REALTEK:
@@ -2699,6 +2699,7 @@ static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->disable		= rtl8152_disable;
 			ops->down		= rtl8152_down;
 			ops->unload		= rtl8152_unload;
+			ret = 0;
 			break;
 		case PRODUCT_ID_RTL8153:
 			ops->init		= r8153_init;
@@ -2706,9 +2707,9 @@ static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->disable		= rtl8152_disable;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
+			ret = 0;
 			break;
 		default:
-			ret = false;
 			break;
 		}
 		break;
@@ -2721,18 +2722,20 @@ static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->disable		= rtl8152_disable;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
+			ret = 0;
 			break;
 		default:
-			ret = false;
 			break;
 		}
 		break;
 
 	default:
-		ret = false;
 		break;
 	}
 
+	if (ret)
+		netif_err(tp, probe, tp->netdev, "Unknown Device\n");
+
 	return ret;
 }
 
@@ -2763,10 +2766,9 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->netdev = netdev;
 	tp->intf = intf;
 
-	if (!rtl_ops_init(tp, id)) {
-		netif_err(tp, probe, netdev, "Unknown Device");
-		return -ENODEV;
-	}
+	ret = rtl_ops_init(tp, id);
+	if (ret)
+		goto out;
 
 	tasklet_init(&tp->tl, bottom_half, (unsigned long)tp);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
-- 
1.8.4.2
