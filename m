From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 2/7 v3] initdev:kernel:USB init device discovery
	notification
Date: Tue, 4 Aug 2009 15:15:06 -0700
Message-ID: <20090804221506.GA9256@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:39391 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755266AbZHDWPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 18:15:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Stern <stern@rowland.harvard.edu>

Use init device discovery infrastructure to provide notification of
availability of USB devices.

Signed-off-by: Alan Stern <stern@rowland.harvard.edu>
Signed-off-by: David VomLehn <dvomlehn@cisco.com>
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
