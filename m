From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 01/20] net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
Date: Sun, 29 Nov 2009 17:45:58 -0800
Message-ID: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46428 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbZK3BqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

The motivation for an additional notifier in batched netdevice
notification (rt_do_flush) only needs to be called once per
batch not once per namespace.  For further batching improvements

I need a guarantee that the netdevices are unregistered in order
allowing me to unregister an all of the network devices in a network
namespace at the same time with the guarantee that the loopback
device is really and truly unregistered last.

Additionally it appears that we moved the route cache flush after
the final synchronize_net, which seems wrong and there was no
explanation.  So I have restored the original location of the final
synchronize_net.

Cc: Octavian Purdila <opurdila@ixiacom.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/notifier.h |    2 +-
 include/net/route.h      |    1 +
 net/core/dev.c           |   36 +++++++++---------------------------
 net/ipv4/fib_frontend.c  |    4 +++-
 net/ipv4/route.c         |    6 ++++++
 5 files changed, 20 insertions(+), 29 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index b0c3671..fee6c2f 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -202,7 +202,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_BONDING_OLDTYPE  0x000E
 #define NETDEV_BONDING_NEWTYPE  0x000F
 #define NETDEV_POST_INIT	0x0010
-#define NETDEV_UNREGISTER_PERNET 0x0011
+#define NETDEV_UNREGISTER_BATCH 0x0011
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
diff --git a/include/net/route.h b/include/net/route.h
index cfb4c07..bce6dd6 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -108,6 +108,7 @@ extern int		ip_rt_init(void);
 extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
+extern void		rt_cache_flush_batch(void);
 extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7775e8b..124029e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1353,7 +1353,7 @@ rollback:
 				nb->notifier_call(nb, NETDEV_DOWN, dev);
 			}
 			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
-			nb->notifier_call(nb, NETDEV_UNREGISTER_PERNET, dev);
+			nb->notifier_call(nb, NETDEV_UNREGISTER_BATCH, dev);
 		}
 	}
 
@@ -4770,8 +4770,7 @@ static void net_set_todo(struct net_device *dev)
 
 static void rollback_registered_many(struct list_head *head)
 {
-	struct net_device *dev, *aux, *fdev;
-	LIST_HEAD(pernet_list);
+	struct net_device *dev;
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -4827,26 +4826,14 @@ static void rollback_registered_many(struct list_head *head)
 		netdev_unregister_kobject(dev);
 	}
 
-	synchronize_net();
+	/* Process any work delayed until the end of the batch */
+	dev = list_entry(head->next, struct net_device, unreg_list);
+	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
 
-	list_for_each_entry_safe(dev, aux, head, unreg_list) {
-		int new_net = 1;
-		list_for_each_entry(fdev, &pernet_list, unreg_list) {
-			if (net_eq(dev_net(dev), dev_net(fdev))) {
-				new_net = 0;
-				dev_put(dev);
-				break;
-			}
-		}
-		if (new_net)
-			list_move(&dev->unreg_list, &pernet_list);
-	}
+	synchronize_net();
 
-	list_for_each_entry_safe(dev, aux, &pernet_list, unreg_list) {
-		call_netdevice_notifiers(NETDEV_UNREGISTER_PERNET, dev);
-		list_move(&dev->unreg_list, head);
+	list_for_each_entry(dev, head, unreg_list)
 		dev_put(dev);
-	}
 }
 
 static void rollback_registered(struct net_device *dev)
@@ -5128,7 +5115,7 @@ static void netdev_wait_allrefs(struct net_device *dev)
 
 			/* Rebroadcast unregister notification */
 			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
-			/* don't resend NETDEV_UNREGISTER_PERNET, _PERNET users
+			/* don't resend NETDEV_UNREGISTER_BATCH, _BATCH users
 			 * should have already handle it the first time */
 
 			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
@@ -5441,11 +5428,6 @@ EXPORT_SYMBOL(unregister_netdevice_queue);
 /**
  *	unregister_netdevice_many - unregister many devices
  *	@head: list of devices
- *
- *	WARNING: Calling this modifies the given list
- *	(in rollback_registered_many). It may change the order of the elements
- *	in the list. However, you can assume it does not add or delete elements
- *	to/from the list.
  */
 void unregister_netdevice_many(struct list_head *head)
 {
@@ -5554,7 +5536,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	   this device. They should clean all the things.
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
-	call_netdevice_notifiers(NETDEV_UNREGISTER_PERNET, dev);
+	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
 
 	/*
 	 *	Flush the unicast and multicast chains
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6c1e56a..3b373a8 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -959,9 +959,11 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGE:
-	case NETDEV_UNREGISTER_PERNET:
 		rt_cache_flush(dev_net(dev), 0);
 		break;
+	case NETDEV_UNREGISTER_BATCH:
+		rt_cache_flush_batch();
+		break;
 	}
 	return NOTIFY_DONE;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9889fbd..90cdcfc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -900,6 +900,12 @@ void rt_cache_flush(struct net *net, int delay)
 		rt_do_flush(!in_softirq());
 }
 
+/* Flush previous cache invalidated entries from the cache */
+void rt_cache_flush_batch(void)
+{
+	rt_do_flush(!in_softirq());
+}
+
 /*
  * We change rt_genid and let gc do the cleanup
  */
-- 
1.6.5.2.143.g8cc62

