From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch 6/7] net_device list cleanup: dev_base removal
Date: Mon, 3 Jul 2006 12:18:56 +0400
Message-ID: <20060630165305.H22285@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:36872 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1750996AbWGCQcA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:32:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060630150823.A22285@castle.nmd.msu.ru>; from "Andrey Savochkin" on Fri, Jun 30, 2006 at 03:08:23PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removal of dev_base and dev_tail variables as a part of net_device list
cleanup.
The cleanup consists of
 - converting the to list_head, to make the list double-linked (thus making
   remove operation O(1)), and list walks more readable;
 - introducing of for_each_netdev wrapper over list_for_each.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
---
 include/linux/netdevice.h |    2 --
 net/core/dev.c            |   21 ---------------------
 2 files changed, 23 deletions(-)

--- ./include/linux/netdevice.h.vedevbase-fin	Mon Jul  3 16:16:28 2006
+++ ./include/linux/netdevice.h	Mon Jul  3 16:16:28 2006
@@ -289,7 +289,6 @@ struct net_device
 
 	unsigned long		state;
 
-	struct net_device	*next;
 	struct list_head	dev_list;
 
 	/* The device initialization function. Called only once. */
@@ -558,7 +557,6 @@ struct packet_type {
 #include <linux/notifier.h>
 
 extern struct net_device		loopback_dev;		/* The loopback */
-extern struct net_device		*dev_base;		/* All devices */
 extern struct list_head			dev_base_head;		/* All devices */
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
--- ./net/core/dev.c.vedevbase-fin	Mon Jul  3 16:16:28 2006
+++ ./net/core/dev.c	Mon Jul  3 16:16:28 2006
@@ -174,11 +174,7 @@ static spinlock_t net_dma_event_lock;
  * unregister_netdevice(), which must be called with the rtnl
  * semaphore held.
  */
-struct net_device *dev_base;
-static struct net_device **dev_tail = &dev_base;
 DEFINE_RWLOCK(dev_base_lock);
-
-EXPORT_SYMBOL(dev_base);
 EXPORT_SYMBOL(dev_base_lock);
 
 LIST_HEAD(dev_base_head);
@@ -2973,11 +2969,8 @@ int register_netdevice(struct net_device
 
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 
-	dev->next = NULL;
 	dev_init_scheduler(dev);
 	write_lock_bh(&dev_base_lock);
-	*dev_tail = dev;
-	dev_tail = &dev->next;
 	list_add_tail(&dev->dev_list, &dev_base_head);
 	hlist_add_head(&dev->name_hlist, head);
 	hlist_add_head(&dev->index_hlist, dev_index_hash(dev->ifindex));
@@ -3256,8 +3249,6 @@ void synchronize_net(void) 
 
 int unregister_netdevice(struct net_device *dev)
 {
-	struct net_device *d, **dp;
-
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
 
@@ -3275,22 +3266,10 @@ int unregister_netdevice(struct net_devi
 		dev_close(dev);
 
 	/* And unlink it from device chain. */
-	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
-		if (d == dev)
-			break;
-	}
-	if (!d) {
-		printk(KERN_ERR "unregister net_device: '%s' not found\n",
-		       dev->name);
-		return -ENODEV;
-	}
 	write_lock_bh(&dev_base_lock);
 	list_del(&dev->dev_list);
 	hlist_del(&dev->name_hlist);
 	hlist_del(&dev->index_hlist);
-	if (dev_tail == &dev->next)
-		dev_tail = dp;
-	*dp = d->next;
 	write_unlock_bh(&dev_base_lock);
 
 	dev->reg_state = NETREG_UNREGISTERING;
