From: kaber@trash.net
Subject: [PATCH 2/8] netfilter: ipset: references are protected by rwlock instead of mutex
Date: Tue,  5 Apr 2011 15:04:13 +0200
Message-ID: <1302008659-21141-3-git-send-email-kaber@trash.net>
References: <1302008659-21141-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39613 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab1DENEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 09:04:36 -0400
In-Reply-To: <1302008659-21141-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The timeout variant of the list:set type must reference the member sets.
However, its garbage collector runs at timer interrupt so the mutex
protection of the references is a no go. Therefore the reference protection
is converted to rwlock.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set.h       |    2 +-
 include/linux/netfilter/ipset/ip_set_ahash.h |    3 +-
 net/netfilter/ipset/ip_set_bitmap_ip.c       |    3 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |    3 +-
 net/netfilter/ipset/ip_set_bitmap_port.c     |    3 +-
 net/netfilter/ipset/ip_set_core.c            |  109 ++++++++++++++++----------
 net/netfilter/ipset/ip_set_list_set.c        |    6 +-
 7 files changed, 73 insertions(+), 56 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index ec333d8..5a262e3 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -293,7 +293,7 @@ struct ip_set {
 	/* Lock protecting the set data */
 	rwlock_t lock;
 	/* References to the set */
-	atomic_t ref;
+	u32 ref;
 	/* The core set type */
 	struct ip_set_type *type;
 	/* The type variant doing the real job */
diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index ec9d9be..a0196ac 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -515,8 +515,7 @@ type_pf_head(struct ip_set *set, struct sk_buff *skb)
 	if (h->netmask != HOST_MASK)
 		NLA_PUT_U8(skb, IPSET_ATTR_NETMASK, h->netmask);
 #endif
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES,
-		      htonl(atomic_read(&set->ref) - 1));
+	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
 	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize));
 	if (with_timeout(h->timeout))
 		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(h->timeout));
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index bca9699..a113ff0 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -338,8 +338,7 @@ bitmap_ip_head(struct ip_set *set, struct sk_buff *skb)
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip));
 	if (map->netmask != 32)
 		NLA_PUT_U8(skb, IPSET_ATTR_NETMASK, map->netmask);
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES,
-		      htonl(atomic_read(&set->ref) - 1));
+	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
 	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
 		      htonl(sizeof(*map) + map->memsize));
 	if (with_timeout(map->timeout))
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 5e79017..00a3324 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -434,8 +434,7 @@ bitmap_ipmac_head(struct ip_set *set, struct sk_buff *skb)
 		goto nla_put_failure;
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, htonl(map->first_ip));
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip));
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES,
-		      htonl(atomic_read(&set->ref) - 1));
+	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
 	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
 		      htonl(sizeof(*map)
 			    + (map->last_ip - map->first_ip + 1) * map->dsize));
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 165f09b..6b38eb8 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -320,8 +320,7 @@ bitmap_port_head(struct ip_set *set, struct sk_buff *skb)
 		goto nla_put_failure;
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, htons(map->first_port));
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT_TO, htons(map->last_port));
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES,
-		      htonl(atomic_read(&set->ref) - 1));
+	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
 	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
 		      htonl(sizeof(*map) + map->memsize));
 	if (with_timeout(map->timeout))
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index d6b4823..e88ac3c 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -26,6 +26,7 @@
 
 static LIST_HEAD(ip_set_type_list);		/* all registered set types */
 static DEFINE_MUTEX(ip_set_type_mutex);		/* protects ip_set_type_list */
+static DEFINE_RWLOCK(ip_set_ref_lock);		/* protects the set refs */
 
 static struct ip_set **ip_set_list;		/* all individual sets */
 static ip_set_id_t ip_set_max = CONFIG_IP_SET_MAX; /* max number of sets */
