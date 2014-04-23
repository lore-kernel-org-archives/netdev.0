From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 2/6][v2] netlink: have netlink per-protocol bind function return an error code.
Date: Tue, 22 Apr 2014 21:31:54 -0400
Message-ID: <704474b93e26bf10400b830f9cacfe9d49063501.1398215388.git.rgb@redhat.com>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
	jamal@mojatatu.com, eparis@redhat.com, sgrubb@redhat.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20140422.161904.1187535812839850973.davem@davemloft.net>
In-Reply-To: <cover.1398215388.git.rgb@redhat.com>
References: <cover.1398215388.git.rgb@redhat.com>
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
V1: This rev fixes a bug introduced by flattening the code in the last posting.
*V2: This rev moves the per-protocol bind call above the socket exposure call
and refactors out the unbind procedure.

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
 include/linux/netlink.h   |    3 +-
 net/netfilter/nfnetlink.c |    3 +-
 net/netlink/af_netlink.c  |   68 +++++++++++++++++++++++++++++++-------------
 net/netlink/af_netlink.h  |    6 ++-
 4 files changed, 56 insertions(+), 24 deletions(-)

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
index 894cda0..7e8d229 100644
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
@@ -1411,6 +1415,19 @@ static int netlink_realloc_groups(struct sock *sk)
 	return err;
 }
 
+static void netlink_unbind(int group, long unsigned int groups,
+			   struct netlink_sock *nlk)
+{
+	int undo;
+
+	if (!nlk->netlink_unbind)
+		return;
+
+	for (undo = 0; undo < group; undo++)
+		if (test_bit(group, &groups))
+			nlk->netlink_unbind(undo);
+}
+
 static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			int addr_len)
 {
@@ -1419,6 +1436,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
+	long unsigned int groups = nladdr->nl_groups;
 
 	if (addr_len < sizeof(struct sockaddr_nl))
 		return -EINVAL;
@@ -1427,7 +1445,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		return -EINVAL;
 
 	/* Only superuser is allowed to listen multicasts */
-	if (nladdr->nl_groups) {
+	if (groups) {
 		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
@@ -1435,37 +1453,45 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return err;
 	}
 
-	if (nlk->portid) {
+	if (nlk->portid)
 		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
-	} else {
+
+	if (nlk->netlink_bind && groups) {
+		int group;
+
+		for (group = 0; group < nlk->ngroups; group++) {
+			if (!test_bit(group, &groups))
+				continue;
+			err = nlk->netlink_bind(group);
+			if (!err)
+				continue;
+			netlink_unbind(group, groups, nlk);
+			return err;
+		}
+	}
+
+	if (!nlk->portid) {
 		err = nladdr->nl_pid ?
 			netlink_insert(sk, net, nladdr->nl_pid) :
 			netlink_autobind(sock);
-		if (err)
+		if (err) {
+			netlink_unbind(nlk->ngroups - 1, groups, nlk);
 			return err;
+		}
 	}
 
-	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
+	if (!groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
 		return 0;
 
 	netlink_table_grab();
 	netlink_update_subscriptions(sk, nlk->subscriptions +
-					 hweight32(nladdr->nl_groups) -
+					 hweight32(groups) -
 					 hweight32(nlk->groups[0]));
-	nlk->groups[0] = (nlk->groups[0] & ~0xffffffffUL) | nladdr->nl_groups;
+	nlk->groups[0] = (nlk->groups[0] & ~0xffffffffUL) | groups;
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
 
@@ -2103,14 +2129,16 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
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

