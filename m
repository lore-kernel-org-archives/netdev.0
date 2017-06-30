From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 02/17] net: convert neighbour.refcnt from atomic_t
	to refcount_t
Date: Fri, 30 Jun 2017 13:07:55 +0300
Message-ID: <1498817290-3368-3-git-send-email-elena.reshetova@intel.com>
References: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
Cc: keescook@chromium.org, peterz@infradead.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, Hans Liljestrand <ishkamiel@gmail.com>,
	kuznet@ms2.inr.ac.ru, kaber@trash.net,
	Elena Reshetova <elena.reshetova@intel.com>,
	David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
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
index 1036c90..31b1bb1 100644
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
index 639b675..e5ee739 100644
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
@@ -410,18 +411,18 @@ static inline struct neigh_parms *neigh_parms_clone(struct neigh_parms *parms)
 
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
index a7e4018..47c36f4 100644
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
index dadb5ee..0c78c8e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -124,7 +124,7 @@ static bool neigh_del(struct neighbour *n, __u8 state,
 	bool retval = false;
 
 	write_lock(&n->lock);
-	if (atomic_read(&n->refcnt) == 1 && !(n->nud_state & state)) {
+	if (refcount_read(&n->refcnt) == 1 && !(n->nud_state & state)) {
 		struct neighbour *neigh;
 
 		neigh = rcu_dereference_protected(n->next,
@@ -254,7 +254,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 			neigh_del_timer(n);
 			n->dead = 1;
 
-			if (atomic_read(&n->refcnt) != 1) {
+			if (refcount_read(&n->refcnt) != 1) {
 				/* The most unpleasant situation.
 				   We must destroy neighbour entry,
 				   but someone still uses it.
@@ -335,7 +335,7 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device
 
 	NEIGH_CACHE_STAT_INC(tbl, allocs);
 	n->tbl		  = tbl;
-	atomic_set(&n->refcnt, 1);
+	refcount_set(&n->refcnt, 1);
 	n->dead		  = 1;
 out:
 	return n;
@@ -444,7 +444,7 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 	rcu_read_lock_bh();
 	n = __neigh_lookup_noref(tbl, pkey, dev);
 	if (n) {
-		if (!atomic_inc_not_zero(&n->refcnt))
+		if (!refcount_inc_not_zero(&n->refcnt))
 			n = NULL;
 		NEIGH_CACHE_STAT_INC(tbl, hits);
 	}
@@ -473,7 +473,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	     n = rcu_dereference_bh(n->next)) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
 		    net_eq(dev_net(n->dev), net)) {
-			if (!atomic_inc_not_zero(&n->refcnt))
+			if (!refcount_inc_not_zero(&n->refcnt))
 				n = NULL;
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
@@ -821,7 +821,7 @@ static void neigh_periodic_work(struct work_struct *work)
 			if (time_before(n->used, n->confirmed))
 				n->used = n->confirmed;
 
-			if (atomic_read(&n->refcnt) == 1 &&
+			if (refcount_read(&n->refcnt) == 1 &&
 			    (state == NUD_FAILED ||
 			     time_after(jiffies, n->used + NEIGH_VAR(n->parms, GC_STALETIME)))) {
 				*np = n->next;
@@ -2234,7 +2234,7 @@ static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
 	ci.ndm_used	 = jiffies_to_clock_t(now - neigh->used);
 	ci.ndm_confirmed = jiffies_to_clock_t(now - neigh->confirmed);
 	ci.ndm_updated	 = jiffies_to_clock_t(now - neigh->updated);
-	ci.ndm_refcnt	 = atomic_read(&neigh->refcnt) - 1;
+	ci.ndm_refcnt	 = refcount_read(&neigh->refcnt) - 1;
 	read_unlock_bh(&neigh->lock);
 
 	if (nla_put_u32(skb, NDA_PROBES, atomic_read(&neigh->probes)) ||
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index eeb5fc5..21dedf6 100644
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
