From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC 7/9] net: cdc_ncm: set reasonable padding limits
Date: Fri,  2 May 2014 23:11:54 +0200
Message-ID: <1399065116-19946-8-git-send-email-bjorn@mork.no>
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
Received: from canardo.mork.no ([148.122.252.1]:55170 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724AbaEBVMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 17:12:15 -0400
In-Reply-To: <1399065116-19946-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We pad frames larger than X to maximum size for devices which
don't need a ZLP after maximum sized frames. This allows the
device to optimize its transfers for one fixed buffer size.

X was arbitrarily set at 512 bytes regardless of real buffer
maximum, causing extreme overheads due to excessive padding of
larger tx buffers. Limit the padding to at most 3 full USB
packets, still allowing the overhead to payload ratio of 3/1.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   | 8 ++++++--
 include/linux/usb/cdc_ncm.h | 1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index faa494c0377e..e28b530bff3a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -201,6 +201,10 @@ static void cdc_ncm_update_rxtx_max(struct usbnet =
*dev, u32 new_rx, u32 new_tx)
=20
 	/* max qlen depend on hard_mtu and rx_urb_size */
 	usbnet_update_max_qlen(dev);
+
+	/* never pad more than 3 full USB packets per transfer */
+	ctx->min_tx_pkt =3D clamp_t(u16, ctx->tx_max - 3 * usb_maxpacket(dev-=
>udev, dev->out, 1),
+				  CDC_NCM_MIN_TX_PKT, ctx->tx_max);
 }
=20
 /* helpers for NCM and MBIM differences */
@@ -936,7 +940,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
 		/* variables will be reset at next call */
 	}
=20
-	/* If collected data size is less or equal CDC_NCM_MIN_TX_PKT
+	/* If collected data size is less or equal ctx->min_tx_pkt
 	 * bytes, we send buffers as it is. If we get more data, it
 	 * would be more efficient for USB HS mobile device with DMA
 	 * engine to receive a full size NTB, than canceling DMA
@@ -946,7 +950,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
 	 * a ZLP after full sized NTBs.
 	 */
 	if (!(dev->driver_info->flags & FLAG_SEND_ZLP) &&
-	    skb_out->len > CDC_NCM_MIN_TX_PKT)
+	    skb_out->len > ctx->min_tx_pkt)
 		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0,
 		       ctx->tx_max - skb_out->len);
 	else if ((skb_out->len % dev->maxpacket) =3D=3D 0)
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index bbc4ce9ffef5..0aac70ee23b6 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -115,6 +115,7 @@ struct cdc_ncm_ctx {
 	u16 tx_seq;
 	u16 rx_seq;
 	u16 connected;
+	u16 min_tx_pkt;
 };
=20
 u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_interface =
*intf);
--=20
2.0.0.rc0
