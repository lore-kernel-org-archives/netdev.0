From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/32] netfilter: ipset: Make sure listing doesn't grab a set which is just being destroyed.
Date: Mon, 15 Jun 2015 23:26:18 +0200
Message-ID: <1434403589-24796-22-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58810 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756181AbbFOVVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:34 -0400
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

There was a small window when all sets are destroyed and a concurrent
listing of all sets could grab a set which is just being destroyed.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_core.c |   49 +++++++++++++++++++++++++------------
 1 file changed, 34 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 777cac6..87b4182 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -32,7 +32,8 @@ static DEFINE_RWLOCK(ip_set_ref_lock);		/* protects the set refs */
 struct ip_set_net {
 	struct ip_set * __rcu *ip_set_list;	/* all individual sets */
 	ip_set_id_t	ip_set_max;	/* max number of sets */
-	int		is_deleted;	/* deleted by ip_set_net_exit */
+	bool		is_deleted;	/* deleted by ip_set_net_exit */
+	bool		is_destroyed;	/* all sets are destroyed */
 };
 static int ip_set_net_id __read_mostly;
 
@@ -980,12 +981,9 @@ ip_set_setname_policy[IPSET_ATTR_CMD_MAX + 1] = {
 };
 
 static void
-ip_set_destroy_set(struct ip_set_net *inst, ip_set_id_t index)
+ip_set_destroy_set(struct ip_set *set)
 {
-	struct ip_set *set = ip_set(inst, index);
-
 	pr_debug("set: %s\n",  set->name);
-	ip_set(inst, index) = NULL;
 
 	/* Must call it without holding any lock */
 	set->variant->destroy(set);
@@ -1025,12 +1023,17 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 				goto out;
 			}
 		}
+		inst->is_destroyed = true;
 		read_unlock_bh(&ip_set_ref_lock);
 		for (i = 0; i < inst->ip_set_max; i++) {
 			s = ip_set(inst, i);
-			if (s != NULL)
-				ip_set_destroy_set(inst, i);
+			if (s) {
+				ip_set(inst, i) = NULL;
+				ip_set_destroy_set(s);
+			}
 		}
+		/* Modified by ip_set_destroy() only, which is serialized */
+		inst->is_destroyed = false;
 	} else {
 		s = find_set_and_id(inst, nla_data(attr[IPSET_ATTR_SETNAME]),
 				    &i);
@@ -1041,9 +1044,10 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 			ret = -IPSET_ERR_BUSY;
 			goto out;
 		}
+		ip_set(inst, i) = NULL;
 		read_unlock_bh(&ip_set_ref_lock);
 
-		ip_set_destroy_set(inst, i);
+		ip_set_destroy_set(s);
 	}
 	return 0;
 out:
@@ -1283,6 +1287,7 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 	unsigned int flags = NETLINK_CB(cb->skb).portid ? NLM_F_MULTI : 0;
 	struct ip_set_net *inst = ip_set_pernet(sock_net(skb->sk));
 	u32 dump_type, dump_flags;
+	bool is_destroyed;
 	int ret = 0;
 
 	if (!cb->args[IPSET_CB_DUMP]) {
@@ -1309,12 +1314,20 @@ dump_last:
 		 dump_type, dump_flags, cb->args[IPSET_CB_INDEX]);
 	for (; cb->args[IPSET_CB_INDEX] < max; cb->args[IPSET_CB_INDEX]++) {
 		index = (ip_set_id_t) cb->args[IPSET_CB_INDEX];
+		write_lock_bh(&ip_set_ref_lock);
 		set = ip_set(inst, index);
-		if (set == NULL) {
+		is_destroyed = inst->is_destroyed;
+		if (!set || is_destroyed) {
+			write_unlock_bh(&ip_set_ref_lock);
 			if (dump_type == DUMP_ONE) {
 				ret = -ENOENT;
 				goto out;
 			}
+			if (is_destroyed) {
+				/* All sets are just being destroyed */
+				ret = 0;
+				goto out;
+			}
 			continue;
 		}
 		/* When dumping all sets, we must dump "sorted"
@@ -1322,14 +1335,17 @@ dump_last:
 		 */
 		if (dump_type != DUMP_ONE &&
 		    ((dump_type == DUMP_ALL) ==
-		     !!(set->type->features & IPSET_DUMP_LAST)))
+		     !!(set->type->features & IPSET_DUMP_LAST))) {
+			write_unlock_bh(&ip_set_ref_lock);
 			continue;
+		}
 		pr_debug("List set: %s\n", set->name);
 		if (!cb->args[IPSET_CB_ARG0]) {
 			/* Start listing: make sure set won't be destroyed */
 			pr_debug("reference set\n");
-			__ip_set_get(set);
+			set->ref++;
 		}
+		write_unlock_bh(&ip_set_ref_lock);
 		nlh = start_msg(skb, NETLINK_CB(cb->skb).portid,
 				cb->nlh->nlmsg_seq, flags,
 				IPSET_CMD_LIST);
@@ -2012,7 +2028,8 @@ ip_set_net_init(struct net *net)
 	list = kzalloc(sizeof(struct ip_set *) * inst->ip_set_max, GFP_KERNEL);
 	if (!list)
 		return -ENOMEM;
-	inst->is_deleted = 0;
+	inst->is_deleted = false;
+	inst->is_destroyed = false;
 	rcu_assign_pointer(inst->ip_set_list, list);
 	return 0;
 }
@@ -2025,12 +2042,14 @@ ip_set_net_exit(struct net *net)
 	struct ip_set *set = NULL;
 	ip_set_id_t i;
 
-	inst->is_deleted = 1; /* flag for ip_set_nfnl_put */
+	inst->is_deleted = true; /* flag for ip_set_nfnl_put */
 
 	for (i = 0; i < inst->ip_set_max; i++) {
 		set = ip_set(inst, i);
-		if (set != NULL)
-			ip_set_destroy_set(inst, i);
+		if (set) {
+			ip_set(inst, i) = NULL;
+			ip_set_destroy_set(set);
+		}
 	}
 	kfree(rcu_dereference_protected(inst->ip_set_list, 1));
 }
-- 
1.7.10.4
