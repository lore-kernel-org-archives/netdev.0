From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] net: core: neighbour: Replace rcu_assign_pointer() with
 RCU_INIT_POINTER()
Date: Tue, 26 Aug 2014 17:27:02 +0300
Message-ID: <20140826142702.GA2346@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: davem@davemloft.net, jiri@resnulli.us, hannes@stressinduktion.org,
	duanj.fnst@cn.fujitsu.com, ebiederm@xmission.com,
	aruna.hewapathirane@gmail.com, tim.gardner@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to RCU_INIT_POINTER()'s block comment 3.a, it can be used if
"3.   The referenced data structure has already been exposed to readers either
at compile time or via rcu_assign_pointer() -and-
 a.   You have not made -any- reader-visible changes to this structure since
then".

These cases fulfill the conditions above because between the
rcu_dereference_protected() calls and the rcu_assign_pointer() calls there is
no update of those values.
Therefore, this patch makes the replacements.

The following Coccinelle semantic patch was used:
@@
@@

- rcu_assign_pointer
+ RCU_INIT_POINTER
  (...,
(
 rtnl_dereference(...)
|
 rcu_dereference_protected(...)
) )

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 net/core/neighbour.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 32d872e..a193932 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -147,7 +147,7 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 			write_lock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT)) {
-				rcu_assign_pointer(*np,
+				RCU_INIT_POINTER(*np,
 					rcu_dereference_protected(n->next,
 						  lockdep_is_held(&tbl->lock)));
 				n->dead = 1;
@@ -216,7 +216,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 				np = &n->next;
 				continue;
 			}
-			rcu_assign_pointer(*np,
+			RCU_INIT_POINTER(*np,
 				   rcu_dereference_protected(n->next,
 						lockdep_is_held(&tbl->lock)));
 			write_lock(&n->lock);
@@ -386,7 +386,7 @@ static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
 			next = rcu_dereference_protected(n->next,
 						lockdep_is_held(&tbl->lock));
 
-			rcu_assign_pointer(n->next,
+			RCU_INIT_POINTER(n->next,
 					   rcu_dereference_protected(
 						new_nht->hash_buckets[hash],
 						lockdep_is_held(&tbl->lock)));
@@ -531,7 +531,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 	n->dead = 0;
 	if (want_ref)
 		neigh_hold(n);
-	rcu_assign_pointer(n->next,
+	RCU_INIT_POINTER(n->next,
 			   rcu_dereference_protected(nht->hash_buckets[hash_val],
 						     lockdep_is_held(&tbl->lock)));
 	rcu_assign_pointer(nht->hash_buckets[hash_val], n);
@@ -2432,7 +2432,7 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 			write_lock(&n->lock);
 			release = cb(n);
 			if (release) {
-				rcu_assign_pointer(*np,
+				RCU_INIT_POINTER(*np,
 					rcu_dereference_protected(n->next,
 						lockdep_is_held(&tbl->lock)));
 				n->dead = 1;
-- 
1.9.1
