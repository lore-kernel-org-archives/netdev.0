From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Delay default_device_exit_batch until no devices are unregistering v2
Date: Mon, 23 Sep 2013 21:19:49 -0700
Message-ID: <87a9j26eca.fsf_-_@xmission.com>
References: <e652a11e-b23d-4a83-aaac-00c469a416f1@email.android.com>
	<20130917.201515.1404443973169590392.davem@davemloft.net>
	<CA+HUmGgg3-0UNgfKS6Hpnczzi6PUeztk8TZ7p_97kcvtfMacJQ@mail.gmail.com>
	<20130917.235247.344101545141336143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41581 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab3IXEUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 00:20:06 -0400
In-Reply-To: <20130917.235247.344101545141336143.davem@davemloft.net> (David
	Miller's message of "Tue, 17 Sep 2013 23:52:47 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is currently serialization network namespaces exiting and
network devices exiting as the final part of netdev_run_todo does not
happen under the rtnl_lock.  This is compounded by the fact that the
only list of devices unregistering in netdev_run_todo is local to the
netdev_run_todo.

This lack of serialization in extreme cases results in network devices
unregistering in netdev_run_todo after the loopback device of their
network namespace has been freed (making dst_ifdown unsafe), and after
the their network namespace has exited (making the NETDEV_UNREGISTER,
and NETDEV_UNREGISTER_FINAL callbacks unsafe).

Add the missing serialization by a per network namespace count of how
many network devices are unregistering and having a wait queue that is
woken up whenever the count is decreased.  The count and wait queue
allow default_device_exit_batch to wait until all of the unregistration
activity for a network namespace has finished before proceeding to
unregister the loopback device and then allowing the network namespace
to exit.

Only a single global wait queue is used because there is a single global
lock, and there is a single waiter, per network namespace wait queues
would be a waste of resources.

The per network namespace count of unregistering devices gives a
progress guarantee because the number of network devices unregistering
in an exiting network namespace must ultimately drop to zero (assuming
network device unregistration completes).

The basic logic remains the same as in v1.  This patch is now half
comment and half rtnl_lock_unregistering an expanded version of
wait_event performs no extra work in the common case where no network
devices are unregistering when we get to default_device_exit_batch.

Reported-by: Francesco Ruggeri <fruggeri@aristanetworks.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    1 +
 net/core/dev.c              |   49 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 84e37b1..be46311 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -74,6 +74,7 @@ struct net {
 	struct hlist_head	*dev_index_head;
 	unsigned int		dev_base_seq;	/* protected by rtnl_mutex */
 	int			ifindex;
+	unsigned int		dev_unreg_count;
 
 	/* core fib_rules */
 	struct list_head	rules_ops;
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d702fe..7fa75e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5002,10 +5002,12 @@ static int dev_new_index(struct net *net)
 
 /* Delayed registration/unregisteration */
 static LIST_HEAD(net_todo_list);
+static DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wq);
 
 static void net_set_todo(struct net_device *dev)
 {
 	list_add_tail(&dev->todo_list, &net_todo_list);
+	dev_net(dev)->dev_unreg_count++;
 }
 
 static void rollback_registered_many(struct list_head *head)
@@ -5673,6 +5675,12 @@ void netdev_run_todo(void)
 		if (dev->destructor)
 			dev->destructor(dev);
 
+		/* Report a network device has been unregistered */
+		rtnl_lock();
+		dev_net(dev)->dev_unreg_count--;
+		__rtnl_unlock();
+		wake_up(&netdev_unregistering_wq);
+
 		/* Free network device */
 		kobject_put(&dev->dev.kobj);
 	}
@@ -6358,6 +6366,34 @@ static void __net_exit default_device_exit(struct net *net)
 	rtnl_unlock();
 }
 
+static void __net_exit rtnl_lock_unregistering(struct list_head *net_list)
+{
+	/* Return with the rtnl_lock held when there are no network
+	 * devices unregistering in any network namespace in net_list.
+	 */
+	struct net *net;
+	bool unregistering;
+	DEFINE_WAIT(wait);
+
+	for (;;) {
+		prepare_to_wait(&netdev_unregistering_wq, &wait,
+				TASK_UNINTERRUPTIBLE);
+		unregistering = false;
+		rtnl_lock();
+		list_for_each_entry(net, net_list, exit_list) {
+			if (net->dev_unreg_count > 0) {
+				unregistering = true;
+				break;
+			}
+		}
+		if (!unregistering)
+			break;
+		__rtnl_unlock();
+		schedule();
+	}
+	finish_wait(&netdev_unregistering_wq, &wait);
+}
+
 static void __net_exit default_device_exit_batch(struct list_head *net_list)
 {
 	/* At exit all network devices most be removed from a network
@@ -6369,7 +6405,18 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 	struct net *net;
 	LIST_HEAD(dev_kill_list);
 
-	rtnl_lock();
+	/* To prevent network device cleanup code from dereferencing
+	 * loopback devices or network devices that have been freed
+	 * wait here for all pending unregistrations to complete,
+	 * before unregistring the loopback device and allowing the
+	 * network namespace be freed.
+	 *
+	 * The netdev todo list containing all network devices
+	 * unregistrations that happen in default_device_exit_batch
+	 * will run in the rtnl_unlock() at the end of
+	 * default_device_exit_batch.
+	 */
+	rtnl_lock_unregistering(net_list);
 	list_for_each_entry(net, net_list, exit_list) {
 		for_each_netdev_reverse(net, dev) {
 			if (dev->rtnl_link_ops)
-- 
1.7.5.4
