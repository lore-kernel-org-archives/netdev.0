From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink/genetlink: pass network namespace to bind/unbind
Date: Tue, 23 Dec 2014 21:00:06 +0100
Message-ID: <1419364806-8753-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40232 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512AbaLWUAK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 15:00:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Netlink families can exist in multiple namespaces, and for the most
part multicast subscriptions are per network namespace. Thus it only
makes sense to have bind/unbind notifications per network namespace.

To achieve this, pass the network namespace of a given client socket
to the bind/unbind functions.

Also do this in generic netlink, and there also make sure that any
bind for multicast groups that only exist in init_net is rejected.
This isn't really a problem if it is accepted since a client in a
different namespace will never receive any notifications from such
a group, but it can confuse the family if not rejected (it's also
possible to silently (without telling the family) accept it, but it
would also have to be ignored on unbind so families that take any
kind of action on bind/unbind won't do unnecessary work for invalid
clients like that.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/netlink.h   |  4 ++--
 include/net/genetlink.h   |  4 ++--
 kernel/audit.c            |  2 +-
 net/netfilter/nfnetlink.c |  2 +-
 net/netlink/af_netlink.c  | 21 +++++++++++----------
 net/netlink/af_netlink.h  |  8 ++++----
 net/netlink/genetlink.c   | 12 +++++++-----
 7 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 9e572daa15d5..02fc86d2348e 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -46,8 +46,8 @@ struct netlink_kernel_cfg {
 	unsigned int	flags;
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
-	int		(*bind)(int group);
-	void		(*unbind)(int group);
+	int		(*bind)(struct net *net, int group);
+	void		(*unbind)(struct net *net, int group);
 	bool		(*compare)(struct net *net, struct sock *sk);
 };
 
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 3ed31e5a445b..84125088c309 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -56,8 +56,8 @@ struct genl_family {
 	void			(*post_doit)(const struct genl_ops *ops,
 					     struct sk_buff *skb,
 					     struct genl_info *info);
-	int			(*mcast_bind)(int group);
-	void			(*mcast_unbind)(int group);
+	int			(*mcast_bind)(struct net *net, int group);
+	void			(*mcast_unbind)(struct net *net, int group);
 	struct nlattr **	attrbuf;	/* private */
 	const struct genl_ops *	ops;		/* private */
 	const struct genl_multicast_group *mcgrps; /* private */
diff --git a/kernel/audit.c b/kernel/audit.c
index 1f37f15117e5..0264ab84c446 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1100,7 +1100,7 @@ static void audit_receive(struct sk_buff  *skb)
 }
 
 /* Run custom bind function on netlink socket group connect or bind requests. */
-static int audit_bind(int group)
+static int audit_bind(struct net *net, int group)
 {
 	if (!capable(CAP_AUDIT_READ))
 		return -EPERM;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 13c2e17bbe27..cde4a6702fa3 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -463,7 +463,7 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 }
 
 #ifdef CONFIG_MODULES
-static int nfnetlink_bind(int group)
+static int nfnetlink_bind(struct net *net, int group)
 {
 	const struct nfnetlink_subsystem *ss;
 	int type;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 07a903de4439..5fe199abfa41 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1161,8 +1161,8 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	struct module *module = NULL;
 	struct mutex *cb_mutex;
 	struct netlink_sock *nlk;
-	int (*bind)(int group);
-	void (*unbind)(int group);
+	int (*bind)(struct net *net, int group);
+	void (*unbind)(struct net *net, int group);
 	int err = 0;
 
 	sock->state = SS_UNCONNECTED;
@@ -1271,7 +1271,7 @@ static int netlink_release(struct socket *sock)
 
 		for (i = 0; i < nlk->ngroups; i++)
 			if (test_bit(i, nlk->groups))
-				nlk->netlink_unbind(i + 1);
+				nlk->netlink_unbind(sock_net(sk), i + 1);
 	}
 	kfree(nlk->groups);
 	nlk->groups = NULL;
@@ -1438,8 +1438,9 @@ static int netlink_realloc_groups(struct sock *sk)
 }
 
 static void netlink_undo_bind(int group, long unsigned int groups,
-			      struct netlink_sock *nlk)
+			      struct sock *sk)
 {
+	struct netlink_sock *nlk = nlk_sk(sk);
 	int undo;
 
 	if (!nlk->netlink_unbind)
@@ -1447,7 +1448,7 @@ static void netlink_undo_bind(int group, long unsigned int groups,
 
 	for (undo = 0; undo < group; undo++)
 		if (test_bit(undo, &groups))
-			nlk->netlink_unbind(undo);
+			nlk->netlink_unbind(sock_net(sk), undo);
 }
 
 static int netlink_bind(struct socket *sock, struct sockaddr *addr,
@@ -1485,10 +1486,10 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		for (group = 0; group < nlk->ngroups; group++) {
 			if (!test_bit(group, &groups))
 				continue;
-			err = nlk->netlink_bind(group);
+			err = nlk->netlink_bind(net, group);
 			if (!err)
 				continue;
-			netlink_undo_bind(group, groups, nlk);
+			netlink_undo_bind(group, groups, sk);
 			return err;
 		}
 	}
@@ -1498,7 +1499,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			netlink_insert(sk, net, nladdr->nl_pid) :
 			netlink_autobind(sock);
 		if (err) {
-			netlink_undo_bind(nlk->ngroups, groups, nlk);
+			netlink_undo_bind(nlk->ngroups, groups, sk);
 			return err;
 		}
 	}
