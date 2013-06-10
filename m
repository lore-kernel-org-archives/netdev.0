From: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Subject: [PATCH 1/3] net: add support for MOST protocol
Date: Mon, 10 Jun 2013 14:52:25 +0200
Message-ID: <7d70dd76e3e756ca98414247213b7e8fad7034c9.1370856733.git.asnaghi@st.com>
References: <cover.1370856733.git.asnaghi@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alessandro Rubini <rubini@gnudd.com>,
	Federico Vaga <federico.vaga@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1370856733.git.asnaghi@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds core support for the MOST protocol. More information
about the protocol can be found at: http://www.mostcooperation.com/

See the lkml message "[PATCH 0/3] MOST network protocol" sent on Jun
10th 2013 about this code and the missing "Signed-off" lines.
---
 include/linux/socket.h  |    4 +-
 include/net/most/most.h |  238 ++++++++++++
 net/Kconfig             |    1 +
 net/Makefile            |    1 +
 net/core/sock.c         |    9 +-
 net/most/Kconfig        |   15 +
 net/most/Makefile       |    6 +
 net/most/af_most.c      |  967 +++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 1237 insertions(+), 4 deletions(-)
 create mode 100644 include/net/most/most.h
 create mode 100644 net/most/Kconfig
 create mode 100644 net/most/Makefile
 create mode 100644 net/most/af_most.c

