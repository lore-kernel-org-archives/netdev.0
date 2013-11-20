From: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org
Subject: [PATCH 1/1] Workaround for Suspend/Resume issue of AX88772B under ChromeOS
Date: Wed, 20 Nov 2013 10:11:36 +0800
Message-ID: <1384913496-26261-1-git-send-email-freddy@asix.com.tw>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davemloft-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org,
	grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, daniel-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>

This patch adds a workaroud to solve Suspend/Resume issue that AX88772B turns
off its Ethernet PHY power in the case that REMOTE_WAKEUP feature doesn't
be set when system suspend. In this case, the PHY power will not be turned
on again when system resume, so the HW reset must be added in the resume function.

Signed-off-by: Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Tested-by: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/asix.h         |    1 +
 drivers/net/usb/asix_devices.c |   16 +++++++++++++++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index bdaa12d..0e975aa 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -48,6 +48,7 @@
 #define AX_CMD_SET_SW_MII		0x06
 #define AX_CMD_READ_MII_REG		0x07
 #define AX_CMD_WRITE_MII_REG		0x08
+#define AX_CMD_STATMNGSTS_REG		0x09
 #define AX_CMD_SET_HW_MII		0x0a
 #define AX_CMD_READ_EEPROM		0x0b
 #define AX_CMD_WRITE_EEPROM		0x0c
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 386a3df..3ac9958 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -845,6 +845,20 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 	return 0;
 }
 
+static int asix_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	u8 chipcode = 0;
+
+	asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &chipcode);
+	chipcode &= 0x70;
+
+	if (dev->driver_info->reset && (chipcode == 0x20))
+		dev->driver_info->reset(dev);
+
+	return usbnet_resume(intf);
+}
+
 static const struct driver_info ax8817x_info = {
 	.description = "ASIX AX8817x USB 2.0 Ethernet",
 	.bind = ax88172_bind,
@@ -1101,7 +1115,7 @@ static struct usb_driver asix_driver = {
 	.id_table =	products,
 	.probe =	usbnet_probe,
 	.suspend =	usbnet_suspend,
-	.resume =	usbnet_resume,
+	.resume =	asix_resume,
 	.disconnect =	usbnet_disconnect,
 	.supports_autosuspend = 1,
 	.disable_hub_initiated_lpm = 1,
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
