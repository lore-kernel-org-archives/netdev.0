From: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Subject: =?UTF-8?q?=5BPATCH=20v2=202/2=5D=20net=3A=20asix=3A=20handle=20packets=20crossing=20URB=20boundaries?=
Date: Tue, 18 Dec 2012 16:21:23 +0100
Message-ID: <1355844083-14285-2-git-send-email-dev@lynxeye.de>
References: <1355844083-14285-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1355844083-14285-1-git-send-email-dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ASIX AX88772B started to pack data even more tightly. Packets and the A=
SIX packet
header may now cross URB boundaries. To handle this we have to introduc=
e
some state between individual calls to asix_rx_fixup().

Signed-off-by: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
---
I've running this patch for some weeks already now and it gets rid of a=
ll
the commonly seen rx failures with AX88772B.

v2: don't forget to free driver_private
---
 drivers/net/usb/asix.h         | 11 ++++++
 drivers/net/usb/asix_common.c  | 81 +++++++++++++++++++++++++++++-----=
--------
 drivers/net/usb/asix_devices.c | 17 +++++++++
 3 Dateien ge=C3=A4ndert, 85 Zeilen hinzugef=C3=BCgt(+), 24 Zeilen entf=
ernt(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index 7afe8ac..4dfdbf6 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -167,6 +167,17 @@ struct asix_data {
 	u8 res;
 };
=20
+struct asix_rx_fixup_info {
+	struct sk_buff *ax_skb;
+	u32 header;
+	u16 size;
+	bool split_head;
+};
+
+struct asix_private {
+	struct asix_rx_fixup_info rx_fixup_info;
+};
+
 /* ASIX specific flags */
 #define FLAG_EEPROM_MAC		(1UL << 0)  /* init device MAC from eeprom */
=20
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_commo=
n.c
index 50d1673..17f9801 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -53,44 +53,77 @@ void asix_write_cmd_async(struct usbnet *dev, u8 cm=
d, u16 value, u16 index,
=20
 int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
+	struct asix_private *dp =3D dev->driver_priv;
+	struct asix_rx_fixup_info *rx =3D &dp->rx_fixup_info;
 	int offset =3D 0;
=20
-	while (offset + sizeof(u32) < skb->len) {
-		struct sk_buff *ax_skb;
-		u16 size;
-		u32 header =3D get_unaligned_le32(skb->data + offset);
-
-		offset +=3D sizeof(u32);
-
-		/* get the packet length */
-		size =3D (u16) (header & 0x7ff);
-		if (size !=3D ((~header >> 16) & 0x07ff)) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
-			return 0;
+	while (offset + sizeof(u16) <=3D skb->len) {
+		u16 remaining =3D 0;
+		unsigned char *data;
+
+		if (!rx->size) {
+			if ((skb->len - offset =3D=3D sizeof(u16)) ||
+			    rx->split_head) {
+				if(!rx->split_head) {
+					rx->header =3D get_unaligned_le16(
+							skb->data + offset);
+					rx->split_head =3D true;
+					offset +=3D sizeof(u16);
+					break;
+				} else {
+					rx->header |=3D (get_unaligned_le16(
+							skb->data + offset)
+							<< 16);
+					rx->split_head =3D false;
+					offset +=3D sizeof(u16);
+				}
+			} else {
+				rx->header =3D get_unaligned_le32(skb->data +
+								offset);
+				offset +=3D sizeof(u32);
+			}
+
+			/* get the packet length */
+			rx->size =3D (u16) (rx->header & 0x7ff);
+			if (rx->size !=3D ((~rx->header >> 16) & 0x7ff)) {
+				netdev_err(dev->net, "asix_rx_fixup() Bad Header Length 0x%x, offs=
et %d\n",
+					   rx->header, offset);
+				rx->size =3D 0;
+				return 0;
+			}
+			rx->ax_skb =3D netdev_alloc_skb_ip_align(dev->net,
+							       rx->size);
+			if (!rx->ax_skb)
+				return 0;
 		}
=20
-		if ((size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) ||
-		    (size + offset > skb->len)) {
+		if (rx->size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
 			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
-				   size);
+				   rx->size);
+			kfree_skb(rx->ax_skb);
 			return 0;
 		}
-		ax_skb =3D netdev_alloc_skb_ip_align(dev->net, size);
-		if (!ax_skb)
-			return 0;
=20
-		skb_put(ax_skb, size);
-		memcpy(ax_skb->data, skb->data + offset, size);
-		usbnet_skb_return(dev, ax_skb);
+		if (rx->size > skb->len - offset) {
+			remaining =3D rx->size - (skb->len - offset);
+			rx->size =3D skb->len - offset;
+		}
+
+		data =3D skb_put(rx->ax_skb, rx->size);
+		memcpy(data, skb->data + offset, rx->size);
+		if (!remaining)
+			usbnet_skb_return(dev, rx->ax_skb);
=20
-		offset +=3D (size + 1) & 0xfffe;
+		offset +=3D (rx->size + 1) & 0xfffe;
+		rx->size =3D remaining;
 	}
=20
 	if (skb->len !=3D offset) {
-		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d\n",
-			   skb->len);
+		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d, %d\n",
+			   skb->len, offset);
 		return 0;
 	}
+
 	return 1;
 }
=20
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devi=
ces.c
index 0ecc3bc..c651243 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -495,9 +495,19 @@ static int ax88772_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 		dev->rx_urb_size =3D 2048;
 	}
=20
+	dev->driver_priv =3D kzalloc(sizeof(struct asix_private), GFP_KERNEL)=
;
+	if (!dev->driver_priv)
+		return -ENOMEM;
+
 	return 0;
 }
=20
+void ax88772_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	if (dev->driver_priv)
+		kfree(dev->driver_priv);
+}
+
 static const struct ethtool_ops ax88178_ethtool_ops =3D {
 	.get_drvinfo		=3D asix_get_drvinfo,
 	.get_link		=3D asix_get_link,
@@ -829,6 +839,10 @@ static int ax88178_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 		dev->rx_urb_size =3D 2048;
 	}
=20
+	dev->driver_priv =3D kzalloc(sizeof(struct asix_private), GFP_KERNEL)=
;
+	if (!dev->driver_priv)
+			return -ENOMEM;
+
 	return 0;
 }
=20
@@ -875,6 +889,7 @@ static const struct driver_info hawking_uf200_info =
=3D {
 static const struct driver_info ax88772_info =3D {
 	.description =3D "ASIX AX88772 USB 2.0 Ethernet",
 	.bind =3D ax88772_bind,
+	.unbind =3D ax88772_unbind,
 	.status =3D asix_status,
 	.link_reset =3D ax88772_link_reset,
 	.reset =3D ax88772_reset,
@@ -886,6 +901,7 @@ static const struct driver_info ax88772_info =3D {
 static const struct driver_info ax88772b_info =3D {
 	.description =3D "ASIX AX88772B USB 2.0 Ethernet",
 	.bind =3D ax88772_bind,
+	.unbind =3D ax88772_unbind,
 	.status =3D asix_status,
 	.link_reset =3D ax88772_link_reset,
 	.reset =3D ax88772_reset,
@@ -899,6 +915,7 @@ static const struct driver_info ax88772b_info =3D {
 static const struct driver_info ax88178_info =3D {
 	.description =3D "ASIX AX88178 USB 2.0 Ethernet",
 	.bind =3D ax88178_bind,
+	.unbind =3D ax88772_unbind,
 	.status =3D asix_status,
 	.link_reset =3D ax88178_link_reset,
 	.reset =3D ax88178_reset,
--=20
1.7.11.7

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
