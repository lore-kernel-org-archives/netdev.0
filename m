From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 1/2] r8152: add pre_reset and post_reset
Date: Tue, 28 Jul 2015 20:08:41 +0800
Message-ID: <1394712342-15778-160-Taiwan-albertk@realtek.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
 <1394712342-15778-159-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-159-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add rtl8152_pre_reset() and rtl8152_post_reset() which are used when
calling usb_reset_device(). The two functions could reduce the time
of reset when calling usb_reset_device() after probe().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 144dc64..e1b6d6d 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3342,6 +3342,58 @@ static void r8153_init(struct r8152 *tp)
 	r8153_u2p3en(tp, true);
 }
 
+static int rtl8152_pre_reset(struct usb_interface *intf)
+{
+	struct r8152 *tp = usb_get_intfdata(intf);
+	struct net_device *netdev;
+
+	if (!tp)
+		return 0;
+
+	netdev = tp->netdev;
+	if (!netif_running(netdev))
+		return 0;
+
+	napi_disable(&tp->napi);
+	clear_bit(WORK_ENABLE, &tp->flags);
+	usb_kill_urb(tp->intr_urb);
+	cancel_delayed_work_sync(&tp->schedule);
+	if (netif_carrier_ok(netdev)) {
+		netif_stop_queue(netdev);
+		mutex_lock(&tp->control);
+		tp->rtl_ops.disable(tp);
+		mutex_unlock(&tp->control);
+	}
+
+	return 0;
+}
+
+static int rtl8152_post_reset(struct usb_interface *intf)
+{
+	struct r8152 *tp = usb_get_intfdata(intf);
+	struct net_device *netdev;
+
+	if (!tp)
+		return 0;
+
+	netdev = tp->netdev;
+	if (!netif_running(netdev))
+		return 0;
+
+	set_bit(WORK_ENABLE, &tp->flags);
+	if (netif_carrier_ok(netdev)) {
+		mutex_lock(&tp->control);
+		tp->rtl_ops.enable(tp);
+		rtl8152_set_rx_mode(netdev);
+		mutex_unlock(&tp->control);
+		netif_wake_queue(netdev);
+	}
+
+	napi_enable(&tp->napi);
+
+	return 0;
+}
+
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
@@ -4164,6 +4216,8 @@ static struct usb_driver rtl8152_driver = {
 	.suspend =	rtl8152_suspend,
 	.resume =	rtl8152_resume,
 	.reset_resume =	rtl8152_resume,
+	.pre_reset =	rtl8152_pre_reset,
+	.post_reset =	rtl8152_post_reset,
 	.supports_autosuspend = 1,
 	.disable_hub_initiated_lpm = 1,
 };
-- 
2.4.2
