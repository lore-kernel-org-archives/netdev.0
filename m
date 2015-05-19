From: Baptiste Covolato <baptiste@arista.com>
Subject: [PATCH net-next 2/3] net: Inline netdev_wait_allrefs inside netdev_run_todo
Date: Tue, 19 May 2015 16:24:52 -0700
Message-ID: <1432077893-4431-3-git-send-email-baptiste@arista.com>
References: <1432077893-4431-1-git-send-email-baptiste@arista.com>
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	Eric Mowat <mowat@arista.com>,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35236 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbESXZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 19:25:20 -0400
Received: by pdea3 with SMTP id a3so44649829pde.2
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 16:25:19 -0700 (PDT)
In-Reply-To: <1432077893-4431-1-git-send-email-baptiste@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make netdev_wait_allrefs part of netdev_run_todo

Signed-off-by: Baptiste Covolato <baptiste@arista.com>
Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 net/core/dev.c | 110 ++++++++++++++++++++++++---------------------------------
 1 file changed, 47 insertions(+), 63 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index db59d18..9b0814b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6671,68 +6671,6 @@ int netdev_refcnt_read(const struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_refcnt_read);
 
-/**
- * netdev_wait_allrefs - wait until all references are gone.
- * @dev: target net_device
- *
- * This is called when unregistering network devices.
- *
- * Any protocol or device that holds a reference should register
- * for netdevice notification, and cleanup and put back the
- * reference if they receive an UNREGISTER event.
- * We can get stuck here if buggy protocols don't correctly
- * call dev_put.
- */
-static void netdev_wait_allrefs(struct net_device *dev)
-{
-	unsigned long rebroadcast_time, warning_time;
-	int refcnt;
-
-	linkwatch_forget_dev(dev);
-
-	rebroadcast_time = warning_time = jiffies;
-	refcnt = netdev_refcnt_read(dev);
-
-	while (refcnt != 0) {
-		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
-			rtnl_lock();
-
-			/* Rebroadcast unregister notification */
-			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
-
-			__rtnl_unlock();
-			rcu_barrier();
-			rtnl_lock();
-
-			call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
-			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
-				     &dev->state)) {
-				/* We must not have linkwatch events
-				 * pending on unregister. If this
-				 * happens, we simply run the queue
-				 * unscheduled, resulting in a noop
-				 * for this device.
-				 */
-				linkwatch_run_queue();
-			}
-
-			__rtnl_unlock();
-
-			rebroadcast_time = jiffies;
-		}
-
-		msleep(250);
-
-		refcnt = netdev_refcnt_read(dev);
-
-		if (time_after(jiffies, warning_time + 10 * HZ)) {
-			pr_emerg("unregister_netdevice: waiting for %s to become free. Usage count = %d\n",
-				 dev->name, refcnt);
-			warning_time = jiffies;
-		}
-	}
-}
-
 /* The sequence is:
  *
  *	rtnl_lock();
@@ -6760,6 +6698,7 @@ static void netdev_wait_allrefs(struct net_device *dev)
 void netdev_run_todo(void)
 {
 	struct list_head list;
+	unsigned long rebroadcast_time, warning_time;
 
 	/* Snapshot list, allow later requests */
 	list_replace_init(&net_todo_list, &list);
@@ -6772,6 +6711,7 @@ void netdev_run_todo(void)
 		rcu_barrier();
 
 	while (!list_empty(&list)) {
+		int refcnt;
 		struct net_device *dev
 			= list_first_entry(&list, struct net_device, todo_list);
 		list_del(&dev->todo_list);
@@ -6791,7 +6731,51 @@ void netdev_run_todo(void)
 
 		on_each_cpu(flush_backlog, NULL, 1);
 
-		netdev_wait_allrefs(dev);
+		linkwatch_forget_dev(dev);
+
+		rebroadcast_time = warning_time = jiffies;
+		refcnt = netdev_refcnt_read(dev);
+
+		while (refcnt != 0) {
+			if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
+				rtnl_lock();
+
+				/* Rebroadcast unregister notification */
+				call_netdevice_notifiers(NETDEV_UNREGISTER,
+							 dev);
+
+				__rtnl_unlock();
+				rcu_barrier();
+				rtnl_lock();
+
+				call_netdevice_notifiers(
+					NETDEV_UNREGISTER_FINAL, dev);
+				if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
+					     &dev->state)) {
+					/* We must not have linkwatch events
+					 * pending on unregister. If this
+					 * happens, we simply run the queue
+					 * unscheduled, resulting in a noop
+					 * for this device.
+					 */
+					linkwatch_run_queue();
+				}
+
+				__rtnl_unlock();
+
+				rebroadcast_time = jiffies;
+			}
+
+			msleep(250);
+
+			refcnt = netdev_refcnt_read(dev);
+
+			if (time_after(jiffies, warning_time + 10 * HZ)) {
+				pr_emerg("unregister_netdevice: waiting for %s to become free. Usage count = %d\n",
+					 dev->name, refcnt);
+				warning_time = jiffies;
+			}
+		}
 
 		/* paranoia */
 		BUG_ON(netdev_refcnt_read(dev));
-- 
2.4.1
