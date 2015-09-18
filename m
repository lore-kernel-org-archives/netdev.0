From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 09/11] net: Move netif_index_is_l3_master to l3mdev.h
Date: Fri, 18 Sep 2015 10:06:23 -0700
Message-ID: <1442595985-7049-10-git-send-email-dsa@cumulusnetworks.com>
References: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, gospo@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36344 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbbIRRGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:06:49 -0400
Received: by padhk3 with SMTP id hk3so55836178pad.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 10:06:49 -0700 (PDT)
In-Reply-To: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change CONFIG dependency to CONFIG_NET_L3_MASTER_DEV as well.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/netdevice.h | 21 ---------------------
 include/net/l3mdev.h      | 24 ++++++++++++++++++++++++
 include/net/route.h       |  1 +
 3 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 796c65dfa0ff..daffe38b49fc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3839,27 +3839,6 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_OPENVSWITCH;
 }
 
-static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
-{
-	bool rc = false;
-
-#if IS_ENABLED(CONFIG_NET_VRF)
-	struct net_device *dev;
-
-	if (ifindex == 0)
-		return false;
-
-	rcu_read_lock();
-
-	dev = dev_get_by_index_rcu(net, ifindex);
-	if (dev)
-		rc = netif_is_l3_master(dev);
-
-	rcu_read_unlock();
-#endif
-	return rc;
-}
-
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 3892637d2f0e..8befd629f8ac 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -84,6 +84,25 @@ static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
 	return NULL;
 }
 
+static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
+{
+	struct net_device *dev;
+	bool rc = false;
+
+	if (ifindex == 0)
+		return false;
+
+	rcu_read_lock();
+
+	dev = dev_get_by_index_rcu(net, ifindex);
+	if (dev)
+		rc = netif_is_l3_master(dev);
+
+	rcu_read_unlock();
+
+	return rc;
+}
+
 #else
 
 static inline int l3mdev_master_ifindex_rcu(struct net_device *dev)
@@ -123,6 +142,11 @@ static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
 	return NULL;
 }
 
+static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
+{
+	return false;
+}
+
 #endif
 
 #endif /* _NET_L3MDEV_H_ */
diff --git a/include/net/route.h b/include/net/route.h
index 49c93d8733d3..aef6c9a38fcb 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -28,6 +28,7 @@
 #include <net/inetpeer.h>
 #include <net/flow.h>
 #include <net/inet_sock.h>
+#include <net/l3mdev.h>
 #include <linux/in_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/rcupdate.h>
-- 
1.9.1
