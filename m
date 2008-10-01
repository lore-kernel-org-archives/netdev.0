From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 3/4] Phonet: support GPRS interface over PEP socket
Date: Wed,  1 Oct 2008 11:22:36 +0300
Message-ID: <1222849357-8561-3-git-send-email-remi.denis-courmont@nokia.com>
References: <200810011121.14746.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:20223 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbYJAIWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 04:22:44 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m918MMCs001353
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 11:22:41 +0300
In-Reply-To: <200810011121.14746.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/phonet.h    |    8 +
 include/linux/socket.h    |    1 +
 include/net/phonet/gprs.h |   38 +++++
 include/net/phonet/pep.h  |    1 +
 net/phonet/Makefile       |    2 +-
 net/phonet/pep-gprs.c     |  345 +++++++++++++++++++++++++++++++++++++=
++++++++
 net/phonet/pep.c          |  157 +++++++++++++++++++--
 net/phonet/socket.c       |    8 +-
 8 files changed, 546 insertions(+), 14 deletions(-)
 create mode 100644 include/net/phonet/gprs.h
 create mode 100644 net/phonet/pep-gprs.c

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index f921852..c9609f9 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -31,9 +31,17 @@
 #define PN_PROTO_PIPE		2
 #define PHONET_NPROTO		3
=20
+/* Socket options for SOL_PNPIPE level */
+#define PNPIPE_ENCAP		1
+#define PNPIPE_IFINDEX		2
+
 #define PNADDR_ANY		0
 #define PNPORT_RESOURCE_ROUTING	0
=20
+/* Values for PNPIPE_ENCAP option */
+#define PNPIPE_ENCAP_NONE	0
+#define PNPIPE_ENCAP_IP		1
+
 /* ioctls */
 #define SIOCPNGETOBJECT		(SIOCPROTOPRIVATE + 0)
