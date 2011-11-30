From: =?UTF-8?q?Sjur=20Br=81=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [RFC 3/3] caif: Add support for CAIF over CDC NCM USB interface
Date: Wed, 30 Nov 2011 21:44:06 +0100
Message-ID: <1322685846-7790-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61187 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab1K3Uof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 15:44:35 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so1196880eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 12:44:34 -0800 (PST)
In-Reply-To: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

NCM 1.0 does not support anything but Ethernet framing, hence
CAIF payload will be put into Ethernet frames.

Discovery is based on fixed USB vendor 0x04cc (ST-Ericsson),
product-id 0x230f (NCM). In this variant only CAIF payload is sent over
the NCM interface.

The CAIF stack (cfusbl.c) will when USB registers first check if
we got a CDC NCM USB interface with the right VID, PID.
It will then read the device's Ethernet address and create a 'template'
Ethernet TX header, using a broadcast address as the destination addres=
s,
and EthType 0x88b5 (802.1 Local Experimental - vendor specific).

A protocol handler for 0x88b5 is setup for reception of CAIF frames fro=
m
the CDC NCM USB interface.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfusbl.h |   13 +++
 net/caif/Kconfig          |   11 +++
 net/caif/Makefile         |    4 +-
 net/caif/caif_dev.c       |    7 ++
 net/caif/cfusbl.c         |  199 +++++++++++++++++++++++++++++++++++++=
++++++++
 5 files changed, 233 insertions(+), 1 deletions(-)
 create mode 100644 include/net/caif/cfusbl.h
 create mode 100644 net/caif/cfusbl.c

diff --git a/include/net/caif/cfusbl.h b/include/net/caif/cfusbl.h
new file mode 100644
index 0000000..7ef2499
--- /dev/null
+++ b/include/net/caif/cfusbl.h
@@ -0,0 +1,13 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CFUSBL_H_
+#define CFUSBL_H_
+
+void cfusbl_init(void);
+void cfusbl_exit(void);
+
+#endif				/* CFUSBL_H_ */
diff --git a/net/caif/Kconfig b/net/caif/Kconfig
index 529750d..43cd844 100644
--- a/net/caif/Kconfig
+++ b/net/caif/Kconfig
@@ -40,3 +40,14 @@ config CAIF_NETDEV
 	If you select to build it as a built-in then the main CAIF device mus=
t
 	also be a built-in.
 	If unsure say Y.
+
+config CAIF_USB
+	bool "CAIF USB support"
+	depends on CAIF
+	default CAIF
+	---help---
+	Say Y if you are using CAIF over USB CDC NCM.
+	This can be either built-in or a loadable module,
+	If you select to build it as a built-in then the main CAIF device mus=
t
+	also be a built-in.
+	If unsure say N.
diff --git a/net/caif/Makefile b/net/caif/Makefile
index ebcd4e7..3965f73 100644
--- a/net/caif/Makefile
+++ b/net/caif/Makefile
@@ -1,4 +1,5 @@
-ccflags-$(CONFIG_CAIF_DEBUG)     :=3D      -DDEBUG
+ccflags-$(CONFIG_CAIF_DEBUG) +=3D -DDEBUG
+ccflags-$(CONFIG_CAIF_USB) +=3D -DCAIF_USB
=20
 caif-y :=3D caif_dev.o \
 	cfcnfg.o cfmuxl.o cfctrl.o  \
@@ -6,6 +7,7 @@ caif-y :=3D caif_dev.o \
 	cfserl.o cfdgml.o  \
 	cfrfml.o cfvidl.o cfutill.o \
 	cfsrvl.o cfpkt_skbuff.o
+caif-$(CONFIG_CAIF_USB) +=3D cfusbl.o
=20
 obj-$(CONFIG_CAIF) +=3D caif.o
 obj-$(CONFIG_CAIF_NETDEV) +=3D chnl_net.o
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 415353e..6ef0e90 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -25,6 +25,7 @@
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfcnfg.h>
 #include <net/caif/cfserl.h>
+#include <net/caif/cfusbl.h>
=20
 MODULE_LICENSE("GPL");
=20
@@ -506,6 +507,9 @@ static int __init caif_device_init(void)
 	if (result)
 		return result;
