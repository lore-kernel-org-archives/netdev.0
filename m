From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 2/2] kproxy: Kernel proxy
Date: Thu, 29 Jun 2017 11:27:05 -0700
Message-ID: <1498760825-8516-3-git-send-email-tom@herbertland.com>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35900 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752915AbdF2S2D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 14:28:03 -0400
Received: by mail-pf0-f171.google.com with SMTP id q86so54452146pfl.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 11:27:57 -0700 (PDT)
In-Reply-To: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement an in-kernel proxy.

This patch defines a new address family for create a kproxy socket
(AF_KPROXY). Two IOCTL operations are defined SIOCKPROXYJOIN and
SIOCKPROXYUNJOIN. The first takes two (TCP) sockets and creates
a proxy between them, the latter destroys the proxy. When the
proxy is established packets received on on socket are sent on
the other. Proxy functionality (e.g. applicatation layer filtering
will be implement via BPF programs attached to the proxy.

A proc file (/prox/net/kproxy) is created to list all the running
kernel proxies and relevant statistics for them.
---
 include/linux/socket.h              |   4 +-
 include/net/kproxy.h                |  80 +++++
 include/uapi/linux/kproxy.h         |  30 ++
 net/Kconfig                         |   1 +
 net/Makefile                        |   1 +
 net/core/skbuff.c                   |   4 +-
 net/kproxy/Kconfig                  |  10 +
 net/kproxy/Makefile                 |   3 +
 net/kproxy/kproxyproc.c             | 246 +++++++++++++++
 net/kproxy/kproxysock.c             | 605 ++++++++++++++++++++++++++++++++++++
 security/selinux/hooks.c            |   4 +-
 security/selinux/include/classmap.h |   4 +-
 12 files changed, 987 insertions(+), 5 deletions(-)
 create mode 100644 include/net/kproxy.h
 create mode 100644 include/uapi/linux/kproxy.h
 create mode 100644 net/kproxy/Kconfig
 create mode 100644 net/kproxy/Makefile
 create mode 100644 net/kproxy/kproxyproc.c
 create mode 100644 net/kproxy/kproxysock.c

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8b13db5..50b8ccf 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -206,8 +206,9 @@ struct ucred {
 				 * PF_SMC protocol family that
 				 * reuses AF_INET address family
 				 */
+#define AF_KPROXY	44	/* Kernel Proxy */
 
-#define AF_MAX		44	/* For now.. */
+#define AF_MAX		45	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -257,6 +258,7 @@ struct ucred {
 #define PF_QIPCRTR	AF_QIPCRTR
 #define PF_SMC		AF_SMC
 #define PF_MAX		AF_MAX
+#define PF_KPROXY	AF_KPROXY
 
 /* Maximum queue length specifiable by listen.  */
 #define SOMAXCONN	128
diff --git a/include/net/kproxy.h b/include/net/kproxy.h
new file mode 100644
index 0000000..237f275
--- /dev/null
+++ b/include/net/kproxy.h
@@ -0,0 +1,80 @@
+/*
+ * Kernel Proxy
+ *
+ * Copyright (c) 2017 Tom Herbert <tom@quantonium.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+
+#ifndef __NET_KPROXY_H_
+#define __NET_KPROXY_H_
+
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <uapi/linux/kproxy.h>
+
+extern unsigned int kproxy_net_id;
+
+struct kproxy_stats {
+	unsigned long long tx_bytes;
+	unsigned long long rx_bytes;
+};
+
+struct kproxy_psock {
+	struct sk_buff_head rxqueue;
+	unsigned int queue_hiwat;
+	unsigned int queue_lowat;
+	unsigned int produced;
+	unsigned int consumed;
+
+	struct kproxy_stats stats;
+
+	int save_sent;
+	struct sk_buff *save_skb;
+
+	u32 tx_stopped : 1;
+	int deferred_err;
+
+	struct socket *sock;
+	struct kproxy_psock *peer;
+	struct work_struct tx_work;
+	struct work_struct rx_work;
+
+	void (*save_data_ready)(struct sock *sk);
+	void (*save_write_space)(struct sock *sk);
+	void (*save_state_change)(struct sock *sk);
+};
+
+struct kproxy_sock {
+	struct sock sk;
+
+	u32 running : 1;
+
+	struct list_head kproxy_list;
+
+	struct kproxy_psock client_sock;
+	struct kproxy_psock server_sock;
+};
+
+struct kproxy_net {
+	struct mutex mutex;
+	struct list_head kproxy_list;
+	int count;
+};
+
+static inline unsigned int kproxy_enqueued(struct kproxy_psock *psock)
+{
+		return psock->produced - psock->peer->consumed;
+}
+
+#ifdef CONFIG_PROC_FS
+int kproxy_proc_init(void);
+void kproxy_proc_exit(void);
+#else
+static inline int kproxy_proc_init(void) { return 0; }
+static inline void kproxy_proc_exit(void) { }
+#endif
+
+#endif /* __NET_KPROXY_H_ */
diff --git a/include/uapi/linux/kproxy.h b/include/uapi/linux/kproxy.h
new file mode 100644
index 0000000..d9a3e9c
--- /dev/null
+++ b/include/uapi/linux/kproxy.h
@@ -0,0 +1,30 @@
+/*
+ * Kernel Proxy
+ *
+ * Copyright (c) 2017 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * User API to create in-kernel proxies.
+ */
+
+#ifndef KPROXYKERNEL_H
+#define KPROXYKERNEL_H
+
+struct kproxy_join {
+	int client_fd;
+	int server_fd;
+};
+
+struct kproxy_unjoin {
+	int client_fd;
+	int server_fd;
+};
+
+#define SIOCKPROXYJOIN		(SIOCPROTOPRIVATE + 0)
+#define SIOCKPROXYUNJOIN	(SIOCPROTOPRIVATE + 1)
+
+#endif
+
diff --git a/net/Kconfig b/net/Kconfig
index 7d57ef3..1f2263d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -368,6 +368,7 @@ source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
 source "net/kcm/Kconfig"
+source "net/kproxy/Kconfig"
 source "net/strparser/Kconfig"
 
 config FIB_RULES
diff --git a/net/Makefile b/net/Makefile
index bed80fa..7f7026d 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
 obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_AF_KCM)		+= kcm/
+obj-$(CONFIG_AF_KPROXY)		+= kproxy/
 obj-$(CONFIG_STREAM_PARSER)	+= strparser/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_L2TP)		+= l2tp/
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ff9f88d..a3b09e4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2009,7 +2009,7 @@ EXPORT_SYMBOL_GPL(skb_splice_bits);
 int skb_send_sock(struct sk_buff *skb, struct socket *sock, unsigned int offset)
 {
 	unsigned int sent = 0;
-	unsigned int ret;
+	int ret;
 	unsigned short fragidx;
 
 	/* Deal with head data */
@@ -2053,7 +2053,7 @@ int skb_send_sock(struct sk_buff *skb, struct socket *sock, unsigned int offset)
 				      frag->page_offset + offset,
 				      frag->size - offset,
 				      MSG_DONTWAIT);
