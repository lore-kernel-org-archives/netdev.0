From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 2/5]: refcount qdisc->dev
Date: Tue, 03 Aug 2004 17:22:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FADBC.6000904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040702070608010202030705"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040702070608010202030705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds refcounting for qdisc->dev to avoid accessing freed memory
from the __qdisc_destroy rcu-callback when the device is unregistered. 
Without
refcounting netdev_wait_allrefs could free the device before __qdisc_destroy
is done.


--------------040702070608010202030705
Content-Type: text/x-patch;
 name="02-refcount-qdisc-dev.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02-refcount-qdisc-dev.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/02 23:50:01+02:00 kaber@coreworks.de 
#   [PKT_SCHED: Refcount qdisc->dev for __qdisc_destroy rcu-callback
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/08/02 23:49:40+02:00 kaber@coreworks.de +3 -0
#   [PKT_SCHED: Refcount qdisc->dev for __qdisc_destroy rcu-callback
# 
# net/sched/sch_api.c
#   2004/08/02 23:49:40+02:00 kaber@coreworks.de +1 -0
#   [PKT_SCHED: Refcount qdisc->dev for __qdisc_destroy rcu-callback
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-03 01:10:18 +02:00
+++ b/net/sched/sch_api.c	2004-08-03 01:10:18 +02:00
@@ -430,6 +430,7 @@
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
 	sch->dev = dev;
+	dev_hold(dev);
 	atomic_set(&sch->refcnt, 1);
 	sch->stats_lock = &dev->queue_lock;
 	if (handle == 0) {
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-08-03 01:10:18 +02:00
+++ b/net/sched/sch_generic.c	2004-08-03 01:10:18 +02:00
@@ -399,6 +399,7 @@
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
 	sch->dev = dev;
+	dev_hold(dev);
 	sch->stats_lock = &dev->queue_lock;
 	atomic_set(&sch->refcnt, 1);
 	/* enqueue is accessed locklessly - make sure it's visible
@@ -440,6 +441,8 @@
 	write_unlock(&qdisc_tree_lock);
 	module_put(ops->owner);
 
+	if (qdisc->dev)
+		dev_put(qdisc->dev);
 	if (!(qdisc->flags&TCQ_F_BUILTIN))
 		kfree(qdisc);
 }

--------------040702070608010202030705--