@@ -301,13 +302,18 @@ EXPORT_SYMBOL_GPL(ip_set_get_ipaddr6);
 static inline void
 __ip_set_get(ip_set_id_t index)
 {
-	atomic_inc(&ip_set_list[index]->ref);
+	write_lock_bh(&ip_set_ref_lock);
+	ip_set_list[index]->ref++;
+	write_unlock_bh(&ip_set_ref_lock);
 }
 
 static inline void
 __ip_set_put(ip_set_id_t index)
 {
-	atomic_dec(&ip_set_list[index]->ref);
+	write_lock_bh(&ip_set_ref_lock);
+	BUG_ON(ip_set_list[index]->ref == 0);
+	ip_set_list[index]->ref--;
+	write_unlock_bh(&ip_set_ref_lock);
 }
 
 /*
@@ -324,7 +330,7 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	struct ip_set *set = ip_set_list[index];
 	int ret = 0;
 
-	BUG_ON(set == NULL || atomic_read(&set->ref) == 0);
+	BUG_ON(set == NULL);
 	pr_debug("set %s, index %u\n", set->name, index);
 
 	if (dim < set->type->dimension ||
@@ -356,7 +362,7 @@ ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	struct ip_set *set = ip_set_list[index];
 	int ret;
 
-	BUG_ON(set == NULL || atomic_read(&set->ref) == 0);
+	BUG_ON(set == NULL);
 	pr_debug("set %s, index %u\n", set->name, index);
 
 	if (dim < set->type->dimension ||
@@ -378,7 +384,7 @@ ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	struct ip_set *set = ip_set_list[index];
 	int ret = 0;
 
-	BUG_ON(set == NULL || atomic_read(&set->ref) == 0);
+	BUG_ON(set == NULL);
 	pr_debug("set %s, index %u\n", set->name, index);
 
 	if (dim < set->type->dimension ||
@@ -397,7 +403,6 @@ EXPORT_SYMBOL_GPL(ip_set_del);
  * Find set by name, reference it once. The reference makes sure the
  * thing pointed to, does not go away under our feet.
  *
- * The nfnl mutex must already be activated.
  */
 ip_set_id_t
 ip_set_get_byname(const char *name, struct ip_set **set)
@@ -423,15 +428,12 @@ EXPORT_SYMBOL_GPL(ip_set_get_byname);
  * reference count by 1. The caller shall not assume the index
  * to be valid, after calling this function.
  *
- * The nfnl mutex must already be activated.
  */
 void
 ip_set_put_byindex(ip_set_id_t index)
 {
-	if (ip_set_list[index] != NULL) {
-		BUG_ON(atomic_read(&ip_set_list[index]->ref) == 0);
+	if (ip_set_list[index] != NULL)
 		__ip_set_put(index);
-	}
 }
 EXPORT_SYMBOL_GPL(ip_set_put_byindex);
 
@@ -441,7 +443,6 @@ EXPORT_SYMBOL_GPL(ip_set_put_byindex);
  * can't be destroyed. The set cannot be renamed due to
  * the referencing either.
  *
- * The nfnl mutex must already be activated.
  */
 const char *
 ip_set_name_byindex(ip_set_id_t index)
@@ -449,7 +450,7 @@ ip_set_name_byindex(ip_set_id_t index)
 	const struct ip_set *set = ip_set_list[index];
 
 	BUG_ON(set == NULL);
-	BUG_ON(atomic_read(&set->ref) == 0);
+	BUG_ON(set->ref == 0);
 
 	/* Referenced, so it's safe */
 	return set->name;
@@ -515,10 +516,7 @@ void
 ip_set_nfnl_put(ip_set_id_t index)
 {
 	nfnl_lock();
-	if (ip_set_list[index] != NULL) {
-		BUG_ON(atomic_read(&ip_set_list[index]->ref) == 0);
-		__ip_set_put(index);
-	}
+	ip_set_put_byindex(index);
 	nfnl_unlock();
 }
 EXPORT_SYMBOL_GPL(ip_set_nfnl_put);
