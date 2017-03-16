From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 09/17] net: convert ip_mc_list.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:28:59 +0200
Message-ID: <1489678147-21404-10-git-send-email-elena.reshetova@intel.com>
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
 include/linux/igmp.h |  3 ++-
 net/ipv4/igmp.c      | 10 +++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 12f6fba..97caf18 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -18,6 +18,7 @@
 #include <linux/skbuff.h>
 #include <linux/timer.h>
 #include <linux/in.h>
+#include <linux/refcount.h>
 #include <uapi/linux/igmp.h>
 
 static inline struct igmphdr *igmp_hdr(const struct sk_buff *skb)
@@ -84,7 +85,7 @@ struct ip_mc_list {
 	struct ip_mc_list __rcu *next_hash;
 	struct timer_list	timer;
 	int			users;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	spinlock_t		lock;
 	char			tm_running;
 	char			reporter;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 44fd86d..0ed4f7b 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -173,7 +173,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 
 static void ip_ma_put(struct ip_mc_list *im)
 {
-	if (atomic_dec_and_test(&im->refcnt)) {
+	if (refcount_dec_and_test(&im->refcnt)) {
 		in_dev_put(im->interface);
 		kfree_rcu(im, rcu);
 	}
@@ -199,7 +199,7 @@ static void igmp_stop_timer(struct ip_mc_list *im)
 {
 	spin_lock_bh(&im->lock);
 	if (del_timer(&im->timer))
-		atomic_dec(&im->refcnt);
+		refcount_dec(&im->refcnt);
 	im->tm_running = 0;
 	im->reporter = 0;
 	im->unsolicit_count = 0;
@@ -213,7 +213,7 @@ static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
 
 	im->tm_running = 1;
 	if (!mod_timer(&im->timer, jiffies+tv+2))
-		atomic_inc(&im->refcnt);
+		refcount_inc(&im->refcnt);
 }
 
 static void igmp_gq_start_timer(struct in_device *in_dev)
@@ -249,7 +249,7 @@ static void igmp_mod_timer(struct ip_mc_list *im, int max_delay)
 			spin_unlock_bh(&im->lock);
 			return;
 		}
-		atomic_dec(&im->refcnt);
+		refcount_dec(&im->refcnt);
 	}
 	igmp_start_timer(im, max_delay);
 	spin_unlock_bh(&im->lock);
@@ -1373,7 +1373,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	/* initial mode is (EX, empty) */
 	im->sfmode = MCAST_EXCLUDE;
 	im->sfcount[MCAST_EXCLUDE] = 1;
-	atomic_set(&im->refcnt, 1);
+	refcount_set(&im->refcnt, 1);
 	spin_lock_init(&im->lock);
 #ifdef CONFIG_IP_MULTICAST
 	setup_timer(&im->timer, igmp_timer_expire, (unsigned long)im);
-- 
2.7.4
