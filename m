From: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 27/36] net, xfrm: convert xfrm_policy.refcnt from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:53:22 +0300
Message-ID: <1499172811-16271-28-git-send-email-elena.reshetova@intel.com>
References: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
        kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, 3chas3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
        stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, jchapman-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
        bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
        keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org,
        steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
        santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, jreuter-K7Hl1MveuGQ@public.gmane.org,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hans Li
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1499172811-16271-1-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/xfrm.h     | 6 +++---
 net/key/af_key.c       | 2 +-
 net/xfrm/xfrm_policy.c | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f5272a2..e1bd1de 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -560,7 +560,7 @@ struct xfrm_policy {
 
 	/* This lock only affects elements except for entry. */
 	rwlock_t		lock;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	struct timer_list	timer;
 
 	struct flow_cache_object flo;
@@ -816,14 +816,14 @@ static inline void xfrm_audit_state_icvfail(struct xfrm_state *x,
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 {
 	if (likely(policy != NULL))
-		atomic_inc(&policy->refcnt);
+		refcount_inc(&policy->refcnt);
 }
 
 void xfrm_policy_destroy(struct xfrm_policy *policy);
 
 static inline void xfrm_pol_put(struct xfrm_policy *policy)
 {
-	if (atomic_dec_and_test(&policy->refcnt))
+	if (refcount_dec_and_test(&policy->refcnt))
 		xfrm_policy_destroy(policy);
 }
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index edcf1d0..ca9d3ae 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2177,7 +2177,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	}
 
 	hdr->sadb_msg_len = size / sizeof(uint64_t);
-	hdr->sadb_msg_reserved = atomic_read(&xp->refcnt);
+	hdr->sadb_msg_reserved = refcount_read(&xp->refcnt);
 
 	return 0;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4706df6..ff61d85 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -62,7 +62,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 
 static inline bool xfrm_pol_hold_rcu(struct xfrm_policy *policy)
 {
-	return atomic_inc_not_zero(&policy->refcnt);
+	return refcount_inc_not_zero(&policy->refcnt);
 }
 
 static inline bool
@@ -292,7 +292,7 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
 		rwlock_init(&policy->lock);
-		atomic_set(&policy->refcnt, 1);
+		refcount_set(&policy->refcnt, 1);
 		skb_queue_head_init(&policy->polq.hold_queue);
 		setup_timer(&policy->timer, xfrm_policy_timer,
 				(unsigned long)policy);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
