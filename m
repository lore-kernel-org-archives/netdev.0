From: Lucas Stach <dev@lynxeye.de>
Subject: =?UTF-8?q?=5BPATCH=201/2=5D=20net=3A=20asix=3A=20init=20ASIX=20AX88772B=20MAC=20from=20EEPROM?=
Date: Tue, 18 Dec 2012 13:10:25 +0100
Message-ID: <1355832626-3034-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>, linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km20343-01.keymachine.de ([84.19.182.79]:54126 "EHLO
	km20343-01.keymachine.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754611Ab2LRMUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 07:20:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device comes up with a MAC address of all zeros. We need to read th=
e
initial device MAC from EEPROM so it can be set properly later.

Signed-off-by: Lucas Stach <dev@lynxeye.de>
---
A similar fix was added into U-Boot:
http://patchwork.ozlabs.org/patch/179409/
---
 drivers/net/usb/asix_devices.c | 29 ++++++++++++++++++++++++++---
 include/linux/usb/usbnet.h     |  1 +
 2 Dateien ge=C3=A4ndert, 27 Zeilen hinzugef=C3=BCgt(+), 3 Zeilen entfe=
rnt(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devi=
ces.c
index 7a6e758..06f7f7cb 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -422,14 +422,25 @@ static const struct net_device_ops ax88772_netdev=
_ops =3D {
=20
 static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf=
)
 {
-	int ret, embd_phy;
+	int ret, embd_phy, i;
 	u8 buf[ETH_ALEN];
 	u32 phyid;
=20
 	usbnet_get_endpoints(dev,intf);
=20
 	/* Get the MAC address */
-	ret =3D asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
+	if (dev->driver_info->flags & FLAG_EEPROM_MAC) {
+		for (i =3D 0; i < (ETH_ALEN >> 1); i++) {
+			ret =3D asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x04 + i,
+					0, 2, buf + i * 2);
+			if (ret < 0)
+				break;
+		}
+	} else {
+		ret =3D asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
+				0, 0, ETH_ALEN, buf);
+	}
+
 	if (ret < 0) {
 		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
@@ -872,6 +883,18 @@ static const struct driver_info ax88772_info =3D {
 	.tx_fixup =3D asix_tx_fixup,
 };
=20
+static const struct driver_info ax88772b_info =3D {
+	.description =3D "ASIX AX88772B USB 2.0 Ethernet",
+	.bind =3D ax88772_bind,
+	.status =3D asix_status,
+	.link_reset =3D ax88772_link_reset,
+	.reset =3D ax88772_reset,
+	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+	         FLAG_MULTI_PACKET | FLAG_EEPROM_MAC,
+	.rx_fixup =3D asix_rx_fixup,
+	.tx_fixup =3D asix_tx_fixup,
+};
+
 static const struct driver_info ax88178_info =3D {
 	.description =3D "ASIX AX88178 USB 2.0 Ethernet",
 	.bind =3D ax88178_bind,
@@ -953,7 +976,7 @@ static const struct usb_device_id	products [] =3D {
 }, {
 	// ASIX AX88772B 10/100
 	USB_DEVICE (0x0b95, 0x772b),
-	.driver_info =3D (unsigned long) &ax88772_info,
+	.driver_info =3D (unsigned long) &ax88772b_info,
 }, {
 	// ASIX AX88772 10/100
 	USB_DEVICE (0x0b95, 0x7720),
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 9bbeabf..8e9516f 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -106,6 +106,7 @@ struct driver_info {
  */
 #define FLAG_MULTI_PACKET	0x2000
 #define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */
+#define FLAG_EEPROM_MAC		0x8000	/* initialize device MAC from eeprom *=
/
=20
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
--=20
1.7.11.7
