From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 07/11] Phonet: Phonet datagram transport protocol
Date: Mon, 22 Sep 2008 18:47:21 +0300
Message-ID: <1222098445-26175-7-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:53017 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbYIVPrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:51 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlZFl027641
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 18:47:48 +0300
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides the basic SOCK_DGRAM transport protocol for Phonet.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    6 ++
 net/phonet/Makefile         |    1 +
 net/phonet/af_phonet.c      |  106 +++++++++++++++++++++++
 net/phonet/datagram.c       |  197 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 310 insertions(+), 0 deletions(-)
 create mode 100644 net/phonet/datagram.c

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 2ae5cbb..d3957d3 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -51,6 +51,9 @@ void pn_sock_hash(struct sock *sk);
 void pn_sock_unhash(struct sock *sk);
 int pn_sock_get_port(struct sock *sk, unsigned short sport);
 
+int pn_skb_send(struct sock *sk, struct sk_buff *skb,
+		const struct sockaddr_pn *target);
+
 static inline struct phonethdr *pn_hdr(struct sk_buff *skb)
 {
 	return (struct phonethdr *)skb_network_header(skb);
@@ -95,4 +98,7 @@ int phonet_proto_register(int protocol, struct phonet_protocol *pp);
 void phonet_proto_unregister(int protocol, struct phonet_protocol *pp);
 
 void phonet_netlink_register(void);
+int isi_register(void);
+void isi_unregister(void);
+
 #endif
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
index c1d671d..d218abc 100644
--- a/net/phonet/Makefile
+++ b/net/phonet/Makefile
@@ -4,4 +4,5 @@ phonet-objs := \
 	pn_dev.o \
 	pn_netlink.o \
 	socket.o \
+	datagram.o \
 	af_phonet.o
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index ba54d53..e6771d3 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -99,6 +99,101 @@ static struct net_proto_family phonet_proto_family = {
 	.owner = THIS_MODULE,
 };
 
+/*
+ * Prepends an ISI header and sends a datagram.
+ */
+static int pn_send(struct sk_buff *skb, struct net_device *dev,
+			u16 dst, u16 src, u8 res)
+{
+	struct phonethdr *ph;
+	int err;
+
+	if (skb->len + 2 > 0xffff) {
+		/* Phonet length field would overflow */
+		err = -EMSGSIZE;
+		goto drop;
+	}
+
+	skb_reset_transport_header(skb);
+	WARN_ON(skb_headroom(skb) & 1); /* HW assumes word alignment */
+	skb_push(skb, sizeof(struct phonethdr));
+	skb_reset_network_header(skb);
+	ph = pn_hdr(skb);
+	ph->pn_rdev = pn_dev(dst);
+	ph->pn_sdev = pn_dev(src);
+	ph->pn_res = res;
+	ph->pn_length = __cpu_to_be16(skb->len + 2 - sizeof(*ph));
+	ph->pn_robj = pn_obj(dst);
+	ph->pn_sobj = pn_obj(src);
+
+	skb->protocol = htons(ETH_P_PHONET);
+	skb->priority = 0;
+	skb->dev = dev;
+
+	if (pn_addr(src) == pn_addr(dst)) {
+		skb_reset_mac_header(skb);
+		skb->pkt_type = PACKET_LOOPBACK;
+		skb_orphan(skb);
+		netif_rx_ni(skb);
+		err = 0;
+	} else {
+		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+					NULL, NULL, skb->len);
+		if (err < 0) {
+			err = -EHOSTUNREACH;
+			goto drop;
+		}
+		err = dev_queue_xmit(skb);
+	}
+
+	return err;
+drop:
+	kfree_skb(skb);
+	return err;
+}
+
+/*
+ * Create a Phonet header for the skb and send it out. Returns
+ * non-zero error code if failed. The skb is freed then.
+ */
+int pn_skb_send(struct sock *sk, struct sk_buff *skb,
+		const struct sockaddr_pn *target)
+{
+	struct net_device *dev;
+	struct pn_sock *pn = pn_sk(sk);
+	int err;
+	u16 src;
+	u8 daddr = pn_sockaddr_get_addr(target), saddr = PN_NO_ADDR;
+
+	err = -EHOSTUNREACH;
+	if (sk->sk_bound_dev_if)
+		dev = dev_get_by_index(sock_net(sk), sk->sk_bound_dev_if);
+	else
+		dev = phonet_device_get(sock_net(sk));
+	if (!dev || !(dev->flags & IFF_UP))
+		goto drop;
+
+	saddr = phonet_address_get(dev, daddr);
+	if (saddr == PN_NO_ADDR)
+		goto drop;
+
+	src = pn->sobject;
+	if (!pn_addr(src))
+		src = pn_object(saddr, pn_obj(src));
+
+	err = pn_send(skb, dev, pn_sockaddr_get_object(target),
+			src, pn_sockaddr_get_resource(target));
+	dev_put(dev);
+	return err;
+
+drop:
+	kfree_skb(skb);
+	if (dev)
+		dev_put(dev);
+	return err;
+}
+EXPORT_SYMBOL(pn_skb_send);
+
 /* packet type functions */
 
 /*
@@ -226,11 +321,22 @@ static int __init phonet_init(void)
 	phonet_device_init();
 	dev_add_pack(&phonet_packet_type);
 	phonet_netlink_register();
+
+	err = isi_register();
+	if (err)
+		goto err;
 	return 0;
+
+err:
+	sock_unregister(AF_PHONET);
+	dev_remove_pack(&phonet_packet_type);
+	phonet_device_exit();
+	return err;
 }
 
 static void __exit phonet_exit(void)
 {
+	isi_unregister();
 	sock_unregister(AF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
 	phonet_device_exit();
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
new file mode 100644
index 0000000..e087862
--- /dev/null
+++ b/net/phonet/datagram.c
@@ -0,0 +1,197 @@
+/*
+ * File: datagram.c
+ *
+ * Datagram (ISI) Phonet sockets
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
+#include <linux/socket.h>
+#include <asm/ioctls.h>
+#include <net/sock.h>
+
+#include <linux/phonet.h>
+#include <net/phonet/phonet.h>
+
+static int pn_backlog_rcv(struct sock *sk, struct sk_buff *skb);
+
+/* associated socket ceases to exist */
+static void pn_sock_close(struct sock *sk, long timeout)
+{
+	sk_common_release(sk);
+}
+
+static int pn_ioctl(struct sock *sk, int cmd, unsigned long arg)
+{
+	struct sk_buff *skb;
+	int answ;
+
+	switch (cmd) {
+	case SIOCINQ:
+		lock_sock(sk);
+		skb = skb_peek(&sk->sk_receive_queue);
+		answ = skb ? skb->len : 0;
+		release_sock(sk);
+		return put_user(answ, (int __user *)arg);
+	}
+
+	return -ENOIOCTLCMD;
+}
+
+/* Destroy socket. All references are gone. */
+static void pn_destruct(struct sock *sk)
+{
+	skb_queue_purge(&sk->sk_receive_queue);
+}
+
+static int pn_init(struct sock *sk)
+{
+	sk->sk_destruct = pn_destruct;
+	return 0;
+}
+
+static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t len)
+{
+	struct sockaddr_pn *target;
+	struct sk_buff *skb;
+	int err;
+
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	if (msg->msg_name == NULL)
+		return -EDESTADDRREQ;
+
+	if (msg->msg_namelen < sizeof(struct sockaddr_pn))
+		return -EINVAL;
+
+	target = (struct sockaddr_pn *)msg->msg_name;
+	if (target->spn_family != AF_PHONET)
+		return -EAFNOSUPPORT;
+
+	skb = sock_alloc_send_skb(sk, MAX_PHONET_HEADER + len,
+					msg->msg_flags & MSG_DONTWAIT, &err);
+	if (skb == NULL)
+		return err;
+	skb_reserve(skb, MAX_PHONET_HEADER);
+
+	err = memcpy_fromiovec((void *)skb_put(skb, len), msg->msg_iov, len);
+	if (err < 0) {
+		kfree_skb(skb);
+		return err;
+	}
+
+	/*
+	 * Fill in the Phonet header and
+	 * finally pass the packet forwards.
+	 */
+	err = pn_skb_send(sk, skb, target);
+
+	/* If ok, return len. */
+	return (err >= 0) ? len : err;
+}
+
+static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t len, int noblock,
+			int flags, int *addr_len)
+{
+	struct sk_buff *skb = NULL;
+	struct sockaddr_pn sa;
+	int rval = -EOPNOTSUPP;
+	int copylen;
+
+	if (flags & MSG_OOB)
+		goto out_nofree;
+
+	if (addr_len)
+		*addr_len = sizeof(sa);
+
+	skb = skb_recv_datagram(sk, flags, noblock, &rval);
+	if (skb == NULL)
+		goto out_nofree;
+
+	pn_skb_get_src_sockaddr(skb, &sa);
+
+	copylen = skb->len;
+	if (len < copylen) {
+		msg->msg_flags |= MSG_TRUNC;
+		copylen = len;
+	}
+
+	rval = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copylen);
+	if (rval) {
+		rval = -EFAULT;
+		goto out;
+	}
+
+	rval = (flags & MSG_TRUNC) ? skb->len : copylen;
+
+	if (msg->msg_name != NULL)
+		memcpy(msg->msg_name, &sa, sizeof(struct sockaddr_pn));
+
+out:
+	skb_free_datagram(sk, skb);
+
+out_nofree:
+	return rval;
+}
+
+/* Queue an skb for a sock. */
+static int pn_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	int err = sock_queue_rcv_skb(sk, skb);
+	if (err < 0)
+		kfree_skb(skb);
+	return err ? NET_RX_DROP : NET_RX_SUCCESS;
+}
+
+/* Module registration */
+static struct proto pn_proto = {
+	.close		= pn_sock_close,
+	.ioctl		= pn_ioctl,
+	.init		= pn_init,
+	.sendmsg	= pn_sendmsg,
+	.recvmsg	= pn_recvmsg,
+	.backlog_rcv	= pn_backlog_rcv,
+	.hash		= pn_sock_hash,
+	.unhash		= pn_sock_unhash,
+	.get_port	= pn_sock_get_port,
+	.obj_size	= sizeof(struct pn_sock),
+	.owner		= THIS_MODULE,
+	.name		= "PHONET",
+};
+
+static struct phonet_protocol pn_dgram_proto = {
+	.ops		= &phonet_dgram_ops,
+	.prot		= &pn_proto,
+	.sock_type	= SOCK_DGRAM,
+};
+
+int __init isi_register(void)
+{
+	return phonet_proto_register(PN_PROTO_PHONET, &pn_dgram_proto);
+}
+
+void __exit isi_unregister(void)
+{
+	phonet_proto_unregister(PN_PROTO_PHONET, &pn_dgram_proto);
+}
-- 
1.5.4.3

