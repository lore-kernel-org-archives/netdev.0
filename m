From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next] arp: Really delete an arp entry on "arp -d"
Date: Mon, 29 May 2017 20:48:16 -0700
Message-ID: <1496116096-77316-1-git-send-email-sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23653 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdE3XOy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 19:14:54 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v4UNEpdH024980
        (version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 23:14:52 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.13.8/8.14.4) with ESMTP id v4UNEoDc013528
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 23:14:51 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v4UNEoGX008917
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 23:14:50 GMT
To: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed during some testing: the command
  # arp -s 62.2.0.1 a:b:c:d:e:f dev eth2
adds an entry like the following (listed by "arp -an")
  ? (62.2.0.1) at 0a:0b:0c:0d:0e:0f [ether] PERM on eth2
but the symmetric deletion command
  # arp -i eth2 -d 62.2.0.1
does not remove the PERM entry from the table, and instead leaves behind
  ? (62.2.0.1) at <incomplete> on eth2

The reason is that there is a refcnt of 1 for the arp_tbl itself
(neigh_alloc starts off the entry with a refcnt of 1), thus
the neigh_release() call from arp_invalidate() will (at best) just
decrement the ref to 1, but will never actually free it from the
table.

To fix this, we need to do something like neigh_forced_gc: if
the refcnt is 1 (i.e., on the table's ref), remove the entry from
the table and free it.

We may need something symmetric for IPv6- I was going to check into
that, after getting some feedback on this RFC patch.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/net/neighbour.h |    1 +
 net/core/neighbour.c    |   42 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/arp.c          |    1 +
 3 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index e4dd3a2..639b675 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -317,6 +317,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, u32 flags,
 		 u32 nlmsg_pid);
 void __neigh_set_probe_once(struct neighbour *neigh);
+bool neigh_remove_one(struct neighbour *ndel, struct neigh_table *tbl);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d274f81..0a09f6f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -117,6 +117,48 @@ unsigned long neigh_rand_reach_time(unsigned long base)
 }
 EXPORT_SYMBOL(neigh_rand_reach_time);
 
+bool neigh_remove_one(struct neighbour *ndel, struct neigh_table *tbl)
+{
+	struct neigh_hash_table *nht;
+	void *pkey = ndel->primary_key;
+	u32 hash_val;
+	struct neighbour *n;
+	struct neighbour __rcu **np;
+
+	write_lock_bh(&tbl->lock);
+	nht = rcu_dereference_protected(tbl->nht,
+					lockdep_is_held(&tbl->lock));
+	hash_val = tbl->hash(pkey, ndel->dev, nht->hash_rnd);
+	hash_val = hash_val >> (32 - nht->hash_shift);
+
+	np = &nht->hash_buckets[hash_val];
+	while ((n = rcu_dereference_protected(*np,
+				lockdep_is_held(&tbl->lock))) != NULL) {
+		write_lock(&n->lock);
+		if (n == ndel) {
+			bool retval = false;
+
+			if  (atomic_read(&n->refcnt) == 1) {
+				rcu_assign_pointer(*np,
+					rcu_dereference_protected(n->next,
+					lockdep_is_held(&tbl->lock)));
+				n->dead = 1;
+				retval = true;
+			}
+			write_unlock(&n->lock);
+			if (retval)
+				neigh_cleanup_and_release(n);
+			write_unlock_bh(&tbl->lock);
+			return retval;
+		}
+		write_unlock(&n->lock);
+		np = &n->next;
+	}
+
+	write_unlock_bh(&tbl->lock);
+	return false;
+}
+EXPORT_SYMBOL(neigh_remove_one);
 
 static int neigh_forced_gc(struct neigh_table *tbl)
 {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index e9f3386..5264004 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1120,6 +1120,7 @@ static int arp_invalidate(struct net_device *dev, __be32 ip)
 					   NEIGH_UPDATE_F_OVERRIDE|
 					   NEIGH_UPDATE_F_ADMIN, 0);
 		neigh_release(neigh);
+		neigh_remove_one(neigh, &arp_tbl);
 	}
 
 	return err;
-- 
1.7.1
