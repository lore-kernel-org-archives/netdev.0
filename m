From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/33] netfiler: ipset: Add net namespace for ipset
Date: Fri,  4 Oct 2013 10:33:13 +0200
Message-ID: <1380875598-5250-29-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55725 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753436Ab3JDIeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:22 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaly Lavrov <lve@guap.ru>

This patch adds netns support for ipset.

Major changes were made in ip_set_core.c and ip_set.h.
Global variables are moved to per net namespace.
Added initialization code and the destruction of the network namespace ipset subsystem.
In the prototypes of public functions ip_set_* added parameter "struct net*".

The remaining corrections related to the change prototypes of public functions ip_set_*.

The patch for git://git.netfilter.org/ipset.git commit 6a4ec96c0b8caac5c35474e40e319704d92ca347

Signed-off-by: Vitaly Lavrov <lve@guap.ru>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h    |   16 +-
 net/netfilter/ipset/ip_set_bitmap_ip.c    |    3 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |    2 +-
 net/netfilter/ipset/ip_set_bitmap_port.c  |    3 +-
 net/netfilter/ipset/ip_set_core.c         |  288 +++++++++++++++++++----------
 net/netfilter/ipset/ip_set_hash_gen.h     |    3 +-
 net/netfilter/ipset/ip_set_list_set.c     |   31 ++--
 net/netfilter/xt_set.c                    |   40 ++--
 net/sched/em_ipset.c                      |    7 +-
 9 files changed, 245 insertions(+), 148 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index da2a45a..7967516 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -184,7 +184,8 @@ struct ip_set_type {
 	u8 revision_min, revision_max;
 
 	/* Create set */
-	int (*create)(struct ip_set *set, struct nlattr *tb[], u32 flags);
+	int (*create)(struct net *net, struct ip_set *set,
+		      struct nlattr *tb[], u32 flags);
 
 	/* Attribute policies */
 	const struct nla_policy create_policy[IPSET_ATTR_CREATE_MAX + 1];
@@ -316,12 +317,13 @@ ip_set_init_counter(struct ip_set_counter *counter,
 }
 
 /* register and unregister set references */
-extern ip_set_id_t ip_set_get_byname(const char *name, struct ip_set **set);
-extern void ip_set_put_byindex(ip_set_id_t index);
-extern const char *ip_set_name_byindex(ip_set_id_t index);
-extern ip_set_id_t ip_set_nfnl_get(const char *name);
-extern ip_set_id_t ip_set_nfnl_get_byindex(ip_set_id_t index);
-extern void ip_set_nfnl_put(ip_set_id_t index);
+extern ip_set_id_t ip_set_get_byname(struct net *net,
+				     const char *name, struct ip_set **set);
+extern void ip_set_put_byindex(struct net *net, ip_set_id_t index);
+extern const char *ip_set_name_byindex(struct net *net, ip_set_id_t index);
+extern ip_set_id_t ip_set_nfnl_get(struct net *net, const char *name);
+extern ip_set_id_t ip_set_nfnl_get_byindex(struct net *net, ip_set_id_t index);
+extern void ip_set_nfnl_put(struct net *net, ip_set_id_t index);
 
 /* API for iptables set match, and SET target */
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index faac124..6f1f9f4 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -242,7 +242,8 @@ init_map_ip(struct ip_set *set, struct bitmap_ip *map,
 }
 
 static int
-bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
+bitmap_ip_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
+		 u32 flags)
 {
 	struct bitmap_ip *map;
 	u32 first_ip = 0, last_ip = 0, hosts;
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 87a218f..740eabe 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -309,7 +309,7 @@ init_map_ipmac(struct ip_set *set, struct bitmap_ipmac *map,
 }
 
 static int
-bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
+bitmap_ipmac_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
 		    u32 flags)
 {
 	u32 first_ip = 0, last_ip = 0;
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 407a63c..e7603c5 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -228,7 +228,8 @@ init_map_port(struct ip_set *set, struct bitmap_port *map,
 }
 
 static int
-bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
+bitmap_port_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
+		   u32 flags)
 {
 	struct bitmap_port *map;
 	u16 first_port, last_port;
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 3bf9a3d..dc9284b 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -17,6 +17,8 @@
 #include <linux/spinlock.h>
 #include <linux/rculist.h>
 #include <net/netlink.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #include <linux/netfilter.h>
 #include <linux/netfilter/x_tables.h>
@@ -27,8 +29,17 @@ static LIST_HEAD(ip_set_type_list);		/* all registered set types */
 static DEFINE_MUTEX(ip_set_type_mutex);		/* protects ip_set_type_list */
 static DEFINE_RWLOCK(ip_set_ref_lock);		/* protects the set refs */
 
-static struct ip_set * __rcu *ip_set_list;	/* all individual sets */
-static ip_set_id_t ip_set_max = CONFIG_IP_SET_MAX; /* max number of sets */
+struct ip_set_net {
+	struct ip_set * __rcu *ip_set_list;	/* all individual sets */
+	ip_set_id_t	ip_set_max;	/* max number of sets */
+	int		is_deleted;	/* deleted by ip_set_net_exit */
+};
+static int ip_set_net_id __read_mostly;
+
+static inline struct ip_set_net *ip_set_pernet(struct net *net)
+{
+	return net_generic(net, ip_set_net_id);
+}
 
 #define IP_SET_INC	64
 #define STREQ(a, b)	(strncmp(a, b, IPSET_MAXNAMELEN) == 0)
@@ -45,8 +56,8 @@ MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_IPSET);
 /* When the nfnl mutex is held: */
 #define nfnl_dereference(p)		\
 	rcu_dereference_protected(p, 1)
-#define nfnl_set(id)			\
-	nfnl_dereference(ip_set_list)[id]
+#define nfnl_set(inst, id)			\
+	nfnl_dereference((inst)->ip_set_list)[id]
 
 /*
  * The set types are implemented in modules and registered set types
@@ -434,13 +445,14 @@ __ip_set_put(struct ip_set *set)
  */
 
 static inline struct ip_set *
