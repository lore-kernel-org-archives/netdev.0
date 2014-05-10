From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 04/11] net: cdc_ncm: support rx_max/tx_max updates when running
Date: Sat, 10 May 2014 17:41:42 +0200
Message-ID: <1399736509-1159-5-git-send-email-bjorn@mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399736509-1159-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46inish the rx_max/tx_max setup by flushing buffers and
informing usbnet about the changes.  This way, the settings
can be modified while the netdev is up and running.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index ad29cde75f41..466922a8af4d 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -82,11 +82,20 @@ static void cdc_ncm_update_rxtx_max(struct usbnet *=
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
@@ -110,7 +119,6 @@ static void cdc_ncm_update_rxtx_max(struct usbnet *=
dev, u32 new_rx, u32 new_tx)
 	}
 	if (val !=3D ctx->tx_max)
 		dev_info(&dev->intf->dev, "setting tx_max =3D %u\n", val);
-	ctx->tx_max =3D val;
=20
 	/* Adding a pad byte here if necessary simplifies the handling
 	 * in cdc_ncm_fill_tx_frame, making tx_max always represent
@@ -119,13 +127,24 @@ static void cdc_ncm_update_rxtx_max(struct usbnet=
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
