From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: [NET]: gen_estimator deadlock fix
Date: Wed, 11 Jul 2007 16:41:37 +0300
Message-ID: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Jarek Poplawski <jarkao2@o2.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:24137 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762998AbXGKNmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 09:42:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes ABBA deadlock noted by Patrick McHardy <kaber@trash.net>:
> There is at least one ABBA deadlock, est_timer() does:
> read_lock(&est_lock)
> spin_lock(e->stats_lock) (which is dev->queue_lock)
> 
> and qdisc_destroy calls htb_destroy under dev->queue_lock, which
> calls htb_destroy_class, then gen_kill_estimator and this
> write_locks est_lock.

est_lock completely removed and the RCU list implemented instead.
Both gen_kill_estimator and gen_new_estimator are already called under
rtnl_mutex.

Signed-off-by: Ranko Zivojnovic <ranko@spidernet.net>
---
 net/core/gen_estimator.c |   73 ++++++++++++++++++++++++----------------------
 1 files changed, 38 insertions(+), 35 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cc84d8d..444b2bd 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -79,7 +79,7 @@

 struct gen_estimator
 {
-       struct gen_estimator    *next;
+       struct list_head        list;
        struct gnet_stats_basic *bstats;
        struct gnet_stats_rate_est      *rate_est;
        spinlock_t              *stats_lock;
@@ -89,26 +89,24 @@ struct gen_estimator
        u32                     last_packets;
        u32                     avpps;
        u32                     avbps;
+       struct rcu_head         e_rcu;
 };

 struct gen_estimator_head
 {
        struct timer_list       timer;
-       struct gen_estimator    *list;
+       struct list_head        list;
 };

 static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];

-/* Estimator array lock */
-static DEFINE_RWLOCK(est_lock);
-
 static void est_timer(unsigned long arg)
 {
        int idx = (int)arg;
        struct gen_estimator *e;

-       read_lock(&est_lock);
-       for (e = elist[idx].list; e; e = e->next) {
+       rcu_read_lock();
+       list_for_each_entry_rcu(e, &elist[idx].list, list) {
                u64 nbytes;
                u32 npackets;
                u32 rate;
@@ -128,9 +126,9 @@ static void est_timer(unsigned long arg)
                spin_unlock(e->stats_lock);
        }

-       if (elist[idx].list != NULL)
+       if (!list_empty(&elist[idx].list))
                mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
-       read_unlock(&est_lock);
+       rcu_read_unlock();
 }

 /**
@@ -147,12 +145,15 @@ static void est_timer(unsigned long arg)
  * &rate_est with the statistics lock grabed during this period.
  *
  * Returns 0 on success or a negative error code.
+ *
+ * NOTE: Called under rtnl_mutex
  */
 int gen_new_estimator(struct gnet_stats_basic *bstats,
        struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock, struct rtattr *opt)
 {
        struct gen_estimator *est;
        struct gnet_estimator *parm = RTA_DATA(opt);
+       int idx;

        if (RTA_PAYLOAD(opt) < sizeof(*parm))
                return -EINVAL;
@@ -164,7 +165,7 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
        if (est == NULL)
                return -ENOBUFS;

-       est->interval = parm->interval + 2;
+       est->interval = idx = parm->interval + 2;
        est->bstats = bstats;
        est->rate_est = rate_est;
        est->stats_lock = stats_lock;
@@ -174,20 +175,25 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
        est->last_packets = bstats->packets;
        est->avpps = rate_est->pps<<10;

-       est->next = elist[est->interval].list;
-       if (est->next == NULL) {
-               init_timer(&elist[est->interval].timer);
-               elist[est->interval].timer.data = est->interval;
-               elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
-               elist[est->interval].timer.function = est_timer;
-               add_timer(&elist[est->interval].timer);
+       if (!elist[idx].timer.function) {
+               INIT_LIST_HEAD(&elist[idx].list);
+               setup_timer(&elist[idx].timer, est_timer, est->interval);
        }
-       write_lock_bh(&est_lock);
-       elist[est->interval].list = est;
-       write_unlock_bh(&est_lock);
+
+       if (list_empty(&elist[idx].list))
+               mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+
+       list_add_rcu(&est->list, &elist[idx].list);
        return 0;
 }

+static void __gen_kill_estimator(struct rcu_head *head)
+{
+       struct gen_estimator *e = container_of(head,
+                                       struct gen_estimator, e_rcu);
+       kfree(e);
+}
+
 /**
  * gen_kill_estimator - remove a rate estimator
  * @bstats: basic statistics
@@ -195,31 +201,28 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
  *
  * Removes the rate estimator specified by &bstats and &rate_est
  * and deletes the timer.
+ *
+ * NOTE: Called under rtnl_mutex
  */
 void gen_kill_estimator(struct gnet_stats_basic *bstats,
        struct gnet_stats_rate_est *rate_est)
 {
        int idx;
-       struct gen_estimator *est, **pest;
+       struct gen_estimator *e, *n;

        for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-               int killed = 0;
-               pest = &elist[idx].list;
-               while ((est=*pest) != NULL) {
-                       if (est->rate_est != rate_est || est->bstats != bstats) {
-                               pest = &est->next;
-                               continue;
-                       }

-                       write_lock_bh(&est_lock);
-                       *pest = est->next;
-                       write_unlock_bh(&est_lock);
+               /* Skip non initialized indexes */
+               if (!elist[idx].timer.function)
+                       continue;
+
+               list_for_each_entry_safe(e, n, &elist[idx].list, list) {
+                       if (e->rate_est != rate_est || e->bstats != bstats)
+                               continue;

-                       kfree(est);
-                       killed++;
+                       list_del_rcu(&e->list);
+                       call_rcu(&e->e_rcu, __gen_kill_estimator);
                }
-               if (killed && elist[idx].list == NULL)
-                       del_timer(&elist[idx].timer);
        }
 }



