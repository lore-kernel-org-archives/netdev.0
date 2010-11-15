From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/5] bridge: add RCU annotation to bridge multicast table
Date: Mon, 15 Nov 2010 08:38:10 -0800
Message-ID: <20101115163828.043960281@vyatta.com>
References: <20101115163809.215552143@vyatta.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38460 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757947Ab0KOQlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 11:41:44 -0500
Content-Disposition: inline; filename=bridge-mlock-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Add modern __rcu annotatations to bridge multicast table.
Use newer hlist macros to avoid direct access to hlist internals.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2. Fix hlist_next_rcu call

 net/bridge/br_forward.c   |    4 +-
 net/bridge/br_multicast.c |   78 ++++++++++++++++++++++++++++++----------------
 net/bridge/br_private.h   |    6 +--
 3 files changed, 56 insertions(+), 32 deletions(-)

--- a/net/bridge/br_multicast.c	2010-11-14 12:36:30.383348571 -0800
+++ b/net/bridge/br_multicast.c	2010-11-14 12:36:37.084167303 -0800
@@ -33,6 +33,9 @@
 
 #include "br_private.h"
 
+#define mlock_dereference(X, br) \
+	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline int ipv6_is_local_multicast(const struct in6_addr *addr)
 {
@@ -135,7 +138,7 @@ static struct net_bridge_mdb_entry *br_m
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb = rcu_dereference(br->mdb);
 	struct br_ip ip;
 
 	if (br->multicast_disabled)
@@ -235,7 +238,8 @@ static void br_multicast_group_expired(u
 	if (mp->ports)
 		goto out;
 
-	mdb = br->mdb;
+	mdb = mlock_dereference(br->mdb, br);
+
 	hlist_del_rcu(&mp->hlist[mdb->ver]);
 	mdb->size--;
 
@@ -249,16 +253,20 @@ out:
 static void br_multicast_del_pg(struct net_bridge *br,
 				struct net_bridge_port_group *pg)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
-	struct net_bridge_port_group **pp;
+	struct net_bridge_port_group __rcu **pp;
+
+	mdb = mlock_dereference(br->mdb, br);
 
 	mp = br_mdb_ip_get(mdb, &pg->addr);
 	if (WARN_ON(!mp))
 		return;
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (p != pg)
 			continue;
 
@@ -294,10 +302,10 @@ out:
 	spin_unlock(&br->multicast_lock);
 }
 
-static int br_mdb_rehash(struct net_bridge_mdb_htable **mdbp, int max,
+static int br_mdb_rehash(struct net_bridge_mdb_htable __rcu **mdbp, int max,
 			 int elasticity)
 {
-	struct net_bridge_mdb_htable *old = *mdbp;
+	struct net_bridge_mdb_htable *old = rcu_dereference_protected(*mdbp, 1);
 	struct net_bridge_mdb_htable *mdb;
 	int err;
 
@@ -569,7 +577,7 @@ static struct net_bridge_mdb_entry *br_m
 	struct net_bridge *br, struct net_bridge_port *port,
 	struct br_ip *group, int hash)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
 	struct hlist_node *p;
 	unsigned count = 0;
@@ -577,6 +585,7 @@ static struct net_bridge_mdb_entry *br_m
 	int elasticity;
 	int err;
 
+	mdb = rcu_dereference_protected(br->mdb, 1);
 	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
 		count++;
 		if (unlikely(br_ip_equal(group, &mp->addr)))
@@ -642,10 +651,11 @@ static struct net_bridge_mdb_entry *br_m
 	struct net_bridge *br, struct net_bridge_port *port,
 	struct br_ip *group)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
 	int hash;
 
+	mdb = rcu_dereference_protected(br->mdb, 1);
 	if (!mdb) {
 		if (br_mdb_rehash(&br->mdb, BR_HASH_SIZE, 0))
 			return NULL;
@@ -660,7 +670,7 @@ static struct net_bridge_mdb_entry *br_m
 
 	case -EAGAIN:
 rehash:
-		mdb = br->mdb;
+		mdb = rcu_dereference_protected(br->mdb, 1);
 		hash = br_ip_hash(mdb, group);
 		break;
 
@@ -692,7 +702,7 @@ static int br_multicast_add_group(struct
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
-	struct net_bridge_port_group **pp;
+	struct net_bridge_port_group __rcu **pp;
 	unsigned long now = jiffies;
 	int err;
 
@@ -712,7 +722,9 @@ static int br_multicast_add_group(struct
 		goto out;
 	}
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (p->port == port)
 			goto found;
 		if ((unsigned long)p->port < (unsigned long)port)
@@ -1106,7 +1118,7 @@ static int br_ip4_multicast_query(struct
 	struct net_bridge_mdb_entry *mp;
 	struct igmpv3_query *ih3;
 	struct net_bridge_port_group *p;
-	struct net_bridge_port_group **pp;
+	struct net_bridge_port_group __rcu **pp;
 	unsigned long max_delay;
 	unsigned long now = jiffies;
 	__be32 group;
@@ -1145,7 +1157,7 @@ static int br_ip4_multicast_query(struct
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip4_get(br->mdb, group);
+	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group);
 	if (!mp)
 		goto out;
 
@@ -1157,7 +1169,9 @@ static int br_ip4_multicast_query(struct
 	     try_to_del_timer_sync(&mp->timer) >= 0))
 		mod_timer(&mp->timer, now + max_delay);
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (timer_pending(&p->timer) ?
 		    time_after(p->timer.expires, now + max_delay) :
 		    try_to_del_timer_sync(&p->timer) >= 0)
@@ -1178,7 +1192,8 @@ static int br_ip6_multicast_query(struct
 	struct mld_msg *mld = (struct mld_msg *) icmp6_hdr(skb);
 	struct net_bridge_mdb_entry *mp;
 	struct mld2_query *mld2q;
-	struct net_bridge_port_group *p, **pp;
+	struct net_bridge_port_group *p;
+	struct net_bridge_port_group __rcu **pp;
 	unsigned long max_delay;
 	unsigned long now = jiffies;
 	struct in6_addr *group = NULL;
@@ -1214,7 +1229,7 @@ static int br_ip6_multicast_query(struct
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip6_get(br->mdb, group);
+	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group);
 	if (!mp)
 		goto out;
 
@@ -1225,7 +1240,9 @@ static int br_ip6_multicast_query(struct
 	     try_to_del_timer_sync(&mp->timer) >= 0))
 		mod_timer(&mp->timer, now + max_delay);
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (timer_pending(&p->timer) ?
 		    time_after(p->timer.expires, now + max_delay) :
 		    try_to_del_timer_sync(&p->timer) >= 0)
@@ -1254,7 +1271,7 @@ static void br_multicast_leave_group(str
 	    timer_pending(&br->multicast_querier_timer))
 		goto out;
 
-	mdb = br->mdb;
+	mdb = mlock_dereference(br->mdb, br);
 	mp = br_mdb_ip_get(mdb, group);
 	if (!mp)
 		goto out;
@@ -1277,7 +1294,9 @@ static void br_multicast_leave_group(str
 		goto out;
 	}
 
-	for (p = mp->ports; p; p = p->next) {
+	for (p = mlock_dereference(mp->ports, br);
+	     p != NULL;
+	     p = mlock_dereference(p->next, br)) {
 		if (p->port != port)
 			continue;
 
@@ -1625,7 +1644,7 @@ void br_multicast_stop(struct net_bridge
 	del_timer_sync(&br->multicast_query_timer);
 
 	spin_lock_bh(&br->multicast_lock);
-	mdb = br->mdb;
+	mdb = mlock_dereference(br->mdb, br);
 	if (!mdb)
 		goto out;
 
@@ -1729,6 +1748,7 @@ int br_multicast_toggle(struct net_bridg
 {
 	struct net_bridge_port *port;
 	int err = 0;
+	struct net_bridge_mdb_htable *mdb;
 
 	spin_lock(&br->multicast_lock);
 	if (br->multicast_disabled == !val)
@@ -1741,15 +1761,16 @@ int br_multicast_toggle(struct net_bridg
 	if (!netif_running(br->dev))
 		goto unlock;
 
-	if (br->mdb) {
-		if (br->mdb->old) {
+	mdb = mlock_dereference(br->mdb, br);
+	if (mdb) {
+		if (mdb->old) {
 			err = -EEXIST;
 rollback:
 			br->multicast_disabled = !!val;
 			goto unlock;
 		}
 
-		err = br_mdb_rehash(&br->mdb, br->mdb->max,
+		err = br_mdb_rehash(&br->mdb, mdb->max,
 				    br->hash_elasticity);
 		if (err)
 			goto rollback;
@@ -1774,6 +1795,7 @@ int br_multicast_set_hash_max(struct net
 {
 	int err = -ENOENT;
 	u32 old;
+	struct net_bridge_mdb_htable *mdb;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev))
@@ -1782,7 +1804,9 @@ int br_multicast_set_hash_max(struct net
 	err = -EINVAL;
 	if (!is_power_of_2(val))
 		goto unlock;
-	if (br->mdb && val < br->mdb->size)
+
+	mdb = mlock_dereference(br->mdb, br);
+	if (mdb && val < mdb->size)
 		goto unlock;
 
 	err = 0;
@@ -1790,8 +1814,8 @@ int br_multicast_set_hash_max(struct net
 	old = br->hash_max;
 	br->hash_max = val;
 
-	if (br->mdb) {
-		if (br->mdb->old) {
+	if (mdb) {
+		if (mdb->old) {
 			err = -EEXIST;
 rollback:
 			br->hash_max = old;
--- a/net/bridge/br_private.h	2010-11-14 12:36:30.399350527 -0800
+++ b/net/bridge/br_private.h	2010-11-14 12:44:07.257410977 -0800
@@ -72,7 +72,7 @@ struct net_bridge_fdb_entry
 
 struct net_bridge_port_group {
 	struct net_bridge_port		*port;
-	struct net_bridge_port_group	*next;
+	struct net_bridge_port_group __rcu *next;
 	struct hlist_node		mglist;
 	struct rcu_head			rcu;
 	struct timer_list		timer;
@@ -86,7 +86,7 @@ struct net_bridge_mdb_entry
 	struct hlist_node		hlist[2];
 	struct hlist_node		mglist;
 	struct net_bridge		*br;
-	struct net_bridge_port_group	*ports;
+	struct net_bridge_port_group __rcu *ports;
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
@@ -227,7 +227,7 @@ struct net_bridge
 	unsigned long			multicast_startup_query_interval;
 
 	spinlock_t			multicast_lock;
-	struct net_bridge_mdb_htable	*mdb;
+	struct net_bridge_mdb_htable __rcu *mdb;
 	struct hlist_head		router_list;
 	struct hlist_head		mglist;
 
--- a/net/bridge/br_forward.c	2010-11-14 12:36:47.833478598 -0800
+++ b/net/bridge/br_forward.c	2010-11-14 12:42:22.001208297 -0800
@@ -223,7 +223,7 @@ static void br_multicast_flood(struct ne
 	struct net_bridge_port_group *p;
 	struct hlist_node *rp;
 
-	rp = rcu_dereference(br->router_list.first);
+	rp = rcu_dereference(hlist_first_rcu(&br->router_list));
 	p = mdst ? rcu_dereference(mdst->ports) : NULL;
 	while (p || rp) {
 		struct net_bridge_port *port, *lport, *rport;
@@ -242,7 +242,7 @@ static void br_multicast_flood(struct ne
 		if ((unsigned long)lport >= (unsigned long)port)
 			p = rcu_dereference(p->next);
 		if ((unsigned long)rport >= (unsigned long)port)
-			rp = rcu_dereference(rp->next);
+			rp = rcu_dereference(hlist_next_rcu(rp));
 	}
 
 	if (!prev)


