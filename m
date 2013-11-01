From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 07/24] net: cdc_ncm: remove tx_speed and rx_speed fields
Date: Fri,  1 Nov 2013 11:16:44 +0100
Message-ID: <1383301021-16613-8-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49964 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These fields are only used to prevent printing the same speeds
multiple times if we receive multiple identical speed notifications.

The value of these printk's is questionable, and even more so when
we filter out some of the notifications sent us by the firmware. If
we are going to print any of these, then we should print them all.

Removing little used fields is a bonus.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |   37 ++++++++++++++---------------------=
--
 include/linux/usb/cdc_ncm.h |    2 --
 2 files changed, 14 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 9cdd762..fc36a99 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -510,7 +510,6 @@ advance:
 	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
 		ctx->tx_max++;
=20
-	ctx->tx_speed =3D ctx->rx_speed =3D 0;
 	return 0;
=20
 error2:
@@ -1048,7 +1047,6 @@ static void
 cdc_ncm_speed_change(struct usbnet *dev,
 		     struct usb_cdc_speed_change *data)
 {
-	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
 	uint32_t rx_speed =3D le32_to_cpu(data->DLBitRRate);
 	uint32_t tx_speed =3D le32_to_cpu(data->ULBitRate);
=20
@@ -1056,25 +1054,20 @@ cdc_ncm_speed_change(struct usbnet *dev,
 	 * Currently the USB-NET API does not support reporting the actual
 	 * device speed. Do print it instead.
 	 */
-	if ((tx_speed !=3D ctx->tx_speed) || (rx_speed !=3D ctx->rx_speed)) {
-		ctx->tx_speed =3D tx_speed;
-		ctx->rx_speed =3D rx_speed;
-
-		if ((tx_speed > 1000000) && (rx_speed > 1000000)) {
-			printk(KERN_INFO KBUILD_MODNAME
-			       ": %s: %u mbit/s downlink "
-			       "%u mbit/s uplink\n",
-			       dev->net->name,
-			       (unsigned int)(rx_speed / 1000000U),
-			       (unsigned int)(tx_speed / 1000000U));
-		} else {
-			printk(KERN_INFO KBUILD_MODNAME
-			       ": %s: %u kbit/s downlink "
-			       "%u kbit/s uplink\n",
-			       dev->net->name,
-			       (unsigned int)(rx_speed / 1000U),
-			       (unsigned int)(tx_speed / 1000U));
-		}
+	if ((tx_speed > 1000000) && (rx_speed > 1000000)) {
+		printk(KERN_INFO KBUILD_MODNAME
+		       ": %s: %u mbit/s downlink "
+		       "%u mbit/s uplink\n",
+		       dev->net->name,
+		       (unsigned int)(rx_speed / 1000000U),
+		       (unsigned int)(tx_speed / 1000000U));
+	} else {
+		printk(KERN_INFO KBUILD_MODNAME
+		       ": %s: %u kbit/s downlink "
+		       "%u kbit/s uplink\n",
+		       dev->net->name,
+		       (unsigned int)(rx_speed / 1000U),
+		       (unsigned int)(tx_speed / 1000U));
 	}
 }
=20
@@ -1111,8 +1104,6 @@ static void cdc_ncm_status(struct usbnet *dev, st=
ruct urb *urb)
 		       dev->net->name, ctx->connected ? "" : "dis");
=20
 		usbnet_link_change(dev, ctx->connected, 0);
-		if (!ctx->connected)
-			ctx->tx_speed =3D ctx->rx_speed =3D 0;
 		break;
=20
 	case USB_CDC_NOTIFY_SPEED_CHANGE:
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 059dcc9..f14af3d 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -110,8 +110,6 @@ struct cdc_ncm_ctx {
=20
 	u32 tx_timer_pending;
 	u32 tx_curr_frame_num;
-	u32 rx_speed;
-	u32 tx_speed;
 	u32 rx_max;
 	u32 tx_max;
 	u32 max_datagram_size;
--=20
1.7.10.4
