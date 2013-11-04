From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/20] netfilter: ipset: Use netlink callback dump args only
Date: Mon,  4 Nov 2013 22:50:33 +0100
Message-ID: <1383601842-4570-12-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55757 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816Ab3KDVvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:51:08 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Instead of cb->data, use callback dump args only and introduce symbolic
names instead of plain numbers at accessing the argument members.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h  |   10 +++++
 net/netfilter/ipset/ip_set_bitmap_gen.h |   11 ++---
 net/netfilter/ipset/ip_set_core.c       |   70 +++++++++++++++----------------
 net/netfilter/ipset/ip_set_hash_gen.h   |   20 +++++----
 net/netfilter/ipset/ip_set_list_set.c   |   11 ++---
 5 files changed, 68 insertions(+), 54 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 7967516..c7174b8 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -316,6 +316,16 @@ ip_set_init_counter(struct ip_set_counter *counter,
 		atomic64_set(&(counter)->packets, (long long)(ext->packets));
 }
 
+/* Netlink CB args */
+enum {
+	IPSET_CB_NET = 0,
+	IPSET_CB_DUMP,
+	IPSET_CB_INDEX,
+	IPSET_CB_ARG0,
+	IPSET_CB_ARG1,
+	IPSET_CB_ARG2,
+};
+
 /* register and unregister set references */
 extern ip_set_id_t ip_set_get_byname(struct net *net,
 				     const char *name, struct ip_set **set);
diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index a13e15b..f2c7d83 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -198,13 +198,14 @@ mtype_list(const struct ip_set *set,
 	struct mtype *map = set->data;
 	struct nlattr *adt, *nested;
 	void *x;
-	u32 id, first = cb->args[2];
+	u32 id, first = cb->args[IPSET_CB_ARG0];
 
 	adt = ipset_nest_start(skb, IPSET_ATTR_ADT);
 	if (!adt)
 		return -EMSGSIZE;
-	for (; cb->args[2] < map->elements; cb->args[2]++) {
-		id = cb->args[2];
+	for (; cb->args[IPSET_CB_ARG0] < map->elements;
+	     cb->args[IPSET_CB_ARG0]++) {
+		id = cb->args[IPSET_CB_ARG0];
 		x = get_ext(set, map, id);
 		if (!test_bit(id, map->members) ||
 		    (SET_WITH_TIMEOUT(set) &&
@@ -231,14 +232,14 @@ mtype_list(const struct ip_set *set,
 	ipset_nest_end(skb, adt);
 
 	/* Set listing finished */
-	cb->args[2] = 0;
+	cb->args[IPSET_CB_ARG0] = 0;
 
 	return 0;
 
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
 	if (unlikely(id == first)) {
-		cb->args[2] = 0;
+		cb->args[IPSET_CB_ARG0] = 0;
 		return -EMSGSIZE;
 	}
 	ipset_nest_end(skb, adt);
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index dc9284b..bac7e01 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1182,10 +1182,12 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 static int
 ip_set_dump_done(struct netlink_callback *cb)
 {
-	struct ip_set_net *inst = (struct ip_set_net *)cb->data;
-	if (cb->args[2]) {
-		pr_debug("release set %s\n", nfnl_set(inst, cb->args[1])->name);
-		__ip_set_put_byindex(inst, (ip_set_id_t) cb->args[1]);
+	struct ip_set_net *inst = (struct ip_set_net *)cb->args[IPSET_CB_NET];
+	if (cb->args[IPSET_CB_ARG0]) {
+		pr_debug("release set %s\n",
+			 nfnl_set(inst, cb->args[IPSET_CB_INDEX])->name);
+		__ip_set_put_byindex(inst,
+			(ip_set_id_t) cb->args[IPSET_CB_INDEX]);
 	}
 	return 0;
 }
@@ -1203,7 +1205,7 @@ dump_attrs(struct nlmsghdr *nlh)
 }
 
 static int
-dump_init(struct netlink_callback *cb)
+dump_init(struct netlink_callback *cb, struct ip_set_net *inst)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(cb->skb);
 	int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
@@ -1211,15 +1213,15 @@ dump_init(struct netlink_callback *cb)
 	struct nlattr *attr = (void *)nlh + min_len;
 	u32 dump_type;
 	ip_set_id_t index;
-	struct ip_set_net *inst = (struct ip_set_net *)cb->data;
 
 	/* Second pass, so parser can't fail */
 	nla_parse(cda, IPSET_ATTR_CMD_MAX,
 		  attr, nlh->nlmsg_len - min_len, ip_set_setname_policy);
 
-	/* cb->args[0] : dump single set/all sets
-	 *         [1] : set index
-	 *         [..]: type specific
+	/* cb->args[IPSET_CB_NET]:	net namespace
+	 *         [IPSET_CB_DUMP]:	dump single set/all sets
+	 *         [IPSET_CB_INDEX]: 	set index
+	 *         [IPSET_CB_ARG0]:	type specific
 	 */
 
 	if (cda[IPSET_ATTR_SETNAME]) {
@@ -1231,7 +1233,7 @@ dump_init(struct netlink_callback *cb)
 			return -ENOENT;
 
 		dump_type = DUMP_ONE;
-		cb->args[1] = index;
+		cb->args[IPSET_CB_INDEX] = index;
 	} else
 		dump_type = DUMP_ALL;
 
@@ -1239,7 +1241,8 @@ dump_init(struct netlink_callback *cb)
 		u32 f = ip_set_get_h32(cda[IPSET_ATTR_FLAGS]);
 		dump_type |= (f << 16);
 	}
-	cb->args[0] = dump_type;
+	cb->args[IPSET_CB_NET] = (unsigned long)inst;
+	cb->args[IPSET_CB_DUMP] = dump_type;
 
 	return 0;
 }
@@ -1251,12 +1254,12 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 	struct ip_set *set = NULL;
 	struct nlmsghdr *nlh = NULL;
 	unsigned int flags = NETLINK_CB(cb->skb).portid ? NLM_F_MULTI : 0;
+	struct ip_set_net *inst = ip_set_pernet(sock_net(skb->sk));
 	u32 dump_type, dump_flags;
 	int ret = 0;
-	struct ip_set_net *inst = (struct ip_set_net *)cb->data;
 
-	if (!cb->args[0]) {
-		ret = dump_init(cb);
+	if (!cb->args[IPSET_CB_DUMP]) {
+		ret = dump_init(cb, inst);
 		if (ret < 0) {
 			nlh = nlmsg_hdr(cb->skb);
 			/* We have to create and send the error message
@@ -1267,17 +1270,18 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 		}
 	}
 
-	if (cb->args[1] >= inst->ip_set_max)
+	if (cb->args[IPSET_CB_INDEX] >= inst->ip_set_max)
 		goto out;
 
-	dump_type = DUMP_TYPE(cb->args[0]);
-	dump_flags = DUMP_FLAGS(cb->args[0]);
-	max = dump_type == DUMP_ONE ? cb->args[1] + 1 : inst->ip_set_max;
+	dump_type = DUMP_TYPE(cb->args[IPSET_CB_DUMP]);
+	dump_flags = DUMP_FLAGS(cb->args[IPSET_CB_DUMP]);
+	max = dump_type == DUMP_ONE ? cb->args[IPSET_CB_INDEX] + 1
+				    : inst->ip_set_max;
 dump_last:
-	pr_debug("args[0]: %u %u args[1]: %ld\n",
-		 dump_type, dump_flags, cb->args[1]);
-	for (; cb->args[1] < max; cb->args[1]++) {
-		index = (ip_set_id_t) cb->args[1];
+	pr_debug("dump type, flag: %u %u index: %ld\n",
+		 dump_type, dump_flags, cb->args[IPSET_CB_INDEX]);
+	for (; cb->args[IPSET_CB_INDEX] < max; cb->args[IPSET_CB_INDEX]++) {
+		index = (ip_set_id_t) cb->args[IPSET_CB_INDEX];
 		set = nfnl_set(inst, index);
 		if (set == NULL) {
 			if (dump_type == DUMP_ONE) {
@@ -1294,7 +1298,7 @@ dump_last:
 		     !!(set->type->features & IPSET_DUMP_LAST)))
 			continue;
 		pr_debug("List set: %s\n", set->name);
-		if (!cb->args[2]) {
+		if (!cb->args[IPSET_CB_ARG0]) {
 			/* Start listing: make sure set won't be destroyed */
 			pr_debug("reference set\n");
 			__ip_set_get(set);
@@ -1311,7 +1315,7 @@ dump_last:
 			goto nla_put_failure;
 		if (dump_flags & IPSET_FLAG_LIST_SETNAME)
 			goto next_set;
-		switch (cb->args[2]) {
+		switch (cb->args[IPSET_CB_ARG0]) {
 		case 0:
 			/* Core header data */
 			if (nla_put_string(skb, IPSET_ATTR_TYPENAME,
@@ -1331,7 +1335,7 @@ dump_last:
 			read_lock_bh(&set->lock);
 			ret = set->variant->list(set, skb, cb);
 			read_unlock_bh(&set->lock);
-			if (!cb->args[2])
+			if (!cb->args[IPSET_CB_ARG0])
 				/* Set is done, proceed with next one */
 				goto next_set;
 			goto release_refcount;
@@ -1340,8 +1344,8 @@ dump_last:
 	/* If we dump all sets, continue with dumping last ones */
 	if (dump_type == DUMP_ALL) {
 		dump_type = DUMP_LAST;
-		cb->args[0] = dump_type | (dump_flags << 16);
-		cb->args[1] = 0;
+		cb->args[IPSET_CB_DUMP] = dump_type | (dump_flags << 16);
+		cb->args[IPSET_CB_INDEX] = 0;
 		goto dump_last;
 	}
 	goto out;
@@ -1350,15 +1354,15 @@ nla_put_failure:
 	ret = -EFAULT;
 next_set:
 	if (dump_type == DUMP_ONE)
-		cb->args[1] = IPSET_INVALID_ID;
+		cb->args[IPSET_CB_INDEX] = IPSET_INVALID_ID;
 	else
-		cb->args[1]++;
+		cb->args[IPSET_CB_INDEX]++;
 release_refcount:
 	/* If there was an error or set is done, release set */
-	if (ret || !cb->args[2]) {
+	if (ret || !cb->args[IPSET_CB_ARG0]) {
 		pr_debug("release set %s\n", nfnl_set(inst, index)->name);
 		__ip_set_put_byindex(inst, index);
-		cb->args[2] = 0;
+		cb->args[IPSET_CB_ARG0] = 0;
 	}
 out:
 	if (nlh) {
@@ -1375,8 +1379,6 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 	    const struct nlmsghdr *nlh,
 	    const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
-
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
 
@@ -1384,7 +1386,6 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 		struct netlink_dump_control c = {
 			.dump = ip_set_dump_start,
 			.done = ip_set_dump_done,
-			.data = (void *)inst
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
@@ -1961,7 +1962,6 @@ static int __net_init
 ip_set_net_init(struct net *net)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
-
 	struct ip_set **list;
 
 	inst->ip_set_max = max_sets ? max_sets : CONFIG_IP_SET_MAX;
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 6a80dbd..2f80c74 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -931,7 +931,7 @@ mtype_list(const struct ip_set *set,
 	struct nlattr *atd, *nested;
 	const struct hbucket *n;
 	const struct mtype_elem *e;
-	u32 first = cb->args[2];
+	u32 first = cb->args[IPSET_CB_ARG0];
 	/* We assume that one hash bucket fills into one page */
 	void *incomplete;
 	int i;
@@ -940,20 +940,22 @@ mtype_list(const struct ip_set *set,
 	if (!atd)
 		return -EMSGSIZE;
 	pr_debug("list hash set %s\n", set->name);
-	for (; cb->args[2] < jhash_size(t->htable_bits); cb->args[2]++) {
+	for (; cb->args[IPSET_CB_ARG0] < jhash_size(t->htable_bits);
+	     cb->args[IPSET_CB_ARG0]++) {
 		incomplete = skb_tail_pointer(skb);
-		n = hbucket(t, cb->args[2]);
-		pr_debug("cb->args[2]: %lu, t %p n %p\n", cb->args[2], t, n);
+		n = hbucket(t, cb->args[IPSET_CB_ARG0]);
+		pr_debug("cb->arg bucket: %lu, t %p n %p\n",
+			 cb->args[IPSET_CB_ARG0], t, n);
 		for (i = 0; i < n->pos; i++) {
 			e = ahash_data(n, i, set->dsize);
 			if (SET_WITH_TIMEOUT(set) &&
 			    ip_set_timeout_expired(ext_timeout(e, set)))
 				continue;
 			pr_debug("list hash %lu hbucket %p i %u, data %p\n",
-				 cb->args[2], n, i, e);
+				 cb->args[IPSET_CB_ARG0], n, i, e);
 			nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 			if (!nested) {
-				if (cb->args[2] == first) {
+				if (cb->args[IPSET_CB_ARG0] == first) {
 					nla_nest_cancel(skb, atd);
 					return -EMSGSIZE;
 				} else
@@ -968,16 +970,16 @@ mtype_list(const struct ip_set *set,
 	}
 	ipset_nest_end(skb, atd);
 	/* Set listing finished */
-	cb->args[2] = 0;
+	cb->args[IPSET_CB_ARG0] = 0;
 
 	return 0;
 
 nla_put_failure:
 	nlmsg_trim(skb, incomplete);
-	if (unlikely(first == cb->args[2])) {
+	if (unlikely(first == cb->args[IPSET_CB_ARG0])) {
 		pr_warning("Can't list set %s: one bucket does not fit into "
 			   "a message. Please report it!\n", set->name);
-		cb->args[2] = 0;
+		cb->args[IPSET_CB_ARG0] = 0;
 		return -EMSGSIZE;
 	}
 	ipset_nest_end(skb, atd);
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index ec6f6d1..3e2317f 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -490,14 +490,15 @@ list_set_list(const struct ip_set *set,
 {
 	const struct list_set *map = set->data;
 	struct nlattr *atd, *nested;
-	u32 i, first = cb->args[2];
+	u32 i, first = cb->args[IPSET_CB_ARG0];
 	const struct set_elem *e;
 
 	atd = ipset_nest_start(skb, IPSET_ATTR_ADT);
 	if (!atd)
 		return -EMSGSIZE;
-	for (; cb->args[2] < map->size; cb->args[2]++) {
-		i = cb->args[2];
+	for (; cb->args[IPSET_CB_ARG0] < map->size;
+	     cb->args[IPSET_CB_ARG0]++) {
+		i = cb->args[IPSET_CB_ARG0];
 		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			goto finish;
@@ -522,13 +523,13 @@ list_set_list(const struct ip_set *set,
 finish:
 	ipset_nest_end(skb, atd);
 	/* Set listing finished */
-	cb->args[2] = 0;
+	cb->args[IPSET_CB_ARG0] = 0;
 	return 0;
 
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
 	if (unlikely(i == first)) {
-		cb->args[2] = 0;
+		cb->args[IPSET_CB_ARG0] = 0;
 		return -EMSGSIZE;
 	}
 	ipset_nest_end(skb, atd);
-- 
1.7.10.4
