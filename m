From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 2/3] net: Add extack to fib_notifier_info
Date: Wed, 25 Oct 2017 22:08:04 -0700
Message-ID: <1508994485-24533-3-git-send-email-dsahern@gmail.com>
References: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, johannes.berg@intel.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:46260 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdJZFIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 01:08:15 -0400
Received: by mail-pf0-f195.google.com with SMTP id p87so1673185pfj.3
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 22:08:15 -0700 (PDT)
In-Reply-To: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack to fib_notifier_info and plumb through stack to
call_fib_rule_notifiers, call_fib_entry_notifiers and
call_fib6_entry_notifiers. This allows notifer handlers to
return messages to user.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/fib_notifier.h |  1 +
 net/core/fib_rules.c       |  9 ++++++---
 net/ipv4/fib_trie.c        | 13 ++++++++-----
 net/ipv6/ip6_fib.c         | 15 +++++++++------
 4 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/include/net/fib_notifier.h b/include/net/fib_notifier.h
index 54cd6b839d2f..c91ec732afd6 100644
--- a/include/net/fib_notifier.h
+++ b/include/net/fib_notifier.h
@@ -9,6 +9,7 @@
 struct fib_notifier_info {
 	struct net *net;
 	int family;
+	struct netlink_ext_ack  *extack;
 };
 
 enum fib_event_type {
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 9a6d97c1d810..fafd0a41e3f7 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -314,10 +314,12 @@ static int call_fib_rule_notifier(struct notifier_block *nb, struct net *net,
 static int call_fib_rule_notifiers(struct net *net,
 				   enum fib_event_type event_type,
 				   struct fib_rule *rule,
-				   struct fib_rules_ops *ops)
+				   struct fib_rules_ops *ops,
+				   struct netlink_ext_ack *extack)
 {
 	struct fib_rule_notifier_info info = {
 		.info.family = ops->family,
+		.info.extack = extack,
 		.rule = rule,
 	};
 
@@ -609,7 +611,7 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (rule->tun_id)
 		ip_tunnel_need_metadata();
 
-	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD, rule, ops);
+	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD, rule, ops, extack);
 	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).portid);
 	flush_route_cache(ops);
 	rules_ops_put(ops);
@@ -749,7 +751,8 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 			}
 		}
 
-		call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL, rule, ops);
+		call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL, rule, ops,
+					NULL);
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
 				   NETLINK_CB(skb).portid);
 		fib_rule_put(rule);
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index aaa1ba09afaa..5ddc4aefff12 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -102,9 +102,11 @@ static int call_fib_entry_notifier(struct notifier_block *nb, struct net *net,
 
 static int call_fib_entry_notifiers(struct net *net,
 				    enum fib_event_type event_type, u32 dst,
-				    int dst_len, struct fib_alias *fa)
+				    int dst_len, struct fib_alias *fa,
+				    struct netlink_ext_ack *extack)
 {
 	struct fib_entry_notifier_info info = {
+		.info.extack = extack,
 		.dst = dst,
 		.dst_len = dst_len,
 		.fi = fa->fa_info,
@@ -1214,7 +1216,7 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 			new_fa->fa_default = -1;
 
 			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_REPLACE,
-						 key, plen, new_fa);
+						 key, plen, new_fa, extack);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
 				  tb->tb_id, &cfg->fc_nlinfo, nlflags);
 
@@ -1269,7 +1271,7 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 		tb->tb_num_default++;
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
-	call_fib_entry_notifiers(net, event, key, plen, new_fa);
+	call_fib_entry_notifiers(net, event, key, plen, new_fa, extack);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
 		  &cfg->fc_nlinfo, nlflags);
 succeeded:
@@ -1569,7 +1571,7 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 		return -ESRCH;
 
 	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, key, plen,
-				 fa_to_delete);
+				 fa_to_delete, extack);
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1886,7 +1888,8 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 
 			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL,
 						 n->key,
-						 KEYLENGTH - fa->fa_slen, fa);
+						 KEYLENGTH - fa->fa_slen, fa,
+						 NULL);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 1ada9672d198..2e2804f5823e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -353,9 +353,11 @@ static int call_fib6_entry_notifier(struct notifier_block *nb, struct net *net,
 
 static int call_fib6_entry_notifiers(struct net *net,
 				     enum fib_event_type event_type,
-				     struct rt6_info *rt)
+				     struct rt6_info *rt,
+				     struct netlink_ext_ack *extack)
 {
 	struct fib6_entry_notifier_info info = {
+		.info.extack = extack,
 		.rt = rt,
 	};
 
@@ -868,7 +870,8 @@ static void fib6_purge_rt(struct rt6_info *rt, struct fib6_node *fn,
  */
 
 static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
-			    struct nl_info *info, struct mx6_config *mxc)
+			    struct nl_info *info, struct mx6_config *mxc,
+			    struct netlink_ext_ack *extack)
 {
 	struct rt6_info *leaf = rcu_dereference_protected(fn->leaf,
 				    lockdep_is_held(&rt->rt6i_table->tb6_lock));
@@ -1011,7 +1014,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		rcu_assign_pointer(rt->rt6i_node, fn);
 		rcu_assign_pointer(*ins, rt);
 		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_ADD,
-					  rt);
+					  rt, extack);
 		if (!info->skip_notify)
 			inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
@@ -1040,7 +1043,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		rt->dst.rt6_next = iter->dst.rt6_next;
 		rcu_assign_pointer(*ins, rt);
 		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_REPLACE,
-					  rt);
+					  rt, extack);
 		if (!info->skip_notify)
 			inet6_rt_notify(RTM_NEWROUTE, rt, info, NLM_F_REPLACE);
 		if (!(fn->fn_flags & RTN_RTINFO)) {
@@ -1225,7 +1228,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 	}
 #endif
 
-	err = fib6_add_rt2node(fn, rt, info, mxc);
+	err = fib6_add_rt2node(fn, rt, info, mxc, extack);
 	if (!err) {
 		fib6_update_sernum_upto_root(rt, sernum);
 		fib6_start_gc(info->nl_net, rt);
@@ -1686,7 +1689,7 @@ static void fib6_del_route(struct fib6_table *table, struct fib6_node *fn,
 
 	fib6_purge_rt(rt, fn, net);
 
-	call_fib6_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, rt);
+	call_fib6_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, rt, NULL);
 	if (!info->skip_notify)
 		inet6_rt_notify(RTM_DELROUTE, rt, info, 0);
 	rt6_release(rt);
-- 
2.1.4
