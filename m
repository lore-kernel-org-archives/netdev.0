From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH RESEND v3 1/2] net: qmi_wwan: support devices having a shared QMI/wwan interface
Date: Fri,  9 Mar 2012 12:35:05 +0100
Message-ID: <1331292906-7467-2-git-send-email-bjorn@mork.no>
References: <20120308185324.GA13836@kroah.com>
 <1331292906-7467-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331292906-7467-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use the new cdc-wdm subdriver interface to create a device management
device even for USB devices having a single combined QMI/wwan USB
interface with three endpoints (int, bulk in, bulk out) instead of
separate data and control interfaces.

Some Huawei devices can be switched to a single interface mode for
use with other operating systems than Linux.  This adds support
for these devices when they run in such non-Linux modes.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Previously sent as patch number 4/5.
Requires:
  9b28ecd net: usb: qmi_wwan: New driver for Huawei QMI based WWAN devi=
ces


 drivers/net/usb/qmi_wwan.c |  168 ++++++++++++++++++++++++++++++++++++=
+++----
 1 files changed, 152 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 739e6de..a61c7a1 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -13,6 +13,7 @@
 #include <linux/usb.h>
 #include <linux/usb/cdc.h>
 #include <linux/usb/usbnet.h>
+#include <linux/usb/cdc-wdm.h>
=20
 /* The name of the CDC Device Management driver */
 #define DM_DRIVER "cdc_wdm"
@@ -64,6 +65,9 @@ static int qmi_wwan_bind(struct usbnet *dev, struct u=
sb_interface *intf)
 	struct usb_cdc_ether_desc *cdc_ether =3D NULL;
 	u32 required =3D 1 << USB_CDC_HEADER_TYPE | 1 << USB_CDC_UNION_TYPE;
 	u32 found =3D 0;
+	atomic_t *pmcount =3D (void *)&dev->data[1];
+
+	atomic_set(pmcount, 0);
=20
 	/*
 	 * assume a data interface has no additional descriptors and
@@ -170,13 +174,127 @@ err:
 	return status;
 }
=20
-/* stolen from cdc_ether.c */
+/* using a counter to merge subdriver requests with our own into a com=
bined state */
 static int qmi_wwan_manage_power(struct usbnet *dev, int on)
 {
-	dev->intf->needs_remote_wakeup =3D on;
-	return 0;
+	atomic_t *pmcount =3D (void *)&dev->data[1];
+	int rv =3D 0;
+
+	dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __func__, at=
omic_read(pmcount), on);
+
+	if ((on && atomic_add_return(1, pmcount) =3D=3D 1) || (!on && atomic_=
dec_and_test(pmcount))) {
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
 }
