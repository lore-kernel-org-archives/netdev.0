From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/38] netfilter: ip_set: rename nfnl_dereference()/nfnl_set()
Date: Mon, 17 Mar 2014 13:42:24 +0100
Message-ID: <1395060178-11833-5-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The next patch will introduce a nfnl_dereference() macro that actually
checks that the appropriate mutex is held and therefore needs a
subsystem argument.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c |   46 ++++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index de770ec..728a2cf 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -54,10 +54,10 @@ MODULE_DESCRIPTION("core IP set support");
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_IPSET);
 
 /* When the nfnl mutex is held: */
-#define nfnl_dereference(p)		\
+#define ip_set_dereference(p)		\
 	rcu_dereference_protected(p, 1)
-#define nfnl_set(inst, id)			\
-	nfnl_dereference((inst)->ip_set_list)[id]
+#define ip_set(inst, id)		\
+	ip_set_dereference((inst)->ip_set_list)[id]
 
 /*
  * The set types are implemented in modules and registered set types
@@ -640,7 +640,7 @@ ip_set_nfnl_get_byindex(struct net *net, ip_set_id_t index)
 		return IPSET_INVALID_ID;
 
 	nfnl_lock(NFNL_SUBSYS_IPSET);
-	set = nfnl_set(inst, index);
+	set = ip_set(inst, index);
 	if (set)
 		__ip_set_get(set);
 	else
@@ -666,7 +666,7 @@ ip_set_nfnl_put(struct net *net, ip_set_id_t index)
 
 	nfnl_lock(NFNL_SUBSYS_IPSET);
 	if (!inst->is_deleted) { /* already deleted from ip_set_net_exit() */
-		set = nfnl_set(inst, index);
+		set = ip_set(inst, index);
 		if (set != NULL)
 			__ip_set_put(set);
 	}
