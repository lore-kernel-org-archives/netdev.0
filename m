From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net] r8152: fix the carrier off when autoresuming
Date: Tue, 23 Sep 2014 16:31:47 +0800
Message-ID: <1394712342-15778-45-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

netif_carrier_off would be called when autoresuming, even though
the cable is plugged. This causes some applications do relative
actions when detecting the carrier off. Keep the status of the
carrier, and let it be modified when the linking change occurs.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 52 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 35 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 74760e8..e039442 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1949,10 +1949,34 @@ static void rxdy_gated_en(struct r8152 *tp, bool enable)
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
 }
 
+static int rtl_start_rx(struct r8152 *tp)
+{
+	int i, ret = 0;
+
+	INIT_LIST_HEAD(&tp->rx_done);
+	for (i = 0; i < RTL8152_MAX_RX; i++) {
+		INIT_LIST_HEAD(&tp->rx_info[i].list);
+		ret = r8152_submit_rx(tp, &tp->rx_info[i], GFP_KERNEL);
+		if (ret)
+			break;
+	}
+
+	return ret;
+}
+
+static int rtl_stop_rx(struct r8152 *tp)
+{
+	int i;
+
+	for (i = 0; i < RTL8152_MAX_RX; i++)
+		usb_kill_urb(tp->rx_info[i].urb);
+
+	return 0;
+}
+
 static int rtl_enable(struct r8152 *tp)
 {
 	u32 ocp_data;
-	int i, ret;
 
 	r8152b_reset_packet_filter(tp);
 
@@ -1962,14 +1986,7 @@ static int rtl_enable(struct r8152 *tp)
 
 	rxdy_gated_en(tp, false);
 
-	INIT_LIST_HEAD(&tp->rx_done);
-	ret = 0;
-	for (i = 0; i < RTL8152_MAX_RX; i++) {
-		INIT_LIST_HEAD(&tp->rx_info[i].list);
-		ret |= r8152_submit_rx(tp, &tp->rx_info[i], GFP_KERNEL);
-	}
-
-	return ret;
+	return rtl_start_rx(tp);
 }
 
 static int rtl8152_enable(struct r8152 *tp)
@@ -2053,8 +2070,7 @@ static void rtl_disable(struct r8152 *tp)
 		mdelay(1);
 	}
 
-	for (i = 0; i < RTL8152_MAX_RX; i++)
-		usb_kill_urb(tp->rx_info[i].urb);
+	rtl_stop_rx(tp);
 
 	rtl8152_nic_reset(tp);
 }
@@ -3083,13 +3099,14 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
 		cancel_delayed_work_sync(&tp->schedule);
+		tasklet_disable(&tp->tl);
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+			rtl_stop_rx(tp);
 			rtl_runtime_suspend_enable(tp, true);
 		} else {
-			tasklet_disable(&tp->tl);
 			tp->rtl_ops.down(tp);
-			tasklet_enable(&tp->tl);
 		}
+		tasklet_enable(&tp->tl);
 	}
 
 	return 0;
@@ -3108,17 +3125,18 @@ static int rtl8152_resume(struct usb_interface *intf)
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 			rtl_runtime_suspend_enable(tp, false);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+			set_bit(WORK_ENABLE, &tp->flags);
 			if (tp->speed & LINK_STATUS)
-				tp->rtl_ops.disable(tp);
+				rtl_start_rx(tp);
 		} else {
 			tp->rtl_ops.up(tp);
 			rtl8152_set_speed(tp, AUTONEG_ENABLE,
 				tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
 				DUPLEX_FULL);
+			tp->speed = 0;
+			netif_carrier_off(tp->netdev);
+			set_bit(WORK_ENABLE, &tp->flags);
 		}
-		tp->speed = 0;
-		netif_carrier_off(tp->netdev);
-		set_bit(WORK_ENABLE, &tp->flags);
 		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 	}
 
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
