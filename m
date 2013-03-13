From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC PATCH] qmi_wwan: set correct altsetting for Gobi 1K devices
Date: Wed, 13 Mar 2013 08:13:40 +0100
Message-ID: <87hakf93h7.fsf@nemi.mork.no>
References: <1363117205.9644.17.camel@dcbw.foobar.com>
	<2400f481-f2eb-440d-b74d-ff9bfccd1179@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38445 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752285Ab3CMHNt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 03:13:49 -0400
In-Reply-To: <2400f481-f2eb-440d-b74d-ff9bfccd1179@email.android.com>
 (=?utf-8?Q?=22Bj=C3=B8rn?=
	Mork"'s message of "Tue, 12 Mar 2013 22:17:53 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

>
> Risking that I am trying to be too smart again. .. But I really think
> we can fix this in a more generic way by making the probe behave more
> like it did before. How about just letting it continue without erring
> out until it has called usbnet_get_endpoints? That should work withou=
t
> needing any quirks.

I was thinking about something like this patch, dropping both the
unnecessary verification of bNumEndpoints and of the CDC functional
descriptors.  If we find a CDC Union, then fine - we use it to locate
the data interface. If we find a CDC Ether, then fine - we use it to se=
t
the MAC address.

This should end up calling usbnet_get_endpoints (first thing
qmi_wwan_register_subdriver does), and succeed if any data interface
altsetting have the necessary endpoints.

There really are few reasons to do any strict verification step in the
probe in this driver, because there really are no usable markers on the
functions. That's why the driver does explicit interface matching in
the first place.  So it makes sense to allow the probe to succeed if
collecting the 3 required endpoints is at all possible.

It will of course succeed on a number of unsupported interfaces if
dynamical IDs are used.  But with nothing to differentiate a QMI/wwan
function from other functions, there is really nothing we can do to
prevent that. If we are to support dynamic IDs, then there will be fals=
e
positives.  The user can manually unbind the driver from unwanted
matches in this case.

Only build tested for now. I will test on the devices I have before
submitting, if this works for you:


diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index efb5c7c..1cfa80c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -139,18 +139,11 @@ static int qmi_wwan_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
=20
 	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) < sizeof(struct qmi_=
wwan_state)));
=20
-	/* control and data is shared? */
-	if (intf->cur_altsetting->desc.bNumEndpoints =3D=3D 3) {
-		info->control =3D intf;
-		info->data =3D intf;
-		goto shared;
-	}
-
-	/* else require a single interrupt status endpoint on control intf */
-	if (intf->cur_altsetting->desc.bNumEndpoints !=3D 1)
-		goto err;
+	/* set up initial state */
+	info->control =3D intf;
+	info->data =3D intf;
=20
-	/* and a number of CDC descriptors */
+	/* some vendors add CDC descriptors */
 	while (len > 3) {
 		struct usb_descriptor_header *h =3D (void *)buf;
=20
@@ -207,25 +200,17 @@ next_desc:
 		buf +=3D h->bLength;
 	}
=20
-	/* did we find all the required ones? */
-	if (!(found & (1 << USB_CDC_HEADER_TYPE)) ||
-	    !(found & (1 << USB_CDC_UNION_TYPE))) {
-		dev_err(&intf->dev, "CDC functional descriptors missing\n");
-		goto err;
-	}
-
-	/* verify CDC Union */
-	if (desc->bInterfaceNumber !=3D cdc_union->bMasterInterface0) {
-		dev_err(&intf->dev, "bogus CDC Union: master=3D%u\n", cdc_union->bMa=
sterInterface0);
-		goto err;
-	}
-
-	/* need to save these for unbind */
-	info->control =3D intf;
-	info->data =3D usb_ifnum_to_if(dev->udev,	cdc_union->bSlaveInterface0=
);
-	if (!info->data) {
-		dev_err(&intf->dev, "bogus CDC Union: slave=3D%u\n", cdc_union->bSla=
veInterface0);
-		goto err;
+	/* using two interfaces if we found a CDC Union */
+	if (cdc_union) {
+		if (desc->bInterfaceNumber !=3D cdc_union->bMasterInterface0) {
+			dev_err(&intf->dev, "bogus CDC Union: master=3D%u\n", cdc_union->bM=
asterInterface0);
+			goto err;
+		}
+		info->data =3D usb_ifnum_to_if(dev->udev,	cdc_union->bSlaveInterface=
0);
+		if (!info->data) {
+			dev_err(&intf->dev, "bogus CDC Union: slave=3D%u\n", cdc_union->bSl=
aveInterface0);
+			goto err;
+		}
 	}
=20
 	/* errors aren't fatal - we can live with the dynamic address */
@@ -234,12 +219,13 @@ next_desc:
 		usbnet_get_ethernet_addr(dev, cdc_ether->iMACAddress);
 	}
=20
-	/* claim data interface and set it up */
-	status =3D usb_driver_claim_interface(driver, info->data, dev);
-	if (status < 0)
-		goto err;
+	/* claim separate data interface? */
+	if (info->control !=3D info->data) {
+		status =3D usb_driver_claim_interface(driver, info->data, dev);
+		if (status < 0)
+			goto err;
+	}
=20
-shared:
 	status =3D qmi_wwan_register_subdriver(dev);
 	if (status < 0 && info->control !=3D info->data) {
 		usb_set_intfdata(info->data, NULL);