@@ -526,7 +524,7 @@ EXPORT_SYMBOL_GPL(ip_set_nfnl_put);
 /*
  * Communication protocol with userspace over netlink.
  *
- * We already locked by nfnl_lock.
+ * The commands are serialized by the nfnl mutex.
  */
 
 static inline bool
@@ -657,7 +655,6 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 		return -ENOMEM;
 	rwlock_init(&set->lock);
 	strlcpy(set->name, name, IPSET_MAXNAMELEN);
-	atomic_set(&set->ref, 0);
 	set->family = family;
 
 	/*
@@ -690,8 +687,8 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 
 	/*
 	 * Here, we have a valid, constructed set and we are protected
-	 * by nfnl_lock. Find the first free index in ip_set_list and
-	 * check clashing.
+	 * by the nfnl mutex. Find the first free index in ip_set_list
+	 * and check clashing.
 	 */
 	if ((ret = find_free_id(set->name, &index, &clash)) != 0) {
 		/* If this is the same set and requested, ignore error */
@@ -751,31 +748,51 @@ ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
 	       const struct nlattr * const attr[])
 {
 	ip_set_id_t i;
+	int ret = 0;
 
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
 
-	/* References are protected by the nfnl mutex */
+	/* Commands are serialized and references are
+	 * protected by the ip_set_ref_lock.
+	 * External systems (i.e. xt_set) must call
+	 * ip_set_put|get_nfnl_* functions, that way we
+	 * can safely check references here.
+	 *
+	 * list:set timer can only decrement the reference
+	 * counter, so if it's already zero, we can proceed
+	 * without holding the lock.
+	 */
+	read_lock_bh(&ip_set_ref_lock);
 	if (!attr[IPSET_ATTR_SETNAME]) {
 		for (i = 0; i < ip_set_max; i++) {
-			if (ip_set_list[i] != NULL &&
-			    (atomic_read(&ip_set_list[i]->ref)))
-				return -IPSET_ERR_BUSY;
+			if (ip_set_list[i] != NULL && ip_set_list[i]->ref) {
+				ret = IPSET_ERR_BUSY;
+				goto out;
+			}
 		}
+		read_unlock_bh(&ip_set_ref_lock);
 		for (i = 0; i < ip_set_max; i++) {
 			if (ip_set_list[i] != NULL)
 				ip_set_destroy_set(i);
 		}
 	} else {
 		i = find_set_id(nla_data(attr[IPSET_ATTR_SETNAME]));
-		if (i == IPSET_INVALID_ID)
-			return -ENOENT;
-		else if (atomic_read(&ip_set_list[i]->ref))
-			return -IPSET_ERR_BUSY;
+		if (i == IPSET_INVALID_ID) {
+			ret = -ENOENT;
+			goto out;
+		} else if (ip_set_list[i]->ref) {
+			ret = -IPSET_ERR_BUSY;
+			goto out;
+		}
+		read_unlock_bh(&ip_set_ref_lock);
 
 		ip_set_destroy_set(i);
 	}
 	return 0;
+out:
+	read_unlock_bh(&ip_set_ref_lock);
+	return ret;
 }
 
 /* Flush sets */
@@ -834,6 +851,7 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 	struct ip_set *set;
 	const char *name2;
 	ip_set_id_t i;
