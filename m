From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 05/24] net: cdc_ncm: remove redundant netdev field
Date: Fri,  1 Nov 2013 11:16:42 +0100
Message-ID: <1383301021-16613-6-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Too many pointers back and forth are likely to confuse developers,
creating subtle bugs whenever we forget to syncronize them all.

As a usbnet driver, we should stick with the standard struct
usbnet fields as much as possible.  The netdevice is one such
field.

Cc: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c  |    2 +-
 drivers/net/usb/cdc_ncm.c   |   73 ++++++++++++++++++++++-------------=
--------
 include/linux/usb/cdc_ncm.h |    3 +-
 3 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 253472a..af76aaf 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -175,7 +175,7 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usb=
net *dev, struct sk_buff *skb
 	}
=20
 	spin_lock_bh(&ctx->mtx);
-	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb, sign);
+	skb_out =3D cdc_ncm_fill_tx_frame(dev, skb, sign);
 	spin_unlock_bh(&ctx->mtx);
 	return skb_out;
=20
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index a989bd5..e39e767 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -80,8 +80,9 @@ cdc_ncm_get_drvinfo(struct net_device *net, struct et=
htool_drvinfo *info)
 	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
 }
=20
-static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
+static u8 cdc_ncm_setup(struct usbnet *dev)
 {
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
 	u32 val;
 	u8 flags;
 	u8 iface_no;
@@ -90,7 +91,6 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	u16 ntb_fmt_supported;
 	u32 min_dgram_size;
 	u32 min_hdr_size;
-	struct usbnet *dev =3D netdev_priv(ctx->netdev);
=20
 	iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
=20
@@ -285,8 +285,8 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	}
=20
 max_dgram_err:
-	if (ctx->netdev->mtu !=3D (ctx->max_datagram_size - eth_hlen))
-		ctx->netdev->mtu =3D ctx->max_datagram_size - eth_hlen;
+	if (dev->net->mtu !=3D (ctx->max_datagram_size - eth_hlen))
+		dev->net->mtu =3D ctx->max_datagram_size - eth_hlen;
=20
 	return 0;
 }
@@ -375,11 +375,10 @@ int cdc_ncm_bind_common(struct usbnet *dev, struc=
t usb_interface *intf, u8 data_
=20
 	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 	ctx->tx_timer.function =3D &cdc_ncm_tx_timer_cb;
-	ctx->bh.data =3D (unsigned long)ctx;
+	ctx->bh.data =3D (unsigned long)dev;
 	ctx->bh.func =3D cdc_ncm_txpath_bh;
 	atomic_set(&ctx->stop, 0);
 	spin_lock_init(&ctx->mtx);
-	ctx->netdev =3D dev->net;
=20
 	/* store ctx pointer in device data field */
 	dev->data[0] =3D (unsigned long)ctx;
@@ -477,7 +476,7 @@ advance:
 		goto error2;
=20
 	/* initialize data interface */
-	if (cdc_ncm_setup(ctx))
+	if (cdc_ncm_setup(dev))
 		goto error2;
=20
 	/* configure data interface */
@@ -669,9 +668,9 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct=
 cdc_ncm_ctx *ctx, struct sk_
 }
=20
 struct sk_buff *
-cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __=
le32 sign)
+cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 =
sign)
 {
-	struct usbnet *dev =3D netdev_priv(ctx->netdev);
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
 	struct usb_cdc_ncm_nth16 *nth16;
 	struct usb_cdc_ncm_ndp16 *ndp16;
 	struct sk_buff *skb_out;
@@ -695,7 +694,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, stru=
ct sk_buff *skb, __le32 sign)
 		if (skb_out =3D=3D NULL) {
 			if (skb !=3D NULL) {
 				dev_kfree_skb_any(skb);
-				ctx->netdev->stats.tx_dropped++;
+				dev->net->stats.tx_dropped++;
 			}
 			goto exit_no_skb;
 		}
@@ -733,12 +732,12 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb, __le32 sign)
 				/* won't fit, MTU problem? */
 				dev_kfree_skb_any(skb);
 				skb =3D NULL;
-				ctx->netdev->stats.tx_dropped++;
+				dev->net->stats.tx_dropped++;
 			} else {
 				/* no room for skb - store for later */
 				if (ctx->tx_rem_skb !=3D NULL) {
 					dev_kfree_skb_any(ctx->tx_rem_skb);
-					ctx->netdev->stats.tx_dropped++;
+					dev->net->stats.tx_dropped++;
 				}
 				ctx->tx_rem_skb =3D skb;
 				ctx->tx_rem_sign =3D sign;
@@ -771,7 +770,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, stru=
ct sk_buff *skb, __le32 sign)
 	if (skb !=3D NULL) {
 		dev_kfree_skb_any(skb);
 		skb =3D NULL;
-		ctx->netdev->stats.tx_dropped++;
+		dev->net->stats.tx_dropped++;
 	}
=20
 	ctx->tx_curr_frame_num =3D n;
@@ -814,7 +813,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, stru=
ct sk_buff *skb, __le32 sign)
=20
 	/* return skb */
 	ctx->tx_curr_skb =3D NULL;
-	ctx->netdev->stats.tx_packets +=3D ctx->tx_curr_frame_num;
+	dev->net->stats.tx_packets +=3D ctx->tx_curr_frame_num;
 	return skb_out;
=20
 exit_no_skb:
