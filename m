From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: sierra_net: replace whitelist with ifnumber match
Date: Sun, 12 Aug 2012 21:53:38 +0200
Message-ID: <1344801218-11041-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---

This driver can also be simplified by using the new interface number
matching, avoiding unnecessary probing of unsupported interfaces at
the same time.

Please apply to "net".


 drivers/net/usb/sierra_net.c |   52 ++++++++++------------------------=
--------
 1 file changed, 12 insertions(+), 40 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.=
c
index d75d1f5..7be49ea 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -68,15 +68,8 @@ static	atomic_t iface_counter =3D ATOMIC_INIT(0);
  */
 #define SIERRA_NET_USBCTL_BUF_LEN	1024
=20
-/* list of interface numbers - used for constructing interface lists *=
/
-struct sierra_net_iface_info {
-	const u32 infolen;	/* number of interface numbers on list */
-	const u8  *ifaceinfo;	/* pointer to the array holding the numbers */
-};
-
 struct sierra_net_info_data {
 	u16 rx_urb_size;
-	struct sierra_net_iface_info whitelist;
 };
=20
 /* Private data structure */
@@ -637,21 +630,6 @@ static int sierra_net_change_mtu(struct net_device=
 *net, int new_mtu)
 	return usbnet_change_mtu(net, new_mtu);
 }
=20
-static int is_whitelisted(const u8 ifnum,
-			const struct sierra_net_iface_info *whitelist)
-{
-	if (whitelist) {
-		const u8 *list =3D whitelist->ifaceinfo;
-		int i;
-
-		for (i =3D 0; i < whitelist->infolen; i++) {
-			if (list[i] =3D=3D ifnum)
-				return 1;
-		}
-	}
-	return 0;
-}
-
 static int sierra_net_get_fw_attr(struct usbnet *dev, u16 *datap)
 {
 	int result =3D 0;
@@ -706,11 +684,6 @@ static int sierra_net_bind(struct usbnet *dev, str=
uct usb_interface *intf)
 	dev_dbg(&dev->udev->dev, "%s", __func__);
=20
 	ifacenum =3D intf->cur_altsetting->desc.bInterfaceNumber;
-	/* We only accept certain interfaces */
-	if (!is_whitelisted(ifacenum, &data->whitelist)) {
-		dev_dbg(&dev->udev->dev, "Ignoring interface: %d", ifacenum);
-		return -ENODEV;
-	}
 	numendpoints =3D intf->cur_altsetting->desc.bNumEndpoints;
 	/* We have three endpoints, bulk in and out, and a status */
 	if (numendpoints !=3D 3) {
@@ -945,13 +918,8 @@ struct sk_buff *sierra_net_tx_fixup(struct usbnet =
*dev, struct sk_buff *skb,
 	return NULL;
 }
=20
-static const u8 sierra_net_ifnum_list[] =3D { 7, 10, 11 };
 static const struct sierra_net_info_data sierra_net_info_data_direct_i=
p =3D {
 	.rx_urb_size =3D 8 * 1024,
-	.whitelist =3D {
-		.infolen =3D ARRAY_SIZE(sierra_net_ifnum_list),
-		.ifaceinfo =3D sierra_net_ifnum_list
-	}
 };
=20
 static const struct driver_info sierra_net_info_direct_ip =3D {
@@ -965,15 +933,19 @@ static const struct driver_info sierra_net_info_d=
irect_ip =3D {
 	.data =3D (unsigned long)&sierra_net_info_data_direct_ip,
 };
=20
+#define DIRECT_IP_DEVICE(vend, prod) \
+	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 7), \
+	.driver_info =3D (unsigned long)&sierra_net_info_direct_ip}, \
+	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 10), \
+	.driver_info =3D (unsigned long)&sierra_net_info_direct_ip}, \
+	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 11), \
+	.driver_info =3D (unsigned long)&sierra_net_info_direct_ip}
+
 static const struct usb_device_id products[] =3D {
-	{USB_DEVICE(0x1199, 0x68A3), /* Sierra Wireless USB-to-WWAN modem */
-	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
-	{USB_DEVICE(0x0F3D, 0x68A3), /* AT&T Direct IP modem */
-	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
-	{USB_DEVICE(0x1199, 0x68AA), /* Sierra Wireless Direct IP LTE modem *=
/
-	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
-	{USB_DEVICE(0x0F3D, 0x68AA), /* AT&T Direct IP LTE modem */
-	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
+	DIRECT_IP_DEVICE(0x1199, 0x68A3), /* Sierra Wireless USB-to-WWAN mode=
m */
+	DIRECT_IP_DEVICE(0x0F3D, 0x68A3), /* AT&T Direct IP modem */
+	DIRECT_IP_DEVICE(0x1199, 0x68AA), /* Sierra Wireless Direct IP LTE mo=
dem */
+	DIRECT_IP_DEVICE(0x0F3D, 0x68AA), /* AT&T Direct IP LTE modem */
=20
 	{}, /* last item */
 };
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
