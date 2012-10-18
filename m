From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 13/14] net: cdc_ncm: map MBIM IPS SessionID to VLAN ID
Date: Thu, 18 Oct 2012 22:41:06 +0200
Message-ID: <1350592867-25651-14-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

MBIM devices can support up to 256 independent IP Streams.
The main network device will only handle SessionID 0. Mapping
SessionIDs 1 to 255 to VLANs using the SessionID as VLAN ID
allow userspace to use these streams with traditional tools
like vconfig.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c |   51 ++++++++++++++++++++++++++++++++++++=
+-------
 1 file changed, 43 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 2f21139..45f5f50 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/mii.h>
 #include <linux/usb.h>
@@ -107,6 +108,9 @@ static int cdc_mbim_bind(struct usbnet *dev, struct=
 usb_interface *intf)
=20
 	/* MBIM cannot do ARP */
 	dev->net->flags |=3D IFF_NOARP;
+
+	/* no need to put the VLAN tci in the packet headers */
+	dev->net->features |=3D NETIF_F_HW_VLAN_TX;
 err:
 	return ret;
 }
@@ -131,6 +135,9 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usb=
net *dev, struct sk_buff *skb
 	struct sk_buff *skb_out;
 	struct cdc_mbim_state *info =3D (void *)&dev->data;
 	struct cdc_ncm_ctx *ctx =3D info->ctx;
+	__le32 sign =3D cpu_to_le32(USB_CDC_MBIM_NDP16_IPS_SIGN);
+	u16 tci =3D 0;
+	u8 *c;
=20
 	if (!ctx)
 		goto error;
@@ -139,6 +146,24 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct us=
bnet *dev, struct sk_buff *skb
 		if (skb->len <=3D sizeof(ETH_HLEN))
 			goto error;
=20
+		/* mapping VLANs to MBIM sessions:
+		 *   no tag     =3D> IPS session <0>
+		 *   1 - 255    =3D> IPS session <vlanid>
+		 *   256 - 4095 =3D> unsupported, drop
+		 */
+		vlan_get_tag(skb, &tci);
+
+		switch (tci & 0x0f00) {
+		case 0x0000: /* VLAN ID 0 - 255 */
+			c =3D (u8 *)&sign;
+			c[3] =3D tci;
+			break;
+		default:
+			netif_err(dev, tx_err, dev->net,
+				  "unsupported tci=3D0x%04x\n", tci);
+			goto error;
+		}
+
 		skb_reset_mac_header(skb);
 		switch (eth_hdr(skb)->h_proto) {
 		case htons(ETH_P_IP):
@@ -151,7 +176,7 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usb=
net *dev, struct sk_buff *skb
 	}
=20
 	spin_lock_bh(&ctx->mtx);
-	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb, cpu_to_le32(USB_CDC_MBIM_=
NDP16_IPS_SIGN));
+	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb, sign);
 	spin_unlock_bh(&ctx->mtx);
 	return skb_out;
=20
@@ -162,11 +187,14 @@ error:
 	return NULL;
 }
=20
-static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *=
buf, size_t len)
+static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *=
buf, size_t len, u16 tci)
 {
 	__be16 proto;
 	struct sk_buff *skb =3D NULL;
=20
+	if (len < sizeof(struct iphdr))
+		goto err;
+
 	switch (*buf & 0xf0) {
 	case 0x40:
 		proto =3D htons(ETH_P_IP);
@@ -191,6 +219,10 @@ static struct sk_buff *cdc_mbim_process_dgram(stru=
ct usbnet *dev, u8 *buf, size_
=20
 	/* add datagram */
 	memcpy(skb_put(skb, len), buf, len);
+
+	/* map MBIM session to VLAN */
+	if (tci)
+		vlan_put_tag(skb, tci);
 err:
 	return skb;
 }
@@ -198,7 +230,8 @@ err:
 static int cdc_mbim_rx_fixup(struct usbnet *dev, struct sk_buff *skb_i=
n)
 {
 	struct sk_buff *skb;
-	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+	struct cdc_ncm_ctx *ctx =3D info->ctx;
 	int len;
 	int nframes;
 	int x;
@@ -207,6 +240,8 @@ static int cdc_mbim_rx_fixup(struct usbnet *dev, st=
ruct sk_buff *skb_in)
 	struct usb_cdc_ncm_dpe16 *dpe16;
 	int ndpoffset;
 	int loopcount =3D 50; /* arbitrary max preventing infinite loop */
+	u8 *c;
+	u16 tci;
=20
 	ndpoffset =3D cdc_ncm_rx_verify_nth16(ctx, skb_in);
 	if (ndpoffset < 0)
@@ -219,9 +254,10 @@ next_ndp:
=20
 	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
=20
-	/* only supporting IPS Session #0 for now */
-	switch (ndp16->dwSignature) {
+	switch (ndp16->dwSignature & cpu_to_le32(0x00ffffff)) {
 	case cpu_to_le32(USB_CDC_MBIM_NDP16_IPS_SIGN):
+		c =3D (u8 *)&ndp16->dwSignature;
+		tci =3D c[3];
 		break;
 	default:
 		netif_dbg(dev, rx_err, dev->net,
@@ -247,8 +283,7 @@ next_ndp:
 		}
=20
 		/* sanity checking */
-		if (((offset + len) > skb_in->len) || (len > ctx->rx_max) ||
-		    (len < sizeof(struct iphdr))) {
+		if (((offset + len) > skb_in->len) || (len > ctx->rx_max)) {
 			netif_dbg(dev, rx_err, dev->net,
 				  "invalid frame detected (ignored) offset[%u]=3D%u, length=3D%u, =
skb=3D%p\n",
 				  x, offset, len, skb_in);
@@ -256,7 +291,7 @@ next_ndp:
 				goto err_ndp;
 			break;
 		} else {
-			skb =3D cdc_mbim_process_dgram(dev, skb_in->data + offset, len);
+			skb =3D cdc_mbim_process_dgram(dev, skb_in->data + offset, len, tci=
);
 			if (!skb)
 				goto error;
 			usbnet_skb_return(dev, skb);
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
