From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 3/3] fix bad macro definition
Date: Wed, 12 Sep 2007 14:38:14 +0200
Message-ID: <20070912124429.288622995@mai.toulouse-stg.fr.ibm.com>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org, Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:12858 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966136AbXILMqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:46:16 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8CCkFL7034874
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:46:15 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CCkFWM2261000
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:46:15 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CCkEFj001006
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:46:14 +0200
Content-Disposition: inline; filename=net-fix-llc-core-init-panic.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

The macro definition is bad. When calling next_net_device with 
parameter name "dev", the resulting code is:
	  struct net_device *dev = dev and that leads to an unexpected
behavior. Especially when llc_core is compiled in, the kernel panics
at boot time.
The patchset change macro definition with static inline functions as
they were defined before.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/linux/netdevice.h |   35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

Index: net-2.6.24/include/linux/netdevice.h
===================================================================
--- net-2.6.24.orig/include/linux/netdevice.h
+++ net-2.6.24/include/linux/netdevice.h
@@ -41,7 +41,8 @@
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 
-struct net;
+#include <net/net_namespace.h>
+
 struct vlan_group;
 struct ethtool_ops;
 struct netpoll_info;
@@ -739,23 +740,21 @@
 		list_for_each_entry_continue(d, &(net)->dev_base_head, dev_list)
 #define net_device_entry(lh)	list_entry(lh, struct net_device, dev_list)
 
-#define next_net_device(d) 						\
-({									\
-	struct net_device *dev = d;					\
-	struct list_head *lh;						\
-	struct net *net;						\
-									\
-	net = dev->nd_net;						\
-	lh = dev->dev_list.next;					\
-	lh == &net->dev_base_head ? NULL : net_device_entry(lh);	\
-})
-
-#define first_net_device(N)					\
-({								\
-	struct net *NET = (N);					\
-	list_empty(&NET->dev_base_head) ? NULL :		\
-		net_device_entry(NET->dev_base_head.next);	\
-})
+static inline struct net_device *next_net_device(struct net_device *dev)
+{
+	struct list_head *lh;
+	struct net *net;
+
+	net = dev->nd_net;
+        lh = dev->dev_list.next;
+	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
+}
+
+static inline struct net_device *first_net_device(struct net *net)
+{
+	return list_empty(&net->dev_base_head) ? NULL :
+		net_device_entry(net->dev_base_head.next);
+}
 
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);

-- 
