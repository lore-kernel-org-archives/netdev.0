From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH 1/2] net: introduce NETDEV_UNREGISTER_PERNET
Date: Tue, 17 Nov 2009 01:49:35 +0200
Message-ID: <200911170149.35240.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13543 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753592AbZKPXwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 18:52:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new event is called once for each unique net namespace in batched
unregister operations (with the argument set to a random device from
that namespace) and once per device in non-batched unregister
operations.

It allows us to factorize some device unregister work such as clearing the
routing cache.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/linux/notifier.h |    1 +
 net/core/dev.c           |   29 +++++++++++++++++++++++++++--
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 29714b8..b0c3671 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -202,6 +202,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_BONDING_OLDTYPE  0x000E
 #define NETDEV_BONDING_NEWTYPE  0x000F
 #define NETDEV_POST_INIT	0x0010
+#define NETDEV_UNREGISTER_PERNET 0x0011
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
diff --git a/net/core/dev.c b/net/core/dev.c
index 4b24d79..2bd357a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1343,6 +1343,7 @@ rollback:
 				nb->notifier_call(nb, NETDEV_DOWN, dev);
 			}
 			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
+			nb->notifier_call(nb, NETDEV_UNREGISTER_PERNET, dev);
 		}
 	}
 
@@ -4720,7 +4721,8 @@ static void net_set_todo(struct net_device *dev)
 
 static void rollback_registered_many(struct list_head *head)
 {
-	struct net_device *dev;
+	struct net_device *dev, *aux, *fdev;
+	LIST_HEAD(pernet_list);
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -4778,8 +4780,24 @@ static void rollback_registered_many(struct list_head *head)
 
 	synchronize_net();
 
-	list_for_each_entry(dev, head, unreg_list)
+	list_for_each_entry_safe(dev, aux, head, unreg_list) {
+		int new_net = 1;
+		list_for_each_entry(fdev, &pernet_list, unreg_list) {
+			if (dev_net(dev) == dev_net(fdev)) {
+				new_net = 0;
+				dev_put(dev);
+				break;
+			}
+		}
+		if (new_net)
+			list_move(&dev->unreg_list, &pernet_list);
+	}
+
+	list_for_each_entry_safe(dev, aux, &pernet_list, unreg_list) {
+		call_netdevice_notifiers(NETDEV_UNREGISTER_PERNET, dev);
+		list_move(&dev->unreg_list, head);
 		dev_put(dev);
+	}
 }
 
 static void rollback_registered(struct net_device *dev)
@@ -5073,6 +5091,8 @@ static void netdev_wait_allrefs(struct net_device *dev)
 
 			/* Rebroadcast unregister notification */
 			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+			/* don't resend NETDEV_UNREGISTER_PERNET, _PERNET users
+			 * should have already handle it the first time */
 
 			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
 				     &dev->state)) {
@@ -5374,6 +5394,10 @@ EXPORT_SYMBOL(unregister_netdevice_queue);
  *	unregister_netdevice_many - unregister many devices
  *	@head: list of devices
  *
+ *	WARNING: Calling this modifies the given list
+ *	(in rollback_registered_many). It may change the order of the elements
+ *	in the list. However, you can assume it does not add or delete elements
+ *	to/from the list.
  */
 void unregister_netdevice_many(struct list_head *head)
 {
@@ -5493,6 +5517,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	   this device. They should clean all the things.
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+	call_netdevice_notifiers(NETDEV_UNREGISTER_PERNET, dev);
 
 	/*
 	 *	Flush the unicast and multicast chains
-- 
1.5.6.5

