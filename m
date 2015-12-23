From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] net: cdc_ncm: avoid changing RX/TX buffers on MTU changes
Date: Wed, 23 Dec 2015 13:42:43 +0100
Message-ID: <1450874563-21311-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

NCM buffer sizes are negotiated with the device independently of
the network device MTU.  The RX buffers are allocated by the
usbnet framework based on the rx_urb_size value set by cdc_ncm. A
single RX buffer can hold a number of MTU sized packets.

The default usbnet change_mtu ndo only modifies rx_urb_size if it
is equal to hard_mtu.  And the cdc_ncm driver will set rx_urb_size
and hard_mtu independently of each other, based on dwNtbInMaxSize
and dwNtbOutMaxSize respectively. It was therefore assumed that
usbnet_change_mtu() would never touch rx_urb_size.  This failed to
consider the case where dwNtbInMaxSize and dwNtbOutMaxSize happens
to be equal.

=46ix by implementing an NCM specific change_mtu ndo, modifying the
netdev MTU without touching the buffer size settings.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c  |  2 +-
 drivers/net/usb/cdc_ncm.c   | 31 +++++++++++++++++++++++++++++++
 include/linux/usb/cdc_ncm.h |  1 +
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 190f8d935da4..980789503f7b 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -100,7 +100,7 @@ static const struct net_device_ops cdc_mbim_netdev_=
ops =3D {
 	.ndo_stop             =3D usbnet_stop,
 	.ndo_start_xmit       =3D usbnet_start_xmit,
 	.ndo_tx_timeout       =3D usbnet_tx_timeout,
-	.ndo_change_mtu       =3D usbnet_change_mtu,
+	.ndo_change_mtu       =3D cdc_ncm_change_mtu,
 	.ndo_set_mac_address  =3D eth_mac_addr,
 	.ndo_validate_addr    =3D eth_validate_addr,
 	.ndo_vlan_rx_add_vid  =3D cdc_mbim_rx_add_vid,
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index c48c7f8ca727..b6433fdebbb6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -41,6 +41,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/ctype.h>
+#include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/workqueue.h>
 #include <linux/mii.h>
@@ -732,6 +733,33 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 	kfree(ctx);
 }
=20
+/* we need to override the usbnet change_mtu ndo for two reasons:
+ *  - respect the negotiated maximum datagram size
+ *  - avoid unwanted changes to rx and tx buffers
+ */
+int cdc_ncm_change_mtu(struct net_device *net, int new_mtu)
+{
+	struct usbnet *dev =3D netdev_priv(net);
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	int maxmtu =3D ctx->max_datagram_size - cdc_ncm_eth_hlen(dev);
+
+	if (new_mtu <=3D 0 || new_mtu > maxmtu)
+		return -EINVAL;
+	net->mtu =3D new_mtu;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cdc_ncm_change_mtu);
+
+static const struct net_device_ops cdc_ncm_netdev_ops =3D {
+	.ndo_open	     =3D usbnet_open,
+	.ndo_stop	     =3D usbnet_stop,
+	.ndo_start_xmit	     =3D usbnet_start_xmit,
+	.ndo_tx_timeout	     =3D usbnet_tx_timeout,
+	.ndo_change_mtu	     =3D cdc_ncm_change_mtu,
+	.ndo_set_mac_address =3D eth_mac_addr,
+	.ndo_validate_addr   =3D eth_validate_addr,
+};
+
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting, int drvflags)
 {
 	struct cdc_ncm_ctx *ctx;
@@ -866,6 +894,9 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct =
usb_interface *intf, u8 data_
 	/* add our sysfs attrs */
 	dev->net->sysfs_groups[0] =3D &cdc_ncm_sysfs_attr_group;
=20
+	/* must handle MTU changes */
+	dev->net->netdev_ops =3D &cdc_ncm_netdev_ops;
+
 	return 0;
=20
 error2:
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 1f6526c76ee8..3a375d07d0dc 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -138,6 +138,7 @@ struct cdc_ncm_ctx {
 };
=20
 u8 cdc_ncm_select_altsetting(struct usb_interface *intf);
+int cdc_ncm_change_mtu(struct net_device *net, int new_mtu);
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting, int drvflags);
 void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
 struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_bu=
ff *skb, __le32 sign);
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
