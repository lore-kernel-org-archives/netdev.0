From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 2/6] netlink: have netlink per-protocol bind function return an error code.
Date: Fri, 18 Apr 2014 13:34:06 -0400
Message-ID: <c9a8a0879bc9f375bb3484f8e86189a8af5aa142.1397831970.git.rgb@redhat.com>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
	eparis@redhat.com, netfilter-devel@vger.kernel.org,
	hadi@mojatatu.com, sgrubb@redhat.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20140324183406.GE28666@madcap2.tricolour.ca>
In-Reply-To: <cover.1397831970.git.rgb@redhat.com>
References: <cover.1397831970.git.rgb@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Have the netlink per-protocol optional bind function return an int error code
rather than void to signal a failure.

This will enable netlink protocols to perform extra checks including
capabilities and permissions verifications when updating memberships in
multicast groups.

In netlink_bind() and netlink_setsockopt() the call to the per-protocol bind
function was moved above the multicast group update to prevent any access to
the multicast socket groups before checking with the per-protocol bind
function.  This will enable the per-protocol bind function to be used to check
permissions which could be denied before making them available, and to avoid
the messy job of undoing the addition should the per-protocol bind function
fail.

The netfilter subsystem seems to be the only one currently using the
per-protocol bind function.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
In particular, the audit subsystem (NETLINK_AUDIT protocol) could benefit by
being able to check specific capabilities for each multicast group before
granting membership to the requesting socket.  Currently, all NETLINK_AUDIT
sockets must have the capability CAP_NET_ADMIN.  No other capabilities are
required to join a multicast group.  This capability is too broad allowing
access to this socket by many applications that must not have access to this
information.  It is proposed to add capability CAP_AUDIT_READ to allow this
access while dropping the exessively broad capability CAP_NET_ADMIN.

There has also been some interest expressed by IETF ForCES folk.
---
 include/linux/netlink.h   |    3 ++-
 net/netfilter/nfnetlink.c |    3 ++-
 net/netlink/af_netlink.c  |   43 ++++++++++++++++++++++++++++++-------------
 net/netlink/af_netlink.h  |    6 ++++--
 4 files changed, 38 insertions(+), 17 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index aad8eea..5146ce0 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -45,7 +45,8 @@ struct netlink_kernel_cfg {
 	unsigned int	flags;
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
-	void		(*bind)(int group);
+	int		(*bind)(int group);
+	void		(*unbind)(int group);
 	bool		(*compare)(struct net *net, struct sock *sk);
 };
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 0df800a..6e42dcf 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -400,7 +400,7 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 }
 
 #ifdef CONFIG_MODULES
-static void nfnetlink_bind(int group)
+static int nfnetlink_bind(int group)
 {
 	const struct nfnetlink_subsystem *ss;
 	int type = nfnl_group2type[group];
@@ -410,6 +410,7 @@ static void nfnetlink_bind(int group)
 	rcu_read_unlock();
 	if (!ss)
 		request_module("nfnetlink-subsys-%d", type);
+	return 0;
 }
 #endif
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 894cda0..3f43e5a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1206,7 +1206,8 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	struct module *module = NULL;
 	struct mutex *cb_mutex;
 	struct netlink_sock *nlk;
-	void (*bind)(int group);
+	int (*bind)(int group);
+	void (*unbind)(int group);
 	int err = 0;
 
 	sock->state = SS_UNCONNECTED;
@@ -1232,6 +1233,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 		err = -EPROTONOSUPPORT;
 	cb_mutex = nl_table[protocol].cb_mutex;
 	bind = nl_table[protocol].bind;
+	unbind = nl_table[protocol].unbind;
 	netlink_unlock_table();
 
 	if (err < 0)
@@ -1248,6 +1250,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	nlk = nlk_sk(sock->sk);
 	nlk->module = module;
 	nlk->netlink_bind = bind;
+	nlk->netlink_unbind = unbind;
 out:
 	return err;
 
@@ -1301,6 +1304,7 @@ static int netlink_release(struct socket *sock)
 			kfree_rcu(old, rcu);
 			nl_table[sk->sk_protocol].module = NULL;
 			nl_table[sk->sk_protocol].bind = NULL;
+			nl_table[sk->sk_protocol].unbind = NULL;
 			nl_table[sk->sk_protocol].flags = 0;
 			nl_table[sk->sk_protocol].registered = 0;
 		}
@@ -1449,6 +1453,26 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
 		return 0;
 
+	if (nlk->netlink_bind && nladdr->nl_groups) {
+		int i;
+
+		for (i = 0; i < nlk->ngroups; i++) {
+			int undo;
+
+			if (!test_bit(i, (long unsigned int *)&nladdr->nl_groups))
+				continue;
+			err = nlk->netlink_bind(i);
+			if (!err)
+				continue;
+			if (!nlk->portid)
+				netlink_remove(sk);
+			for (undo = 0; undo < i; undo++)
+				if (nlk->netlink_unbind)
+					nlk->netlink_unbind(undo);
+			return err;
+		}
+	}
+
 	netlink_table_grab();
 	netlink_update_subscriptions(sk, nlk->subscriptions +
 					 hweight32(nladdr->nl_groups) -
@@ -1457,15 +1481,6 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	netlink_update_listeners(sk);
 	netlink_table_ungrab();
 
-	if (nlk->netlink_bind && nlk->groups[0]) {
-		int i;
-
-		for (i = 0; i < nlk->ngroups; i++) {
-			if (test_bit(i, nlk->groups))
-				nlk->netlink_bind(i);
-		}
-	}
-
 	return 0;
 }
 
@@ -2103,14 +2118,16 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			return err;
 		if (!val || val - 1 >= nlk->ngroups)
 			return -EINVAL;
+		if (nlk->netlink_bind) {
+			err = nlk->netlink_bind(val);
+			if (err)
+				return err;
+		}
 		netlink_table_grab();
 		netlink_update_socket_mc(nlk, val,
 					 optname == NETLINK_ADD_MEMBERSHIP);
 		netlink_table_ungrab();
 
-		if (nlk->netlink_bind)
-			nlk->netlink_bind(val);
-
 		err = 0;
 		break;
 	}
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index ed13a79..0b59d44 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -38,7 +38,8 @@ struct netlink_sock {
 	struct mutex		*cb_mutex;
 	struct mutex		cb_def_mutex;
 	void			(*netlink_rcv)(struct sk_buff *skb);
-	void			(*netlink_bind)(int group);
+	int			(*netlink_bind)(int group);
+	void			(*netlink_unbind)(int group);
 	struct module		*module;
 #ifdef CONFIG_NETLINK_MMAP
 	struct mutex		pg_vec_lock;
@@ -74,7 +75,8 @@ struct netlink_table {
 	unsigned int		groups;
 	struct mutex		*cb_mutex;
 	struct module		*module;
-	void			(*bind)(int group);
+	int			(*bind)(int group);
+	void			(*unbind)(int group);
 	bool			(*compare)(struct net *net, struct sock *sock);
 	int			registered;
 };
-- 
1.7.1