diff --git a/include/linux/socket.h b/include/linux/socket.h
index b10ce4b..b1e6669 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -179,7 +179,8 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_MOST		41	/* MOST sockets			*/
+#define AF_MAX		42	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -223,6 +224,7 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_MOST		AF_MOST
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/net/most/most.h b/include/net/most/most.h
new file mode 100644
index 0000000..f266fc7
--- /dev/null
+++ b/include/net/most/most.h
@@ -0,0 +1,238 @@
+#ifndef __MOST_H
+#define __MOST_H
+
+#include <linux/interrupt.h>
+#include <net/sock.h>
+
+/* Reserve for core and drivers use */
+#define MOST_SKB_RESERVE	8
+
+#define CTL_FRAME_SIZE 32
+
+#define MOSTPROTO_DEV	0
+#define MOSTPROTO_CTL	1
+#define MOSTPROTO_SYNC	2
+#define MOSTPROTO_ASYNC	3
+
+#define MOST_NO_CHANNEL 0xFE
+
+#define MOST_CONF_FLAG_UP   0x01
+#define MOST_CONF_FLAG_TX   0x02
+
+enum most_dev_state {
+	MOST_DEV_DOWN = 0,
+	MOST_DEV_UP
+};
+
+enum most_chan_type {
+	CHAN_DEV = 0,
+	CHAN_CTL,
+	CHAN_SYNC,
+	CHAN_ASYNC,
+};
+
+enum {
+	MOST_CONNECTED = 1, /* Equal to TCP_ESTABLISHED makes net code happy */
+	MOST_OPEN,
+	MOST_BOUND,
+};
+
+struct sockaddr_most {
+	sa_family_t    most_family;
+	unsigned short most_dev;
+	unsigned char  rx_channel;
+	unsigned char  tx_channel;
+};
+
+struct sockaddr_mostdev {
+	sa_family_t    most_family;
+	unsigned short most_dev;
+};
+
+/* MOST Dev ioctl defines */
+#define MOSTDEVUP	_IOW('M', 201, int)
+#define MOSTDEVDOWN	_IOW('M', 202, int)
+
+#define MOSTGETDEVLIST	_IOR('M', 210, int)
+
+struct most_dev_req {
+	uint16_t dev_id;
+};
+
+struct most_dev_list_req {
+	uint16_t dev_num;
+	struct most_dev_req dev_req[0];
+};
+
+struct most_skb_cb {
+	__u8 channel_type;
+	__u8 channel;
+};
+#define most_cb(skb) ((struct most_skb_cb *)(skb->cb))
+
+struct most_sock {
+	struct sock sk;
+	u8 channel_type;
+	u8 rx_channel;
+	u8 tx_channel;
+	int dev_id;
+	struct most_dev *mdev;
+};
+#define most_sk(sk) ((struct most_sock *)sk)
+
+static inline struct sock *most_sk_alloc(struct net *net,
+	struct proto *pops, u8 channel_type)
+{
+	struct sock *sk = sk_alloc(net, PF_MOST, GFP_ATOMIC, pops);
+	if (sk) {
+		most_sk(sk)->channel_type = channel_type;
+		most_sk(sk)->dev_id = -1;
+	}
+
+	return sk;
+}
+static inline struct sk_buff *most_skb_alloc(unsigned int len, gfp_t how)
+{
+	struct sk_buff *skb = alloc_skb(len + MOST_SKB_RESERVE, how);
+
+	if (skb)
+		skb_reserve(skb, MOST_SKB_RESERVE);
+
+	return skb;
+}
+
+static inline struct sk_buff *most_skb_send_alloc(struct sock *sk,
+	unsigned long len, int nb, int *err)
+{
+	struct sk_buff *skb =
+		sock_alloc_send_skb(sk, len + MOST_SKB_RESERVE, nb, err);
+
+	if (skb)
+		skb_reserve(skb, MOST_SKB_RESERVE);
+
+	return skb;
+}
+
+struct most_sock_list {
+	struct hlist_head head;
+	rwlock_t          lock;
+};
+
+
+struct most_dev {
+
+	struct list_head list;
+	atomic_t refcnt;
+
+	char name[8];
+
+	__u16 id;
+	enum most_dev_state state;
+
+	struct module *owner;
+
+	struct tasklet_struct rx_task;
+	struct tasklet_struct tx_task;
+
+	struct sk_buff_head rx_q;
+	struct sk_buff_head ctl_q;
+	struct sk_buff_head async_q;
+	struct sk_buff_head sync_q;
+
+	/* set by the driver */
+
+	void *driver_data;
+	struct device	*parent;
+
+	int (*open)(struct most_dev *mdev);
+	int (*close)(struct most_dev *mdev);
+	int (*conf_channel)(struct most_dev *mdev, enum most_chan_type type,
+		u8 channel, u8 flags);
+	int (*send)(struct sk_buff *skb);
+	int (*can_send)(struct sk_buff *skb);
+};
+
+static inline struct most_dev *most_dev_hold(struct most_dev *d)
+{
+	if (try_module_get(d->owner))
+		return d;
+	return NULL;
+}
+
+static inline void most_dev_put(struct most_dev *d)
+{
+	module_put(d->owner);
+}
+
+static inline void most_sched_tx(struct most_dev *mdev)
+{
+	tasklet_schedule(&mdev->tx_task);
+}
+
+static inline void most_sched_rx(struct most_dev *mdev)
+{
+	tasklet_schedule(&mdev->rx_task);
+}
+
+static inline int most_recv_frame(struct sk_buff *skb)
+{
+	struct most_dev *mdev = (struct most_dev *) skb->dev;
+
+	/* Time stamp */
+	__net_timestamp(skb);
+
+	/* Queue frame for rx task */
+	skb_queue_tail(&mdev->rx_q, skb);
+	most_sched_rx(mdev);
+	return 0;
+}
+
+static inline int __most_configure_channel(struct most_dev *mdev,
+	u8 channel_type, u8 channel, u8 up)
+{
+	if (mdev->state != MOST_DEV_UP)
+		return -ENETDOWN;
+
+	if (mdev->conf_channel)
+		if (channel != MOST_NO_CHANNEL)
+			return mdev->conf_channel(mdev, channel_type, channel,
+				up);
+	return 0;
+}
+
+static inline int most_configure_channels(struct most_dev *mdev,
+	struct most_sock *sk, u8 up)
+{
+	int err;
+	u8 flags = (up) ? MOST_CONF_FLAG_UP : 0;
+
+	err = __most_configure_channel(mdev, sk->channel_type, sk->rx_channel,
+		flags);
+	if (err)
+		return err;
+
+	err = __most_configure_channel(mdev, sk->channel_type, sk->tx_channel,
+		flags | MOST_CONF_FLAG_TX);
+	if (err)
+		__most_configure_channel(mdev, sk->channel_type, sk->rx_channel,
+		(up) ? 0 : MOST_CONF_FLAG_UP);
+	return err;
+}
+
+struct most_dev *most_alloc_dev(void);
+void most_free_dev(struct most_dev *mdev);
+int most_register_dev(struct most_dev *mdev);
+int most_unregister_dev(struct most_dev *mdev);
+
+int most_get_dev_list(void __user *arg);
+int most_open_dev(u16 dev_id);
+int most_close_dev(u16 dev_id);
+
+struct most_dev *most_dev_get(int index);
+
+void most_sock_link(struct sock *s);
+void most_sock_unlink(struct sock *sk);
+
+int most_send_to_sock(int dev_id, struct sk_buff *skb);
+
+#endif /* __MOST_H */
diff --git a/net/Kconfig b/net/Kconfig
index 2273655..8bfc9a2 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -327,6 +327,7 @@ source "net/can/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
+source "net/most/Kconfig"
 
 config FIB_RULES
 	bool
diff --git a/net/Makefile b/net/Makefile
index 9492e8c..ee1a125 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -40,6 +40,7 @@ obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_L2TP)		+= l2tp/
 obj-$(CONFIG_DECNET)		+= decnet/
 obj-$(CONFIG_PHONET)		+= phonet/
+obj-$(CONFIG_MOST)		+= most/
 ifneq ($(CONFIG_VLAN_8021Q),)
 obj-y				+= 8021q/
 endif
