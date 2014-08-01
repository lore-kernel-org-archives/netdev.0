From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] cdc_subset: deal with a device that needs reset for timeout
Date: Fri,  1 Aug 2014 14:01:51 +0200
Message-ID: <1406894511-26808-1-git-send-email-oneukum@suse.de>
Cc: Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52986 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698AbaHAMB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 08:01:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device needs to be reset to recover from a timeout.
Unfortunately this can be handled only at the level of
the subdrivers.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc_subset.c | 27 ++++++++++++++++++++++++++-
 drivers/net/usb/usbnet.c     |  8 ++++++--
 include/linux/usb/usbnet.h   |  3 +++
 3 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
index 91f0919..6ea98cf 100644
--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -85,14 +85,28 @@ static int always_connected (struct usbnet *dev)
  *
  *-------------------------------------------------------------------------*/
 
+static void m5632_recover(struct usbnet *dev)
+{
+	struct usb_device	*udev = dev->udev;
+	struct usb_interface	*intf = dev->intf;
+	int r;
+
+	r = usb_lock_device_for_reset(udev, intf);
+	if (r < 0)
+		return;
+
+	usb_reset_device(udev);
+	usb_unlock_device(udev);
+}
+
 static const struct driver_info	ali_m5632_info = {
 	.description =	"ALi M5632",
 	.flags       = FLAG_POINTTOPOINT,
+	.recover     = m5632_recover,
 };
 
 #endif
 
-
 #ifdef	CONFIG_USB_AN2720
 #define	HAVE_HARDWARE
 
@@ -326,12 +340,23 @@ static const struct usb_device_id	products [] = {
 MODULE_DEVICE_TABLE(usb, products);
 
 /*-------------------------------------------------------------------------*/
+static int dummy_prereset(struct usb_interface *intf)
+{
+        return 0;
+}
+
+static int dummy_postreset(struct usb_interface *intf)
+{
+        return 0;
+}
 
 static struct usb_driver cdc_subset_driver = {
 	.name =		"cdc_subset",
 	.probe =	usbnet_probe,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.pre_reset =	dummy_prereset,
+	.post_reset =	dummy_postreset,
 	.disconnect =	usbnet_disconnect,
 	.id_table =	products,
 	.disable_hub_initiated_lpm = 1,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f9e96c4..5173821 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1218,8 +1218,12 @@ void usbnet_tx_timeout (struct net_device *net)
 
 	unlink_urbs (dev, &dev->txq);
 	tasklet_schedule (&dev->bh);
-
-	// FIXME: device recovery -- reset?
+	/* this needs to be handled individually because the generic layer
+	 * doesn't know what is sufficient and could not restore private
+	 * information if a remedy of an unconditional reset were used.
+	 */
+	if (dev->driver_info->recover)
+		(dev->driver_info->recover)(dev);
 }
 EXPORT_SYMBOL_GPL(usbnet_tx_timeout);
 
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 0662e98..26088fe 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -148,6 +148,9 @@ struct driver_info {
 	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
 				struct sk_buff *skb, gfp_t flags);
 
+	/* recover from timeout */
+	void	(*recover)(struct usbnet *dev);
+
 	/* early initialization code, can sleep. This is for minidrivers
 	 * having 'subminidrivers' that need to do extra initialization
 	 * right after minidriver have initialized hardware. */
-- 
1.8.4.5
