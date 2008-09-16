From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 10/14] Phonet: Phonet datagram transport protocol
Date: Tue, 16 Sep 2008 18:08:10 +0300
Message-ID: <1221577694-4513-10-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52828 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbYIPPI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:29 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF88JL031631
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:27 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides the basic SOCK_DGRAM transport protocol for Phonet.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    6 ++
 net/phonet/Makefile         |    1 +
 net/phonet/af_phonet.c      |  108 +++++++++++++++++++++++
 net/phonet/datagram.c       |  198 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 313 insertions(+), 0 deletions(-)
 create mode 100644 net/phonet/datagram.c

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 1131833..ead764d 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -49,6 +49,9 @@ void pn_sock_hash(struct sock *sk);
 void pn_sock_unhash(struct sock *sk);
 int pn_sock_get_port(struct sock *sk, unsigned short sport);
 
+int pn_skb_send(struct sock *sk, struct sk_buff *skb,
+		const struct sockaddr_pn *target);
+
 #define pn_hdr(skb) ((struct phonethdr *)skb_network_header(skb))
 
 /*
@@ -91,4 +94,7 @@ void phonet_proto_unregister(int protocol, struct phonet_protocol *pp);
 
 void phonet_socket_init(void);
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
index 1628e7c..ec99413 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -101,6 +101,107 @@ static struct net_proto_family phonet_proto_family = {
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
+	if (skb->len > 0xfffd) {
+		err = -EMSGSIZE;
+		goto drop;
+	}
+
+	skb_reset_transport_header(skb);
+	WARN_ON(skb_headroom(skb) & 1); /* HW assumes word alignment */
+	ph = (struct phonethdr *)skb_push(skb, sizeof(struct phonethdr));
+	skb_reset_network_header(skb);
+	ph->rdev = pn_dev(dst);
+	ph->sdev = pn_dev(src);
+	ph->function = res;
+	ph->length = __cpu_to_be16(skb->len + 2 - sizeof(*ph));
+	ph->robj = pn_obj(dst);
+	ph->sobj = pn_obj(src);
+
+	skb->protocol = __constant_htons(ETH_P_PHONET);
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
+	struct phonet_address *pna = NULL;
+	struct pn_sock *pn = pn_sk(sk);
+	int err;
+	uint16_t src;
+	uint8_t addr = pn_sockaddr_get_addr(target);
+
+	spin_lock_bh(&pndevs.lock);
+	if (sk->sk_bound_dev_if) {
+		struct phonet_device *pnd;
+
+		pnd = __phonet_get_by_index(sk->sk_bound_dev_if);
+		if (pnd && (pnd->netdev->flags & IFF_UP))
+			pna = phonet_dev2addr(pnd, addr, 0);
+	} else {
+		pna = phonet_addr2addr(pn_sockaddr_get_addr(target), 0);
+	}
+
+	if (pna == NULL) {
+		spin_unlock_bh(&pndevs.lock);
+		err = -EHOSTUNREACH;
+		goto drop;
+	}
+
+	src = pn->sobject;
+	if (!pn_addr(src))
+		src = pn_object(pna->addr, pn_obj(src));
+
+	dev = pna->pnd->netdev;
+	dev_hold(dev);
+	spin_unlock_bh(&pndevs.lock);
+
+	err = pn_send(skb, dev, pn_sockaddr_get_object(target),
+			src, pn_sockaddr_get_resource(target));
+	dev_put(dev);
+	return err;
+
+drop:
+	kfree_skb(skb);
+	return err;
+}
+EXPORT_SYMBOL(pn_skb_send);
+
 /* packet type functions */
 
 /*
@@ -238,8 +339,14 @@ static int __init phonet_init(void)
 
 	dev_add_pack(&phonet_packet_type);
 	phonet_netlink_register();
+
+	err = isi_register();
+	if (err)
+		goto err2;
 	return 0;
 
+err2:
+	phonet_device_exit();
 unregister:
 	sock_unregister(AF_PHONET);
 	return err;
@@ -247,6 +354,7 @@ unregister:
 
 static void __exit phonet_exit(void)
 {
+	isi_unregister();
 	sock_unregister(AF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
 	phonet_device_exit();
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
new file mode 100644
index 0000000..5d8e701
--- /dev/null
+++ b/net/phonet/datagram.c
@@ -0,0 +1,198 @@
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
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		answ = skb ? skb->len : 0;
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
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
+	pn_sk(sk)->handler = pn_backlog_rcv;
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
+	return err;
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

