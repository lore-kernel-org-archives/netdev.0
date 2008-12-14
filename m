From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH] AF_VMCHANNEL address family for guest<->host communication.
Date: Sun, 14 Dec 2008 13:50:55 +0200
Message-ID: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40896 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424AbYLNLuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2008 06:50:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a need for communication channel between host and various
agents that are running inside a VM guest. The channel will be used
for statistic gathering, logging, cut & paste, host screen resolution
changes notifications, guest configuration etc.

It is undesirable to use TCP/IP for this purpose since network
connectivity may not exist between host and guest and if it exists the
traffic can be not routable between host and guest for security reasons
or TCP/IP traffic can be firewalled (by mistake) by unsuspecting VM user.

This patch implement new address family AF_VMCHANNEL that is used
for communication between guest and host. Channels are created at VM
start time. Each channel has a name. Agent, that runs on a guest, can
send/receive data to/from a channel by creating AF_VMCHANNEL socket and
connecting to a channel using channels name as an address.

Only stream sockets are supported by this implementation. Also only
connect, sendmsg and recvmsg socket ops are implemented which is enough
to allow application running in a guest to connect to a channel created
by a host and read/write from/to the channel. This can be extended to
allow channel creation from inside a guest by creating listen socket and
accepting on it if the need will arise and thus even allow guest<->guest
communication in the future (but TCP/IP may be preferable for this).

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---

 include/linux/socket.h       |    4 
 include/linux/vmchannel.h    |   54 +++
 net/Kconfig                  |    1 
 net/Makefile                 |    1 
 net/vmchannel/Kconfig        |   11 +
 net/vmchannel/Makefile       |    5 
 net/vmchannel/af_vmchannel.c |  769 ++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 844 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/vmchannel.h
 create mode 100644 net/vmchannel/Kconfig
 create mode 100644 net/vmchannel/Makefile
 create mode 100644 net/vmchannel/af_vmchannel.c

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 20fc4bb..e65834c 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -191,7 +191,8 @@ struct ucred {
 #define AF_RXRPC	33	/* RxRPC sockets 		*/
 #define AF_ISDN		34	/* mISDN sockets 		*/
 #define AF_PHONET	35	/* Phonet sockets		*/
-#define AF_MAX		36	/* For now.. */
+#define AF_VMCHANNEL	36	/* Vmchannel sockets		*/
+#define AF_MAX		37	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -229,6 +230,7 @@ struct ucred {
 #define PF_RXRPC	AF_RXRPC
 #define PF_ISDN		AF_ISDN
 #define PF_PHONET	AF_PHONET
+#define PF_VMCHANNEL	AF_VMCHANNEL
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/linux/vmchannel.h b/include/linux/vmchannel.h
new file mode 100644
index 0000000..27c1f94
--- /dev/null
+++ b/include/linux/vmchannel.h
@@ -0,0 +1,54 @@
+/*
+ *  Copyright 2008 Red Hat, Inc --- All Rights Reserved
+ *
+ *  Author(s): Gleb Natapov <gleb@redhat.com>
+ */
+
+#ifndef VMCHANNEL_H
+#define VMCHANNEL_H
+
+#define VMCHANNEL_NAME_MAX 80
+struct sockaddr_vmchannel {
+	sa_family_t svmchannel_family;
+	char svmchannel_name[VMCHANNEL_NAME_MAX];
+};
+
+#ifdef __KERNEL__
+
+#define VIRTIO_ID_VMCHANNEL 6
+#define VMCHANNEL_BAD_ID (~(__u32)0)
+
+#define vmchannel_sk(__sk) ((struct vmchannel_sock *) __sk)
+
+struct vmchannel_sock {
+	struct sock sk;
+	char name[VMCHANNEL_NAME_MAX];
+	__u32 id;
+	struct sk_buff_head backlog_skb_q;
+};
+
+struct vmchannel_info {
+	__u32 id;
+	char *name;
+};
+
+struct vmchannel_dev {
+	struct virtio_device *vdev;
+	struct virtqueue *rq;
+	struct virtqueue *sq;
+	struct tasklet_struct rx_tasklet;
+	struct tasklet_struct tx_tasklet;
+	__u32 channel_count;
+	struct vmchannel_info *channels;
+	struct sk_buff_head rx_skbuff_q;
+	struct sk_buff_head tx_skbuff_q;
+	atomic_t recv_posted;
+};
+
+struct vmchannel_desc {
+	__u32 id;
+	__le32 len;
+};
+
+#endif /* __KERNEL__ */
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index d789d79..d01f135 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -36,6 +36,7 @@ source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
 source "net/iucv/Kconfig"
+source "net/vmchannel/Kconfig"
 
 config INET
 	bool "TCP/IP networking"
diff --git a/net/Makefile b/net/Makefile
index 27d1f10..ddc89dc 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
 obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
+obj-$(CONFIG_VMCHANNEL)		+= vmchannel/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
 
diff --git a/net/vmchannel/Kconfig b/net/vmchannel/Kconfig
new file mode 100644
index 0000000..53f256a
--- /dev/null
+++ b/net/vmchannel/Kconfig
@@ -0,0 +1,11 @@
+#
+# VMCHANNEL address family
+#
+
+config VMCHANNEL
+	tristate "AF_VMCHANNEL address family (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && VIRTIO
+
+	---help---
+	  AF_VMCHANNEL family is used for communication between host and guest.
+	  Say Y or M if you are going to run this kernel in a VM.
diff --git a/net/vmchannel/Makefile b/net/vmchannel/Makefile
new file mode 100644
index 0000000..f972fc4
--- /dev/null
+++ b/net/vmchannel/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the vmchannel AF.
+#
+
+obj-$(CONFIG_VMCHANNEL) += af_vmchannel.o
diff --git a/net/vmchannel/af_vmchannel.c b/net/vmchannel/af_vmchannel.c
new file mode 100644
index 0000000..ac87b31
--- /dev/null
+++ b/net/vmchannel/af_vmchannel.c
@@ -0,0 +1,769 @@
+/*
+ *  Copyright 2008 Red Hat, Inc --- All Rights Reserved
+ *
+ *  Author(s): Gleb Natapov <gleb@redhat.com>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/poll.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <linux/kmod.h>
+#include <linux/virtio.h>
+#include <linux/virtio_config.h>
+#include <linux/vmchannel.h>
+
+static int max_ring_len = 1000;
+static int max_packet_len = 1024;
+
+module_param(max_ring_len, int, 0444);
+module_param(max_packet_len, int, 0444);
+
+static struct vmchannel_dev vmc_dev;
+
+static int vmchannel_send_skb(struct sk_buff *skb, const __u32 id);
+static __u32 vmchannel_find_channel_id(const char *name);
+
+static struct proto vmchannel_proto = {
+	.name           = "AF_VMCHANNEL",
+	.owner          = THIS_MODULE,
+	.obj_size       = sizeof(struct vmchannel_sock),
+};
+
+static struct vmchannel_sock_list {
+	struct hlist_head head;
+	spinlock_t lock;
+} vmchannel_sk_list = {
+	.lock = __SPIN_LOCK_UNLOCKED(vmchannel_sk_list.lock)
+};
+
+static void vmchannel_sock_link(struct vmchannel_sock_list *l, struct sock *sk)
+{
+	spin_lock_bh(&l->lock);
+	sk_add_node(sk, &l->head);
+	spin_unlock_bh(&l->lock);
+}
+
+static void vmchannel_sock_unlink(struct vmchannel_sock_list *l,
+		struct sock *sk)
+{
+	spin_lock_bh(&l->lock);
+	sk_del_node_init(sk);
+	spin_unlock_bh(&l->lock);
+}
+
+static struct sock *__vmchannel_get_sock_by_name(const char *nm)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+
+	sk_for_each(sk, node, &vmchannel_sk_list.head) {
+		struct vmchannel_sock *vmc = vmchannel_sk(sk);
+		if (!strncmp(vmc->name, nm, VMCHANNEL_NAME_MAX))
+			return sk;
+	}
+
+	return NULL;
+}
+
+static struct sock *vmchannel_get_sock_by_id(const __u32 id)
+{
+	struct sock *sk = NULL;
+	struct hlist_node *node;
+
+	spin_lock(&vmchannel_sk_list.lock);
+
+	sk_for_each(sk, node, &vmchannel_sk_list.head) {
+		struct vmchannel_sock *vmc = vmchannel_sk(sk);
+		if (vmc->id == id)
+			break;
+	}
+
+	if (sk)
+		sock_hold(sk);
+
+	spin_unlock(&vmchannel_sk_list.lock);
+
+	return sk;
+}
+
+static int vmchannel_address_valid(struct sockaddr *addr, int alen)
+{
+	return addr && (alen >= sizeof(struct sockaddr_vmchannel)) &&
+		addr->sa_family == AF_VMCHANNEL;
+}
+
+/* vmchannel socket OPS */
+static int vmchannel_sock_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct vmchannel_sock *vmc = vmchannel_sk(sk);
+
+	if (!sk)
+		return 0;
+
+	vmchannel_sock_unlink(&vmchannel_sk_list, sk);
+
+	sock_orphan(sk);
+	lock_sock(sk);
+	if (sk->sk_state == TCP_ESTABLISHED) {
+		sk->sk_state = TCP_CLOSE;
+		sk->sk_shutdown |= SEND_SHUTDOWN | RCV_SHUTDOWN;
+		sk->sk_err = ECONNRESET;
+		sk->sk_state_change(sk);
+		skb_queue_purge(&vmc->backlog_skb_q);
+	}
+	release_sock(sk);
+	sock_put(sk);
+	return 0;
+}
+
+/* Bind an unbound socket */
+static int vmchannel_sock_bind(struct socket *sock, struct sockaddr *addr,
+		int alen)
+{
+	struct sockaddr_vmchannel *sa = (struct sockaddr_vmchannel *)addr;
+	struct sock *sk = sock->sk;
+	struct vmchannel_sock *vmc;
+	uint32_t id;
+	int err;
+
+	/* Verify the input sockaddr */
+	if (!vmchannel_address_valid(addr, alen))
+		return -EINVAL;
+
+	id = vmchannel_find_channel_id(sa->svmchannel_name);
+
+	if (id == VMCHANNEL_BAD_ID)
+		return -EADDRNOTAVAIL;
+
+	lock_sock(sk);
+	if (!sock_flag(sk, SOCK_ZAPPED)) {
+		err = -EBADFD;
+		goto done;
+	}
+
+	spin_lock_bh(&vmchannel_sk_list.lock);
+
+	if (__vmchannel_get_sock_by_name(sa->svmchannel_name)) {
+		err = -EADDRINUSE;
+		goto done_unlock;
+	}
+
+	vmc = vmchannel_sk(sk);
+
+	/* Bind the socket */
+	memcpy(vmc->name, sa->svmchannel_name, VMCHANNEL_NAME_MAX);
+	vmc->id = id;
+	sock_reset_flag(sk, SOCK_ZAPPED);
+	err = 0;
+
+done_unlock:
+	/* Release the socket list lock */
+	spin_unlock_bh(&vmchannel_sk_list.lock);
+done:
+	release_sock(sk);
+	return err;
+}
+
+static int vmchannel_sock_connect(struct socket *sock, struct sockaddr *addr,
+		int alen, int flags)
+{
+	struct sock *sk = sock->sk;
+	int err;
+
+	if (!vmchannel_address_valid(addr, alen))
+		return -EINVAL;
+
+	if (sk->sk_type != SOCK_STREAM)
+		return -EINVAL;
+
+	if (sock_flag(sk, SOCK_ZAPPED)) {
+		err = vmchannel_sock_bind(sock, addr, alen);
+		if (unlikely(err))
+			return err;
+	}
+
+	lock_sock(sk);
+	sk->sk_state = TCP_ESTABLISHED;
+	sock->state = SS_CONNECTED;
+	sk->sk_state_change(sk);
+	release_sock(sk);
+
+	return 0;
+}
+
+static int vmchannel_sock_getname(struct socket *sock, struct sockaddr *addr,
+		int *len, int peer)
+{
+	struct sockaddr_vmchannel *svmc = (struct sockaddr_vmchannel *)addr;
+	struct sock *sk = sock->sk;
+
+	addr->sa_family = AF_VMCHANNEL;
+	*len = sizeof(struct sockaddr_vmchannel);
+
+	memcpy(svmc->svmchannel_name, vmchannel_sk(sk)->name,
+			VMCHANNEL_NAME_MAX);
+
+	return 0;
+}
+
+static int vmchannel_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct vmchannel_sock *vmc = vmchannel_sk(sk);
+	struct sk_buff *skb;
+	int err;
+
+	err = sock_error(sk);
+	if (err)
+		return err;
+
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	if (sk->sk_shutdown & SEND_SHUTDOWN) {
+		send_sig(SIGPIPE, current, 0);
+		return -EPIPE;
+	}
+
+	if (sk->sk_state != TCP_ESTABLISHED)
+		return -ENOTCONN;
+
+	skb = sock_alloc_send_skb(sk, len, msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
+		return err;
+
+	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+		err = -EFAULT;
+		goto free_skb;
+	}
+
+	err = vmchannel_send_skb(skb, vmc->id);
+	if (err) {
+		err = -EPIPE;
+		goto free_skb;
+	}
+
+	return len;
+
+free_skb:
+	kfree_skb(skb);
+	return err;
+}
+
+static int vmchannel_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *msg, size_t len, int flags)
+{
+	int noblock = flags & MSG_DONTWAIT;
+	struct sock *sk = sock->sk;
+	struct vmchannel_sock *vmc = vmchannel_sk(sk);
+	int target, copied = 0, chunk;
+	struct sk_buff *skb;
+	int err;
+
+	if (flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	if (sk->sk_state != TCP_ESTABLISHED)
+		return -EINVAL;
+
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);
+
+	do {
+		spin_lock_bh(&vmc->backlog_skb_q.lock);
+		while ((skb = __skb_dequeue(&vmc->backlog_skb_q))) {
+			if (sock_queue_rcv_skb(sk, skb)) {
+				__skb_queue_head(&vmc->backlog_skb_q, skb);
+				break;
+			}
+			atomic_dec(&vmc_dev.recv_posted);
+		}
+		spin_unlock_bh(&vmc->backlog_skb_q.lock);
+
+		BUG_ON(atomic_read(&vmc_dev.recv_posted) < 0);
+
+		/* this will repost buffers */
+		if (atomic_read(&vmc_dev.recv_posted) < max_ring_len / 2)
+			tasklet_schedule(&vmc_dev.rx_tasklet);
+
+		skb = skb_recv_datagram(sk, flags, noblock, &err);
+		if (!skb) {
+			if (sk->sk_shutdown & RCV_SHUTDOWN)
+				err = 0;
+			return err;
+		}
+
+		chunk = min_t(unsigned int, skb->len, len);
+
+		err = memcpy_toiovec(msg->msg_iov, skb->data, chunk);
+		if (err) {
+			if (!(flags & MSG_PEEK))
+				skb_queue_head(&sk->sk_receive_queue, skb);
+			else
+				kfree_skb(skb);
+
+			if (copied != 0)
+				return copied;
+			return err;
+		}
+
+		copied += chunk;
+		len -= chunk;
+
+		if (flags & MSG_PEEK) {
+			kfree_skb(skb);
+			break;
+		}
+
+		/* Mark read part of skb as used */
+		skb_pull(skb, chunk);
+
+		if (skb->len) {
+			skb_queue_head(&sk->sk_receive_queue, skb);
+			break;
+		}
+
+		kfree_skb(skb);
+	} while (copied < target);
+
+	return copied;
+}
+
+static int vmchannel_sock_shutdown(struct socket *sock, int mode)
+{
+	struct sock *sk = sock->sk;
+	int err = 0;
+
+	mode = (mode + 1) & (RCV_SHUTDOWN | SEND_SHUTDOWN);
+
+	lock_sock(sk);
+	if (sk->sk_state == TCP_CLOSE) {
+		err = -ENOTCONN;
+		goto unlock;
+	}
+
+	sk->sk_shutdown |= mode;
+
+	if (mode & RCV_SHUTDOWN) {
+		skb_queue_purge(&sk->sk_receive_queue);
+		skb_queue_purge(&vmchannel_sk(sk)->backlog_skb_q);
+	}
+
+	/* Wake up anyone sleeping in poll */
+	sk->sk_state_change(sk);
+
+unlock:
+	release_sock(sk);
+	return err;
+}
+
+static struct proto_ops vmchannel_sock_ops = {
+	.family         = PF_VMCHANNEL,
+	.owner          = THIS_MODULE,
+	.release        = vmchannel_sock_release,
+	.bind           = vmchannel_sock_bind,
+	.connect        = vmchannel_sock_connect,
+	.listen         = sock_no_listen,
+	.accept         = sock_no_accept,
+	.getname        = vmchannel_sock_getname,
+	.sendmsg        = vmchannel_sock_sendmsg,
+	.recvmsg        = vmchannel_sock_recvmsg,
+	.poll           = datagram_poll,
+	.ioctl          = sock_no_ioctl,
+	.mmap           = sock_no_mmap,
+	.socketpair     = sock_no_socketpair,
+	.shutdown       = vmchannel_sock_shutdown,
+	.setsockopt     = sock_no_setsockopt,
+	.getsockopt     = sock_no_getsockopt
+};
+
+static int vmchannel_socket_recv(struct sk_buff *skb, const __u32 id)
+{
+	struct sock *sk;
+	struct vmchannel_sock *vmc;
+	int ret = 0;
+
+	sk = vmchannel_get_sock_by_id(id);
+	if (!sk) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	if (sk->sk_state != TCP_ESTABLISHED ||
+			(sk->sk_shutdown & RCV_SHUTDOWN)) {
+		kfree_skb(skb);
+		goto unlock;
+	}
+
+	vmc = vmchannel_sk(sk);
+
+	spin_lock(&vmc->backlog_skb_q.lock);
+	if (!skb_queue_empty(&vmc->backlog_skb_q) ||
+			sock_queue_rcv_skb(sk, skb)) {
+		__skb_queue_tail(&vmc->backlog_skb_q, skb);
+		ret = 1;
+	}
+	spin_unlock(&vmc->backlog_skb_q.lock);
+unlock:
+	sock_put(sk);
+	return ret;
+}
+
+static void vmchannel_sock_destruct(struct sock *sk)
+{
+	skb_queue_purge(&sk->sk_receive_queue);
+	skb_queue_purge(&sk->sk_write_queue);
+}
+
+static struct sock *vmchannel_sock_alloc(struct socket *sock, int proto,
+		gfp_t prio)
+{
+	struct sock *sk;
+
+	sk = sk_alloc(&init_net, PF_VMCHANNEL, prio, &vmchannel_proto);
+
+	if (!sk)
+		return NULL;
+
+	sock_init_data(sock, sk);
+	skb_queue_head_init(&vmchannel_sk(sk)->backlog_skb_q);
+	sk->sk_destruct = vmchannel_sock_destruct;
+	sk->sk_protocol = proto;
+
+	vmchannel_sock_link(&vmchannel_sk_list, sk);
+
+	return sk;
+}
+
+static int vmchannel_sock_create(struct net *net, struct socket *sock,
+		int protocol)
+{
+	struct sock *sk;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (sock->type != SOCK_STREAM)
+		return -ESOCKTNOSUPPORT;
+
+	sock->state = SS_UNCONNECTED;
+	sock->ops = &vmchannel_sock_ops;
+
+	sk = vmchannel_sock_alloc(sock, protocol, GFP_KERNEL);
+	if (!sk)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static struct net_proto_family vmchannel_sock_family_ops = {
+	.family = AF_VMCHANNEL,
+	.owner  = THIS_MODULE,
+	.create = vmchannel_sock_create,
+};
+
+/* vmchannel device functions */
+static __u32 vmchannel_find_channel_id(const char *name)
+{
+	__u32 id = VMCHANNEL_BAD_ID;
+	int i;
+
+	for (i = 0; i < vmc_dev.channel_count; i++) {
+		if (!strncmp(name, vmc_dev.channels[i].name,
+					VMCHANNEL_NAME_MAX)) {
+			id = vmc_dev.channels[i].id;
+			break;
+		}
+	}
+
+	return id;
+}
+
+static inline struct vmchannel_desc *skb_vmchannel_desc(struct sk_buff *skb)
+{
+	return (struct vmchannel_desc *)skb->cb;
+}
+
+static inline void vmchannel_desc_to_sg(struct scatterlist *sg,
+		struct sk_buff *skb)
+{
+	sg_init_one(sg, skb_vmchannel_desc(skb), sizeof(struct vmchannel_desc));
+}
+
+static int try_fill_recvq(void)
+{
+	struct sk_buff *skb;
+	struct scatterlist sg[2];
+	int err, num = 0;
+
+	sg_init_table(sg, 2);
+	for (; atomic_read(&vmc_dev.recv_posted) < max_ring_len;
+			atomic_inc(&vmc_dev.recv_posted)) {
+		skb = alloc_skb(max_packet_len, GFP_KERNEL);
+		if (unlikely(!skb))
+			break;
+
+		skb_put(skb, max_packet_len);
+		vmchannel_desc_to_sg(sg, skb);
+		skb_to_sgvec(skb, sg + 1, 0, skb->len);
+		skb_queue_head(&vmc_dev.rx_skbuff_q, skb);
+
+		err = vmc_dev.rq->vq_ops->add_buf(vmc_dev.rq, sg, 0, 2, skb);
+		if (err) {
+			skb_unlink(skb, &vmc_dev.rx_skbuff_q);
+			kfree_skb(skb);
+			break;
+		}
+		num++;
+	}
+
+	if (num)
+		vmc_dev.rq->vq_ops->kick(vmc_dev.rq);
+
+	return num;
+}
+
+static void vmchannel_rx(unsigned long data)
+{
+	struct sk_buff *skb;
+	unsigned int l;
+
+	while ((skb = vmc_dev.rq->vq_ops->get_buf(vmc_dev.rq, &l))) {
+		struct vmchannel_desc *desc = skb_vmchannel_desc(skb);
+		__u32 len = le32_to_cpu(desc->len);
+
+		skb_unlink(skb, &vmc_dev.rx_skbuff_q);
+		skb_trim(skb, len);
+		if (!vmchannel_socket_recv(skb, le32_to_cpu(desc->id)))
+			atomic_dec(&vmc_dev.recv_posted);
+	}
+	try_fill_recvq();
+}
+
+static void recvq_notify(struct virtqueue *recvq)
+{
+	tasklet_schedule(&vmc_dev.rx_tasklet);
+}
+
+static int vmchannel_try_send_one(struct sk_buff *skb)
+{
+	struct scatterlist sg[2];
+
+	sg_init_table(sg, 2);
+	vmchannel_desc_to_sg(sg, skb);
+	skb_to_sgvec(skb, sg + 1, 0, skb->len);
+
+	return vmc_dev.sq->vq_ops->add_buf(vmc_dev.sq, sg, 2, 0, skb);
+}
+
+static void vmchannel_tx(unsigned long data)
+{
+	struct sk_buff *skb;
+	unsigned int len;
+	int sent = 0;
+
+	while ((skb = vmc_dev.sq->vq_ops->get_buf(vmc_dev.sq, &len)))
+		kfree_skb(skb);
+
+	spin_lock(&vmc_dev.tx_skbuff_q.lock);
+	while ((skb = skb_peek(&vmc_dev.tx_skbuff_q))) {
+		if (vmchannel_try_send_one(skb))
+			break;
+		__skb_unlink(skb, &vmc_dev.tx_skbuff_q);
+		sent++;
+	}
+	spin_unlock(&vmc_dev.tx_skbuff_q.lock);
+	if (sent)
+		vmc_dev.sq->vq_ops->kick(vmc_dev.sq);
+}
+
+static void sendq_notify(struct virtqueue *sendq)
+{
+	tasklet_schedule(&vmc_dev.tx_tasklet);
+}
+
+static int vmchannel_send_skb(struct sk_buff *skb, const __u32 id)
+{
+	struct vmchannel_desc *desc;
+
+	desc = skb_vmchannel_desc(skb);
+	desc->id = cpu_to_le32(id);
+	desc->len = cpu_to_le32(skb->len);
+
+	skb_queue_tail(&vmc_dev.tx_skbuff_q, skb);
+	tasklet_schedule(&vmc_dev.tx_tasklet);
+
+	return 0;
+}
+
+static int vmchannel_probe(struct virtio_device *vdev)
+{
+	int r, i;
+	__le32 count;
+	unsigned offset;
+
+	vdev->priv = &vmc_dev;
+	vmc_dev.vdev = vdev;
+
+	vdev->config->get(vdev, 0, &count, sizeof(count));
+
+	vmc_dev.channel_count = le32_to_cpu(count);
+	if (vmc_dev.channel_count == 0) {
+		dev_printk(KERN_ERR, &vdev->dev, "No channels present\n");
+		return -ENODEV;
+	}
+
+	pr_debug("vmchannel: %d channel detected\n", vmc_dev.channel_count);
+
+	vmc_dev.channels =
+		kzalloc(vmc_dev.channel_count * sizeof(struct vmchannel_info),
+				GFP_KERNEL);
+	if (!vmc_dev.channels)
+		return -ENOMEM;
+
+	offset = sizeof(count);
+	for (i = 0; i < count; i++) {
+		__u32 len;
+		__le32 tmp;
+		vdev->config->get(vdev, offset, &tmp, 4);
+		vmc_dev.channels[i].id = le32_to_cpu(tmp);
+		offset += 4;
+		vdev->config->get(vdev, offset, &tmp, 4);
+		len = le32_to_cpu(tmp);
+		if (len > VMCHANNEL_NAME_MAX) {
+			dev_printk(KERN_ERR, &vdev->dev,
+					"Wrong device configuration. "
+					"Channel name is too long");
+			r = -ENODEV;
+			goto out;
+		}
+		vmc_dev.channels[i].name = kmalloc(len, GFP_KERNEL);
+		if (!vmc_dev.channels[i].name) {
+			r = -ENOMEM;
+			goto out;
+		}
+		offset += 4;
+		vdev->config->get(vdev, offset, vmc_dev.channels[i].name, len);
+		offset += len;
+		pr_debug("vmhannel: found channel '%s' id %d\n",
+				vmc_dev.channels[i].name,
+				vmc_dev.channels[i].id);
+	}
+
+	vmc_dev.rq = vdev->config->find_vq(vdev, 0, recvq_notify);
+	if (IS_ERR(vmc_dev.rq)) {
+		r = PTR_ERR(vmc_dev.rq);
+		vmc_dev.rq = NULL;
+		goto out;
+	}
+
+	vmc_dev.sq = vdev->config->find_vq(vdev, 1, sendq_notify);
+	if (IS_ERR(vmc_dev.sq)) {
+		r = PTR_ERR(vmc_dev.sq);
+		vmc_dev.sq = NULL;
+		goto out;
+	}
+
+	r = proto_register(&vmchannel_proto, 0);
+	if (r)
+		goto out;
+
+	r = sock_register(&vmchannel_sock_family_ops);
+	if (r)
+		goto out_proto;
+
+	skb_queue_head_init(&vmc_dev.rx_skbuff_q);
+	skb_queue_head_init(&vmc_dev.tx_skbuff_q);
+	tasklet_init(&vmc_dev.rx_tasklet, vmchannel_rx, 0);
+	tasklet_init(&vmc_dev.tx_tasklet, vmchannel_tx, 0);
+	atomic_set(&vmc_dev.recv_posted, 0);
+	if (try_fill_recvq())
+		return 0;
+
+	r = -ENOMEM;
+
+	tasklet_kill(&vmc_dev.rx_tasklet);
+	tasklet_kill(&vmc_dev.tx_tasklet);
+	sock_unregister(PF_VMCHANNEL);
+out_proto:
+	proto_unregister(&vmchannel_proto);
+out:
+	if (vmc_dev.sq)
+		vdev->config->del_vq(vmc_dev.sq);
+	if (vmc_dev.rq)
+		vdev->config->del_vq(vmc_dev.rq);
+
+	for (i = 0; i < count; i++) {
+		if (!vmc_dev.channels[i].name)
+			break;
+		kfree(vmc_dev.channels[i].name);
+	}
+
+	kfree(vmc_dev.channels);
+
+	return r;
+}
+static void vmchannel_remove(struct virtio_device *vdev)
+{
+	int i;
+
+	/* Stop all the virtqueues. */
+	vdev->config->reset(vdev);
+
+	tasklet_kill(&vmc_dev.rx_tasklet);
+	tasklet_kill(&vmc_dev.tx_tasklet);
+
+	sock_unregister(PF_VMCHANNEL);
+	proto_unregister(&vmchannel_proto);
+
+	vdev->config->del_vq(vmc_dev.rq);
+	vdev->config->del_vq(vmc_dev.sq);
+
+	skb_queue_purge(&vmc_dev.rx_skbuff_q);
+	skb_queue_purge(&vmc_dev.tx_skbuff_q);
+
+	for (i = 0; i < vmc_dev.channel_count; i++)
+		kfree(vmc_dev.channels[i].name);
+
+	kfree(vmc_dev.channels);
+}
+
+static struct virtio_device_id id_table[] = {
+	{ VIRTIO_ID_VMCHANNEL, VIRTIO_DEV_ANY_ID }, { 0 },
+};
+
+static struct virtio_driver virtio_vmchannel = {
+	.driver.name =  "virtio-vmchannel",
+	.driver.owner = THIS_MODULE,
+	.id_table =     id_table,
+	.probe =	vmchannel_probe,
+	.remove =       __devexit_p(vmchannel_remove),
+};
+
+static int __init init(void)
+{
+	return register_virtio_driver(&virtio_vmchannel);
+}
+
+static void __exit fini(void)
+{
+	unregister_virtio_driver(&virtio_vmchannel);
+}
+
+module_init(init);
+module_exit(fini);
+
+MODULE_AUTHOR("Gleb Natapov");
+MODULE_DEVICE_TABLE(virtio, id_table);
+MODULE_DESCRIPTION("Virtio vmchannel driver");
+MODULE_LICENSE("GPL");

