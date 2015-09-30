From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 09/11] net: Move netif_index_is_l3_master to l3mdev.h
Date: Tue, 29 Sep 2015 20:07:18 -0700
Message-ID: <1443582438-23823-10-git-send-email-dsa@cumulusnetworks.com>
References: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34436 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbbI3DHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 23:07:39 -0400
Received: by padhy16 with SMTP id hy16so24932941pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 20:07:39 -0700 (PDT)
In-Reply-To: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
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
index 72bf9e37a2f0..b9450784ae06 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3840,27 +3840,6 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
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
index e382c777bab8..87cee05a0a17 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -81,6 +81,25 @@ static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
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
@@ -120,6 +139,11 @@ static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
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
index a565d0dad12c..e211dc167db1 100644
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
