From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 7/7] [S390]: Add AF_IUCV socket support
Date: Fri, 2 Feb 2007 13:07:41 +0100
Message-ID: <20070202120741.GH10392@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:43714 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423026AbXBBMGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 07:06:50 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l12C6m8C002192
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:48 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l12C6lhs281914
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:47 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l12C6lB3018320
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:47 -0500
Received: from goulee.de.ibm.com (dyn-9-152-216-77.boeblingen.de.ibm.com [9.152.216.77])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l12C6hC9018058
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:47 -0500
Received: from goulee.de.ibm.com (localhost.localdomain [127.0.0.1])
	by goulee.de.ibm.com (8.13.1/8.13.1) with ESMTP id l12C7fr1015308
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 13:07:41 +0100
Received: (from pavlic@localhost)
	by goulee.de.ibm.com (8.13.1/8.13.1/Submit) id l12C7fSD015305
	for netdev@vger.kernel.org; Fri, 2 Feb 2007 13:07:41 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jennifer Hunt<jenhunt@us.ibm.com>

This patch adds AF_IUCV socket support.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/defconfig        |    1 
 include/linux/net.h        |    2 
 include/linux/socket.h     |    4 
 include/net/iucv/af_iucv.h |  106 ++++
 net/iucv/Kconfig           |    8 
 net/iucv/Makefile          |    1 
 net/iucv/af_iucv.c         | 1077 ++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1197 insertions(+), 2 deletions(-)

diff --git a/arch/s390/defconfig b/arch/s390/defconfig
index 56fe005..11a8049 100644
--- a/arch/s390/defconfig
+++ b/arch/s390/defconfig
@@ -178,6 +178,7 @@ # CONFIG_XFRM_USER is not set
 # CONFIG_XFRM_SUB_POLICY is not set
 CONFIG_NET_KEY=y
 CONFIG_IUCV=m
+CONFIG_AFIUCV=m
 CONFIG_INET=y
 CONFIG_IP_MULTICAST=y
 # CONFIG_IP_ADVANCED_ROUTER is not set
diff --git a/include/linux/net.h b/include/linux/net.h
index f28d8a2..4db21e6 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -24,7 +24,7 @@ #include <asm/socket.h>
 struct poll_table_struct;
 struct inode;
 
-#define NPROTO		32		/* should be enough for now..	*/
+#define NPROTO		33		/* should be enough for now..	*/
 
 #define SYS_SOCKET	1		/* sys_socket(2)		*/
 #define SYS_BIND	2		/* sys_bind(2)			*/
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 92cd38e..fcd35a2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -187,7 +187,8 @@ #define AF_WANPIPE	25	/* Wanpipe API Soc
 #define AF_LLC		26	/* Linux LLC			*/
 #define AF_TIPC		30	/* TIPC sockets			*/
 #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
-#define AF_MAX		32	/* For now.. */
+#define AF_IUCV		32	/* IUCV sockets			*/
+#define AF_MAX		33	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -220,6 +221,7 @@ #define PF_WANPIPE	AF_WANPIPE
 #define PF_LLC		AF_LLC
 #define PF_TIPC		AF_TIPC
 #define PF_BLUETOOTH	AF_BLUETOOTH
