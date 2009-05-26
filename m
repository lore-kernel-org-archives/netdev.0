From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 3/5] ieee802154: add socket address family code
Date: Tue, 26 May 2009 15:23:06 +0400
Message-ID: <1243336988-20109-3-git-send-email-dbaryshkov@gmail.com>
References: <20090526112157.GA19976@doriath.ww600.siemens.net>
 <1243336988-20109-1-git-send-email-dbaryshkov@gmail.com>
 <1243336988-20109-2-git-send-email-dbaryshkov@gmail.com>
Cc: slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:37399 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbZEZLXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 07:23:32 -0400
In-Reply-To: <1243336988-20109-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for BSD sockets over the IEEE 802.15.4 networks.
One can either send RAW datagrams or use SOCK_DGRAM to encapsulate data
inside normal IEEE 802.15.4 packets.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Signed-off-by: Sergey Lapin <slapin@ossfans.org>
---
 net/ieee802154/Makefile        |    3 +-
 net/ieee802154/af_ieee802154.c |  312 +++++++++++++++++++++++++++++++++
 net/ieee802154/dgram.c         |  372 ++++++++++++++++++++++++++++++++++++++++
 net/ieee802154/raw.c           |  249 +++++++++++++++++++++++++++
 4 files changed, 935 insertions(+), 1 deletions(-)
 create mode 100644 net/ieee802154/af_ieee802154.c
 create mode 100644 net/ieee802154/dgram.c
 create mode 100644 net/ieee802154/raw.c

diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index d964365..aace5b1 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,5 +1,6 @@
-obj-$(CONFIG_IEEE802154) +=	ieee802154.o
+obj-$(CONFIG_IEEE802154) +=	ieee802154.o af_802154.o
 ieee802154-objs		:= main.o mdev.o dev.o netlink.o mac_cmd.o scan.o \
 			crc.o beacon.o beacon_hash.o start.o
