From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: reinstate rtnl in call_netdevice_notifiers()
Date: Thu, 23 Aug 2012 09:50:59 +0200
Message-ID: <1345708259.5904.178.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org,
	therbert@google.com, maheshb@google.com, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33806 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758112Ab2HWHvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 03:51:04 -0400
Received: by bkwj10 with SMTP id j10so111785bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 00:51:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Eric Biederman pointed out that not holding RTNL while calling
call_netdevice_notifiers() was racy.

This patch is a direct transcription his feedback
against commit 0115e8e30d6fc (net: remove delay at device dismantle)

Thanks Eric !

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
---
Note: After this patch, it seems less risky to push these fixes for 3.6,
since notifiers have the guarantee that RTNL is held.

 net/core/dev.c          |    9 +++++++--
 net/core/fib_rules.c    |    3 +--
 net/ipv4/devinet.c      |    6 +-----
 net/ipv4/fib_frontend.c |    7 ++-----
 net/ipv6/addrconf.c     |    6 +-----
 5 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0640d2a..bc857fe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1466,8 +1466,7 @@ EXPORT_SYMBOL(unregister_netdevice_notifier);
 
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 {
-	if (val != NETDEV_UNREGISTER_FINAL)
-		ASSERT_RTNL();
+	ASSERT_RTNL();
 	return raw_notifier_call_chain(&netdev_chain, val, dev);
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
@@ -5782,7 +5781,11 @@ static void netdev_wait_allrefs(struct net_device *dev)
 
 			/* Rebroadcast unregister notification */
 			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+
+			__rtnl_unlock();
 			rcu_barrier();
+			rtnl_lock();
+
 			call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
 			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
 				     &dev->state)) {
@@ -5855,7 +5858,9 @@ void netdev_run_todo(void)
 			= list_first_entry(&list, struct net_device, todo_list);
 		list_del(&dev->todo_list);
 
+		rtnl_lock();
 		call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
+		__rtnl_unlock();
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
 			pr_err("network todo '%s' but state %d\n",
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 5850937..ab7db83 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -711,16 +711,15 @@ static int fib_rules_event(struct notifier_block *this, unsigned long event,
 	struct net *net = dev_net(dev);
 	struct fib_rules_ops *ops;
 
+	ASSERT_RTNL();
 
 	switch (event) {
 	case NETDEV_REGISTER:
-		ASSERT_RTNL();
 		list_for_each_entry(ops, &net->rules_ops, list)
 			attach_rules(&ops->rules_list, dev);
 		break;
 
 	case NETDEV_UNREGISTER:
-		ASSERT_RTNL();
 		list_for_each_entry(ops, &net->rules_ops, list)
 			detach_rules(&ops->rules_list, dev);
 		break;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 6a5e6e4..adf273f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1147,12 +1147,8 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 			 void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct in_device *in_dev;
-
-	if (event == NETDEV_UNREGISTER_FINAL)
-		goto out;
+	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
-	in_dev = __in_dev_get_rtnl(dev);
 	ASSERT_RTNL();
 
 	if (!in_dev) {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index fd7d9ae..acdee32 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1050,9 +1050,6 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		return NOTIFY_DONE;
 	}
 
-	if (event == NETDEV_UNREGISTER_FINAL)
-		return NOTIFY_DONE;
-
 	in_dev = __in_dev_get_rtnl(dev);
 
 	switch (event) {
@@ -1064,14 +1061,14 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		fib_sync_up(dev);
 #endif
 		atomic_inc(&net->ipv4.dev_addr_genid);
-		rt_cache_flush(dev_net(dev), -1);
+		rt_cache_flush(net, -1);
 		break;
 	case NETDEV_DOWN:
 		fib_disable_ip(dev, 0, 0);
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGE:
-		rt_cache_flush(dev_net(dev), 0);
+		rt_cache_flush(net, 0);
 		break;
 	}
 	return NOTIFY_DONE;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e581009..6bc85f7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2566,14 +2566,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct inet6_dev *idev;
+	struct inet6_dev *idev = __in6_dev_get(dev);
 	int run_pending = 0;
 	int err;
 
-	if (event == NETDEV_UNREGISTER_FINAL)
-		return NOTIFY_DONE;
-
-	idev = __in6_dev_get(dev);
 	switch (event) {
 	case NETDEV_REGISTER:
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
