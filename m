From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 4/4] f_phonet: use page-sized rather than MTU-sized RX buffers
Date: Mon,  6 Apr 2009 18:02:57 +0300
Message-ID: <1239030177-28783-4-git-send-email-remi.denis-courmont@nokia.com>
References: <200904061758.58057.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:43733 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbZDFPE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 11:04:26 -0400
In-Reply-To: <200904061758.58057.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Instead of a large (physically) linear buffer, we generate a paged
sk_buff, so no extra memory copy is involved.

This removes high-order allocations and saves quite a bit of locked
memory (MTU is 65543 bytes, was padded to 128 kilo-bytes). This also
limits overcharging of the receiver socket buffer space.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |   76 +++++++++++++++++++++++++++------=
-------
 1 files changed, 51 insertions(+), 25 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index 25e711f..51235f2 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -35,6 +35,10 @@
 #include "u_phonet.h"
=20
 #define PN_MEDIA_USB	0x1B
+#define MAXPACKET	512
+#if (PAGE_SIZE % MAXPACKET)
+#error MAXPACKET must divide PAGE_SIZE!
+#endif
=20
 /*--------------------------------------------------------------------=
-----*/
=20
@@ -45,6 +49,10 @@ struct phonet_port {
=20
 struct f_phonet {
 	struct usb_function		function;
+	struct {
+		struct sk_buff		*skb;
+		spinlock_t		lock;
+	} rx;
 	struct net_device		*dev;
 	struct usb_ep			*in_ep, *out_ep;
=20
@@ -138,7 +146,7 @@ pn_hs_sink_desc =3D {
=20
 	.bEndpointAddress =3D	USB_DIR_OUT,
 	.bmAttributes =3D		USB_ENDPOINT_XFER_BULK,
-	.wMaxPacketSize =3D	cpu_to_le16(512),
+	.wMaxPacketSize =3D	cpu_to_le16(MAXPACKET),
 };
=20
 static struct usb_endpoint_descriptor
@@ -308,21 +316,21 @@ static void pn_net_setup(struct net_device *dev)
 static int
 pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_f=
lags)
 {
-	struct sk_buff *skb;
-	const size_t size =3D fp->dev->mtu;
+	struct net_device *dev =3D fp->dev;
+	struct page *page;
 	int err;
=20
-	skb =3D alloc_skb(size, gfp_flags);
-	if (!skb)
+	page =3D __netdev_alloc_page(dev, gfp_flags);
+	if (!page)
 		return -ENOMEM;
=20
-	req->buf =3D skb->data;
-	req->length =3D size;
-	req->context =3D skb;
+	req->buf =3D page_address(page);
+	req->length =3D PAGE_SIZE;
+	req->context =3D page;
=20
 	err =3D usb_ep_queue(fp->out_ep, req, gfp_flags);
 	if (unlikely(err))
-		dev_kfree_skb_any(skb);
+		netdev_free_page(dev, page);
 	return err;
 }
=20
@@ -330,25 +338,37 @@ static void pn_rx_complete(struct usb_ep *ep, str=
uct usb_request *req)
 {
 	struct f_phonet *fp =3D ep->driver_data;
 	struct net_device *dev =3D fp->dev;
-	struct sk_buff *skb =3D req->context;
+	struct page *page =3D req->context;
+	struct sk_buff *skb;
+	unsigned long flags;
 	int status =3D req->status;
=20
 	switch (status) {
 	case 0:
-		if (unlikely(!netif_running(dev)))
-			break;
-		if (unlikely(req->actual < 1))
+		spin_lock_irqsave(&fp->rx.lock, flags);
+		skb =3D fp->rx.skb;
+		if (!skb)
+			skb =3D fp->rx.skb =3D netdev_alloc_skb(dev, 12);
+		if (req->actual < req->length) /* Last fragment */
+			fp->rx.skb =3D NULL;
+		spin_unlock_irqrestore(&fp->rx.lock, flags);
+
+		if (unlikely(!skb))
 			break;
-		skb_put(skb, req->actual);
-		skb->protocol =3D htons(ETH_P_PHONET);
-		skb_reset_mac_header(skb);
-		__skb_pull(skb, 1);
-		skb->dev =3D dev;
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes +=3D skb->len;
-
-		netif_rx(skb);
-		skb =3D NULL;
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page, 0,
+				req->actual);
+		page =3D NULL;
+
+		if (req->actual < req->length) { /* Last fragment */
+			skb->protocol =3D htons(ETH_P_PHONET);
+			skb_reset_mac_header(skb);
+			pskb_pull(skb, 1);
+			skb->dev =3D dev;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes +=3D skb->len;
+
+			netif_rx(skb);
+		}
 		break;
=20
 	/* Do not resubmit in these cases: */
@@ -366,8 +386,8 @@ static void pn_rx_complete(struct usb_ep *ep, struc=
t usb_request *req)
 		break;
 	}
=20
-	if (skb)
-		dev_kfree_skb_any(skb);
+	if (page)
+		netdev_free_page(dev, page);
 	if (req)
 		pn_rx_submit(fp, req, GFP_ATOMIC);
 }
@@ -386,6 +407,10 @@ static void __pn_reset(struct usb_function *f)
=20
 	usb_ep_disable(fp->out_ep);
 	usb_ep_disable(fp->in_ep);
+	if (fp->rx.skb) {
+		dev_kfree_skb_irq(fp->rx.skb);
+		fp->rx.skb =3D NULL;
+	}
 }
=20
 static int pn_set_alt(struct usb_function *f, unsigned intf, unsigned =
alt)
@@ -584,6 +609,7 @@ int __init phonet_bind_config(struct usb_configurat=
ion *c)
 	fp->function.set_alt =3D pn_set_alt;
 	fp->function.get_alt =3D pn_get_alt;
 	fp->function.disable =3D pn_disconnect;
+	spin_lock_init(&fp->rx.lock);
=20
 	err =3D usb_add_function(c, &fp->function);
 	if (err)
--=20
1.5.6.5