+af_802154-objs		:= af_ieee802154.o raw.o dgram.o
 
 EXTRA_CFLAGS += -Wall -DDEBUG
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
new file mode 100644
index 0000000..58e0a07
--- /dev/null
+++ b/net/ieee802154/af_ieee802154.c
@@ -0,0 +1,312 @@
+/*
+ * IEEE802154.4 socket interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ */
+
+#include <linux/net.h>
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/if.h>
+#include <linux/termios.h>	/* For TIOCOUTQ/INQ */
+#include <linux/list.h>
+#include <net/datalink.h>
+#include <net/psnap.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <net/route.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/phy.h>
+
+#define DBG_DUMP(data, len) { \
+	int i; \
+	pr_debug("file %s: function: %s: data: len %d:\n", __FILE__, __func__, len); \
+	for (i = 0; i < len; i++) {\
+		pr_debug("%02x: %02x\n", i, (data)[i]); \
+	} \
+}
+
+static int ieee802154_sock_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	if (sk) {
+		sock->sk = NULL;
+		sk->sk_prot->close(sk, 0);
+	}
+	return 0;
+}
+static int ieee802154_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+
+	return sk->sk_prot->sendmsg(iocb, sk, msg, len);
+}
+
+static int ieee802154_sock_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
+{
+	struct sock *sk = sock->sk;
+
+	if (sk->sk_prot->bind)
+		return sk->sk_prot->bind(sk, uaddr, addr_len);
+
+	return sock_no_bind(sock, uaddr, addr_len);
+}
+
+static int ieee802154_sock_connect(struct socket *sock, struct sockaddr *uaddr,
+			int addr_len, int flags)
+{
+	struct sock *sk = sock->sk;
+
+	if (uaddr->sa_family == AF_UNSPEC)
+		return sk->sk_prot->disconnect(sk, flags);
+
+	return sk->sk_prot->connect(sk, uaddr, addr_len);
+}
+
+static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg, unsigned int cmd)
+{
+	struct ifreq ifr;
+	int ret = -EINVAL;
+	struct net_device *dev;
+
+	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
+		return -EFAULT;
+
+	ifr.ifr_name[IFNAMSIZ-1] = 0;
+
+	dev_load(sock_net(sk), ifr.ifr_name);
+	dev = dev_get_by_name(sock_net(sk), ifr.ifr_name);
+	if (dev->type == ARPHRD_IEEE802154 || dev->type == ARPHRD_IEEE802154_PHY)
+		ret = dev->netdev_ops->ndo_do_ioctl(dev, &ifr, cmd);
+
+	if (!ret && copy_to_user(arg, &ifr, sizeof(struct ifreq)))
+		ret = -EFAULT;
+	dev_put(dev);
+
+	return ret;
+}
+
+static int ieee802154_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct sock *sk = sock->sk;
+
+	switch (cmd) {
+	case SIOCGSTAMP:
+		return sock_get_timestamp(sk, (struct timeval __user *)arg);
+	case SIOCGSTAMPNS:
+		return sock_get_timestampns(sk, (struct timespec __user *)arg);
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+		return ieee802154_dev_ioctl(sk, (struct ifreq __user *)arg, cmd);
+	default:
+		if (!sk->sk_prot->ioctl)
+			return -ENOIOCTLCMD;
+		return sk->sk_prot->ioctl(sk, cmd, arg);
+	}
+}
+
+static const struct proto_ops ieee802154_raw_ops = {
+	.family		   = PF_IEEE802154,
+	.owner		   = THIS_MODULE,
+	.release	   = ieee802154_sock_release,
+	.bind		   = ieee802154_sock_bind,
+	.connect	   = ieee802154_sock_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = sock_no_accept,
+	.getname	   = sock_no_getname,
+	.poll		   = datagram_poll,
+	.ioctl		   = ieee802154_sock_ioctl,
+	.listen		   = sock_no_listen,
+	.shutdown	   = sock_no_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = ieee802154_sock_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
+#endif
+};
+
+static const struct proto_ops ieee802154_dgram_ops = {
+	.family		   = PF_IEEE802154,
+	.owner		   = THIS_MODULE,
+	.release	   = ieee802154_sock_release,
+	.bind		   = ieee802154_sock_bind,
+	.connect	   = ieee802154_sock_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = sock_no_accept,
+	.getname	   = sock_no_getname,
+	.poll		   = datagram_poll,
+	.ioctl		   = ieee802154_sock_ioctl,
+	.listen		   = sock_no_listen,
+	.shutdown	   = sock_no_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = ieee802154_sock_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
+#endif
+};
+
+
+/*
+ * Create a socket. Initialise the socket, blank the addresses
+ * set the state.
+ */
+static int ieee802154_create(struct net *net, struct socket *sock, int protocol)
+{
+	struct sock *sk;
+	int rc;
+	struct proto *proto;
+	const struct proto_ops *ops;
+
+	/* FIXME: init_net */
+	if (net != &init_net)
+		return -EAFNOSUPPORT;
+
+	switch (sock->type) {
+	case SOCK_RAW:
+		proto = &ieee802154_raw_prot;
+		ops = &ieee802154_raw_ops;
+		break;
+	case SOCK_DGRAM:
+		proto = &ieee802154_dgram_prot;
+		ops = &ieee802154_dgram_ops;
+		break;
+	default:
+		rc = -ESOCKTNOSUPPORT;
+		goto out;
+	}
+
+	rc = -ENOMEM;
+	sk = sk_alloc(net, PF_IEEE802154, GFP_KERNEL, proto);
+	if (!sk)
+		goto out;
+	rc = 0;
+
+	sock->ops = ops;
+
+	sock_init_data(sock, sk);
+	/* FIXME: sk->sk_destruct */
+	sk->sk_family = PF_IEEE802154;
+
+	/* Checksums on by default */
+	sock_set_flag(sk, SOCK_ZAPPED);
+
+	if (sk->sk_prot->hash)
+		sk->sk_prot->hash(sk);
+
+	if (sk->sk_prot->init) {
+		rc = sk->sk_prot->init(sk);
+		if (rc)
+			sk_common_release(sk);
+	}
+out:
+	return rc;
+}
+
+static struct net_proto_family ieee802154_family_ops = {
+	.family		= PF_IEEE802154,
+	.create		= ieee802154_create,
+	.owner		= THIS_MODULE,
+};
+
+static int ieee802154_rcv(struct sk_buff *skb, struct net_device *dev,
+	struct packet_type *pt, struct net_device *orig_dev)
+{
+	DBG_DUMP(skb->data, skb->len);
+	if (!netif_running(dev))
+		return -ENODEV;
+	pr_debug("got frame, type %d, dev %p\n", dev->type, dev);
+	/* FIXME: init_net */
+	if (!net_eq(dev_net(dev), &init_net))
+		goto drop;
+
+	ieee802154_raw_deliver(dev, skb);
+
+	if (dev->type != ARPHRD_IEEE802154)
+		goto drop;
+
+	if (skb->pkt_type != PACKET_OTHERHOST)
+		return ieee802154_dgram_deliver(dev, skb);
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+
+static struct packet_type ieee802154_packet_type = {
+	.type = __constant_htons(ETH_P_IEEE802154),
+	.func = ieee802154_rcv,
+};
+
+static int __init af_ieee802154_init(void)
+{
+	int rc = -EINVAL;
+
+	rc = proto_register(&ieee802154_raw_prot, 1);
+	if (rc)
+		goto out;
+
+	rc = proto_register(&ieee802154_dgram_prot, 1);
+	if (rc)
+		goto err_dgram;
+
+	/* Tell SOCKET that we are alive */
+	rc = sock_register(&ieee802154_family_ops);
+	if (rc)
+		goto err_sock;
+	dev_add_pack(&ieee802154_packet_type);
+
+	rc = 0;
+	goto out;
+
+err_sock:
+	proto_unregister(&ieee802154_dgram_prot);
+err_dgram:
+	proto_unregister(&ieee802154_raw_prot);
+out:
+	return rc;
+}
+static void af_ieee802154_remove(void)
+{
+	dev_remove_pack(&ieee802154_packet_type);
+	sock_unregister(PF_IEEE802154);
+	proto_unregister(&ieee802154_dgram_prot);
+	proto_unregister(&ieee802154_raw_prot);
+}
+
+module_init(af_ieee802154_init);
+module_exit(af_ieee802154_remove);
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_IEEE802154);
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
new file mode 100644
index 0000000..a4d6571
--- /dev/null
+++ b/net/ieee802154/dgram.c
@@ -0,0 +1,372 @@
+/*
+ * ZigBee socket interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/net.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/list.h>
+#include <net/sock.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <asm/ioctls.h>
+
+static HLIST_HEAD(dgram_head);
+static DEFINE_RWLOCK(dgram_lock);
+
+struct dgram_sock {
+	struct sock sk;
+
+	int bound;
+	struct ieee802154_addr src_addr;
+	struct ieee802154_addr dst_addr;
+};
+
+static inline struct dgram_sock *dgram_sk(const struct sock *sk)
+{
+	return (struct dgram_sock *)sk;
+}
+
+
+static void dgram_hash(struct sock *sk)
+{
+	write_lock_bh(&dgram_lock);
+	sk_add_node(sk, &dgram_head);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	write_unlock_bh(&dgram_lock);
+}
+
+static void dgram_unhash(struct sock *sk)
+{
+	write_lock_bh(&dgram_lock);
+	if (sk_del_node_init(sk))
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	write_unlock_bh(&dgram_lock);
+}
+
+static int dgram_init(struct sock *sk)
+{
+	struct dgram_sock *ro = dgram_sk(sk);
+
+	ro->dst_addr.addr_type = IEEE802154_ADDR_LONG;
+	ro->dst_addr.pan_id = 0xffff;
+	memset(&ro->dst_addr.hwaddr, 0xff, sizeof(ro->dst_addr.hwaddr));
+	return 0;
+}
+
+static void dgram_close(struct sock *sk, long timeout)
+{
+	sk_common_release(sk);
+}
+
+static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
+{
+	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	struct dgram_sock *ro = dgram_sk(sk);
+	int err = 0;
+	struct net_device *dev;
+
+	ro->bound = 0;
+
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
+	if (addr->family != AF_IEEE802154)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	dev = ieee802154_get_dev(sock_net(sk), &addr->addr);
+	if (!dev) {
+		err = -ENODEV;
+		goto out;
+	}
+
+	if (dev->type != ARPHRD_IEEE802154) {
+		err = -ENODEV;
+		goto out_put;
+	}
+
+	memcpy(&ro->src_addr, &addr->addr, sizeof(struct ieee802154_addr));
+
+	ro->bound = 1;
+out_put:
+	dev_put(dev);
+out:
+	release_sock(sk);
+
+	return err;
+}
+
+static int dgram_ioctl(struct sock *sk, int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCOUTQ:
+	{
+		int amount = atomic_read(&sk->sk_wmem_alloc);
+		return put_user(amount, (int __user *)arg);
+	}
+
+	case SIOCINQ:
+	{
+		struct sk_buff *skb;
+		unsigned long amount;
+
+		amount = 0;
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb != NULL) {
+			/*
+			 * We will only return the amount
+			 * of this packet since that is all
+			 * that will be read.
+			 */
+			/* FIXME: parse the header for more correct value */
+			amount = skb->len - (3+8+8);
+		}
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		return put_user(amount, (int __user *)arg);
+	}
+
+	}
+	return -ENOIOCTLCMD;
+}
+
+/* FIXME: autobind */
+static int dgram_connect(struct sock *sk, struct sockaddr *uaddr,
+			int len)
+{
+	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	struct dgram_sock *ro = dgram_sk(sk);
+	int err = 0;
+
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
+	if (addr->family != AF_IEEE802154)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	if (!ro->bound) {
+		err = -ENETUNREACH;
+		goto out;
+	}
+
+	memcpy(&ro->dst_addr, &addr->addr, sizeof(struct ieee802154_addr));
+
+out:
+	release_sock(sk);
+	return err;
+}
+
+static int dgram_disconnect(struct sock *sk, int flags)
+{
+	struct dgram_sock *ro = dgram_sk(sk);
+
+	lock_sock(sk);
+
+	ro->dst_addr.addr_type = IEEE802154_ADDR_LONG;
+	memset(&ro->dst_addr.hwaddr, 0xff, sizeof(ro->dst_addr.hwaddr));
+
+	release_sock(sk);
+
+	return 0;
+}
+
+static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t size)
+{
+	struct net_device *dev;
+	unsigned mtu;
+	struct sk_buff *skb;
+	struct dgram_sock *ro = dgram_sk(sk);
+	int err;
+	struct ieee802154_priv *hw;
+
+	if (msg->msg_flags & MSG_OOB) {
+		pr_debug("msg->msg_flags = 0x%x\n", msg->msg_flags);
+		return -EOPNOTSUPP;
+	}
+
+	if (!ro->bound)
+		dev = dev_getfirstbyhwtype(sock_net(sk), ARPHRD_IEEE802154);
+	else
+		dev = ieee802154_get_dev(sock_net(sk), &ro->src_addr);
+
+	if (!dev) {
+		pr_debug("no dev\n");
+		return -ENXIO;
+	}
+	hw = ieee802154_slave_get_hw(dev);
+	mtu = dev->mtu;
+	pr_debug("name = %s, mtu = %u\n", dev->name, mtu);
+
+	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + size, msg->msg_flags & MSG_DONTWAIT,
+				  &err);
+	if (!skb) {
+		dev_put(dev);
+		return err;
+	}
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_network_header(skb);
+
+	MAC_CB(skb)->flags = IEEE802154_FC_TYPE_DATA | MAC_CB_FLAG_ACKREQ;
+	MAC_CB(skb)->seq = hw->dsn;
+	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &ro->dst_addr, ro->bound ? &ro->src_addr : NULL, size);
+	if (err < 0) {
+		kfree_skb(skb);
+		dev_put(dev);
+		return err;
+	}
+
+	skb_reset_mac_header(skb);
+
+	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	if (err < 0) {
+		kfree_skb(skb);
+		dev_put(dev);
+		return err;
+	}
+
+	if (size > mtu) {
+		pr_debug("size = %u, mtu = %u\n", size, mtu);
+		return -EINVAL;
+	}
+
+	skb->dev = dev;
+	skb->sk  = sk;
+	skb->protocol = htons(ETH_P_IEEE802154);
+
+	err = dev_queue_xmit(skb);
+	hw->dsn++;
+
+	dev_put(dev);
+
+	if (err)
+		return err;
+
+	return size;
+}
+
+static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t len, int noblock, int flags, int *addr_len)
+{
+	size_t copied = 0;
+	int err = -EOPNOTSUPP;
+	struct sk_buff *skb;
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		goto out;
+
+	copied = skb->len;
+	if (len < copied) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+
+	/* FIXME: skip headers if necessary ?! */
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto done;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
+done:
+	skb_free_datagram(sk, skb);
+out:
+	if (err)
+		return err;
+	return copied;
+}
+
+static int dgram_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
+		atomic_inc(&sk->sk_drops);
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
+{
+	struct sock *sk, *prev = NULL;
+	struct hlist_node *node;
+	int ret = NET_RX_SUCCESS;
+
+	/* Data frame processing */
+
+	read_lock(&dgram_lock);
+	sk_for_each(sk, node, &dgram_head) {
+		struct dgram_sock *ro = dgram_sk(sk);
+		if (!ro->bound ||
+		  (ro->src_addr.addr_type == IEEE802154_ADDR_LONG &&
+		     !memcmp(ro->src_addr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN)) ||
+		  (ro->src_addr.addr_type == IEEE802154_ADDR_SHORT &&
+		     ieee802154_dev_get_pan_id(dev) == ro->src_addr.pan_id &&
+		     ieee802154_dev_get_short_addr(dev) == ro->src_addr.short_addr)) {
+			if (prev) {
+				struct sk_buff *clone;
+				clone = skb_clone(skb, GFP_ATOMIC);
+				if (clone)
+					dgram_rcv_skb(prev, clone);
+			}
+
+			prev = sk;
+		}
+	}
+
+	if (prev)
+		dgram_rcv_skb(prev, skb);
+	else {
+		kfree_skb(skb);
+		ret = NET_RX_DROP;
+	}
+	read_unlock(&dgram_lock);
+
+	return ret;
+}
+
+struct proto ieee802154_dgram_prot = {
+	.name		= "IEEE-802.15.4-MAC",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct dgram_sock),
+	.init		= dgram_init,
+	.close		= dgram_close,
+	.bind		= dgram_bind,
+	.sendmsg	= dgram_sendmsg,
+	.recvmsg	= dgram_recvmsg,
+	.hash		= dgram_hash,
+	.unhash		= dgram_unhash,
+	.connect	= dgram_connect,
+	.disconnect	= dgram_disconnect,
+	.ioctl		= dgram_ioctl,
+};
+
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
new file mode 100644
index 0000000..4fe6f37
--- /dev/null
+++ b/net/ieee802154/raw.c
@@ -0,0 +1,249 @@
+/*
+ * Raw IEEE 802.15.4 sockets
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/net.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/list.h>
+#include <net/sock.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/af_ieee802154.h>
+
+static HLIST_HEAD(raw_head);
+static DEFINE_RWLOCK(raw_lock);
+
+static void raw_hash(struct sock *sk)
+{
+	write_lock_bh(&raw_lock);
+	sk_add_node(sk, &raw_head);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	write_unlock_bh(&raw_lock);
+}
+
+static void raw_unhash(struct sock *sk)
+{
+	write_lock_bh(&raw_lock);
+	if (sk_del_node_init(sk))
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	write_unlock_bh(&raw_lock);
+}
+
+static void raw_close(struct sock *sk, long timeout)
+{
+	sk_common_release(sk);
+}
+
+static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int len)
+{
+	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	int err = 0;
+	struct net_device *dev = NULL;
+
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
+	if (addr->family != AF_IEEE802154)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	dev = ieee802154_get_dev(sock_net(sk), &addr->addr);
+	if (!dev) {
+		err = -ENODEV;
+		goto out;
+	}
+
+	if (dev->type != ARPHRD_IEEE802154_PHY && dev->type != ARPHRD_IEEE802154) {
+		err = -ENODEV;
+		goto out_put;
+	}
+
+	sk->sk_bound_dev_if = dev->ifindex;
+	sk_dst_reset(sk);
+
+out_put:
+	dev_put(dev);
+out:
+	release_sock(sk);
+
+	return err;
+}
+
+static int raw_connect(struct sock *sk, struct sockaddr *uaddr,
+			int addr_len)
+{
+	return -ENOTSUPP;
+}
+
+static int raw_disconnect(struct sock *sk, int flags)
+{
+	return 0;
+}
+
+static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t size)
+{
+	struct net_device *dev;
+	unsigned mtu;
+	struct sk_buff *skb;
+	int err;
+
+	if (msg->msg_flags & MSG_OOB) {
+		pr_debug("msg->msg_flags = 0x%x\n", msg->msg_flags);
+		return -EOPNOTSUPP;
+	}
+
+	lock_sock(sk);
+	if (!sk->sk_bound_dev_if)
+		dev = dev_getfirstbyhwtype(sock_net(sk), ARPHRD_IEEE802154_PHY);
+	else
+		dev = dev_get_by_index(sock_net(sk), sk->sk_bound_dev_if);
+	release_sock(sk);
+
+	if (!dev) {
+		pr_debug("no dev\n");
+		err = -ENXIO;
+		goto out;
+	}
+
+	mtu = dev->mtu;
+	pr_debug("name = %s, mtu = %u\n", dev->name, mtu);
+
+	if (size > mtu) {
+		pr_debug("size = %u, mtu = %u\n", size, mtu);
+		err = -EINVAL;
+		goto out_dev;
+	}
+
+	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + size, msg->msg_flags & MSG_DONTWAIT,
+				  &err);
+	if (!skb)
+		goto out_dev;
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+
+	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	if (err < 0)
+		goto out_skb;
+
+	skb->dev = dev;
+	skb->sk  = sk;
+	skb->protocol = htons(ETH_P_IEEE802154);
+
+	err = dev_queue_xmit(skb);
+
+	dev_put(dev);
+
+	return size;
+
+out_skb:
+	kfree_skb(skb);
+out_dev:
+	dev_put(dev);
+out:
+	return err;
+}
+
+static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t len, int noblock, int flags, int *addr_len)
+{
+	size_t copied = 0;
+	int err = -EOPNOTSUPP;
+	struct sk_buff *skb;
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		goto out;
+
+	copied = skb->len;
+	if (len < copied) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto done;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
+done:
+	skb_free_datagram(sk, skb);
+out:
+	if (err)
+		return err;
+	return copied;
+}
+
+static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
+		atomic_inc(&sk->sk_drops);
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+
+void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+
+	read_lock(&raw_lock);
+	sk_for_each(sk, node, &raw_head) {
+		bh_lock_sock(sk);
+		if (!sk->sk_bound_dev_if || sk->sk_bound_dev_if == dev->ifindex) {
+
+			struct sk_buff *clone;
+
+			clone = skb_clone(skb, GFP_ATOMIC);
+			if (clone)
+				raw_rcv_skb(sk, clone);
+		}
+		bh_unlock_sock(sk);
+	}
+	read_unlock(&raw_lock);
+}
+
+struct proto ieee802154_raw_prot = {
+	.name		= "IEEE-802.15.4-RAW",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct sock),
+	.close		= raw_close,
+	.bind		= raw_bind,
+	.sendmsg	= raw_sendmsg,
+	.recvmsg	= raw_recvmsg,
+	.hash		= raw_hash,
+	.unhash		= raw_unhash,
+	.connect	= raw_connect,
+	.disconnect	= raw_disconnect,
+};
+
-- 
1.6.2.4