=20
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 818ca33..20fc4bb 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -297,6 +297,7 @@ struct ucred {
 #define SOL_RXRPC	272
 #define SOL_PPPOL2TP	273
 #define SOL_BLUETOOTH	274
+#define SOL_PNPIPE	275
=20
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/include/net/phonet/gprs.h b/include/net/phonet/gprs.h
new file mode 100644
index 0000000..928daf5
--- /dev/null
+++ b/include/net/phonet/gprs.h
@@ -0,0 +1,38 @@
+/*
+ * File: pep_gprs.h
+ *
+ * GPRS over Phonet pipe end point socket
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * Author: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
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
+#ifndef NET_PHONET_GPRS_H
+#define NET_PHONET_GPRS_H
+
+struct sock;
+struct sk_buff;
+
+int pep_writeable(struct sock *sk);
+int pep_write(struct sock *sk, struct sk_buff *skb);
+struct sk_buff *pep_read(struct sock *sk);
+
+int gprs_attach(struct sock *sk);
+void gprs_detach(struct sock *sk);
+
+#endif
diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index b06852b..a202adc 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -35,6 +35,7 @@ struct pep_sock {
 	struct sock		*listener;
 	struct sk_buff_head	ctrlreq_queue;
 #define PNPIPE_CTRLREQ_MAX	10
+	int			ifindex;
 	u16			peer_type;	/* peer type/subtype */
 	u8			pipe_handle;
=20
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
index 505df2a..d62bbba 100644
--- a/net/phonet/Makefile
+++ b/net/phonet/Makefile
@@ -8,4 +8,4 @@ phonet-objs :=3D \
 	sysctl.o \
 	af_phonet.o
=20
-pn_pep-objs :=3D pep.o
+pn_pep-objs :=3D pep.o pep-gprs.o
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
new file mode 100644
index 0000000..a361be4
--- /dev/null
+++ b/net/phonet/pep-gprs.c
@@ -0,0 +1,345 @@
+/*
+ * File: pep-gprs.c
+ *
+ * GPRS over Phonet pipe end point socket
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * Author: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
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
+#include <linux/netdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_arp.h>
+#include <net/sock.h>
+
+#include <linux/if_phonet.h>
+#include <net/tcp_states.h>
+#include <net/phonet/gprs.h>
+
+#define GPRS_DEFAULT_MTU 1400
+
+#define DBG(dev, fmt, args...) \
+	printk(KERN_DEBUG "GPRS(%p): " fmt, dev, ## args)
+
+struct gprs_dev {
+	struct sock		*sk;
+	void			(*old_state_change)(struct sock *);
+	void			(*old_data_ready)(struct sock *, int);
+	void			(*old_write_space)(struct sock *);
+
+	struct net_device	*net;
+	struct net_device_stats	stats;
+
+	struct sk_buff_head	tx_queue;
+	struct work_struct	tx_work;
+	spinlock_t		tx_lock;
+	unsigned		tx_max;
+};
+
+/*
+ * Socket callbacks
+ */
+
+static void gprs_state_change(struct sock *sk)
+{
+	struct gprs_dev *dev =3D sk->sk_user_data;
+
+	if (sk->sk_state =3D=3D TCP_CLOSE_WAIT) {
+		netif_stop_queue(dev->net);
+		netif_carrier_off(dev->net);
+	}
+}
+
+static int gprs_recv(struct gprs_dev *dev, struct sk_buff *skb)
+{
+	int err =3D 0;
+	u16 protocol;
+
+	if (!pskb_may_pull(skb, 1))
+		goto drop;
+
+	/* Look at IP version field */
+	switch (skb->data[0] >> 4) {
+	case 4:
+		protocol =3D htons(ETH_P_IP);
+		break;
+	case 6:
+		protocol =3D htons(ETH_P_IPV6);
+		break;
+	default:
+		err =3D -EINVAL;
+		goto drop;
+	}
+
+	if (likely(skb_headroom(skb) & 3)) {
+		struct sk_buff *rskb, *fs;
+		int flen =3D 0;
+
+		/* Phonet Pipe data header is misaligned (3 bytes),
+		 * so wrap the IP packet as a single fragment of an head-less
+		 * socket buffer. The network stack will pull what it needs,
+		 * but at least, the whole IP payload is not memcpy'd. */
+		rskb =3D netdev_alloc_skb(dev->net, 0);
+		if (!rskb) {
+			err =3D -ENOBUFS;
+			goto drop;
+		}
+		skb_shinfo(rskb)->frag_list =3D skb;
+		rskb->len +=3D skb->len;
+		rskb->data_len +=3D rskb->len;
+		rskb->truesize +=3D rskb->len;
+
+		/* Avoid nested fragments */
+		for (fs =3D skb_shinfo(skb)->frag_list; fs; fs =3D fs->next)
+			flen +=3D fs->len;
+		skb->next =3D skb_shinfo(skb)->frag_list;
+		skb_shinfo(skb)->frag_list =3D NULL;
+		skb->len -=3D flen;
+		skb->data_len -=3D flen;
+		skb->truesize -=3D flen;
+
+		skb =3D rskb;
+	}
+
+	skb->protocol =3D protocol;
+	skb_reset_mac_header(skb);
+	skb->dev =3D dev->net;
+
+	if (likely(dev->net->flags & IFF_UP)) {
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes +=3D skb->len;
+		netif_rx(skb);
+		skb =3D NULL;
+	} else
+		err =3D -ENODEV;
+
+drop:
+	if (skb) {
+		dev_kfree_skb(skb);
+		dev->stats.rx_dropped++;
+	}
+	return err;
+}
+
+static void gprs_data_ready(struct sock *sk, int len)
+{
+	struct gprs_dev *dev =3D sk->sk_user_data;
+	struct sk_buff *skb;
+
+	while ((skb =3D pep_read(sk)) !=3D NULL) {
+		skb_orphan(skb);
+		gprs_recv(dev, skb);
+	}
+}
+
+static void gprs_write_space(struct sock *sk)
+{
+	struct gprs_dev *dev =3D sk->sk_user_data;
+	unsigned credits =3D pep_writeable(sk);
+
+	spin_lock_bh(&dev->tx_lock);
+	dev->tx_max =3D credits;
+	if (credits > skb_queue_len(&dev->tx_queue))
+		netif_wake_queue(dev->net);
+	spin_unlock_bh(&dev->tx_lock);
+}
+
+/*
+ * Network device callbacks
+ */
+
+static int gprs_xmit(struct sk_buff *skb, struct net_device *net)
+{
+	struct gprs_dev *dev =3D netdev_priv(net);
+
+	switch (skb->protocol) {
+	case  htons(ETH_P_IP):
+	case  htons(ETH_P_IPV6):
+		break;
+	default:
+		dev_kfree_skb(skb);
+		return 0;
+	}
+
+	spin_lock(&dev->tx_lock);
+	if (likely(skb_queue_len(&dev->tx_queue) < dev->tx_max)) {
+		skb_queue_tail(&dev->tx_queue, skb);
+		skb =3D NULL;
+	}
+	if (skb_queue_len(&dev->tx_queue) >=3D dev->tx_max)
+		netif_stop_queue(net);
+	spin_unlock(&dev->tx_lock);
+
+	schedule_work(&dev->tx_work);
+	if (unlikely(skb))
+		dev_kfree_skb(skb);
+	return 0;
+}
+
+static void gprs_tx(struct work_struct *work)
+{
+	struct gprs_dev *dev =3D container_of(work, struct gprs_dev, tx_work)=
;
+	struct sock *sk =3D dev->sk;
+	struct sk_buff *skb;
+
+	while ((skb =3D skb_dequeue(&dev->tx_queue)) !=3D NULL) {
+		int err;
+
+		dev->stats.tx_bytes +=3D skb->len;
+		dev->stats.tx_packets++;
+
+		skb_orphan(skb);
+		skb_set_owner_w(skb, sk);
+
+		lock_sock(sk);
+		err =3D pep_write(sk, skb);
+		if (err) {
+			DBG(dev, "TX error (%d)\n", err);
+			dev->stats.tx_aborted_errors++;
+			dev->stats.tx_errors++;
+		}
+		release_sock(sk);
+	}
+
+	lock_sock(sk);
+	gprs_write_space(sk);
+	release_sock(sk);
+}
+
+static int gprs_set_mtu(struct net_device *net, int new_mtu)
+{
+	if ((new_mtu < 576) || (new_mtu > (PHONET_MAX_MTU - 11)))
+		return -EINVAL;
+
+	net->mtu =3D new_mtu;
+	return 0;
+}
+
+static struct net_device_stats *gprs_get_stats(struct net_device *net)
+{
+	struct gprs_dev *dev =3D netdev_priv(net);
+
+	return &dev->stats;
+}
+
+static void gprs_setup(struct net_device *net)
+{
+	net->features		=3D NETIF_F_FRAGLIST;
+	net->type		=3D ARPHRD_NONE;
+	net->flags		=3D IFF_POINTOPOINT | IFF_NOARP;
+	net->mtu		=3D GPRS_DEFAULT_MTU;
+	net->hard_header_len	=3D 0;
+	net->addr_len		=3D 0;
+	net->tx_queue_len	=3D 10;
+
+	net->destructor		=3D free_netdev;
+	net->hard_start_xmit	=3D gprs_xmit; /* mandatory */
+	net->change_mtu		=3D gprs_set_mtu;
+	net->get_stats		=3D gprs_get_stats;
+}
+
+/*
+ * External interface
+ */
+
+/*
+ * Attach a GPRS interface to a datagram socket.
+ * Returns the interface index on success, negative error code on erro=
r.
+ */
+int gprs_attach(struct sock *sk)
+{
+	static const char ifname[] =3D "gprs%d";
+	struct gprs_dev *dev;
+	struct net_device *net;
+	int err;
+
+	printk(KERN_DEBUG "GPRS(): attaching to %p...\n", sk);
+	if (unlikely(sk->sk_type =3D=3D SOCK_STREAM))
+		return -EINVAL; /* need packet boundaries */
+
+	/* Create net device */
+	net =3D alloc_netdev(sizeof(*dev), ifname, gprs_setup);
+	if (!net)
+		return -ENOMEM;
+	dev =3D netdev_priv(net);
+	dev->net =3D net;
+	dev->tx_max =3D 0;
+	spin_lock_init(&dev->tx_lock);
+	skb_queue_head_init(&dev->tx_queue);
+	INIT_WORK(&dev->tx_work, gprs_tx);
+
+	netif_stop_queue(net);
+	err =3D register_netdev(net);
+	if (err) {
+		free_netdev(net);
+		return err;
+	}
+
+	lock_sock(sk);
+	if (unlikely(sk->sk_user_data)) {
+		err =3D -EBUSY;
+		goto out_rel;
+	}
+	if (unlikely((1 << sk->sk_state & (TCPF_CLOSE|TCPF_LISTEN)) ||
+			sock_flag(sk, SOCK_DEAD))) {
+		err =3D -EINVAL;
+		goto out_rel;
+	}
+	sk->sk_user_data	=3D dev;
+	dev->old_state_change	=3D sk->sk_state_change;
+	dev->old_data_ready	=3D sk->sk_data_ready;
+	dev->old_write_space	=3D sk->sk_write_space;
+	sk->sk_state_change	=3D gprs_state_change;
+	sk->sk_data_ready	=3D gprs_data_ready;
+	sk->sk_write_space	=3D gprs_write_space;
+	release_sock(sk);
+
+	sock_hold(sk);
+	dev->sk =3D sk;
+
+	DBG(dev, "attached %s\n", net->name);
+	gprs_write_space(sk); /* kick off TX */
+	return net->ifindex;
+
+out_rel:
+	release_sock(sk);
+	unregister_netdev(net);
+	return err;
+}
+
+void gprs_detach(struct sock *sk)
+{
+	struct gprs_dev *dev =3D sk->sk_user_data;
+	struct net_device *net =3D dev->net;
+
+	DBG(dev, "detaching %s\n", net->name);
+
+	lock_sock(sk);
+	sk->sk_user_data	=3D NULL;
+	sk->sk_state_change	=3D dev->old_state_change;
+	sk->sk_data_ready	=3D dev->old_data_ready;
+	sk->sk_write_space	=3D dev->old_write_space;
+	release_sock(sk);
+
+	unregister_netdev(net);
+	flush_scheduled_work();
+	sock_put(sk);
+	skb_queue_purge(&dev->tx_queue);
+	DBG(dev, "detached from %p\n", sk);
+}
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 6bf3d0b..797f2d3 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -31,6 +31,7 @@
 #include <linux/phonet.h>
 #include <net/phonet/phonet.h>
 #include <net/phonet/pep.h>
+#include <net/phonet/gprs.h>
=20
 /* sk_state values:
  * TCP_CLOSE		sock not in use yet
@@ -618,6 +619,7 @@ drop:
 static void pep_sock_close(struct sock *sk, long timeout)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
+	int ifindex =3D 0;
=20
 	sk_common_release(sk);
=20
@@ -631,7 +633,12 @@ static void pep_sock_close(struct sock *sk, long t=
imeout)
 			sk_del_node_init(sknode);
 		sk->sk_state =3D TCP_CLOSE;
 	}
+	ifindex =3D pn->ifindex;
+	pn->ifindex =3D 0;
 	release_sock(sk);
+
+	if (ifindex)
+		gprs_detach(sk);
 }
=20
 static int pep_wait_connreq(struct sock *sk, int noblock)
@@ -736,12 +743,105 @@ static int pep_init(struct sock *sk)
 	return 0;
 }
=20
+static int pep_setsockopt(struct sock *sk, int level, int optname,
+				char __user *optval, int optlen)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	int val =3D 0, err =3D 0;
+
+	if (level !=3D SOL_PNPIPE)
+		return -ENOPROTOOPT;
+	if (optlen >=3D sizeof(int)) {
+		if (get_user(val, (int __user *) optval))
+			return -EFAULT;
+	}
+
+	lock_sock(sk);
+	switch (optname) {
+	case PNPIPE_ENCAP:
+		if (val && val !=3D PNPIPE_ENCAP_IP) {
+			err =3D -EINVAL;
+			break;
+		}
+		if (!pn->ifindex =3D=3D !val)
+			break; /* Nothing to do! */
+		if (!capable(CAP_NET_ADMIN)) {
+			err =3D -EPERM;
+			break;
+		}
+		if (val) {
+			release_sock(sk);
+			err =3D gprs_attach(sk);
+			if (err > 0) {
+				pn->ifindex =3D err;
+				err =3D 0;
+			}
+		} else {
+			pn->ifindex =3D 0;
+			release_sock(sk);
+			gprs_detach(sk);
+			err =3D 0;
+		}
+		goto out_norel;
+	default:
+		err =3D -ENOPROTOOPT;
+	}
+	release_sock(sk);
+
+out_norel:
+	return err;
+}
+
+static int pep_getsockopt(struct sock *sk, int level, int optname,
+				char __user *optval, int __user *optlen)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	int len, val;
+
+	if (level !=3D SOL_PNPIPE)
+		return -ENOPROTOOPT;
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	switch (optname) {
+	case PNPIPE_ENCAP:
+		val =3D pn->ifindex ? PNPIPE_ENCAP_IP : PNPIPE_ENCAP_NONE;
+		break;
+	case PNPIPE_IFINDEX:
+		val =3D pn->ifindex;
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	len =3D min_t(unsigned int, sizeof(int), len);
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (put_user(val, (int __user *) optval))
+		return -EFAULT;
+	return 0;
+}
+
+static int pipe_skb_send(struct sock *sk, struct sk_buff *skb)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct pnpipehdr *ph;
+
+	ph =3D (struct pnpipehdr *)skb_push(skb, 3);
+	ph->utid =3D 0;
+	ph->message_id =3D PNS_PIPE_DATA;
+	ph->pipe_handle =3D pn->pipe_handle;
+	if (pn_flow_safe(pn->tx_fc) && pn->tx_credits)
+		pn->tx_credits--;
+
+	return pn_skb_send(sk, skb, &pipe_srv);
+}
+
 static int pep_sendmsg(struct kiocb *iocb, struct sock *sk,
 			struct msghdr *msg, size_t len)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct sk_buff *skb =3D NULL;
