From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 02/11] Phonet: PF_PHONET protocol family support
Date: Mon, 22 Sep 2008 18:47:16 +0300
Message-ID: <1222098445-26175-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:52997 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbYIVPrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:41 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlZFT027641
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 18:47:39 +0300
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the basis for the Phonet protocol families, and introduces
the ETH_P_PHONET packet type and the PF_PHONET socket family.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |   74 +++++++++++++++
 net/phonet/af_phonet.c      |  216 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 290 insertions(+), 0 deletions(-)
 create mode 100644 include/net/phonet/phonet.h
 create mode 100644 net/phonet/af_phonet.c

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
new file mode 100644
index 0000000..c53f2ab
--- /dev/null
+++ b/include/net/phonet/phonet.h
@@ -0,0 +1,74 @@
+/*
+ * File: af_phonet.h
+ *
+ * Phonet sockets kernel definitions
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#ifndef AF_PHONET_H
+#define AF_PHONET_H
+
+/*
+ * The lower layers may not require more space, ever. Make sure it's
+ * enough.
+ */
+#define MAX_PHONET_HEADER	8
+
+static inline struct phonethdr *pn_hdr(struct sk_buff *skb)
+{
+	return (struct phonethdr *)skb_network_header(skb);
+}
+
+/*
+ * Get the other party's sockaddr from received skb. The skb begins
+ * with a Phonet header.
+ */
+static inline
+void pn_skb_get_src_sockaddr(struct sk_buff *skb, struct sockaddr_pn *sa)
+{
+	struct phonethdr *ph = pn_hdr(skb);
+	u16 obj = pn_object(ph->pn_sdev, ph->pn_sobj);
+
+	sa->spn_family = AF_PHONET;
+	pn_sockaddr_set_object(sa, obj);
+	pn_sockaddr_set_resource(sa, ph->pn_res);
+	memset(sa->spn_zero, 0, sizeof(sa->spn_zero));
+}
+
+static inline
+void pn_skb_get_dst_sockaddr(struct sk_buff *skb, struct sockaddr_pn *sa)
+{
+	struct phonethdr *ph = pn_hdr(skb);
+	u16 obj = pn_object(ph->pn_rdev, ph->pn_robj);
+
+	sa->spn_family = AF_PHONET;
+	pn_sockaddr_set_object(sa, obj);
+	pn_sockaddr_set_resource(sa, ph->pn_res);
+	memset(sa->spn_zero, 0, sizeof(sa->spn_zero));
+}
+
+/* Protocols in Phonet protocol family. */
+struct phonet_protocol {
+	struct proto		*prot;
+	int			sock_type;
+};
+
+int phonet_proto_register(int protocol, struct phonet_protocol *pp);
+void phonet_proto_unregister(int protocol, struct phonet_protocol *pp);
+
+#endif
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
new file mode 100644
index 0000000..0cfea9b
--- /dev/null
+++ b/net/phonet/af_phonet.c
@@ -0,0 +1,216 @@
+/*
+ * File: af_phonet.c
+ *
+ * Phonet protocols family
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <asm/unaligned.h>
+#include <net/sock.h>
+
+#include <linux/if_phonet.h>
+#include <linux/phonet.h>
+#include <net/phonet/phonet.h>
+
+static struct net_proto_family phonet_proto_family;
+static struct phonet_protocol *phonet_proto_get(int protocol);
+static inline void phonet_proto_put(struct phonet_protocol *pp);
+
+/* protocol family functions */
+
+static int pn_socket_create(struct net *net, struct socket *sock, int protocol)
+{
+	struct phonet_protocol *pnp;
+	int err;
+
+	if (net != &init_net)
+		return -EAFNOSUPPORT;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	if (protocol == 0) {
+		/* Default protocol selection */
+		switch (sock->type) {
+		case SOCK_DGRAM:
+			protocol = PN_PROTO_PHONET;
+			break;
+		default:
+			return -EPROTONOSUPPORT;
+		}
+	}
+
+	pnp = phonet_proto_get(protocol);
+	if (pnp == NULL)
+		return -EPROTONOSUPPORT;
+	if (sock->type != pnp->sock_type) {
+		err = -EPROTONOSUPPORT;
+		goto out;
+	}
+
+	/* TODO: create and init the struct sock */
+	err = -EPROTONOSUPPORT;
+
+out:
+	phonet_proto_put(pnp);
+	return err;
+}
+
+static struct net_proto_family phonet_proto_family = {
+	.family = AF_PHONET,
+	.create = pn_socket_create,
+	.owner = THIS_MODULE,
+};
+
+/* packet type functions */
+
+/*
+ * Stuff received packets to associated sockets.
+ * On error, returns non-zero and releases the skb.
+ */
+static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
+			struct packet_type *pkttype,
+			struct net_device *orig_dev)
+{
+	struct phonethdr *ph;
+	struct sockaddr_pn sa;
+	u16 len;
+
+	if (dev_net(dev) != &init_net)
+		goto out;
+
+	/* check we have at least a full Phonet header */
+	if (!pskb_pull(skb, sizeof(struct phonethdr)))
+		goto out;
+
+	/* check that the advertised length is correct */
+	ph = pn_hdr(skb);
+	len = get_unaligned_be16(&ph->pn_length);
+	if (len < 2)
+		goto out;
+	len -= 2;
+	if ((len > skb->len) || pskb_trim(skb, len))
+		goto out;
+	skb_reset_transport_header(skb);
+
+	pn_skb_get_dst_sockaddr(skb, &sa);
+	if (pn_sockaddr_get_addr(&sa) == 0)
+		goto out; /* currently, we cannot be device 0 */
+
+	/* TODO: put packets to sockets backlog */
+
+out:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+static struct packet_type phonet_packet_type = {
+	.type = __constant_htons(ETH_P_PHONET),
+	.dev = NULL,
+	.func = phonet_rcv,
+};
+
+/* Transport protocol registration */
+static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
+static DEFINE_SPINLOCK(proto_tab_lock);
+
+int __init_or_module phonet_proto_register(int protocol,
+						struct phonet_protocol *pp)
+{
+	int err = 0;
+
+	if (protocol >= PHONET_NPROTO)
+		return -EINVAL;
+
+	err = proto_register(pp->prot, 1);
+	if (err)
+		return err;
+
+	spin_lock(&proto_tab_lock);
+	if (proto_tab[protocol])
+		err = -EBUSY;
+	else
+		proto_tab[protocol] = pp;
+	spin_unlock(&proto_tab_lock);
+
+	return err;
+}
+EXPORT_SYMBOL(phonet_proto_register);
+
+void phonet_proto_unregister(int protocol, struct phonet_protocol *pp)
+{
+	spin_lock(&proto_tab_lock);
+	BUG_ON(proto_tab[protocol] != pp);
+	proto_tab[protocol] = NULL;
+	spin_unlock(&proto_tab_lock);
+	proto_unregister(pp->prot);
+}
+EXPORT_SYMBOL(phonet_proto_unregister);
+
+static struct phonet_protocol *phonet_proto_get(int protocol)
+{
+	struct phonet_protocol *pp;
+
+	if (protocol >= PHONET_NPROTO)
+		return NULL;
+
+	spin_lock(&proto_tab_lock);
+	pp = proto_tab[protocol];
+	if (pp && !try_module_get(pp->prot->owner))
+		pp = NULL;
+	spin_unlock(&proto_tab_lock);
+
+	return pp;
+}
+
+static inline void phonet_proto_put(struct phonet_protocol *pp)
+{
+	module_put(pp->prot->owner);
+}
+
+/* Module registration */
+static int __init phonet_init(void)
+{
+	int err;
+
+	err = sock_register(&phonet_proto_family);
+	if (err) {
+		printk(KERN_ALERT
+			"phonet protocol family initialization failed\n");
+		return err;
+	}
+
+	dev_add_pack(&phonet_packet_type);
+	return 0;
+}
+
+static void __exit phonet_exit(void)
+{
+	sock_unregister(AF_PHONET);
+	dev_remove_pack(&phonet_packet_type);
+}
+
+module_init(phonet_init);
+module_exit(phonet_exit);
+MODULE_DESCRIPTION("Phonet protocol stack for Linux");
+MODULE_LICENSE("GPL");
-- 
1.5.4.3

