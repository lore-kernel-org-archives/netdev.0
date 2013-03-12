From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC PATCH] qmi_wwan: set correct altsetting for Gobi 1K devices
Date: Tue, 12 Mar 2013 22:17:53 +0100
Message-ID: <2400f481-f2eb-440d-b74d-ff9bfccd1179@email.android.com>
References: <1363117205.9644.17.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60194 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932675Ab3CLVSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 17:18:04 -0400
In-Reply-To: <1363117205.9644.17.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> wrote:

>With Gobi 1K devices, USB interface #3's altsetting is 0 by default,
>but
>altsetting 0 only provides one interrupt endpoint and is not sufficent
>for QMI.  Altsetting 1 provides all 3 endpoints required for qmi_wwan
>and works with QMI.
>
>IIRC the altsetting used to be set by qcserial back before we made
>qcserial stop touching interfaces that qmi_wwan was going to use.  But
>now that qcserial only touches the modem interface, we need qmi_wwan t=
o
>set the correct altsetting on the QMI interface.

No, I broke this when I tried to be smart and merged the 1 and 2 interf=
ace probes. That's the second time I break probing of these devices by =
making too many unfounded assumptions.=20

This used to work because usbnet_get_endpoints selects the first usable=
 altsetting. It doesn't work anymore because qmi_wwan checks the number=
 of endpoints before calling usbnet_get_endpoints.

>The attached patch works for my Gobi1K (and should work for all other
>1Ks too) but seems somewhat ugly.  What approach should we take?
>Basically, we need to know that a device is Gobi1K at probe time so we
>can set the right altsetting on it.
>
>Gobi 1K layout for intf#3 is:
>
>    Interface Descriptor:  255/255/255
>      bInterfaceNumber        3
>      bAlternateSetting       0
>      Endpoint Descriptor:  Interrupt IN
>    Interface Descriptor:  255/255/255
>      bInterfaceNumber        3
>      bAlternateSetting       1
>      Endpoint Descriptor:  Interrupt IN
>      Endpoint Descriptor:  Bulk IN
>      Endpoint Descriptor:  Bulk OUT

Ouch. I did not know this. I should get one of these devices, I guess. =
=2E.


>Dan
>
>---
>diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
>index efb5c7c..50e1b7c 100644
>--- a/drivers/net/usb/qmi_wwan.c
>+++ b/drivers/net/usb/qmi_wwan.c
>@@ -43,6 +43,9 @@
>  * commands on a serial interface
>  */
>=20
>+/* Quirks for the usbnet 'struct driver_info' data field */
>+#define QUIRK_GOBI_1K  (1 << 0)   /* QMI interface requires altsettin=
g
>1 */
>+
> /* driver specific data */
> struct qmi_wwan_state {
> 	struct usb_driver *subdriver;
>@@ -326,6 +329,15 @@ static const struct driver_info	qmi_wwan_info =3D=
 {
> 	.manage_power	=3D qmi_wwan_manage_power,
> };
>=20
>+static const struct driver_info	gobi1k_info =3D {
>+	.description	=3D "WWAN/QMI device",
>+	.flags		=3D FLAG_WWAN,
>+	.bind		=3D qmi_wwan_bind,
>+	.unbind		=3D qmi_wwan_unbind,
>+	.manage_power	=3D qmi_wwan_manage_power,
>+	.data           =3D QUIRK_GOBI_1K,
>+};
>+
> #define HUAWEI_VENDOR_ID	0x12D1
>=20
> /* map QMI/wwan function by a fixed interface number */
>@@ -335,7 +347,8 @@ static const struct driver_info	qmi_wwan_info =3D =
{
>=20
> /* Gobi 1000 QMI/wwan interface number is 3 according to qcserial */
> #define QMI_GOBI1K_DEVICE(vend, prod) \
>-	QMI_FIXED_INTF(vend, prod, 3)
>+	USB_DEVICE_INTERFACE_NUMBER(vend, prod, 3), \
>+	.driver_info =3D (unsigned long)&gobi1k_info
>=20
>/* Gobi 2000/3000 QMI/wwan interface number is 0 according to qcserial
>*/
> #define QMI_GOBI_DEVICE(vend, prod) \
>@@ -541,6 +554,9 @@ MODULE_DEVICE_TABLE(usb, products);
>static int qmi_wwan_probe(struct usb_interface *intf, const struct
>usb_device_id *prod)
> {
> 	struct usb_device_id *id =3D (struct usb_device_id *)prod;
>+	struct driver_info *info;
>+	u8 intf_num =3D intf->cur_altsetting->desc.bInterfaceNumber;
>+	int retval;
>=20
> 	/* Workaround to enable dynamic IDs.  This disables usbnet
> 	 * blacklisting functionality.  Which, if required, can be
>@@ -552,6 +568,20 @@ static int qmi_wwan_probe(struct usb_interface
>*intf, const struct usb_device_id
> 		id->driver_info =3D (unsigned long)&qmi_wwan_info;
> 	}
>=20
>+	info =3D (struct driver_info *) id->driver_info;
>+	if (info->data & QUIRK_GOBI_1K) {
>+		/* Gobi 1K's QMI interface is always USB interface #3 */
>+		BUG_ON(intf_num !=3D 3);

Definitely not. We return ENODEV if the probe logic fails for whatever =
reason.=20

>+		retval =3D usb_set_interface(interface_to_usbdev (intf),
>+					   intf_num, 1);
>+		if (retval < 0) {
>+			dev_err(&intf->dev, "Failed to set altsetting 1: %d\n",
>+			        retval);
>+			return -ENODEV;
>+		}
>+	}

Risking that I am trying to be too smart again. .. But I really think w=
e can fix this in a more generic way by making the probe behave more li=
ke it did before. How about just letting it continue without erring out=
 until it has called usbnet_get_endpoints? That should work without nee=
ding any quirks.=20


Bj=C3=B8rn
