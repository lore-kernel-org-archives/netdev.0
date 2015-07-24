From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 2/3] r8152: fix wakeup settings
Date: Fri, 24 Jul 2015 13:54:24 +0800
Message-ID: <1394712342-15778-154-Taiwan-albertk@realtek.com>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
 <1394712342-15778-152-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-152-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid the driver to enable WOL if the device doesn't support it.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e3a0110..d537c30 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2378,6 +2378,13 @@ static void r8153_power_cut_en(struct r8152 *tp, bool enable)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_MISC_0, ocp_data);
 }
 
+static bool rtl_can_wakeup(struct r8152 *tp)
+{
+	struct usb_device *udev = tp->udev;
+
+	return (udev->actconfig->desc.bmAttributes & USB_CONFIG_ATT_WAKEUP);
+}
+
 static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 {
 	if (enable) {
@@ -3417,12 +3424,15 @@ static void rtl8152_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (usb_autopm_get_interface(tp->intf) < 0)
 		return;
 
-	mutex_lock(&tp->control);
-
-	wol->supported = WAKE_ANY;
-	wol->wolopts = __rtl_get_wol(tp);
-
-	mutex_unlock(&tp->control);
+	if (!rtl_can_wakeup(tp)) {
+		wol->supported = 0;
+		wol->wolopts = 0;
+	} else {
+		mutex_lock(&tp->control);
+		wol->supported = WAKE_ANY;
+		wol->wolopts = __rtl_get_wol(tp);
+		mutex_unlock(&tp->control);
+	}
 
 	usb_autopm_put_interface(tp->intf);
 }
@@ -3432,6 +3442,9 @@ static int rtl8152_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct r8152 *tp = netdev_priv(dev);
 	int ret;
 
+	if (!rtl_can_wakeup(tp))
+		return -EOPNOTSUPP;
+
 	ret = usb_autopm_get_interface(tp->intf);
 	if (ret < 0)
 		goto out_set_wol;
@@ -4073,6 +4086,9 @@ static int rtl8152_probe(struct usb_interface *intf,
 		goto out1;
 	}
 
+	if (!rtl_can_wakeup(tp))
+		__rtl_set_wol(tp, 0);
+
 	tp->saved_wolopts = __rtl_get_wol(tp);
 	if (tp->saved_wolopts)
 		device_set_wakeup_enable(&udev->dev, true);
-- 
2.4.2
