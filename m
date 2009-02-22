From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 8/8] l2tp: add ethernet pseudowire support
Date: Sun, 22 Feb 2009 17:52:20 GMT
Message-ID: <200902221752.n1MHqKcA006555@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48301 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370AbZBVRqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 12:46:33 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 85F21A620B4
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:28 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XZ199MSs9DC9 for <netdev@vger.kernel.org>;
	Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id 66351A620A0
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: (from james@localhost)
	by bert.katalix.com (8.14.2/8.14.2/Submit) id n1MHqKcA006555
	for netdev@vger.kernel.org; Sun, 22 Feb 2009 17:52:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add L2TP ethernet pseudowire support.

This driver presents a regular net_device for each L2TP ethernet
pseudowire instance. These interfaces are named l2tpethN by default,
though userspace can specify an alternative name when the L2TP
session is created, if preferred. When the pseudowire is established,
regular Linux networking utilities may be used to configure the
interface, i.e. give it IP address info or add it to a bridge. Any
data passed over the interface is carried over an L2TP tunnel.

Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_eth.c
===================================================================
--- /dev/null
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_eth.c
@@ -0,0 +1,294 @@
+/*
+ * L2TPv3 ethernet pseudowire driver
+ *
+ * Copyright (c) 2008,2009 Katalix Systems Ltd
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/hash.h>
+#include <linux/l2tp.h>
+#include <linux/in.h>
+#include <linux/etherdevice.h>
+#include <net/sock.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/udp.h>
+#include <net/inet_common.h>
+#include <net/inet_hashtables.h>
+#include <net/tcp_states.h>
+#include <net/protocol.h>
+#include <net/xfrm.h>
+
+#include "l2tp_core.h"
+
+#define L2TP_ETH_DEV_NAME	"l2tpeth%d"
+
+/* via netdev_priv() */
+struct l2tp_eth {
+	struct net_device	*dev;
+	struct sock		*tunnel_sock;
+	struct l2tp_session	*session;
+	struct list_head	list;
+};
+
+/* via l2tp_session_priv() */
+struct l2tp_eth_sess {
+	struct net_device	*dev;
+};
+
+static DEFINE_RWLOCK(l2tp_eth_lock);
+static LIST_HEAD(l2tp_eth_dev_list);
+
+static struct l2tp_session *l2tp_eth_session_find_by_ifname(char *ifname)
+{
+	struct net_device *dev;
+
+	dev = dev_get_by_name(&init_net, ifname);
+	if (dev) {
+		struct l2tp_eth *priv = netdev_priv(dev);
+		return priv->session;
+	}
+
+	return NULL;
+}
+
+static int l2tp_eth_dev_init(struct net_device *dev)
+{
+	struct l2tp_eth *priv = netdev_priv(dev);
+	struct l2tp_session *session = priv->session;
+	__be32 sid = htonl(session->session_id);
+	__be32 peer_sid = htonl(session->peer_session_id);
+
+	priv->dev = dev;
+
+	/* Derive a MAC address for the new interface. We use the L2TP
+	 * session's session-id to guarantee a system-wide unique
+	 * address. This MAC is only visible within the L2TP session.
+	 */
+	dev->dev_addr[0] = 0x02; /* IEEE 802 local */
+	dev->dev_addr[1] = 'L';
+	memcpy(&dev->dev_addr[2], &sid, 4);
+	dev->broadcast[0] = 0x02; /* IEEE 802 local */
+	dev->broadcast[1] = 'L';
+	memcpy(&dev->broadcast[2], &peer_sid, 4);
+
+	return 0;
+}
+
+static void l2tp_eth_dev_uninit(struct net_device *dev)
+{
+	struct l2tp_eth *priv = netdev_priv(dev);
+
+	write_lock(&l2tp_eth_lock);
+	list_del_init(&priv->list);
+	write_unlock(&l2tp_eth_lock);
+	dev_put(dev);
+}
+
+static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct l2tp_eth *priv = netdev_priv(dev);
+	struct l2tp_session *session = priv->session;
+
+	l2tp_xmit_skb(session, skb, session->header_len);
+
+	dev->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+
+	return 0;
+}
+
+static struct net_device_ops l2tp_eth_netdev_ops = {
+	.ndo_init		= l2tp_eth_dev_init,
+	.ndo_uninit		= l2tp_eth_dev_uninit,
+	.ndo_start_xmit		= l2tp_eth_dev_xmit,
+};
+
+static void l2tp_eth_dev_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	dev->netdev_ops		= &l2tp_eth_netdev_ops;
+	dev->destructor 	= free_netdev;
+}
+
+static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb, int data_len)
+{
+	struct l2tp_eth_sess *spriv = l2tp_session_priv(session);
+	struct net_device *dev = spriv->dev;
+
+	if (session->debug & L2TP_MSG_DATA) {
+		unsigned int length;
+		int offset;
+		u8 *ptr = skb->data;
+
+		length = min(32u, skb->len);
+		if (!pskb_may_pull(skb, length))
+			goto error;
+
+		printk(KERN_DEBUG "%s: eth recv: ", session->name);
+
+		offset = 0;
+		do {
+			printk(" %02X", ptr[offset]);
+		} while (++offset < length);
+
+		printk("\n");
+	}
+
+	if (data_len < ETH_HLEN)
+		goto error;
+
+	secpath_reset(skb);
+
+	skb->protocol = eth_type_trans(skb, dev);
+
+	dev->last_rx = jiffies;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += data_len;
+
+	/* checksums verified by L2TP */
+	skb->ip_summed = CHECKSUM_NONE;
+
+	dst_release(skb->dst);
+	skb->dst = NULL;
+	nf_reset(skb);
+	netif_receive_skb(skb);
+
+	return;
+
+error:
+	dev->stats.rx_errors++;
+	kfree_skb(skb);
+}
+
+static void l2tp_eth_delete(struct l2tp_session *session)
+{
+	struct l2tp_eth_sess *spriv;
+	struct net_device *dev;
+
+	if (session) {
+		spriv = l2tp_session_priv(session);
+		dev = spriv->dev;
+		if (dev) {
+			unregister_netdev(dev);
+			spriv->dev = NULL;
+		}
+	}
+}
+
+static int l2tp_eth_create(u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
+{
+	struct net_device *dev;
+	char name[IFNAMSIZ];
+	struct l2tp_tunnel *tunnel;
+	struct l2tp_session *session;
+	struct l2tp_eth *priv;
+	struct l2tp_eth_sess *spriv;
+	int rc;
+
+	tunnel = l2tp_tunnel_find(tunnel_id);
+	if (!tunnel) {
+		rc = -ENODEV;
+		goto out;
+	}
+
+	session = l2tp_session_find(tunnel, session_id);
+	if (session) {
+		rc = -EEXIST;
+		goto out;
+	}
+
+	if (cfg->ifname) {
+		session = l2tp_eth_session_find_by_ifname(cfg->ifname);
+		if (session) {
+			rc = -EEXIST;
+			goto out;
+		}
+		strlcpy(name, cfg->ifname, IFNAMSIZ);
+	} else
+		strcpy(name, L2TP_ETH_DEV_NAME);
+
+	session = l2tp_session_create(sizeof(*spriv), tunnel, session_id,
+				      peer_session_id, cfg);
+	if (!session) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	dev = alloc_netdev(sizeof(*priv), name, l2tp_eth_dev_setup);
+	if (!dev) {
+		rc = -ENOMEM;
+		goto out_del_session;
+	}
+
+	priv = netdev_priv(dev);
+	priv->dev = dev;
+	priv->session = session;
+	INIT_LIST_HEAD(&priv->list);
+
+	priv->tunnel_sock = tunnel->sock;
+	session->recv_skb = l2tp_eth_dev_recv;
+	session->session_close = l2tp_eth_delete;
+	strlcpy(session->ifname, dev->name, IFNAMSIZ);
+
+	spriv = l2tp_session_priv(session);
+	spriv->dev = dev;
+
+	rc = register_netdev(dev);
+	if (rc < 0)
+		goto out_del_dev;
+
+	dev_hold(dev);
+	write_lock(&l2tp_eth_lock);
+	list_add(&priv->list, &l2tp_eth_dev_list);
+	write_unlock(&l2tp_eth_lock);
+
+	return 0;
+
+out_del_dev:
+	free_netdev(dev);
+out_del_session:
+	l2tp_session_delete(session);
+out:
+	return rc;
+}
+
+static const struct l2tp_nl_cmd_ops l2tp_eth_nl_cmd_ops = {
+	.session_create	= l2tp_eth_create,
+	.session_delete	= l2tp_session_delete,
+};
+
+
+static int __init l2tp_eth_init(void)
+{
+	int err = 0;
+
+	err = l2tp_nl_register_ops(L2TP_PWTYPE_ETH, &l2tp_eth_nl_cmd_ops);
+	if (err)
+		goto out;
+
+	printk(KERN_INFO "L2TP ethernet pseudowire support (L2TPv3)\n");
+
+out:
+	return err;
+}
+
+static void __exit l2tp_eth_exit(void)
+{
+	l2tp_nl_unregister_ops(L2TP_PWTYPE_ETH);
+}
+
+module_init(l2tp_eth_init);
+module_exit(l2tp_eth_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
+MODULE_DESCRIPTION("L2TP ethernet pseudowire driver");
Index: net-next-2.6-l2tpv3-2/net/l2tp/Makefile
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/Makefile
+++ net-next-2.6-l2tpv3-2/net/l2tp/Makefile
@@ -8,3 +8,4 @@ obj-$(CONFIG_L2TP) += l2tp_core.o
 obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_PPPOL2TP)) += l2tp_ppp.o
 obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_L2TP_IP)) += l2tp_ip.o
 obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_L2TP_V3)) += l2tp_netlink.o
+obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_L2TP_ETH)) += l2tp_eth.o
Index: net-next-2.6-l2tpv3-2/net/l2tp/Kconfig
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/Kconfig
+++ net-next-2.6-l2tpv3-2/net/l2tp/Kconfig
@@ -69,3 +69,27 @@ config L2TP_IP
 	  To compile this driver as a module, choose M here. The module
 	  will be called l2tp_ip.
 
+config L2TP_ETH
+	tristate "L2TP ethernet pseudowire support for L2TPv3"
+	depends on L2TP_V3
+	help
+	  Support for carrying raw ethernet frames over L2TPv3.
+
+	  From RFC 4719 <http://www.ietf.org/rfc/rfc4719.txt>.
+
+	  The Layer 2 Tunneling Protocol, Version 3 (L2TPv3) can be
+   	  used as a control protocol and for data encapsulation to set
+   	  up Pseudowires for transporting layer 2 Packet Data Units
+   	  across an IP network [RFC3931].
+
+	  This driver provides an ethernet virtual interface for each
+	  L2TP ethernet pseudowire instance. Standard Linux tools may
+	  be used to assign an IP address to the local virtual
+	  interface, or add the interface to a bridge.
+
+	  If you are using L2TPv3, you will almost certainly want to
+	  enable this option.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called l2tp_eth.
+
