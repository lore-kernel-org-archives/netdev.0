From: Andy Grover <andy.grover@oracle.com>
Subject: [ofa-general] [PATCH 01/21] RDS: Socket interface
Date: Mon, 26 Jan 2009 18:17:38 -0800
Message-ID: <1233022678-9259-2-git-send-email-andy.grover@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Implement the RDS (Reliable Datagram Sockets) interface.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 drivers/infiniband/ulp/rds/af_rds.c |  677 +++++++++++++++++++++++++++++++++++
 drivers/infiniband/ulp/rds/bind.c   |  202 +++++++++++
 2 files changed, 879 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/rds/af_rds.c
 create mode 100644 drivers/infiniband/ulp/rds/bind.c

diff --git a/drivers/infiniband/ulp/rds/af_rds.c b/drivers/infiniband/ulp/rds/af_rds.c
new file mode 100644
index 0000000..7158438
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/af_rds.c
@@ -0,0 +1,677 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/in.h>
+#include <linux/poll.h>
+#include <linux/version.h>
+#include <net/sock.h>
+
+#include "rds.h"
+#include "rdma.h"
+
+static int enable_rdma = 1;
+
+module_param(enable_rdma, int, 0444);
+MODULE_PARM_DESC(enable_rdma, " Enable RDMA operations support");
+
+/* this is just used for stats gathering :/ */
+static DEFINE_SPINLOCK(rds_sock_lock);
+static unsigned long rds_sock_count;
+static LIST_HEAD(rds_sock_list);
+DECLARE_WAIT_QUEUE_HEAD(rds_poll_waitq);
+
+/*
+ * This is called as the final descriptor referencing this socket is closed.
+ * We have to unbind the socket so that another socket can be bound to the
+ * address it was using.
+ *
+ * We have to be careful about racing with the incoming path.  sock_orphan()
+ * sets SOCK_DEAD and we use that as an indicator to the rx path that new
+ * messages shouldn't be queued.
+ */
+static int rds_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct rds_sock *rs;
+	unsigned long flags;
+
+	if (sk == NULL)
+		goto out;
+
+	rs = rds_sk_to_rs(sk);
+
+	sock_orphan(sk);
+	/* Note - rds_clear_recv_queue grabs rs_recv_lock, so
+	 * that ensures the recv path has completed messing
+	 * with the socket. */
+	rds_clear_recv_queue(rs);
+	rds_cong_remove_socket(rs);
+	rds_remove_bound(rs);
+	rds_send_drop_to(rs, NULL);
+	rds_rdma_drop_keys(rs);
+	rds_notify_queue_get(rs, NULL);
+
+	spin_lock_irqsave(&rds_sock_lock, flags);
+	list_del_init(&rs->rs_item);
+	rds_sock_count--;
+	spin_unlock_irqrestore(&rds_sock_lock, flags);
+
+	sock->sk = NULL;
+	sock_put(sk);
+out:
+	return 0;
+}
+
+/*
+ * Careful not to race with rds_release -> sock_orphan which clears sk_sleep.
+ * _bh() isn't OK here, we're called from interrupt handlers.  It's probably OK
+ * to wake the waitqueue after sk_sleep is clear as we hold a sock ref, but
+ * this seems more conservative.
+ * NB - normally, one would use sk_callback_lock for this, but we can
+ * get here from interrupts, whereas the network code grabs sk_callback_lock
+ * with _lock_bh only - so relying on sk_callback_lock introduces livelocks.
+ */
+void rds_wake_sk_sleep(struct rds_sock *rs)
+{
+	unsigned long flags;
+
+	read_lock_irqsave(&rs->rs_recv_lock, flags);
+	__rds_wake_sk_sleep(rds_rs_to_sk(rs));
+	read_unlock_irqrestore(&rs->rs_recv_lock, flags);
+}
+
+static int rds_getname(struct socket *sock, struct sockaddr *uaddr,
+		       int *uaddr_len, int peer)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)uaddr;
+	struct rds_sock *rs = rds_sk_to_rs(sock->sk);
+
+	memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+
+	/* racey, don't care */
+	if (peer) {
+		if (!rs->rs_conn_addr)
+			return -ENOTCONN;
+
+		sin->sin_port = rs->rs_conn_port;
+		sin->sin_addr.s_addr = rs->rs_conn_addr;
+	} else {
+		sin->sin_port = rs->rs_bound_port;
+		sin->sin_addr.s_addr = rs->rs_bound_addr;
+	}
+
+	sin->sin_family = AF_INET;
+
+	*uaddr_len = sizeof(*sin);
+	return 0;
+}
+
+/*
+ * RDS' poll is without a doubt the least intuitive part of the interface,
+ * as POLLIN and POLLOUT do not behave entirely as you would expect from
+ * a network protocol.
+ *
+ * POLLIN is asserted if
+ *  -	there is data on the receive queue.
+ *  -	to signal that a previously congested destination may have become
+ *	uncongested
+ *  -	A notification has been queued to the socket (this can be a congestion
+ *	update, or a RDMA completion).
+ *
+ * POLLOUT is asserted if there is room on the send queue. This does not mean
+ * however, that the next sendmsg() call will succeed. If the application tries
+ * to send to a congested destination, the system call may still fail (and
+ * return ENOBUFS).
+ */
+static unsigned int rds_poll(struct file *file, struct socket *sock,
+			     poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	struct rds_sock *rs = rds_sk_to_rs(sk);
+	unsigned int mask = 0;
+	unsigned long flags;
+
+	poll_wait(file, sk->sk_sleep, wait);
+
+	poll_wait(file, &rds_poll_waitq, wait);
+
+	read_lock_irqsave(&rs->rs_recv_lock, flags);
+	if (!rs->rs_cong_monitor) {
+		/* When a congestion map was updated, we signal POLLIN for
+		 * "historical" reasons. Applications can also poll for
+		 * WRBAND instead. */
+		if (rds_cong_updated_since(&rs->rs_cong_track))
+			mask |= (POLLIN | POLLRDNORM | POLLWRBAND);
+	} else {
+		spin_lock(&rs->rs_lock);
+		if (rs->rs_cong_notify)
+			mask |= (POLLIN | POLLRDNORM);
+		spin_unlock(&rs->rs_lock);
+	}
+	if (!list_empty(&rs->rs_recv_queue)
+	 || !list_empty(&rs->rs_notify_queue))
+		mask |= (POLLIN | POLLRDNORM);
+	if (rs->rs_snd_bytes < rds_sk_sndbuf(rs))
+		mask |= (POLLOUT | POLLWRNORM);
+	read_unlock_irqrestore(&rs->rs_recv_lock, flags);
+
+	return mask;
+}
+
+static int rds_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+#ifdef KERNEL_HAS_CORE_CALLING_DEV_IOCTL
+	return -ENOIOCTLCMD;
+#endif /* KERNEL_HAS_CORE_CALLING_DEV_IOCTL */
+#ifndef KERNEL_HAS_CORE_CALLING_DEV_IOCTL
+	return dev_ioctl(cmd, (void __user *)arg);
+#endif /* KERNEL_HAS_CORE_CALLING_DEV_IOCTL */
+}
+
+static int rds_cancel_sent_to(struct rds_sock *rs, char __user *optval,
+			      int len)
+{
+	struct sockaddr_in sin;
+	int ret = 0;
+
+	/* racing with another thread binding seems ok here */
+	if (rs->rs_bound_addr == 0) {
+		ret = -ENOTCONN; /* XXX not a great errno */
+		goto out;
+	}
+
+	if (len < sizeof(struct sockaddr_in)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (copy_from_user(&sin, optval, sizeof(sin))) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	rds_send_drop_to(rs, &sin);
+out:
+	return ret;
+}
+
+static int rds_set_bool_option(unsigned char *optvar, char __user *optval,
+			       int optlen)
+{
+	int value;
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+	if (get_user(value, (int __user *) optval))
+		return -EFAULT;
+	*optvar = !!value;
+	return 0;
+}
+
+static int rds_cong_monitor(struct rds_sock *rs, char __user *optval,
+			    int optlen)
+{
+	int ret;
+
+	ret = rds_set_bool_option(&rs->rs_cong_monitor, optval, optlen);
+	if (ret == 0) {
+		if (rs->rs_cong_monitor) {
+			rds_cong_add_socket(rs);
+		} else {
+			rds_cong_remove_socket(rs);
+			rs->rs_cong_mask = 0;
+			rs->rs_cong_notify = 0;
+		}
+	}
+	return ret;
+}
+
+static int rds_setsockopt(struct socket *sock, int level, int optname,
+			  char __user *optval, int optlen)
+{
+	struct rds_sock *rs = rds_sk_to_rs(sock->sk);
+	int ret;
+
+	if (level != SOL_RDS) {
+		ret = -ENOPROTOOPT;
+		goto out;
+	}
+
+	switch (optname) {
+	case RDS_CANCEL_SENT_TO:
+		ret = rds_cancel_sent_to(rs, optval, optlen);
+		break;
+	case RDS_GET_MR:
+		if (enable_rdma)
+			ret = rds_get_mr(rs, optval, optlen);
+		else
+			ret = -EOPNOTSUPP;
+			break;
+	case RDS_FREE_MR:
+		if (enable_rdma)
+			ret = rds_free_mr(rs, optval, optlen);
+		else
+			ret = -EOPNOTSUPP;
+		break;
+	case RDS_RECVERR:
+		ret = rds_set_bool_option(&rs->rs_recverr, optval, optlen);
+		break;
+	case RDS_CONG_MONITOR:
+		ret = rds_cong_monitor(rs, optval, optlen);
+		break;
+	default:
+		ret = -ENOPROTOOPT;
+	}
+out:
+	return ret;
+}
+
+static int rds_getsockopt(struct socket *sock, int level, int optname,
+			  char __user *optval, int __user *optlen)
+{
+	struct rds_sock *rs = rds_sk_to_rs(sock->sk);
+	int ret = -ENOPROTOOPT, len;
+
+	if (level != SOL_RDS)
+		goto out;
+
+	if (get_user(len, optlen)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	switch (optname) {
+	case RDS_INFO_FIRST ... RDS_INFO_LAST:
+		ret = rds_info_getsockopt(sock, optname, optval,
+					  optlen);
+		break;
+
+	case RDS_RECVERR:
+		if (len < sizeof(int))
+			ret = -EINVAL;
+		else
+		if (put_user(rs->rs_recverr, (int __user *) optval)
+		 || put_user(sizeof(int), optlen))
+			ret = -EFAULT;
+		else
+			ret = 0;
+		break;
+	default:
+		break;
+	}
+
+out:
+	return ret;
+
+}
+
+static int rds_connect(struct socket *sock, struct sockaddr *uaddr,
+		       int addr_len, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct sockaddr_in *sin = (struct sockaddr_in *)uaddr;
+	struct rds_sock *rs = rds_sk_to_rs(sk);
+	int ret = 0;
+
+	lock_sock(sk);
+
+	if (addr_len != sizeof(struct sockaddr_in)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (sin->sin_family != AF_INET) {
+		ret = -EAFNOSUPPORT;
+		goto out;
+	}
+
+	if (sin->sin_addr.s_addr == htonl(INADDR_ANY)) {
+		ret = -EDESTADDRREQ;
+		goto out;
+	}
+
+	rs->rs_conn_addr = sin->sin_addr.s_addr;
+	rs->rs_conn_port = sin->sin_port;
+
+out:
+	release_sock(sk);
+	return ret;
+}
+
+#ifdef KERNEL_HAS_PROTO_REGISTER
+static struct proto rds_proto = {
+	.name	  = "RDS",
+	.owner	  = THIS_MODULE,
+	.obj_size = sizeof(struct rds_sock),
+};
+#endif /* KERNEL_HAS_PROTO_REGISTER */
+
+static struct proto_ops rds_proto_ops = {
+	.family =	AF_RDS,
+	.owner =	THIS_MODULE,
+	.release =	rds_release,
+	.bind =		rds_bind,
+	.connect =	rds_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	sock_no_accept,
+	.getname =	rds_getname,
+	.poll =		rds_poll,
+	.ioctl =	rds_ioctl,
+	.listen =	sock_no_listen,
+	.shutdown =	sock_no_shutdown,
+	.setsockopt =	rds_setsockopt,
+	.getsockopt =	rds_getsockopt,
+	.sendmsg =	rds_sendmsg,
+	.recvmsg =	rds_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
+};
+
+#ifndef KERNEL_HAS_PROTO_REGISTER
+static struct sock *sk_alloc_compat(int pf, gfp_t gfp, struct proto *prot,
+				    int zero_it)
+{
+	struct rds_sock *rs;
+
+	sk = sk_alloc(pf, gfp, prot, zero_it);
+	if (sk == NULL)
+		return NULL;
+
+	rs = kcalloc(1, sizeof(struct rds_sock), GFP_ATOMIC);
+	if (rs == NULL) {
+		sk_free(sk);
+		return NULL;
+	}
+
+	/* sock_def_destruct frees this for us */
+	sk->sk_protinfo = rs;
+	rs->rs_sk = sk;
+
+	return sk;
+}
+
+#undef sk_alloc
+#define sk_alloc sk_alloc_compat
+#endif /* KERNEL_HAS_PROTO_REGISTER */
+
+static int __rds_create(struct socket *sock, struct sock *sk, int protocol)
+{
+	unsigned long flags;
+	struct rds_sock *rs;
+
+	sock_init_data(sock, sk);
+#ifndef KERNEL_HAS_PROTO_REGISTER
+	/* Can this be moved to sk_alloc_compat? */
+	sk_set_owner(sk, THIS_MODULE);
+#endif /* KERNEL_HAS_PROTO_REGISTER */
+	sock->ops		= &rds_proto_ops;
+	sk->sk_protocol		= protocol;
+
+	rs = rds_sk_to_rs(sk);
+	spin_lock_init(&rs->rs_lock);
+	rwlock_init(&rs->rs_recv_lock);
+	INIT_LIST_HEAD(&rs->rs_send_queue);
+	INIT_LIST_HEAD(&rs->rs_recv_queue);
+	INIT_LIST_HEAD(&rs->rs_notify_queue);
+	INIT_LIST_HEAD(&rs->rs_cong_list);
+	spin_lock_init(&rs->rs_rdma_lock);
+	rs->rs_rdma_keys = RB_ROOT;
+
+	spin_lock_irqsave(&rds_sock_lock, flags);
+	list_add_tail(&rs->rs_item, &rds_sock_list);
+	rds_sock_count++;
+	spin_unlock_irqrestore(&rds_sock_lock, flags);
+
+	return 0;
+}
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 24)
+static int rds_create(struct socket *sock, int protocol)
+{
+	struct sock *sk;
+
+	if (sock->type != SOCK_SEQPACKET || protocol)
+		return -ESOCKTNOSUPPORT;
+
+	sk = sk_alloc(AF_RDS, GFP_ATOMIC, &rds_proto, 1);
+	if (sk == NULL)
+		return -ENOMEM;
+
+	return __rds_create(sock, sk, protocol);
+}
+#else
+static int rds_create(struct net *net, struct socket *sock, int protocol)
+{
+	struct sock *sk;
+
+	if (sock->type != SOCK_SEQPACKET || protocol)
+		return -ESOCKTNOSUPPORT;
+
+	sk = sk_alloc(net, AF_RDS, GFP_ATOMIC, &rds_proto);
+	if (!sk)
+		return -ENOMEM;
+
+	return __rds_create(sock, sk, protocol);
+}
+#endif
+
+void rds_sock_addref(struct rds_sock *rs)
+{
+	sock_hold(rds_rs_to_sk(rs));
+}
+
+void rds_sock_put(struct rds_sock *rs)
+{
+	sock_put(rds_rs_to_sk(rs));
+}
+
+static struct net_proto_family rds_family_ops = {
+	.family =	AF_RDS,
+	.create =	rds_create,
+	.owner	=	THIS_MODULE,
+};
+
+static void rds_sock_inc_info(struct socket *sock, unsigned int len,
+			      struct rds_info_iterator *iter,
+			      struct rds_info_lengths *lens)
+{
+	struct rds_sock *rs;
+	struct sock *sk;
+	struct rds_incoming *inc;
+	unsigned long flags;
+	unsigned int total = 0;
+
+	len /= sizeof(struct rds_info_message);
+
+	spin_lock_irqsave(&rds_sock_lock, flags);
+
+	list_for_each_entry(rs, &rds_sock_list, rs_item) {
+		sk = rds_rs_to_sk(rs);
+		read_lock(&rs->rs_recv_lock);
+
+		/* XXX too lazy to maintain counts.. */
+		list_for_each_entry(inc, &rs->rs_recv_queue, i_item) {
+			total++;
+			if (total <= len)
+				rds_inc_info_copy(inc, iter, inc->i_saddr,
+						  rs->rs_bound_addr, 1);
+		}
+
+		read_unlock(&rs->rs_recv_lock);
+	}
+
+	spin_unlock_irqrestore(&rds_sock_lock, flags);
+
+	lens->nr = total;
+	lens->each = sizeof(struct rds_info_message);
+}
+
+static void rds_sock_info(struct socket *sock, unsigned int len,
+			  struct rds_info_iterator *iter,
+			  struct rds_info_lengths *lens)
+{
+	struct rds_info_socket sinfo;
+	struct rds_sock *rs;
+	unsigned long flags;
+
+	len /= sizeof(struct rds_info_socket);
+
+	spin_lock_irqsave(&rds_sock_lock, flags);
+
+	if (len < rds_sock_count)
+		goto out;
+
+	list_for_each_entry(rs, &rds_sock_list, rs_item) {
+		sinfo.sndbuf = rds_sk_sndbuf(rs);
+		sinfo.rcvbuf = rds_sk_rcvbuf(rs);
+		sinfo.bound_addr = rs->rs_bound_addr;
+		sinfo.connected_addr = rs->rs_conn_addr;
+		sinfo.bound_port = rs->rs_bound_port;
+		sinfo.connected_port = rs->rs_conn_port;
+		sinfo.inum = sock_i_ino(rds_rs_to_sk(rs));
+
+		rds_info_copy(iter, &sinfo, sizeof(sinfo));
+	}
+
+out:
+	lens->nr = rds_sock_count;
+	lens->each = sizeof(struct rds_info_socket);
+
+	spin_unlock_irqrestore(&rds_sock_lock, flags);
+}
+
+/*
+ * The order is important here.
+ *
+ * rds_trans_stop_listening() is called before conn_exit so new connections
+ * don't hit while existing ones are being torn down.
+ *
+ * rds_conn_exit() is before rds_trans_exit() as rds_conn_exit() calls into the
+ * transports to free connections and incoming fragments as they're torn down.
+ */
+static void __exit rds_exit(void)
+{
+	rds_ib_exit();
+	sock_unregister(rds_family_ops.family);
+#ifdef KERNEL_HAS_PROTO_REGISTER
+	proto_unregister(&rds_proto);
+#endif /* KERNEL_HAS_PROTO_REGISTER */
+	rds_trans_stop_listening();
+	rds_conn_exit();
+	rds_cong_exit();
+	rds_sysctl_exit();
+	rds_threads_exit();
+	rds_stats_exit();
+	rds_page_exit();
+	rds_info_deregister_func(RDS_INFO_SOCKETS, rds_sock_info);
+	rds_info_deregister_func(RDS_INFO_RECV_MESSAGES, rds_sock_inc_info);
+}
+module_exit(rds_exit);
+
+static int __init rds_init(void)
+{
+	int ret;
+
+#ifndef KERNEL_HAS_NOT_DEFINED
+	/* the strange ifdef above has scripts/makepatch.sh strip this out */
+#if PF_RDS == 21
+	printk(KERN_ERR "!!! This build of RDS is using PF 21 which is not "
+	       "reserved\n");
+	printk(KERN_ERR "!!! This is only suitable for testing, DO NOT "
+	       "RELEASE THIS.\n");
+	printk(KERN_ERR "!!! No, seriously.\n");
+#endif
+#endif /* KERNEL_HAS_NOT_DEFINED */
+
+	ret = rds_conn_init();
+	if (ret)
+		goto out;
+	ret = rds_threads_init();
+	if (ret)
+		goto out_conn;
+	ret = rds_sysctl_init();
+	if (ret)
+		goto out_threads;
+	ret = rds_stats_init();
+	if (ret)
+		goto out_sysctl;
+#ifdef KERNEL_HAS_PROTO_REGISTER
+	ret = proto_register(&rds_proto, 1);
+	if (ret)
+		goto out_stats;
+#endif /* KERNEL_HAS_PROTO_REGISTER */
+	ret = sock_register(&rds_family_ops);
+	if (ret)
+		goto out_proto;
+
+	rds_info_register_func(RDS_INFO_SOCKETS, rds_sock_info);
+	rds_info_register_func(RDS_INFO_RECV_MESSAGES, rds_sock_inc_info);
+
+	ret = rds_ib_init();
+	if (ret)
+		goto out_sock;
+	goto out;
+
+out_sock:
+	sock_unregister(rds_family_ops.family);
+out_proto:
+#ifdef KERNEL_HAS_PROTO_REGISTER
+	proto_unregister(&rds_proto);
+out_stats:
+#endif /* KERNEL_HAS_PROTO_REGISTER */
+	rds_stats_exit();
+out_sysctl:
+	rds_sysctl_exit();
+out_threads:
+	rds_threads_exit();
+out_conn:
+	rds_conn_exit();
+	rds_cong_exit();
+	rds_page_exit();
+out:
+	return ret;
+}
+module_init(rds_init);
+
+#define DRV_VERSION     "4.0"
+#define DRV_RELDATE     "July 28, 2008"
+
+MODULE_AUTHOR("Zach Brown");
+MODULE_AUTHOR("Olaf Kirch");
+MODULE_DESCRIPTION("RDS: Reliable Datagram Sockets"
+		   " v" DRV_VERSION " (" DRV_RELDATE ")");
+MODULE_VERSION(DRV_VERSION);
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_ALIAS_NETPROTO(PF_RDS);
diff --git a/drivers/infiniband/ulp/rds/bind.c b/drivers/infiniband/ulp/rds/bind.c
new file mode 100644
index 0000000..0f625d0
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/bind.c
@@ -0,0 +1,202 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/kernel.h>
+#include <net/sock.h>
+#include <linux/in.h>
+#include <linux/if_arp.h>
+#include "rds.h"
+
+/*
+ * XXX this probably still needs more work.. no INADDR_ANY, and rbtrees aren't
+ * particularly zippy.
+ *
+ * This is now called for every incoming frame so we arguably care much more
+ * about it than we used to.
+ */
+static DEFINE_SPINLOCK(rds_bind_lock);
+static struct rb_root rds_bind_tree = RB_ROOT;
+
+static struct rds_sock *rds_bind_tree_walk(__be32 addr, __be16 port,
+					   struct rds_sock *insert)
+{
+	struct rb_node **p = &rds_bind_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct rds_sock *rs;
+	u64 cmp;
+	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
+
+	while (*p) {
+		parent = *p;
+		rs = rb_entry(parent, struct rds_sock, rs_bound_node);
+
+		cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
+		      be16_to_cpu(rs->rs_bound_port);
+
+		if (needle < cmp)
+			p = &(*p)->rb_left;
+		else if (needle > cmp)
+			p = &(*p)->rb_right;
+		else
+			return rs;
+	}
+
+	if (insert) {
+		rb_link_node(&insert->rs_bound_node, parent, p);
+		rb_insert_color(&insert->rs_bound_node, &rds_bind_tree);
+	}
+	return NULL;
+}
+
+/*
+ * Return the rds_sock bound at the given local address.
+ *
+ * The rx path can race with rds_release.  We notice if rds_release() has
+ * marked this socket and don't return a rs ref to the rx path.
+ */
+struct rds_sock *rds_find_bound(__be32 addr, __be16 port)
+{
+	struct rds_sock *rs;
+	unsigned long flags;
+
+	spin_lock_irqsave(&rds_bind_lock, flags);
+	rs = rds_bind_tree_walk(addr, port, NULL);
+	if (rs && !sock_flag(rds_rs_to_sk(rs), SOCK_DEAD))
+		rds_sock_addref(rs);
+	else
+		rs = NULL;
+	spin_unlock_irqrestore(&rds_bind_lock, flags);
+
+	rdsdebug("returning rs %p for %u.%u.%u.%u:%u\n", rs, NIPQUAD(addr),
+		ntohs(port));
+	return rs;
+}
+
+/* returns -ve errno or +ve port */
+static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
+{
+	unsigned long flags;
+	int ret = -EADDRINUSE;
+	u16 rover, last;
+
+	if (*port != 0) {
+		rover = be16_to_cpu(*port);
+		last = rover;
+	} else {
+		rover = max_t(u16, net_random(), 2);
+		last = rover - 1;
+	}
+
+	spin_lock_irqsave(&rds_bind_lock, flags);
+
+	do {
+		if (rover == 0)
+			rover++;
+		if (rds_bind_tree_walk(addr, cpu_to_be16(rover), rs) == NULL) {
+			*port = cpu_to_be16(rover);
+			ret = 0;
+			break;
+		}
+	} while (rover++ != last);
+
+	if (ret == 0)  {
+		rs->rs_bound_addr = addr;
+		rs->rs_bound_port = *port;
+		rds_sock_addref(rs);
+
+		rdstrace(RDS_BIND, RDS_LOW,
+		  "rs %p binding to %u.%u.%u.%u:%d\n",
+		  rs, NIPQUAD(addr), (int)ntohs(*port));
+
+	}
+
+	spin_unlock_irqrestore(&rds_bind_lock, flags);
+
+	return ret;
+}
+
+void rds_remove_bound(struct rds_sock *rs)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&rds_bind_lock, flags);
+
+	if (rs->rs_bound_addr) {
+		rdstrace(RDS_BIND, RDS_LOW,
+		  "rs %p unbinding from %u.%u.%u.%u:%d\n",
+		  rs, NIPQUAD(rs->rs_bound_addr),
+		  (int)ntohs(rs->rs_bound_port));
+
+		rb_erase(&rs->rs_bound_node, &rds_bind_tree);
+		rds_sock_put(rs);
+		rs->rs_bound_addr = 0;
+	}
+
+	spin_unlock_irqrestore(&rds_bind_lock, flags);
+}
+
+int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
+{
+	struct sock *sk = sock->sk;
+	struct sockaddr_in *sin = (struct sockaddr_in *)uaddr;
+	struct rds_sock *rs = rds_sk_to_rs(sk);
+	struct rds_transport *trans;
+	int ret = 0;
+
+	lock_sock(sk);
+
+	if (addr_len != sizeof(struct sockaddr_in) ||
+	    sin->sin_family != AF_INET ||
+	    rs->rs_bound_addr ||
+	    sin->sin_addr.s_addr == htonl(INADDR_ANY)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = rds_add_bound(rs, sin->sin_addr.s_addr, &sin->sin_port);
+	if (ret)
+		goto out;
+
+	trans = rds_trans_get_preferred(sin->sin_addr.s_addr);
+	if (trans == NULL) {
+		ret = -EADDRNOTAVAIL;
+		rds_remove_bound(rs);
+		goto out;
+	}
+
+	rs->rs_transport = trans;
+	ret = 0;
+
+out:
+	release_sock(sk);
+	return ret;
+}
-- 
1.5.6.3
