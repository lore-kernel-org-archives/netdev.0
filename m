From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: cdc_ncm: fix probing of devices with multiple control interface altsettings
Date: Wed, 13 Feb 2013 23:09:52 +0100
Message-ID: <1360793392-7412-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52968 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760928Ab3BMWKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 17:10:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible MBIM devic=
es")
added a test for a CDC MBIM altsetting, implementing the cdc_ncm part o=
f
MBIM backward compatibility support.  This intentionally made the drive=
r
behave differently for CDC NCM devices with 2 alternate settings for th=
e
Communication interface, depending on whether or not CONFIG_USB_NET_CDC=
_MBIM
was enabled.  This is correct iff alternate setting #1 really *is* a MB=
IM
setting.  If not, then NCM probing will use a different altsetting than=
 before,
possibly causing probing failures depending on CONFIG_USB_NET_CDC_MBIM.

=46ix by setting the altsetting back to default after the test, restori=
ng the
previous behaviour for non MBIM devices.

This bug causes probing of Huawei E3276 devices to fail when the MBIM d=
river
is enabled, because these devices have a second alternate setting with =
no CDC
functional descriptors.

Cc: Greg Suarez <gsuarez@smithmicro.com>
Cc: Alexey Orishko <alexey.orishko@stericsson.com>
Reported-and-tested-by: Jonathan A. <yo.natan@hotmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 00d3b2d..6d25439 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -576,9 +576,14 @@ static int cdc_ncm_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 	if ((intf->num_altsetting =3D=3D 2) &&
 	    !usb_set_interface(dev->udev,
 			       intf->cur_altsetting->desc.bInterfaceNumber,
-			       CDC_NCM_COMM_ALTSETTING_MBIM) &&
-	    cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
-		return -ENODEV;
+			       CDC_NCM_COMM_ALTSETTING_MBIM)) {
+		if (cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
+			return -ENODEV;
+		else
+			usb_set_interface(dev->udev,
+					  intf->cur_altsetting->desc.bInterfaceNumber,
+					  CDC_NCM_COMM_ALTSETTING_NCM);
+	}
 #endif
=20
 	/* NCM data altsetting is always 1 */
--=20
1.7.10.4