-	struct pnpipehdr *ph;
 	long timeo;
 	int flags =3D msg->msg_flags;
 	int err, done;
@@ -807,14 +907,7 @@ disabled:
 	if (err < 0)
 		goto out;
=20
-	ph =3D (struct pnpipehdr *)skb_push(skb, 3);
-	ph->utid =3D 0;
-	ph->message_id =3D PNS_PIPE_DATA;
-	ph->pipe_handle =3D pn->pipe_handle;
-	if (pn_flow_safe(pn->tx_fc)) /* credit-based flow control */
-		pn->tx_credits--;
-
-	err =3D pn_skb_send(sk, skb, &pipe_srv);
+	err =3D pipe_skb_send(sk, skb);
 	if (err >=3D 0)
 		err =3D len; /* success! */
 	skb =3D NULL;
@@ -825,6 +918,50 @@ out:
 	return err;
 }
=20
+int pep_writeable(struct sock *sk)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+
+	return (sk->sk_state =3D=3D TCP_ESTABLISHED) ? pn->tx_credits : 0;
+}
+
+int pep_write(struct sock *sk, struct sk_buff *skb)
+{
+	struct sk_buff *rskb, *fs;
+	int flen =3D 0;
+
+	rskb =3D alloc_skb(MAX_PNPIPE_HEADER, GFP_ATOMIC);
+	if (!rskb) {
+		kfree_skb(skb);
+		return -ENOMEM;
+	}
+	skb_shinfo(rskb)->frag_list =3D skb;
+	rskb->len +=3D skb->len;
+	rskb->data_len +=3D rskb->len;
+	rskb->truesize +=3D rskb->len;
+
+	/* Avoid nested fragments */
+	for (fs =3D skb_shinfo(skb)->frag_list; fs; fs =3D fs->next)
+		flen +=3D fs->len;
+	skb->next =3D skb_shinfo(skb)->frag_list;
+	skb_shinfo(skb)->frag_list =3D NULL;
+	skb->len -=3D flen;
+	skb->data_len -=3D flen;
+	skb->truesize -=3D flen;
+
+	skb_reserve(rskb, MAX_PHONET_HEADER + 3);
+	return pipe_skb_send(sk, rskb);
+}
+
+struct sk_buff *pep_read(struct sock *sk)
+{
+	struct sk_buff *skb =3D skb_dequeue(&sk->sk_receive_queue);
+
+	if (sk->sk_state =3D=3D TCP_ESTABLISHED)
+		pipe_grant_credits(sk);
+	return skb;
+}
+
 static int pep_recvmsg(struct kiocb *iocb, struct sock *sk,
 			struct msghdr *msg, size_t len, int noblock,
 			int flags, int *addr_len)
