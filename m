From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 4/6] net: qmi_wwan: support "raw IP" mode
Date: Thu,  3 Dec 2015 19:24:21 +0100
Message-ID: <1449167063-22703-5-git-send-email-bjorn@mork.no>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35845 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbbLCSZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 13:25:12 -0500
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QMI wwan devices have traditionally emulated ethernet devices
by default. But they have always had the capability of operating
without any L2 header at all, transmitting and receiving "raw"
IP packets over the USB link.  This firmware feature used to be
configurable through the QMI management protocol.

Traditionally there was no way to verify the firmware mode
without attempting to change it.  And the firmware would often
disallow changes anyway, i.e. due to a session already being
established.  In some cases, this could be a hidden firmware
internal session, completely outside host control.  For these
reasons, sticking with the "well known" default mode was safest.

But newer generations of QMI hardware and firmware have moved
towards defaulting to "raw IP" mode instead, followed by an
increasing number of bugs in the already buggy "802.3" firmware
implementation. At the same time, the QMI management protocol
gained the ability to detect the current mode.  This has enabled
the userspace QMI management application to verify the current
firmware mode without trying to modify it.

=46ollowing this development, the latest QMI hardware and firmware
(the MDM9x30 generation) has dropped support for "802.3" mode
entirely. Support for "raw IP" framing in the driver is therefore
necessary for these devices, and to a certain degree to work
around problems with the previous generation,

This patch adds support for "raw IP" framing for QMI devices,
changing the netdev from an ethernet device to an ARPHRD_NONE
p-t-p device when "raw IP" framing is enabled.

The firmware setup is fully delegated to the QMI userspace
management application, through simple tunneling of the QMI
protocol. The driver will therefore not know which mode has been
"negotiated" between firmware and userspace. Allowing userspace
to inform the driver of the result through a sysfs switch is
considered a better alternative than to change the well established
clean delegation of firmware management to userspace.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 98 ++++++++++++++++++++++++++++++++++++++=
+++++++-
 1 file changed, 97 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index e3727b66d850..98add3bf8821 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
+#include <linux/if_arp.h>
 #include <linux/mii.h>
 #include <linux/usb.h>
 #include <linux/usb/cdc.h>
@@ -48,11 +49,93 @@
 struct qmi_wwan_state {
 	struct usb_driver *subdriver;
 	atomic_t pmcount;
-	unsigned long unused;
+	unsigned long flags;
 	struct usb_interface *control;
 	struct usb_interface *data;
 };
=20
+enum qmi_wwan_flags {
+	QMI_WWAN_FLAG_RAWIP =3D 1 << 0,
+};
+
+static void qmi_wwan_netdev_setup(struct net_device *net)
+{
+	struct usbnet *dev =3D netdev_priv(net);
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	if (info->flags & QMI_WWAN_FLAG_RAWIP) {
+		net->header_ops      =3D NULL;  /* No header */
+		net->type            =3D ARPHRD_NONE;
+		net->hard_header_len =3D 0;
+		net->addr_len        =3D 0;
+		net->flags           =3D IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST=
;
+		netdev_dbg(net, "mode: raw IP\n");
+	} else if (!net->header_ops) { /* don't bother if already set */
+		ether_setup(net);
+		netdev_dbg(net, "mode: Ethernet\n");
+	}
+
+	/* recalculate buffers after changing hard_header_len */
+	usbnet_change_mtu(net, net->mtu);
+}
+
+static ssize_t raw_ip_show(struct device *d, struct device_attribute *=
attr, char *buf)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+
+	return sprintf(buf, "%c\n", info->flags & QMI_WWAN_FLAG_RAWIP ? 'Y' :=
 'N');
+}
+
+static ssize_t raw_ip_store(struct device *d,  struct device_attribute=
 *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	bool enable;
+	int err;
+
+	if (strtobool(buf, &enable))
+		return -EINVAL;
+
+	/* no change? */
+	if (enable =3D=3D (info->flags & QMI_WWAN_FLAG_RAWIP))
+		return len;
+
+	/* we don't want to modify a running netdev */
+	if (netif_running(dev->net)) {
+		netdev_err(dev->net, "Cannot change a running device\n");
+		return -EBUSY;
+	}
+
+	/* let other drivers deny the change */
+	err =3D call_netdevice_notifiers(NETDEV_PRE_TYPE_CHANGE, dev->net);
+	err =3D notifier_to_errno(err);
+	if (err) {
+		netdev_err(dev->net, "Type change was refused\n");
+		return err;
+	}
+
+	if (enable)
+		info->flags |=3D QMI_WWAN_FLAG_RAWIP;
+	else
+		info->flags &=3D ~QMI_WWAN_FLAG_RAWIP;
+	qmi_wwan_netdev_setup(dev->net);
+	call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev->net);
+	return len;
+}
+
+static DEVICE_ATTR_RW(raw_ip);
+
+static struct attribute *qmi_wwan_sysfs_attrs[] =3D {
+	&dev_attr_raw_ip.attr,
+	NULL,
+};
+
+static struct attribute_group qmi_wwan_sysfs_attr_group =3D {
+	.name =3D "qmi",
+	.attrs =3D qmi_wwan_sysfs_attrs,
+};
+
 /* default ethernet address used by the modem */
 static const u8 default_modem_addr[ETH_ALEN] =3D {0x02, 0x50, 0xf3};
=20
@@ -80,6 +163,8 @@ static const u8 buggy_fw_addr[ETH_ALEN] =3D {0x00, 0=
xa0, 0xc6, 0x00, 0x00, 0x00};
  */
 static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
+	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	bool rawip =3D info->flags & QMI_WWAN_FLAG_RAWIP;
 	__be16 proto;
=20
 	/* This check is no longer done by usbnet */
@@ -94,15 +179,25 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, s=
truct sk_buff *skb)
 		proto =3D htons(ETH_P_IPV6);
 		break;
 	case 0x00:
+		if (rawip)
+			return 0;
 		if (is_multicast_ether_addr(skb->data))
 			return 1;
 		/* possibly bogus destination - rewrite just in case */
 		skb_reset_mac_header(skb);
 		goto fix_dest;
 	default:
+		if (rawip)
+			return 0;
 		/* pass along other packets without modifications */
 		return 1;
 	}
+	if (rawip) {
+		skb->dev =3D dev->net; /* normally set by eth_type_trans */
+		skb->protocol =3D proto;
+		return 1;
+	}
+
 	if (skb_headroom(skb) < ETH_HLEN)
 		return 0;
 	skb_push(skb, ETH_HLEN);
@@ -326,6 +421,7 @@ static int qmi_wwan_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 		dev->net->dev_addr[0] &=3D 0xbf;	/* clear "IP" bit */
 	}
 	dev->net->netdev_ops =3D &qmi_wwan_netdev_ops;
+	dev->net->sysfs_groups[0] =3D &qmi_wwan_sysfs_attr_group;
 err:
 	return status;
 }
--=20
2.1.4
