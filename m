From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] f_phonet: use page-sized rather than MTU-sized RX buffers
Date: Fri,  7 Aug 2009 10:56:44 +0300
Message-ID: <1249631804-7438-2-git-send-email-remi.denis-courmont@nokia.com>
References: <1249631804-7438-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:39311 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757145AbZHGH4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 03:56:52 -0400
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n777uFDb014495
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 10:56:40 +0300
Received: from localhost.localdomain (esdhcp038135.research.nokia.com [172.21.38.135])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n777uWfe000603
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 10:56:34 +0300
In-Reply-To: <1249631804-7438-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Instead of a large (physically) linear buffer, we generate a set of
paged sk_buff, so no extra memory copy is involved. This removes
high-order allocations and saves quite a bit of memory. Phonet MTU is
65541 bytes, so the two buffers were padded to 128 kilo-bytes each.
Now, we create 17 page buffers, almost a 75% memory use reduction.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |   77 +++++++++++++++++++++++++++------=
--------
 1 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index f4eff7c..d2de10b 100644
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
@@ -52,7 +60,7 @@ struct f_phonet {
 	struct usb_request		*out_reqv[0];
 };
=20
-static int phonet_rxq_size =3D 2;
+static int phonet_rxq_size =3D 17;
=20
 static inline struct f_phonet *func_to_pn(struct usb_function *f)
 {
@@ -138,7 +146,7 @@ pn_hs_sink_desc =3D {
=20
 	.bEndpointAddress =3D	USB_DIR_OUT,
 	.bmAttributes =3D		USB_ENDPOINT_XFER_BULK,
-	.wMaxPacketSize =3D	cpu_to_le16(512),
+	.wMaxPacketSize =3D	cpu_to_le16(MAXPACKET),
 };
=20
 static struct usb_endpoint_descriptor
@@ -298,21 +306,21 @@ static void pn_net_setup(struct net_device *dev)
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
@@ -320,25 +328,37 @@ static void pn_rx_complete(struct usb_ep *ep, str=
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
@@ -356,8 +376,8 @@ static void pn_rx_complete(struct usb_ep *ep, struc=
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
@@ -375,6 +395,10 @@ static void __pn_reset(struct usb_function *f)
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
@@ -573,6 +597,7 @@ int __init phonet_bind_config(struct usb_configurat=
ion *c)
 	fp->function.set_alt =3D pn_set_alt;
 	fp->function.get_alt =3D pn_get_alt;
 	fp->function.disable =3D pn_disconnect;
+	spin_lock_init(&fp->rx.lock);
=20
 	err =3D usb_add_function(c, &fp->function);
 	if (err)
--=20
1.6.0.4

