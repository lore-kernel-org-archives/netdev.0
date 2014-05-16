From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next v2 07/12] net: cdc_ncm: set reasonable padding limits
Date: Fri, 16 May 2014 21:48:24 +0200
Message-ID: <1400269709-18854-8-git-send-email-bjorn@mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
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
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We pad frames larger than X to maximum size for devices which
don't need a ZLP after maximum sized frames. This allows the
device to optimize its transfers for one fixed buffer size.

X was arbitrarily set at 512 bytes regardless of real buffer
maximum, causing extreme overheads due to excessive padding of
larger tx buffers. Limit the padding to at most 3 full USB
packets, still allowing the overhead to payload ratio of 3/1.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c   | 8 ++++++--
 include/linux/usb/cdc_ncm.h | 1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b9b562b9128a..9592d4669435 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -213,6 +213,10 @@ static void cdc_ncm_update_rxtx_max(struct usbnet =
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
@@ -947,7 +951,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
 		/* variables will be reset at next call */
 	}
=20
-	/* If collected data size is less or equal CDC_NCM_MIN_TX_PKT
+	/* If collected data size is less or equal ctx->min_tx_pkt
 	 * bytes, we send buffers as it is. If we get more data, it
 	 * would be more efficient for USB HS mobile device with DMA
 	 * engine to receive a full size NTB, than canceling DMA
@@ -957,7 +961,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
 	 * a ZLP after full sized NTBs.
 	 */
 	if (!(dev->driver_info->flags & FLAG_SEND_ZLP) &&
-	    skb_out->len > CDC_NCM_MIN_TX_PKT)
+	    skb_out->len > ctx->min_tx_pkt)
 		memset(skb_put(skb_out, ctx->tx_max - skb_out->len), 0,
 		       ctx->tx_max - skb_out->len);
 	else if (skb_out->len < ctx->tx_max && (skb_out->len % dev->maxpacket=
) =3D=3D 0)
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 60a44b8a464e..79de6724d398 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -115,6 +115,7 @@ struct cdc_ncm_ctx {
 	u16 tx_seq;
 	u16 rx_seq;
 	u16 connected;
+	u16 min_tx_pkt;
 };
=20
 u8 cdc_ncm_select_altsetting(struct usb_interface *intf);
--=20
2.0.0.rc2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
