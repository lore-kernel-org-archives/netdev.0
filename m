From: Craig Gallek <kraig@google.com>
Subject: [PATCH net-next 1/3] sock_diag: define destruction multicast groups
Date: Mon, 15 Jun 2015 11:26:18 -0400
Message-ID: <1434381980-20588-2-git-send-email-kraig@google.com>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
Cc: edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org,
	Craig Gallek <kraig@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:36807 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbbFOP1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:27:20 -0400
Received: by yhan67 with SMTP id n67so45022998yha.3
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 08:27:19 -0700 (PDT)
In-Reply-To: <1434381980-20588-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These groups will contain socket-destruction events for
AF_INET/AF_INET6, IPPROTO_TCP/IPPROTO_UDP.

Near the end of socket destruction, a check for listeners is
performed.  In the presence of a listener, rather than completely
cleanup the socket, a unit of work will be added to a private
work queue which will first broadcast information about the socket
and then finish the cleanup operation.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/sock_diag.h      | 42 +++++++++++++++++++++
 include/net/sock.h             |  1 +
 include/uapi/linux/sock_diag.h | 10 +++++
 net/core/sock.c                | 11 +++++-
 net/core/sock_diag.c           | 85 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 148 insertions(+), 1 deletion(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 083ac38..fddebc6 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -1,7 +1,10 @@
 #ifndef __SOCK_DIAG_H__
 #define __SOCK_DIAG_H__
 
+#include <linux/netlink.h>
 #include <linux/user_namespace.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
 #include <uapi/linux/sock_diag.h>
 
 struct sk_buff;
@@ -11,6 +14,7 @@ struct sock;
 struct sock_diag_handler {
 	__u8 family;
 	int (*dump)(struct sk_buff *skb, struct nlmsghdr *nlh);
+	int (*get_info)(struct sk_buff *skb, struct sock *sk);
 };
 
 int sock_diag_register(const struct sock_diag_handler *h);
@@ -26,4 +30,42 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
 int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype);
 
+static inline
+enum sknetlink_groups sock_diag_destroy_group(const struct sock *sk)
+{
+	switch (sk->sk_family) {
+	case AF_INET:
+		switch (sk->sk_protocol) {
+		case IPPROTO_TCP:
+			return SKNLGRP_INET_TCP_DESTROY;
+		case IPPROTO_UDP:
+			return SKNLGRP_INET_UDP_DESTROY;
+		default:
+			return SKNLGRP_NONE;
+		}
+	case AF_INET6:
+		switch (sk->sk_protocol) {
+		case IPPROTO_TCP:
+			return SKNLGRP_INET6_TCP_DESTROY;
+		case IPPROTO_UDP:
+			return SKNLGRP_INET6_UDP_DESTROY;
+		default:
+			return SKNLGRP_NONE;
+		}
+	default:
+		return SKNLGRP_NONE;
+	}
+}
+
+static inline
+bool sock_diag_has_destroy_listeners(const struct sock *sk)
+{
+	const struct net *n = sock_net(sk);
+	const enum sknetlink_groups group = sock_diag_destroy_group(sk);
+
+	return group != SKNLGRP_NONE && n->diag_nlsk &&
+		netlink_has_listeners(n->diag_nlsk, group);
+}
+void sock_diag_broadcast_destroy(struct sock *sk);
+
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 26c1c31..3e82586 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1518,6 +1518,7 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		      struct proto *prot, int kern);
 void sk_free(struct sock *sk);
+void sk_destruct(struct sock *sk);
 struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority);
 
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
diff --git a/include/uapi/linux/sock_diag.h b/include/uapi/linux/sock_diag.h
index b00e29e..49230d3 100644
--- a/include/uapi/linux/sock_diag.h
+++ b/include/uapi/linux/sock_diag.h
@@ -23,4 +23,14 @@ enum {
 	SK_MEMINFO_VARS,
 };
 
+enum sknetlink_groups {
+	SKNLGRP_NONE,
+	SKNLGRP_INET_TCP_DESTROY,
+	SKNLGRP_INET_UDP_DESTROY,
+	SKNLGRP_INET6_TCP_DESTROY,
+	SKNLGRP_INET6_UDP_DESTROY,
+	__SKNLGRP_MAX,
+};
+#define SKNLGRP_MAX	(__SKNLGRP_MAX - 1)
+
 #endif /* _UAPI__SOCK_DIAG_H__ */
diff --git a/net/core/sock.c b/net/core/sock.c
index 7063c32..1e1fe9a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -131,6 +131,7 @@
 #include <linux/ipsec.h>
 #include <net/cls_cgroup.h>
 #include <net/netprio_cgroup.h>
+#include <linux/sock_diag.h>
 
 #include <linux/filter.h>
 
@@ -1423,7 +1424,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 }
 EXPORT_SYMBOL(sk_alloc);
 