@@ -734,7 +734,7 @@ find_set_and_id(struct ip_set_net *inst, const char *name, ip_set_id_t *id)
 
 	*id = IPSET_INVALID_ID;
 	for (i = 0; i < inst->ip_set_max; i++) {
-		set = nfnl_set(inst, i);
+		set = ip_set(inst, i);
 		if (set != NULL && STREQ(set->name, name)) {
 			*id = i;
 			break;
@@ -760,7 +760,7 @@ find_free_id(struct ip_set_net *inst, const char *name, ip_set_id_t *index,
 
 	*index = IPSET_INVALID_ID;
 	for (i = 0;  i < inst->ip_set_max; i++) {
-		s = nfnl_set(inst, i);
+		s = ip_set(inst, i);
 		if (s == NULL) {
 			if (*index == IPSET_INVALID_ID)
 				*index = i;
@@ -883,7 +883,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 		if (!list)
 			goto cleanup;
 		/* nfnl mutex is held, both lists are valid */
-		tmp = nfnl_dereference(inst->ip_set_list);
+		tmp = ip_set_dereference(inst->ip_set_list);
 		memcpy(list, tmp, sizeof(struct ip_set *) * inst->ip_set_max);
 		rcu_assign_pointer(inst->ip_set_list, list);
 		/* Make sure all current packets have passed through */
@@ -900,7 +900,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	 * Finally! Add our shiny new set to the list, and be done.
 	 */
 	pr_debug("create: '%s' created with index %u!\n", set->name, index);
-	nfnl_set(inst, index) = set;
+	ip_set(inst, index) = set;
 
 	return ret;
 
@@ -925,10 +925,10 @@ ip_set_setname_policy[IPSET_ATTR_CMD_MAX + 1] = {
 static void
 ip_set_destroy_set(struct ip_set_net *inst, ip_set_id_t index)
 {
-	struct ip_set *set = nfnl_set(inst, index);
+	struct ip_set *set = ip_set(inst, index);
 
 	pr_debug("set: %s\n",  set->name);
-	nfnl_set(inst, index) = NULL;
+	ip_set(inst, index) = NULL;
 
 	/* Must call it without holding any lock */
 	set->variant->destroy(set);
@@ -962,7 +962,7 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 	read_lock_bh(&ip_set_ref_lock);
 	if (!attr[IPSET_ATTR_SETNAME]) {
 		for (i = 0; i < inst->ip_set_max; i++) {
-			s = nfnl_set(inst, i);
+			s = ip_set(inst, i);
 			if (s != NULL && s->ref) {
 				ret = -IPSET_ERR_BUSY;
 				goto out;
@@ -970,7 +970,7 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 		}
 		read_unlock_bh(&ip_set_ref_lock);
 		for (i = 0; i < inst->ip_set_max; i++) {
-			s = nfnl_set(inst, i);
+			s = ip_set(inst, i);
 			if (s != NULL)
 				ip_set_destroy_set(inst, i);
 		}
@@ -1020,7 +1020,7 @@ ip_set_flush(struct sock *ctnl, struct sk_buff *skb,
 
 	if (!attr[IPSET_ATTR_SETNAME]) {
 		for (i = 0; i < inst->ip_set_max; i++) {
-			s = nfnl_set(inst, i);
+			s = ip_set(inst, i);
 			if (s != NULL)
 				ip_set_flush_set(s);
 		}
@@ -1074,7 +1074,7 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 
 	name2 = nla_data(attr[IPSET_ATTR_SETNAME2]);
 	for (i = 0; i < inst->ip_set_max; i++) {
-		s = nfnl_set(inst, i);
+		s = ip_set(inst, i);
 		if (s != NULL && STREQ(s->name, name2)) {
 			ret = -IPSET_ERR_EXIST_SETNAME2;
 			goto out;
@@ -1134,8 +1134,8 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 
 	write_lock_bh(&ip_set_ref_lock);
 	swap(from->ref, to->ref);
-	nfnl_set(inst, from_id) = to;
-	nfnl_set(inst, to_id) = from;
+	ip_set(inst, from_id) = to;
+	ip_set(inst, to_id) = from;
 	write_unlock_bh(&ip_set_ref_lock);
 
 	return 0;
@@ -1157,7 +1157,7 @@ ip_set_dump_done(struct netlink_callback *cb)
 	struct ip_set_net *inst = (struct ip_set_net *)cb->args[IPSET_CB_NET];
 	if (cb->args[IPSET_CB_ARG0]) {
 		pr_debug("release set %s\n",
-			 nfnl_set(inst, cb->args[IPSET_CB_INDEX])->name);
+			 ip_set(inst, cb->args[IPSET_CB_INDEX])->name);
 		__ip_set_put_byindex(inst,
 			(ip_set_id_t) cb->args[IPSET_CB_INDEX]);
 	}
@@ -1254,7 +1254,7 @@ dump_last:
 		 dump_type, dump_flags, cb->args[IPSET_CB_INDEX]);
 	for (; cb->args[IPSET_CB_INDEX] < max; cb->args[IPSET_CB_INDEX]++) {
 		index = (ip_set_id_t) cb->args[IPSET_CB_INDEX];
-		set = nfnl_set(inst, index);
+		set = ip_set(inst, index);
 		if (set == NULL) {
 			if (dump_type == DUMP_ONE) {
 				ret = -ENOENT;
@@ -1332,7 +1332,7 @@ next_set:
 release_refcount:
 	/* If there was an error or set is done, release set */
 	if (ret || !cb->args[IPSET_CB_ARG0]) {
-		pr_debug("release set %s\n", nfnl_set(inst, index)->name);
+		pr_debug("release set %s\n", ip_set(inst, index)->name);
 		__ip_set_put_byindex(inst, index);
 		cb->args[IPSET_CB_ARG0] = 0;
 	}
@@ -1887,7 +1887,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		find_set_and_id(inst, req_get->set.name, &id);
 		req_get->set.index = id;
 		if (id != IPSET_INVALID_ID)
-			req_get->family = nfnl_set(inst, id)->family;
+			req_get->family = ip_set(inst, id)->family;
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
 	}
@@ -1901,7 +1901,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 			goto done;
 		}
 		nfnl_lock(NFNL_SUBSYS_IPSET);
-		set = nfnl_set(inst, req_get->set.index);
+		set = ip_set(inst, req_get->set.index);
 		strncpy(req_get->set.name, set ? set->name : "",
 			IPSET_MAXNAMELEN);
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
@@ -1960,7 +1960,7 @@ ip_set_net_exit(struct net *net)
 	inst->is_deleted = 1; /* flag for ip_set_nfnl_put */
 
 	for (i = 0; i < inst->ip_set_max; i++) {
-		set = nfnl_set(inst, i);
+		set = ip_set(inst, i);
 		if (set != NULL)
 			ip_set_destroy_set(inst, i);
 	}
-- 
1.7.10.4

