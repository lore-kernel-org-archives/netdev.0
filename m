From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH V2 net-next] neigh: Really delete an arp/neigh entry on "ip neigh delete" or "arp -d"
Date: Tue, 30 May 2017 14:31:37 -0700
Message-ID: <1496179897-82646-1-git-send-email-sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31398 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbdEaQ6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 12:58:17 -0400
To: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The command
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
the table and free it. This patch refactors and shares common code
between neigh_forced_gc and the newly added neigh_remove_one.

A similar issue exists for IPv6 Neighbor Cache entries, and is fixed
in a similar manner by this patch.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: fix kbuild-test-robot compile error.

 include/net/neighbour.h |    1 +
 net/core/neighbour.c    |   63 ++++++++++++++++++++++++++++++++++++++--------
 net/ipv4/arp.c          |    1 +
 3 files changed, 54 insertions(+), 11 deletions(-)

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
index d274f81..cedab54 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -118,6 +118,55 @@ unsigned long neigh_rand_reach_time(unsigned long base)
 EXPORT_SYMBOL(neigh_rand_reach_time);
 
 
+static bool neigh_del(struct neighbour *n, __u8 state,
+		      struct neighbour __rcu **np, struct neigh_table *tbl)
+{
+	bool retval = false;
+
+	write_lock(&n->lock);
+	if (atomic_read(&n->refcnt) == 1 && !(n->nud_state & state)) {
+		rcu_assign_pointer(*np,
+				   rcu_dereference_protected(n->next,
+				   lockdep_is_held(&tbl->lock)));
+		n->dead = 1;
+		retval = true;
+	}
+	write_unlock(&n->lock);
+	if (retval)
+		neigh_cleanup_and_release(n);
+	return retval;
+}
+
+bool neigh_remove_one(struct neighbour *ndel, struct neigh_table *tbl)
+{
+	struct neigh_hash_table *nht;
+	void *pkey = ndel->primary_key;
+	u32 hash_val;
+	struct neighbour *n;
+	struct neighbour __rcu **np;
+	bool retval = false;
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
+		if (n == ndel) {
+			retval = neigh_del(n, 0, np, tbl);
+			write_unlock_bh(&tbl->lock);
+			return retval;
+		}
+		np = &n->next;
+	}
+	write_unlock_bh(&tbl->lock);
+	return retval;
+}
+EXPORT_SYMBOL(neigh_remove_one);
+
 static int neigh_forced_gc(struct neigh_table *tbl)
 {
 	int shrunk = 0;
@@ -140,19 +189,10 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 			 * - nobody refers to it.
 			 * - it is not permanent
 			 */
-			write_lock(&n->lock);
-			if (atomic_read(&n->refcnt) == 1 &&
-			    !(n->nud_state & NUD_PERMANENT)) {
-				rcu_assign_pointer(*np,
-					rcu_dereference_protected(n->next,
-						  lockdep_is_held(&tbl->lock)));
-				n->dead = 1;
-				shrunk	= 1;
-				write_unlock(&n->lock);
-				neigh_cleanup_and_release(n);
+			if (neigh_del(n, NUD_PERMANENT, np, tbl)) {
+				shrunk = 1;
 				continue;
 			}
-			write_unlock(&n->lock);
 			np = &n->next;
 		}
 	}
@@ -1650,6 +1690,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh,
 			   NEIGH_UPDATE_F_ADMIN,
 			   NETLINK_CB(skb).portid);
 	neigh_release(neigh);
+	neigh_remove_one(neigh, tbl);
 
 out:
 	return err;
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
