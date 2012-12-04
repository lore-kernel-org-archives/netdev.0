From: pablo@netfilter.org
Subject: [PATCH 1/6] netfilter: ipset: Increase the number of maximal sets automatically
Date: Tue,  4 Dec 2012 18:31:28 +0100
Message-ID: <1354642293-4114-2-git-send-email-pablo@netfilter.org>
References: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54431 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754170Ab2LDRbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:31:51 -0500
In-Reply-To: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The max number of sets was hardcoded at kernel cofiguration time and
could only be modified via a module parameter. The patch adds the support
of increasing the max number of sets automatically, as needed.

The array of sets is incremented by 64 new slots if we run out of
empty slots. The absolute limit for the maximal number of sets
is limited by 65534.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c |  243 ++++++++++++++++++++++++-------------
 1 file changed, 160 insertions(+), 83 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index fed899f..6d6d8f2 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -28,9 +28,10 @@ static LIST_HEAD(ip_set_type_list);		/* all registered set types */
 static DEFINE_MUTEX(ip_set_type_mutex);		/* protects ip_set_type_list */
 static DEFINE_RWLOCK(ip_set_ref_lock);		/* protects the set refs */
 
-static struct ip_set **ip_set_list;		/* all individual sets */
+static struct ip_set * __rcu *ip_set_list;	/* all individual sets */
 static ip_set_id_t ip_set_max = CONFIG_IP_SET_MAX; /* max number of sets */
 
+#define IP_SET_INC	64
 #define STREQ(a, b)	(strncmp(a, b, IPSET_MAXNAMELEN) == 0)
 
 static unsigned int max_sets;
@@ -42,6 +43,12 @@ MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
 MODULE_DESCRIPTION("core IP set support");
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_IPSET);
 
+/* When the nfnl mutex is held: */
+#define nfnl_dereference(p)		\
+	rcu_dereference_protected(p, 1)
+#define nfnl_set(id)			\
+	nfnl_dereference(ip_set_list)[id]
+
 /*
  * The set types are implemented in modules and registered set types
  * can be found in ip_set_type_list. Adding/deleting types is
@@ -321,19 +328,19 @@ EXPORT_SYMBOL_GPL(ip_set_get_ipaddr6);
  */
 
 static inline void
-__ip_set_get(ip_set_id_t index)
+__ip_set_get(struct ip_set *set)
 {
 	write_lock_bh(&ip_set_ref_lock);
-	ip_set_list[index]->ref++;
+	set->ref++;
 	write_unlock_bh(&ip_set_ref_lock);
 }
 
 static inline void
-__ip_set_put(ip_set_id_t index)
+__ip_set_put(struct ip_set *set)
 {
 	write_lock_bh(&ip_set_ref_lock);
-	BUG_ON(ip_set_list[index]->ref == 0);
-	ip_set_list[index]->ref--;
+	BUG_ON(set->ref == 0);
+	set->ref--;
 	write_unlock_bh(&ip_set_ref_lock);
 }
 
@@ -344,12 +351,25 @@ __ip_set_put(ip_set_id_t index)
  * so it can't be destroyed (or changed) under our foot.
  */
 
+static inline struct ip_set *
+ip_set_rcu_get(ip_set_id_t index)
+{
+	struct ip_set *set;
+
+	rcu_read_lock();
+	/* ip_set_list itself needs to be protected */
+	set = rcu_dereference(ip_set_list)[index];
+	rcu_read_unlock();
+
+	return set;
+}
+
 int
 ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	    const struct xt_action_param *par,
 	    const struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_list[index];
+	struct ip_set *set = ip_set_rcu_get(index);
 	int ret = 0;
 
 	BUG_ON(set == NULL);
@@ -388,7 +408,7 @@ ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par,
 	   const struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_list[index];
+	struct ip_set *set = ip_set_rcu_get(index);
 	int ret;
 
 	BUG_ON(set == NULL);
@@ -411,7 +431,7 @@ ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par,
 	   const struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_list[index];
+	struct ip_set *set = ip_set_rcu_get(index);
 	int ret = 0;
 
 	BUG_ON(set == NULL);
@@ -440,14 +460,17 @@ ip_set_get_byname(const char *name, struct ip_set **set)
 	ip_set_id_t i, index = IPSET_INVALID_ID;
 	struct ip_set *s;
 
+	rcu_read_lock();
 	for (i = 0; i < ip_set_max; i++) {
-		s = ip_set_list[i];
+		s = rcu_dereference(ip_set_list)[i];
 		if (s != NULL && STREQ(s->name, name)) {
-			__ip_set_get(i);
+			__ip_set_get(s);
 			index = i;
 			*set = s;
+			break;
 		}
 	}