-		if (ret < 0)
+		if (ret <= 0)
 			goto error;
 
 		sent += ret;
diff --git a/net/kproxy/Kconfig b/net/kproxy/Kconfig
new file mode 100644
index 0000000..4754406
--- /dev/null
+++ b/net/kproxy/Kconfig
@@ -0,0 +1,10 @@
+
+config AF_KPROXY
+	tristate "Kernel proxy"
+	depends on INET
+	select BPF_SYSCALL
+	select STREAM_PARSER
+	---help---
+	  Kernel proxy implements an in kernel TCP proxy for performance.
+	  Filtering is done by BPF on incoming sockets.
+
diff --git a/net/kproxy/Makefile b/net/kproxy/Makefile
new file mode 100644
index 0000000..fdcd3a7
--- /dev/null
+++ b/net/kproxy/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_AF_KPROXY) += kproxy.o
+
+kproxy-y := kproxysock.o kproxyproc.o
diff --git a/net/kproxy/kproxyproc.c b/net/kproxy/kproxyproc.c
new file mode 100644
index 0000000..66699d5
--- /dev/null
+++ b/net/kproxy/kproxyproc.c
@@ -0,0 +1,246 @@
+#include <linux/in.h>
+#include <linux/inet.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/proc_fs.h>
+#include <linux/rculist.h>
+#include <linux/seq_file.h>
+#include <linux/socket.h>
+#include <net/inet_sock.h>
+#include <net/kproxy.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
+#ifdef CONFIG_PROC_FS
+struct kproxy_seq_proxyinfo {
+	char				*name;
+	const struct file_operations	*seq_fops;
+	const struct seq_operations	seq_ops;
+};
+
+static struct kproxy_sock *kproxy_get_first(struct seq_file *seq)
+{
+	struct net *net = seq_file_net(seq);
+	struct kproxy_net *knet = net_generic(net, kproxy_net_id);
+
+	return list_first_or_null_rcu(&knet->kproxy_list,
+				      struct kproxy_sock, kproxy_list);
+}
+
+static struct kproxy_sock *kproxy_get_next(struct kproxy_sock *kproxy)
+{
+	struct kproxy_net *knet = net_generic(sock_net(&kproxy->sk),
+					      kproxy_net_id);
+
+	return list_next_or_null_rcu(&knet->kproxy_list,
+				     &kproxy->kproxy_list,
+				     struct kproxy_sock, kproxy_list);
+}
+
+static struct kproxy_sock *kproxy_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct net *net = seq_file_net(seq);
+	struct kproxy_net *knet = net_generic(net, kproxy_net_id);
+	struct kproxy_sock *ksock;
+
+	list_for_each_entry_rcu(ksock, &knet->kproxy_list, kproxy_list) {
+		if (!pos)
+			return ksock;
+		--pos;
+	}
+	return NULL;
+}
+
+static void *kproxy_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	void *p;
+
+	if (v == SEQ_START_TOKEN)
+		p = kproxy_get_first(seq);
+	else
+		p = kproxy_get_next(v);
+	++*pos;
+	return p;
+}
+
+static void *kproxy_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rcu)
+{
+	rcu_read_lock();
+
+	if (!*pos)
+		return SEQ_START_TOKEN;
+	else
+		return kproxy_get_idx(seq, *pos - 1);
+}
+
+static void kproxy_seq_stop(struct seq_file *seq, void *v)
+	__releases(rcu)
+{
+	rcu_read_unlock();
+}
+
+struct kproxy_proc_proxy_state {
+	struct seq_net_private p;
+	int idx;
+};
+
+static int kproxy_seq_open(struct inode *inode, struct file *file)
+{
+	struct kproxy_seq_proxyinfo *proxyinfo = PDE_DATA(inode);
+
+	return seq_open_net(inode, file, &proxyinfo->seq_ops,
+			   sizeof(struct kproxy_proc_proxy_state));
+}
+
+static void kproxy_format_proxy_header(struct seq_file *seq)
+{
+	struct net *net = seq_file_net(seq);
+	struct kproxy_net *knet = net_generic(net, kproxy_net_id);
+
+	seq_printf(seq, "*** kProxy **** (%d proxies)\n",
+		   knet->count);
+
+	seq_printf(seq,
+		   "%-16s %-16s %-10s %-16s %-16s %-10s %s\n",
+		   "Client-RX-bytes",
+		   "ClientQ",
+		   "Server-TX-bytes",
+		   "Server-RX-bytes",
+		   "Client-TX-bytes",
+		   "ServerQ",
+		   "Addresses"
+	);
+}
+
+static void kproxy_format_addresses(struct seq_file *seq,
+				    struct sock *sk)
+{
+	switch (sk->sk_family) {
+	case AF_INET: {
+		struct inet_sock *inet = inet_sk(sk);
+
+		seq_printf(seq, "%pI4:%u->%pI4:%u",
+			   &inet->inet_saddr, ntohs(inet->inet_sport),
+			   &inet->inet_daddr, ntohs(inet->inet_dport));
+		break;
+	}
+	case AF_INET6: {
+		struct inet_sock *inet = (struct inet_sock *)sk;
+
+		seq_printf(seq, "%pI6:%u->%pI6:%u",
+			   &sk->sk_v6_rcv_saddr, ntohs(inet->inet_sport),
+			   &sk->sk_v6_daddr, ntohs(inet->inet_dport));
+		break;
+	}
+	default:
+		seq_puts(seq, "Unknown-family");
+	}
+}
+
+static void kproxy_format_proxy(struct kproxy_sock *ksock,
+				struct seq_file *seq)
+{
+	seq_printf(seq, "%-16llu %-16llu %-10u %-16llu %-16llu %-10u",
+		   ksock->client_sock.stats.rx_bytes,
+		   ksock->server_sock.stats.tx_bytes,
+		   kproxy_enqueued(&ksock->client_sock),
+		   ksock->server_sock.stats.rx_bytes,
+		   ksock->client_sock.stats.tx_bytes,
+		   kproxy_enqueued(&ksock->server_sock));
+
+	kproxy_format_addresses(seq, ksock->client_sock.sock->sk);
+	seq_puts(seq, " ");
+	kproxy_format_addresses(seq, ksock->server_sock.sock->sk);
+
+	seq_puts(seq, "\n");
+}
+
+static int kproxy_seq_show(struct seq_file *seq, void *v)
+{
+	struct kproxy_proc_proxy_state *proxy_state;
+
+	proxy_state = seq->private;
+	if (v == SEQ_START_TOKEN) {
+		proxy_state->idx = 0;
+		kproxy_format_proxy_header(seq);
+	} else {
+		kproxy_format_proxy(v, seq);
+		proxy_state->idx++;
+	}
+	return 0;
+}
+
+static const struct file_operations kproxy_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= kproxy_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_net,
+};
+
+static struct kproxy_seq_proxyinfo kproxy_seq_proxyinfo = {
+	.name		= "kproxy",
+	.seq_fops	= &kproxy_seq_fops,
+	.seq_ops	= {
+		.show	= kproxy_seq_show,
+		.start	= kproxy_seq_start,
+		.next	= kproxy_seq_next,
+		.stop	= kproxy_seq_stop,
+	}
+};
+
+static int kproxy_proc_register(struct net *net,
+				struct kproxy_seq_proxyinfo *proxyinfo)
+{
+	struct proc_dir_entry *p;
+	int rc = 0;
+
+	p = proc_create_data(proxyinfo->name, 0444, net->proc_net,
+			     proxyinfo->seq_fops, proxyinfo);
+	if (!p)
+		rc = -ENOMEM;
+	return rc;
+}
+EXPORT_SYMBOL(kproxy_proc_register);
+
+static void kproxy_proc_unregister(struct net *net,
+				   struct kproxy_seq_proxyinfo *proxyinfo)
+{
+	remove_proc_entry(proxyinfo->name, net->proc_net);
+}
+EXPORT_SYMBOL(kproxy_proc_unregister);
+
+static int kproxy_proc_init_net(struct net *net)
+{
+	int err;
+
+	err = kproxy_proc_register(net, &kproxy_seq_proxyinfo);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+static void kproxy_proc_exit_net(struct net *net)
+{
+	kproxy_proc_unregister(net, &kproxy_seq_proxyinfo);
+}
+
+static struct pernet_operations kproxy_net_ops = {
+	.init = kproxy_proc_init_net,
+	.exit = kproxy_proc_exit_net,
+};
+
+int __init kproxy_proc_init(void)
+{
+	return register_pernet_subsys(&kproxy_net_ops);
+}
+
+void __exit kproxy_proc_exit(void)
+{
+	unregister_pernet_subsys(&kproxy_net_ops);
+}
+
+#endif /* CONFIG_PROC_FS */
diff --git a/net/kproxy/kproxysock.c b/net/kproxy/kproxysock.c
new file mode 100644
index 0000000..1e71d51
--- /dev/null
+++ b/net/kproxy/kproxysock.c
@@ -0,0 +1,605 @@
+/*
+ * Kernel Proxy
+ *
+ * Copyright (c) 2017 Tom Herbert <tom@quantonium.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+
+#include <linux/errno.h>
+#include <linux/file.h>
+#include <linux/in.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/rculist.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/workqueue.h>
+#include <net/kproxy.h>
+#include <net/netns/generic.h>
+#include <net/sock.h>
+#include <uapi/linux/kproxy.h>
+
+unsigned int kproxy_net_id;
+
+static inline struct kproxy_sock *kproxy_sk(const struct sock *sk)
+{
+	return (struct kproxy_sock *)sk;
+}
+
+static inline struct kproxy_psock *kproxy_psock_sk(const struct sock *sk)
+{
+	return (struct kproxy_psock *)sk->sk_user_data;
+}
+
+static void kproxy_report_sk_error(struct kproxy_psock *psock, int err,
+				   bool hard_report)
+{
+	struct sock *sk = psock->sock->sk;
+
+	/* Check if we still have stuff in receive queue that we might be
+	 * able to finish sending on the peer socket. Hold off on reporting
+	 * the error if there is data queued and not a hard error.
+	 */
+	if (hard_report || !kproxy_enqueued(psock)) {
+		sk->sk_err = err;
+		sk->sk_error_report(sk);
+	} else {
+		psock->deferred_err = err;
+	}
+}
+
+static void kproxy_report_deferred_error(struct kproxy_psock *psock)
+{
+	struct sock *sk = psock->sock->sk;
+
+	sk->sk_err = psock->deferred_err;
+	sk->sk_error_report(sk);
+}
+
+static void kproxy_state_change(struct sock *sk)
+{
+	kproxy_report_sk_error(kproxy_psock_sk(sk), EPIPE, false);
+}
+
+void schedule_writer(struct kproxy_psock *psock)
+{
+	schedule_work(&psock->tx_work);
+}
+
+static int kproxy_recv(read_descriptor_t *desc, struct sk_buff *skb,
+		       unsigned int offset, size_t len)
+{
+	struct kproxy_psock *psock = (struct kproxy_psock *)desc->arg.data;
+
+	WARN_ON(len != skb->len - offset);
+
+	/* Check limit of queued data */
+	if (kproxy_enqueued(psock) > psock->queue_hiwat)
+		return 0;
+
+	/* Dequeue from lower socket and put skbufs on an internal queue
+	 * queue.
+	 */
+
+	/* Always clone since we're consuming whole skbuf */
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (!skb) {
+		desc->error = -ENOMEM;
+		return 0;
+	}
+
+	if (unlikely(offset)) {
+		/* Don't expect offsets to be present */
+
+		if (!pskb_pull(skb, offset)) {
+			kfree_skb(skb);
+			desc->error = -ENOMEM;
+			return 0;
+		}
+	}
+
+	psock->produced += skb->len;
+	psock->stats.rx_bytes += skb->len;
+
+	skb_queue_tail(&psock->rxqueue, skb);
+
+	return skb->len;
+}
+
+/* Called with lock held on lower socket */
+static int kproxy_read_sock(struct kproxy_psock *psock)
+{
+	struct socket *sock = psock->sock;
+	read_descriptor_t desc;
+
+	/* Check limit of queued data. If we're over then just
+	 * return. We'll be called again when the write has
+	 * consumed data to below queue_lowat.
+	 */
+	if (kproxy_enqueued(psock) > psock->queue_hiwat)
+		return 0;
+
+	desc.arg.data = psock;
+	desc.error = 0;
+	desc.count = 1; /* give more than one skb per call */
+
+	/* sk should be locked here, so okay to do read_sock */
+	sock->ops->read_sock(sock->sk, &desc, kproxy_recv);
+
+	/* Probably got some data, kick writer side */
+	if (likely(!skb_queue_empty(&psock->rxqueue)))
+		schedule_writer(psock->peer);
+
+	return desc.error;
+}
+
+/* Called with lock held on socket */
+static void kproxy_data_ready(struct sock *sk)
+{
+	struct kproxy_psock *psock = kproxy_psock_sk(sk);
+
+	if (unlikely(!psock))
+		return;
+
+	read_lock_bh(&sk->sk_callback_lock);
+
+	if (kproxy_read_sock(psock) == -ENOMEM)
+		schedule_work(&psock->rx_work);
+
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+
+static void check_for_rx_wakeup(struct kproxy_psock *psock,
+				int orig_consumed)
+{
+	int started_with = psock->produced - orig_consumed;
+
+	/* Check if we fell below low watermark with new data that
+	 * was consumed and if so schedule receiver.
+	 */
+	if (started_with > psock->queue_lowat &&
+	    kproxy_enqueued(psock) <= psock->queue_lowat)
+		schedule_work(&psock->peer->rx_work);
+}
+
+static void kproxy_rx_work(struct work_struct *w)
+{
+	struct kproxy_psock *psock = container_of(w, struct kproxy_psock,
+						  rx_work);
+	struct sock *sk = psock->sock->sk;
+
+	lock_sock(sk);
+	if (kproxy_read_sock(psock) == -ENOMEM)
+		schedule_work(&psock->peer->rx_work);
+	release_sock(sk);
+}
+
+/* Perform TX side. This is only called from the workqueue so we
+ * assume mutual exclusion.
+ */
+static void kproxy_tx_work(struct work_struct *w)
+{
+	struct kproxy_psock *psock = container_of(w, struct kproxy_psock,
+						  tx_work);
+	int sent, n;
+	struct sk_buff *skb;
+	int orig_consumed = psock->consumed;
+
+	if (unlikely(psock->tx_stopped))
+		return;
+
+	if (psock->save_skb) {
+		skb = psock->save_skb;
+		sent = psock->save_sent;
+		psock->save_skb = NULL;
+		goto start;
+	}
+
+	while ((skb = skb_dequeue(&psock->peer->rxqueue))) {
+		sent = 0;
+start:
+		do {
+			n = skb_send_sock(skb, psock->sock, sent);
+			if (n <= 0) {
+				if (n == -EAGAIN) {
+					/* Save state to try again when
+					 * there's write space on the
+					 * socket.
+					 */
+					psock->save_skb = skb;
+					psock->save_sent = sent;
+					goto out;
+				}
+
+				/* Got a hard error or socket had
+				 * been closed somehow. Report this
+				 * on the transport socket.
+				 */
+//				kproxy_report_sk_error(psock,
+//						       n ? -n : EPIPE, true);
+				psock->tx_stopped = 1;
+				goto out;
+			}
+			sent += n;
+			psock->consumed += n;
+			psock->stats.tx_bytes += n;
+		} while (sent < skb->len);
+	}
+
+	if (unlikely(psock->peer->deferred_err)) {
+		/* An error had been report on the peer and
+		 * now the queue has been drained, go ahead
+		 * and report the errot.
+		 */
+		kproxy_report_deferred_error(psock->peer);
+	}
+out:
+	check_for_rx_wakeup(psock, orig_consumed);
+}
+
+static void kproxy_write_space(struct sock *sk)
+{
+	struct kproxy_psock *psock = kproxy_psock_sk(sk);
+
+	schedule_writer(psock);
+}
+
+static void kproxy_stop_sock(struct kproxy_psock *psock)
+{
+	struct sock *sk = psock->sock->sk;
+
+	/* Set up callbacks */
+	write_lock_bh(&sk->sk_callback_lock);
+	sk->sk_data_ready = psock->save_data_ready;
+	sk->sk_write_space = psock->save_write_space;
+	sk->sk_state_change = psock->save_state_change;
+	sk->sk_user_data = NULL;
+	write_unlock_bh(&sk->sk_callback_lock);
+
+	/* Shut down the workers. Sequence is important because
+	 * RX and TX can schedule on another.
+	 */
+
+	psock->tx_stopped = 1;
+
+	/* Make sure tx_stopped is committed */
+	smp_mb();
+
+	cancel_work_sync(&psock->tx_work);
+	/* At this point tx_work will just return if schedule, it will
+	 * not schedule rx_work.
+	 */
+
+	cancel_work_sync(&psock->peer->rx_work);
+	/* rx_work is done */
+
+	cancel_work_sync(&psock->tx_work);
+	/* Just in case rx_work managed to schedule a tx_work after we
+	 * set tx_stopped .
+	 */
+}
+
+static void kproxy_done_psock(struct kproxy_psock *psock)
+{
+	__skb_queue_purge(&psock->rxqueue);
+	sock_put(psock->sock->sk);
+	fput(psock->sock->file);
+	psock->sock = NULL;
+}
+
+static int kproxy_unjoin(struct socket *sock, struct kproxy_unjoin *info)
+{
+	struct kproxy_sock *ksock = kproxy_sk(sock->sk);
+	int err = 0;
+
+	lock_sock(sock->sk);
+
+	if (ksock->running) {
+		err = -EALREADY;
+		goto out;
+	}
+
+	/* Stop proxy activity */
+	kproxy_stop_sock(&ksock->client_sock);
+	kproxy_stop_sock(&ksock->server_sock);
+
+	/* Done with sockets */
+	kproxy_done_psock(&ksock->client_sock);
+	kproxy_done_psock(&ksock->server_sock);
+
+	ksock->running = false;
+
+out:
+	release_sock(sock->sk);
+
+	return err;
+}
+
+static int kproxy_release(struct socket *sock)
+{
+	struct kproxy_net *knet = net_generic(sock_net(sock->sk),
+					      kproxy_net_id);
+	struct sock *sk = sock->sk;
+	struct kproxy_sock *ksock = kproxy_sk(sock->sk);
+
+	if (!sk)
+		goto out;
+
+	sock_orphan(sk);
+
+	if (ksock->running) {
+		struct kproxy_unjoin info;
+
+		memset(&info, 0, sizeof(info));
+		kproxy_unjoin(sock, &info);
+	}
+
+	mutex_lock(&knet->mutex);
+	list_del_rcu(&ksock->kproxy_list);
+	knet->count--;
+	mutex_unlock(&knet->mutex);
+
+	sock->sk = NULL;
+	sock_put(sk);
+
+out:
+	return 0;
+}
+
+static void kproxy_init_sock(struct kproxy_psock *psock,
+			     struct socket *sock,
+			     struct kproxy_psock *peer)
+{
+	skb_queue_head_init(&psock->rxqueue);
+	psock->sock = sock;
+	psock->peer = peer;
+	psock->queue_hiwat = 1000000;
+	psock->queue_lowat = 1000000;
+	INIT_WORK(&psock->tx_work, kproxy_tx_work);
+	INIT_WORK(&psock->rx_work, kproxy_rx_work);
+	sock_hold(sock->sk);
+}
+
+static void kproxy_start_sock(struct kproxy_psock *psock)
+{
+	struct sock *sk = psock->sock->sk;
+
+	/* Set up callbacks */
+	write_lock_bh(&sk->sk_callback_lock);
+	psock->save_data_ready = sk->sk_data_ready;
+	psock->save_write_space = sk->sk_write_space;
+	psock->save_state_change = sk->sk_state_change;
+	sk->sk_user_data = psock;
+	sk->sk_data_ready = kproxy_data_ready;
+	sk->sk_write_space = kproxy_write_space;
+	sk->sk_state_change = kproxy_state_change;
+	write_unlock_bh(&sk->sk_callback_lock);
+
+	schedule_work(&psock->rx_work);
+}
+
+static int kproxy_join(struct socket *sock, struct kproxy_join *info)
+{
+	struct kproxy_sock *ksock = kproxy_sk(sock->sk);
+	struct socket *csock, *ssock;
+	int err;
+
+	csock = sockfd_lookup(info->client_fd, &err);
+	if (!csock)
+		return err;
+
+	ssock = sockfd_lookup(info->server_fd, &err);
+	if (!ssock) {
+		fput(csock->file);
+		return err;
+	}
+
+	err = 0;
+
+	lock_sock(sock->sk);
+
+	if (ksock->running) {
+		err = -EALREADY;
+		goto outerr;
+	}
+
+	kproxy_init_sock(&ksock->client_sock, csock,
+			 &ksock->server_sock);
+	kproxy_init_sock(&ksock->server_sock, ssock,
+			 &ksock->client_sock);
+
+	kproxy_start_sock(&ksock->client_sock);
+	kproxy_start_sock(&ksock->server_sock);
+
+	ksock->running = true;
+
+	release_sock(sock->sk);
+	return 0;
+
+outerr:
+	release_sock(sock->sk);
+	fput(csock->file);
+	fput(ssock->file);
+
+	return err;
+}
+
+static int kproxy_ioctl(struct socket *sock, unsigned int cmd,
+			unsigned long arg)
+{
+	int err;
+
+	switch (cmd) {
+	case SIOCKPROXYJOIN: {
+		struct kproxy_join info;
+
+		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
+			return -EFAULT;
+
+		err = kproxy_join(sock, &info);
+
+		break;
+	}
+
+	case SIOCKPROXYUNJOIN: {
+		struct kproxy_unjoin info;
+
+		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
+			return -EFAULT;
+
+		err = kproxy_unjoin(sock, &info);
+
+		break;
+	}
+
+	default:
+		err = -ENOIOCTLCMD;
+		break;
+	}
+
+	return err;
+}
+
+static const struct proto_ops kproxy_dgram_ops = {
+	.family =	PF_KPROXY,
+	.owner =	THIS_MODULE,
+	.release =	kproxy_release,
+	.bind =		sock_no_bind,
+	.connect =	sock_no_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	sock_no_accept,
+	.getname =	sock_no_getname,
+	.poll =		sock_no_poll,
+	.ioctl =	kproxy_ioctl,
+	.listen =	sock_no_listen,
+	.shutdown =	sock_no_shutdown,
+	.setsockopt =	sock_no_setsockopt,
+	.getsockopt =	sock_no_getsockopt,
+	.sendmsg =	sock_no_sendmsg,
+	.recvmsg =	sock_no_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
+};
+
+static struct proto kproxy_proto = {
+	.name   = "KPROXY",
+	.owner  = THIS_MODULE,
+	.obj_size = sizeof(struct kproxy_sock),
+};
+
+/* Create proto operation for kcm sockets */
+static int kproxy_create(struct net *net, struct socket *sock,
+			 int protocol, int kern)
+{
+	struct kproxy_net *knet = net_generic(net, kproxy_net_id);
+	struct sock *sk;
+	struct kproxy_sock *ksock;
+
+	switch (sock->type) {
+	case SOCK_DGRAM:
+		sock->ops = &kproxy_dgram_ops;
+		break;
+	default:
+		return -ESOCKTNOSUPPORT;
+	}
+
+	sk = sk_alloc(net, PF_KPROXY, GFP_KERNEL, &kproxy_proto, kern);
+	if (!sk)
+		return -ENOMEM;
+
+	sock_init_data(sock, sk);
+
+	ksock = kproxy_sk(sk);
+
+	mutex_lock(&knet->mutex);
+	list_add_rcu(&ksock->kproxy_list, &knet->kproxy_list);
+	knet->count++;
+	mutex_unlock(&knet->mutex);
+
+	return 0;
+}
+
+static struct net_proto_family kproxy_family_ops = {
+	.family = PF_KPROXY,
+	.create = kproxy_create,
+	.owner  = THIS_MODULE,
+};
+
+static __net_init int kproxy_init_net(struct net *net)
+{
+	struct kproxy_net *knet = net_generic(net, kproxy_net_id);
+
+	INIT_LIST_HEAD_RCU(&knet->kproxy_list);
+	mutex_init(&knet->mutex);
+
+	return 0;
+}
+
+static __net_exit void kproxy_exit_net(struct net *net)
+{
+	struct kproxy_net *knet = net_generic(net, kproxy_net_id);
+
+	/* All kProxy sockets should be closed at this point, which should mean
+	 * that all multiplexors and psocks have been destroyed.
+	 */
+	WARN_ON(!list_empty(&knet->kproxy_list));
+}
+
+static struct pernet_operations kproxy_net_ops = {
+	.init = kproxy_init_net,
+	.exit = kproxy_exit_net,
+	.id   = &kproxy_net_id,
+	.size = sizeof(struct kproxy_net),
+};
+
+static int __init kproxy_init(void)
+{
+	int err = -ENOMEM;
+
+	err = proto_register(&kproxy_proto, 1);
+	if (err)
+		goto fail;
+
+	err = sock_register(&kproxy_family_ops);
+	if (err)
+		goto sock_register_fail;
+
+	err = register_pernet_device(&kproxy_net_ops);
+	if (err)
+		goto net_ops_fail;
+
+	err = kproxy_proc_init();
+	if (err)
+		goto proc_init_fail;
+
+	return 0;
+
+proc_init_fail:
+	unregister_pernet_device(&kproxy_net_ops);
+net_ops_fail:
+	sock_unregister(PF_KPROXY);
+sock_register_fail:
+	proto_unregister(&kproxy_proto);
+
+fail:
+
+	return err;
+}
+
+static void __exit kproxy_exit(void)
+{
+	kproxy_proc_exit();
+	unregister_pernet_device(&kproxy_net_ops);
+	sock_unregister(PF_KPROXY);
+	proto_unregister(&kproxy_proto);
+}
+
+module_init(kproxy_init);
+module_exit(kproxy_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_KPROXY);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 819fd68..7f4c164 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -1404,7 +1404,9 @@ static inline u16 socket_type_to_security_class(int family, int type, int protoc
 			return SECCLASS_QIPCRTR_SOCKET;
 		case PF_SMC:
 			return SECCLASS_SMC_SOCKET;
-#if PF_MAX > 44
+		case PF_KPROXY:
+			return SECCLASS_KPROXY_SOCKET;
+#if PF_MAX > 45
 #error New address family defined, please update this function.
 #endif
 		}
diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index 1e0cc9b..047831e 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -231,9 +231,11 @@ struct security_class_mapping secclass_map[] = {
 	  { COMMON_SOCK_PERMS, NULL } },
 	{ "smc_socket",
 	  { COMMON_SOCK_PERMS, NULL } },
+	{ "kproxy_socket",
+	  { COMMON_SOCK_PERMS, NULL } },
 	{ NULL }
   };
 
-#if PF_MAX > 44
+#if PF_MAX > 45
 #error New address family defined, please update secclass_map.
 #endif
-- 
2.7.4
