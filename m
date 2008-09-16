From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 07/14] Phonet: common socket glue
Date: Tue, 16 Sep 2008 18:08:07 +0300
Message-ID: <1221577694-4513-7-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52818 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbYIPPI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:27 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF8AVs031651
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:24 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides the socket API for the Phonet protocols family.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/phonet.h      |    3 +
 include/net/phonet/phonet.h |   20 +++
 net/phonet/Makefile         |    1 +
 net/phonet/socket.c         |  312 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 336 insertions(+), 0 deletions(-)
 create mode 100644 net/phonet/socket.c

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 000b6d7..4510458 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -32,6 +32,9 @@
 #define PNADDR_ANY		0
 #define PNPORT_RESOURCE_ROUTING	0
 
+/* ioctls */
+#define SIOCPNGETOBJECT		(SIOCPROTOPRIVATE + 0)
+
 /* Phonet protocol header */
 struct phonethdr {
 	uint8_t rdev;
diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index d62883c..e0fa080 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -29,6 +29,25 @@
  */
 #define MAX_PHONET_HEADER	8
 
+/*
+ * Every Phonet* socket has this structure first in its
+ * protocol-specific structure under name c.
+ */
+struct pn_sock {
+	struct sock	sk;
+	u16		sobject;
+	u8		resource;
+};
+
+#define pn_sk(sk) ((struct pn_sock *)(sk))
+
+extern const struct proto_ops phonet_dgram_ops;
+
+struct sock *pn_find_sock_by_sa(const struct sockaddr_pn *sa);
+void pn_sock_hash(struct sock *sk);
+void pn_sock_unhash(struct sock *sk);
+int pn_sock_get_port(struct sock *sk, unsigned short sport);
+
 #define pn_hdr(skb) ((struct phonethdr *)skb_network_header(skb))
 
 /*
@@ -68,5 +87,6 @@ struct phonet_protocol {
 int phonet_proto_register(int protocol, struct phonet_protocol *pp);
 void phonet_proto_unregister(int protocol, struct phonet_protocol *pp);
 
+void phonet_socket_init(void);
 void phonet_netlink_register(void);
 #endif
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
index 4143c3e..c1d671d 100644
--- a/net/phonet/Makefile
+++ b/net/phonet/Makefile
@@ -3,4 +3,5 @@ obj-$(CONFIG_PHONET) += phonet.o
 phonet-objs := \
 	pn_dev.o \
 	pn_netlink.o \
+	socket.o \
 	af_phonet.o
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
new file mode 100644
index 0000000..0e28327
--- /dev/null
+++ b/net/phonet/socket.c
@@ -0,0 +1,312 @@
+/*
+ * File: socket.c
+ *
+ * Phonet sockets
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
+#include <linux/net.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+
+#include <linux/phonet.h>
+#include <net/phonet/phonet.h>
+#include <net/phonet/pn_dev.h>
+
+static int pn_socket_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	if (sk) {
+		sock->sk = NULL;
+		sk->sk_prot->close(sk, 0);
+	}
+	return 0;
+}
+
+static struct  {
+	struct hlist_head hlist;
+	spinlock_t lock;
+} pnsocks;
+
+/*
+ * Find address based on socket address, match only certain fields.
+ * Also grab sock if it was found. Remember to sock_put it later.
+ */
+struct sock *pn_find_sock_by_sa(const struct sockaddr_pn *spn)
+{
+	struct hlist_node *node;
+	struct sock *sknode;
+	struct sock *rval = NULL;
+	uint16_t obj = pn_sockaddr_get_object(spn);
+	uint8_t res = spn->spn_resource;
+
+	spin_lock_bh(&pnsocks.lock);
+
+	sk_for_each(sknode, node, &pnsocks.hlist) {
+		struct pn_sock *pn = pn_sk(sknode);
+		BUG_ON(!pn->sobject); /* unbound socket */
+
+		if (pn_port(obj)) {
+			/* Look up socket by port */
+			if (pn_port(pn->sobject) != pn_port(obj))
+				continue;
+		} else {
+			/* If port is zero, look up by resource */
+			if (pn->resource != res)
+				continue;
+		}
+		if (pn_addr(pn->sobject)
+		 && pn_addr(pn->sobject) != pn_addr(obj))
+			continue;
+
+		rval = sknode;
+		sock_hold(sknode);
+		break;
+	}
+
+	spin_unlock_bh(&pnsocks.lock);
+
+	return rval;
+
+}
+
+void pn_sock_hash(struct sock *sk)
+{
+	spin_lock_bh(&pnsocks.lock);
+	sk_add_node(sk, &pnsocks.hlist);
+	spin_unlock_bh(&pnsocks.lock);
+}
+EXPORT_SYMBOL(pn_sock_hash);
+
+void pn_sock_unhash(struct sock *sk)
+{
+	spin_lock_bh(&pnsocks.lock);
+	sk_del_node_init(sk);
+	spin_unlock_bh(&pnsocks.lock);
+}
+EXPORT_SYMBOL(pn_sock_unhash);
+
+static int pn_socket_bind(struct socket *sock, struct sockaddr *addr, int len)
+{
+	struct sock *sk = sock->sk;
+	struct pn_sock *pn = pn_sk(sk);
+	struct sockaddr_pn *spn = (struct sockaddr_pn *)addr;
+	int err;
+	uint16_t handle;
+	uint8_t saddr;
+
+	if (sk->sk_prot->bind)
+		return sk->sk_prot->bind(sk, addr, len);
+
+	if (len < sizeof(struct sockaddr_pn))
+		return -EINVAL;
+	if (spn->spn_family != AF_PHONET)
+		return -EAFNOSUPPORT;
+
+	handle = pn_sockaddr_get_object((struct sockaddr_pn *)addr);
+	saddr = pn_addr(handle);
+	if (saddr) {
+		struct phonet_address *pna;
+
+		spin_lock_bh(&pndevs.lock);
+		pna = phonet_addr2addr(pn_addr(handle), PN_FIND_EXACT);
+		spin_unlock_bh(&pndevs.lock);
+		if (pna == NULL)
+			return -EADDRNOTAVAIL;
+	}
+
+	lock_sock(sk);
+	if (sk->sk_state != TCP_CLOSE || pn_port(pn->sobject)) {
+		err = -EINVAL; /* attempt to rebind */
+		goto out;
+	}
+	err = sk->sk_prot->get_port(sk, pn_port(handle));
+	if (err)
+		goto out;
+
+	/* get_port() sets the port, bind() sets the address if applicable */
+	pn->sobject = pn_object(saddr, pn_port(pn->sobject));
+	pn->resource = spn->spn_resource;
+
+	/* Enable RX on the socket */
+	sk->sk_prot->hash(sk);
+out:
+	release_sock(sk);
+	return err;
+}
+
+static int pn_socket_autobind(struct socket *sock)
+{
+	struct sockaddr_pn sa;
+	int err;
+
+	memset(&sa, 0, sizeof(sa));
+	sa.spn_family = AF_PHONET;
+	err = pn_socket_bind(sock, (struct sockaddr *)&sa,
+				sizeof(struct sockaddr_pn));
+	if (err != -EINVAL)
+		return err;
+	BUG_ON(!pn_port(pn_sk(sock->sk)->sobject));
+	return 0; /* socket was already bound */
+}
+
+static int pn_socket_getname(struct socket *sock, struct sockaddr *addr,
+				int *sockaddr_len, int peer)
+{
+	struct sock *sk = sock->sk;
+	struct pn_sock *pn = pn_sk(sk);
+
+	memset(addr, 0, sizeof(struct sockaddr_pn));
+	addr->sa_family = AF_PHONET;
+	if (!peer) /* Race with bind() here is userland's problem. */
+		pn_sockaddr_set_object((struct sockaddr_pn *)addr,
+					pn->sobject);
+
+	*sockaddr_len = sizeof(struct sockaddr_pn);
+	return 0;
+}
+
+static int pn_socket_ioctl(struct socket *sock, unsigned int cmd,
+				unsigned long arg)
+{
+	struct sock *sk = sock->sk;
+	struct pn_sock *pn = pn_sk(sk);
+
+	if (cmd == SIOCPNGETOBJECT) {
+		struct phonet_address *pna;
+		uint16_t handle;
+		uint8_t rdev;
+
+		if (get_user(handle, (uint16_t __user *)arg))
+			return -EFAULT;
+
+		rdev = pn_dev(handle);
+		spin_lock_bh(&pndevs.lock);
+		pna = phonet_addr2addr(rdev, 0);
+		if (pna)
+			handle = pn_object(pna->addr, pn_port(pn->sobject));
+		spin_unlock_bh(&pndevs.lock);
+
+		if (!pna)
+			return -EHOSTUNREACH;
+		return put_user(handle, (uint16_t __user *)arg);
+	}
+
+	return sk->sk_prot->ioctl(sk, cmd, arg);
+}
+
+static int pn_socket_sendmsg(struct kiocb *iocb, struct socket *sock,
+				struct msghdr *m, size_t total_len)
+{
+	struct sock *sk = sock->sk;
+
+	if (pn_socket_autobind(sock))
+		return -EAGAIN;
+
+	return sk->sk_prot->sendmsg(iocb, sk, m, total_len);
+}
+
+const struct proto_ops phonet_dgram_ops = {
+	.family		= AF_PHONET,
+	.owner		= THIS_MODULE,
+	.release	= pn_socket_release,
+	.bind		= pn_socket_bind,
+	.connect	= sock_no_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= sock_no_accept,
+	.getname	= pn_socket_getname,
+	.poll		= datagram_poll,
+	.ioctl		= pn_socket_ioctl,
+	.listen		= sock_no_listen,
+	.shutdown	= sock_no_shutdown,
+	.setsockopt	= sock_no_setsockopt,
+	.getsockopt	= sock_no_getsockopt,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = sock_no_setsockopt,
+	.compat_getsockopt = sock_no_getsockopt,
+#endif
+	.sendmsg	= pn_socket_sendmsg,
+	.recvmsg	= sock_common_recvmsg,
+	.mmap		= sock_no_mmap,
+	.sendpage	= sock_no_sendpage,
+};
+
+static DEFINE_MUTEX(port_mutex);
+
+/* allocate port for a socket */
+int pn_sock_get_port(struct sock *sk, unsigned short sport)
+{
+	static int port_cur;
+	struct pn_sock *pn = pn_sk(sk);
+	struct sockaddr_pn try_sa;
+	struct sock *tmpsk;
+
+	memset(&try_sa, 0, sizeof(struct sockaddr_pn));
+	try_sa.spn_family = AF_PHONET;
+
+	mutex_lock(&port_mutex);
+
+	if (!sport) {
+		/* search free port */
+		int port, pmin = 0x40, pmax = 0x7f;
+
+		for (port = pmin; port <= pmax; port++) {
+			port_cur++;
+			if (port_cur < pmin || port_cur > pmax)
+				port_cur = pmin;
+
+			pn_sockaddr_set_port(&try_sa, port_cur);
+			tmpsk = pn_find_sock_by_sa(&try_sa);
+			if (tmpsk == NULL) {
+				sport = port_cur;
+				goto found;
+			} else
+				sock_put(tmpsk);
+		}
+	} else {
+		/* try to find specific port */
+		pn_sockaddr_set_port(&try_sa, sport);
+		tmpsk = pn_find_sock_by_sa(&try_sa);
+		if (tmpsk == NULL)
+			/* No sock there! We can use that port... */
+			goto found;
+		else
+			sock_put(tmpsk);
+	}
+	mutex_unlock(&port_mutex);
+
+	/* the port must be in use already */
+	return -EADDRINUSE;
+
+found:
+	mutex_unlock(&port_mutex);
+	pn->sobject = pn_object(pn_addr(pn->sobject), sport);
+	return 0;
+}
+EXPORT_SYMBOL(pn_sock_get_port);
+
+void __init phonet_socket_init(void)
+{
+	INIT_HLIST_HEAD(&pnsocks.hlist);
+	spin_lock_init(&pnsocks.lock);
+}
-- 
1.5.4.3