@@ -907,6 +1044,8 @@ static struct proto pep_proto =3D {
 	.accept		=3D pep_sock_accept,
 	.ioctl		=3D pep_ioctl,
 	.init		=3D pep_init,
+	.setsockopt	=3D pep_setsockopt,
+	.getsockopt	=3D pep_getsockopt,
 	.sendmsg	=3D pep_sendmsg,
 	.recvmsg	=3D pep_recvmsg,
 	.backlog_rcv	=3D pep_do_rcv,
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index a9c3d1f..d817401 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -342,11 +342,11 @@ const struct proto_ops phonet_stream_ops =3D {
 	.ioctl		=3D pn_socket_ioctl,
 	.listen		=3D pn_socket_listen,
 	.shutdown	=3D sock_no_shutdown,
-	.setsockopt	=3D sock_no_setsockopt,
-	.getsockopt	=3D sock_no_getsockopt,
+	.setsockopt	=3D sock_common_setsockopt,
+	.getsockopt	=3D sock_common_getsockopt,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt =3D sock_no_setsockopt,
-	.compat_getsockopt =3D compat_sock_no_getsockopt,
+	.compat_setsockopt =3D compat_sock_common_setsockopt,
+	.compat_getsockopt =3D compat_sock_common_getsockopt,
 #endif
 	.sendmsg	=3D pn_socket_sendmsg,
 	.recvmsg	=3D sock_common_recvmsg,
--=20
1.5.4.3

