From: pablo@netfilter.org
Subject: [PATCH 2/2] netlink: add nlk->netlink_bind hook for module auto-loading
Date: Fri, 29 Jun 2012 18:15:22 +0200
Message-ID: <1340986522-3442-3-git-send-email-pablo@netfilter.org>
References: <1340986522-3442-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43622 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932370Ab2F2QPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 12:15:46 -0400
In-Reply-To: <1340986522-3442-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds a hook in the binding path of netlink.

This is used by ctnetlink to allow module autoloading for the case
in which one user executes:

 conntrack -E

So far, this resulted in nfnetlink loaded, but not
nf_conntrack_netlink.

I have received in the past many complains on this behaviour.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netlink.h   |    1 +
 net/netfilter/nfnetlink.c |   29 +++++++++++++++++++++++++++++
 net/netlink/af_netlink.c  |   19 +++++++++++++++++++
 3 files changed, 49 insertions(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 6085e49..f74dd13 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -179,6 +179,7 @@ struct netlink_kernel_cfg {
 	unsigned int	groups;
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
+	void		(*bind)(int group);
 };
 
 extern struct sock *netlink_kernel_create(struct net *net, int unit,
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 700e461..5a2132b 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -39,6 +39,15 @@ static char __initdata nfversion[] = "0.30";
 static const struct nfnetlink_subsystem __rcu *subsys_table[NFNL_SUBSYS_COUNT];
 static DEFINE_MUTEX(nfnl_mutex);
 
+static const int nfnl_group2type[NFNLGRP_MAX+1] = {
+	[NFNLGRP_CONNTRACK_NEW]		= NFNL_SUBSYS_CTNETLINK,
+	[NFNLGRP_CONNTRACK_UPDATE]	= NFNL_SUBSYS_CTNETLINK,
+	[NFNLGRP_CONNTRACK_DESTROY]	= NFNL_SUBSYS_CTNETLINK,
+	[NFNLGRP_CONNTRACK_EXP_NEW]	= NFNL_SUBSYS_CTNETLINK_EXP,
+	[NFNLGRP_CONNTRACK_EXP_UPDATE]	= NFNL_SUBSYS_CTNETLINK_EXP,
+	[NFNLGRP_CONNTRACK_EXP_DESTROY] = NFNL_SUBSYS_CTNETLINK_EXP,
+};
+
 void nfnl_lock(void)
 {
 	mutex_lock(&nfnl_mutex);
@@ -200,12 +209,32 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 	netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
 }
 
+#ifdef CONFIG_MODULES
+static void nfnetlink_bind(int group)
+{
+	const struct nfnetlink_subsystem *ss;
+	int type = nfnl_group2type[group];
+
+	rcu_read_lock();
+	ss = nfnetlink_get_subsys(type);
+	if (!ss) {
+		rcu_read_unlock();
+		request_module("nfnetlink-subsys-%d", type);
+		return;
+	}
+	rcu_read_unlock();
+}
+#endif
+
 static int __net_init nfnetlink_net_init(struct net *net)
 {
 	struct sock *nfnl;
 	struct netlink_kernel_cfg cfg = {
 		.groups	= NFNLGRP_MAX,
 		.input	= nfnetlink_rcv,
+#ifdef CONFIG_MODULES
+		.bind	= nfnetlink_bind,
+#endif
 	};
 
 	nfnl = netlink_kernel_create(net, NETLINK_NETFILTER, THIS_MODULE, &cfg);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 43a124f..5463969 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -80,6 +80,7 @@ struct netlink_sock {
 	struct mutex		*cb_mutex;
 	struct mutex		cb_def_mutex;
 	void			(*netlink_rcv)(struct sk_buff *skb);
+	void			(*netlink_bind)(int group);
 	struct module		*module;
 };
 
@@ -124,6 +125,7 @@ struct netlink_table {
 	unsigned int		groups;
 	struct mutex		*cb_mutex;
 	struct module		*module;
+	void			(*bind)(int group);
 	int			registered;
 };
 
@@ -444,6 +446,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	struct module *module = NULL;
 	struct mutex *cb_mutex;
 	struct netlink_sock *nlk;
+	void (*bind)(int group);
 	int err = 0;
 
 	sock->state = SS_UNCONNECTED;
@@ -468,6 +471,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	else
 		err = -EPROTONOSUPPORT;
 	cb_mutex = nl_table[protocol].cb_mutex;
+	bind = nl_table[protocol].bind;
 	netlink_unlock_table();
 
 	if (err < 0)
@@ -483,6 +487,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 
 	nlk = nlk_sk(sock->sk);
 	nlk->module = module;
+	nlk->netlink_bind = bind;
 out:
 	return err;
 
@@ -683,6 +688,15 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	netlink_update_listeners(sk);
 	netlink_table_ungrab();
 
+	if (nlk->netlink_bind && nlk->groups[0]) {
+		int i;
+
+		for (i=0; i<nlk->ngroups; i++) {
+			if (test_bit(i, nlk->groups))
+				nlk->netlink_bind(i);
+		}
+	}
+
 	return 0;
 }
 
@@ -1239,6 +1253,10 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		netlink_update_socket_mc(nlk, val,
 					 optname == NETLINK_ADD_MEMBERSHIP);
 		netlink_table_ungrab();
+
+		if (nlk->netlink_bind)
+			nlk->netlink_bind(val);
+
 		err = 0;
 		break;
 	}
@@ -1559,6 +1577,7 @@ netlink_kernel_create(struct net *net, int unit,
 		rcu_assign_pointer(nl_table[unit].listeners, listeners);
 		nl_table[unit].cb_mutex = cb_mutex;
 		nl_table[unit].module = module;
+		nl_table[unit].bind = cfg ? cfg->bind : NULL;
 		nl_table[unit].registered = 1;
 	} else {
 		kfree(listeners);
-- 
1.7.10