@@ -2149,7 +2150,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		if (!val || val - 1 >= nlk->ngroups)
 			return -EINVAL;
 		if (optname == NETLINK_ADD_MEMBERSHIP && nlk->netlink_bind) {
-			err = nlk->netlink_bind(val);
+			err = nlk->netlink_bind(sock_net(sk), val);
 			if (err)
 				return err;
 		}
@@ -2158,7 +2159,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 					 optname == NETLINK_ADD_MEMBERSHIP);
 		netlink_table_ungrab();
 		if (optname == NETLINK_DROP_MEMBERSHIP && nlk->netlink_unbind)
-			nlk->netlink_unbind(val);
+			nlk->netlink_unbind(sock_net(sk), val);
 
 		err = 0;
 		break;
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index b20a1731759b..f123a88496f8 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -39,8 +39,8 @@ struct netlink_sock {
 	struct mutex		*cb_mutex;
 	struct mutex		cb_def_mutex;
 	void			(*netlink_rcv)(struct sk_buff *skb);
-	int			(*netlink_bind)(int group);
-	void			(*netlink_unbind)(int group);
+	int			(*netlink_bind)(struct net *net, int group);
+	void			(*netlink_unbind)(struct net *net, int group);
 	struct module		*module;
 #ifdef CONFIG_NETLINK_MMAP
 	struct mutex		pg_vec_lock;
@@ -65,8 +65,8 @@ struct netlink_table {
 	unsigned int		groups;
 	struct mutex		*cb_mutex;
 	struct module		*module;
-	int			(*bind)(int group);
-	void			(*unbind)(int group);
+	int			(*bind)(struct net *net, int group);
+	void			(*unbind)(struct net *net, int group);
 	bool			(*compare)(struct net *net, struct sock *sock);
 	int			registered;
 };
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 05bf40bbd189..91566ed36c43 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -983,7 +983,7 @@ static struct genl_multicast_group genl_ctrl_groups[] = {
 	{ .name = "notify", },
 };
 
-static int genl_bind(int group)
+static int genl_bind(struct net *net, int group)
 {
 	int i, err;
 	bool found = false;
@@ -997,8 +997,10 @@ static int genl_bind(int group)
 			    group < f->mcgrp_offset + f->n_mcgrps) {
 				int fam_grp = group - f->mcgrp_offset;
 
-				if (f->mcast_bind)
-					err = f->mcast_bind(fam_grp);
+				if (!f->netnsok && net != &init_net)
+					err = -ENOENT;
+				else if (f->mcast_bind)
+					err = f->mcast_bind(net, fam_grp);
 				else
 					err = 0;
 				found = true;
@@ -1014,7 +1016,7 @@ static int genl_bind(int group)
 	return err;
 }
 
-static void genl_unbind(int group)
+static void genl_unbind(struct net *net, int group)
 {
 	int i;
 	bool found = false;
@@ -1029,7 +1031,7 @@ static void genl_unbind(int group)
 				int fam_grp = group - f->mcgrp_offset;
 
 				if (f->mcast_unbind)
-					f->mcast_unbind(fam_grp);
+					f->mcast_unbind(net, fam_grp);
 				found = true;
 				break;
 			}
-- 
2.1.1
