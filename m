From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 2/2] net: cdc_mbim: change the default to send ZLPs
Date: Thu, 31 Oct 2013 15:56:11 +0100
Message-ID: <1383231371-8098-3-git-send-email-bjorn@mork.no>
References: <1383231371-8098-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34801 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755206Ab3JaPBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 11:01:21 -0400
In-Reply-To: <1383231371-8098-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of devices in the wild have turned out to require ZLPs.
Even if this is a spec violation, our priority is to make any
device work as good as possible. Devices needing ZLPs will fail
to receive any full sized frame we send. On the other hand,
devices which do not need the ZLP will still work if we send
them.

This gives us no other option than sending ZLPs by default.

This will prevent devices conforming to the spec from making the
optimizations which are possible without ZLPs.  Adding known
such devices to a whitelist, to avoid the possible negative
impact of the new spec violating default.

Cc: Greg Suarez <gsuarez@smithmicro.com>
Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c |   28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 6533a9f..253472a 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -429,9 +429,18 @@ static const struct driver_info cdc_mbim_info =3D =
{
 };
=20
 /* MBIM and NCM devices should not need a ZLP after NTBs with
- * dwNtbOutMaxSize length. This driver_info is for the exceptional
- * devices requiring it anyway, allowing them to be supported without
- * forcing the performance penalty on all the sane devices.
+ * dwNtbOutMaxSize length. Nevertheless, a number of devices from
+ * different vendor IDs will fail unless we send ZLPs, forcing us
+ * to make this the default.
+ *
+ * This default may cause a performance penalty for spec conforming
+ * devices wanting to take advantage of optimizations possible without
+ * ZLPs.  A whitelist is added in an attempt to avoid this for devices
+ * known to conform to the MBIM specification.
+ *
+ * All known devices supporting NCM compatibility mode are also
+ * conforming to the NCM and MBIM specifications. For this reason, the
+ * NCM subclass entry is also in the ZLP whitelist.
  */
 static const struct driver_info cdc_mbim_info_zlp =3D {
 	.description =3D "CDC MBIM",
@@ -454,16 +463,13 @@ static const struct usb_device_id mbim_devs[] =3D=
 {
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_NCM, USB_CDC_PR=
OTO_NONE),
 	  .driver_info =3D (unsigned long)&cdc_mbim_info,
 	},
-	/* Sierra Wireless MC7710 need ZLPs */
-	{ USB_DEVICE_AND_INTERFACE_INFO(0x1199, 0x68a2, USB_CLASS_COMM, USB_C=
DC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
-	  .driver_info =3D (unsigned long)&cdc_mbim_info_zlp,
-	},
-	/* HP hs2434 Mobile Broadband Module needs ZLPs */
-	{ USB_DEVICE_AND_INTERFACE_INFO(0x3f0, 0x4b1d, USB_CLASS_COMM, USB_CD=
C_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
-	  .driver_info =3D (unsigned long)&cdc_mbim_info_zlp,
+	/* ZLP conformance whitelist: All Ericsson MBIM devices */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x0bdb, USB_CLASS_COMM, USB_CDC_SUBCL=
ASS_MBIM, USB_CDC_PROTO_NONE),
+	  .driver_info =3D (unsigned long)&cdc_mbim_info,
 	},
+	/* default entry */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_P=
ROTO_NONE),
-	  .driver_info =3D (unsigned long)&cdc_mbim_info,
+	  .driver_info =3D (unsigned long)&cdc_mbim_info_zlp,
 	},
 	{
 	},
--=20
1.7.10.4
