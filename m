From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 PKT_SCHED]: Fix rcu_assign_pointer fallout, use it in
 the right place
Date: Fri, 05 Nov 2004 22:45:46 +0100
Message-ID: <418BF48A.5060707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010107060405000301040302"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010107060405000301040302
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

The patch "RCU: use rcu_assign_pointer()" 
http://linux.bkbits.net:8080/linux-2.6/diffs/net/sched/sch_api.c@1.39?nav=index.html|src/net/|src/net|src/net/sched|related/net/sched/sch_api.c|cset@1.2287
changed a list_add_tail to list_add_tail_rcu in qdisc_create. It's
dev->qdisc not dev->qdisc_list that is protected by RCU, this patch
reverts that change. It also removes a misleading comment and replaces
the smp_wmb in qdisc_create_dflt by rcu_assign_pointer in dev_activate
to document more clearly what is protected.

Regards
Patrick







--------------010107060405000301040302
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/05 22:14:18+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix rcu_assign_pointer fallout, use it in the right place
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/11/05 22:14:08+01:00 kaber@coreworks.de +5 -7
#   [PKT_SCHED]: Fix rcu_assign_pointer fallout, use it in the right place
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_api.c
#   2004/11/05 22:14:08+01:00 kaber@coreworks.de +2 -4
#   [PKT_SCHED]: Fix rcu_assign_pointer fallout, use it in the right place
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-11-05 22:29:06 +01:00
+++ b/net/sched/sch_api.c	2004-11-05 22:29:06 +01:00
@@ -451,11 +451,9 @@
         else
                 sch->handle = handle;
 
-	/* enqueue is accessed locklessly - make sure it's visible
-	 * before we set a netdevice's qdisc pointer to sch */
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
 		qdisc_lock_tree(dev);
-		list_add_tail_rcu(&sch->list, &dev->qdisc_list);
+		list_add_tail(&sch->list, &dev->qdisc_list);
 		qdisc_unlock_tree(dev);
 
 #ifdef CONFIG_NET_ESTIMATOR
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-11-05 22:29:06 +01:00
+++ b/net/sched/sch_generic.c	2004-11-05 22:29:06 +01:00
@@ -436,9 +436,6 @@
 	dev_hold(dev);
 	sch->stats_lock = &dev->queue_lock;
 	atomic_set(&sch->refcnt, 1);
-	/* enqueue is accessed locklessly - make sure it's visible
-	 * before we set a netdevice's qdisc pointer to sch */
-	smp_wmb();
 	if (!ops->init || ops->init(sch, NULL) == 0)
 		return sch;
 
@@ -519,7 +516,8 @@
 	}
 
 	spin_lock_bh(&dev->queue_lock);
-	if ((dev->qdisc = dev->qdisc_sleeping) != &noqueue_qdisc) {
+	rcu_assign_pointer(dev->qdisc, dev->qdisc_sleeping);
+	if (dev->qdisc != &noqueue_qdisc) {
 		dev->trans_start = jiffies;
 		dev_watchdog_up(dev);
 	}

--------------010107060405000301040302--
