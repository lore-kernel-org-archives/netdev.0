From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2] net: remove delay at device dismantle
Date: Fri, 10 Aug 2012 17:42:49 +0200
Message-ID: <1344613369.31104.2734.camel@edumazet-glaptop>
References: <1344590824.31104.1953.camel@edumazet-glaptop>
	 <20120810.034211.994338127277150687.davem@davemloft.net>
	 <1344596809.31104.2358.camel@edumazet-glaptop>
	 <1344609966.31104.2705.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63099 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754825Ab2HJPmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 11:42:55 -0400
Received: by bkwj10 with SMTP id j10so649620bkw.19
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 08:42:53 -0700 (PDT)
In-Reply-To: <1344609966.31104.2705.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I noticed extra one second delay in device dismantle, tracked down to
a call to dst_dev_event() while some call_rcu() are still in RCU queues.

These call_rcu() were posted by rt_free(struct rtable *rt) calls.

We then wait a little (but one second) in netdev_wait_allrefs() before
kicking again NETDEV_UNREGISTER.

As the call_rcu() are now completed, dst_dev_event() can do the needed
device swap on busy dst.

To solve this problem, add a new NETDEV_UNREGISTER_FINAL, called
after a rcu_barrier(), but outside of RTNL lock.

Use NETDEV_UNREGISTER_FINAL with care !

Change dst_dev_event() handler to react to NETDEV_UNREGISTER_FINAL

Also remove NETDEV_UNREGISTER_BATCH, as its not used anymore after
IP cache removal.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
---
v2: NETDEV_UNREGISTER_FINAL called outside of rtnl lock
    as its more risky, base this patch on net-next

 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |   22 ++++++++--------------
 net/core/dst.c            |    2 +-
 net/core/fib_rules.c      |    3 ++-
 net/core/rtnetlink.c      |    2 +-
 net/ipv4/devinet.c        |    6 +++++-
 net/ipv4/fib_frontend.c   |    2 --
 7 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a9db4f3..e3a43fd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1550,7 +1550,7 @@ struct packet_type {
 #define NETDEV_PRE_TYPE_CHANGE	0x000E
 #define NETDEV_POST_TYPE_CHANGE	0x000F
 #define NETDEV_POST_INIT	0x0010
-#define NETDEV_UNREGISTER_BATCH 0x0011
+#define NETDEV_UNREGISTER_FINAL 0x0011
 #define NETDEV_RELEASE		0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
diff --git a/net/core/dev.c b/net/core/dev.c
index 1f06df8..4c0f837 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1391,7 +1391,6 @@ rollback:
 				nb->notifier_call(nb, NETDEV_DOWN, dev);
 			}
 			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
-			nb->notifier_call(nb, NETDEV_UNREGISTER_BATCH, dev);
 		}
 	}
 
@@ -1433,7 +1432,6 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
 				nb->notifier_call(nb, NETDEV_DOWN, dev);
 			}
 			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
-			nb->notifier_call(nb, NETDEV_UNREGISTER_BATCH, dev);
 		}
 	}
 unlock:
@@ -1453,7 +1451,8 @@ EXPORT_SYMBOL(unregister_netdevice_notifier);
 
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 {
-	ASSERT_RTNL();
+	if (val != NETDEV_UNREGISTER_FINAL)
+		ASSERT_RTNL();
 	return raw_notifier_call_chain(&netdev_chain, val, dev);
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
@@ -5304,10 +5303,6 @@ static void rollback_registered_many(struct list_head *head)
 		netdev_unregister_kobject(dev);
 	}
 
-	/* Process any work delayed until the end of the batch */
-	dev = list_first_entry(head, struct net_device, unreg_list);
-	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
-
 	synchronize_net();
 
 	list_for_each_entry(dev, head, unreg_list)
@@ -5759,9 +5754,8 @@ static void netdev_wait_allrefs(struct net_device *dev)
 
 			/* Rebroadcast unregister notification */
 			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
-			/* don't resend NETDEV_UNREGISTER_BATCH, _BATCH users
-			 * should have already handle it the first time */
-
+			rcu_barrier();
+			call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
 			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
 				     &dev->state)) {
 				/* We must not have linkwatch events
@@ -5823,9 +5817,8 @@ void netdev_run_todo(void)
 
 	__rtnl_unlock();
 
-	/* Wait for rcu callbacks to finish before attempting to drain
-	 * the device list.  This usually avoids a 250ms wait.
-	 */
+
+	/* Wait for rcu callbacks to finish before next phase */
 	if (!list_empty(&list))
 		rcu_barrier();
 
@@ -5834,6 +5827,8 @@ void netdev_run_todo(void)
 			= list_first_entry(&list, struct net_device, todo_list);
 		list_del(&dev->todo_list);
 
+		call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
+
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
 			pr_err("network todo '%s' but state %d\n",
 			       dev->name, dev->reg_state);
@@ -6228,7 +6223,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	   the device is just moving and can keep their slaves up.
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
-	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
 	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
 
 	/*
diff --git a/net/core/dst.c b/net/core/dst.c
index 069d51d..a2d3624 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -366,7 +366,7 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event,
 	struct dst_entry *dst, *last = NULL;
 
 	switch (event) {
-	case NETDEV_UNREGISTER:
+	case NETDEV_UNREGISTER_FINAL:
 	case NETDEV_DOWN:
 		mutex_lock(&dst_gc_mutex);
 		for (dst = dst_busy_list; dst; dst = dst->next) {
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index ab7db83..5850937 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -711,15 +711,16 @@ static int fib_rules_event(struct notifier_block *this, unsigned long event,
 	struct net *net = dev_net(dev);
 	struct fib_rules_ops *ops;
 
-	ASSERT_RTNL();
 
 	switch (event) {
 	case NETDEV_REGISTER:
+		ASSERT_RTNL();
 		list_for_each_entry(ops, &net->rules_ops, list)
 			attach_rules(&ops->rules_list, dev);
 		break;
 
 	case NETDEV_UNREGISTER:
+		ASSERT_RTNL();
 		list_for_each_entry(ops, &net->rules_ops, list)
 			detach_rules(&ops->rules_list, dev);
 		break;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 34d975b..c64efcf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2358,7 +2358,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_PRE_TYPE_CHANGE:
 	case NETDEV_GOING_DOWN:
 	case NETDEV_UNREGISTER:
-	case NETDEV_UNREGISTER_BATCH:
+	case NETDEV_UNREGISTER_FINAL:
 	case NETDEV_RELEASE:
 	case NETDEV_JOIN:
 		break;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index adf273f..6a5e6e4 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1147,8 +1147,12 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 			 void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct in_device *in_dev = __in_dev_get_rtnl(dev);
+	struct in_device *in_dev;
 
+	if (event == NETDEV_UNREGISTER_FINAL)
+		goto out;
+
+	in_dev = __in_dev_get_rtnl(dev);
 	ASSERT_RTNL();
 
 	if (!in_dev) {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7f073a3..43d6fea 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1071,8 +1071,6 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	case NETDEV_CHANGE:
 		rt_cache_flush(dev_net(dev), 0);
 		break;
-	case NETDEV_UNREGISTER_BATCH:
-		break;
 	}
 	return NOTIFY_DONE;
 }
