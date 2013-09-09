From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Mon,  9 Sep 2013 16:15:11 -0700
Message-ID: <1378768511-27866-1-git-send-email-fruggeri@aristanetworks.com>
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:50129 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756Ab3IIXQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 19:16:00 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so6795242pbb.10
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 16:15:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition when removing a net_device while its net namespace
is also being removed.
This can result in a crash or other unpredictable behavior.
This is a sample scenario with veth, but the same applies to other virtual
devices such as vlan and macvlan.
veth pair v0-v1 is created, with v0 in namespace ns0 and v1 in ns1.
Process p0 deletes v0. v1 is also unregistered (in veth_dellink), so when p0
gets to netdev_run_todo both v0 and v1 are in net_todo_list, and they have both
been unlisted from their respective namespaces. If all references to v1 have not
already been dropped then netdev_run_todo/netdev_wait_allrefs will call netdev
notifiers for v1, releasing the rtnl lock between calls.
Now process p1 removes namespace ns1. v1 will not prevent this from happening
(in default_device_exit_batch) since it was already unlisted by p0.
Next time p0 invokes the notifiers for v1 any notifiers that use dev_net(v1)
will get a pointer to a namespace that has been or is being removed.
Similar scenarios apply with v1 as a vlan or macvlan interface and v0 as its
real device.
We hit this problem in 3.4 with sequence fib_netdev_event, fib_disable_ip,
rt_cache_flush, rt_cache_invalidate, inetpeer_invalidate_tree. That sequence no
longer applies in later kernels, but unless we can guarantee that no
NETDEV_UNREGISTER or NETDEV_UNREGISTER_FINAL handler accesses a net_device's
dev_net(dev) then there is a vulnerability (this happens for example with
NETDEV_UNREGISTER_FINAL in dst_dev_event/dst_ifdown).
Commit 0115e8e3 later made things better by reducing the chances of this
happening, but the underlying problem still seems to be there.
I would like to get some feedback on this patch.
The idea is to take a reference to the loopback_dev of a net_device's
namespace (which is always the last net_device to be removed when a namespace
is destroyed) when the net_device is unlisted, and release it when the
net_device is disposed of.
To avoid deadlocks in cleanup_net all loopback_devs are queued at the end
of net_todo_list.

Tested on Linux 3.4.

Signed-off-by: Francesco Ruggeri <fruggeri@aristanetworks.com>
---
 net/core/dev.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 26755dd..da2fd78 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -225,10 +225,14 @@ static void list_netdevice(struct net_device *dev)
 }
 
 /* Device list removal
+ * Take a reference to dev_net(dev)->loopback_dev, so dev_net(dev)
+ * will not be freed until we are done with dev.
  * caller must respect a RCU grace period before freeing/reusing dev
  */
 static void unlist_netdevice(struct net_device *dev)
 {
+	struct net_device *loopback_dev = dev_net(dev)->loopback_dev;
+
 	ASSERT_RTNL();
 
 	/* Unlink dev from the device chain */
@@ -238,9 +242,23 @@ static void unlist_netdevice(struct net_device *dev)
 	hlist_del_rcu(&dev->index_hlist);
 	write_unlock_bh(&dev_base_lock);
 
+	if (dev != loopback_dev)
+		dev_hold(loopback_dev);
+
 	dev_base_seq_inc(dev_net(dev));
 }
 
+/**
+ * Called when a net_device that has been previously unlisted from a net
+ * namespace is disposed of.
+ */
+static inline void unlist_netdevice_done(struct net_device *dev)
+{
+	struct net_device *loopback_dev = dev_net(dev)->loopback_dev;
+	if (dev != loopback_dev)
+		dev_put(loopback_dev);
+}
+
 /*
  *	Our notifier list
  */
@@ -5009,10 +5027,17 @@ static int dev_new_index(struct net *net)
 
 /* Delayed registration/unregisteration */
 static LIST_HEAD(net_todo_list);
+static struct list_head *first_loopback_dev = &net_todo_list;
 
 static void net_set_todo(struct net_device *dev)
 {
-	list_add_tail(&dev->todo_list, &net_todo_list);
+	/* All loopback_devs go to end of net_todo_list. */
+	if (dev == dev_net(dev)->loopback_dev) {
+		list_add_tail(&dev->todo_list, &net_todo_list);
+		if (first_loopback_dev == &net_todo_list)
+			first_loopback_dev = &dev->todo_list;
+	} else
+		list_add_tail(&dev->todo_list, first_loopback_dev);
 }
 
 static void rollback_registered_many(struct list_head *head)
@@ -5641,6 +5666,7 @@ void netdev_run_todo(void)
 
 	/* Snapshot list, allow later requests */
 	list_replace_init(&net_todo_list, &list);
+	first_loopback_dev = &net_todo_list;
 
 	__rtnl_unlock();
 
@@ -5670,6 +5696,7 @@ void netdev_run_todo(void)
 		on_each_cpu(flush_backlog, dev, 1);
 
 		netdev_wait_allrefs(dev);
+		unlist_netdevice_done(dev);
 
 		/* paranoia */
 		BUG_ON(netdev_refcnt_read(dev));
@@ -6076,6 +6103,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
 
 	/* Actually switch the network namespace */
+	unlist_netdevice_done(dev);
 	dev_net_set(dev, net);
 
 	/* If there is an ifindex conflict assign a new one */
-- 
1.7.4.4