+	int ret = 0;
 
 	if (unlikely(protocol_failed(attr) ||
 		     attr[IPSET_ATTR_SETNAME] == NULL ||
@@ -843,25 +861,33 @@ ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
 	set = find_set(nla_data(attr[IPSET_ATTR_SETNAME]));
 	if (set == NULL)
 		return -ENOENT;
-	if (atomic_read(&set->ref) != 0)
-		return -IPSET_ERR_REFERENCED;
+
+	read_lock_bh(&ip_set_ref_lock);
+	if (set->ref != 0) {
+		ret = -IPSET_ERR_REFERENCED;
+		goto out;
+	}
 
 	name2 = nla_data(attr[IPSET_ATTR_SETNAME2]);
 	for (i = 0; i < ip_set_max; i++) {
 		if (ip_set_list[i] != NULL &&
-		    STREQ(ip_set_list[i]->name, name2))
-			return -IPSET_ERR_EXIST_SETNAME2;
+		    STREQ(ip_set_list[i]->name, name2)) {
+			ret = -IPSET_ERR_EXIST_SETNAME2;
+			goto out;
+		}
 	}
 	strncpy(set->name, name2, IPSET_MAXNAMELEN);
 
-	return 0;
+out:
+	read_unlock_bh(&ip_set_ref_lock);
+	return ret;
 }
 
 /* Swap two sets so that name/index points to the other.
  * References and set names are also swapped.
  *
- * We are protected by the nfnl mutex and references are
- * manipulated only by holding the mutex. The kernel interfaces
+ * The commands are serialized by the nfnl mutex and references are
+ * protected by the ip_set_ref_lock. The kernel interfaces
  * do not hold the mutex but the pointer settings are atomic
  * so the ip_set_list always contains valid pointers to the sets.
  */
@@ -874,7 +900,6 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 	struct ip_set *from, *to;
 	ip_set_id_t from_id, to_id;
 	char from_name[IPSET_MAXNAMELEN];
-	u32 from_ref;
 
 	if (unlikely(protocol_failed(attr) ||
 		     attr[IPSET_ATTR_SETNAME] == NULL ||
@@ -899,17 +924,15 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 	      from->type->family == to->type->family))
 		return -IPSET_ERR_TYPE_MISMATCH;
 
-	/* No magic here: ref munging protected by the nfnl_lock */
 	strncpy(from_name, from->name, IPSET_MAXNAMELEN);
-	from_ref = atomic_read(&from->ref);
-
 	strncpy(from->name, to->name, IPSET_MAXNAMELEN);
-	atomic_set(&from->ref, atomic_read(&to->ref));
 	strncpy(to->name, from_name, IPSET_MAXNAMELEN);
-	atomic_set(&to->ref, from_ref);
 
+	write_lock_bh(&ip_set_ref_lock);
+	swap(from->ref, to->ref);
 	ip_set_list[from_id] = to;
 	ip_set_list[to_id] = from;
+	write_unlock_bh(&ip_set_ref_lock);
 
 	return 0;
 }
@@ -926,7 +949,7 @@ ip_set_dump_done(struct netlink_callback *cb)
 {
 	if (cb->args[2]) {
 		pr_debug("release set %s\n", ip_set_list[cb->args[1]]->name);
-		__ip_set_put((ip_set_id_t) cb->args[1]);
+		ip_set_put_byindex((ip_set_id_t) cb->args[1]);
 	}
 	return 0;
 }
@@ -1068,7 +1091,7 @@ release_refcount:
 	/* If there was an error or set is done, release set */
 	if (ret || !cb->args[2]) {
 		pr_debug("release set %s\n", ip_set_list[index]->name);
-		__ip_set_put(index);
+		ip_set_put_byindex(index);
 	}
 
 	/* If we dump all sets, continue with dumping last ones */
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index f4a46c0..e9159e9 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -366,8 +366,7 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	NLA_PUT_NET32(skb, IPSET_ATTR_SIZE, htonl(map->size));
 	if (with_timeout(map->timeout))
 		NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout));
-	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES,
-		      htonl(atomic_read(&set->ref) - 1));
+	NLA_PUT_NET32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1));
 	NLA_PUT_NET32(skb, IPSET_ATTR_MEMSIZE,
 		      htonl(sizeof(*map) + map->size * map->dsize));
 	ipset_nest_end(skb, nested);
@@ -457,8 +456,7 @@ list_set_gc(unsigned long ul_set)
 	struct list_set *map = set->data;
 	struct set_telem *e;
 	u32 i;
-	
-	/* nfnl_lock should be called */
+
 	write_lock_bh(&set->lock);
 	for (i = 0; i < map->size; i++) {
 		e = list_set_telem(map, i);
-- 
1.7.2.3

