From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net v2] cdc_ether: Ignore bogus union descriptor for RNDIS devices
Date: Thu, 26 Apr 2012 14:35:10 +0200
Message-ID: <1335443710-2627-1-git-send-email-bjorn@mork.no>
References: <201204261356.03000.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Markus Kolb <linux-201011@tower-net.de>,
	=?UTF-8?q?Iker=20Salm=C3=B3n=20San=20Mill=C3=A1n?=
	<shaola@esdebian.org>, Jonathan Nieder <jrnieder@gmail.com>,
	Oliver Neukum <oliver@neukum.org>, 655387@bugs.debian.org,
	stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39060 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111Ab2DZMfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 08:35:47 -0400
In-Reply-To: <201204261356.03000.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some RNDIS devices include a bogus CDC Union descriptor pointing
to non-existing interfaces.  The RNDIS code is already prepared
to handle devices without a CDC Union descriptor by hardwiring
the driver to use interfaces 0 and 1, which is correct for the
devices with the bogus descriptor as well. So we can reuse the
existing workaround.

Cc: Markus Kolb <linux-201011@tower-net.de>
Cc: Iker Salm=C3=B3n San Mill=C3=A1n <shaola@esdebian.org>
Cc: Jonathan Nieder <jrnieder@gmail.com>
Cc: Oliver Neukum <oliver@neukum.org>
Cc: 655387@bugs.debian.org
Cc: stable@vger.kernel.org
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
v2: adding a test to verify that the resulting control interface is the
    probed interface, as suggested by Oliver Neukum

The same comments as for v1 regarding testing applies.  This is build
tested only.  Should go through some functional testing before being
applied.


Bj=C3=B8rn

 drivers/net/usb/cdc_ether.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 90a3002..00880ed 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -83,6 +83,7 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 	struct cdc_state		*info =3D (void *) &dev->data;
 	int				status;
 	int				rndis;
+	bool				android_rndis_quirk =3D false;
 	struct usb_driver		*driver =3D driver_of(intf);
 	struct usb_cdc_mdlm_desc	*desc =3D NULL;
 	struct usb_cdc_mdlm_detail_desc *detail =3D NULL;
@@ -195,6 +196,11 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
 					info->control,
 					info->u->bSlaveInterface0,
 					info->data);
+				/* fall back to hard-wiring for RNDIS */
+				if (rndis) {
+					android_rndis_quirk =3D true;
+					goto next_desc;
+				}
 				goto bad_desc;
 			}
 			if (info->control !=3D intf) {
@@ -271,11 +277,15 @@ next_desc:
 	/* Microsoft ActiveSync based and some regular RNDIS devices lack the
 	 * CDC descriptors, so we'll hard-wire the interfaces and not check
 	 * for descriptors.
+	 *
+	 * Some Android RNDIS devices have a CDC Union descriptor pointing
+	 * to non-existing interfaces.  Ignore that and attempt the same
+	 * hard-wired 0 and 1 interfaces.
 	 */
-	if (rndis && !info->u) {
+	if (rndis && (!info->u || android_rndis_quirk)) {
 		info->control =3D usb_ifnum_to_if(dev->udev, 0);
 		info->data =3D usb_ifnum_to_if(dev->udev, 1);
-		if (!info->control || !info->data) {
+		if (!info->control || !info->data || info->control !=3D intf) {
 			dev_dbg(&intf->dev,
 				"rndis: master #0/%p slave #1/%p\n",
 				info->control,
--=20
1.7.10
