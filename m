From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 11/11] net: cdc_ncm: remove redundant "disconnected" flag
Date: Sat, 10 May 2014 17:41:49 +0200
Message-ID: <1399736509-1159-12-git-send-email-bjorn@mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43767 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591AbaEJPmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 May 2014 11:42:22 -0400
In-Reply-To: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling netif_carrier_{on,off} is sufficient.  There is no need
to duplicate the carrier state in a driver specific flag.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c        | 19 ++-----------------
 drivers/net/usb/huawei_cdc_ncm.c | 13 -------------
 include/linux/usb/cdc_ncm.h      |  1 -
 3 files changed, 2 insertions(+), 31 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index c65145671521..114d56b9fe29 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1353,11 +1353,10 @@ static void cdc_ncm_status(struct usbnet *dev, =
struct urb *urb)
 		 * USB_CDC_NOTIFY_NETWORK_CONNECTION notification shall be
 		 * sent by device after USB_CDC_NOTIFY_SPEED_CHANGE.
 		 */
-		ctx->connected =3D le16_to_cpu(event->wValue);
 		netif_info(dev, link, dev->net,
 			   "network connection: %sconnected\n",
-			   ctx->connected ? "" : "dis");
-		usbnet_link_change(dev, ctx->connected, 0);
+			   !!event->wValue ? "" : "dis");
+		usbnet_link_change(dev, !!event->wValue, 0);
 		break;
=20
 	case USB_CDC_NOTIFY_SPEED_CHANGE:
@@ -1377,23 +1376,11 @@ static void cdc_ncm_status(struct usbnet *dev, =
struct urb *urb)
 	}
 }
=20
-static int cdc_ncm_check_connect(struct usbnet *dev)
-{
-	struct cdc_ncm_ctx *ctx;
-
-	ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	if (ctx =3D=3D NULL)
-		return 1;	/* disconnected */
-
-	return !ctx->connected;
-}
-
 static const struct driver_info cdc_ncm_info =3D {
 	.description =3D "CDC NCM",
 	.flags =3D FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
 	.bind =3D cdc_ncm_bind,
 	.unbind =3D cdc_ncm_unbind,
-	.check_connect =3D cdc_ncm_check_connect,
 	.manage_power =3D usbnet_manage_power,
 	.status =3D cdc_ncm_status,
 	.rx_fixup =3D cdc_ncm_rx_fixup,
@@ -1407,7 +1394,6 @@ static const struct driver_info wwan_info =3D {
 			| FLAG_WWAN,
 	.bind =3D cdc_ncm_bind,
 	.unbind =3D cdc_ncm_unbind,
-	.check_connect =3D cdc_ncm_check_connect,
 	.manage_power =3D usbnet_manage_power,
 	.status =3D cdc_ncm_status,
 	.rx_fixup =3D cdc_ncm_rx_fixup,
@@ -1421,7 +1407,6 @@ static const struct driver_info wwan_noarp_info =3D=
 {
 			| FLAG_WWAN | FLAG_NOARP,
 	.bind =3D cdc_ncm_bind,
 	.unbind =3D cdc_ncm_unbind,
-	.check_connect =3D cdc_ncm_check_connect,
 	.manage_power =3D usbnet_manage_power,
 	.status =3D cdc_ncm_status,
 	.rx_fixup =3D cdc_ncm_rx_fixup,
diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_=
cdc_ncm.c
index 312178d7b698..f9822bc75425 100644
--- a/drivers/net/usb/huawei_cdc_ncm.c
+++ b/drivers/net/usb/huawei_cdc_ncm.c
@@ -172,24 +172,11 @@ err:
 	return ret;
 }
=20
-static int huawei_cdc_ncm_check_connect(struct usbnet *usbnet_dev)
-{
-	struct cdc_ncm_ctx *ctx;
-
-	ctx =3D (struct cdc_ncm_ctx *)usbnet_dev->data[0];
-
-	if (ctx =3D=3D NULL)
-		return 1; /* disconnected */
-
-	return !ctx->connected;
-}
-
 static const struct driver_info huawei_cdc_ncm_info =3D {
 	.description =3D "Huawei CDC NCM device",
 	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
 	.bind =3D huawei_cdc_ncm_bind,
 	.unbind =3D huawei_cdc_ncm_unbind,
-	.check_connect =3D huawei_cdc_ncm_check_connect,
 	.manage_power =3D huawei_cdc_ncm_manage_power,
 	.rx_fixup =3D cdc_ncm_rx_fixup,
 	.tx_fixup =3D cdc_ncm_tx_fixup,
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 1921bdadd9ab..dc175b1debdf 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -118,7 +118,6 @@ struct cdc_ncm_ctx {
 	u16 tx_ndp_modulus;
 	u16 tx_seq;
 	u16 rx_seq;
-	u16 connected;
 	u16 min_tx_pkt;
=20
 	/* statistics */
--=20
2.0.0.rc2
