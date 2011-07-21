From: kaber@trash.net
Subject: [PATCH 2/8] netfilter: nfnetlink: add RCU in nfnetlink_rcv_msg()
Date: Thu, 21 Jul 2011 12:17:50 +0200
Message-ID: <1311243476-18236-3-git-send-email-kaber@trash.net>
References: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34510 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab1GUKSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 06:18:01 -0400
In-Reply-To: <1311243476-18236-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Goal of this patch is to permit nfnetlink providers not mandate
nfnl_mutex being held while nfnetlink_rcv_msg() calls them.

If struct nfnl_callback contains a non NULL call_rcu(), then
nfnetlink_rcv_msg() will use it instead of call() field, holding
rcu_read_lock instead of nfnl_mutex

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Florian Westphal <fw@strlen.de>
CC: Eric Leblond <eric@regit.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink.h |    3 ++
 net/netfilter/nfnetlink.c           |   40 ++++++++++++++++++++++++++--------
 2 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 2b11fc1..74d3386 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -60,6 +60,9 @@ struct nfnl_callback {
 	int (*call)(struct sock *nl, struct sk_buff *skb, 
 		    const struct nlmsghdr *nlh,
 		    const struct nlattr * const cda[]);
+	int (*call_rcu)(struct sock *nl, struct sk_buff *skb, 
+		    const struct nlmsghdr *nlh,
+		    const struct nlattr * const cda[]);
 	const struct nla_policy *policy;	/* netlink attribute policy */
 	const u_int16_t attr_count;		/* number of nlattr's */
 };
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index b4a4532..1905976 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -37,7 +37,7 @@ MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_NETFILTER);
 
 static char __initdata nfversion[] = "0.30";
 
-static const struct nfnetlink_subsystem *subsys_table[NFNL_SUBSYS_COUNT];
+static const struct nfnetlink_subsystem __rcu *subsys_table[NFNL_SUBSYS_COUNT];
 static DEFINE_MUTEX(nfnl_mutex);
 
 void nfnl_lock(void)
@@ -59,7 +59,7 @@ int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n)
 		nfnl_unlock();
 		return -EBUSY;
 	}
-	subsys_table[n->subsys_id] = n;
+	rcu_assign_pointer(subsys_table[n->subsys_id], n);
 	nfnl_unlock();
 
 	return 0;
@@ -71,7 +71,7 @@ int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n)
 	nfnl_lock();
 	subsys_table[n->subsys_id] = NULL;
 	nfnl_unlock();
-
+	synchronize_rcu();
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nfnetlink_subsys_unregister);
@@ -83,7 +83,7 @@ static inline const struct nfnetlink_subsystem *nfnetlink_get_subsys(u_int16_t t
 	if (subsys_id >= NFNL_SUBSYS_COUNT)
 		return NULL;
 
-	return subsys_table[subsys_id];
+	return rcu_dereference(subsys_table[subsys_id]);
 }
 
 static inline const struct nfnl_callback *
@@ -139,21 +139,27 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	type = nlh->nlmsg_type;
 replay:
+	rcu_read_lock();
 	ss = nfnetlink_get_subsys(type);
 	if (!ss) {
 #ifdef CONFIG_MODULES
-		nfnl_unlock();
+		rcu_read_unlock();
 		request_module("nfnetlink-subsys-%d", NFNL_SUBSYS_ID(type));
-		nfnl_lock();
+		rcu_read_lock();
 		ss = nfnetlink_get_subsys(type);
 		if (!ss)
 #endif
+		{
+			rcu_read_unlock();
 			return -EINVAL;
+		}
 	}
 
 	nc = nfnetlink_find_client(type, ss);
-	if (!nc)
+	if (!nc) {
+		rcu_read_unlock();
 		return -EINVAL;
+	}
 
 	{
 		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
@@ -167,7 +173,23 @@ replay:
 		if (err < 0)
 			return err;
 
-		err = nc->call(net->nfnl, skb, nlh, (const struct nlattr **)cda);
+		if (nc->call_rcu) {
+			err = nc->call_rcu(net->nfnl, skb, nlh,
+					   (const struct nlattr **)cda);
+			rcu_read_unlock();
+		} else {
+			rcu_read_unlock();
+			nfnl_lock();
+			if (rcu_dereference_protected(
+					subsys_table[NFNL_SUBSYS_ID(type)],
+					lockdep_is_held(&nfnl_mutex)) != ss ||
+			    nfnetlink_find_client(type, ss) != nc)
+				err = -EAGAIN;
+			else
+				err = nc->call(net->nfnl, skb, nlh,
+						   (const struct nlattr **)cda);
+			nfnl_unlock();
+		}
 		if (err == -EAGAIN)
 			goto replay;
 		return err;
@@ -176,9 +198,7 @@ replay:
 
 static void nfnetlink_rcv(struct sk_buff *skb)
 {
-	nfnl_lock();
 	netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
-	nfnl_unlock();
 }
 
 static int __net_init nfnetlink_net_init(struct net *net)
-- 
1.7.2.3

