From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC 3/9] net: cdc_ncm: split .bind device initialization
Date: Fri,  2 May 2014 23:11:50 +0200
Message-ID: <1399065116-19946-4-git-send-email-bjorn@mork.no>
References: <1399065116-19946-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55178 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806AbaEBVMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 17:12:15 -0400
In-Reply-To: <1399065116-19946-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have split out the part of the device setup
which MUST be done with the data interface in altsetting 0,
we can delay the rest of the initialization. This allows us
to move some of post-init buffer size config from bind to
the appropriate setup function.

The purpose of this refactoring is to collect all code
adjusting the rx_max and tx_max buffers in one place, so
that it is easier to call it from multiple call sites.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index d2e9b56c27ff..ad29cde75f41 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -111,6 +111,21 @@ static void cdc_ncm_update_rxtx_max(struct usbnet =
*dev, u32 new_rx, u32 new_tx)
 	if (val !=3D ctx->tx_max)
 		dev_info(&dev->intf->dev, "setting tx_max =3D %u\n", val);
 	ctx->tx_max =3D val;
+
+	/* Adding a pad byte here if necessary simplifies the handling
+	 * in cdc_ncm_fill_tx_frame, making tx_max always represent
+	 * the real skb max size.
+	 *
+	 * We cannot use dev->maxpacket here because this is called from
+	 * .bind which is called before usbnet sets up dev->maxpacket
+	 */
+	if (ctx->tx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
+	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
+		ctx->tx_max++;
+
+	/* usbnet use these values for sizing tx/rx queues */
+	dev->hard_mtu =3D ctx->tx_max;
+	dev->rx_urb_size =3D ctx->rx_max;
 }
=20
 /* helpers for NCM and MBIM differences */
@@ -316,9 +331,6 @@ static int cdc_ncm_setup(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
=20
-	/* initialize basic device settings */
-	cdc_ncm_init(dev);
-
 	/* clamp rx_max and tx_max and inform device */
 	cdc_ncm_update_rxtx_max(dev, le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize=
),
 				le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize));
@@ -525,8 +537,8 @@ advance:
 		goto error2;
 	}
=20
-	/* initialize data interface */
-	if (cdc_ncm_setup(dev))
+	/* initialize basic device settings */
+	if (cdc_ncm_init(dev))
 		goto error2;
=20
 	/* configure data interface */
@@ -555,18 +567,8 @@ advance:
 		dev_info(&intf->dev, "MAC-Address: %pM\n", dev->net->dev_addr);
 	}
=20
-	/* usbnet use these values for sizing tx/rx queues */
-	dev->hard_mtu =3D ctx->tx_max;
-	dev->rx_urb_size =3D ctx->rx_max;
-
-	/* cdc_ncm_setup will override dwNtbOutMaxSize if it is
-	 * outside the sane range. Adding a pad byte here if necessary
-	 * simplifies the handling in cdc_ncm_fill_tx_frame, making
-	 * tx_max always represent the real skb max size.
-	 */
-	if (ctx->tx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
-	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
-		ctx->tx_max++;
+	/* finish setting up the device specific data */
+	cdc_ncm_setup(dev);
=20
 	return 0;
=20
--=20
2.0.0.rc0
