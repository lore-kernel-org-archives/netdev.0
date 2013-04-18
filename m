From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable 1/3] net: qmi_wwan: fixup missing ethernet header (firmware bug workaround)
Date: Fri, 19 Apr 2013 00:57:09 +0200
Message-ID: <1366325831-13727-2-git-send-email-bjorn@mork.no>
References: <1366325831-13727-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1366325831-13727-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A number of LTE devices from different vendors all suffer from the
same firmware bug: Most of the packets received from the device while
it is attached to a LTE network will not have an ethernet header. The
devices work as expected when attached to 2G or 3G networks, sending
an ethernet header with all packets.

This driver is not aware of which network the modem attached to, and
even if it were there are still some packet types which are always
received with the header intact.

All devices supported by this driver have severely limited
networking capabilities:
 - can only transmit IPv4, IPv6 and possibly ARP
 - can only support a single host hardware address at any time
 - will only do point-to-point communcation with the host

Because of this, we are able to reliably identify any bogus raw IP
packets by simply looking at the 4 IP version bits.  All we need to
do is to avoid 4 or 6 in the first digit of the mac address.  This
workaround ensures this, and fix up the received packets as necessary.

Given the distribution of the bug, it is believed that the source is
the chipset vendor.  The devices which are verified to be affected are:
 Huawei E392u-12 (Qualcomm MDM9200)
 Pantech UML290  (Qualcomm MDM9600)
 Novatel USB551L (Qualcomm MDM9600)
 Novatel E362    (Qualcomm MDM9600)

It is believed that the bug depend on firmware revision, which means
that possibly all devices based on the above mentioned chipset may be
affected if we consider all available firmware revisions.

The information about affected devices and versions is likely
incomplete.  As the additional overhead for packets not needing this
fixup is very small, it is considered acceptable to apply the
workaround to all devices handled by this driver.

Reported-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |   84 ++++++++++++++++++++++++++++++++++++=
++++++++
 1 file changed, 84 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 968d5d5..d8a50c7 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
+#include <linux/etherdevice.h>
 #include <linux/mii.h>
 #include <linux/usb.h>
 #include <linux/usb/cdc.h>
@@ -52,6 +53,82 @@ struct qmi_wwan_state {
 	struct usb_interface *data;
 };
=20
+/* Make up an ethernet header if the packet doesn't have one.
+ *
+ * A firmware bug common among several devices cause them to send raw
+ * IP packets under some circumstances.  There is no way for the
+ * driver/host to know when this will happen.  And even when the bug
+ * hits, some packets will still arrive with an intact header.
+ *
+ * The supported devices are only capably of sending IPv4, IPv6 and
+ * ARP packets on a point-to-point link. Any packet with an ethernet
+ * header will have either our address or a broadcast/multicast
+ * address as destination.  ARP packets will always have a header.
+ *
+ * This means that this function will reliably add the appropriate
+ * header iff necessary, provided our hardware address does not start
+ * with 4 or 6.
+ */
+static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	__be16 proto;
+
+	/* usbnet rx_complete guarantees that skb->len is at least
+	 * hard_header_len, so we can inspect the dest address without
+	 * checking skb->len
+	 */
+	switch (skb->data[0] & 0xf0) {
+	case 0x40:
+		proto =3D htons(ETH_P_IP);
+		break;
+	case 0x60:
+		proto =3D htons(ETH_P_IPV6);
+		break;
+	default:
+		/* pass along other packets without modifications */
+		return 1;
+	}
+	if (skb_headroom(skb) < ETH_HLEN)
+		return 0;
+	skb_push(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	eth_hdr(skb)->h_proto =3D proto;
+	memset(eth_hdr(skb)->h_source, 0, ETH_ALEN);
+	memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
+	return 1;
+}
+
+/* very simplistic detection of IPv4 or IPv6 headers */
+static bool possibly_iphdr(const char *data)
+{
+	return (data[0] & 0xd0) =3D=3D 0x40;
+}
+
+/* disallow addresses which may be confused with IP headers */
+static int qmi_wwan_mac_addr(struct net_device *dev, void *p)
+{
+	int ret;
+	struct sockaddr *addr =3D p;
+
+	ret =3D eth_prepare_mac_addr_change(dev, p);
+	if (ret < 0)
+		return ret;
+	if (possibly_iphdr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	eth_commit_mac_addr_change(dev, p);
+	return 0;
+}
+
+static const struct net_device_ops qmi_wwan_netdev_ops =3D {
+	.ndo_open		=3D usbnet_open,
+	.ndo_stop		=3D usbnet_stop,
+	.ndo_start_xmit		=3D usbnet_start_xmit,
+	.ndo_tx_timeout		=3D usbnet_tx_timeout,
+	.ndo_change_mtu		=3D usbnet_change_mtu,
+	.ndo_set_mac_address	=3D qmi_wwan_mac_addr,
+	.ndo_validate_addr	=3D eth_validate_addr,
+};
+
 /* using a counter to merge subdriver requests with our own into a com=
bined state */
 static int qmi_wwan_manage_power(struct usbnet *dev, int on)
 {
@@ -229,6 +306,12 @@ next_desc:
 		usb_driver_release_interface(driver, info->data);
 	}
=20
+	/* make MAC addr easily distinguishable from an IP header */
+	if (possibly_iphdr(dev->net->dev_addr)) {
+		dev->net->dev_addr[0] |=3D 0x02;	/* set local assignment bit */
+		dev->net->dev_addr[0] &=3D 0xbf;	/* clear "IP" bit */
+	}
+	dev->net->netdev_ops =3D &qmi_wwan_netdev_ops;
 err:
 	return status;
 }
@@ -307,6 +390,7 @@ static const struct driver_info	qmi_wwan_info =3D {
 	.bind		=3D qmi_wwan_bind,
 	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
+	.rx_fixup       =3D qmi_wwan_rx_fixup,
 };
=20
 #define HUAWEI_VENDOR_ID	0x12D1
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
