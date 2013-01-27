From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: support dm9620 variant
Date: Sun, 27 Jan 2013 23:34:22 +0100
Message-ID: <1359326062-5042-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, davem@davemloft.net, slawek@wernikowski.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:47891 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab3A0We3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 17:34:29 -0500
Received: by mail-ee0-f47.google.com with SMTP id e52so1014829eek.20
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 14:34:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dm9620 is a newer variant of dm9601 with more features (usb 2.0, checks=
um
offload, ..), but it can also be put in a dm9601 compatible mode, allow=
ing
us to reuse the existing driver.

This does mean that the extended features like checksum offload cannot =
be
used, but that's hardly critical on a 100mbps interface.

Thanks to S=C5=82awek Wernikowski <slawek@wernikowski.net> for providin=
g me
with a dm9620 based device to test.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |   30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 8670a53..174e5ec 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -45,6 +45,12 @@
 #define DM_MCAST_ADDR	0x16	/* 8 bytes */
 #define DM_GPR_CTRL	0x1e
 #define DM_GPR_DATA	0x1f
+#define DM_CHIP_ID	0x2c
+#define DM_MODE_CTRL	0x91	/* only on dm9620 */
+
+/* chip id values */
+#define ID_DM9601	0
+#define ID_DM9620	1
=20
 #define DM_MAX_MCAST	64
 #define DM_MCAST_SIZE	8
@@ -348,7 +354,7 @@ static const struct net_device_ops dm9601_netdev_op=
s =3D {
 static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
-	u8 mac[ETH_ALEN];
+	u8 mac[ETH_ALEN], id;
=20
 	ret =3D usbnet_get_endpoints(dev, intf);
 	if (ret)
@@ -389,6 +395,24 @@ static int dm9601_bind(struct usbnet *dev, struct =
usb_interface *intf)
 		__dm9601_set_mac_address(dev);
 	}
=20
+	if (dm_read_reg(dev, DM_CHIP_ID, &id) < 0) {
+		netdev_err(dev->net, "Error reading chip ID\n");
+		ret =3D -ENODEV;
+		goto out;
+	}
+
+	/* put dm9620 devices in dm9601 mode */
+	if (id =3D=3D ID_DM9620) {
+		u8 mode;
+
+		if (dm_read_reg(dev, DM_MODE_CTRL, &mode) < 0) {
+			netdev_err(dev->net, "Error reading MODE_CTRL\n");
+			ret =3D -ENODEV;
+			goto out;
+		}
+		dm_write_reg(dev, DM_MODE_CTRL, mode & 0x7f);
+	}
+
 	/* power up phy */
 	dm_write_reg(dev, DM_GPR_CTRL, 1);
 	dm_write_reg(dev, DM_GPR_DATA, 0);
@@ -571,6 +595,10 @@ static const struct usb_device_id products[] =3D {
 	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
 	 .driver_info =3D (unsigned long)&dm9601_info,
 	 },
+	{
+	 USB_DEVICE(0x0a46, 0x9620),	/* DM9620 USB to Fast Ethernet Adapter *=
/
+	 .driver_info =3D (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
=20
--=20
1.7.10.4
