From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 1/5] net: qmi_wwan: define a structure for driver specific state
Date: Tue, 19 Jun 2012 12:41:59 +0200
Message-ID: <1340102523-23990-2-git-send-email-bjorn@mork.no>
References: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Andrew Bird (Sphere Systems)" <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340102523-23990-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

usbnet allocates a fixed size array for minidriver specific
state.  Naming the fields and taking advantage of type checking
is a bit more failsafe than casting array elements each time
they are referenced.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |   49 ++++++++++++++++++++++++++----------=
--------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 3b20678..c7b9be8 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -54,6 +54,13 @@
  *     corresponding management interface
  */
=20
+/* driver specific data */
+struct qmi_wwan_state {
+	struct usb_driver *subdriver;
+	atomic_t pmcount;
+	unsigned long unused[3];
+};
+
 static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *int=
f)
 {
 	int status =3D -1;
@@ -65,9 +72,11 @@ static int qmi_wwan_bind(struct usbnet *dev, struct =
usb_interface *intf)
 	struct usb_cdc_ether_desc *cdc_ether =3D NULL;
 	u32 required =3D 1 << USB_CDC_HEADER_TYPE | 1 << USB_CDC_UNION_TYPE;
 	u32 found =3D 0;
-	atomic_t *pmcount =3D (void *)&dev->data[1];
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) < sizeof(struct qmi_=
wwan_state)));
=20
-	atomic_set(pmcount, 0);
+	atomic_set(&info->pmcount, 0);
=20
 	/*
 	 * assume a data interface has no additional descriptors and
@@ -177,12 +186,12 @@ err:
 /* using a counter to merge subdriver requests with our own into a com=
bined state */
 static int qmi_wwan_manage_power(struct usbnet *dev, int on)
 {
-	atomic_t *pmcount =3D (void *)&dev->data[1];
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
 	int rv =3D 0;
=20
-	dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __func__, at=
omic_read(pmcount), on);
+	dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __func__, at=
omic_read(&info->pmcount), on);
=20
-	if ((on && atomic_add_return(1, pmcount) =3D=3D 1) || (!on && atomic_=
dec_and_test(pmcount))) {
+	if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) || (!on && =
atomic_dec_and_test(&info->pmcount))) {
 		/* need autopm_get/put here to ensure the usbcore sees the new value=
 */
 		rv =3D usb_autopm_get_interface(dev->intf);
 		if (rv < 0)
@@ -212,7 +221,7 @@ static int qmi_wwan_bind_shared(struct usbnet *dev,=
 struct usb_interface *intf)
 {
 	int rv;
 	struct usb_driver *subdriver =3D NULL;
-	atomic_t *pmcount =3D (void *)&dev->data[1];
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
=20
 	/* ZTE makes devices where the interface descriptors and endpoint
 	 * configurations of two or more interfaces are identical, even
@@ -228,7 +237,7 @@ static int qmi_wwan_bind_shared(struct usbnet *dev,=
 struct usb_interface *intf)
 		goto err;
 	}
=20
-	atomic_set(pmcount, 0);
+	atomic_set(&info->pmcount, 0);
=20
 	/* collect all three endpoints */
 	rv =3D usbnet_get_endpoints(dev, intf);
@@ -251,7 +260,7 @@ static int qmi_wwan_bind_shared(struct usbnet *dev,=
 struct usb_interface *intf)
 	dev->status =3D NULL;
=20
 	/* save subdriver struct for suspend/resume wrappers */
-	dev->data[0] =3D (unsigned long)subdriver;
+	info->subdriver =3D subdriver;
=20
 err:
 	return rv;
@@ -282,12 +291,12 @@ err:
=20
 static void qmi_wwan_unbind_shared(struct usbnet *dev, struct usb_inte=
rface *intf)
 {
-	struct usb_driver *subdriver =3D (void *)dev->data[0];
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
=20
-	if (subdriver && subdriver->disconnect)
-		subdriver->disconnect(intf);
+	if (info->subdriver && info->subdriver->disconnect)
+		info->subdriver->disconnect(intf);
=20
-	dev->data[0] =3D (unsigned long)NULL;
+	info->subdriver =3D NULL;
 }
=20
 /* suspend/resume wrappers calling both usbnet and the cdc-wdm
@@ -299,15 +308,15 @@ static void qmi_wwan_unbind_shared(struct usbnet =
*dev, struct usb_interface *int
 static int qmi_wwan_suspend(struct usb_interface *intf, pm_message_t m=
essage)
 {
 	struct usbnet *dev =3D usb_get_intfdata(intf);
-	struct usb_driver *subdriver =3D (void *)dev->data[0];
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
 	int ret;
=20
 	ret =3D usbnet_suspend(intf, message);
 	if (ret < 0)
 		goto err;
=20
-	if (subdriver && subdriver->suspend)
-		ret =3D subdriver->suspend(intf, message);
+	if (info->subdriver && info->subdriver->suspend)
+		ret =3D info->subdriver->suspend(intf, message);
 	if (ret < 0)
 		usbnet_resume(intf);
 err:
@@ -317,16 +326,16 @@ err:
 static int qmi_wwan_resume(struct usb_interface *intf)
 {
 	struct usbnet *dev =3D usb_get_intfdata(intf);
-	struct usb_driver *subdriver =3D (void *)dev->data[0];
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
 	int ret =3D 0;
=20
-	if (subdriver && subdriver->resume)
-		ret =3D subdriver->resume(intf);
+	if (info->subdriver && info->subdriver->resume)
+		ret =3D info->subdriver->resume(intf);
 	if (ret < 0)
 		goto err;
 	ret =3D usbnet_resume(intf);
-	if (ret < 0 && subdriver && subdriver->resume && subdriver->suspend)
-		subdriver->suspend(intf, PMSG_SUSPEND);
+	if (ret < 0 && info->subdriver && info->subdriver->resume && info->su=
bdriver->suspend)
+		info->subdriver->suspend(intf, PMSG_SUSPEND);
 err:
 	return ret;
 }
--=20
1.7.10

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
