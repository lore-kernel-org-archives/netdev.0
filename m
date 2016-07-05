From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net] r8152: fix runtime function for RTL8152
Date: Tue, 5 Jul 2016 16:11:46 +0800
Message-ID: <1394712342-15778-207-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The RTL8152 doesn't have U1U2 and U2P3 features, so use different
runtime functions for RTL812 and RTL8153 by adding autosuspend_en()
to rtl_ops.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d7f20a9..0da72d3 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -31,7 +31,7 @@
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"4"
+#define NET_VERSION		"5"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>"
@@ -624,6 +624,7 @@ struct r8152 {
 		int (*eee_get)(struct r8152 *, struct ethtool_eee *);
 		int (*eee_set)(struct r8152 *, struct ethtool_eee *);
 		bool (*in_nway)(struct r8152 *);
+		void (*autosuspend_en)(struct r8152 *tp, bool enable);
 	} rtl_ops;
 
 	int intr_interval;
@@ -2408,9 +2409,6 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 	if (enable) {
 		u32 ocp_data;
 
-		r8153_u1u2en(tp, false);
-		r8153_u2p3en(tp, false);
-
 		__rtl_set_wol(tp, WAKE_ANY);
 
 		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
@@ -2432,7 +2430,17 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 		ocp_write_word(tp, MCU_TYPE_PLA, PLA_CONFIG34, ocp_data);
 
 		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
+	}
+}
 
+static void rtl8153_runtime_enable(struct r8152 *tp, bool enable)
+{
+	rtl_runtime_suspend_enable(tp, enable);
+
+	if (enable) {
+		r8153_u1u2en(tp, false);
+		r8153_u2p3en(tp, false);
+	} else {
 		r8153_u2p3en(tp, true);
 		r8153_u1u2en(tp, true);
 	}
@@ -3523,7 +3531,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 		napi_disable(&tp->napi);
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 			rtl_stop_rx(tp);
-			rtl_runtime_suspend_enable(tp, true);
+			tp->rtl_ops.autosuspend_en(tp, true);
 		} else {
 			cancel_delayed_work_sync(&tp->schedule);
 			tp->rtl_ops.down(tp);
@@ -3549,7 +3557,7 @@ static int rtl8152_resume(struct usb_interface *intf)
 
 	if (netif_running(tp->netdev) && tp->netdev->flags & IFF_UP) {
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
-			rtl_runtime_suspend_enable(tp, false);
+			tp->rtl_ops.autosuspend_en(tp, false);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 			napi_disable(&tp->napi);
 			set_bit(WORK_ENABLE, &tp->flags);
@@ -3568,7 +3576,7 @@ static int rtl8152_resume(struct usb_interface *intf)
 		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 	} else if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 		if (tp->netdev->flags & IFF_UP)
-			rtl_runtime_suspend_enable(tp, false);
+			tp->rtl_ops.autosuspend_en(tp, false);
 		clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 	}
 
@@ -4148,6 +4156,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_get		= r8152_get_eee;
 		ops->eee_set		= r8152_set_eee;
 		ops->in_nway		= rtl8152_in_nway;
+		ops->autosuspend_en	= rtl_runtime_suspend_enable;
 		break;
 
 	case RTL_VER_03:
@@ -4163,6 +4172,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_get		= r8153_get_eee;
 		ops->eee_set		= r8153_set_eee;
 		ops->in_nway		= rtl8153_in_nway;
+		ops->autosuspend_en	= rtl8153_runtime_enable;
 		break;
 
 	default:
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
