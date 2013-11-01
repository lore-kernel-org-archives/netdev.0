From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 12/24] net: cdc_ncm: no point in filling up the NTBs if we send ZLPs
Date: Fri,  1 Nov 2013 11:16:49 +0100
Message-ID: <1383301021-16613-13-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49988 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755951Ab3KAKR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:26 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Padding NTBs to max size is part of the support for devices
optimizing their DMA transfers. This optimization depends on
max sized NTBs not being ZLP terminated. So we are much better
off dropping the padding if we are going to send a ZLP anyway.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 5aa3e60..42c8620 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -800,8 +800,12 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct s=
k_buff *skb, __le32 sign)
 	 * would be more efficient for USB HS mobile device with DMA
 	 * engine to receive a full size NTB, than canceling DMA
 	 * transfer and receiving a short packet.
+	 *
+	 * This optimization support is pointless if we end up sending
+	 * a ZLP after full sized NTBs.
 	 */
-	if (skb_out->len > CDC_NCM_MIN_TX_PKT)
+	if (!(dev->driver_info->flags & FLAG_SEND_ZLP) &&
+	    skb_out->len > CDC_NCM_MIN_TX_PKT)
 		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0,
 		       ctx->tx_max - skb_out->len);
 	else if ((skb_out->len % dev->maxpacket) =3D=3D 0)
--=20
1.7.10.4
