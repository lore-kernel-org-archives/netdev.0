From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next] net: qmi_wwan: make dynamic device IDs work
Date: Tue, 17 Jul 2012 23:14:32 +0200
Message-ID: <1342559672-5893-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The usbnet API use the device ID table to store a pointer to
a minidriver. Setting a generic pointer for dynamic device
IDs will in most cases make them work as expected.  usbnet
will otherwise treat the dynamic IDs as blacklisted. That is
rarely useful.

There is no standard class describing devices supported by
this driver, and most vendors don't even provide enough
information to allow vendor specific wildcard matching. The
result is that most of the supported devices must be
explicitly listed in the device table.  Allowing dynamic IDs
to work both simplifies testing and verification of new
devices, and provides a way for end users to use a device
before the ID is added to the driver.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---

I gave up on the generic solution to this problem.  Different
drivers will have different needs, and even the different usbnet
minidrivers are very different.  Some do mostly class based
wildcard matching and rarely need an ID table update, while
others, like qmi_wwan, will need frequent updates as new devices
hit the market.

My conclusion was that it was best to add support like this
in the few drivers actually needing it.  Each driver will have
to make a policy decision wrt which data they will use for
dynamic devices.  It just can't be done wholesale.



 drivers/net/usb/qmi_wwan.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index bc0469e..2ea126a 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -609,10 +609,27 @@ static const struct usb_device_id products[] =3D =
{
 };
 MODULE_DEVICE_TABLE(usb, products);
=20
+static int qmi_wwan_probe(struct usb_interface *intf, const struct usb=
_device_id *prod)
+{
+	struct usb_device_id *id =3D (struct usb_device_id *)prod;
+
+	/* Workaround to enable dynamic IDs.  This disables usbnet
+	 * blacklisting functionality.  Which, if required, can be
+	 * reimplemented here by using a magic "blacklist" value
+	 * instead of 0 in the static device id table
+	 */
+	if (!id->driver_info) {
+		dev_dbg(&intf->dev, "setting defaults for dynamic device id\n");
+		id->driver_info =3D (unsigned long)&qmi_wwan_shared;
+	}
+
+	return usbnet_probe(intf, id);
+}
+
 static struct usb_driver qmi_wwan_driver =3D {
 	.name		      =3D "qmi_wwan",
 	.id_table	      =3D products,
-	.probe		      =3D	usbnet_probe,
+	.probe		      =3D qmi_wwan_probe,
 	.disconnect	      =3D usbnet_disconnect,
 	.suspend	      =3D qmi_wwan_suspend,
 	.resume		      =3D	qmi_wwan_resume,
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
