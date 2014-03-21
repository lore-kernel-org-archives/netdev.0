From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH] netlink: have netlink per-protocol bind function return an error code.
Date: Fri, 21 Mar 2014 12:39:11 -0400
Message-ID: <1239812af16a5c746772913ef68d3570383f2e50.1395419169.git.rgb@redhat.com>
Cc: Richard Guy Briggs <rgb@redhat.com>, eparis@redhat.com,
	sgrubb@redhat.com, hadi@mojatatu.com, davem@davemloft.net
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
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
 include/linux/netlink.h   |    2 +-
 net/netfilter/nfnetlink.c |    3 ++-
 net/netlink/af_netlink.c  |   30 +++++++++++++++++-------------
 net/netlink/af_netlink.h  |    4 ++--
 4 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 7a6c396..4402653 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -45,7 +45,7 @@ struct netlink_kernel_cfg {
 	unsigned int	flags;
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
-	void		(*bind)(int group);
+	int		(*bind)(int group);
 	bool		(*compare)(struct net *net, struct sock *sk);
 };
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 75619f9..10a4cf5 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -392,7 +392,7 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 }
 
 #ifdef CONFIG_MODULES
-static void nfnetlink_bind(int group)
+static int nfnetlink_bind(int group)
 {
 	const struct nfnetlink_subsystem *ss;
 	int type = nfnl_group2type[group];
@@ -403,6 +403,7 @@ static void nfnetlink_bind(int group)
 	if (!ss) {
 		request_module("nfnetlink-subsys-%d", type);
 	}
+	return 0;
 }
 #endif
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index bca50b9..4224dc5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1198,7 +1198,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	struct module *module = NULL;
 	struct mutex *cb_mutex;
 	struct netlink_sock *nlk;
-	void (*bind)(int group);
+	int (*bind)(int group);
 	int err = 0;
 
 	sock->state = SS_UNCONNECTED;
@@ -1441,6 +1441,17 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
 		return 0;
 
+	if (nlk->netlink_bind && nladdr->nl_groups) {
+		int i;
+
+		for (i = 0; i < nlk->ngroups; i++)
+			if (test_bit(i, (long unsigned int *)&nladdr->nl_groups)) {
+				err = nlk->netlink_bind(i);
+				if (err)
+					return err;
+			}
+	}
+
 	netlink_table_grab();
 	netlink_update_subscriptions(sk, nlk->subscriptions +
 					 hweight32(nladdr->nl_groups) -
@@ -1449,15 +1460,6 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	netlink_update_listeners(sk);
 	netlink_table_ungrab();
 
-	if (nlk->netlink_bind && nlk->groups[0]) {
-		int i;
-
-		for (i=0; i<nlk->ngroups; i++) {
-			if (test_bit(i, nlk->groups))
-				nlk->netlink_bind(i);
-		}
-	}
-
 	return 0;
 }
 
@@ -2095,14 +2097,16 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
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
index acbd774..0edb8d5 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -37,7 +37,7 @@ struct netlink_sock {
 	struct mutex		*cb_mutex;
 	struct mutex		cb_def_mutex;
 	void			(*netlink_rcv)(struct sk_buff *skb);
-	void			(*netlink_bind)(int group);
+	int			(*netlink_bind)(int group);
 	struct module		*module;
 #ifdef CONFIG_NETLINK_MMAP
 	struct mutex		pg_vec_lock;
@@ -73,7 +73,7 @@ struct netlink_table {
 	unsigned int		groups;
 	struct mutex		*cb_mutex;
 	struct module		*module;
-	void			(*bind)(int group);
+	int			(*bind)(int group);
 	bool			(*compare)(struct net *net, struct sock *sock);
 	int			registered;
 };
-- 
1.7.1

