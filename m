From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] usbnet: Fix tx_bytes statistic running backward in cdc_ncm
Date: Wed, 25 Mar 2015 21:41:33 +0100
Message-ID: <1427316093-13595-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>

cdc_ncm disagrees with usbnet about how much framing overhead should
be counted in the tx_bytes statistics, and tries 'fix' this by
decrementing tx_bytes on the transmit path.  But statistics must never
be decremented except due to roll-over; this will thoroughly confuse
user-space.  Also, tx_bytes is only incremented by usbnet in the
completion path.

=46ix this by requiring drivers that set FLAG_MULTI_FRAME to set a
tx_bytes delta along with the tx_packets count.

=46ixes: beeecd42c3b4 ("net: cdc_ncm/cdc_mbim: adding NCM protocol stat=
istics")
Signed-off-by: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
This should really go to stable-3.19 and 4.0, but since it depends on
6588af614e7b ("usbnet: Fix tx_packets stat for FLAG_MULTI_FRAME drivers=
")
already in net-next, then I guess it is net-next for this patch as well=
=2E

Thanks Ben, for fixing this.

Bj=C3=B8rn

 drivers/net/usb/asix_common.c |  2 +-
 drivers/net/usb/cdc_ncm.c     |  7 +++----
 drivers/net/usb/sr9800.c      |  2 +-
 drivers/net/usb/usbnet.c      | 16 +++++++++++++---
 include/linux/usb/usbnet.h    |  6 ++++--
 5 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_commo=
n.c
index 724a9b50df7a..75d6f26729a3 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -189,7 +189,7 @@ struct sk_buff *asix_tx_fixup(struct usbnet *dev, s=
truct sk_buff *skb,
 		skb_put(skb, sizeof(padbytes));
 	}
=20
-	usbnet_set_skb_tx_stats(skb, 1);
+	usbnet_set_skb_tx_stats(skb, 1, 0);
 	return skb;
 }
=20
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 70cbea551139..c3e4da9e79ca 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1177,13 +1177,12 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struc=
t sk_buff *skb, __le32 sign)
 	ctx->tx_overhead +=3D skb_out->len - ctx->tx_curr_frame_payload;
 	ctx->tx_ntbs++;
=20
-	/* usbnet has already counted all the framing overhead.
+	/* usbnet will count all the framing overhead by default.
 	 * Adjust the stats so that the tx_bytes counter show real
 	 * payload data instead.
 	 */
-	dev->net->stats.tx_bytes -=3D skb_out->len - ctx->tx_curr_frame_paylo=
ad;
-
-	usbnet_set_skb_tx_stats(skb_out, n);
+	usbnet_set_skb_tx_stats(skb_out, n,
+				ctx->tx_curr_frame_payload - skb_out->len);
=20
 	return skb_out;
=20
diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 7650cdc8fe6b..953de13267df 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -144,7 +144,7 @@ static struct sk_buff *sr_tx_fixup(struct usbnet *d=
ev, struct sk_buff *skb,
 		skb_put(skb, sizeof(padbytes));
 	}
=20
-	usbnet_set_skb_tx_stats(skb, 1);
+	usbnet_set_skb_tx_stats(skb, 1, 0);
 	return skb;
 }
=20
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 0f3ff285f6a1..777757ae1973 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1346,9 +1346,19 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *s=
kb,
 		} else
 			urb->transfer_flags |=3D URB_ZERO_PACKET;
 	}
-	entry->length =3D urb->transfer_buffer_length =3D length;
-	if (!(info->flags & FLAG_MULTI_PACKET))
-		usbnet_set_skb_tx_stats(skb, 1);
+	urb->transfer_buffer_length =3D length;
+
+	if (info->flags & FLAG_MULTI_PACKET) {
+		/* Driver has set number of packets and a length delta.
+		 * Calculate the complete length and ensure that it's
+		 * positive.
+		 */
+		entry->length +=3D length;
+		if (WARN_ON_ONCE(entry->length <=3D 0))
+			entry->length =3D length;
+	} else {
+		usbnet_set_skb_tx_stats(skb, 1, length);
+	}
=20
 	spin_lock_irqsave(&dev->txq.lock, flags);
 	retval =3D usb_autopm_get_interface_async(dev->intf);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ff3fb2bd0e90..6e0ce8c7b8cb 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -227,7 +227,7 @@ struct skb_data {	/* skb->cb is one of these */
 	struct urb		*urb;
 	struct usbnet		*dev;
 	enum skb_state		state;
-	size_t			length;
+	long			length;
 	unsigned long		packets;
 };
=20
@@ -235,11 +235,13 @@ struct skb_data {	/* skb->cb is one of these */
  * tx_fixup method before returning an skb.
  */
 static inline void
-usbnet_set_skb_tx_stats(struct sk_buff *skb, unsigned long packets)
+usbnet_set_skb_tx_stats(struct sk_buff *skb,
+			unsigned long packets, long bytes_delta)
 {
 	struct skb_data *entry =3D (struct skb_data *) skb->cb;
=20
 	entry->packets =3D packets;
+	entry->length =3D bytes_delta;
 }
=20
 extern int usbnet_open(struct net_device *net);
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
