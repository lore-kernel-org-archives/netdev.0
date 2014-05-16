From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v2 04/12] net: cdc_ncm: support rx_max/tx_max updates when running
Date: Fri, 16 May 2014 21:48:21 +0200
Message-ID: <1400269709-18854-5-git-send-email-bjorn@mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
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
Received: from canardo.mork.no ([148.122.252.1]:52166 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757329AbaEPTst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 15:48:49 -0400
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46inish the rx_max/tx_max setup by flushing buffers and
informing usbnet about the changes.  This way, the settings
can be modified while the netdev is up and running.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 7a3de73c8ded..2ec3790a4db8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -89,11 +89,20 @@ static void cdc_ncm_update_rxtx_max(struct usbnet *=
dev, u32 new_rx, u32 new_tx)
 			min, max, val);
 	}
=20
+	/* usbnet use these values for sizing rx queues */
+	dev->rx_urb_size =3D val;
+
 	/* inform device about NTB input size changes */
 	if (val !=3D ctx->rx_max) {
 		__le32 dwNtbInMaxSize =3D cpu_to_le32(val);
=20
 		dev_info(&dev->intf->dev, "setting rx_max =3D %u\n", val);
+
+		/* need to unlink rx urbs before increasing buffer size */
+		if (netif_running(dev->net) && dev->rx_urb_size > ctx->rx_max)
+			usbnet_unlink_rx_urbs(dev);
+
+		/* tell device to use new size */
 		if (usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
 				     USB_TYPE_CLASS | USB_DIR_OUT
 				     | USB_RECIP_INTERFACE,
@@ -117,7 +126,6 @@ static void cdc_ncm_update_rxtx_max(struct usbnet *=
dev, u32 new_rx, u32 new_tx)
 	}
 	if (val !=3D ctx->tx_max)
 		dev_info(&dev->intf->dev, "setting tx_max =3D %u\n", val);
-	ctx->tx_max =3D val;
=20
 	/* Adding a pad byte here if necessary simplifies the handling
 	 * in cdc_ncm_fill_tx_frame, making tx_max always represent
@@ -126,13 +134,24 @@ static void cdc_ncm_update_rxtx_max(struct usbnet=
 *dev, u32 new_rx, u32 new_tx)
 	 * We cannot use dev->maxpacket here because this is called from
 	 * .bind which is called before usbnet sets up dev->maxpacket
 	 */
-	if (ctx->tx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
-	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
-		ctx->tx_max++;
+	if (val !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
+	    val % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
+		val++;
+
+	/* we might need to flush any pending tx buffers if running */
+	if (netif_running(dev->net) && val > ctx->tx_max) {
+		netif_tx_lock_bh(dev->net);
+		usbnet_start_xmit(NULL, dev->net);
+		ctx->tx_max =3D val;
+		netif_tx_unlock_bh(dev->net);
+	} else {
+		ctx->tx_max =3D val;
+	}
=20
-	/* usbnet use these values for sizing tx/rx queues */
 	dev->hard_mtu =3D ctx->tx_max;
-	dev->rx_urb_size =3D ctx->rx_max;
+
+	/* max qlen depend on hard_mtu and rx_urb_size */
+	usbnet_update_max_qlen(dev);
 }
=20
 /* helpers for NCM and MBIM differences */
--=20
2.0.0.rc2