@@ -846,18 +845,19 @@ static enum hrtimer_restart cdc_ncm_tx_timer_cb(s=
truct hrtimer *timer)
=20
 static void cdc_ncm_txpath_bh(unsigned long param)
 {
-	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)param;
+	struct usbnet *dev =3D (struct usbnet *)param;
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
=20
 	spin_lock_bh(&ctx->mtx);
 	if (ctx->tx_timer_pending !=3D 0) {
 		ctx->tx_timer_pending--;
 		cdc_ncm_tx_timeout_start(ctx);
 		spin_unlock_bh(&ctx->mtx);
-	} else if (ctx->netdev !=3D NULL) {
+	} else if (dev->net !=3D NULL) {
 		spin_unlock_bh(&ctx->mtx);
-		netif_tx_lock_bh(ctx->netdev);
-		usbnet_start_xmit(NULL, ctx->netdev);
-		netif_tx_unlock_bh(ctx->netdev);
+		netif_tx_lock_bh(dev->net);
+		usbnet_start_xmit(NULL, dev->net);
+		netif_tx_unlock_bh(dev->net);
 	} else {
 		spin_unlock_bh(&ctx->mtx);
 	}
@@ -880,7 +880,7 @@ cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff=
 *skb, gfp_t flags)
 		goto error;
=20
 	spin_lock_bh(&ctx->mtx);
-	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb, cpu_to_le32(USB_CDC_NCM_N=
DP16_NOCRC_SIGN));
+	skb_out =3D cdc_ncm_fill_tx_frame(dev, skb, cpu_to_le32(USB_CDC_NCM_N=
DP16_NOCRC_SIGN));
 	spin_unlock_bh(&ctx->mtx);
 	return skb_out;
=20
@@ -1047,9 +1047,10 @@ error:
 }
=20
 static void
-cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
+cdc_ncm_speed_change(struct usbnet *dev,
 		     struct usb_cdc_speed_change *data)
 {
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
 	uint32_t rx_speed =3D le32_to_cpu(data->DLBitRRate);
 	uint32_t tx_speed =3D le32_to_cpu(data->ULBitRate);
=20
@@ -1063,18 +1064,18 @@ cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
=20
 		if ((tx_speed > 1000000) && (rx_speed > 1000000)) {
 			printk(KERN_INFO KBUILD_MODNAME
-				": %s: %u mbit/s downlink "
-				"%u mbit/s uplink\n",
-				ctx->netdev->name,
-				(unsigned int)(rx_speed / 1000000U),
-				(unsigned int)(tx_speed / 1000000U));
+			       ": %s: %u mbit/s downlink "
+			       "%u mbit/s uplink\n",
+			       dev->net->name,
+			       (unsigned int)(rx_speed / 1000000U),
+			       (unsigned int)(tx_speed / 1000000U));
 		} else {
 			printk(KERN_INFO KBUILD_MODNAME
-				": %s: %u kbit/s downlink "
-				"%u kbit/s uplink\n",
-				ctx->netdev->name,
-				(unsigned int)(rx_speed / 1000U),
-				(unsigned int)(tx_speed / 1000U));
+			       ": %s: %u kbit/s downlink "
+			       "%u kbit/s uplink\n",
+			       dev->net->name,
+			       (unsigned int)(rx_speed / 1000U),
+			       (unsigned int)(tx_speed / 1000U));
 		}
 	}
 }
@@ -1091,7 +1092,7 @@ static void cdc_ncm_status(struct usbnet *dev, st=
ruct urb *urb)
=20
 	/* test for split data in 8-byte chunks */
 	if (test_and_clear_bit(EVENT_STS_SPLIT, &dev->flags)) {
-		cdc_ncm_speed_change(ctx,
+		cdc_ncm_speed_change(dev,
 		      (struct usb_cdc_speed_change *)urb->transfer_buffer);
 		return;
 	}
@@ -1108,8 +1109,8 @@ static void cdc_ncm_status(struct usbnet *dev, st=
ruct urb *urb)
 		ctx->connected =3D le16_to_cpu(event->wValue);
=20
 		printk(KERN_INFO KBUILD_MODNAME ": %s: network connection:"
-			" %sconnected\n",
-			ctx->netdev->name, ctx->connected ? "" : "dis");
+		       " %sconnected\n",
+		       dev->net->name, ctx->connected ? "" : "dis");
=20
 		usbnet_link_change(dev, ctx->connected, 0);
 		if (!ctx->connected)
@@ -1121,8 +1122,8 @@ static void cdc_ncm_status(struct usbnet *dev, st=
ruct urb *urb)
 					sizeof(struct usb_cdc_speed_change)))
 			set_bit(EVENT_STS_SPLIT, &dev->flags);
 		else
-			cdc_ncm_speed_change(ctx,
-				(struct usb_cdc_speed_change *) &event[1]);
+			cdc_ncm_speed_change(dev,
+					     (struct usb_cdc_speed_change *)&event[1]);
 		break;
=20
 	default:
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 36e1e15..5c47bd9 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -98,7 +98,6 @@ struct cdc_ncm_ctx {
 	const struct usb_cdc_union_desc *union_desc;
 	const struct usb_cdc_ether_desc *ether_desc;
=20
-	struct net_device *netdev;
 	struct usb_device *udev;
 	struct usb_interface *control;
 	struct usb_interface *data;
@@ -129,7 +128,7 @@ struct cdc_ncm_ctx {
 extern u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_int=
erface *intf);
 extern int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interfac=
e *intf, u8 data_altsetting);
 extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *i=
ntf);
-extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, =
struct sk_buff *skb, __le32 sign);
+extern struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struc=
t sk_buff *skb, __le32 sign);
 extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_=
buff *skb_in);
 extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffs=
et);
=20
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
