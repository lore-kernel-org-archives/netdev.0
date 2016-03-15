From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/18] netfilter: ipset: Fix set:list type crash when flush/dump set in parallel
Date: Tue, 15 Mar 2016 02:27:45 +0100
Message-ID: <1458005282-24665-2-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Flushing/listing entries was not RCU safe, so parallel flush/dump
could lead to kernel crash. Bug reported by Deniz Eren.

Fixes netfilter bugzilla id #1050.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_core.c     |  3 ++
 net/netfilter/ipset/ip_set_list_set.c | 55 ++++++++++++++++-------------------
 2 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 95db43f..7e6568c 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -985,6 +985,9 @@ static int ip_set_destroy(struct net *net, struct sock *ctnl,
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
 
+	/* Must wait for flush to be really finished in list:set */
+	rcu_barrier();
+
 	/* Commands are serialized and references are
 	 * protected by the ip_set_ref_lock.
 	 * External systems (i.e. xt_set) must call
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index bbede95..24c6c19 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -30,6 +30,7 @@ MODULE_ALIAS("ip_set_list:set");
 struct set_elem {
 	struct rcu_head rcu;
 	struct list_head list;
+	struct ip_set *set;	/* Sigh, in order to cleanup reference */
 	ip_set_id_t id;
 } __aligned(__alignof__(u64));
 
@@ -151,30 +152,29 @@ list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
 /* Userspace interfaces: we are protected by the nfnl mutex */
 
 static void
-__list_set_del(struct ip_set *set, struct set_elem *e)
+__list_set_del_rcu(struct rcu_head * rcu)
 {
+	struct set_elem *e = container_of(rcu, struct set_elem, rcu);
+	struct ip_set *set = e->set;
 	struct list_set *map = set->data;
 
 	ip_set_put_byindex(map->net, e->id);
-	/* We may call it, because we don't have a to be destroyed
-	 * extension which is used by the kernel.
-	 */
 	ip_set_ext_destroy(set, e);
-	kfree_rcu(e, rcu);
+	kfree(e);
 }
 
 static inline void
 list_set_del(struct ip_set *set, struct set_elem *e)
 {
 	list_del_rcu(&e->list);
-	__list_set_del(set, e);
+	call_rcu(&e->rcu, __list_set_del_rcu);
 }
 
 static inline void
-list_set_replace(struct ip_set *set, struct set_elem *e, struct set_elem *old)
+list_set_replace(struct set_elem *e, struct set_elem *old)
 {
 	list_replace_rcu(&old->list, &e->list);
-	__list_set_del(set, old);
+	call_rcu(&old->rcu, __list_set_del_rcu);
 }
 
 static void
@@ -244,9 +244,6 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	struct set_elem *e, *n, *prev, *next;
 	bool flag_exist = flags & IPSET_FLAG_EXIST;
 
-	if (SET_WITH_TIMEOUT(set))
-		set_cleanup_entries(set);
-
 	/* Find where to add the new entry */
 	n = prev = next = NULL;
 	list_for_each_entry(e, &map->members, list) {
@@ -301,10 +298,11 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	if (!e)
 		return -ENOMEM;
 	e->id = d->id;
+	e->set = set;
 	INIT_LIST_HEAD(&e->list);
 	list_set_init_extensions(set, ext, e);
 	if (n)
-		list_set_replace(set, e, n);
+		list_set_replace(e, n);
 	else if (next)
 		list_add_tail_rcu(&e->list, &next->list);
 	else if (prev)
@@ -431,6 +429,7 @@ list_set_destroy(struct ip_set *set)
 
 	if (SET_WITH_TIMEOUT(set))
 		del_timer_sync(&map->gc);
+
 	list_for_each_entry_safe(e, n, &map->members, list) {
 		list_del(&e->list);
 		ip_set_put_byindex(map->net, e->id);
@@ -450,8 +449,10 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	struct set_elem *e;
 	u32 n = 0;
 
-	list_for_each_entry(e, &map->members, list)
+	rcu_read_lock();
+	list_for_each_entry_rcu(e, &map->members, list)
 		n++;
+	rcu_read_unlock();
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
@@ -483,33 +484,25 @@ list_set_list(const struct ip_set *set,
 	atd = ipset_nest_start(skb, IPSET_ATTR_ADT);
 	if (!atd)
 		return -EMSGSIZE;
-	list_for_each_entry(e, &map->members, list) {
-		if (i == first)
-			break;
-		i++;
-	}
 
 	rcu_read_lock();
-	list_for_each_entry_from(e, &map->members, list) {
-		i++;
-		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(e, set)))
+	list_for_each_entry_rcu(e, &map->members, list) {
+		if (i < first ||
+		    (SET_WITH_TIMEOUT(set) &&
+		     ip_set_timeout_expired(ext_timeout(e, set)))) {
+			i++;
 			continue;
+		}
 		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-		if (!nested) {
-			if (i == first) {
-				nla_nest_cancel(skb, atd);
-				ret = -EMSGSIZE;
-				goto out;
-			}
+		if (!nested)
 			goto nla_put_failure;
-		}
 		if (nla_put_string(skb, IPSET_ATTR_NAME,
 				   ip_set_name_byindex(map->net, e->id)))
 			goto nla_put_failure;
 		if (ip_set_put_extensions(skb, set, e, true))
 			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
+		i++;
 	}
 
 	ipset_nest_end(skb, atd);
@@ -520,10 +513,12 @@ list_set_list(const struct ip_set *set,
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
 	if (unlikely(i == first)) {
+		nla_nest_cancel(skb, atd);
 		cb->args[IPSET_CB_ARG0] = 0;
 		ret = -EMSGSIZE;
+	} else {
+		cb->args[IPSET_CB_ARG0] = i;
 	}
-	cb->args[IPSET_CB_ARG0] = i - 1;
 	ipset_nest_end(skb, atd);
 out:
 	rcu_read_unlock();
-- 
2.1.4

