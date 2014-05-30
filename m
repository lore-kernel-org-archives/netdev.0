From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 3/8] net: cdc_ncm: inform usbnet when rx buffers are reduced
Date: Fri, 30 May 2014 09:31:05 +0200
Message-ID: <1401435070-26721-4-git-send-email-bjorn@mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51749 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbaE3Hb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 03:31:56 -0400
In-Reply-To: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't matter whether the buffer size goes up or down.  We have to
keep usbnet and device syncronized to be able to split transfers at the
correct boundaries. The spec allow skipping short packets when using
max sized transfers.  If we don't tell usbnet about our new expected rx
buffer size, then it will merge and/or split NTBs.  The driver does not
support this, and the result will be lots of framing errors.

=46ix by always reallocating usbnet rx buffers when the rx_max value
changes.

=46ixes: 68864abf08f0 ("net: cdc_ncm: support rx_max/tx_max updates whe=
n running")
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index ff5b3a854898..5bce86a0d063 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -215,19 +215,12 @@ static void cdc_ncm_update_rxtx_max(struct usbnet=
 *dev, u32 new_rx, u32 new_tx)
 			min, max, val);
 	}
=20
-	/* usbnet use these values for sizing rx queues */
-	dev->rx_urb_size =3D val;
-
 	/* inform device about NTB input size changes */
 	if (val !=3D ctx->rx_max) {
 		__le32 dwNtbInMaxSize =3D cpu_to_le32(val);
=20
 		dev_info(&dev->intf->dev, "setting rx_max =3D %u\n", val);
=20
-		/* need to unlink rx urbs before increasing buffer size */
-		if (netif_running(dev->net) && dev->rx_urb_size > ctx->rx_max)
-			usbnet_unlink_rx_urbs(dev);
-
 		/* tell device to use new size */
 		if (usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
 				     USB_TYPE_CLASS | USB_DIR_OUT
@@ -238,6 +231,13 @@ static void cdc_ncm_update_rxtx_max(struct usbnet =
*dev, u32 new_rx, u32 new_tx)
 			ctx->rx_max =3D val;
 	}
=20
+	/* usbnet use these values for sizing rx queues */
+	if (dev->rx_urb_size !=3D ctx->rx_max) {
+		dev->rx_urb_size =3D ctx->rx_max;
+		if (netif_running(dev->net))
+			usbnet_unlink_rx_urbs(dev);
+	}
+
 	/* clamp new_tx to sane values */
 	min =3D ctx->max_datagram_size + ctx->max_ndp_size + sizeof(struct us=
b_cdc_ncm_nth16);
 	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_TX, le32_to_cpu(ctx->ncm_parm=
=2EdwNtbOutMaxSize));
--=20
2.0.0.rc4
