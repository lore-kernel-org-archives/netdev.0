From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 01/17] net: convert neighbour.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:28:51 +0200
Message-ID: <1489678147-21404-2-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/arp.h       |  2 +-
 include/net/ndisc.h     |  2 +-
 include/net/neighbour.h |  9 +++++----
 net/atm/clip.c          |  6 +++---
 net/core/neighbour.c    | 14 +++++++-------
 net/decnet/dn_neigh.c   |  2 +-
 6 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 65619a2..17d90e4 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -28,7 +28,7 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32
 
 	rcu_read_lock_bh();
 	n = __ipv4_neigh_lookup_noref(dev, key);
-	if (n && !atomic_inc_not_zero(&n->refcnt))
+	if (n && !refcount_inc_not_zero(&n->refcnt))
 		n = NULL;
 	rcu_read_unlock_bh();
 
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 8a02146..54062c1 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -384,7 +384,7 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
 
 	rcu_read_lock_bh();
 	n = __ipv6_neigh_lookup_noref(dev, pkey);
-	if (n && !atomic_inc_not_zero(&n->refcnt))
+	if (n && !refcount_inc_not_zero(&n->refcnt))
 		n = NULL;
 	rcu_read_unlock_bh();
 
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 5ebf694..9a66cfc9 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -17,6 +17,7 @@
  */
 
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rcupdate.h>
@@ -137,7 +138,7 @@ struct neighbour {
 	unsigned long		confirmed;
 	unsigned long		updated;
 	rwlock_t		lock;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	struct sk_buff_head	arp_queue;
 	unsigned int		arp_queue_len_bytes;
 	struct timer_list	timer;
@@ -408,18 +409,18 @@ static inline struct neigh_parms *neigh_parms_clone(struct neigh_parms *parms)
 
 static inline void neigh_release(struct neighbour *neigh)
 {
-	if (atomic_dec_and_test(&neigh->refcnt))
+	if (refcount_dec_and_test(&neigh->refcnt))
 		neigh_destroy(neigh);
 }
 
 static inline struct neighbour * neigh_clone(struct neighbour *neigh)
 {
 	if (neigh)
-		atomic_inc(&neigh->refcnt);
+		refcount_inc(&neigh->refcnt);
 	return neigh;
 }
 
-#define neigh_hold(n)	atomic_inc(&(n)->refcnt)
+#define neigh_hold(n)	refcount_inc(&(n)->refcnt)
 
 static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 53b4ac0..33e0940 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -137,11 +137,11 @@ static int neigh_check_cb(struct neighbour *n)
 	if (entry->vccs || time_before(jiffies, entry->expires))
 		return 0;
 
-	if (atomic_read(&n->refcnt) > 1) {
+	if (refcount_read(&n->refcnt) > 1) {
 		struct sk_buff *skb;
 
 		pr_debug("destruction postponed with ref %d\n",
-			 atomic_read(&n->refcnt));
+			 refcount_read(&n->refcnt));
 
 		while ((skb = skb_dequeue(&n->arp_queue)) != NULL)
 			dev_kfree_skb(skb);
@@ -767,7 +767,7 @@ static void atmarp_info(struct seq_file *seq, struct neighbour *n,
 			seq_printf(seq, "(resolving)\n");
 		else
 			seq_printf(seq, "(expired, ref %d)\n",
-				   atomic_read(&entry->neigh->refcnt));
+				   refcount_read(&entry->neigh->refcnt));
 	} else if (!svc) {
 		seq_printf(seq, "%d.%d.%d\n",
 			   clip_vcc->vcc->dev->number,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e7c12ca..36f8008 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -140,7 +140,7 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 			 * - it is not permanent
 			 */
 			write_lock(&n->lock);
-			if (atomic_read(&n->refcnt) == 1 &&
+			if (refcount_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT)) {
 				rcu_assign_pointer(*np,
 					rcu_dereference_protected(n->next,
@@ -218,7 +218,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 			neigh_del_timer(n);
 			n->dead = 1;
 
-			if (atomic_read(&n->refcnt) != 1) {
+			if (refcount_read(&n->refcnt) != 1) {
 				/* The most unpleasant situation.
 				   We must destroy neighbour entry,
 				   but someone still uses it.
@@ -299,7 +299,7 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device
 
 	NEIGH_CACHE_STAT_INC(tbl, allocs);
 	n->tbl		  = tbl;
-	atomic_set(&n->refcnt, 1);
+	refcount_set(&n->refcnt, 1);
 	n->dead		  = 1;
 out:
 	return n;
@@ -408,7 +408,7 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 	rcu_read_lock_bh();
 	n = __neigh_lookup_noref(tbl, pkey, dev);
 	if (n) {
-		if (!atomic_inc_not_zero(&n->refcnt))
+		if (!refcount_inc_not_zero(&n->refcnt))
 			n = NULL;
 		NEIGH_CACHE_STAT_INC(tbl, hits);
 	}
@@ -437,7 +437,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	     n = rcu_dereference_bh(n->next)) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
 		    net_eq(dev_net(n->dev), net)) {
-			if (!atomic_inc_not_zero(&n->refcnt))
+			if (!refcount_inc_not_zero(&n->refcnt))
 				n = NULL;
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
@@ -785,7 +785,7 @@ static void neigh_periodic_work(struct work_struct *work)
 			if (time_before(n->used, n->confirmed))
 				n->used = n->confirmed;
 
-			if (atomic_read(&n->refcnt) == 1 &&
+			if (refcount_read(&n->refcnt) == 1 &&
 			    (state == NUD_FAILED ||
 			     time_after(jiffies, n->used + NEIGH_VAR(n->parms, GC_STALETIME)))) {
 				*np = n->next;
@@ -2183,7 +2183,7 @@ static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
 	ci.ndm_used	 = jiffies_to_clock_t(now - neigh->used);
 	ci.ndm_confirmed = jiffies_to_clock_t(now - neigh->confirmed);
 	ci.ndm_updated	 = jiffies_to_clock_t(now - neigh->updated);
-	ci.ndm_refcnt	 = atomic_read(&neigh->refcnt) - 1;
+	ci.ndm_refcnt	 = refcount_read(&neigh->refcnt) - 1;
 	read_unlock_bh(&neigh->lock);
 
 	if (nla_put_u32(skb, NDA_PROBES, atomic_read(&neigh->probes)) ||
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 482730c..d8f7b6d 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -559,7 +559,7 @@ static inline void dn_neigh_format_entry(struct seq_file *seq,
 		   (dn->flags&DN_NDFLAG_R2) ? "2" : "-",
 		   (dn->flags&DN_NDFLAG_P3) ? "3" : "-",
 		   dn->n.nud_state,
-		   atomic_read(&dn->n.refcnt),
+		   refcount_read(&dn->n.refcnt),
 		   dn->blksize,
 		   (dn->n.dev) ? dn->n.dev->name : "?");
 	read_unlock(&n->lock);
-- 
2.7.4
