From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] cdc_subset: deal with a device that needs reset for timeout
Date: Thu, 24 Jul 2014 13:59:34 +0200
Message-ID: <1406203174-13102-1-git-send-email-oneukum@suse.de>
Cc: Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47446 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758075AbaGXL7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 07:59:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device needs to be reset to recover from a timeout.
Unfortunately this can be handled only at the level of
the subdrivers.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/cdc_subset.c | 27 +++++++++++++++++++++++++++
 drivers/net/usb/usbnet.c     |  2 ++
 include/linux/usb/usbnet.h   |  3 +++
 3 files changed, 32 insertions(+)

diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
index 91f0919..3ef411e 100644
--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -85,9 +85,34 @@ static int always_connected (struct usbnet *dev)
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
+static int dummy_prereset(struct usb_interface *intf)
+{
+	return 0;
+}
+
+static int dummy_postreset(struct usb_interface *intf)
+{
+	return 0;
+}
+
 static const struct driver_info	ali_m5632_info = {
 	.description =	"ALi M5632",
 	.flags       = FLAG_POINTTOPOINT,
+	.recover     = m5632_recover,
 };
 
 #endif
@@ -332,6 +357,8 @@ static struct usb_driver cdc_subset_driver = {
 	.probe =	usbnet_probe,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.pre_reset =	dummy_prereset,
+	.post_reset =	dummy_postreset,
 	.disconnect =	usbnet_disconnect,
 	.id_table =	products,
 	.disable_hub_initiated_lpm = 1,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f9e96c4..e0b63d2 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1218,6 +1218,8 @@ void usbnet_tx_timeout (struct net_device *net)
 
 	unlink_urbs (dev, &dev->txq);
 	tasklet_schedule (&dev->bh);
+	if (dev->driver_info->recover)
+		(dev->driver_info->recover)(dev);
 
 	// FIXME: device recovery -- reset?
 }
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