+#define PF_IUCV		AF_IUCV
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/net/iucv/af_iucv.h b/include/net/iucv/af_iucv.h
new file mode 100644
index 0000000..04d1abb
--- /dev/null
+++ b/include/net/iucv/af_iucv.h
@@ -0,0 +1,106 @@
+/*
+ * Copyright 2006 IBM Corporation
+ * IUCV protocol stack for Linux on zSeries
+ * Version 1.0
+ * Author(s): Jennifer Hunt <jenhunt@us.ibm.com>
+ *
+ */
+
+#ifndef __AFIUCV_H
+#define __AFIUCV_H
+
+#include <asm/types.h>
+#include <asm/byteorder.h>
+#include <linux/list.h>
+#include <linux/poll.h>
+#include <linux/socket.h>
+
+#ifndef AF_IUCV
+#define AF_IUCV		32
+#define PF_IUCV		AF_IUCV
+#endif
+
+/* Connection and socket states */
+enum {
+	IUCV_CONNECTED = 1,
+	IUCV_OPEN,
+	IUCV_BOUND,
+	IUCV_LISTEN,
+	IUCV_SEVERED,
+	IUCV_DISCONN,
+	IUCV_CLOSED
+};
+
+#define IUCV_QUEUELEN_DEFAULT	65535
+#define IUCV_CONN_TIMEOUT	(HZ * 40)
+#define IUCV_DISCONN_TIMEOUT	(HZ * 2)
+#define IUCV_CONN_IDLE_TIMEOUT	(HZ * 60)
+#define IUCV_BUFSIZE_DEFAULT	32768
+
+/* IUCV socket address */
+struct sockaddr_iucv {
+	sa_family_t	siucv_family;
+	unsigned short	siucv_port;		/* Reserved */
+	unsigned int	siucv_addr;		/* Reserved */
+	char		siucv_nodeid[8];	/* Reserved */
+	char		siucv_user_id[8];	/* Guest User Id */
+	char		siucv_name[8];		/* Application Name */
+};
+
+
+/* Common socket structures and functions */
+
+#define iucv_sk(__sk) ((struct iucv_sock *) __sk)
+
+struct iucv_sock {
+	struct sock		sk;
+	char			src_user_id[8];
+	char			src_name[8];
+	char			dst_user_id[8];
+	char			dst_name[8];
+	struct list_head	accept_q;
+	struct sock		*parent;
+	struct iucv_path	*path;
+	struct sk_buff_head	send_skb_q;
+	unsigned int		send_tag;
+};
+
+struct iucv_sock_list {
+	struct hlist_head head;
+	rwlock_t	  lock;
+	atomic_t	  autobind_name;
+};
+
+static void iucv_sock_destruct(struct sock *sk);
+static void iucv_sock_cleanup_listen(struct sock *parent);
+static void iucv_sock_kill(struct sock *sk);
+static void iucv_sock_close(struct sock *sk);
+static int  iucv_sock_create(struct socket *sock, int proto);
+static int  iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
+			int addr_len);
+static int  iucv_sock_connect(struct socket *sock, struct sockaddr *addr,
+			      int alen, int flags);
+static int  iucv_sock_listen(struct socket *sock, int backlog);
+static int  iucv_sock_accept(struct socket *sock, struct socket *newsock,
+			     int flags);
+static int  iucv_sock_getname(struct socket *sock, struct sockaddr *addr,
+			      int *len, int peer);
+static int  iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+			      struct msghdr *msg, size_t len);
+static int  iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+			      struct msghdr *msg, size_t len, int flags);
+unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
+			    poll_table *wait);
+static int iucv_sock_release(struct socket *sock);
+static int iucv_sock_shutdown(struct socket *sock, int how);
+
+void iucv_sock_link(struct iucv_sock_list *l, struct sock *s);
+void iucv_sock_unlink(struct iucv_sock_list *l, struct sock *s);
+int  iucv_sock_wait_state(struct sock *sk, int state, int state2,
+			  unsigned long timeo);
+int  iucv_sock_wait_cnt(struct sock *sk, unsigned long timeo);
+void iucv_accept_enqueue(struct sock *parent, struct sock *sk);
+void iucv_accept_unlink(struct sock *sk);
+struct sock *iucv_accept_dequeue(struct sock *parent, struct socket *newsock);
+
+#endif /* __IUCV_H */
diff --git a/net/iucv/Kconfig b/net/iucv/Kconfig
index 45ecf0b..f8fcc3d 100644
--- a/net/iucv/Kconfig
+++ b/net/iucv/Kconfig
@@ -5,3 +5,11 @@ config IUCV
 	  Select this option if you want to use inter-user communication under
 	  VM or VIF sockets. If you run on z/VM, say "Y" to enable a fast
 	  communication link between VM guests.
+
+config AFIUCV
+	tristate "AF_IUCV support (VM only)"
+	depends on IUCV
+	help
+	  Select this option if you want to use inter-user communication under
+	  VM or VIF sockets. If you run on z/VM, say "Y" to enable a fast
+	  communication link between VM guests.
diff --git a/net/iucv/Makefile b/net/iucv/Makefile
index 8759417..7bfdc85 100644
--- a/net/iucv/Makefile
+++ b/net/iucv/Makefile
@@ -3,3 +3,4 @@ # Makefile for IUCV
 #
 
 obj-$(CONFIG_IUCV)	+= iucv.o
