From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next v2 1/4] net: cdc_mbim: optionally use VLAN ID 4094 for IP session 0
Date: Sun, 11 May 2014 10:47:12 +0200
Message-ID: <1399798035-29117-2-git-send-email-bjorn@mork.no>
References: <1399798035-29117-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399798035-29117-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The cdc_mbim driver maps 802.1q VLANs to MBIM IP and DSS
sessions. MBIM IP session 0 is handled as an exception and
is mapped to untagged frames.

This patch adds optional support for remapping MBIM IP
session 0 to 802.1q VLAN ID 4094 instead. The default
behaviour is not changed. The new behaviour is triggered
by adding a link for this previously unsupported VLAN.

The untagged mapping was chosen initially to support the
assumed most common use case: Most current MBIM devices only
support a single IP session (i.e. session 0 only), and using
untagged frames lets the users completely ignore the
additonal complexity of the multiplexing layer.

But when the multiplexing features of MBIM are used, then
this netdev gets a double meaning: It becomes the master
interface for all the VLAN subdevs the additional sessions
are mapped to, while still serving as the untagged IP
interface for session 0.

This can be problematic, especially when using Device Service
Streams (DSS), as have become apparent recently with the
availability of devices with real DSS support. Some use cases
need to e.g set a MTU which is higher than allowed for IP
Session 0. The dual role also leads to the situation where
the IP Session 0 interface cannot be taken down without
breaking unrelated IP or DSS sessions - a devastating side
effect which applications managing a simple IP session cannot
be expected to be aware of. A typical DHCP client will assume
that it should bring the interface down after releasing the
IP lease.

These problems can be avoided by tagging IP session 0 packets
too, making this session similar to all other multiplexed
sessions. This redefines the main netdev as an upper master
interface only.

Cc: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c | 74 ++++++++++++++++++++++++++++++++++++++=
++++----
 1 file changed, 68 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 076aa8a179fb..572c09a601e1 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -24,13 +24,21 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
=20
+/* alternative VLAN for IP session 0 if not untagged */
+#define MBIM_IPS0_VID	4094
+
 /* driver specific data - must match cdc_ncm usage */
 struct cdc_mbim_state {
 	struct cdc_ncm_ctx *ctx;
 	atomic_t pmcount;
 	struct usb_driver *subdriver;
-	struct usb_interface *control;
-	struct usb_interface *data;
+	unsigned long _unused;
+	unsigned long flags;
+};
+
+/* flags for the cdc_mbim_state.flags field */
+enum cdc_mbim_flags {
+	FLAG_IPS0_VLAN =3D 1 << 0,	/* IP session 0 is tagged  */
 };
=20
 /* using a counter to merge subdriver requests with our own into a com=
bined state */
@@ -62,6 +70,42 @@ static int cdc_mbim_wdm_manage_power(struct usb_inte=
rface *intf, int status)
 	return cdc_mbim_manage_power(dev, status);
 }
=20
+static int cdc_mbim_rx_add_vid(struct net_device *netdev, __be16 proto=
, u16 vid)
+{
+	struct usbnet *dev =3D netdev_priv(netdev);
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+
+	/* creation of this VLAN is a request to tag IP session 0 */
+	if (vid =3D=3D MBIM_IPS0_VID)
+		info->flags |=3D FLAG_IPS0_VLAN;
+	else
+		if (vid >=3D 512)	/* we don't map these to MBIM session */
+			return -EINVAL;
+	return 0;
+}
+
+static int cdc_mbim_rx_kill_vid(struct net_device *netdev, __be16 prot=
o, u16 vid)
+{
+	struct usbnet *dev =3D netdev_priv(netdev);
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+
+	/* this is a request for an untagged IP session 0 */
+	if (vid =3D=3D MBIM_IPS0_VID)
+		info->flags &=3D ~FLAG_IPS0_VLAN;
+	return 0;
+}
+
+static const struct net_device_ops cdc_mbim_netdev_ops =3D {
+	.ndo_open             =3D usbnet_open,
+	.ndo_stop             =3D usbnet_stop,
+	.ndo_start_xmit       =3D usbnet_start_xmit,
+	.ndo_tx_timeout       =3D usbnet_tx_timeout,
+	.ndo_change_mtu       =3D usbnet_change_mtu,
+	.ndo_set_mac_address  =3D eth_mac_addr,
+	.ndo_validate_addr    =3D eth_validate_addr,
+	.ndo_vlan_rx_add_vid  =3D cdc_mbim_rx_add_vid,
+	.ndo_vlan_rx_kill_vid =3D cdc_mbim_rx_kill_vid,
+};
=20
 static int cdc_mbim_bind(struct usbnet *dev, struct usb_interface *int=
f)
 {
@@ -101,7 +145,10 @@ static int cdc_mbim_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 	dev->net->flags |=3D IFF_NOARP;
=20
 	/* no need to put the VLAN tci in the packet headers */
-	dev->net->features |=3D NETIF_F_HW_VLAN_CTAG_TX;
+	dev->net->features |=3D NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTA=
G_FILTER;
+
+	/* monitor VLAN additions and removals */
+	dev->net->netdev_ops =3D &cdc_mbim_netdev_ops;
 err:
 	return ret;
 }
@@ -164,12 +211,24 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct u=
sbnet *dev, struct sk_buff *skb
 			skb_pull(skb, ETH_HLEN);
 		}
=20
+		/* Is IP session <0> tagged too? */
+		if (info->flags & FLAG_IPS0_VLAN) {
+			/* drop all untagged packets */
+			if (!tci)
+				goto error;
+			/* map MBIM_IPS0_VID to IPS<0> */
+			if (tci =3D=3D MBIM_IPS0_VID)
+				tci =3D 0;
+		}
+
 		/* mapping VLANs to MBIM sessions:
-		 *   no tag     =3D> IPS session <0>
+		 *   no tag     =3D> IPS session <0> if !FLAG_IPS0_VLAN
 		 *   1 - 255    =3D> IPS session <vlanid>
 		 *   256 - 511  =3D> DSS session <vlanid - 256>
-		 *   512 - 4095 =3D> unsupported, drop
+		 *   512 - 4093 =3D> unsupported, drop
+		 *   4094       =3D> IPS session <0> if FLAG_IPS0_VLAN
 		 */
+
 		switch (tci & 0x0f00) {
 		case 0x0000: /* VLAN ID 0 - 255 */
 			if (!is_ip)
@@ -260,7 +319,7 @@ static struct sk_buff *cdc_mbim_process_dgram(struc=
t usbnet *dev, u8 *buf, size_
 	__be16 proto =3D htons(ETH_P_802_3);
 	struct sk_buff *skb =3D NULL;
=20
-	if (tci < 256) { /* IPS session? */
+	if (tci < 256 || tci =3D=3D MBIM_IPS0_VID) { /* IPS session? */
 		if (len < sizeof(struct iphdr))
 			goto err;
=20
@@ -330,6 +389,9 @@ next_ndp:
 	case cpu_to_le32(USB_CDC_MBIM_NDP16_IPS_SIGN):
 		c =3D (u8 *)&ndp16->dwSignature;
 		tci =3D c[3];
+		/* tag IPS<0> packets too if MBIM_IPS0_VID exists */
+		if (!tci && info->flags & FLAG_IPS0_VLAN)
+			tci =3D MBIM_IPS0_VID;
 		break;
 	case cpu_to_le32(USB_CDC_MBIM_NDP16_DSS_SIGN):
 		c =3D (u8 *)&ndp16->dwSignature;
--=20
2.0.0.rc2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
