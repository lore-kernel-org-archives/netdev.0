From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 05/11] net: Replace vrf_dev_table and friends
Date: Tue, 29 Sep 2015 20:07:14 -0700
Message-ID: <1443582438-23823-6-git-send-email-dsa@cumulusnetworks.com>
References: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34326 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbbI3DHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 23:07:33 -0400
Received: by padhy16 with SMTP id hy16so24930300pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 20:07:33 -0700 (PDT)
In-Reply-To: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace calls to vrf_dev_table and friends with l3mdev_fib_table
and kin.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/vrf.h       | 80 -------------------------------------------------
 net/ipv4/af_inet.c      |  4 +--
 net/ipv4/fib_frontend.c |  7 ++---
 3 files changed, 5 insertions(+), 86 deletions(-)

diff --git a/include/net/vrf.h b/include/net/vrf.h
index 874a6c9e4217..b05b96646e2a 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -34,66 +34,6 @@ struct net_vrf {
 
 
 #if IS_ENABLED(CONFIG_NET_VRF)
-/* called with rcu_read_lock */
-static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
-{
-	u32 tb_id = 0;
-
-	if (dev) {
-		struct net_vrf_dev *vrf_ptr;
-
-		vrf_ptr = rcu_dereference(dev->vrf_ptr);
-		if (vrf_ptr)
-			tb_id = vrf_ptr->tb_id;
-	}
-	return tb_id;
-}
-
-static inline u32 vrf_dev_table(const struct net_device *dev)
-{
-	u32 tb_id;
-
-	rcu_read_lock();
-	tb_id = vrf_dev_table_rcu(dev);
-	rcu_read_unlock();
-
-	return tb_id;
-}
-
-static inline u32 vrf_dev_table_ifindex(struct net *net, int ifindex)
-{
-	struct net_device *dev;
-	u32 tb_id = 0;
-
-	if (!ifindex)
-		return 0;
-
-	rcu_read_lock();
-
-	dev = dev_get_by_index_rcu(net, ifindex);
-	if (dev)
-		tb_id = vrf_dev_table_rcu(dev);
-
-	rcu_read_unlock();
-
-	return tb_id;
-}
-
-/* called with rtnl */
-static inline u32 vrf_dev_table_rtnl(const struct net_device *dev)
-{
-	u32 tb_id = 0;
-
-	if (dev) {
-		struct net_vrf_dev *vrf_ptr;
-
-		vrf_ptr = rtnl_dereference(dev->vrf_ptr);
-		if (vrf_ptr)
-			tb_id = vrf_ptr->tb_id;
-	}
-	return tb_id;
-}
-
 /* caller has already checked netif_is_l3_master(dev) */
 static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
 {
@@ -108,26 +48,6 @@ static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
 }
 
 #else
-static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline u32 vrf_dev_table(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline u32 vrf_dev_table_ifindex(struct net *net, int ifindex)
-{
-	return 0;
-}
-
-static inline u32 vrf_dev_table_rtnl(const struct net_device *dev)
-{
-	return 0;
-}
-
 static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
 {
 	return ERR_PTR(-ENETUNREACH);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8a556643b874..0df3f0527648 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -119,7 +119,7 @@
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
-#include <net/vrf.h>
+#include <net/l3mdev.h>
 
 
 /* The inetsw table contains everything that inet_create needs to
@@ -450,7 +450,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	tb_id = vrf_dev_table_ifindex(net, sk->sk_bound_dev_if) ? : tb_id;
+	tb_id = l3mdev_fib_table_by_index(net, sk->sk_bound_dev_if) ? : tb_id;
 	chk_addr_ret = inet_addr_type_table(net, addr->sin_addr.s_addr, tb_id);
 
 	/* Not specified by any standard per-se, however it breaks too
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b901b344f22d..fac172370276 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -45,7 +45,6 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
-#include <net/vrf.h>
 #include <net/l3mdev.h>
 #include <trace/events/fib.h>
 
@@ -256,7 +255,7 @@ EXPORT_SYMBOL(inet_addr_type);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
-	u32 rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+	u32 rt_table = l3mdev_fib_table(dev) ? : RT_TABLE_LOCAL;
 
 	return __inet_dev_addr_type(net, dev, addr, rt_table);
 }
@@ -269,7 +268,7 @@ unsigned int inet_addr_type_dev_table(struct net *net,
 				      const struct net_device *dev,
 				      __be32 addr)
 {
-	u32 rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+	u32 rt_table = l3mdev_fib_table(dev) ? : RT_TABLE_LOCAL;
 
 	return __inet_dev_addr_type(net, NULL, addr, rt_table);
 }
@@ -804,7 +803,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
 	struct net *net = dev_net(ifa->ifa_dev->dev);
-	u32 tb_id = vrf_dev_table_rtnl(ifa->ifa_dev->dev);
+	u32 tb_id = l3mdev_fib_table(ifa->ifa_dev->dev);
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
-- 
1.9.1
