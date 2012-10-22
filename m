From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 11/13] net: cdc_ncm: do not bind to NCM compatible MBIM devices
Date: Mon, 22 Oct 2012 22:56:38 +0200
Message-ID: <1350939400-27209-12-git-send-email-bjorn@mork.no>
References: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48611 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756390Ab2JVU5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 16:57:24 -0400
In-Reply-To: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MBIM specification allows a MBIM device to disguise
itself as NCM for backwards compatibility, using additional
altsettings with different subclass (control) or protocol
(data):

C:* #Ifs=3D 2 Cfg#=3D 1 Atr=3D80 MxPwr=3D100mA
I:  If#=3D 0 Alt=3D 0 #EPs=3D 1 Cls=3D02(comm.) Sub=3D0d Prot=3D00 Driv=
er=3Dcdc_mbim
E:  Ad=3D81(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D7ms
I:* If#=3D 0 Alt=3D 1 #EPs=3D 1 Cls=3D02(comm.) Sub=3D0e Prot=3D00 Driv=
er=3Dcdc_mbim
E:  Ad=3D81(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D7ms
I:  If#=3D 1 Alt=3D 0 #EPs=3D 0 Cls=3D0a(data ) Sub=3D00 Prot=3D01 Driv=
er=3Dcdc_mbim
I:  If#=3D 1 Alt=3D 1 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D01 Driv=
er=3Dcdc_mbim
E:  Ad=3D81(I) Atr=3D02(Bulk) MxPS=3D  64 Ivl=3D0ms
E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D  64 Ivl=3D0ms
I:* If#=3D 1 Alt=3D 2 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driv=
er=3Dcdc_mbim
E:  Ad=3D81(I) Atr=3D02(Bulk) MxPS=3D  64 Ivl=3D0ms
E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D  64 Ivl=3D0ms

If the MBIM driver is enabled then that should have priority
for devices providing such a NCM 1.0 backward compatibility
mode.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: Greg Suarez <gsuarez@smithmicro.com>
---
 drivers/net/usb/cdc_ncm.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 17b4ba0..0ed03b1 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -563,6 +563,33 @@ static int cdc_ncm_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 {
 	int ret;
=20
+	/* The MBIM spec defines a NCM compatible default altsetting,
+	 * which we may have matched:
+	 *
+	 *  "Functions that implement both NCM 1.0 and MBIM (an
+	 *   =E2=80=9CNCM/MBIM function=E2=80=9D) according to this recommend=
ation
+	 *   shall provide two alternate settings for the
+	 *   Communication Interface.  Alternate setting 0, and the
+	 *   associated class and endpoint descriptors, shall be
+	 *   constructed according to the rules given for the
+	 *   Communication Interface in section 5 of [USBNCM10].
+	 *   Alternate setting 1, and the associated class and
+	 *   endpoint descriptors, shall be constructed according to
+	 *   the rules given in section 6 (USB Device Model) of this
+	 *   specification."
+	 *
+	 * Do not bind to such interfaces, allowing cdc_mbim to handle
+	 * them
+	 */
+#if IS_ENABLED(CONFIG_USB_NET_CDC_MBIM)
+	if ((intf->num_altsetting =3D=3D 2) &&
+	    !usb_set_interface(dev->udev,
+			       intf->cur_altsetting->desc.bInterfaceNumber,
+			       CDC_NCM_COMM_ALTSETTING_MBIM) &&
+	    cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
+		return -ENODEV;
+#endif
+
 	/* NCM data altsetting is always 1 */
 	ret =3D cdc_ncm_bind_common(dev, intf, 1);
=20
--=20
1.7.10.4