+obj-$(CONFIG_AFIUCV)	+= af_iucv.o
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
new file mode 100644
index 0000000..acc9421
--- /dev/null
+++ b/net/iucv/af_iucv.c
@@ -0,0 +1,1077 @@
+/*
+ *  linux/net/iucv/af_iucv.c
+ *
+ *  IUCV protocol stack for Linux on zSeries
+ *
+ *  Copyright 2006 IBM Corporation
+ *
+ *  Author(s):	Jennifer Hunt <jenhunt@us.ibm.com>
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
+#include <asm/ebcdic.h>
+#include <asm/cpcmd.h>
+#include <linux/kmod.h>
+
+#include <net/iucv/iucv.h>
+#include <net/iucv/af_iucv.h>
+
+#define CONFIG_IUCV_SOCK_DEBUG 1
+
+#define IPRMDATA 0x80
+#define VERSION "1.0"
+
+static char iucv_userid[80];
+
+static struct proto_ops iucv_sock_ops;
+
+static struct proto iucv_proto = {
+	.name		= "AF_IUCV",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct iucv_sock),
+};
+
+/* Call Back functions */
+static void iucv_callback_rx(struct iucv_path *, struct iucv_message *);
+static void iucv_callback_txdone(struct iucv_path *, struct iucv_message *);
+static void iucv_callback_connack(struct iucv_path *, u8 ipuser[16]);
+static int iucv_callback_connreq(struct iucv_path *, u8 ipvmid[8], u8 ipuser[16]);
+static void iucv_callback_connrej(struct iucv_path *, u8 ipuser[16]);
+
+static struct iucv_sock_list iucv_sk_list = {
+	.lock = RW_LOCK_UNLOCKED,
+	.autobind_name = ATOMIC_INIT(0)
+};
+
+static struct iucv_handler af_iucv_handler = {
+	.path_pending	  = iucv_callback_connreq,
+	.path_complete	  = iucv_callback_connack,
+	.path_severed	  = iucv_callback_connrej,
+	.message_pending  = iucv_callback_rx,
+	.message_complete = iucv_callback_txdone
+};
+
+static inline void high_nmcpy(unsigned char *dst, char *src)
+{
+       memcpy(dst, src, 8);
+}
+
+static inline void low_nmcpy(unsigned char *dst, char *src)
+{
+       memcpy(&dst[8], src, 8);
+}
+
+/* Timers */
+static void iucv_sock_timeout(unsigned long arg)
+{
+	struct sock *sk = (struct sock *)arg;
+
+	bh_lock_sock(sk);
+	sk->sk_err = ETIMEDOUT;
+	sk->sk_state_change(sk);
+	bh_unlock_sock(sk);
+
+	iucv_sock_kill(sk);
+	sock_put(sk);
+}
+
+static void iucv_sock_clear_timer(struct sock *sk)
+{
+	sk_stop_timer(sk, &sk->sk_timer);
+}
+
+static void iucv_sock_init_timer(struct sock *sk)
+{
+	init_timer(&sk->sk_timer);
+	sk->sk_timer.function = iucv_sock_timeout;
+	sk->sk_timer.data = (unsigned long)sk;
+}
+
+static struct sock *__iucv_get_sock_by_name(char *nm)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+
+	sk_for_each(sk, node, &iucv_sk_list.head)
+		if (!memcmp(&iucv_sk(sk)->src_name, nm, 8))
+			return sk;
+
+	return NULL;
+}
+
+static void iucv_sock_destruct(struct sock *sk)
+{
+	skb_queue_purge(&sk->sk_receive_queue);
+	skb_queue_purge(&sk->sk_write_queue);
+}
+
+/* Cleanup Listen */
+static void iucv_sock_cleanup_listen(struct sock *parent)
+{
+	struct sock *sk;
+
+	/* Close non-accepted connections */
+	while ((sk = iucv_accept_dequeue(parent, NULL))) {
+		iucv_sock_close(sk);
+		iucv_sock_kill(sk);
+	}
+
+	parent->sk_state = IUCV_CLOSED;
+	sock_set_flag(parent, SOCK_ZAPPED);
+}
+
+/* Kill socket */
+static void iucv_sock_kill(struct sock *sk)
+{
+	if (!sock_flag(sk, SOCK_ZAPPED) || sk->sk_socket)
+		return;
+
+	iucv_sock_unlink(&iucv_sk_list, sk);
+	sock_set_flag(sk, SOCK_DEAD);
+	sock_put(sk);
+}
+
+/* Close an IUCV socket */
+static void iucv_sock_close(struct sock *sk)
+{
+	unsigned char user_data[16];
+	struct iucv_sock *iucv = iucv_sk(sk);
+	int err;
+
+	iucv_sock_clear_timer(sk);
+	lock_sock(sk);
+
+	switch(sk->sk_state) {
+	case IUCV_LISTEN:
+		iucv_sock_cleanup_listen(sk);
+		break;
+
+	case IUCV_CONNECTED:
+	case IUCV_DISCONN:
+		err = 0;
+		if (iucv->path) {
+			low_nmcpy(user_data, iucv->src_name);
+			high_nmcpy(user_data, iucv->dst_name);
+			ASCEBC(user_data, sizeof(user_data));
+			err = iucv_path_sever(iucv->path, user_data);
+			iucv_path_free(iucv->path);
+			iucv->path = NULL;
+		}
+
+		sk->sk_state = IUCV_CLOSED;
+		sk->sk_state_change(sk);
+		sk->sk_err = ECONNRESET;
+		sk->sk_state_change(sk);
+
+		skb_queue_purge(&iucv->send_skb_q);
+
+		sock_set_flag(sk, SOCK_ZAPPED);
+		break;
+
+	default:
+		sock_set_flag(sk, SOCK_ZAPPED);
+		break;
+	};
+
+	release_sock(sk);
+	iucv_sock_kill(sk);
+}
+
+static void iucv_sock_init(struct sock *sk, struct sock *parent)
+{
+	if (parent)
+		sk->sk_type = parent->sk_type;
+}
+
+static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio)
+{
+	struct sock *sk;
+
+	sk = sk_alloc(PF_IUCV, prio, &iucv_proto, 1);
+	if (!sk)
+		return NULL;
+
+	sock_init_data(sock, sk);
+	INIT_LIST_HEAD(&iucv_sk(sk)->accept_q);
+	skb_queue_head_init(&iucv_sk(sk)->send_skb_q);
+	iucv_sk(sk)->send_tag = 0;
+
+	sk->sk_destruct = iucv_sock_destruct;
+	sk->sk_sndtimeo = IUCV_CONN_TIMEOUT;
+	sk->sk_allocation = GFP_DMA;
+
+	sock_reset_flag(sk, SOCK_ZAPPED);
+
+	sk->sk_protocol = proto;
+	sk->sk_state	= IUCV_OPEN;
+
+	iucv_sock_init_timer(sk);
+
+	iucv_sock_link(&iucv_sk_list, sk);
+	return sk;
+}
+
+/* Create an IUCV socket */
+static int iucv_sock_create(struct socket *sock, int protocol)
+{
+	struct sock *sk;
+
+	if (sock->type != SOCK_STREAM)
+		return -ESOCKTNOSUPPORT;
+
+	sock->state = SS_UNCONNECTED;
+	sock->ops = &iucv_sock_ops;
+
+	sk = iucv_sock_alloc(sock, protocol, GFP_KERNEL);
+	if (!sk)
+		return -ENOMEM;
+
+	iucv_sock_init(sk, NULL);
+
+	return 0;
+}
+
+void iucv_sock_link(struct iucv_sock_list *l, struct sock *sk)
+{
+	write_lock_bh(&l->lock);
+	sk_add_node(sk, &l->head);
+	write_unlock_bh(&l->lock);
+}
+
+void iucv_sock_unlink(struct iucv_sock_list *l, struct sock *sk)
+{
+	write_lock_bh(&l->lock);
+	sk_del_node_init(sk);
+	write_unlock_bh(&l->lock);
+}
+
+void iucv_accept_enqueue(struct sock *parent, struct sock *sk)
+{
+	sock_hold(sk);
+	list_add_tail(&iucv_sk(sk)->accept_q, &iucv_sk(parent)->accept_q);
+	iucv_sk(sk)->parent = parent;
+	parent->sk_ack_backlog++;
+}
+
+void iucv_accept_unlink(struct sock *sk)
+{
+	list_del_init(&iucv_sk(sk)->accept_q);
+	iucv_sk(sk)->parent->sk_ack_backlog--;
+	iucv_sk(sk)->parent = NULL;
+	sock_put(sk);
+}
+
+struct sock *iucv_accept_dequeue(struct sock *parent, struct socket *newsock)
+{
+	struct iucv_sock *isk, *n;
+	struct sock *sk;
+
+	list_for_each_entry_safe(isk, n, &iucv_sk(parent)->accept_q, accept_q){
+		sk = (struct sock *) isk;
+		lock_sock(sk);
+
+		if (sk->sk_state == IUCV_CLOSED) {
+			release_sock(sk);
+			iucv_accept_unlink(sk);
+			continue;
+		}
+
+		if (sk->sk_state == IUCV_CONNECTED ||
+		    sk->sk_state == IUCV_SEVERED ||
+		    !newsock) {
+			iucv_accept_unlink(sk);
+			if (newsock)
+				sock_graft(sk, newsock);
+
+			if (sk->sk_state == IUCV_SEVERED)
+				sk->sk_state = IUCV_DISCONN;
+
+			release_sock(sk);
+			return sk;
+		}
+
+		release_sock(sk);
+	}
+	return NULL;
+}
+
+int iucv_sock_wait_state(struct sock *sk, int state, int state2,
+			 unsigned long timeo)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	int err = 0;
+
+	add_wait_queue(sk->sk_sleep, &wait);
+	while (sk->sk_state != state && sk->sk_state != state2) {
+		set_current_state(TASK_INTERRUPTIBLE);
+
+		if (!timeo) {
+			err = -EAGAIN;
+			break;
+		}
+
+		if (signal_pending(current)) {
+			err = sock_intr_errno(timeo);
+			break;
+		}
+
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		lock_sock(sk);
+
+		err = sock_error(sk);
+		if (err)
+			break;
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(sk->sk_sleep, &wait);
+	return err;
+}
+
+/* Bind an unbound socket */
+static int iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
+			  int addr_len)
+{
+	struct sockaddr_iucv *sa = (struct sockaddr_iucv *) addr;
+	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv;
+	int err;
+
+	/* Verify the input sockaddr */
+	if (!addr || addr->sa_family != AF_IUCV)
+		return -EINVAL;
+
+	lock_sock(sk);
+	if (sk->sk_state != IUCV_OPEN) {
+		err = -EBADFD;
+		goto done;
+	}
+
+	write_lock_bh(&iucv_sk_list.lock);
+
+	iucv = iucv_sk(sk);
+	if (__iucv_get_sock_by_name(sa->siucv_name)) {
+		err = -EADDRINUSE;
+		goto done_unlock;
+	}
+	if (iucv->path) {
+		err = 0;
+		goto done_unlock;
+	}
+
+	/* Bind the socket */
+	memcpy(iucv->src_name, sa->siucv_name, 8);
+
+	/* Copy the user id */
+	memcpy(iucv->src_user_id, iucv_userid, 8);
+	sk->sk_state = IUCV_BOUND;
+	err = 0;
+
+done_unlock:
+	/* Release the socket list lock */
+	write_unlock_bh(&iucv_sk_list.lock);
+done:
+	release_sock(sk);
+	return err;
+}
+
+/* Automatically bind an unbound socket */
+static int iucv_sock_autobind(struct sock *sk)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+	char query_buffer[80];
+	char name[12];
+	int err = 0;
+
+	/* Set the userid and name */
+	cpcmd("QUERY USERID", query_buffer, sizeof(query_buffer), &err);
+	if (unlikely(err))
+		return -EPROTO;
+
+	memcpy(iucv->src_user_id, query_buffer, 8);
+
+	write_lock_bh(&iucv_sk_list.lock);
+
+	sprintf(name, "%08x", atomic_inc_return(&iucv_sk_list.autobind_name));
+	while (__iucv_get_sock_by_name(name)) {
+		sprintf(name, "%08x",
+			atomic_inc_return(&iucv_sk_list.autobind_name));
+	}
+
+	write_unlock_bh(&iucv_sk_list.lock);
+
+	memcpy(&iucv->src_name, name, 8);
+
+	return err;
+}
+
+/* Connect an unconnected socket */
+static int iucv_sock_connect(struct socket *sock, struct sockaddr *addr,
+			     int alen, int flags)
+{
+	struct sockaddr_iucv *sa = (struct sockaddr_iucv *) addr;
+	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv;
+	unsigned char user_data[16];
+	int err;
+
+	if (addr->sa_family != AF_IUCV || alen < sizeof(struct sockaddr_iucv))
+		return -EINVAL;
+
+	if (sk->sk_state != IUCV_OPEN && sk->sk_state != IUCV_BOUND)
+		return -EBADFD;
+
+	if (sk->sk_type != SOCK_STREAM)
+		return -EINVAL;
+
+	iucv = iucv_sk(sk);
+
+	if (sk->sk_state == IUCV_OPEN) {
+		err = iucv_sock_autobind(sk);
+		if (unlikely(err))
+			return err;
+	}
+
+	lock_sock(sk);
+
+	/* Set the destination information */
+	memcpy(iucv_sk(sk)->dst_user_id, sa->siucv_user_id, 8);
+	memcpy(iucv_sk(sk)->dst_name, sa->siucv_name, 8);
+
+	high_nmcpy(user_data, sa->siucv_name);
+	low_nmcpy(user_data, iucv_sk(sk)->src_name);
+	ASCEBC(user_data, sizeof(user_data));
+
+	iucv = iucv_sk(sk);
+	/* Create path. */
+	iucv->path = iucv_path_alloc(IUCV_QUEUELEN_DEFAULT,
+				     IPRMDATA, GFP_KERNEL);
+	err = iucv_path_connect(iucv->path, &af_iucv_handler,
+				sa->siucv_user_id, NULL, user_data, sk);
+	if (err) {
+		iucv_path_free(iucv->path);
+		iucv->path = NULL;
+		err = -ECONNREFUSED;
+		goto done;
+	}
+
+	if (sk->sk_state != IUCV_CONNECTED) {
+		err = iucv_sock_wait_state(sk, IUCV_CONNECTED, IUCV_DISCONN,
+				sock_sndtimeo(sk, flags & O_NONBLOCK));
+	}
+
+	if (sk->sk_state == IUCV_DISCONN) {
+		release_sock(sk);
+		return -ECONNREFUSED;
+	}
+done:
+	release_sock(sk);
+	return err;
+}
+
+/* Move a socket into listening state. */
+static int iucv_sock_listen(struct socket *sock, int backlog)
+{
+	struct sock *sk = sock->sk;
+	int err;
+
+	lock_sock(sk);
+
+	err = -EINVAL;
+	if (sk->sk_state != IUCV_BOUND || sock->type != SOCK_STREAM)
+		goto done;
+
+	sk->sk_max_ack_backlog = backlog;
+	sk->sk_ack_backlog = 0;
+	sk->sk_state = IUCV_LISTEN;
+	err = 0;
+
+done:
+	release_sock(sk);
+	return err;
+}
+
+/* Accept a pending connection */
+static int iucv_sock_accept(struct socket *sock, struct socket *newsock,
+			    int flags)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	struct sock *sk = sock->sk, *nsk;
+	long timeo;
+	int err = 0;
+
+	lock_sock(sk);
+
+	if (sk->sk_state != IUCV_LISTEN) {
+		err = -EBADFD;
+		goto done;
+	}
+
+	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
+
+	/* Wait for an incoming connection */
+	add_wait_queue_exclusive(sk->sk_sleep, &wait);
+	while (!(nsk = iucv_accept_dequeue(sk, newsock))){
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (!timeo) {
+			err = -EAGAIN;
+			break;
+		}
+
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		lock_sock(sk);
+
+		if (sk->sk_state != IUCV_LISTEN) {
+			err = -EBADFD;
+			break;
+		}
+
+		if (signal_pending(current)) {
+			err = sock_intr_errno(timeo);
+			break;
+		}
+	}
+
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(sk->sk_sleep, &wait);
+
+	if (err)
+		goto done;
+
+	newsock->state = SS_CONNECTED;
+
+done:
+	release_sock(sk);
+	return err;
+}
+
+static int iucv_sock_getname(struct socket *sock, struct sockaddr *addr,
+			     int *len, int peer)
+{
+	struct sockaddr_iucv *siucv = (struct sockaddr_iucv *) addr;
+	struct sock *sk = sock->sk;
+
+	addr->sa_family = AF_IUCV;
+	*len = sizeof(struct sockaddr_iucv);
+
+	if (peer) {
+		memcpy(siucv->siucv_user_id, iucv_sk(sk)->dst_user_id, 8);
+		memcpy(siucv->siucv_name, &iucv_sk(sk)->dst_name, 8);
+	} else {
+		memcpy(siucv->siucv_user_id, iucv_sk(sk)->src_user_id, 8);
+		memcpy(siucv->siucv_name, iucv_sk(sk)->src_name, 8);
+	}
+	memset(&siucv->siucv_port, 0, sizeof(siucv->siucv_port));
+	memset(&siucv->siucv_addr, 0, sizeof(siucv->siucv_addr));
+	memset(siucv->siucv_nodeid, 0, sizeof(siucv->siucv_nodeid));
+
+	return 0;
+}
+
+static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+			     struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv = iucv_sk(sk);
+	struct sk_buff *skb;
+	struct iucv_message txmsg;
+	int err;
+
+	err = sock_error(sk);
+	if (err)
+		return err;
+
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	lock_sock(sk);
+
+	if (sk->sk_shutdown & SEND_SHUTDOWN) {
+		err = -EPIPE;
+		goto out;
+	}
+
+	if (sk->sk_state == IUCV_CONNECTED){
+		if(!(skb = sock_alloc_send_skb(sk, len,
+				       msg->msg_flags & MSG_DONTWAIT,
+				       &err)))
+			return err;
+
+		if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)){
+			err = -EFAULT;
+			goto fail;
+		}
+
+		txmsg.class = 0;
+		txmsg.tag = iucv->send_tag++;
+		memcpy(skb->cb, &txmsg.tag, 4);
+		skb_queue_tail(&iucv->send_skb_q, skb);
+		err = iucv_message_send(iucv->path, &txmsg, 0, 0,
+					(void *) skb->data, skb->len);
+		if (err) {
+			if (err == 3)
+				printk(KERN_ERR "AF_IUCV msg limit exceeded\n");
+			skb_unlink(skb, &iucv->send_skb_q);
+			err = -EPIPE;
+			goto fail;
+		}
+
+	} else {
+		err = -ENOTCONN;
+		goto out;
+	}
+
+	release_sock(sk);
+	return len;
+
+fail:
+	kfree_skb(skb);
+out:
+	release_sock(sk);
+	return err;
+}
+
+static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+			     struct msghdr *msg, size_t len, int flags)
+{
+	int noblock = flags & MSG_DONTWAIT;
+	struct sock *sk = sock->sk;
+	int target, copied = 0;
+	struct sk_buff *skb;
+	int err = 0;
+
+	if (flags & (MSG_OOB))
+		return -EOPNOTSUPP;
+
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb) {
+		if (sk->sk_shutdown & RCV_SHUTDOWN)
+			return 0;
+		return err;
+	}
+
+	copied = min_t(unsigned int, skb->len, len);
+
+	if (memcpy_toiovec(msg->msg_iov, skb->data, copied)) {
+		skb_queue_head(&sk->sk_receive_queue, skb);
+		if (copied == 0)
+			return -EFAULT;
+	}
+
+	len -= copied;
+
+	/* Mark read part of skb as used */
+	if (!(flags & MSG_PEEK)) {
+		skb_pull(skb, copied);
+
+		if (skb->len) {
+			skb_queue_head(&sk->sk_receive_queue, skb);
+			goto done;
+		}
+
+		kfree_skb(skb);
+	} else
+		skb_queue_head(&sk->sk_receive_queue, skb);
+
+done:
+	return err ? : copied;
+}
+
+static inline unsigned int iucv_accept_poll(struct sock *parent)
+{
+	struct iucv_sock *isk, *n;
+	struct sock *sk;
+
+	list_for_each_entry_safe(isk, n, &iucv_sk(parent)->accept_q, accept_q){
+		sk = (struct sock *) isk;
+
+		if (sk->sk_state == IUCV_CONNECTED)
+			return POLLIN | POLLRDNORM;
+	}
+
+	return 0;
+}
+
+unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
+			    poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	unsigned int mask = 0;
+
+	poll_wait(file, sk->sk_sleep, wait);
+
+	if (sk->sk_state == IUCV_LISTEN)
+		return iucv_accept_poll(sk);
+
+	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+		mask |= POLLERR;
+
+	if (sk->sk_shutdown & RCV_SHUTDOWN)
+		mask |= POLLRDHUP;
+
+	if (sk->sk_shutdown == SHUTDOWN_MASK)
+		mask |= POLLHUP;
+
+	if (!skb_queue_empty(&sk->sk_receive_queue) ||
+			(sk->sk_shutdown & RCV_SHUTDOWN))
+		mask |= POLLIN | POLLRDNORM;
+
+	if (sk->sk_state == IUCV_CLOSED)
+		mask |= POLLHUP;
+
+	if (sock_writeable(sk))
+		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+	else
+		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+
+	return mask;
+}
+
+static int iucv_sock_shutdown(struct socket *sock, int how)
+{
+	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv = iucv_sk(sk);
+	struct iucv_message txmsg;
+	int err = 0;
+	u8 prmmsg[8] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01};
+
+	how++;
+
+	if ((how & ~SHUTDOWN_MASK) || !how)
+		return -EINVAL;
+
+	lock_sock(sk);
+	switch(sk->sk_state) {
+	case IUCV_CLOSED:
+		err = -ENOTCONN;
+		goto fail;
+
+	default:
+		sk->sk_shutdown |= how;
+		break;
+	}
+
+	if (how == SEND_SHUTDOWN || how == SHUTDOWN_MASK) {
+		txmsg.class = 0;
+		txmsg.tag = 0;
+		err = iucv_message_send(iucv->path, &txmsg, IUCV_IPRMDATA, 0,
+					(void *) prmmsg, 8);
+		if (err) {
+			switch(err) {
+			case 1:
+				err = -ENOTCONN;
+				break;
+			case 2:
+				err = -ECONNRESET;
+				break;
+			default:
+				err = -ENOTCONN;
+				break;
+			}
+		}
+	}
+
+	if (how == RCV_SHUTDOWN || how == SHUTDOWN_MASK) {
+		err = iucv_path_quiesce(iucv_sk(sk)->path, NULL);
+		if (err)
+			err = -ENOTCONN;
+
+		skb_queue_purge(&sk->sk_receive_queue);
+	}
+
+	/* Wake up anyone sleeping in poll */
+	sk->sk_state_change(sk);
+
+fail:
+	release_sock(sk);
+	return err;
+}
+
+static int iucv_sock_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	int err = 0;
+
+	if (!sk)
+		return 0;
+
+	iucv_sock_close(sk);
+
+	/* Unregister with IUCV base support */
+	if (iucv_sk(sk)->path) {
+		iucv_path_sever(iucv_sk(sk)->path, NULL);
+		iucv_path_free(iucv_sk(sk)->path);
+		iucv_sk(sk)->path = NULL;
+	}
+
+	if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime){
+		lock_sock(sk);
+		err = iucv_sock_wait_state(sk, IUCV_CLOSED, 0,
+					   sk->sk_lingertime);
+		release_sock(sk);
+	}
+
+	sock_orphan(sk);
+	iucv_sock_kill(sk);
+	return err;
+}
+
+/* Callback wrappers - called from iucv base support */
+static int iucv_callback_connreq(struct iucv_path *path,
+				 u8 ipvmid[8], u8 ipuser[16])
+{
+	unsigned char user_data[16];
+	unsigned char nuser_data[16];
+	unsigned char src_name[8];
+	struct hlist_node *node;
+	struct sock *sk, *nsk;
+	struct iucv_sock *iucv, *niucv;
+	int err;
+
+	memcpy(src_name, ipuser, 8);
+	EBCASC(src_name, 8);
+	/* Find out if this path belongs to af_iucv. */
+	read_lock(&iucv_sk_list.lock);
+	iucv = NULL;
+	sk_for_each(sk, node, &iucv_sk_list.head)
+		if (sk->sk_state == IUCV_LISTEN &&
+		    !memcmp(&iucv_sk(sk)->src_name, src_name, 8)) {
+			/*
+			 * Found a listening socket with
+			 * src_name == ipuser[0-7].
+			 */
+			iucv = iucv_sk(sk);
+			break;
+		}
+	read_unlock(&iucv_sk_list.lock);
+	if (!iucv)
+		/* No socket found, not one of our paths. */
+		return -EINVAL;
+
+	bh_lock_sock(sk);
+
+	/* Check if parent socket is listening */
+	low_nmcpy(user_data, iucv->src_name);
+	high_nmcpy(user_data, iucv->dst_name);
+	ASCEBC(user_data, sizeof(user_data));
+	if (sk->sk_state != IUCV_LISTEN) {
+		err = iucv_path_sever(path, user_data);
+		goto fail;
+	}
+
+	/* Check for backlog size */
+	if (sk_acceptq_is_full(sk)) {
+		err = iucv_path_sever(path, user_data);
+		goto fail;
+	}
+
+	/* Create the new socket */
+	nsk = iucv_sock_alloc(NULL, SOCK_STREAM, GFP_ATOMIC);
+	if (!nsk){
+		err = iucv_path_sever(path, user_data);
+		goto fail;
+	}
+
+	niucv = iucv_sk(nsk);
+	iucv_sock_init(nsk, sk);
+
+	/* Set the new iucv_sock */
+	memcpy(niucv->dst_name, ipuser + 8, 8);
+	EBCASC(niucv->dst_name, 8);
+	memcpy(niucv->dst_user_id, ipvmid, 8);
+	memcpy(niucv->src_name, iucv->src_name, 8);
+	memcpy(niucv->src_user_id, iucv->src_user_id, 8);
+	niucv->path = path;
+
+	/* Call iucv_accept */
+	high_nmcpy(nuser_data, ipuser + 8);
+	memcpy(nuser_data + 8, niucv->src_name, 8);
+	ASCEBC(nuser_data + 8, 8);
+
+	path->msglim = IUCV_QUEUELEN_DEFAULT;
+	err = iucv_path_accept(path, &af_iucv_handler, nuser_data, nsk);
+	if (err){
+		err = iucv_path_sever(path, user_data);
+		goto fail;
+	}
+
+	iucv_accept_enqueue(sk, nsk);
+
+	/* Wake up accept */
+	nsk->sk_state = IUCV_CONNECTED;
+	sk->sk_data_ready(sk, 1);
+	err = 0;
+fail:
+	bh_unlock_sock(sk);
+	return 0;
+}
+
+static void iucv_callback_connack(struct iucv_path *path, u8 ipuser[16])
+{
+	struct sock *sk = path->private;
+
+	sk->sk_state = IUCV_CONNECTED;
+	sk->sk_state_change(sk);
+}
+
+static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
+{
+	struct sock *sk = path->private;
+	struct sk_buff *skb;
+	int rc;
+
+	if (sk->sk_shutdown & RCV_SHUTDOWN)
+		return;
+
+	skb = alloc_skb(msg->length, GFP_ATOMIC | GFP_DMA);
+	if (!skb) {
+		iucv_message_reject(path, msg);
+		return;
+	}
+
+	if (msg->flags & IPRMDATA) {
+		skb->data = NULL;
+		skb->len = 0;
+	} else {
+		rc = iucv_message_receive(path, msg, 0, skb->data,
+					  msg->length, NULL);
+		if (rc) {
+			kfree_skb(skb);
+			return;
+		}
+
+		skb->h.raw = skb->data;
+		skb->nh.raw = skb->data;
+		skb->len = msg->length;
+	}
+
+	if (sock_queue_rcv_skb(sk, skb))
+		kfree_skb(skb);
+}
+
+static void iucv_callback_txdone(struct iucv_path *path,
+				 struct iucv_message *msg)
+{
+	struct sock *sk = path->private;
+	struct sk_buff *this;
+	struct sk_buff_head *list = &iucv_sk(sk)->send_skb_q;
+	struct sk_buff *list_skb = list->next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&list->lock, flags);
+
+	do {
+		this = list_skb;
+		list_skb = list_skb->next;
+	} while (memcmp(&msg->tag, this->cb, 4));
+
+	spin_unlock_irqrestore(&list->lock, flags);
+
+	skb_unlink(this, &iucv_sk(sk)->send_skb_q);
+	kfree_skb(this);
+}
+
+static void iucv_callback_connrej(struct iucv_path *path, u8 ipuser[16])
+{
+	struct sock *sk = path->private;
+
+	if (!list_empty(&iucv_sk(sk)->accept_q))
+		sk->sk_state = IUCV_SEVERED;
+	else
+		sk->sk_state = IUCV_DISCONN;
+
+	sk->sk_state_change(sk);
+}
+
+static struct proto_ops iucv_sock_ops = {
+	.family		= PF_IUCV,
+	.owner		= THIS_MODULE,
+	.release	= iucv_sock_release,
+	.bind		= iucv_sock_bind,
+	.connect	= iucv_sock_connect,
+	.listen		= iucv_sock_listen,
+	.accept		= iucv_sock_accept,
+	.getname	= iucv_sock_getname,
+	.sendmsg	= iucv_sock_sendmsg,
+	.recvmsg	= iucv_sock_recvmsg,
+	.poll		= iucv_sock_poll,
+	.ioctl		= sock_no_ioctl,
+	.mmap		= sock_no_mmap,
+	.socketpair	= sock_no_socketpair,
+	.shutdown	= iucv_sock_shutdown,
+	.setsockopt	= sock_no_setsockopt,
+	.getsockopt	= sock_no_getsockopt
+};
+
+static struct net_proto_family iucv_sock_family_ops = {
+	.family	= AF_IUCV,
+	.owner	= THIS_MODULE,
+	.create	= iucv_sock_create,
+};
+
+static int afiucv_init(void)
+{
+	int err;
+
+	if (!MACHINE_IS_VM) {
+		printk(KERN_ERR "AF_IUCV connection needs VM as base\n");
+		err = -EPROTONOSUPPORT;
+		goto out;
+	}
+	cpcmd("QUERY USERID", iucv_userid, sizeof(iucv_userid), &err);
+	if (unlikely(err)) {
+		printk(KERN_ERR "AF_IUCV needs the VM userid\n");
+		err = -EPROTONOSUPPORT;
+		goto out;
+	}
+
+	err = iucv_register(&af_iucv_handler, 0);
+	if (err)
+		goto out;
+	err = proto_register(&iucv_proto, 0);
+	if (err)
+		goto out_iucv;
+	err = sock_register(&iucv_sock_family_ops);
+	if (err)
+		goto out_proto;
+	printk(KERN_INFO "AF_IUCV lowlevel driver initialized\n");
+	return 0;
+
+out_proto:
+	proto_unregister(&iucv_proto);
+out_iucv:
+	iucv_unregister(&af_iucv_handler, 0);
+out:
+	return err;
+}
+
+static void __exit afiucv_exit(void)
+{
+	sock_unregister(PF_IUCV);
+	proto_unregister(&iucv_proto);
+	iucv_unregister(&af_iucv_handler, 0);
+
+	printk(KERN_INFO "AF_IUCV lowlevel driver unloaded\n");
+}
+
+module_init(afiucv_init);
+module_exit(afiucv_exit);
+
+MODULE_AUTHOR("Jennifer Hunt <jenhunt@us.ibm.com>");
+MODULE_DESCRIPTION("IUCV Sockets ver " VERSION);
+MODULE_VERSION(VERSION);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_IUCV);
-- 
1.4.2.3

