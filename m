From: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/7] initdev:kernel:USB init device discovery notification,
	v3
Date: Fri, 5 Jun 2009 19:34:05 -0700
Message-ID: <20090606023405.GA5670@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>

Use init device discovery infrastructure to provide notification of
availability of USB devices.

History
v3	Changes names from BOOTDEV_* to INITDEV_*.
v2	Change names from bootdev_* to initdev_*.
v1.1	Changed check for blockdevice in #if to use || instead of |	
v1	Initial versions

Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Signed-off-by: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
---
 drivers/usb/core/hub.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/usb/core/hub.c b/drivers/usb/core/hub.c
index be86ae3..08baee0 100644
--- a/drivers/usb/core/hub.c
+++ b/drivers/usb/core/hub.c
@@ -37,6 +37,20 @@
 #endif
 #endif
 
+/* The mask of possible USB boot devices depends on what drivers and
+ * options have been configured into the kernel.  There are too many
+ * USB network config options to list here, so just assume it is always
+ * possible to have a USB network device.
+ */
+static int usb_initdev_mask = 0
+#ifdef CONFIG_USB_SERIAL_CONSOLE
+				| INITDEV_CONSOLE_MASK
+#endif
+#if defined(CONFIG_USB_STORAGE) || defined(CONFIG_BLK_DEV_UB)
+				| INITDEV_BLOCK_MASK
+#endif
+				| INITDEV_NETDEV_MASK;
+
 struct usb_hub {
 	struct device		*intfdev;	/* the "interface" device */
 	struct usb_device	*hdev;
@@ -73,6 +87,7 @@ struct usb_hub {
 	unsigned		limited_power:1;
 	unsigned		quiescing:1;
 	unsigned		disconnected:1;
+	unsigned		probing:1;
 
 	unsigned		has_indicators:1;
 	u8			indicator[USB_MAXCHILDREN];
@@ -1079,6 +1094,9 @@ static int hub_configure(struct usb_hub *hub,
 	if (hub->has_indicators && blinkenlights)
 		hub->indicator [0] = INDICATOR_CYCLE;
 
+	hub->probing = 1;
+	initdev_found(usb_initdev_mask);
+
 	hub_activate(hub, HUB_INIT);
 	return 0;
 
@@ -1124,6 +1142,9 @@ static void hub_disconnect(struct usb_interface *intf)
 	usb_buffer_free(hub->hdev, sizeof(*hub->buffer), hub->buffer,
 			hub->buffer_dma);
 
+	if (hub->probing)
+		initdev_probe_done(usb_initdev_mask);
+
 	kref_put(&hub->kref, hub_release);
 }
 
@@ -3135,6 +3156,11 @@ static void hub_events(void)
 						portstatus, portchange);
 		} /* end for i */
 
+		if (hub->probing) {
+			hub->probing = 0;
+			initdev_probe_done(usb_initdev_mask);
+		}
+
 		/* deal with hub status changes */
 		if (test_and_clear_bit(0, hub->event_bits) == 0)
 			;	/* do nothing */
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