-static void __sk_free(struct sock *sk)
+void sk_destruct(struct sock *sk)
 {
 	struct sk_filter *filter;
 
@@ -1451,6 +1452,14 @@ static void __sk_free(struct sock *sk)
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
+static void __sk_free(struct sock *sk)
+{
+	if (unlikely(sock_diag_has_destroy_listeners(sk)))
+		sock_diag_broadcast_destroy(sk);
+	else
+		sk_destruct(sk);
+}
+
 void sk_free(struct sock *sk)
 {
 	/*
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 74dddf8..d79866c 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -5,6 +5,9 @@
 #include <net/net_namespace.h>
 #include <linux/module.h>
 #include <net/sock.h>
+#include <linux/kernel.h>
+#include <linux/tcp.h>
+#include <linux/workqueue.h>
 
 #include <linux/inet_diag.h>
 #include <linux/sock_diag.h>
@@ -12,6 +15,7 @@
 static const struct sock_diag_handler *sock_diag_handlers[AF_MAX];
 static int (*inet_rcv_compat)(struct sk_buff *skb, struct nlmsghdr *nlh);
 static DEFINE_MUTEX(sock_diag_table_mutex);
+static struct workqueue_struct *broadcast_wq;
 
 static u64 sock_gen_cookie(struct sock *sk)
 {
@@ -101,6 +105,62 @@ out:
 }
 EXPORT_SYMBOL(sock_diag_put_filterinfo);
 
+struct broadcast_sk {
+	struct sock *sk;
+	struct work_struct work;
+};
+
+static size_t sock_diag_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct inet_diag_msg)
+	       + nla_total_size(sizeof(u8)) /* INET_DIAG_PROTOCOL */
+	       + nla_total_size(sizeof(struct tcp_info))); /* INET_DIAG_INFO */
+}
+
+static void sock_diag_broadcast_destroy_work(struct work_struct *work)
+{
+	struct broadcast_sk *bsk =
+		container_of(work, struct broadcast_sk, work);
+	struct sock *sk = bsk->sk;
+	const struct sock_diag_handler *hndl;
+	struct sk_buff *skb;
+	const enum sknetlink_groups group = sock_diag_destroy_group(sk);
+	int err = -1;
+
+	WARN_ON(group == SKNLGRP_NONE);
+
+	skb = nlmsg_new(sock_diag_nlmsg_size(), GFP_KERNEL);
+	if (!skb)
+		goto out;
+
+	mutex_lock(&sock_diag_table_mutex);
+	hndl = sock_diag_handlers[sk->sk_family];
+	if (hndl && hndl->get_info)
+		err = hndl->get_info(skb, sk);
+	mutex_unlock(&sock_diag_table_mutex);
+
+	if (!err)
+		nlmsg_multicast(sock_net(sk)->diag_nlsk, skb, 0, group,
+				GFP_KERNEL);
+	else
+		kfree_skb(skb);
+out:
+	sk_destruct(sk);
+	kfree(bsk);
+}
+
+void sock_diag_broadcast_destroy(struct sock *sk)
+{
+	/* Note, this function is often called from an interrupt context. */
+	struct broadcast_sk *bsk =
+		kmalloc(sizeof(struct broadcast_sk), GFP_ATOMIC);
+	if (!bsk)
+		return sk_destruct(sk);
+	bsk->sk = sk;
+	INIT_WORK(&bsk->work, sock_diag_broadcast_destroy_work);
+	queue_work(broadcast_wq, &bsk->work);
+}
+
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh))
 {
 	mutex_lock(&sock_diag_table_mutex);
@@ -211,10 +271,32 @@ static void sock_diag_rcv(struct sk_buff *skb)
 	mutex_unlock(&sock_diag_mutex);
 }
 
+static int sock_diag_bind(struct net *net, int group)
+{
+	switch (group) {
+	case SKNLGRP_INET_TCP_DESTROY:
+	case SKNLGRP_INET_UDP_DESTROY:
+		if (!sock_diag_handlers[AF_INET])
+			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+				       NETLINK_SOCK_DIAG, AF_INET);
+		break;
+	case SKNLGRP_INET6_TCP_DESTROY:
+	case SKNLGRP_INET6_UDP_DESTROY:
+		if (!sock_diag_handlers[AF_INET6])
+			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+				       NETLINK_SOCK_DIAG, AF_INET);
+		break;
+	}
+	return 0;
+}
+
 static int __net_init diag_net_init(struct net *net)
 {
 	struct netlink_kernel_cfg cfg = {
+		.groups	= SKNLGRP_MAX,
 		.input	= sock_diag_rcv,
+		.bind	= sock_diag_bind,
+		.flags	= NL_CFG_F_NONROOT_RECV,
 	};
 
 	net->diag_nlsk = netlink_kernel_create(net, NETLINK_SOCK_DIAG, &cfg);
@@ -234,12 +316,15 @@ static struct pernet_operations diag_net_ops = {
 
 static int __init sock_diag_init(void)
 {
+	broadcast_wq = alloc_workqueue("sock_diag_events", 0, 0);
+	BUG_ON(!broadcast_wq);
 	return register_pernet_subsys(&diag_net_ops);
 }
 
 static void __exit sock_diag_exit(void)
 {
 	unregister_pernet_subsys(&diag_net_ops);
+	destroy_workqueue(broadcast_wq);
 }
 
 module_init(sock_diag_init);
-- 
2.2.0.rc0.207.ga3a616c