-ip_set_rcu_get(ip_set_id_t index)
+ip_set_rcu_get(struct net *net, ip_set_id_t index)
 {
 	struct ip_set *set;
+	struct ip_set_net *inst = ip_set_pernet(net);
 
 	rcu_read_lock();
 	/* ip_set_list itself needs to be protected */
-	set = rcu_dereference(ip_set_list)[index];
+	set = rcu_dereference(inst->ip_set_list)[index];
 	rcu_read_unlock();
 
 	return set;
@@ -450,7 +462,8 @@ int
 ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	    const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(index);
+	struct ip_set *set = ip_set_rcu_get(
+			dev_net(par->in ? par->in : par->out), index);
 	int ret = 0;
 
 	BUG_ON(set == NULL);
@@ -488,7 +501,8 @@ int
 ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(index);
+	struct ip_set *set = ip_set_rcu_get(
+			dev_net(par->in ? par->in : par->out), index);
 	int ret;
 
 	BUG_ON(set == NULL);
@@ -510,7 +524,8 @@ int
 ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(index);
+	struct ip_set *set = ip_set_rcu_get(
+			dev_net(par->in ? par->in : par->out), index);
 	int ret = 0;
 
 	BUG_ON(set == NULL);
@@ -534,14 +549,15 @@ EXPORT_SYMBOL_GPL(ip_set_del);
  *
  */
 ip_set_id_t
-ip_set_get_byname(const char *name, struct ip_set **set)
+ip_set_get_byname(struct net *net, const char *name, struct ip_set **set)
 {
 	ip_set_id_t i, index = IPSET_INVALID_ID;
 	struct ip_set *s;
+	struct ip_set_net *inst = ip_set_pernet(net);
 
 	rcu_read_lock();
-	for (i = 0; i < ip_set_max; i++) {
-		s = rcu_dereference(ip_set_list)[i];
+	for (i = 0; i < inst->ip_set_max; i++) {
+		s = rcu_dereference(inst->ip_set_list)[i];
 		if (s != NULL && STREQ(s->name, name)) {
 			__ip_set_get(s);
 			index = i;
@@ -561,17 +577,26 @@ EXPORT_SYMBOL_GPL(ip_set_get_byname);
  * to be valid, after calling this function.
  *
  */
-void
-ip_set_put_byindex(ip_set_id_t index)
+
+static inline void
+__ip_set_put_byindex(struct ip_set_net *inst, ip_set_id_t index)
 {
 	struct ip_set *set;
 
 	rcu_read_lock();
-	set = rcu_dereference(ip_set_list)[index];
+	set = rcu_dereference(inst->ip_set_list)[index];
 	if (set != NULL)
 		__ip_set_put(set);
 	rcu_read_unlock();
 }
+
+void
+ip_set_put_byindex(struct net *net, ip_set_id_t index)
+{
+	struct ip_set_net *inst = ip_set_pernet(net);
+
+	__ip_set_put_byindex(inst, index);
+}
 EXPORT_SYMBOL_GPL(ip_set_put_byindex);
 
 /*
@@ -582,9 +607,9 @@ EXPORT_SYMBOL_GPL(ip_set_put_byindex);
  *
  */
 const char *
-ip_set_name_byindex(ip_set_id_t index)
+ip_set_name_byindex(struct net *net, ip_set_id_t index)
 {
-	const struct ip_set *set = ip_set_rcu_get(index);
+	const struct ip_set *set = ip_set_rcu_get(net, index);
 
 	BUG_ON(set == NULL);
 	BUG_ON(set->ref == 0);
@@ -606,14 +631,15 @@ EXPORT_SYMBOL_GPL(ip_set_name_byindex);
  * The nfnl mutex is used in the function.
  */
 ip_set_id_t
-ip_set_nfnl_get(const char *name)
+ip_set_nfnl_get(struct net *net, const char *name)
 {
 	ip_set_id_t i, index = IPSET_INVALID_ID;
 	struct ip_set *s;
+	struct ip_set_net *inst = ip_set_pernet(net);
 
 	nfnl_lock(NFNL_SUBSYS_IPSET);
-	for (i = 0; i < ip_set_max; i++) {
-		s = nfnl_set(i);
+	for (i = 0; i < inst->ip_set_max; i++) {
+		s = nfnl_set(inst, i);
 		if (s != NULL && STREQ(s->name, name)) {
 			__ip_set_get(s);
 			index = i;
@@ -633,15 +659,16 @@ EXPORT_SYMBOL_GPL(ip_set_nfnl_get);
  * The nfnl mutex is used in the function.
  */
 ip_set_id_t
-ip_set_nfnl_get_byindex(ip_set_id_t index)
+ip_set_nfnl_get_byindex(struct net *net, ip_set_id_t index)
 {
 	struct ip_set *set;
+	struct ip_set_net *inst = ip_set_pernet(net);
 
-	if (index > ip_set_max)
+	if (index > inst->ip_set_max)
 		return IPSET_INVALID_ID;
 
 	nfnl_lock(NFNL_SUBSYS_IPSET);
-	set = nfnl_set(index);
+	set = nfnl_set(inst, index);
 	if (set)
 		__ip_set_get(set);
 	else
@@ -660,13 +687,17 @@ EXPORT_SYMBOL_GPL(ip_set_nfnl_get_byindex);
  * The nfnl mutex is used in the function.
  */
 void
-ip_set_nfnl_put(ip_set_id_t index)
+ip_set_nfnl_put(struct net *net, ip_set_id_t index)
 {
 	struct ip_set *set;
+	struct ip_set_net *inst = ip_set_pernet(net);
+
 	nfnl_lock(NFNL_SUBSYS_IPSET);
-	set = nfnl_set(index);
-	if (set != NULL)
-		__ip_set_put(set);
+	if (!inst->is_deleted) { /* already deleted from ip_set_net_exit() */
+		set = nfnl_set(inst, index);
+		if (set != NULL)
+			__ip_set_put(set);
+	}
 	nfnl_unlock(NFNL_SUBSYS_IPSET);
 }
 EXPORT_SYMBOL_GPL(ip_set_nfnl_put);
@@ -724,14 +755,14 @@ static const struct nla_policy ip_set_create_policy[IPSET_ATTR_CMD_MAX + 1] = {
 };
 
 static struct ip_set *
-find_set_and_id(const char *name, ip_set_id_t *id)
+find_set_and_id(struct ip_set_net *inst, const char *name, ip_set_id_t *id)
 {
 	struct ip_set *set = NULL;
 	ip_set_id_t i;
 
 	*id = IPSET_INVALID_ID;
-	for (i = 0; i < ip_set_max; i++) {
-		set = nfnl_set(i);
+	for (i = 0; i < inst->ip_set_max; i++) {
+		set = nfnl_set(inst, i);
 		if (set != NULL && STREQ(set->name, name)) {
 			*id = i;
 			break;
@@ -741,22 +772,23 @@ find_set_and_id(const char *name, ip_set_id_t *id)
 }
 
 static inline struct ip_set *
-find_set(const char *name)
+find_set(struct ip_set_net *inst, const char *name)
 {
 	ip_set_id_t id;
 
-	return find_set_and_id(name, &id);
+	return find_set_and_id(inst, name, &id);
 }
 
 static int
-find_free_id(const char *name, ip_set_id_t *index, struct ip_set **set)
+find_free_id(struct ip_set_net *inst, const char *name, ip_set_id_t *index,
+	     struct ip_set **set)
 {
 	struct ip_set *s;
 	ip_set_id_t i;
 
 	*index = IPSET_INVALID_ID;
-	for (i = 0;  i < ip_set_max; i++) {
-		s = nfnl_set(i);
+	for (i = 0;  i < inst->ip_set_max; i++) {
+		s = nfnl_set(inst, i);
 		if (s == NULL) {
 			if (*index == IPSET_INVALID_ID)
 				*index = i;
@@ -785,6 +817,8 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	      const struct nlmsghdr *nlh,
 	      const struct nlattr * const attr[])
 {
+	struct net *net = sock_net(ctnl);
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set, *clash = NULL;
 	ip_set_id_t index = IPSET_INVALID_ID;
 	struct nlattr *tb[IPSET_ATTR_CREATE_MAX+1] = {};
@@ -843,7 +877,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 		goto put_out;
 	}
 
-	ret = set->type->create(set, tb, flags);
+	ret = set->type->create(net, set, tb, flags);
 	if (ret != 0)
 		goto put_out;
 
@@ -854,7 +888,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	 * by the nfnl mutex. Find the first free index in ip_set_list
 	 * and check clashing.
 	 */
-	ret = find_free_id(set->name, &index, &clash);
+	ret = find_free_id(inst, set->name, &index, &clash);
 	if (ret == -EEXIST) {
 		/* If this is the same set and requested, ignore error */
 		if ((flags & IPSET_FLAG_EXIST) &&
@@ -867,9 +901,9 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 		goto cleanup;
 	} else if (ret == -IPSET_ERR_MAX_SETS) {
 		struct ip_set **list, **tmp;
-		ip_set_id_t i = ip_set_max + IP_SET_INC;
+		ip_set_id_t i = inst->ip_set_max + IP_SET_INC;
 
-		if (i < ip_set_max || i == IPSET_INVALID_ID)
+		if (i < inst->ip_set_max || i == IPSET_INVALID_ID)
 			/* Wraparound */
 			goto cleanup;
 
@@ -877,14 +911,14 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 		if (!list)
 			goto cleanup;
 		/* nfnl mutex is held, both lists are valid */
-		tmp = nfnl_dereference(ip_set_list);
-		memcpy(list, tmp, sizeof(struct ip_set *) * ip_set_max);
-		rcu_assign_pointer(ip_set_list, list);
+		tmp = nfnl_dereference(inst->ip_set_list);
+		memcpy(list, tmp, sizeof(struct ip_set *) * inst->ip_set_max);
+		rcu_assign_pointer(inst->ip_set_list, list);
 		/* Make sure all current packets have passed through */
 		synchronize_net();
 		/* Use new list */
-		index = ip_set_max;
-		ip_set_max = i;
+		index = inst->ip_set_max;
+		inst->ip_set_max = i;
 		kfree(tmp);
 		ret = 0;
 	} else if (ret)
@@ -894,7 +928,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	 * Finally! Add our shiny new set to the list, and be done.
 	 */
 	pr_debug("create: '%s' created with index %u!\n", set->name, index);
-	nfnl_set(index) = set;
+	nfnl_set(inst, index) = set;
 
 	return ret;
 
@@ -917,12 +951,12 @@ ip_set_setname_policy[IPSET_ATTR_CMD_MAX + 1] = {
 };
 
 static void
-ip_set_destroy_set(ip_set_id_t index)
+ip_set_destroy_set(struct ip_set_net *inst, ip_set_id_t index)
 {
-	struct ip_set *set = nfnl_set(index);
+	struct ip_set *set = nfnl_set(inst, index);
 
 	pr_debug("set: %s\n",  set->name);
-	nfnl_set(index) = NULL;
+	nfnl_set(inst, index) = NULL;
 
 	/* Must call it without holding any lock */
 	set->variant->destroy(set);
@@ -935,6 +969,7 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 	       const struct nlmsghdr *nlh,
 	       const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	struct ip_set *s;
 	ip_set_id_t i;
 	int ret = 0;
@@ -954,21 +989,22 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 	 */
 	read_lock_bh(&ip_set_ref_lock);
 	if (!attr[IPSET_ATTR_SETNAME]) {
-		for (i = 0; i < ip_set_max; i++) {
-			s = nfnl_set(i);
+		for (i = 0; i < inst->ip_set_max; i++) {
+			s = nfnl_set(inst, i);
 			if (s != NULL && s->ref) {
 				ret = -IPSET_ERR_BUSY;
 				goto out;
 			}
 		}
 		read_unlock_bh(&ip_set_ref_lock);
-		for (i = 0; i < ip_set_max; i++) {
-			s = nfnl_set(i);
+		for (i = 0; i < inst->ip_set_max; i++) {
+			s = nfnl_set(inst, i);
 			if (s != NULL)
-				ip_set_destroy_set(i);
+				ip_set_destroy_set(inst, i);
 		}
 	} else {
-		s = find_set_and_id(nla_data(attr[IPSET_ATTR_SETNAME]), &i);
+		s = find_set_and_id(inst, nla_data(attr[IPSET_ATTR_SETNAME]),
+				    &i);
 		if (s == NULL) {
 			ret = -ENOENT;
 			goto out;
@@ -978,7 +1014,7 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 		}
 		read_unlock_bh(&ip_set_ref_lock);
 
-		ip_set_destroy_set(i);
+		ip_set_destroy_set(inst, i);
 	}
 	return 0;
 out:
@@ -1003,6 +1039,7 @@ ip_set_flush(struct sock *ctnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh,
 	     const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	struct ip_set *s;
 	ip_set_id_t i;
 
@@ -1010,13 +1047,13 @@ ip_set_flush(struct sock *ctnl, struct sk_buff *skb,
 		return -IPSET_ERR_PROTOCOL;
 
 	if (!attr[IPSET_ATTR_SETNAME]) {
-		for (i = 0; i < ip_set_max; i++) {
-			s = nfnl_set(i);
+		for (i = 0; i < inst->ip_set_max; i++) {
+			s = nfnl_set(inst, i);
 			if (s != NULL)
 				ip_set_flush_set(s);
 		}
 	} else {
-		s = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+		s = find_set(inst, nla_data(attr[IPSET_ATTR_SETNAME]));
 		if (s == NULL)
 			return -ENOENT;
 
@@ -1042,6 +1079,7 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 	      const struct nlmsghdr *nlh,
 	      const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	struct ip_set *set, *s;
 	const char *name2;
 	ip_set_id_t i;
@@ -1052,7 +1090,7 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 		     attr[IPSET_ATTR_SETNAME2] == NULL))
 		return -IPSET_ERR_PROTOCOL;
 
-	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	set = find_set(inst, nla_data(attr[IPSET_ATTR_SETNAME]));
 	if (set == NULL)
 		return -ENOENT;
 
@@ -1063,8 +1101,8 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	name2 = nla_data(attr[IPSET_ATTR_SETNAME2]);
-	for (i = 0; i < ip_set_max; i++) {
-		s = nfnl_set(i);
+	for (i = 0; i < inst->ip_set_max; i++) {
+		s = nfnl_set(inst, i);
 		if (s != NULL && STREQ(s->name, name2)) {
 			ret = -IPSET_ERR_EXIST_SETNAME2;
 			goto out;
@@ -1091,6 +1129,7 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 	    const struct nlmsghdr *nlh,
 	    const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	struct ip_set *from, *to;
 	ip_set_id_t from_id, to_id;
 	char from_name[IPSET_MAXNAMELEN];
@@ -1100,11 +1139,13 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 		     attr[IPSET_ATTR_SETNAME2] == NULL))
 		return -IPSET_ERR_PROTOCOL;
 
-	from = find_set_and_id(nla_data(attr[IPSET_ATTR_SETNAME]), &from_id);
+	from = find_set_and_id(inst, nla_data(attr[IPSET_ATTR_SETNAME]),
+			       &from_id);
 	if (from == NULL)
 		return -ENOENT;
 
-	to = find_set_and_id(nla_data(attr[IPSET_ATTR_SETNAME2]), &to_id);
+	to = find_set_and_id(inst, nla_data(attr[IPSET_ATTR_SETNAME2]),
+			     &to_id);
 	if (to == NULL)
 		return -IPSET_ERR_EXIST_SETNAME2;
 
@@ -1121,8 +1162,8 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 
 	write_lock_bh(&ip_set_ref_lock);
 	swap(from->ref, to->ref);
-	nfnl_set(from_id) = to;
-	nfnl_set(to_id) = from;
+	nfnl_set(inst, from_id) = to;
+	nfnl_set(inst, to_id) = from;
 	write_unlock_bh(&ip_set_ref_lock);
 
 	return 0;
@@ -1141,9 +1182,10 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 static int
 ip_set_dump_done(struct netlink_callback *cb)
 {
+	struct ip_set_net *inst = (struct ip_set_net *)cb->data;
 	if (cb->args[2]) {
-		pr_debug("release set %s\n", nfnl_set(cb->args[1])->name);
-		ip_set_put_byindex((ip_set_id_t) cb->args[1]);
+		pr_debug("release set %s\n", nfnl_set(inst, cb->args[1])->name);
+		__ip_set_put_byindex(inst, (ip_set_id_t) cb->args[1]);
 	}
 	return 0;
 }
@@ -1169,6 +1211,7 @@ dump_init(struct netlink_callback *cb)
 	struct nlattr *attr = (void *)nlh + min_len;
 	u32 dump_type;
 	ip_set_id_t index;
+	struct ip_set_net *inst = (struct ip_set_net *)cb->data;
 
 	/* Second pass, so parser can't fail */
 	nla_parse(cda, IPSET_ATTR_CMD_MAX,
@@ -1182,7 +1225,7 @@ dump_init(struct netlink_callback *cb)
 	if (cda[IPSET_ATTR_SETNAME]) {
 		struct ip_set *set;
 
-		set = find_set_and_id(nla_data(cda[IPSET_ATTR_SETNAME]),
+		set = find_set_and_id(inst, nla_data(cda[IPSET_ATTR_SETNAME]),
 				      &index);
 		if (set == NULL)
 			return -ENOENT;
@@ -1210,6 +1253,7 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 	unsigned int flags = NETLINK_CB(cb->skb).portid ? NLM_F_MULTI : 0;
 	u32 dump_type, dump_flags;
 	int ret = 0;
+	struct ip_set_net *inst = (struct ip_set_net *)cb->data;
 
 	if (!cb->args[0]) {
 		ret = dump_init(cb);
@@ -1223,18 +1267,18 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 		}
 	}
 
-	if (cb->args[1] >= ip_set_max)
+	if (cb->args[1] >= inst->ip_set_max)
 		goto out;
 
 	dump_type = DUMP_TYPE(cb->args[0]);
 	dump_flags = DUMP_FLAGS(cb->args[0]);
-	max = dump_type == DUMP_ONE ? cb->args[1] + 1 : ip_set_max;
+	max = dump_type == DUMP_ONE ? cb->args[1] + 1 : inst->ip_set_max;
 dump_last:
 	pr_debug("args[0]: %u %u args[1]: %ld\n",
 		 dump_type, dump_flags, cb->args[1]);
 	for (; cb->args[1] < max; cb->args[1]++) {
 		index = (ip_set_id_t) cb->args[1];
-		set = nfnl_set(index);
+		set = nfnl_set(inst, index);
 		if (set == NULL) {
 			if (dump_type == DUMP_ONE) {
 				ret = -ENOENT;
@@ -1312,8 +1356,8 @@ next_set:
 release_refcount:
 	/* If there was an error or set is done, release set */
 	if (ret || !cb->args[2]) {
-		pr_debug("release set %s\n", nfnl_set(index)->name);
-		ip_set_put_byindex(index);
+		pr_debug("release set %s\n", nfnl_set(inst, index)->name);
+		__ip_set_put_byindex(inst, index);
 		cb->args[2] = 0;
 	}
 out:
@@ -1331,6 +1375,8 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 	    const struct nlmsghdr *nlh,
 	    const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
 
@@ -1338,6 +1384,7 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 		struct netlink_dump_control c = {
 			.dump = ip_set_dump_start,
 			.done = ip_set_dump_done,
+			.data = (void *)inst
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
@@ -1416,6 +1463,7 @@ ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
 	    const struct nlmsghdr *nlh,
 	    const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	struct ip_set *set;
 	struct nlattr *tb[IPSET_ATTR_ADT_MAX+1] = {};
 	const struct nlattr *nla;
@@ -1434,7 +1482,7 @@ ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
 		       attr[IPSET_ATTR_LINENO] == NULL))))
 		return -IPSET_ERR_PROTOCOL;
 
-	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	set = find_set(inst, nla_data(attr[IPSET_ATTR_SETNAME]));
 	if (set == NULL)
 		return -ENOENT;
 
@@ -1470,6 +1518,7 @@ ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
 	    const struct nlmsghdr *nlh,
 	    const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	struct ip_set *set;
 	struct nlattr *tb[IPSET_ATTR_ADT_MAX+1] = {};
 	const struct nlattr *nla;
@@ -1488,7 +1537,7 @@ ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
 		       attr[IPSET_ATTR_LINENO] == NULL))))
 		return -IPSET_ERR_PROTOCOL;
 
-	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	set = find_set(inst, nla_data(attr[IPSET_ATTR_SETNAME]));
 	if (set == NULL)
 		return -ENOENT;
 
@@ -1524,6 +1573,7 @@ ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh,
 	     const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	struct ip_set *set;
 	struct nlattr *tb[IPSET_ATTR_ADT_MAX+1] = {};
 	int ret = 0;
@@ -1534,7 +1584,7 @@ ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
 		     !flag_nested(attr[IPSET_ATTR_DATA])))
 		return -IPSET_ERR_PROTOCOL;
 
-	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	set = find_set(inst, nla_data(attr[IPSET_ATTR_SETNAME]));
 	if (set == NULL)
 		return -ENOENT;
 
@@ -1559,6 +1609,7 @@ ip_set_header(struct sock *ctnl, struct sk_buff *skb,
 	      const struct nlmsghdr *nlh,
 	      const struct nlattr * const attr[])
 {
+	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
 	const struct ip_set *set;
 	struct sk_buff *skb2;
 	struct nlmsghdr *nlh2;
@@ -1568,7 +1619,7 @@ ip_set_header(struct sock *ctnl, struct sk_buff *skb,
 		     attr[IPSET_ATTR_SETNAME] == NULL))
 		return -IPSET_ERR_PROTOCOL;
 
-	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
+	set = find_set(inst, nla_data(attr[IPSET_ATTR_SETNAME]));
 	if (set == NULL)
 		return -ENOENT;
 
@@ -1793,8 +1844,10 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 	unsigned int *op;
 	void *data;
 	int copylen = *len, ret = 0;
+	struct net *net = sock_net(sk);
+	struct ip_set_net *inst = ip_set_pernet(net);
 
-	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (optval != SO_IP_SET)
 		return -EBADF;
@@ -1843,7 +1896,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		}
 		req_get->set.name[IPSET_MAXNAMELEN - 1] = '\0';
 		nfnl_lock(NFNL_SUBSYS_IPSET);
-		find_set_and_id(req_get->set.name, &id);
+		find_set_and_id(inst, req_get->set.name, &id);
 		req_get->set.index = id;
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
@@ -1858,10 +1911,10 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		}
 		req_get->set.name[IPSET_MAXNAMELEN - 1] = '\0';
 		nfnl_lock(NFNL_SUBSYS_IPSET);
-		find_set_and_id(req_get->set.name, &id);
+		find_set_and_id(inst, req_get->set.name, &id);
 		req_get->set.index = id;
 		if (id != IPSET_INVALID_ID)
-			req_get->family = nfnl_set(id)->family;
+			req_get->family = nfnl_set(inst, id)->family;
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
 		goto copy;
 	}
@@ -1870,12 +1923,12 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		struct ip_set *set;
 
 		if (*len != sizeof(struct ip_set_req_get_set) ||
-		    req_get->set.index >= ip_set_max) {
+		    req_get->set.index >= inst->ip_set_max) {
 			ret = -EINVAL;
 			goto done;
 		}
 		nfnl_lock(NFNL_SUBSYS_IPSET);
-		set = nfnl_set(req_get->set.index);
+		set = nfnl_set(inst, req_get->set.index);
 		strncpy(req_get->set.name, set ? set->name : "",
 			IPSET_MAXNAMELEN);
 		nfnl_unlock(NFNL_SUBSYS_IPSET);
@@ -1904,49 +1957,82 @@ static struct nf_sockopt_ops so_set __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
-static int __init
-ip_set_init(void)
+static int __net_init
+ip_set_net_init(struct net *net)
 {
+	struct ip_set_net *inst = ip_set_pernet(net);
+
 	struct ip_set **list;
-	int ret;
 
-	if (max_sets)
-		ip_set_max = max_sets;
-	if (ip_set_max >= IPSET_INVALID_ID)
-		ip_set_max = IPSET_INVALID_ID - 1;
+	inst->ip_set_max = max_sets ? max_sets : CONFIG_IP_SET_MAX;
+	if (inst->ip_set_max >= IPSET_INVALID_ID)
+		inst->ip_set_max = IPSET_INVALID_ID - 1;
 
-	list = kzalloc(sizeof(struct ip_set *) * ip_set_max, GFP_KERNEL);
+	list = kzalloc(sizeof(struct ip_set *) * inst->ip_set_max, GFP_KERNEL);
 	if (!list)
 		return -ENOMEM;
+	inst->is_deleted = 0;
+	rcu_assign_pointer(inst->ip_set_list, list);
+	pr_notice("ip_set: protocol %u\n", IPSET_PROTOCOL);
+	return 0;
+}
+
+static void __net_exit
+ip_set_net_exit(struct net *net)
+{
+	struct ip_set_net *inst = ip_set_pernet(net);
+
+	struct ip_set *set = NULL;
+	ip_set_id_t i;
+
+	inst->is_deleted = 1; /* flag for ip_set_nfnl_put */
+
+	for (i = 0; i < inst->ip_set_max; i++) {
+		set = nfnl_set(inst, i);
+		if (set != NULL)
+			ip_set_destroy_set(inst, i);
+	}
+	kfree(rcu_dereference_protected(inst->ip_set_list, 1));
+}
+
+static struct pernet_operations ip_set_net_ops = {
+	.init	= ip_set_net_init,
+	.exit   = ip_set_net_exit,
+	.id	= &ip_set_net_id,
+	.size	= sizeof(struct ip_set_net)
+};
+
 
-	rcu_assign_pointer(ip_set_list, list);
-	ret = nfnetlink_subsys_register(&ip_set_netlink_subsys);
+static int __init
+ip_set_init(void)
+{
+	int ret = nfnetlink_subsys_register(&ip_set_netlink_subsys);
 	if (ret != 0) {
 		pr_err("ip_set: cannot register with nfnetlink.\n");
-		kfree(list);
 		return ret;
 	}
 	ret = nf_register_sockopt(&so_set);
 	if (ret != 0) {
 		pr_err("SO_SET registry failed: %d\n", ret);
 		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
-		kfree(list);
 		return ret;
 	}
-
-	pr_notice("ip_set: protocol %u\n", IPSET_PROTOCOL);
+	ret = register_pernet_subsys(&ip_set_net_ops);
+	if (ret) {
+		pr_err("ip_set: cannot register pernet_subsys.\n");
+		nf_unregister_sockopt(&so_set);
+		nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
+		return ret;
+	}
 	return 0;
 }
 
 static void __exit
 ip_set_fini(void)
 {
-	struct ip_set **list = rcu_dereference_protected(ip_set_list, 1);
-
-	/* There can't be any existing set */
+	unregister_pernet_subsys(&ip_set_net_ops);
 	nf_unregister_sockopt(&so_set);
 	nfnetlink_subsys_unregister(&ip_set_netlink_subsys);
-	kfree(list);
 	pr_debug("these are the famous last words\n");
 }
 
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index b4add20..6a80dbd 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1011,7 +1011,8 @@ static const struct ip_set_type_variant mtype_variant = {
 
 #ifdef IP_SET_EMIT_CREATE
 static int
-IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
+IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
+			    struct nlattr *tb[], u32 flags)
 {
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index ba4232e..ec6f6d1 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -39,6 +39,7 @@ struct set_adt_elem {
 struct list_set {
 	u32 size;		/* size of set list array */
 	struct timer_list gc;	/* garbage collection */
+	struct net *net;	/* namespace */
 	struct set_elem members[0]; /* the set members */
 };
 
@@ -171,7 +172,7 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 	if (e->id != IPSET_INVALID_ID) {
 		if (i == map->size - 1) {
 			/* Last element replaced: e.g. add new,before,last */
-			ip_set_put_byindex(e->id);
+			ip_set_put_byindex(map->net, e->id);
 			ip_set_ext_destroy(set, e);
 		} else {
 			struct set_elem *x = list_set_elem(set, map,
@@ -179,7 +180,7 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 
 			/* Last element pushed off */
 			if (x->id != IPSET_INVALID_ID) {
-				ip_set_put_byindex(x->id);
+				ip_set_put_byindex(map->net, x->id);
 				ip_set_ext_destroy(set, x);
 			}
 			memmove(list_set_elem(set, map, i + 1), e,
@@ -205,7 +206,7 @@ list_set_del(struct ip_set *set, u32 i)
 	struct list_set *map = set->data;
 	struct set_elem *e = list_set_elem(set, map, i);
 
-	ip_set_put_byindex(e->id);
+	ip_set_put_byindex(map->net, e->id);
 	ip_set_ext_destroy(set, e);
 
 	if (i < map->size - 1)
@@ -307,7 +308,7 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		if (SET_WITH_COMMENT(set))
 			ip_set_init_comment(ext_comment(e, set), ext);
 		/* Set is already added to the list */
-		ip_set_put_byindex(d->id);
+		ip_set_put_byindex(map->net, d->id);
 		return 0;
 	}
 insert:
@@ -366,6 +367,7 @@ static int
 list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
+	struct list_set *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct set_adt_elem e = { .refid = IPSET_INVALID_ID };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
@@ -385,7 +387,7 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
-	e.id = ip_set_get_byname(nla_data(tb[IPSET_ATTR_NAME]), &s);
+	e.id = ip_set_get_byname(map->net, nla_data(tb[IPSET_ATTR_NAME]), &s);
 	if (e.id == IPSET_INVALID_ID)
 		return -IPSET_ERR_NAME;
 	/* "Loop detection" */
@@ -405,7 +407,8 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (tb[IPSET_ATTR_NAMEREF]) {
-		e.refid = ip_set_get_byname(nla_data(tb[IPSET_ATTR_NAMEREF]),
+		e.refid = ip_set_get_byname(map->net,
+					    nla_data(tb[IPSET_ATTR_NAMEREF]),
 					    &s);
 		if (e.refid == IPSET_INVALID_ID) {
 			ret = -IPSET_ERR_NAMEREF;
@@ -421,9 +424,9 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 
 finish:
 	if (e.refid != IPSET_INVALID_ID)
-		ip_set_put_byindex(e.refid);
+		ip_set_put_byindex(map->net, e.refid);
 	if (adt != IPSET_ADD || ret)
-		ip_set_put_byindex(e.id);
+		ip_set_put_byindex(map->net, e.id);
 
 	return ip_set_eexist(ret, flags) ? 0 : ret;
 }
@@ -438,7 +441,7 @@ list_set_flush(struct ip_set *set)
 	for (i = 0; i < map->size; i++) {
 		e = list_set_elem(set, map, i);
 		if (e->id != IPSET_INVALID_ID) {
-			ip_set_put_byindex(e->id);
+			ip_set_put_byindex(map->net, e->id);
 			ip_set_ext_destroy(set, e);
 			e->id = IPSET_INVALID_ID;
 		}
@@ -510,7 +513,7 @@ list_set_list(const struct ip_set *set,
 				goto nla_put_failure;
 		}
 		if (nla_put_string(skb, IPSET_ATTR_NAME,
-				   ip_set_name_byindex(e->id)))
+				   ip_set_name_byindex(map->net, e->id)))
 			goto nla_put_failure;
 		if (ip_set_put_extensions(skb, set, e, true))
 			goto nla_put_failure;
@@ -587,7 +590,7 @@ list_set_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 /* Create list:set type of sets */
 
 static bool
-init_list_set(struct ip_set *set, u32 size)
+init_list_set(struct net *net, struct ip_set *set, u32 size)
 {
 	struct list_set *map;
 	struct set_elem *e;
@@ -598,6 +601,7 @@ init_list_set(struct ip_set *set, u32 size)
 		return false;
 
 	map->size = size;
+	map->net = net;
 	set->data = map;
 
 	for (i = 0; i < size; i++) {
@@ -609,7 +613,8 @@ init_list_set(struct ip_set *set, u32 size)
 }
 
 static int
-list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
+list_set_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
+		u32 flags)
 {
 	u32 size = IP_SET_LIST_DEFAULT_SIZE;
 
@@ -625,7 +630,7 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	set->variant = &set_variant;
 	set->dsize = ip_set_elem_len(set, tb, sizeof(struct set_elem));
-	if (!init_list_set(set, size))
+	if (!init_list_set(net, set, size))
 		return -ENOMEM;
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 2095488..e7c4e0e 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -81,7 +81,7 @@ set_match_v0_checkentry(const struct xt_mtchk_param *par)
 	struct xt_set_info_match_v0 *info = par->matchinfo;
 	ip_set_id_t index;
 
-	index = ip_set_nfnl_get_byindex(info->match_set.index);
+	index = ip_set_nfnl_get_byindex(par->net, info->match_set.index);
 
 	if (index == IPSET_INVALID_ID) {
 		pr_warning("Cannot find set indentified by id %u to match\n",
@@ -91,7 +91,7 @@ set_match_v0_checkentry(const struct xt_mtchk_param *par)
 	if (info->match_set.u.flags[IPSET_DIM_MAX-1] != 0) {
 		pr_warning("Protocol error: set match dimension "
 			   "is over the limit!\n");
-		ip_set_nfnl_put(info->match_set.index);
+		ip_set_nfnl_put(par->net, info->match_set.index);
 		return -ERANGE;
 	}
 
@@ -106,7 +106,7 @@ set_match_v0_destroy(const struct xt_mtdtor_param *par)
 {
 	struct xt_set_info_match_v0 *info = par->matchinfo;
 
-	ip_set_nfnl_put(info->match_set.index);
+	ip_set_nfnl_put(par->net, info->match_set.index);
 }
 
 /* Revision 1 match */
@@ -131,7 +131,7 @@ set_match_v1_checkentry(const struct xt_mtchk_param *par)
 	struct xt_set_info_match_v1 *info = par->matchinfo;
 	ip_set_id_t index;
 
-	index = ip_set_nfnl_get_byindex(info->match_set.index);
+	index = ip_set_nfnl_get_byindex(par->net, info->match_set.index);
 
 	if (index == IPSET_INVALID_ID) {
 		pr_warning("Cannot find set indentified by id %u to match\n",
@@ -141,7 +141,7 @@ set_match_v1_checkentry(const struct xt_mtchk_param *par)
 	if (info->match_set.dim > IPSET_DIM_MAX) {
 		pr_warning("Protocol error: set match dimension "
 			   "is over the limit!\n");
-		ip_set_nfnl_put(info->match_set.index);
+		ip_set_nfnl_put(par->net, info->match_set.index);
 		return -ERANGE;
 	}
 
@@ -153,7 +153,7 @@ set_match_v1_destroy(const struct xt_mtdtor_param *par)
 {
 	struct xt_set_info_match_v1 *info = par->matchinfo;
 
-	ip_set_nfnl_put(info->match_set.index);
+	ip_set_nfnl_put(par->net, info->match_set.index);
 }
 
 /* Revision 3 match */
@@ -228,7 +228,7 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 	ip_set_id_t index;
 
 	if (info->add_set.index != IPSET_INVALID_ID) {
-		index = ip_set_nfnl_get_byindex(info->add_set.index);
+		index = ip_set_nfnl_get_byindex(par->net, info->add_set.index);
 		if (index == IPSET_INVALID_ID) {
 			pr_warning("Cannot find add_set index %u as target\n",
 				   info->add_set.index);
@@ -237,12 +237,12 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 	}
 
 	if (info->del_set.index != IPSET_INVALID_ID) {
-		index = ip_set_nfnl_get_byindex(info->del_set.index);
+		index = ip_set_nfnl_get_byindex(par->net, info->del_set.index);
 		if (index == IPSET_INVALID_ID) {
 			pr_warning("Cannot find del_set index %u as target\n",
 				   info->del_set.index);
 			if (info->add_set.index != IPSET_INVALID_ID)
-				ip_set_nfnl_put(info->add_set.index);
+				ip_set_nfnl_put(par->net, info->add_set.index);
 			return -ENOENT;
 		}
 	}
@@ -251,9 +251,9 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 		pr_warning("Protocol error: SET target dimension "
 			   "is over the limit!\n");
 		if (info->add_set.index != IPSET_INVALID_ID)
-			ip_set_nfnl_put(info->add_set.index);
+			ip_set_nfnl_put(par->net, info->add_set.index);
 		if (info->del_set.index != IPSET_INVALID_ID)
-			ip_set_nfnl_put(info->del_set.index);
+			ip_set_nfnl_put(par->net, info->del_set.index);
 		return -ERANGE;
 	}
 
@@ -270,9 +270,9 @@ set_target_v0_destroy(const struct xt_tgdtor_param *par)
 	const struct xt_set_info_target_v0 *info = par->targinfo;
 
 	if (info->add_set.index != IPSET_INVALID_ID)
-		ip_set_nfnl_put(info->add_set.index);
+		ip_set_nfnl_put(par->net, info->add_set.index);
 	if (info->del_set.index != IPSET_INVALID_ID)
-		ip_set_nfnl_put(info->del_set.index);
+		ip_set_nfnl_put(par->net, info->del_set.index);
 }
 
 /* Revision 1 target */
@@ -301,7 +301,7 @@ set_target_v1_checkentry(const struct xt_tgchk_param *par)
 	ip_set_id_t index;
 
 	if (info->add_set.index != IPSET_INVALID_ID) {
-		index = ip_set_nfnl_get_byindex(info->add_set.index);
+		index = ip_set_nfnl_get_byindex(par->net, info->add_set.index);
 		if (index == IPSET_INVALID_ID) {
 			pr_warning("Cannot find add_set index %u as target\n",
 				   info->add_set.index);
@@ -310,12 +310,12 @@ set_target_v1_checkentry(const struct xt_tgchk_param *par)
 	}
 
 	if (info->del_set.index != IPSET_INVALID_ID) {
-		index = ip_set_nfnl_get_byindex(info->del_set.index);
+		index = ip_set_nfnl_get_byindex(par->net, info->del_set.index);
 		if (index == IPSET_INVALID_ID) {
 			pr_warning("Cannot find del_set index %u as target\n",
 				   info->del_set.index);
 			if (info->add_set.index != IPSET_INVALID_ID)
-				ip_set_nfnl_put(info->add_set.index);
+				ip_set_nfnl_put(par->net, info->add_set.index);
 			return -ENOENT;
 		}
 	}
@@ -324,9 +324,9 @@ set_target_v1_checkentry(const struct xt_tgchk_param *par)
 		pr_warning("Protocol error: SET target dimension "
 			   "is over the limit!\n");
 		if (info->add_set.index != IPSET_INVALID_ID)
-			ip_set_nfnl_put(info->add_set.index);
+			ip_set_nfnl_put(par->net, info->add_set.index);
 		if (info->del_set.index != IPSET_INVALID_ID)
-			ip_set_nfnl_put(info->del_set.index);
+			ip_set_nfnl_put(par->net, info->del_set.index);
 		return -ERANGE;
 	}
 
@@ -339,9 +339,9 @@ set_target_v1_destroy(const struct xt_tgdtor_param *par)
 	const struct xt_set_info_target_v1 *info = par->targinfo;
 
 	if (info->add_set.index != IPSET_INVALID_ID)
-		ip_set_nfnl_put(info->add_set.index);
+		ip_set_nfnl_put(par->net, info->add_set.index);
 	if (info->del_set.index != IPSET_INVALID_ID)
-		ip_set_nfnl_put(info->del_set.index);
+		ip_set_nfnl_put(par->net, info->del_set.index);
 }
 
 /* Revision 2 target */
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index 938b7cb..1ac41d3 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -24,11 +24,12 @@ static int em_ipset_change(struct tcf_proto *tp, void *data, int data_len,
 {
 	struct xt_set_info *set = data;
 	ip_set_id_t index;
+	struct net *net = qdisc_dev(tp->q)->nd_net;
 
 	if (data_len != sizeof(*set))
 		return -EINVAL;
 
-	index = ip_set_nfnl_get_byindex(set->index);
+	index = ip_set_nfnl_get_byindex(net, set->index);
 	if (index == IPSET_INVALID_ID)
 		return -ENOENT;
 
@@ -37,7 +38,7 @@ static int em_ipset_change(struct tcf_proto *tp, void *data, int data_len,
 	if (em->data)
 		return 0;
 
-	ip_set_nfnl_put(index);
+	ip_set_nfnl_put(net, index);
 	return -ENOMEM;
 }
 
@@ -45,7 +46,7 @@ static void em_ipset_destroy(struct tcf_proto *p, struct tcf_ematch *em)
 {
 	const struct xt_set_info *set = (const void *) em->data;
 	if (set) {
-		ip_set_nfnl_put(set->index);
+		ip_set_nfnl_put(qdisc_dev(p->q)->nd_net, set->index);
 		kfree((void *) em->data);
 	}
 }
-- 
1.7.10.4
