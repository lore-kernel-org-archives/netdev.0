From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Separate the close_list and the unreg_list v2
Date: Sat, 05 Oct 2013 19:26:05 -0700
Message-ID: <87txgv9ltu.fsf@xmission.com>
References: <5250c0b6.45dc420a.738b.6a58@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40148 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab3JFC0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 22:26:18 -0400
In-Reply-To: <5250c0b6.45dc420a.738b.6a58@mx.google.com> (Francesco Ruggeri's
	message of "Sat, 5 Oct 2013 06:18:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Separate the unreg_list and the close_list in dev_close_many preventing
dev_close_many from permuting the unreg_list.  The permutations of the
unreg_list have resulted in cases where the loopback device is accessed
it has been freed in code such as dst_ifdown.  Resulting in subtle memory
corruption.

This is the second bug from sharing the storage between the close_list
and the unreg_list.  The issues that crop up with sharing are
apparently too subtle to show up in normal testing or usage, so let's
forget about being clever and use two separate lists.

v2: Make all callers pass in a close_list to dev_close_many

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

Sending the complete diff because this version is actually more
readable and more obviously correct.

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   25 ++++++++++++++-----------
 net/sched/sch_generic.c   |    6 +++---
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f5cd464271bf..6d77e0f3cc10 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1143,6 +1143,7 @@ struct net_device {
 	struct list_head	dev_list;
 	struct list_head	napi_list;
 	struct list_head	unreg_list;
+	struct list_head	close_list;
 
 	/* directly linked devices, like slaves for bonding */
 	struct {
diff --git a/net/core/dev.c b/net/core/dev.c
index c25db20a4246..fa0b2b06c1a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1307,7 +1307,7 @@ static int __dev_close_many(struct list_head *head)
 	ASSERT_RTNL();
 	might_sleep();
 
-	list_for_each_entry(dev, head, unreg_list) {
+	list_for_each_entry(dev, head, close_list) {
 		call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
 
 		clear_bit(__LINK_STATE_START, &dev->state);
@@ -1323,7 +1323,7 @@ static int __dev_close_many(struct list_head *head)
 
 	dev_deactivate_many(head);
 
-	list_for_each_entry(dev, head, unreg_list) {
+	list_for_each_entry(dev, head, close_list) {
 		const struct net_device_ops *ops = dev->netdev_ops;
 
 		/*
@@ -1351,7 +1351,7 @@ static int __dev_close(struct net_device *dev)
 	/* Temporarily disable netpoll until the interface is down */
 	netpoll_rx_disable(dev);
 
-	list_add(&dev->unreg_list, &single);
+	list_add(&dev->close_list, &single);
 	retval = __dev_close_many(&single);
 	list_del(&single);
 
@@ -1362,21 +1362,20 @@ static int __dev_close(struct net_device *dev)
 static int dev_close_many(struct list_head *head)
 {
 	struct net_device *dev, *tmp;
-	LIST_HEAD(tmp_list);
 
-	list_for_each_entry_safe(dev, tmp, head, unreg_list)
+	/* Remove the devices that don't need to be closed */
+	list_for_each_entry_safe(dev, tmp, head, close_list)
 		if (!(dev->flags & IFF_UP))
-			list_move(&dev->unreg_list, &tmp_list);
+			list_del_init(&dev->close_list);
 
 	__dev_close_many(head);
 
-	list_for_each_entry(dev, head, unreg_list) {
+	list_for_each_entry_safe(dev, tmp, head, close_list) {
 		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
 		call_netdevice_notifiers(NETDEV_DOWN, dev);
+		list_del_init(&dev->close_list);
 	}
 
-	/* rollback_registered_many needs the complete original list */
-	list_splice(&tmp_list, head);
 	return 0;
 }
 
@@ -1397,7 +1396,7 @@ int dev_close(struct net_device *dev)
 		/* Block netpoll rx while the interface is going down */
 		netpoll_rx_disable(dev);
 
-		list_add(&dev->unreg_list, &single);
+		list_add(&dev->close_list, &single);
 		dev_close_many(&single);
 		list_del(&single);
 
@@ -5439,6 +5438,7 @@ static void net_set_todo(struct net_device *dev)
 static void rollback_registered_many(struct list_head *head)
 {
 	struct net_device *dev, *tmp;
+	LIST_HEAD(close_head);
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -5461,7 +5461,9 @@ static void rollback_registered_many(struct list_head *head)
 	}
 
 	/* If device is running, close it first. */
-	dev_close_many(head);
+	list_for_each_entry(dev, head, unreg_list)
+		list_add_tail(&dev->close_list, &close_head);
+	dev_close_many(&close_head);
 
 	list_for_each_entry(dev, head, unreg_list) {
 		/* And unlink it from device chain. */
@@ -6257,6 +6259,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
+	INIT_LIST_HEAD(&dev->close_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
 	INIT_LIST_HEAD(&dev->adj_list.upper);
 	INIT_LIST_HEAD(&dev->adj_list.lower);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e7121d29c4bd..7fc899a943a8 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -829,7 +829,7 @@ void dev_deactivate_many(struct list_head *head)
 	struct net_device *dev;
 	bool sync_needed = false;
 
-	list_for_each_entry(dev, head, unreg_list) {
+	list_for_each_entry(dev, head, close_list) {
 		netdev_for_each_tx_queue(dev, dev_deactivate_queue,
 					 &noop_qdisc);
 		if (dev_ingress_queue(dev))
@@ -848,7 +848,7 @@ void dev_deactivate_many(struct list_head *head)
 		synchronize_net();
 
 	/* Wait for outstanding qdisc_run calls. */
-	list_for_each_entry(dev, head, unreg_list)
+	list_for_each_entry(dev, head, close_list)
 		while (some_qdisc_is_busy(dev))
 			yield();
 }
@@ -857,7 +857,7 @@ void dev_deactivate(struct net_device *dev)
 {
 	LIST_HEAD(single);
 
-	list_add(&dev->unreg_list, &single);
+	list_add(&dev->close_list, &single);
 	dev_deactivate_many(&single);
 	list_del(&single);
 }
-- 
1.7.5.4
