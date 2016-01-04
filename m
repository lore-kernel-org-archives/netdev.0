From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH net-next 2/4] net: dev: add batching to net_device notifiers
Date: Mon,  4 Jan 2016 15:10:54 -0800
Message-ID: <1451949056-15500-3-git-send-email-noureddine@arista.com>
References: <1451949056-15500-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:20692 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753368AbcADXSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 18:18:02 -0500
In-Reply-To: <1451949056-15500-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This can be used to optimize bringing down and unregsitering
net_devices by running certain cleanup operations only on the
net namespace instead of on each net_device.

Signed-off-by: Salam Noureddine <noureddine@arista.com>
---
 include/linux/netdevice.h |  2 ++
 net/core/dev.c            | 39 ++++++++++++++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c20b814..1b12269 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2183,6 +2183,8 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
+#define NETDEV_UNREGISTER_BATCH	0x001C
+#define NETDEV_DOWN_BATCH	0x001D
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 914b4a2..77410a3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1439,11 +1439,16 @@ static int __dev_close(struct net_device *dev)
 int dev_close_many(struct list_head *head, bool unlink)
 {
 	struct net_device *dev, *tmp;
+	struct net *net, *net_tmp;
+	LIST_HEAD(net_head);
 
 	/* Remove the devices that don't need to be closed */
-	list_for_each_entry_safe(dev, tmp, head, close_list)
+	list_for_each_entry_safe(dev, tmp, head, close_list) {
 		if (!(dev->flags & IFF_UP))
 			list_del_init(&dev->close_list);
+		else
+			net_add_event_list(&net_head, dev_net(dev));
+	}
 
 	__dev_close_many(head);
 
@@ -1454,6 +1459,11 @@ int dev_close_many(struct list_head *head, bool unlink)
 			list_del_init(&dev->close_list);
 	}
 
+	list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
+		call_netdevice_notifiers(NETDEV_DOWN_BATCH, net->loopback_dev);
+		net_del_event_list(net);
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL(dev_close_many);
@@ -1572,8 +1582,12 @@ rollback:
 				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
 							dev);
 				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
+				call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
+							dev);
 			}
 			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
+			call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
+						dev);
 		}
 	}
 
@@ -1614,8 +1628,12 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
 				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
 							dev);
 				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
+				call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
+							dev);
 			}
 			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
+			call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
+						dev);
 		}
 	}
 unlock:
@@ -6187,10 +6205,12 @@ void __dev_notify_flags(struct net_device *dev, unsigned int old_flags,
 		rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges, GFP_ATOMIC);
 
 	if (changes & IFF_UP) {
-		if (dev->flags & IFF_UP)
+		if (dev->flags & IFF_UP) {
 			call_netdevice_notifiers(NETDEV_UP, dev);
-		else
+		} else {
 			call_netdevice_notifiers(NETDEV_DOWN, dev);
+			call_netdevice_notifiers(NETDEV_DOWN_BATCH, dev);
+		}
 	}
 
 	if (dev->flags & IFF_UP &&
@@ -6427,7 +6447,9 @@ static void net_set_todo(struct net_device *dev)
 static void rollback_registered_many(struct list_head *head)
 {
 	struct net_device *dev, *tmp;
+	struct net *net, *net_tmp;
 	LIST_HEAD(close_head);
+	LIST_HEAD(net_head);
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -6504,6 +6526,15 @@ static void rollback_registered_many(struct list_head *head)
 #endif
 	}
 
+	list_for_each_entry(dev, head, unreg_list) {
+		net_add_event_list(&net_head, dev_net(dev));
+	}
+	list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
+		call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH,
+					 net->loopback_dev);
+		net_del_event_list(net);
+	}
+
 	synchronize_net();
 
 	list_for_each_entry(dev, head, unreg_list)
@@ -7065,6 +7096,7 @@ static void netdev_wait_allrefs(struct net_device *dev)
 
 			/* Rebroadcast unregister notification */
 			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+			call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
 
 			__rtnl_unlock();
 			rcu_barrier();
@@ -7581,6 +7613,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	   the device is just moving and can keep their slaves up.
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
 	rcu_barrier();
 	call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
 	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
-- 
1.8.1.4
