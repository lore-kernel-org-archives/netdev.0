From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] net: cdc_ncm: fix buffer overflow
Date: Fri,  2 May 2014 23:27:00 +0200
Message-ID: <1399066020-22748-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55452 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbaEBV1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 17:27:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4d619f625a60 ("net: cdc_ncm: no point in filling up the NTBs
if we send ZLPs") changed the padding logic for devices with the ZLP
flag set.  This meant that frames of any size will be sent without
additional padding, except for the single byte added if the size is
a multiple of the USB packet size. But if the unpadded size is
identical to the maximum frame size, and the maximum size is a
multiplum of the USB packet size, then this one-byte padding will
overflow the buffer.

Prevent padding if already at maximum frame size, letting usbnet
transmit a ZLP instead in this case.

=46ixes: 4d619f625a60 ("net: cdc_ncm: no point in filling up the NTBs i=
f we send ZLPs")
Reported by: Yu-an Shih <yshih@nvidia.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Please add this to the stable v3.13 and v3.14 queues as well.  Thanks.

 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 549dbac710ed..9a2bd11943eb 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -785,7 +785,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
 	    skb_out->len > CDC_NCM_MIN_TX_PKT)
 		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0,
 		       ctx->tx_max - skb_out->len);
-	else if ((skb_out->len % dev->maxpacket) =3D=3D 0)
+	else if (skb_out->len < ctx->tx_max && (skb_out->len % dev->maxpacket=
) =3D=3D 0)
 		*skb_put(skb_out, 1) =3D 0;	/* force short packet */
=20
 	/* set final frame length */
--=20
2.0.0.rc0
