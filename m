From: Baptiste Covolato <baptiste@arista.com>
Subject: [PATCH net-next 3/3] net: Make netdev_run_todo call notifiers in parallel.
Date: Tue, 19 May 2015 16:24:53 -0700
Message-ID: <1432077893-4431-4-git-send-email-baptiste@arista.com>
References: <1432077893-4431-1-git-send-email-baptiste@arista.com>
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	Eric Mowat <mowat@arista.com>,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36062 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbbESXZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 19:25:21 -0400
Received: by pdfh10 with SMTP id h10so44586772pdf.3
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 16:25:20 -0700 (PDT)
In-Reply-To: <1432077893-4431-1-git-send-email-baptiste@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of unregister_netdevice_many, a queue of devices is
deleted but the final notifications are processed serially, with the next
one waiting until the previous device has been completely destroyed. This
patch allows netdev_run_todo to send all notifications at once, reducing
the total processing time for a large list.

Signed-off-by: Baptiste Covolato <baptiste@arista.com>
Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 net/core/dev.c | 146 ++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 83 insertions(+), 63 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9b0814b..00c512e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6698,105 +6698,125 @@ EXPORT_SYMBOL(netdev_refcnt_read);
 void netdev_run_todo(void)
 {
 	struct list_head list;
+	struct net_device *dev, *n;
 	unsigned long rebroadcast_time, warning_time;
+	LIST_HEAD(cleanup_list);
 
 	/* Snapshot list, allow later requests */
 	list_replace_init(&net_todo_list, &list);
 
 	__rtnl_unlock();
 
-
 	/* Wait for rcu callbacks to finish before next phase */
-	if (!list_empty(&list))
-		rcu_barrier();
+	if (list_empty(&list))
+		return;
 
-	while (!list_empty(&list)) {
-		int refcnt;
-		struct net_device *dev
-			= list_first_entry(&list, struct net_device, todo_list);
-		list_del(&dev->todo_list);
+	rcu_barrier();
 
-		rtnl_lock();
+	rtnl_lock();
+	list_for_each_entry(dev, &list, todo_list)
 		call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
-		__rtnl_unlock();
+	__rtnl_unlock();
 
+	list_for_each_entry_safe(dev, n, &list, todo_list) {
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
 			pr_err("network todo '%s' but state %d\n",
 			       dev->name, dev->reg_state);
 			dump_stack();
+			list_del(&dev->todo_list);
 			continue;
 		}
 
 		dev->reg_state = NETREG_UNREGISTERED;
+	}
 
-		on_each_cpu(flush_backlog, NULL, 1);
+	on_each_cpu(flush_backlog, NULL, 1);
 
+	list_for_each_entry(dev, &list, todo_list)
 		linkwatch_forget_dev(dev);
 
-		rebroadcast_time = warning_time = jiffies;
-		refcnt = netdev_refcnt_read(dev);
-
-		while (refcnt != 0) {
-			if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
-				rtnl_lock();
-
-				/* Rebroadcast unregister notification */
-				call_netdevice_notifiers(NETDEV_UNREGISTER,
-							 dev);
-
-				__rtnl_unlock();
-				rcu_barrier();
-				rtnl_lock();
-
-				call_netdevice_notifiers(
-					NETDEV_UNREGISTER_FINAL, dev);
-				if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
-					     &dev->state)) {
-					/* We must not have linkwatch events
-					 * pending on unregister. If this
-					 * happens, we simply run the queue
-					 * unscheduled, resulting in a noop
-					 * for this device.
-					 */
-					linkwatch_run_queue();
-				}
+	rebroadcast_time = warning_time = jiffies;
+again:
+	list_for_each_entry_safe(dev, n, &list, todo_list) {
+		if (netdev_refcnt_read(dev) == 0)
+			list_move(&dev->todo_list, &cleanup_list);
+	}
+
+	if (!list_empty(&cleanup_list)) {
+		list_for_each_entry(dev, &cleanup_list, todo_list) {
+			/* paranoia */
+			BUG_ON(netdev_refcnt_read(dev));
+			BUG_ON(!list_empty(&dev->ptype_all));
+			BUG_ON(!list_empty(&dev->ptype_specific));
+			WARN_ON(rcu_access_pointer(dev->ip_ptr));
+			WARN_ON(rcu_access_pointer(dev->ip6_ptr));
+			WARN_ON(dev->dn_ptr);
+
+			if (dev->destructor)
+				dev->destructor(dev);
+		}
+
+		/* Report some network devices have been unregistered */
+		rtnl_lock();
+		list_for_each_entry(dev, &cleanup_list, todo_list)
+			dev_net(dev)->dev_unreg_count--;
+		__rtnl_unlock();
+		wake_up(&netdev_unregistering_wq);
 
-				__rtnl_unlock();
+		list_for_each_entry_safe(dev, n, &cleanup_list, todo_list) {
+			list_del(&dev->todo_list);
 
-				rebroadcast_time = jiffies;
-			}
+			/* Free network devices */
+			kobject_put(&dev->dev.kobj);
+		}
+	}
 
-			msleep(250);
+	/* No more interface to delete */
+	if (list_empty(&list))
+		return;
 
-			refcnt = netdev_refcnt_read(dev);
+	if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
+		rtnl_lock();
 
-			if (time_after(jiffies, warning_time + 10 * HZ)) {
-				pr_emerg("unregister_netdevice: waiting for %s to become free. Usage count = %d\n",
-					 dev->name, refcnt);
-				warning_time = jiffies;
-			}
+		list_for_each_entry(dev, &list, todo_list) {
+			/* Rebroadcast unregister notification */
+			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 		}
 
-		/* paranoia */
-		BUG_ON(netdev_refcnt_read(dev));
-		BUG_ON(!list_empty(&dev->ptype_all));
-		BUG_ON(!list_empty(&dev->ptype_specific));
-		WARN_ON(rcu_access_pointer(dev->ip_ptr));
-		WARN_ON(rcu_access_pointer(dev->ip6_ptr));
-		WARN_ON(dev->dn_ptr);
+		__rtnl_unlock();
+		rcu_barrier();
+		rtnl_lock();
 
-		if (dev->destructor)
-			dev->destructor(dev);
+		list_for_each_entry(dev, &list, todo_list) {
+			call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
+			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
+				     &dev->state)) {
+				/* We must not have linkwatch events
+				 * pending on unregister. If this
+				 * happens, we simply run the queue
+				 * unscheduled, resulting in a noop
+				 * for this device.
+				 */
+				linkwatch_run_queue();
+			}
+		}
 
-		/* Report a network device has been unregistered */
-		rtnl_lock();
-		dev_net(dev)->dev_unreg_count--;
 		__rtnl_unlock();
-		wake_up(&netdev_unregistering_wq);
 
-		/* Free network device */
-		kobject_put(&dev->dev.kobj);
+		rebroadcast_time = jiffies;
+	}
+
+	msleep(250);
+
+	if (time_after(jiffies, warning_time + 10 * HZ)) {
+		list_for_each_entry(dev, &list, todo_list) {
+			pr_emerg("unregister_netdevice: waiting for %s to become free. Usage count = %d\n",
+				 dev->name, netdev_refcnt_read(dev));
+		}
+		warning_time = jiffies;
 	}
+
+	goto again;
 }
 
 /* Convert net_device_stats to rtnl_link_stats64.  They have the same
-- 
2.4.1
