From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 2/5] net: qmi_wwan: rearranging to prepare for code sharing
Date: Tue, 19 Jun 2012 12:42:00 +0200
Message-ID: <1340102523-23990-3-git-send-email-bjorn@mork.no>
References: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	linux-usb@vger.kernel.org,
	"Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43941 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754121Ab2FSKmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 06:42:37 -0400
In-Reply-To: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the subdriver registration code can be reused for devices
with separate control and data interfaces.  Move the code a bit
around to prepare for such reuse.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |  128 ++++++++++++++++++++++++++----------=
--------
 1 file changed, 76 insertions(+), 52 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index c7b9be8..6fcf54d 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -58,9 +58,80 @@
 struct qmi_wwan_state {
 	struct usb_driver *subdriver;
 	atomic_t pmcount;
-	unsigned long unused[3];
+	unsigned long unused;
+	struct usb_interface *control;
+	struct usb_interface *data;
 };
=20
+/* using a counter to merge subdriver requests with our own into a com=
bined state */
+static int qmi_wwan_manage_power(struct usbnet *dev, int on)
+{
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	int rv =3D 0;
+
+	dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __func__, at=
omic_read(&info->pmcount), on);
+
+	if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) || (!on && =
atomic_dec_and_test(&info->pmcount))) {
+		/* need autopm_get/put here to ensure the usbcore sees the new value=
 */
+		rv =3D usb_autopm_get_interface(dev->intf);
+		if (rv < 0)
+			goto err;
+		dev->intf->needs_remote_wakeup =3D on;
+		usb_autopm_put_interface(dev->intf);
+	}
+err:
+	return rv;
+}
+
+static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *intf, i=
nt on)
+{
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+	return qmi_wwan_manage_power(dev, on);
+}
+
+/* collect all three endpoints and register subdriver */
+static int qmi_wwan_register_subdriver(struct usbnet *dev)
+{
+	int rv;
+	struct usb_driver *subdriver =3D NULL;
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	/* collect bulk endpoints */
+	rv =3D usbnet_get_endpoints(dev, info->data);
+	if (rv < 0)
+		goto err;
+
+	/* update status endpoint if separate control interface */
+	if (info->control !=3D info->data)
+		dev->status =3D &info->control->cur_altsetting->endpoint[0];
+
+	/* require interrupt endpoint for subdriver */
+	if (!dev->status) {
+		rv =3D -EINVAL;
+		goto err;
+	}
+
+	/* for subdriver power management */
+	atomic_set(&info->pmcount, 0);
+
+	/* register subdriver */
+	subdriver =3D usb_cdc_wdm_register(info->control, &dev->status->desc,=
 512, &qmi_wwan_cdc_wdm_manage_power);
+	if (IS_ERR(subdriver)) {
+		dev_err(&info->control->dev, "subdriver registration failed\n");
+		rv =3D PTR_ERR(subdriver);
+		goto err;
+	}
+
+	/* prevent usbnet from using status endpoint */
+	dev->status =3D NULL;
+
+	/* save subdriver struct for suspend/resume wrappers */
+	info->subdriver =3D subdriver;
+
+err:
+	return rv;
+}
+
 static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *int=
f)
 {
 	int status =3D -1;
@@ -183,32 +254,6 @@ err:
 	return status;
 }
=20
-/* using a counter to merge subdriver requests with our own into a com=
bined state */
-static int qmi_wwan_manage_power(struct usbnet *dev, int on)
-{
-	struct qmi_wwan_state *info =3D (void *)&dev->data;
-	int rv =3D 0;
-
-	dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __func__, at=
omic_read(&info->pmcount), on);
-
-	if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) || (!on && =
atomic_dec_and_test(&info->pmcount))) {
-		/* need autopm_get/put here to ensure the usbcore sees the new value=
 */
-		rv =3D usb_autopm_get_interface(dev->intf);
-		if (rv < 0)
-			goto err;
-		dev->intf->needs_remote_wakeup =3D on;
-		usb_autopm_put_interface(dev->intf);
-	}
-err:
-	return rv;
-}
-
-static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *intf, i=
nt on)
-{
-	struct usbnet *dev =3D usb_get_intfdata(intf);
-	return qmi_wwan_manage_power(dev, on);
-}
-
 /* Some devices combine the "control" and "data" functions into a
  * single interface with all three endpoints: interrupt + bulk in and
  * out
@@ -220,7 +265,6 @@ static int qmi_wwan_cdc_wdm_manage_power(struct usb=
_interface *intf, int on)
 static int qmi_wwan_bind_shared(struct usbnet *dev, struct usb_interfa=
ce *intf)
 {
 	int rv;
-	struct usb_driver *subdriver =3D NULL;
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
=20
 	/* ZTE makes devices where the interface descriptors and endpoint
@@ -237,30 +281,10 @@ static int qmi_wwan_bind_shared(struct usbnet *de=
v, struct usb_interface *intf)
 		goto err;
 	}
=20
-	atomic_set(&info->pmcount, 0);
-
-	/* collect all three endpoints */
-	rv =3D usbnet_get_endpoints(dev, intf);
-	if (rv < 0)
-		goto err;
-
-	/* require interrupt endpoint for subdriver */
-	if (!dev->status) {
-		rv =3D -EINVAL;
-		goto err;
-	}
-
-	subdriver =3D usb_cdc_wdm_register(intf, &dev->status->desc, 512, &qm=
i_wwan_cdc_wdm_manage_power);
-	if (IS_ERR(subdriver)) {
-		rv =3D PTR_ERR(subdriver);
-		goto err;
-	}
-
-	/* can't let usbnet use the interrupt endpoint */
-	dev->status =3D NULL;
-
-	/* save subdriver struct for suspend/resume wrappers */
-	info->subdriver =3D subdriver;
+	/*  control and data is shared */
+	info->control =3D intf;
+	info->data =3D intf;
+	rv =3D qmi_wwan_register_subdriver(dev);
=20
 err:
 	return rv;
--=20
1.7.10
