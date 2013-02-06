From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] rtlwifi: rtl8192cu: Fix NULL dereference BUG when using new_id
Date: Wed,  6 Feb 2013 12:54:17 -0600
Message-ID: <1360176857-852-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the new_id entry in /sysfs is used for a foreign USB device, rtlwifi
BUGS with a NULL pointer dereference because the per-driver configuration
data is not available. The probe function has been restructured as
suggested by Ben Hutchings <bhutchings@solarflare.com>.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 8 +++++++-
 drivers/net/wireless/rtlwifi/usb.c          | 5 +++--
 drivers/net/wireless/rtlwifi/usb.h          | 3 ++-
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index d9e659f..577c0dc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -363,9 +363,15 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 
 MODULE_DEVICE_TABLE(usb, rtl8192c_usb_ids);
 
+static int rtl8192cu_probe(struct usb_interface *intf,
+			   const struct usb_device_id *id)
+{
+	return rtl_usb_probe(intf, id, &rtl92cu_hal_cfg);
+}
+
 static struct usb_driver rtl8192cu_driver = {
 	.name = "rtl8192cu",
-	.probe = rtl_usb_probe,
+	.probe = rtl8192cu_probe,
 	.disconnect = rtl_usb_disconnect,
 	.id_table = rtl8192c_usb_ids,
 
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index d42bbe2..476eaef 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -937,7 +937,8 @@ static struct rtl_intf_ops rtl_usb_ops = {
 };
 
 int rtl_usb_probe(struct usb_interface *intf,
-			const struct usb_device_id *id)
+		  const struct usb_device_id *id,
+		  struct rtl_hal_cfg *rtl_hal_cfg)
 {
 	int err;
 	struct ieee80211_hw *hw = NULL;
@@ -972,7 +973,7 @@ int rtl_usb_probe(struct usb_interface *intf,
 	usb_set_intfdata(intf, hw);
 	/* init cfg & intf_ops */
 	rtlpriv->rtlhal.interface = INTF_USB;
-	rtlpriv->cfg = (struct rtl_hal_cfg *)(id->driver_info);
+	rtlpriv->cfg = rtl_hal_cfg;
 	rtlpriv->intf_ops = &rtl_usb_ops;
 	rtl_dbgp_flag_init(hw);
 	/* Init IO handler */
diff --git a/drivers/net/wireless/rtlwifi/usb.h b/drivers/net/wireless/rtlwifi/usb.h
index 5235136..fb986f9 100644
--- a/drivers/net/wireless/rtlwifi/usb.h
+++ b/drivers/net/wireless/rtlwifi/usb.h
@@ -157,7 +157,8 @@ struct rtl_usb_priv {
 
 
 int rtl_usb_probe(struct usb_interface *intf,
-			    const struct usb_device_id *id);
+		  const struct usb_device_id *id,
+		  struct rtl_hal_cfg *rtl92cu_hal_cfg);
 void rtl_usb_disconnect(struct usb_interface *intf);
 int rtl_usb_suspend(struct usb_interface *pusb_intf, pm_message_t message);
 int rtl_usb_resume(struct usb_interface *pusb_intf);
-- 
1.8.1
