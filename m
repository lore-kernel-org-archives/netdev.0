From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] net: Separate the close_list and the unreg_list
Date: Fri, 04 Oct 2013 02:34:50 -0700
Message-ID: <87eh818jlx.fsf_-_@xmission.com>
References: <CA+HUmGgJYeCj-wod=FsWJuZXQN0Kgbwiv+7iY7r+0BCOdqTDvg@mail.gmail.com>
	<20131003.175336.1790817032247867762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: fruggeri@aristanetworks.com, netdev@vger.kernel.org,
	edumazet@google.com, jiri@resnulli.us, alexander.h.duyck@intel.com,
	amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:57025 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3JDJfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 05:35:07 -0400
In-Reply-To: <20131003.175336.1790817032247867762.davem@davemloft.net> (David
	Miller's message of "Thu, 03 Oct 2013 17:53:36 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Separate the unreg_list and the close_list in dev_close_many preventing
dev_close_many from permuting the unreg_list.  The permutations of the
unreg_list have resulted in cases where the loopback device is accessed
it has been freed in code such as dst_ifdown.  Resulting in subtle
memory corruption.

This is the second bug from sharing the storage between the close_list
and the unreg_list.  The issues that crop up with sharing are apparently
too subtle to show up in normal testing or usage, so let's forget about
being clever and use two separate lists.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   25 +++++++++++++------------
 net/sched/sch_generic.c   |    6 +++---
 3 files changed, 17 insertions(+), 15 deletions(-)

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
index c25db20a4246..c8db0bfc36d6 100644
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
 
@@ -1362,21 +1362,21 @@ static int __dev_close(struct net_device *dev)
 static int dev_close_many(struct list_head *head)
 {
 	struct net_device *dev, *tmp;
-	LIST_HEAD(tmp_list);
+	LIST_HEAD(many);
 
-	list_for_each_entry_safe(dev, tmp, head, unreg_list)
-		if (!(dev->flags & IFF_UP))
-			list_move(&dev->unreg_list, &tmp_list);
+	/* rollback_registered_many needs the original unmodified list */
+	list_for_each_entry(dev, head, unreg_list)
+		if (dev->flags & IFF_UP)
+			list_add_tail(&dev->close_list, &many);
 
-	__dev_close_many(head);
+	__dev_close_many(&many);
 
-	list_for_each_entry(dev, head, unreg_list) {
+	list_for_each_entry_safe(dev, tmp, &many, close_list) {
 		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
 		call_netdevice_notifiers(NETDEV_DOWN, dev);
+		list_del_init(&dev->close_list);
 	}
 
-	/* rollback_registered_many needs the complete original list */
-	list_splice(&tmp_list, head);
 	return 0;
 }
 
@@ -1397,7 +1397,7 @@ int dev_close(struct net_device *dev)
 		/* Block netpoll rx while the interface is going down */
 		netpoll_rx_disable(dev);
 
-		list_add(&dev->unreg_list, &single);
+		list_add(&dev->close_list, &single);
 		dev_close_many(&single);
 		list_del(&single);
 
@@ -6257,6 +6257,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
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
