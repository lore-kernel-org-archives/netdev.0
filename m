From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/32] netfilter: ipset: Introduce RCU locking in bitmap:* types
Date: Mon, 15 Jun 2015 23:26:21 +0200
Message-ID: <1434403589-24796-25-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

There's nothing much required because the bitmap types use atomic
bit operations. However the logic of adding elements slightly changed:
first the MAC address updated (which is not atomic), then the element
activated (added). The extensions may call kfree_rcu() therefore we
call rcu_barrier() at module removal.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_gen.h   |   33 ++++++++++++++++++++---------
 net/netfilter/ipset/ip_set_bitmap_ip.c    |    3 ++-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |   13 ++++++++++--
 net/netfilter/ipset/ip_set_bitmap_port.c  |    3 ++-
 4 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index 6f024a8..86429f3 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -144,10 +144,12 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 
 	if (ret == IPSET_ADD_FAILED) {
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(x, set)))
+		    ip_set_timeout_expired(ext_timeout(x, set))) {
 			ret = 0;
-		else if (!(flags & IPSET_FLAG_EXIST))
+		} else if (!(flags & IPSET_FLAG_EXIST)) {
+			set_bit(e->id, map->members);
 			return -IPSET_ERR_EXIST;
+		}
 		/* Element is re-added, cleanup extensions */
 		ip_set_ext_destroy(set, x);
 	}
@@ -165,6 +167,10 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		ip_set_init_comment(ext_comment(x, set), ext);
 	if (SET_WITH_SKBINFO(set))
 		ip_set_init_skbinfo(ext_skbinfo(x, set), ext);
+
+	/* Activate element */
+	set_bit(e->id, map->members);
+
 	return 0;
 }
 
@@ -203,10 +209,13 @@ mtype_list(const struct ip_set *set,
 	struct nlattr *adt, *nested;
 	void *x;
 	u32 id, first = cb->args[IPSET_CB_ARG0];
+	int ret = 0;
 
 	adt = ipset_nest_start(skb, IPSET_ATTR_ADT);
 	if (!adt)
 		return -EMSGSIZE;
+	/* Extensions may be replaced */
+	rcu_read_lock();
 	for (; cb->args[IPSET_CB_ARG0] < map->elements;
 	     cb->args[IPSET_CB_ARG0]++) {
 		id = cb->args[IPSET_CB_ARG0];
@@ -222,9 +231,11 @@ mtype_list(const struct ip_set *set,
 		if (!nested) {
 			if (id == first) {
 				nla_nest_cancel(skb, adt);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
+				ret = -EMSGSIZE;
+				goto out;
+			}
+
+			goto nla_put_failure;
 		}
 		if (mtype_do_list(skb, map, id, set->dsize))
 			goto nla_put_failure;
@@ -238,16 +249,18 @@ mtype_list(const struct ip_set *set,
 	/* Set listing finished */
 	cb->args[IPSET_CB_ARG0] = 0;
 
-	return 0;
+	goto out;
 
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
 	if (unlikely(id == first)) {
 		cb->args[IPSET_CB_ARG0] = 0;
-		return -EMSGSIZE;
+		ret = -EMSGSIZE;
 	}
 	ipset_nest_end(skb, adt);
-	return 0;
+out:
+	rcu_read_unlock();
+	return ret;
 }
 
 static void
@@ -260,7 +273,7 @@ mtype_gc(unsigned long ul_set)
 
 	/* We run parallel with other readers (test element)
 	 * but adding/deleting new entries is locked out */
-	read_lock_bh(&set->lock);
+	spin_lock_bh(&set->lock);
 	for (id = 0; id < map->elements; id++)
 		if (mtype_gc_test(id, map, set->dsize)) {
 			x = get_ext(set, map, id);
@@ -269,7 +282,7 @@ mtype_gc(unsigned long ul_set)
 				ip_set_ext_destroy(set, x);
 			}
 		}
-	read_unlock_bh(&set->lock);
+	spin_unlock_bh(&set->lock);
 
 	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&map->gc);
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 7af99c3..b8ce474 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -81,7 +81,7 @@ static inline int
 bitmap_ip_do_add(const struct bitmap_ip_adt_elem *e, struct bitmap_ip *map,
 		 u32 flags, size_t dsize)
 {
-	return !!test_and_set_bit(e->id, map->members);
+	return !!test_bit(e->id, map->members);
 }
 
 static inline int
@@ -376,6 +376,7 @@ bitmap_ip_init(void)
 static void __exit
 bitmap_ip_fini(void)
 {
+	rcu_barrier();
 	ip_set_type_unregister(&bitmap_ip_type);
 }
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 7733422..fe00e87 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -147,15 +147,23 @@ bitmap_ipmac_do_add(const struct bitmap_ipmac_adt_elem *e,
 	struct bitmap_ipmac_elem *elem;
 
 	elem = get_elem(map->extensions, e->id, dsize);
-	if (test_and_set_bit(e->id, map->members)) {
+	if (test_bit(e->id, map->members)) {
 		if (elem->filled == MAC_FILLED) {
-			if (e->ether && (flags & IPSET_FLAG_EXIST))
+			if (e->ether &&
+			    (flags & IPSET_FLAG_EXIST) &&
+			    !ether_addr_equal(e->ether, elem->ether)) {
+				/* memcpy isn't atomic */
+				clear_bit(e->id, map->members);
+				smp_mb__after_atomic();
 				memcpy(elem->ether, e->ether, ETH_ALEN);
+			}
 			return IPSET_ADD_FAILED;
 		} else if (!e->ether)
 			/* Already added without ethernet address */
 			return IPSET_ADD_FAILED;
 		/* Fill the MAC address and trigger the timer activation */
+		clear_bit(e->id, map->members);
+		smp_mb__after_atomic();
 		memcpy(elem->ether, e->ether, ETH_ALEN);
 		elem->filled = MAC_FILLED;
 		return IPSET_ADD_START_STORED_TIMEOUT;
@@ -413,6 +421,7 @@ bitmap_ipmac_init(void)
 static void __exit
 bitmap_ipmac_fini(void)
 {
+	rcu_barrier();
 	ip_set_type_unregister(&bitmap_ipmac_type);
 }
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index ec3bda1..2d360f9 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -73,7 +73,7 @@ static inline int
 bitmap_port_do_add(const struct bitmap_port_adt_elem *e,
 		   struct bitmap_port *map, u32 flags, size_t dsize)
 {
-	return !!test_and_set_bit(e->id, map->members);
+	return !!test_bit(e->id, map->members);
 }
 
 static inline int
@@ -306,6 +306,7 @@ bitmap_port_init(void)
 static void __exit
 bitmap_port_fini(void)
 {
+	rcu_barrier();
 	ip_set_type_unregister(&bitmap_port_type);
 }
 
-- 
1.7.10.4

