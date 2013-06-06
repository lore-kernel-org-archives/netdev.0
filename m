From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] qmi_wwan/cdc_ether: let qmi_wwan handle the Huawei E1820
Date: Thu,  6 Jun 2013 12:57:02 +0200
Message-ID: <1370516222-11566-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Graham Inggs <graham.inggs@uct.ac.za>, linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55214 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932391Ab3FFK5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 06:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another QMI speaking Qualcomm based device, which should be
driven by qmi_wwan, while cdc_ether should ignore it.

Like on other Huawei devices, the wwan function can appear
either as a single vendor specific interface or as a CDC ECM
class function using separate control and data interfaces.
The ECM control interface protocol is 0xff, likely in an
attempt to indicate that vendor specific management is
required.

In addition to the near standard CDC class, Huawei also add
vendor specific AT management commands to their firmwares.
This is probably an attempt to support non-Windows systems
using standard class drivers.  Unfortunately, this part of
the firmware is often buggy.  Linux is much better off using
whatever native vendor specific management protocol the
device offers, and Windows uses, whenever possible. This
means QMI in the case of Qualcomm based devices.

The E1820 has been verified to work fine with QMI.

Matching on interface number is necessary to distiguish the
wwan function from serial functions in the single interface
mode, as both function types will have class/subclass/function
set to ff/ff/ff.

The control interface number does not change in CDC ECM mode,
so the interface number matching rule is sufficient to handle
both modes.  The cdc_ether blacklist entry is only relevant in
CDC ECM mode, but using a similar interface number based rule
helps document this as a transfer from one driver to another.

Other Huawei 02/06/ff devices are left with the cdc_ether driver
because we do not know whether they are based on Qualcomm chips.
The Huawei specific AT command management is known to be somewhat
hardware independent, and their usage of these class codes may
also be independent of the modem hardware.

Reported-by: Graham Inggs <graham.inggs@uct.ac.za>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ether.c |    6 ++++++
 drivers/net/usb/qmi_wwan.c  |    1 +
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 078795f..04ee044 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -627,6 +627,12 @@ static const struct usb_device_id	products [] =3D =
{
 	.driver_info =3D 0,
 },
=20
+/* Huawei E1820 - handled by qmi_wwan */
+{
+	USB_DEVICE_INTERFACE_NUMBER(HUAWEI_VENDOR_ID, 0x14ac, 1),
+	.driver_info =3D 0,
+},
+
 /* Realtek RTL8152 Based USB 2.0 Ethernet Adapters */
 #if defined(CONFIG_USB_RTL8152) || defined(CONFIG_USB_RTL8152_MODULE)
 {
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 86adfa0..d095d0d 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -519,6 +519,7 @@ static const struct usb_device_id products[] =3D {
 	/* 3. Combined interface devices matching on interface number */
 	{QMI_FIXED_INTF(0x0408, 0xea42, 4)},	/* Yota / Megafon M100-1 */
 	{QMI_FIXED_INTF(0x12d1, 0x140c, 1)},	/* Huawei E173 */
+	{QMI_FIXED_INTF(0x12d1, 0x14ac, 1)},	/* Huawei E1820 */
 	{QMI_FIXED_INTF(0x19d2, 0x0002, 1)},
 	{QMI_FIXED_INTF(0x19d2, 0x0012, 1)},
 	{QMI_FIXED_INTF(0x19d2, 0x0017, 3)},
--=20
1.7.10.4