+	rcu_read_unlock();
 
 	return index;
 }
@@ -462,8 +485,13 @@ EXPORT_SYMBOL_GPL(ip_set_get_byname);
 void
 ip_set_put_byindex(ip_set_id_t index)
 {
-	if (ip_set_list[index] != NULL)
-		__ip_set_put(index);
+	struct ip_set *set;
+
+	rcu_read_lock();
+	set = rcu_dereference(ip_set_list)[index];
+	if (set != NULL)
+		__ip_set_put(set);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(ip_set_put_byindex);
 
@@ -477,7 +505,7 @@ EXPORT_SYMBOL_GPL(ip_set_put_byindex);
 const char *
 ip_set_name_byindex(ip_set_id_t index)
 {
-	const struct ip_set *set = ip_set_list[index];
+	const struct ip_set *set = ip_set_rcu_get(index);
 
 	BUG_ON(set == NULL);
 	BUG_ON(set->ref == 0);
@@ -501,11 +529,18 @@ EXPORT_SYMBOL_GPL(ip_set_name_byindex);
 ip_set_id_t
 ip_set_nfnl_get(const char *name)
 {
+	ip_set_id_t i, index = IPSET_INVALID_ID;
 	struct ip_set *s;
-	ip_set_id_t index;
 
 	nfnl_lock();
-	index = ip_set_get_byname(name, &s);
+	for (i = 0; i < ip_set_max; i++) {
+		s = nfnl_set(i);
+		if (s != NULL && STREQ(s->name, name)) {
+			__ip_set_get(s);
+			index = i;
+			break;
+		}
+	}
 	nfnl_unlock();
 
 	return index;
@@ -521,12 +556,15 @@ EXPORT_SYMBOL_GPL(ip_set_nfnl_get);
 ip_set_id_t
 ip_set_nfnl_get_byindex(ip_set_id_t index)
 {
+	struct ip_set *set;
+
 	if (index > ip_set_max)
 		return IPSET_INVALID_ID;
 
 	nfnl_lock();
-	if (ip_set_list[index])
-		__ip_set_get(index);
+	set = nfnl_set(index);
+	if (set)
+		__ip_set_get(set);
 	else
 		index = IPSET_INVALID_ID;
 	nfnl_unlock();
@@ -545,8 +583,11 @@ EXPORT_SYMBOL_GPL(ip_set_nfnl_get_byindex);
 void
 ip_set_nfnl_put(ip_set_id_t index)
 {
+	struct ip_set *set;
 	nfnl_lock();
-	ip_set_put_byindex(index);
+	set = nfnl_set(index);
+	if (set != NULL)
+		__ip_set_put(set);
 	nfnl_unlock();
 }
 EXPORT_SYMBOL_GPL(ip_set_nfnl_put);
@@ -603,41 +644,46 @@ static const struct nla_policy ip_set_create_policy[IPSET_ATTR_CMD_MAX + 1] = {
 	[IPSET_ATTR_DATA]	= { .type = NLA_NESTED },
 };
 
-static ip_set_id_t
-find_set_id(const char *name)
+static struct ip_set *
+find_set_and_id(const char *name, ip_set_id_t *id)
 {
-	ip_set_id_t i, index = IPSET_INVALID_ID;
-	const struct ip_set *set;
+	struct ip_set *set = NULL;
+	ip_set_id_t i;
 
-	for (i = 0; index == IPSET_INVALID_ID && i < ip_set_max; i++) {
-		set = ip_set_list[i];
-		if (set != NULL && STREQ(set->name, name))
-			index = i;
+	*id = IPSET_INVALID_ID;
+	for (i = 0; i < ip_set_max; i++) {
+		set = nfnl_set(i);
+		if (set != NULL && STREQ(set->name, name)) {
+			*id = i;
+			break;
+		}
 	}
-	return index;
+	return (*id == IPSET_INVALID_ID ? NULL : set);
 }
 
 static inline struct ip_set *
 find_set(const char *name)
 {
-	ip_set_id_t index = find_set_id(name);
+	ip_set_id_t id;
 
-	return index == IPSET_INVALID_ID ? NULL : ip_set_list[index];
+	return find_set_and_id(name, &id);
 }
 
 static int
 find_free_id(const char *name, ip_set_id_t *index, struct ip_set **set)
 {
+	struct ip_set *s;
 	ip_set_id_t i;
 
 	*index = IPSET_INVALID_ID;
 	for (i = 0;  i < ip_set_max; i++) {
-		if (ip_set_list[i] == NULL) {
+		s = nfnl_set(i);
+		if (s == NULL) {
 			if (*index == IPSET_INVALID_ID)
 				*index = i;
-		} else if (STREQ(name, ip_set_list[i]->name)) {
+		} else if (STREQ(name, s->name)) {
 			/* Name clash */
-			*set = ip_set_list[i];
+			*set = s;
 			return -EEXIST;
 		}
 	}
@@ -730,10 +776,9 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	 * and check clashing.
 	 */
 	ret = find_free_id(set->name, &index, &clash);
-	if (ret != 0) {
+	if (ret == -EEXIST) {
 		/* If this is the same set and requested, ignore error */
-		if (ret == -EEXIST &&
-		    (flags & IPSET_FLAG_EXIST) &&
+		if ((flags & IPSET_FLAG_EXIST) &&
 		    STREQ(set->type->name, clash->type->name) &&
 		    set->type->family == clash->type->family &&
 		    set->type->revision_min == clash->type->revision_min &&
@@ -741,13 +786,36 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 		    set->variant->same_set(set, clash))
 			ret = 0;
 		goto cleanup;
-	}
+	} else if (ret == -IPSET_ERR_MAX_SETS) {
+		struct ip_set **list, **tmp;
+		ip_set_id_t i = ip_set_max + IP_SET_INC;
+
+		if (i < ip_set_max || i == IPSET_INVALID_ID)
+			/* Wraparound */
+			goto cleanup;
+
+		list = kzalloc(sizeof(struct ip_set *) * i, GFP_KERNEL);
+		if (!list)
+			goto cleanup;
+		/* nfnl mutex is held, both lists are valid */
+		tmp = nfnl_dereference(ip_set_list);
+		memcpy(list, tmp, sizeof(struct ip_set *) * ip_set_max);
+		rcu_assign_pointer(ip_set_list, list);
+		/* Make sure all current packets have passed through */
+		synchronize_net();
+		/* Use new list */
+		index = ip_set_max;
+		ip_set_max = i;
+		kfree(tmp);
+		ret = 0;
+	} else if (ret)
+		goto cleanup;
 
 	/*
 	 * Finally! Add our shiny new set to the list, and be done.
 	 */
 	pr_debug("create: '%s' created with index %u!\n", set->name, index);
-	ip_set_list[index] = set;
+	nfnl_set(index) = set;
 
 	return ret;
 
@@ -772,10 +840,10 @@ ip_set_setname_policy[IPSET_ATTR_CMD_MAX + 1] = {
 static void
 ip_set_destroy_set(ip_set_id_t index)
 {
-	struct ip_set *set = ip_set_list[index];
+	struct ip_set *set = nfnl_set(index);
 
 	pr_debug("set: %s\n",  set->name);
-	ip_set_list[index] = NULL;
+	nfnl_set(index) = NULL;
 
 	/* Must call it without holding any lock */
 	set->variant->destroy(set);
@@ -788,6 +856,7 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 	       const struct nlmsghdr *nlh,
 	       const struct nlattr * const attr[])
 {
+	struct ip_set *s;
 	ip_set_id_t i;
 	int ret = 0;
 
@@ -807,22 +876,24 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 	read_lock_bh(&ip_set_ref_lock);
 	if (!attr[IPSET_ATTR_SETNAME]) {
 		for (i = 0; i < ip_set_max; i++) {
-			if (ip_set_list[i] != NULL && ip_set_list[i]->ref) {
+			s = nfnl_set(i);
+			if (s != NULL && s->ref) {
 				ret = -IPSET_ERR_BUSY;
 				goto out;
 			}
 		}
 		read_unlock_bh(&ip_set_ref_lock);
 		for (i = 0; i < ip_set_max; i++) {
-			if (ip_set_list[i] != NULL)
+			s = nfnl_set(i);
+			if (s != NULL)
 				ip_set_destroy_set(i);
 		}
 	} else {
-		i = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
-		if (i == IPSET_INVALID_ID) {
+		s = find_set_and_id(nla_data(attr[IPSET_ATTR_SETNAME]), &i);
+		if (s == NULL) {
 			ret = -ENOENT;
 			goto out;
-		} else if (ip_set_list[i]->ref) {
+		} else if (s->ref) {
 			ret = -IPSET_ERR_BUSY;
 			goto out;
 		}
@@ -853,21 +924,24 @@ ip_set_flush(struct sock *ctnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh,
 	     const struct nlattr * const attr[])
 {
+	struct ip_set *s;
 	ip_set_id_t i;
 
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (!attr[IPSET_ATTR_SETNAME]) {
-		for (i = 0; i < ip_set_max; i++)
-			if (ip_set_list[i] != NULL)
-				ip_set_flush_set(ip_set_list[i]);
+		for (i = 0; i < ip_set_max; i++) {
+			s = nfnl_set(i);
+			if (s != NULL)
+				ip_set_flush_set(s);
+		}
 	} else {
-		i = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
-		if (i == IPSET_INVALID_ID)
+		s = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+		if (s == NULL)
 			return -ENOENT;
 
-		ip_set_flush_set(ip_set_list[i]);
+		ip_set_flush_set(s);
 	}
 
 	return 0;
@@ -889,7 +963,7 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 	      const struct nlmsghdr *nlh,
 	      const struct nlattr * const attr[])
 {
-	struct ip_set *set;
+	struct ip_set *set, *s;
 	const char *name2;
 	ip_set_id_t i;
 	int ret = 0;
@@ -911,8 +985,8 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 
 	name2 = nla_data(attr[IPSET_ATTR_SETNAME2]);
 	for (i = 0; i < ip_set_max; i++) {
-		if (ip_set_list[i] != NULL &&
-		    STREQ(ip_set_list[i]->name, name2)) {
+		s = nfnl_set(i);
+		if (s != NULL && STREQ(s->name, name2)) {
 			ret = -IPSET_ERR_EXIST_SETNAME2;
 			goto out;
 		}
@@ -947,17 +1021,14 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 		     attr[IPSET_ATTR_SETNAME2] == NULL))
 		return -IPSET_ERR_PROTOCOL;
 
-	from_id = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
-	if (from_id == IPSET_INVALID_ID)
+	from = find_set_and_id(nla_data(attr[IPSET_ATTR_SETNAME]), &from_id);
+	if (from == NULL)
 		return -ENOENT;
 
-	to_id = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME2]));
-	if (to_id == IPSET_INVALID_ID)
+	to = find_set_and_id(nla_data(attr[IPSET_ATTR_SETNAME2]), &to_id);
+	if (to == NULL)
 		return -IPSET_ERR_EXIST_SETNAME2;
 
-	from = ip_set_list[from_id];
-	to = ip_set_list[to_id];
-
 	/* Features must not change.
 	 * Not an artificial restriction anymore, as we must prevent
 	 * possible loops created by swapping in setlist type of sets. */
@@ -971,8 +1042,8 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 
 	write_lock_bh(&ip_set_ref_lock);
 	swap(from->ref, to->ref);
-	ip_set_list[from_id] = to;
-	ip_set_list[to_id] = from;
+	nfnl_set(from_id) = to;
+	nfnl_set(to_id) = from;
 	write_unlock_bh(&ip_set_ref_lock);
 
 	return 0;
@@ -992,7 +1063,7 @@ static int
 ip_set_dump_done(struct netlink_callback *cb)
 {
 	if (cb->args[2]) {
-		pr_debug("release set %s\n", ip_set_list[cb->args[1]]->name);
+		pr_debug("release set %s\n", nfnl_set(cb->args[1])->name);
 		ip_set_put_byindex((ip_set_id_t) cb->args[1]);
 	}
 	return 0;
@@ -1030,8 +1101,11 @@ dump_init(struct netlink_callback *cb)
 	 */
 
 	if (cda[IPSET_ATTR_SETNAME]) {
-		index = find_set_id(nla_data(cda[IPSET_ATTR_SETNAME]));
-		if (index == IPSET_INVALID_ID)
+		struct ip_set *set;
+
+		set = find_set_and_id(nla_data(cda[IPSET_ATTR_SETNAME]),
+				      &index);
+		if (set == NULL)
 			return -ENOENT;
 
 		dump_type = DUMP_ONE;
@@ -1081,7 +1155,7 @@ dump_last:
 		 dump_type, dump_flags, cb->args[1]);
 	for (; cb->args[1] < max; cb->args[1]++) {
 		index = (ip_set_id_t) cb->args[1];
-		set = ip_set_list[index];
+		set = nfnl_set(index);
 		if (set == NULL) {
 			if (dump_type == DUMP_ONE) {
 				ret = -ENOENT;
@@ -1100,7 +1174,7 @@ dump_last:
 		if (!cb->args[2]) {
 			/* Start listing: make sure set won't be destroyed */
 			pr_debug("reference set\n");
-			__ip_set_get(index);
+			__ip_set_get(set);
 		}
 		nlh = start_msg(skb, NETLINK_CB(cb->skb).portid,
 				cb->nlh->nlmsg_seq, flags,
@@ -1159,7 +1233,7 @@ next_set:
 release_refcount:
 	/* If there was an error or set is done, release set */
 	if (ret || !cb->args[2]) {
-		pr_debug("release set %s\n", ip_set_list[index]->name);
+		pr_debug("release set %s\n", nfnl_set(index)->name);
 		ip_set_put_byindex(index);
 		cb->args[2] = 0;
 	}
@@ -1409,17 +1483,15 @@ ip_set_header(struct sock *ctnl, struct sk_buff *skb,
 	const struct ip_set *set;
 	struct sk_buff *skb2;
 	struct nlmsghdr *nlh2;
-	ip_set_id_t index;
 	int ret = 0;
 
 	if (unlikely(protocol_failed(attr) ||
 		     attr[IPSET_ATTR_SETNAME] == NULL))
 		return -IPSET_ERR_PROTOCOL;
 
-	index = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
-	if (index == IPSET_INVALID_ID)
+	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	if (set == NULL)
 		return -ENOENT;
-	set = ip_set_list[index];
 
 	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (skb2 == NULL)
@@ -1684,6 +1756,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 	}
 	case IP_SET_OP_GET_BYNAME: {
 		struct ip_set_req_get_set *req_get = data;
+		ip_set_id_t id;
 
 		if (*len != sizeof(struct ip_set_req_get_set)) {
 			ret = -EINVAL;
@@ -1691,12 +1764,14 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		}
 		req_get->set.name[IPSET_MAXNAMELEN - 1] = '\0';
 		nfnl_lock();
-		req_get->set.index = find_set_id(req_get->set.name);
+		find_set_and_id(req_get->set.name, &id);
+		req_get->set.index = id;
 		nfnl_unlock();
 		goto copy;
 	}
 	case IP_SET_OP_GET_BYINDEX: {
 		struct ip_set_req_get_set *req_get = data;
+		struct ip_set *set;
 
 		if (*len != sizeof(struct ip_set_req_get_set) ||
 		    req_get->set.index >= ip_set_max) {
@@ -1704,9 +1779,8 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 			goto done;
 		}
 		nfnl_lock();
-		strncpy(req_get->set.name,
-			ip_set_list[req_get->set.index]
-				? ip_set_list[req_get->set.index]->name : "",
+		set = nfnl_set(req_get->set.index);
+		strncpy(req_get->set.name, set ? set->name : "",
 			IPSET_MAXNAMELEN);
 		nfnl_unlock();
 		goto copy;
@@ -1737,6 +1811,7 @@ static struct nf_sockopt_ops so_set __read_mostly = {
 static int __init
 ip_set_init(void)
 {
+	struct ip_set **list;
 	int ret;
 
 	if (max_sets)
@@ -1744,22 +1819,22 @@ ip_set_init(void)
 	if (ip_set_max >= IPSET_INVALID_ID)
 		ip_set_max = IPSET_INVALID_ID - 1;
 
-	ip_set_list = kzalloc(sizeof(struct ip_set *) * ip_set_max,
-			      GFP_KERNEL);
-	if (!ip_set_list)
+	list = kzalloc(sizeof(struct ip_set *) * ip_set_max, GFP_KERNEL);
+	if (!list)
 		return -ENOMEM;
 
+	rcu_assign_pointer(ip_set_list, list);
 	ret = nfnetlink_subsys_register(&ip_set_netlink_subsys);
 	if (ret != 0) {
 		pr_err("ip_set: cannot register with nfnetlink.\n");
-		kfree(ip_set_list);
+		kfree(list);
 		return ret;
 	}
 	ret = nf_register_sockopt(&so_set);
 	if (ret != 0) {
 		pr_err("SO_SET registry failed: %d\n", ret);
 		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
-		kfree(ip_set_list);
+		kfree(list);
 		return ret;
 	}
 
@@ -1770,10 +1845,12 @@ ip_set_init(void)
 static void __exit
 ip_set_fini(void)
 {
+	struct ip_set **list = rcu_dereference_protected(ip_set_list, 1);
+
 	/* There can't be any existing set */
 	nf_unregister_sockopt(&so_set);
 	nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
-	kfree(ip_set_list);
+	kfree(list);
 	pr_debug("these are the famous last words\n");
 }
 
-- 
1.7.10.4
