From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: dev: Reclaim network device indexes
Date: Fri, 16 Jun 2017 19:39:34 +0300
Message-ID: <4d4b3b9dd459fc0487c1d25ef23514b9f01e4bb2.1497631012.git.serhe.popovych@gmail.com>
References: <20170616091659.3361b5d0@xeon-e3>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34589 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752539AbdFPQkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:40:01 -0400
Received: by mail-wr0-f193.google.com with SMTP id y25so4926740wrd.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:40:01 -0700 (PDT)
In-Reply-To: <20170616091659.3361b5d0@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While making dev_new_index() return zero on overrun prevents
from infinite loop, there is no way to recovery mechanisms
since namespace ifindex only increases and never reused
from released network devices.

To address this we introduce dev_free_index() helper which
is used to reclaim released network device index when it is
smaller than last allocated index in namespace.

This also has positive side effect for equal distribution
of network devices per buckets in index hash table. That
positively affects performance of dev_get_by_index() family.

Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 net/core/dev.c | 45 ++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 38 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6f573f7..e1714e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7031,6 +7031,24 @@ static int dev_new_index(struct net *net)
 	}
 }
 
+/**
+ *	dev_free_index	-	free an ifindex
+ *	@dev: the network device whose index to free
+ *
+ *	Sets network namespace last allocated index to the value
+ *	proceed to the ifindex we want to free.  The caller
+ *	must hold the rtnl semaphore or the dev_base_lock to be
+ *	sure it remains unique.
+ */
+static void dev_free_index(struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	int ifindex = dev->ifindex;
+
+	if (--ifindex < net->ifindex)
+		net->ifindex = ifindex;
+}
+
 /* Delayed registration/unregisteration */
 static LIST_HEAD(net_todo_list);
 DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wq);
@@ -7454,8 +7472,9 @@ void netif_tx_stop_all_queues(struct net_device *dev)
 
 int register_netdevice(struct net_device *dev)
 {
-	int ret;
 	struct net *net = dev_net(dev);
+	int ifindex = 0;
+	int ret;
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -7494,7 +7513,7 @@ int register_netdevice(struct net_device *dev)
 
 	ret = -EBUSY;
 	if (dev->ifindex <= 0) {
-		int ifindex = dev_new_index(net);
+		ifindex = dev_new_index(net);
 		if (!ifindex)
 			goto err_uninit;
 		dev->ifindex = ifindex;
@@ -7573,10 +7592,9 @@ int register_netdevice(struct net_device *dev)
 	/* Notify protocols, that a new device appeared. */
 	ret = call_netdevice_notifiers(NETDEV_REGISTER, dev);
 	ret = notifier_to_errno(ret);
-	if (ret) {
-		rollback_registered(dev);
-		dev->reg_state = NETREG_UNREGISTERED;
-	}
+	if (ret)
+		goto err_rollback;
+
 	/*
 	 *	Prevent userspace races by waiting until the network
 	 *	device is fully setup before sending notifications.
@@ -7593,6 +7611,14 @@ int register_netdevice(struct net_device *dev)
 		dev->netdev_ops->ndo_uninit(dev);
 	if (dev->priv_destructor)
 		dev->priv_destructor(dev);
+	goto err_free_index;
+
+err_rollback:
+	rollback_registered(dev);
+	dev->reg_state = NETREG_UNREGISTERED;
+err_free_index:
+	if (ifindex)
+		dev_free_index(dev);
 	goto out;
 }
 EXPORT_SYMBOL(register_netdevice);
@@ -7805,9 +7831,11 @@ void netdev_run_todo(void)
 		if (dev->needs_free_netdev)
 			free_netdev(dev);
 
-		/* Report a network device has been unregistered */
 		rtnl_lock();
+		/* Report a network device has been unregistered */
 		dev_net(dev)->dev_unreg_count--;
+		/* Reclaim a network device index */
+		dev_free_index(dev);
 		__rtnl_unlock();
 		wake_up(&netdev_unregistering_wq);
 
@@ -8256,6 +8284,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
 	netdev_adjacent_del_links(dev);
 
+	/* Free network device index */
+	dev_free_index(dev);
+
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
-- 
1.8.3.1
