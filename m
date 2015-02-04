From: Takashi Iwai <tiwai@suse.de>
Subject: [PATCH] hso: Use static attribute groups for sysfs entry
Date: Wed,  4 Feb 2015 14:39:33 +0100
Message-ID: <1423057173-6981-1-git-send-email-tiwai@suse.de>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43971 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965000AbbBDNjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 08:39:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the static attribute groups and the driver data via
tty_port_register_device_attr() instead of manual device_create_file()
and device_remove_file() calls.

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 drivers/net/usb/hso.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 9c5aa922a9f4..1ecca185510d 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -533,6 +533,13 @@ static ssize_t hso_sysfs_show_porttype(struct device *dev,
 }
 static DEVICE_ATTR(hsotype, S_IRUGO, hso_sysfs_show_porttype, NULL);
 
+static struct attribute *hso_serial_dev_attrs[] = {
+	&dev_attr_hsotype.attr,
+	NULL
+};
+
+ATTRIBUTE_GROUPS(hso_serial_dev);
+
 static int hso_urb_to_index(struct hso_serial *serial, struct urb *urb)
 {
 	int idx;
@@ -2232,9 +2239,6 @@ static void hso_serial_common_free(struct hso_serial *serial)
 {
 	int i;
 
-	if (serial->parent->dev)
-		device_remove_file(serial->parent->dev, &dev_attr_hsotype);
-
 	tty_unregister_device(tty_drv, serial->minor);
 
 	for (i = 0; i < serial->num_rx_urbs; i++) {
@@ -2264,11 +2268,10 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 		goto exit;
 
 	/* register our minor number */
-	serial->parent->dev = tty_port_register_device(&serial->port, tty_drv,
-			minor, &serial->parent->interface->dev);
+	serial->parent->dev = tty_port_register_device_attr(&serial->port,
+			tty_drv, minor, &serial->parent->interface->dev,
+			serial->parent, hso_serial_dev_groups);
 	dev = serial->parent->dev;
-	dev_set_drvdata(dev, serial->parent);
-	i = device_create_file(dev, &dev_attr_hsotype);
 
 	/* fill in specific data for later use */
 	serial->minor = minor;
-- 
2.2.2