=20
+/* Some devices combine the "control" and "data" functions into a
+ * single interface with all three endpoints: interrupt + bulk in and
+ * out
+ *
+ * Setting up cdc-wdm as a subdriver owning the interrupt endpoint
+ * will let it provide userspace access to the encapsulated QMI
+ * protocol without interfering with the usbnet operations.
+  */
+static int qmi_wwan_bind_shared(struct usbnet *dev, struct usb_interfa=
ce *intf)
+{
+	int rv;
+	struct usb_driver *subdriver =3D NULL;
+	atomic_t *pmcount =3D (void *)&dev->data[1];
+
+	atomic_set(pmcount, 0);
+
+	/* collect all three endpoints */
+	rv =3D usbnet_get_endpoints(dev, intf);
+	if (rv < 0)
+		goto err;
+
+	/* require interrupt endpoint for subdriver */
+	if (!dev->status) {
+		rv =3D -EINVAL;
+		goto err;
+	}
+
+	subdriver =3D usb_cdc_wdm_register(intf, &dev->status->desc, 512, &qm=
i_wwan_cdc_wdm_manage_power);
+	if (IS_ERR(subdriver)) {
+		rv =3D PTR_ERR(subdriver);
+		goto err;
+	}
+
+	/* can't let usbnet use the interrupt endpoint */
+	dev->status =3D NULL;
+
+	/* save subdriver struct for suspend/resume wrappers */
+	dev->data[0] =3D (unsigned long)subdriver;
+
+err:
+	return rv;
+}
+
+static void qmi_wwan_unbind_shared(struct usbnet *dev, struct usb_inte=
rface *intf)
+{
+	struct usb_driver *subdriver =3D (void *)dev->data[0];
+
+	if (subdriver && subdriver->disconnect)
+		subdriver->disconnect(intf);
+
+	dev->data[0] =3D (unsigned long)NULL;
+}
+
+/* suspend/resume wrappers calling both usbnet and the cdc-wdm
+ * subdriver if present.
+ *
+ * NOTE: cdc-wdm also supports pre/post_reset, but we cannot provide
+ * wrappers for those without adding usbnet reset support first.
+ */
+static int qmi_wwan_suspend(struct usb_interface *intf, pm_message_t m=
essage)
+{
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+	struct usb_driver *subdriver =3D (void *)dev->data[0];
+	int ret;
+
+	ret =3D usbnet_suspend(intf, message);
+	if (ret < 0)
+		goto err;
+
+	if (subdriver && subdriver->suspend)
+		ret =3D subdriver->suspend(intf, message);
+	if (ret < 0)
+		usbnet_resume(intf);
+err:
+	return ret;
+}
+
+static int qmi_wwan_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+	struct usb_driver *subdriver =3D (void *)dev->data[0];
+	int ret =3D 0;
+
+	if (subdriver && subdriver->resume)
+		ret =3D subdriver->resume(intf);
+	if (ret < 0)
+		goto err;
+	ret =3D usbnet_resume(intf);
+	if (ret < 0 && subdriver && subdriver->resume && subdriver->suspend)
+		subdriver->suspend(intf, PMSG_SUSPEND);
+err:
+	return ret;
+}
+
+
 static const struct driver_info	qmi_wwan_info =3D {
 	.description	=3D "QMI speaking wwan device",
 	.flags		=3D FLAG_WWAN,
@@ -184,19 +302,37 @@ static const struct driver_info	qmi_wwan_info =3D=
 {
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
+static const struct driver_info	qmi_wwan_shared =3D {
+	.description	=3D "QMI speaking wwan device with combined interface",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_bind_shared,
+	.unbind		=3D qmi_wwan_unbind_shared,
+	.manage_power	=3D qmi_wwan_manage_power,
+};
+
 #define HUAWEI_VENDOR_ID	0x12D1
=20
 static const struct usb_device_id products[] =3D {
-{
-	/* Huawei E392, E398 and possibly others sharing both device id and m=
ore... */
-	.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_MA=
TCH_INT_INFO,
-	.idVendor           =3D HUAWEI_VENDOR_ID,
-	.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
-	.bInterfaceSubClass =3D 1,
-	.bInterfaceProtocol =3D 8, /* NOTE: This is the *slave* interface of =
the CDC Union! */
-	.driver_info        =3D (unsigned long)&qmi_wwan_info,
-}, {
-},	/* END */
+	{	/* Huawei E392, E398 and possibly others sharing both device id and=
 more... */
+		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
+		.idVendor           =3D HUAWEI_VENDOR_ID,
+		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
+		.bInterfaceSubClass =3D 1,
+		.bInterfaceProtocol =3D 8, /* NOTE: This is the *slave* interface of=
 the CDC Union! */
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
+	},
+	{	/* Huawei E392, E398 and possibly others in "Windows mode"
+		 * using a combined control and data interface without any CDC
+		 * functional descriptors
+		 */
+		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
+		.idVendor           =3D HUAWEI_VENDOR_ID,
+		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
+		.bInterfaceSubClass =3D 1,
+		.bInterfaceProtocol =3D 17,
+		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+	},
+	{ }	/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
=20
@@ -205,9 +341,9 @@ static struct usb_driver qmi_wwan_driver =3D {
 	.id_table	      =3D products,
 	.probe		      =3D	usbnet_probe,
 	.disconnect	      =3D usbnet_disconnect,
-	.suspend	      =3D usbnet_suspend,
-	.resume		      =3D	usbnet_resume,
-	.reset_resume         =3D usbnet_resume,
+	.suspend	      =3D qmi_wwan_suspend,
+	.resume		      =3D	qmi_wwan_resume,
+	.reset_resume         =3D qmi_wwan_resume,
 	.supports_autosuspend =3D 1,
 };
=20
--=20
1.7.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
