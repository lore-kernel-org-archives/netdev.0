From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH net-next-2.6 v3] net: factorize sync-rcu call in unregister_netdevice_many
Date: Tue, 14 Dec 2010 00:44:07 +0200
Message-ID: <1292280247-9889-1-git-send-email-opurdila@ixiacom.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:26045 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753551Ab0LMWoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 17:44:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dev_close_many and dev_deactivate_many to factorize another
sync-rcu operation on the netdevice unregister path.

$ modprobe dummy numdummies=10000
$ ip link set dev dummy* up
$ time rmmod dummy

Without the patch           With the patch

real    0m 24.63s           real    0m 5.15s
user    0m 0.00s            user    0m 0.00s
sys     0m 6.05s            sys     0m 5.14s

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---

Changes from v2:

* don't delete entries from dev_close_many otherwise rollback_registered_many
will not complete the cleanup for the deleted entries

Changes from v1:

* move ASSERT_RTNL() and might_sleep() out of the loop


 include/net/sch_generic.h |    1 +
 net/core/dev.c            |  118 +++++++++++++++++++++++++++++----------------
 net/sched/sch_generic.c   |   29 ++++++++---
 3 files changed, 99 insertions(+), 49 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ea1f8a8..786cc39 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -321,6 +321,7 @@ extern void dev_init_scheduler(struct net_device *dev);
 extern void dev_shutdown(struct net_device *dev);
 extern void dev_activate(struct net_device *dev);
 extern void dev_deactivate(struct net_device *dev);
+extern void dev_deactivate_many(struct list_head *head);
 extern struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 				     struct Qdisc *qdisc);
 extern void qdisc_reset(struct Qdisc *qdisc);
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..33296ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1222,52 +1222,90 @@ int dev_open(struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_open);
 
-static int __dev_close(struct net_device *dev)
+static int __dev_close_many(struct list_head *head)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
+	struct net_device *dev;
 
 	ASSERT_RTNL();
 	might_sleep();
 
-	/*
-	 *	Tell people we are going down, so that they can
-	 *	prepare to death, when device is still operating.
-	 */
-	call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
+	list_for_each_entry(dev, head, unreg_list) {
+		/*
+		 *	Tell people we are going down, so that they can
+		 *	prepare to death, when device is still operating.
+		 */
+		call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
 
-	clear_bit(__LINK_STATE_START, &dev->state);
+		clear_bit(__LINK_STATE_START, &dev->state);
 
-	/* Synchronize to scheduled poll. We cannot touch poll list,
-	 * it can be even on different cpu. So just clear netif_running().
-	 *
-	 * dev->stop() will invoke napi_disable() on all of it's
-	 * napi_struct instances on this device.
-	 */
-	smp_mb__after_clear_bit(); /* Commit netif_running(). */
+		/* Synchronize to scheduled poll. We cannot touch poll list, it
+		 * can be even on different cpu. So just clear netif_running().
+		 *
+		 * dev->stop() will invoke napi_disable() on all of it's
+		 * napi_struct instances on this device.
+		 */
+		smp_mb__after_clear_bit(); /* Commit netif_running(). */
+	}
 
-	dev_deactivate(dev);
+	dev_deactivate_many(head);
 
-	/*
-	 *	Call the device specific close. This cannot fail.
-	 *	Only if device is UP
-	 *
-	 *	We allow it to be called even after a DETACH hot-plug
-	 *	event.
-	 */
-	if (ops->ndo_stop)
-		ops->ndo_stop(dev);
+	list_for_each_entry(dev, head, unreg_list) {
+		const struct net_device_ops *ops = dev->netdev_ops;
 
-	/*
-	 *	Device is now down.
-	 */
+		/*
+		 *	Call the device specific close. This cannot fail.
+		 *	Only if device is UP
+		 *
+		 *	We allow it to be called even after a DETACH hot-plug
+		 *	event.
+		 */
+		if (ops->ndo_stop)
+			ops->ndo_stop(dev);
+
+		/*
+		 *	Device is now down.
+		 */
+
+		dev->flags &= ~IFF_UP;
+
+		/*
+		 *	Shutdown NET_DMA
+		 */
+		net_dmaengine_put();
+	}
 
-	dev->flags &= ~IFF_UP;
+	return 0;
+}
+
+static int __dev_close(struct net_device *dev)
+{
+	LIST_HEAD(single);
+
+	list_add(&dev->unreg_list, &single);
+	return __dev_close_many(&single);
+}
+
+int dev_close_many(struct list_head *head)
+{
+	struct net_device *dev, *tmp;
+	LIST_HEAD(tmp_list);
+
+	list_for_each_entry_safe(dev, tmp, head, unreg_list)
+		if (!(dev->flags & IFF_UP))
+			list_move(&dev->unreg_list, &tmp_list);
+
+	__dev_close_many(head);
 
 	/*
-	 *	Shutdown NET_DMA
+	 * Tell people we are down
 	 */
-	net_dmaengine_put();
+	list_for_each_entry(dev, head, unreg_list) {
+		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
+		call_netdevice_notifiers(NETDEV_DOWN, dev);
+	}
 
+	/* rollback_registered_many needs the complete original list */
+	list_splice(&tmp_list, head);
 	return 0;
 }
 
@@ -1282,16 +1320,10 @@ static int __dev_close(struct net_device *dev)
  */
 int dev_close(struct net_device *dev)
 {
-	if (!(dev->flags & IFF_UP))
-		return 0;
-
-	__dev_close(dev);
+	LIST_HEAD(single);
 
-	/*
-	 * Tell people we are down
-	 */
-	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
-	call_netdevice_notifiers(NETDEV_DOWN, dev);
+	list_add(&dev->unreg_list, &single);
+	dev_close_many(&single);
 
 	return 0;
 }
@@ -4958,10 +4990,12 @@ static void rollback_registered_many(struct list_head *head)
 		}
 
 		BUG_ON(dev->reg_state != NETREG_REGISTERED);
+	}
 
-		/* If device is running, close it first. */
-		dev_close(dev);
+	/* If device is running, close it first. */
+	dev_close_many(head);
 
+	list_for_each_entry(dev, head, unreg_list) {
 		/* And unlink it from device chain. */
 		unlist_netdevice(dev);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0918834..34dc598 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -810,20 +810,35 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 	return false;
 }
 
-void dev_deactivate(struct net_device *dev)
+void dev_deactivate_many(struct list_head *head)
 {
-	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
-	if (dev_ingress_queue(dev))
-		dev_deactivate_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
+	struct net_device *dev;
 
-	dev_watchdog_down(dev);
+	list_for_each_entry(dev, head, unreg_list) {
+		netdev_for_each_tx_queue(dev, dev_deactivate_queue,
+					 &noop_qdisc);
+		if (dev_ingress_queue(dev))
+			dev_deactivate_queue(dev, dev_ingress_queue(dev),
+					     &noop_qdisc);
+
+		dev_watchdog_down(dev);
+	}
 
 	/* Wait for outstanding qdisc-less dev_queue_xmit calls. */
 	synchronize_rcu();
 
 	/* Wait for outstanding qdisc_run calls. */
-	while (some_qdisc_is_busy(dev))
-		yield();
+	list_for_each_entry(dev, head, unreg_list)
+		while (some_qdisc_is_busy(dev))
+			yield();
+}
+
+void dev_deactivate(struct net_device *dev)
+{
+	LIST_HEAD(single);
+
+	list_add(&dev->unreg_list, &single);
+	dev_deactivate_many(&single);
 }
 
 static void dev_init_scheduler_queue(struct net_device *dev,
-- 
1.7.1

