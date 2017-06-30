From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 09/17] net: convert ip_mc_list.refcnt from atomic_t
	to refcount_t
Date: Fri, 30 Jun 2017 13:08:02 +0300
Message-ID: <1498817290-3368-10-git-send-email-elena.reshetova@intel.com>
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
index c403230..28f14af 100644
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
@@ -1374,7 +1374,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
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
