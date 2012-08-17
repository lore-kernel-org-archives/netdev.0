From: pablo@netfilter.org
Subject: [PATCH 1/2] netlink: kill netlink_set_nonroot
Date: Fri, 17 Aug 2012 19:22:28 +0200
Message-ID: <1345224149-5946-2-git-send-email-pablo@netfilter.org>
References: <1345224149-5946-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60261 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757994Ab2HQRXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 13:23:37 -0400
In-Reply-To: <1345224149-5946-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Replace netlink_set_nonroot by one new field `flags' in
struct netlink_kernel_cfg that is passed to netlink_kernel_create.

This patch also renames NL_NONROOT_* to NL_CFG_F_NONROOT_* since
now the flags field in nl_table is generic (so we can add more
flags if needed in the future).

Also adjust all callers in the net-next tree to use these flags
instead of netlink_set_nonroot.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netlink.h    |    9 ++++-----
 lib/kobject_uevent.c       |    2 +-
 net/core/rtnetlink.c       |    2 +-
 net/netlink/af_netlink.c   |   20 +++++++-------------
 net/netlink/genetlink.c    |    3 +--
 security/selinux/netlink.c |    2 +-
 6 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f74dd13..2f67621 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -174,12 +174,16 @@ struct netlink_skb_parms {
 extern void netlink_table_grab(void);
 extern void netlink_table_ungrab(void);
 
+#define NL_CFG_F_NONROOT_RECV	(1 << 0)
+#define NL_CFG_F_NONROOT_SEND	(1 << 1)
+
 /* optional Netlink kernel configuration parameters */
 struct netlink_kernel_cfg {
 	unsigned int	groups;
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
 	void		(*bind)(int group);
+	unsigned int	flags;
 };
 
 extern struct sock *netlink_kernel_create(struct net *net, int unit,
@@ -258,11 +262,6 @@ extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
 			      struct netlink_dump_control *control);
 
-
-#define NL_NONROOT_RECV 0x1
-#define NL_NONROOT_SEND 0x2
-extern void netlink_set_nonroot(int protocol, unsigned flag);
-
 #endif /* __KERNEL__ */
 
 #endif	/* __LINUX_NETLINK_H */
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 0401d29..c2e9778 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -375,6 +375,7 @@ static int uevent_net_init(struct net *net)
 	struct uevent_sock *ue_sk;
 	struct netlink_kernel_cfg cfg = {
 		.groups	= 1,
+		.flags	= NL_CFG_F_NONROOT_RECV,
 	};
 
 	ue_sk = kzalloc(sizeof(*ue_sk), GFP_KERNEL);
@@ -422,7 +423,6 @@ static struct pernet_operations uevent_net_ops = {
 
 static int __init kobject_uevent_init(void)
 {
-	netlink_set_nonroot(NETLINK_KOBJECT_UEVENT, NL_NONROOT_RECV);
 	return register_pernet_subsys(&uevent_net_ops);
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 34d975b..d83f73b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2381,6 +2381,7 @@ static int __net_init rtnetlink_net_init(struct net *net)
 		.groups		= RTNLGRP_MAX,
 		.input		= rtnetlink_rcv,
 		.cb_mutex	= &rtnl_mutex,
+		.flags		= NL_CFG_F_NONROOT_RECV,
 	};
 
 	sk = netlink_kernel_create(net, NETLINK_ROUTE, THIS_MODULE, &cfg);
@@ -2416,7 +2417,6 @@ void __init rtnetlink_init(void)
 	if (register_pernet_subsys(&rtnetlink_net_ops))
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 
-	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
 	register_netdevice_notifier(&rtnetlink_dev_notifier);
 
 	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink,
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5463969..d04f923 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -121,7 +121,7 @@ struct netlink_table {
 	struct nl_pid_hash	hash;
 	struct hlist_head	mc_list;
 	struct listeners __rcu	*listeners;
-	unsigned int		nl_nonroot;
+	unsigned int		flags;
 	unsigned int		groups;
 	struct mutex		*cb_mutex;
 	struct module		*module;
@@ -596,7 +596,7 @@ retry:
 
 static inline int netlink_capable(const struct socket *sock, unsigned int flag)
 {
-	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
+	return (nl_table[sock->sk->sk_protocol].flags & flag) ||
 	       capable(CAP_NET_ADMIN);
 }
 
@@ -659,7 +659,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 
 	/* Only superuser is allowed to listen multicasts */
 	if (nladdr->nl_groups) {
-		if (!netlink_capable(sock, NL_NONROOT_RECV))
+		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -721,7 +721,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 		return -EINVAL;
 
 	/* Only superuser is allowed to send multicasts */
-	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_SEND))
+	if (nladdr->nl_groups && !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
 	if (!nlk->pid)
@@ -1242,7 +1242,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		if (!netlink_capable(sock, NL_NONROOT_RECV))
+		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -1373,7 +1373,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		dst_pid = addr->nl_pid;
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
-		if (dst_group && !netlink_capable(sock, NL_NONROOT_SEND))
+		if (dst_group && !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
 			goto out;
 	} else {
 		dst_pid = nlk->dst_pid;
@@ -1578,6 +1578,7 @@ netlink_kernel_create(struct net *net, int unit,
 		nl_table[unit].cb_mutex = cb_mutex;
 		nl_table[unit].module = module;
 		nl_table[unit].bind = cfg ? cfg->bind : NULL;
+		nl_table[unit].flags = cfg ? cfg->flags : 0;
 		nl_table[unit].registered = 1;
 	} else {
 		kfree(listeners);
@@ -1676,13 +1677,6 @@ void netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
 	netlink_table_ungrab();
 }
 
-void netlink_set_nonroot(int protocol, unsigned int flags)
-{
-	if ((unsigned int)protocol < MAX_LINKS)
-		nl_table[protocol].nl_nonroot = flags;
-}
-EXPORT_SYMBOL(netlink_set_nonroot);
-
 struct nlmsghdr *
 __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 {
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index fda4974..c1b71ae 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -918,6 +918,7 @@ static int __net_init genl_pernet_init(struct net *net)
 	struct netlink_kernel_cfg cfg = {
 		.input		= genl_rcv,
 		.cb_mutex	= &genl_mutex,
+		.flags		= NL_CFG_F_NONROOT_RECV,
 	};
 
 	/* we'll bump the group number right afterwards */
@@ -955,8 +956,6 @@ static int __init genl_init(void)
 	if (err < 0)
 		goto problem;
 
-	netlink_set_nonroot(NETLINK_GENERIC, NL_NONROOT_RECV);
-
 	err = register_pernet_subsys(&genl_pernet_ops);
 	if (err)
 		goto problem;
diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 8a77725..0d2cd11 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -113,13 +113,13 @@ static int __init selnl_init(void)
 {
 	struct netlink_kernel_cfg cfg = {
 		.groups	= SELNLGRP_MAX,
+		.flags	= NL_CFG_F_NONROOT_RECV,
 	};
 
 	selnl = netlink_kernel_create(&init_net, NETLINK_SELINUX,
 				      THIS_MODULE, &cfg);
 	if (selnl == NULL)
 		panic("SELinux:  Cannot create netlink socket.");
-	netlink_set_nonroot(NETLINK_SELINUX, NL_NONROOT_RECV);
 	return 0;
 }
 
-- 
1.7.10.4
