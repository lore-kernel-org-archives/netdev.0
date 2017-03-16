From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 4/9] net, ipv6: convert ifmcaddr6.mca_refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:26 +0200
Message-ID: <1489688611-4542-5-git-send-email-elena.reshetova@intel.com>
References: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
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
 include/net/if_inet6.h |  2 +-
 net/ipv6/mcast.c       | 18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 2b41cb8..4bb52ce 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -127,7 +127,7 @@ struct ifmcaddr6 {
 	struct timer_list	mca_timer;
 	unsigned int		mca_flags;
 	int			mca_users;
-	atomic_t		mca_refcnt;
+	refcount_t		mca_refcnt;
 	spinlock_t		mca_lock;
 	unsigned long		mca_cstamp;
 	unsigned long		mca_tstamp;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 1bdc703..0f1dc78 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -701,7 +701,7 @@ static void igmp6_group_dropped(struct ifmcaddr6 *mc)
 
 	spin_lock_bh(&mc->mca_lock);
 	if (del_timer(&mc->mca_timer))
-		atomic_dec(&mc->mca_refcnt);
+		refcount_dec(&mc->mca_refcnt);
 	spin_unlock_bh(&mc->mca_lock);
 }
 
@@ -819,12 +819,12 @@ static void mld_clear_delrec(struct inet6_dev *idev)
 
 static void mca_get(struct ifmcaddr6 *mc)
 {
-	atomic_inc(&mc->mca_refcnt);
+	refcount_inc(&mc->mca_refcnt);
 }
 
 static void ma_put(struct ifmcaddr6 *mc)
 {
-	if (atomic_dec_and_test(&mc->mca_refcnt)) {
+	if (refcount_dec_and_test(&mc->mca_refcnt)) {
 		in6_dev_put(mc->idev);
 		kfree(mc);
 	}
@@ -846,7 +846,7 @@ static struct ifmcaddr6 *mca_alloc(struct inet6_dev *idev,
 	mc->mca_users = 1;
 	/* mca_stamp should be updated upon changes */
 	mc->mca_cstamp = mc->mca_tstamp = jiffies;
-	atomic_set(&mc->mca_refcnt, 1);
+	refcount_set(&mc->mca_refcnt, 1);
 	spin_lock_init(&mc->mca_lock);
 
 	/* initial mode is (EX, empty) */
@@ -1065,7 +1065,7 @@ static void igmp6_group_queried(struct ifmcaddr6 *ma, unsigned long resptime)
 		return;
 
 	if (del_timer(&ma->mca_timer)) {
-		atomic_dec(&ma->mca_refcnt);
+		refcount_dec(&ma->mca_refcnt);
 		delay = ma->mca_timer.expires - jiffies;
 	}
 
@@ -1074,7 +1074,7 @@ static void igmp6_group_queried(struct ifmcaddr6 *ma, unsigned long resptime)
 
 	ma->mca_timer.expires = jiffies + delay;
 	if (!mod_timer(&ma->mca_timer, jiffies + delay))
-		atomic_inc(&ma->mca_refcnt);
+		refcount_inc(&ma->mca_refcnt);
 	ma->mca_flags |= MAF_TIMER_RUNNING;
 }
 
@@ -1469,7 +1469,7 @@ int igmp6_event_report(struct sk_buff *skb)
 		if (ipv6_addr_equal(&ma->mca_addr, &mld->mld_mca)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
-				atomic_dec(&ma->mca_refcnt);
+				refcount_dec(&ma->mca_refcnt);
 			ma->mca_flags &= ~(MAF_LAST_REPORTER|MAF_TIMER_RUNNING);
 			spin_unlock(&ma->mca_lock);
 			break;
@@ -2392,12 +2392,12 @@ static void igmp6_join_group(struct ifmcaddr6 *ma)
 
 	spin_lock_bh(&ma->mca_lock);
 	if (del_timer(&ma->mca_timer)) {
-		atomic_dec(&ma->mca_refcnt);
+		refcount_dec(&ma->mca_refcnt);
 		delay = ma->mca_timer.expires - jiffies;
 	}
 
 	if (!mod_timer(&ma->mca_timer, jiffies + delay))
-		atomic_inc(&ma->mca_refcnt);
+		refcount_inc(&ma->mca_refcnt);
 	ma->mca_flags |= MAF_TIMER_RUNNING | MAF_LAST_REPORTER;
 	spin_unlock_bh(&ma->mca_lock);
 }
-- 
2.7.4
