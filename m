From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 02/17] net: convert neigh_params.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:28:52 +0200
Message-ID: <1489678147-21404-3-git-send-email-elena.reshetova@intel.com>
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
 include/net/neighbour.h | 6 +++---
 net/core/neighbour.c    | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 9a66cfc9..d2eab49 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -77,7 +77,7 @@ struct neigh_parms {
 	void	*sysctl_table;
 
 	int dead;
-	atomic_t refcnt;
+	refcount_t refcnt;
 	struct rcu_head rcu_head;
 
 	int	reachable_time;
@@ -394,12 +394,12 @@ void neigh_sysctl_unregister(struct neigh_parms *p);
 
 static inline void __neigh_parms_put(struct neigh_parms *parms)
 {
-	atomic_dec(&parms->refcnt);
+	refcount_dec(&parms->refcnt);
 }
 
 static inline struct neigh_parms *neigh_parms_clone(struct neigh_parms *parms)
 {
-	atomic_inc(&parms->refcnt);
+	refcount_inc(&parms->refcnt);
 	return parms;
 }
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 36f8008..9b38acd 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -673,7 +673,7 @@ static void neigh_parms_destroy(struct neigh_parms *parms);
 
 static inline void neigh_parms_put(struct neigh_parms *parms)
 {
-	if (atomic_dec_and_test(&parms->refcnt))
+	if (refcount_dec_and_test(&parms->refcnt))
 		neigh_parms_destroy(parms);
 }
 
@@ -1436,7 +1436,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 	p = kmemdup(&tbl->parms, sizeof(*p), GFP_KERNEL);
 	if (p) {
 		p->tbl		  = tbl;
-		atomic_set(&p->refcnt, 1);
+		refcount_set(&p->refcnt, 1);
 		p->reachable_time =
 				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 		dev_hold(dev);
@@ -1499,7 +1499,7 @@ void neigh_table_init(int index, struct neigh_table *tbl)
 	INIT_LIST_HEAD(&tbl->parms_list);
 	list_add(&tbl->parms.list, &tbl->parms_list);
 	write_pnet(&tbl->parms.net, &init_net);
-	atomic_set(&tbl->parms.refcnt, 1);
+	refcount_set(&tbl->parms.refcnt, 1);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(NEIGH_VAR(&tbl->parms, BASE_REACHABLE_TIME));
 
@@ -1746,7 +1746,7 @@ static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
 
 	if ((parms->dev &&
 	     nla_put_u32(skb, NDTPA_IFINDEX, parms->dev->ifindex)) ||
-	    nla_put_u32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt)) ||
+	    nla_put_u32(skb, NDTPA_REFCNT, refcount_read(&parms->refcnt)) ||
 	    nla_put_u32(skb, NDTPA_QUEUE_LENBYTES,
 			NEIGH_VAR(parms, QUEUE_LEN_BYTES)) ||
 	    /* approximative value for deprecated QUEUE_LEN (in packets) */
-- 
2.7.4
