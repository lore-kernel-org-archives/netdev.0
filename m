From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 03/11] net: l3mdev: Allow the l3mdev to be a loopback
Date: Sat, 10 Sep 2016 12:09:54 -0700
Message-ID: <1473534602-23602-4-git-send-email-dsa@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33763 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbcIJTL2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:28 -0400
Received: by mail-pa0-f46.google.com with SMTP id cm16so38640583pac.0
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:28 -0700 (PDT)
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow an L3 master device to act as the loopback for that L3 domain.
For IPv4 the device can also have the address 127.0.0.1.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h |  6 +++---
 net/ipv4/route.c     |  8 ++++++--
 net/ipv6/route.c     | 12 ++++++++++--
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 53d5274920e3..3ee110518584 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -90,7 +90,7 @@ static inline int l3mdev_master_ifindex_by_index(struct net *net, int ifindex)
 }
 
 static inline
-const struct net_device *l3mdev_master_dev_rcu(const struct net_device *_dev)
+struct net_device *l3mdev_master_dev_rcu(const struct net_device *_dev)
 {
 	/* netdev_master_upper_dev_get_rcu calls
 	 * list_first_or_null_rcu to walk the upper dev list.
@@ -99,7 +99,7 @@ const struct net_device *l3mdev_master_dev_rcu(const struct net_device *_dev)
 	 * typecast to remove the const
 	 */
 	struct net_device *dev = (struct net_device *)_dev;
-	const struct net_device *master;
+	struct net_device *master;
 
 	if (!dev)
 		return NULL;
@@ -254,7 +254,7 @@ static inline int l3mdev_master_ifindex_by_index(struct net *net, int ifindex)
 }
 
 static inline
-const struct net_device *l3mdev_master_dev_rcu(const struct net_device *dev)
+struct net_device *l3mdev_master_dev_rcu(const struct net_device *dev)
 {
 	return NULL;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3e992783c1d0..f49b2c534e92 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2018,7 +2018,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		return ERR_PTR(-EINVAL);
 
 	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev)))
-		if (ipv4_is_loopback(fl4->saddr) && !(dev_out->flags & IFF_LOOPBACK))
+		if (ipv4_is_loopback(fl4->saddr) &&
+		    !(dev_out->flags & IFF_LOOPBACK) &&
+		    !netif_is_l3_master(dev_out))
 			return ERR_PTR(-EINVAL);
 
 	if (ipv4_is_lbcast(fl4->daddr))
@@ -2302,7 +2304,9 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 			else
 				fl4->saddr = fl4->daddr;
 		}
-		dev_out = net->loopback_dev;
+
+		/* L3 master device is the loopback for that domain */
+		dev_out = l3mdev_master_dev_rcu(dev_out) ? : net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
 		flags |= RTCF_LOCAL;
 		goto make_route;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 09d43ff11a8d..2c681113c055 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2558,8 +2558,16 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 {
 	u32 tb_id;
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev,
-					    DST_NOCOUNT);
+	struct net_device *dev = net->loopback_dev;
+	struct rt6_info *rt;
+
+	/* use L3 Master device as loopback for host routes if device
+	 * is enslaved and address is not link local or multicast
+	 */
+	if (!rt6_need_strict(addr))
+		dev = l3mdev_master_dev_rcu(idev->dev) ? : dev;
+
+	rt = ip6_dst_alloc(net, dev, DST_NOCOUNT);
 	if (!rt)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.1.4