=20
+#ifdef CAIF_USB
+	cfusbl_init();
+#endif
 	register_netdevice_notifier(&caif_device_notifier);
 	dev_add_pack(&caif_packet_type);
=20
@@ -517,6 +521,9 @@ static void __exit caif_device_exit(void)
 	unregister_pernet_device(&caif_net_ops);
 	unregister_netdevice_notifier(&caif_device_notifier);
 	dev_remove_pack(&caif_packet_type);
+#ifdef CAIF_USB
+	cfusbl_exit();
+#endif
 }
=20
 module_init(caif_device_init);
diff --git a/net/caif/cfusbl.c b/net/caif/cfusbl.c
new file mode 100644
index 0000000..8353a55
--- /dev/null
+++ b/net/caif/cfusbl.c
@@ -0,0 +1,199 @@
+/*
+ * CAIF USB handler
+ * Copyright (C) ST-Ericsson AB 2011
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ *
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
+#include <linux/netdevice.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/usbnet.h>
+#include <net/netns/generic.h>
+#include <net/caif/caif_dev.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/cfpkt.h>
+#include <net/caif/cfcnfg.h>
+
+MODULE_LICENSE("GPL");
+
+#define CFUSB_PAD_DESCR_SZ 1	/* Alignment descriptor length */
+#define CFUSB_ALIGNMENT 4	/* Number of bytes to align. */
+#define CFUSB_MAX_HEADLEN (CFUSB_PAD_DESCR_SZ + CFUSB_ALIGNMENT-1)
+#define STE_USB_VID 0x04cc	/* USB Product ID for ST-Ericsson */
+#define STE_USB_PID_CAIF 0x2306	/* Product id for CAIF Modems */
+
+struct cfusbl {
+	struct cflayer layer;
+	u8 tx_eth_hdr[ETH_HLEN];
+};
+
+static bool pack_added;
+
+static int cfusbl_receive(struct cflayer *layr, struct cfpkt *pkt)
+{
+	u8 hpad;
+
+	/* Remove padding. */
+	cfpkt_extr_head(pkt, &hpad, 1);
+	cfpkt_extr_head(pkt, NULL, hpad);
+	return layr->up->receive(layr->up, pkt);
+}
+
+static int cfusbl_transmit(struct cflayer *layr, struct cfpkt *pkt)
+{
+	struct caif_payload_info *info;
+	u8 hpad;
+	u8 zeros[CFUSB_ALIGNMENT];
+	struct sk_buff *skb;
+	struct cfusbl *usbl =3D container_of(layr, struct cfusbl, layer);
+
+	skb =3D cfpkt_tonative(pkt);
+
+	skb_reset_network_header(skb);
+	skb->protocol =3D htons(ETH_P_IP);
+
+	info =3D cfpkt_info(pkt);
+	hpad =3D (info->hdr_len + CFUSB_PAD_DESCR_SZ) & (CFUSB_ALIGNMENT - 1)=
;
+
+	if (skb_headroom(skb) < ETH_HLEN + CFUSB_PAD_DESCR_SZ + hpad) {
+		pr_warn("Headroom to small\n");
+		kfree_skb(skb);
+		return -EIO;
+	}
+	memset(zeros, 0, hpad);
+
+	cfpkt_add_head(pkt, zeros, hpad);
+	cfpkt_add_head(pkt, &hpad, 1);
+	cfpkt_add_head(pkt, usbl->tx_eth_hdr, sizeof(usbl->tx_eth_hdr));
+	return layr->dn->transmit(layr->dn, pkt);
+}
+
+static void cfusbl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctr=
l,
+					int phyid)
+{
+	if (layr->up && layr->up->ctrlcmd)
+		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
+}
+
+struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
+					u8 braddr[ETH_ALEN])
+{
+	struct cfusbl *this =3D kmalloc(sizeof(struct cfusbl), GFP_ATOMIC);
+
+	if (!this) {
+		pr_warn("Out of memory\n");
+		return NULL;
+	}
+	caif_assert(offsetof(struct cfusbl, layer) =3D=3D 0);
+
+	memset(this, 0, sizeof(struct cflayer));
+	this->layer.receive =3D cfusbl_receive;
+	this->layer.transmit =3D cfusbl_transmit;
+	this->layer.ctrlcmd =3D cfusbl_ctrlcmd;
+	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "usb%d", phyid);
+	this->layer.id =3D phyid;
+
+	/*
+	 * Construct TX ethernet header:
+	 *	0-5	destination address
+	 *	5-11	source address
+	 *	12-13	protocol type
+	 */
+	memcpy(&this->tx_eth_hdr[ETH_ALEN], braddr, ETH_ALEN);
+	memcpy(&this->tx_eth_hdr[ETH_ALEN], ethaddr, ETH_ALEN);
+	this->tx_eth_hdr[12] =3D cpu_to_be16(ETH_P_802_EX1) & 0xff;
+	this->tx_eth_hdr[13] =3D (cpu_to_be16(ETH_P_802_EX1) >> 8) & 0xff;
+	pr_debug("caif ethernet TX-header dst:%pM src:%pM type:%02x%02x\n",
+			this->tx_eth_hdr, this->tx_eth_hdr + ETH_ALEN,
+			this->tx_eth_hdr[12], this->tx_eth_hdr[13]);
+
+	return (struct cflayer *) this;
+}
+
+static struct packet_type caif_usb_type __read_mostly =3D {
+	.type =3D cpu_to_be16(ETH_P_802_EX1),
+};
+
+static int cfusbl_device_notify(struct notifier_block *me, unsigned lo=
ng what,
+			      void *arg)
+{
+	struct net_device *dev =3D arg;
+	struct caif_dev_common common;
+	struct cflayer *layer, *link_support;
+	struct usbnet	*usbnet =3D netdev_priv(dev);
+	struct usb_device	*usbdev =3D usbnet->udev;
+	struct ethtool_drvinfo drvinfo;
+
+	if (what !=3D NETDEV_REGISTER)
+		return 0;
+	/*
+	 * Quirks: High-jack ethtool to find if we have a NCM device,
+	 * and find it's VID/PID.
+	 */
+	if (dev->ethtool_ops =3D=3D NULL || dev->ethtool_ops->get_drvinfo =3D=
=3D NULL)
+		return 0;
+
+	dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
+	if (strncmp(drvinfo.driver, "cdc_ncm", 7) !=3D 0)
+		return 0;
+
+	pr_debug("USB CDC NCM device VID:0x%4x PID:0x%4x\n",
+		le16_to_cpu(usbdev->descriptor.idVendor),
+		le16_to_cpu(usbdev->descriptor.idProduct));
+
+	/* Check for VID/PID that supports CAIF */
+	if (!(le16_to_cpu(usbdev->descriptor.idVendor) =3D=3D STE_USB_VID &&
+		le16_to_cpu(usbdev->descriptor.idProduct) =3D=3D STE_USB_PID_CAIF))
+		return 0;
+
+	memset(&common, 0, sizeof(common));
+	common.use_frag =3D false;
+	common.use_fcs =3D false;
+	common.use_stx =3D false;
+	common.link_select =3D CAIF_LINK_HIGH_BANDW;
+	common.flowctrl =3D NULL;
+
+	link_support =3D cfusbl_create(dev->ifindex, dev->dev_addr,
+					dev->broadcast);
+	if (!link_support) {
+		pr_warn("Out of memory\n");
+		return -ENOMEM;
+	}
+
+	if (dev->num_tx_queues > 1)
+		pr_warn("USB device uses more than one tx queue\n");
+
+	caif_enroll_dev(dev, &common, link_support, CFUSB_MAX_HEADLEN,
+			&layer, &caif_usb_type.func);
+	if (!pack_added)
+		dev_add_pack(&caif_usb_type);
+	pack_added =3D 1;
+
+	strncpy(layer->name, dev->name,
+			sizeof(layer->name) - 1);
+	layer->name[sizeof(layer->name) - 1] =3D 0;
+
+	return 0;
+}
+
+static struct notifier_block caif_device_notifier =3D {
+	.notifier_call =3D cfusbl_device_notify,
+	.priority =3D 0,
+};
+
+void cfusbl_init(void)
+{
+	register_netdevice_notifier(&caif_device_notifier);
+}
+
+void cfusbl_exit(void)
+{
+	unregister_netdevice_notifier(&caif_device_notifier);
+	dev_remove_pack(&caif_usb_type);
+}
--=20
1.7.0.4