diff --git a/net/core/sock.c b/net/core/sock.c
index 88868a9..920b68f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -210,7 +210,8 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
-  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_MAX"
+  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_MOST"     ,
+  "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -226,7 +227,8 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
-  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_MAX"
+  "slock-AF_NFC"   , "slock-AF_VSOCK"    , "slock-AF_MOST"     ,
+  "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -242,7 +244,8 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
-  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_MAX"
+  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_MOST"     ,
+  "clock-AF_MAX"
 };
 
 /*
diff --git a/net/most/Kconfig b/net/most/Kconfig
new file mode 100644
index 0000000..6158836
--- /dev/null
+++ b/net/most/Kconfig
@@ -0,0 +1,15 @@
+#
+# Media Oriented Systems Transport (MOST) network layer core configuration
+#
+
+menuconfig MOST
+	depends on NET
+	tristate "MOST bus subsystem support"
+	---help---
+	  Media Oriented Systems Transport (MOST) is a multimedia
+	  communications protocol in the automotive industry.
+	  You also need a low level for the hardware.
+	  Isochronous channels are currently not supported.
+	  If you want MOST support you should say Y here.
+
+source "drivers/net/most/Kconfig"
diff --git a/net/most/Makefile b/net/most/Makefile
new file mode 100644
index 0000000..eadb570
--- /dev/null
+++ b/net/most/Makefile
@@ -0,0 +1,6 @@
+#
+#  Makefile for the Linux Media Oriented Systems Transport core.
+#
+
+obj-$(CONFIG_MOST)	+= most.o
+most-objs		:= af_most.o
diff --git a/net/most/af_most.c b/net/most/af_most.c
new file mode 100644
index 0000000..d51ab1d
--- /dev/null
+++ b/net/most/af_most.c
@@ -0,0 +1,967 @@
+/*
+ * af_most.c Support for the MOST address family
+ * Copyright (c) 2009 Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <net/sock.h>
+#include <net/most/most.h>
+
+#define MOST_MAX_PROTO	4
+static struct net_proto_family most_net_proto_family_ops[];
+static struct proto most_proto[];
+
+/* MOST device list */
+LIST_HEAD(most_dev_list);
+DEFINE_RWLOCK(most_dev_list_lock);
+
+/* * * * * * * * * * * * * * PROTO OPS * * * * * * * * * * * * */
+
+static struct most_sock_list most_sk_list = {
+	.lock = __RW_LOCK_UNLOCKED(ctl_sk_list.lock)
+};
+
+void most_sock_link(struct sock *sk)
+{
+	write_lock_bh(&most_sk_list.lock);
+	sk_add_node(sk, &most_sk_list.head);
+	write_unlock_bh(&most_sk_list.lock);
+}
+EXPORT_SYMBOL(most_sock_link);
+
+void most_sock_unlink(struct sock *sk)
+{
+	write_lock_bh(&most_sk_list.lock);
+	sk_del_node_init(sk);
+	write_unlock_bh(&most_sk_list.lock);
+}
+EXPORT_SYMBOL(most_sock_unlink);
+
+static int channel_in_use(int dev_id, u8 channel)
+{
+	struct sock *sk;
+
+	read_lock_bh(&most_sk_list.lock);
+
+	sk_for_each(sk, &most_sk_list.head)
+		if (most_sk(sk)->dev_id == dev_id &&
+			sk->sk_state == MOST_BOUND &&
+			(most_sk(sk)->rx_channel == channel ||
+			 most_sk(sk)->tx_channel == channel))
+			goto found;
+
+	sk = NULL;
+found:
+	read_unlock_bh(&most_sk_list.lock);
+
+	return sk != NULL;
+}
+
+int most_send_to_sock(int dev_id, struct sk_buff *skb)
+{
+	struct sock *sk;
+
+	read_lock(&most_sk_list.lock);
+	sk_for_each(sk, &most_sk_list.head) {
+		if (most_sk(sk)->dev_id == dev_id &&
+			most_sk(sk)->channel_type == most_cb(skb)->channel_type
+			&& most_sk(sk)->rx_channel == most_cb(skb)->channel &&
+			sk->sk_state == MOST_BOUND) {
+
+			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+			if (nskb)
+				if (sock_queue_rcv_skb(sk, nskb))
+					kfree_skb(nskb);
+		}
+
+	}
+	read_unlock(&most_sk_list.lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(most_send_to_sock);
+
+static int most_sock_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct most_dev *mdev;
+
+	pr_debug("%s: sock %p sk %p\n", __func__, sock, sk);
+
+	if (!sk)
+		return 0;
+
+	mdev = most_sk(sk)->mdev;
+
+	most_sock_unlink(sk);
+
+	if (mdev) {
+		if (sk->sk_state == MOST_BOUND)
+			most_configure_channels(mdev, most_sk(sk), 0);
+
+		most_dev_put(mdev);
+	}
+
+	sock_orphan(sk);
+	sock_put(sk);
+	return 0;
+}
+
+static int most_sock_bind(struct socket *sock, struct sockaddr *addr,
+			  int addr_len)
+{
+	struct sockaddr_most *maddr = (struct sockaddr_most *)addr;
+	struct sock *sk = sock->sk;
+	struct most_dev *mdev = NULL;
+	int err = 0;
+
+	if (!maddr || maddr->most_family != AF_MOST)
+		return -EINVAL;
+
+	pr_debug("%s: sock %p sk %p, rx: %d, tx: %d\n",
+		__func__, sock, sk, maddr->rx_channel, maddr->tx_channel);
+
+	lock_sock(sk);
+
+	if (sk->sk_state != MOST_OPEN) {
+		err = -EBADFD;
+		goto done;
+	}
+
+	if (most_sk(sk)->mdev) {
+		err = -EALREADY;
+		goto done;
+	}
+
+	if (channel_in_use(maddr->most_dev, maddr->rx_channel) ||
+		channel_in_use(maddr->most_dev, maddr->tx_channel)) {
+		err = -EADDRINUSE;
+		goto done;
+	} else {
+		most_sk(sk)->rx_channel = maddr->rx_channel;
+		most_sk(sk)->tx_channel = maddr->tx_channel;
+	}
+
+	mdev = most_dev_get(maddr->most_dev);
+	if (!mdev) {
+		err = -ENODEV;
+		goto done;
+	}
+
+	err = most_configure_channels(mdev, most_sk(sk), 1);
+	if (err) {
+		most_dev_put(mdev);
+		goto done;
+	}
+
+	most_sk(sk)->mdev = mdev;
+	most_sk(sk)->dev_id = mdev->id;
+
+	sk->sk_state = MOST_BOUND;
+
+done:
+	release_sock(sk);
+	return err;
+}
+
+
+static int most_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	pr_debug("%s\n", __func__);
+	return -EINVAL;
+}
+
+static int most_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+				struct msghdr *msg, size_t len, int flags)
+{
+	int noblock = flags & MSG_DONTWAIT;
+	struct sock *sk = sock->sk;
+	struct sk_buff *skb;
+	int copied, err;
+
+	pr_debug("%s\n", __func__);
+
+	if (most_sk(sk)->rx_channel == MOST_NO_CHANNEL)
+		return -EOPNOTSUPP;
+
+	if (flags & (MSG_OOB))
+		return -EOPNOTSUPP;
+
+	if (sk->sk_state != MOST_BOUND)
+		return 0;
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		return err;
+
+	msg->msg_namelen = 0;
+
+	copied = skb->len;
+	if (len < copied) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+
+	skb_reset_transport_header(skb);
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+
+	skb_free_datagram(sk, skb);
+
+	return err ? : copied;
+}
+
+static int most_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+			     struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct most_dev *mdev;
+	struct sk_buff *skb;
+	int err;
+
+	pr_debug("%s: sock %p sk %p, channeltype: %d\n",
+		__func__, sock, sk, most_sk(sk)->channel_type);
+
+	if (most_sk(sk)->tx_channel == MOST_NO_CHANNEL)
+		return -EOPNOTSUPP;
+
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_NOSIGNAL|MSG_ERRQUEUE))
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	mdev = most_sk(sk)->mdev;
+	if (!mdev) {
+		err = -EBADFD;
+		goto done;
+	}
+
+	skb = sock_alloc_send_skb(sk, len, msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
+		goto done;
+
+	most_cb(skb)->channel = most_sk(sk)->tx_channel;
+	most_cb(skb)->channel_type = most_sk(sk)->channel_type;
+
+	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+		err = -EFAULT;
+		goto drop;
+	}
+
+	skb->dev = (void *) mdev;
+
+	skb_queue_tail(&mdev->ctl_q, skb);
+	most_sched_tx(mdev);
+
+	err = len;
+
+done:
+	release_sock(sk);
+	return err;
+
+drop:
+	kfree_skb(skb);
+	goto done;
+}
+
+static int most_sock_setsockopt(struct socket *sock, int level, int optname,
+				char __user *optval, unsigned int optlen)
+{
+	struct sock *sk = sock->sk;
+	int err = 0;
+
+	pr_debug("%s: sk %p", __func__, sk);
+
+	lock_sock(sk);
+
+	switch (optname) {
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	}
+
+	release_sock(sk);
+	return err;
+}
+
+static int most_sock_getsockopt(struct socket *sock, int level, int optname,
+				char __user *optval, int __user *optlen)
+{
+	struct sock *sk = sock->sk;
+	int err = 0;
+
+	pr_debug("%s: sk %p", __func__, sk);
+
+	lock_sock(sk);
+
+	switch (optname) {
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	}
+
+	release_sock(sk);
+	return err;
+}
+
+static int most_sock_getname(struct socket *sock, struct sockaddr *addr,
+	int *addr_len, int peer)
+{
+	struct sockaddr_most *maddr = (struct sockaddr_most *)addr;
+	struct sock *sk = sock->sk;
+	struct most_dev *mdev = most_sk(sk)->mdev;
+
+	if (!mdev)
+		return -EBADFD;
+
+	lock_sock(sk);
+
+	*addr_len = sizeof(struct sockaddr_most);
+	maddr->most_family	= AF_MOST;
+	maddr->most_dev		= mdev->id;
+	/* FIXME dev_sock did not use rx and tx */
+	maddr->rx_channel	= most_sk(sk)->rx_channel;
+	maddr->tx_channel	= most_sk(sk)->tx_channel;
+
+	release_sock(sk);
+	return 0;
+}
+
+static const struct proto_ops most_sock_ops = {
+	.family		= PF_MOST,
+	.owner		= THIS_MODULE,
+	.release	= most_sock_release,
+	.bind		= most_sock_bind,
+	.getname	= most_sock_getname,
+	.sendmsg	= most_sock_sendmsg,
+	.recvmsg	= most_sock_recvmsg,
+	.ioctl		= most_sock_ioctl,
+	.poll		= datagram_poll,
+	.listen		= sock_no_listen,
+	.shutdown	= sock_no_shutdown,
+	.setsockopt	= most_sock_setsockopt,
+	.getsockopt	= most_sock_getsockopt,
+	.connect	= sock_no_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= sock_no_accept,
+	.mmap		= sock_no_mmap
+};
+
+
+static int dev_sock_ioctl(struct socket *sock, unsigned int cmd,
+	unsigned long arg)
+{
+	void __user *argp = (void __user *) arg;
+
+	switch (cmd) {
+	case MOSTDEVUP:
+		return most_open_dev(arg & 0xffff);
+	case MOSTDEVDOWN:
+		return most_close_dev(arg & 0xffff);
+	case MOSTGETDEVLIST:
+		return most_get_dev_list(argp);
+	default:
+		return -EINVAL;
+	}
+}
+
+static int dev_sock_bind(struct socket *sock, struct sockaddr *addr,
+	int addr_len)
+{
+	return -ENOSYS;
+}
+
+static int dev_sock_setsockopt(struct socket *sock, int level, int optname,
+	char __user *optval, unsigned int optlen)
+{
+	return -ENOSYS;
+}
+
+static int dev_sock_getsockopt(struct socket *sock, int level, int optname,
+	char __user *optval, int __user *optlen)
+{
+	return -ENOSYS;
+}
+
+static const struct proto_ops dev_sock_ops = {
+	.family		= PF_MOST,
+	.owner		= THIS_MODULE,
+	.release	= most_sock_release,
+	.bind		= dev_sock_bind,
+	.getname	= most_sock_getname,
+	.sendmsg	= sock_no_sendmsg,
+	.recvmsg	= sock_no_recvmsg,
+	.ioctl		= dev_sock_ioctl,
+	.poll		= sock_no_poll,
+	.listen		= sock_no_listen,
+	.shutdown	= sock_no_shutdown,
+	.setsockopt	= dev_sock_setsockopt,
+	.getsockopt	= dev_sock_getsockopt,
+	.connect	= sock_no_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= sock_no_accept,
+	.mmap		= sock_no_mmap
+};
+
+int ctl_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+			    struct msghdr *msg, size_t len)
+{
+	if (len != CTL_FRAME_SIZE)
+		return -EINVAL;
+
+	return most_sock_sendmsg(iocb, sock, msg, len);
+}
+
+static const struct proto_ops ctl_sock_ops = {
+	.family		= PF_MOST,
+	.owner		= THIS_MODULE,
+	.release	= most_sock_release,
+	.bind		= most_sock_bind,
+	.getname	= most_sock_getname,
+	.sendmsg	= most_sock_sendmsg,
+	.recvmsg	= most_sock_recvmsg,
+	.ioctl		= most_sock_ioctl,
+	.poll		= datagram_poll,
+	.listen		= sock_no_listen,
+	.shutdown	= sock_no_shutdown,
+	.setsockopt	= most_sock_setsockopt,
+	.getsockopt	= most_sock_getsockopt,
+	.connect	= sock_no_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= sock_no_accept,
+	.mmap		= sock_no_mmap
+};
+
+
+/* * * * * * * * * * * * * * SOCKET CREATION * * * * * * * * * * * * */
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+static struct lock_class_key most_lock_key[MOST_MAX_PROTO];
+static const char *most_key_strings[MOST_MAX_PROTO] = {
+	"sk_lock-AF_MOST-MOSTPROTO_DEV",
+	"sk_lock-AF_MOST-MOSTPROTO_CTL",
+	"sk_lock-AF_MOST-MOSTPROTO_SYNC",
+	"sk_lock-AF_MOST-MOSTPROTO_ASYNC",
+};
+
+static struct lock_class_key most_slock_key[MOST_MAX_PROTO];
+static const char *most_slock_key_strings[MOST_MAX_PROTO] = {
+	"slock-AF_MOST-MOSTPROTO_DEV",
+	"slock-AF_MOST-MOSTPROTO_CTL",
+	"slock-AF_MOST-MOSTPROTO_SYNC",
+	"slock-AF_MOST-MOSTPROTO_ASYNC",
+};
+
+static inline void most_sock_reclassify_lock(struct socket *sock, int proto)
+{
+	struct sock *sk = sock->sk;
+
+	if (!sk)
+		return;
+
+	BUG_ON(sock_owned_by_user(sk));
+
+	sock_lock_init_class_and_name(sk,
+			most_slock_key_strings[proto], &most_slock_key[proto],
+				most_key_strings[proto], &most_lock_key[proto]);
+}
+#else
+static inline void most_sock_reclassify_lock(struct socket *sock, int proto)
+{
+}
+#endif
+
+
+static int most_sock_create(struct net *net, struct socket *sock, int proto,
+	int kern)
+{
+	if (net != &init_net)
+		return -EAFNOSUPPORT;
+
+	if (proto < 0 || proto >= MOST_MAX_PROTO)
+		return -EINVAL;
+
+	most_net_proto_family_ops[proto].create(net, sock, proto, kern);
+	most_sock_reclassify_lock(sock, proto);
+
+	return 0;
+}
+
+static struct net_proto_family most_sock_family_ops = {
+	.owner	= THIS_MODULE,
+	.family	= PF_MOST,
+	.create	= most_sock_create,
+};
+
+static int dev_sock_create(struct net *net, struct socket *sock, int protocol,
+	int kern)
+{
+	struct sock *sk;
+
+	if (sock->type != SOCK_RAW)
+		return -ESOCKTNOSUPPORT;
+
+	sock->ops = &dev_sock_ops;
+
+	sk = most_sk_alloc(net, &most_proto[CHAN_DEV], CHAN_DEV);
+	if (!sk)
+		return -ENOMEM;
+
+	sock_init_data(sock, sk);
+
+	sock_reset_flag(sk, SOCK_ZAPPED);
+
+	sk->sk_protocol = protocol;
+
+	sock->state = SS_UNCONNECTED;
+	sk->sk_state = MOST_OPEN;
+
+	most_sock_link(sk);
+	return 0;
+}
+
+static int ctl_sock_create(struct net *net, struct socket *sock, int protocol,
+	int kern)
+{
+	struct sock *sk;
+
+	if (sock->type != SOCK_RAW)
+		return -ESOCKTNOSUPPORT;
+
+	sock->ops = &ctl_sock_ops;
+
+	sk = most_sk_alloc(net, &most_proto[CHAN_CTL], CHAN_CTL);
+	if (!sk)
+		return -ENOMEM;
+
+	sock_init_data(sock, sk);
+
+	sock_reset_flag(sk, SOCK_ZAPPED);
+
+	sk->sk_protocol = protocol;
+
+	sock->state = SS_UNCONNECTED;
+	sk->sk_state = MOST_OPEN;
+
+	most_sock_link(sk);
+	return 0;
+}
+
+static int sync_sock_create(struct net *net, struct socket *sock, int protocol,
+	int kern)
+{
+	struct sock *sk;
+
+	if (sock->type != SOCK_STREAM)
+		return -ESOCKTNOSUPPORT;
+
+	sock->ops = &most_sock_ops;
+
+	sk = most_sk_alloc(net, &most_proto[CHAN_SYNC], CHAN_SYNC);
+	if (!sk)
+		return -ENOMEM;
+
+	sock_init_data(sock, sk);
+
+	sock_reset_flag(sk, SOCK_ZAPPED);
+
+	sk->sk_protocol = protocol;
+
+	sock->state = SS_UNCONNECTED;
+	sk->sk_state = MOST_OPEN;
+
+	most_sock_link(sk);
+	return 0;
+}
+
+static int async_sock_create(struct net *net, struct socket *sock, int protocol,
+	int kern)
+{
+	struct sock *sk;
+
+	if (sock->type != SOCK_DGRAM)
+		return -ESOCKTNOSUPPORT;
+
+	sock->ops = &most_sock_ops;
+
+	sk = most_sk_alloc(net, &most_proto[CHAN_ASYNC], CHAN_ASYNC);
+	if (!sk)
+		return -ENOMEM;
+
+	sock_init_data(sock, sk);
+
+	sock_reset_flag(sk, SOCK_ZAPPED);
+
+	sk->sk_protocol = protocol;
+
+	sock->state = SS_UNCONNECTED;
+	sk->sk_state = MOST_OPEN;
+
+	most_sock_link(sk);
+	return 0;
+}
+
+
+/* * * * * * * * * * * * * * DEVICE REGISTRATION * * * * * * * * * * * * */
+
+int most_open_dev(u16 dev_id)
+{
+	struct most_dev *mdev = most_dev_get(dev_id);
+	int err = 0;
+
+	if (!mdev)
+		return -ENODEV;
+
+	pr_debug("%s: %s, state: %d\n", __func__, mdev->name, mdev->state);
+
+	if (mdev->state == MOST_DEV_UP)
+		err = -EALREADY;
+
+	if (!err)
+		err = mdev->open(mdev);
+	if (!err)
+		mdev->state = MOST_DEV_UP;
+
+	most_dev_put(mdev);
+	pr_debug("%s: %s, state: %d, err: %d\n", __func__,
+		mdev->name, mdev->state, err);
+	return err;
+}
+
+static int __most_close_dev(struct most_dev *mdev)
+{
+	int err = 0;
+
+	pr_debug("%s: %s, state: %d\n", __func__, mdev ? mdev->name : "nil",
+		mdev ? mdev->state : -1);
+
+	if (!mdev)
+		return -ENODEV;
+
+	if (mdev->state == MOST_DEV_DOWN)
+		err = -EALREADY;
+
+	if (!err)
+		err = mdev->close(mdev);
+	if (!err)
+		mdev->state = MOST_DEV_DOWN;
+
+	most_dev_put(mdev);
+	pr_debug("%s: %s, state: %d, err: %d\n", __func__,
+		mdev->name, mdev->state, err);
+	return err;
+}
+
+int most_close_dev(u16 dev_id)
+{
+	return __most_close_dev(most_dev_get(dev_id));
+}
+
+int most_get_dev_list(void __user *arg)
+{
+	struct most_dev_list_req *dl;
+	struct most_dev_req *dr;
+	struct list_head *p;
+	int n = 0, size, err;
+	u16 dev_num;
+
+	if (get_user(dev_num, (u16 __user *) arg))
+		return -EFAULT;
+
+	if (!dev_num || dev_num > (PAGE_SIZE * 2) / sizeof(*dr))
+		return -EINVAL;
+
+	size = sizeof(*dl) + dev_num * sizeof(*dr);
+
+	dl = kzalloc(size, GFP_KERNEL);
+	if (!dl)
+		return -ENOMEM;
+
+	dr = dl->dev_req;
+
+	read_lock_bh(&most_dev_list_lock);
+	list_for_each(p, &most_dev_list) {
+		struct most_dev *mdev;
+		mdev = list_entry(p, struct most_dev, list);
+		(dr + n)->dev_id  = mdev->id;
+		if (++n >= dev_num)
+			break;
+	}
+	read_unlock_bh(&most_dev_list_lock);
+
+	dl->dev_num = n;
+	size = sizeof(*dl) + n * sizeof(*dr);
+
+	err = copy_to_user(arg, dl, size);
+	kfree(dl);
+
+	return err ? -EFAULT : 0;
+}
+
+static int most_send_frame(struct sk_buff *skb)
+{
+	struct most_dev *mdev = (struct most_dev *) skb->dev;
+
+	if (!mdev) {
+		kfree_skb(skb);
+		return -ENODEV;
+	}
+
+	pr_debug("%s: %s type %d len %d\n", __func__, mdev->name,
+		most_cb(skb)->channel_type, skb->len);
+
+	/* Get rid of skb owner, prior to sending to the driver. */
+	skb_orphan(skb);
+
+	return mdev->send(skb);
+}
+
+static void most_send_queue(struct sk_buff_head *q)
+{
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(q))) {
+		struct most_dev *mdev = (struct most_dev *)skb->dev;
+
+		pr_debug("%s: skb %p len %d\n", __func__, skb, skb->len);
+
+		if (!mdev->can_send || mdev->can_send(skb))
+			most_send_frame(skb);
+		else {
+			pr_debug("%s, could not send frame, requeueing\n",
+				__func__);
+			skb_queue_tail(q, skb);
+			break;
+		}
+	}
+}
+
+static void most_tx_task(unsigned long arg)
+{
+	struct most_dev *mdev = (struct most_dev *) arg;
+
+	pr_debug("%s: %s\n", __func__, mdev->name);
+
+	most_send_queue(&mdev->ctl_q);
+	most_send_queue(&mdev->sync_q);
+	most_send_queue(&mdev->async_q);
+}
+
+static void most_rx_task(unsigned long arg)
+{
+	struct most_dev *mdev = (struct most_dev *) arg;
+	struct sk_buff *skb = skb_dequeue(&mdev->rx_q);
+
+	pr_debug("%s: %s\n", __func__, mdev->name);
+
+	while (skb) {
+		/* Send to the sockets */
+		most_send_to_sock(mdev->id, skb);
+		kfree_skb(skb);
+		skb = skb_dequeue(&mdev->rx_q);
+	}
+}
+
+
+/* Get MOST device by index.
+ * Device is held on return. */
+struct most_dev *most_dev_get(int index)
+{
+	struct most_dev *mdev = NULL;
+	struct list_head *p;
+
+	if (index < 0)
+		return NULL;
+
+	read_lock(&most_dev_list_lock);
+	list_for_each(p, &most_dev_list) {
+		struct most_dev *d = list_entry(p, struct most_dev, list);
+		if (d->id == index) {
+			mdev = most_dev_hold(d);
+			break;
+		}
+	}
+	read_unlock(&most_dev_list_lock);
+	return mdev;
+}
+EXPORT_SYMBOL(most_dev_get);
+
+
+/* Alloc MOST device */
+struct most_dev *most_alloc_dev(void)
+{
+	struct most_dev *mdev;
+
+	mdev = kzalloc(sizeof(struct most_dev), GFP_KERNEL);
+	if (!mdev)
+		return NULL;
+
+	mdev->state = MOST_DEV_DOWN;
+
+	return mdev;
+}
+EXPORT_SYMBOL(most_alloc_dev);
+
+
+void most_free_dev(struct most_dev *mdev)
+{
+	kfree(mdev);
+}
+EXPORT_SYMBOL(most_free_dev);
+
+
+/* Register MOST device */
+int most_register_dev(struct most_dev *mdev)
+{
+	struct list_head *head = &most_dev_list, *p;
+	int id = 0;
+
+	if (!mdev->open || !mdev->close || !mdev->send)
+		return -EINVAL;
+
+	write_lock_bh(&most_dev_list_lock);
+
+	/* Find first available device id */
+	list_for_each(p, &most_dev_list) {
+		if (list_entry(p, struct most_dev, list)->id != id)
+			break;
+		head = p; id++;
+	}
+
+	sprintf(mdev->name, "most%d", id);
+	mdev->id = id;
+	list_add(&mdev->list, head);
+
+	tasklet_init(&mdev->rx_task, most_rx_task, (unsigned long) mdev);
+	tasklet_init(&mdev->tx_task, most_tx_task, (unsigned long) mdev);
+
+	skb_queue_head_init(&mdev->rx_q);
+	skb_queue_head_init(&mdev->ctl_q);
+	skb_queue_head_init(&mdev->sync_q);
+	skb_queue_head_init(&mdev->async_q);
+
+	write_unlock_bh(&most_dev_list_lock);
+	return 0;
+}
+EXPORT_SYMBOL(most_register_dev);
+
+int most_unregister_dev(struct most_dev *mdev)
+{
+	int ret = 0;
+	pr_debug("%s: %s: state: %d\n", __func__, mdev->name, mdev->state);
+
+	if (mdev->state != MOST_DEV_DOWN)
+		ret = __most_close_dev(mdev);
+
+	write_lock_bh(&most_dev_list_lock);
+	list_del(&mdev->list);
+	write_unlock_bh(&most_dev_list_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(most_unregister_dev);
+
+
+static struct net_proto_family most_net_proto_family_ops[] = {
+	{
+		.family	= PF_MOST,
+		.owner	= THIS_MODULE,
+		.create	= dev_sock_create,
+	},
+	{
+		.family	= PF_MOST,
+		.owner	= THIS_MODULE,
+		.create	= ctl_sock_create,
+	},
+	{
+		.family	= PF_MOST,
+		.owner	= THIS_MODULE,
+		.create	= sync_sock_create,
+	},
+	{
+		.family	= PF_MOST,
+		.owner	= THIS_MODULE,
+		.create	= async_sock_create,
+	}
+};
+
+static struct proto most_proto[] = {
+	{
+		.name		= "DEV",
+		.owner		= THIS_MODULE,
+		.obj_size	= sizeof(struct most_sock)
+	},
+	{
+		.name		= "CTL",
+		.owner		= THIS_MODULE,
+		.obj_size	= sizeof(struct most_sock)
+	},
+	{
+		.name		= "SYNC",
+		.owner		= THIS_MODULE,
+		.obj_size	= sizeof(struct most_sock)
+	},
+	{
+		.name		= "ASYNC",
+		.owner		= THIS_MODULE,
+		.obj_size	= sizeof(struct most_sock)
+	}
+};
+
+static int __init most_init(void)
+{
+	int i, err;
+
+	err = sock_register(&most_sock_family_ops);
+	if (err < 0)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(most_proto); ++i) {
+		err = proto_register(&most_proto[i], 0);
+		if (err)
+			goto out;
+	}
+
+	pr_info(KERN_INFO "MOST is initialized\n");
+
+	return 0;
+out:
+	while (--i >= 0)
+		proto_unregister(&most_proto[i]);
+
+	return err;
+}
+
+static void __exit most_exit(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(most_proto); ++i)
+		proto_unregister(&most_proto[i]);
+
+	sock_unregister(PF_MOST);
+}
+
+subsys_initcall(most_init);
+module_exit(most_exit);
+
+MODULE_DESCRIPTION("MOST Core");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS_NETPROTO(PF_MOST);
-- 
1.7.7.2
