From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: l3mdev: Allow send on enslaved interface
Date: Wed,  4 May 2016 21:54:10 -0700
Message-ID: <1462424050-16084-3-git-send-email-dsa@cumulusnetworks.com>
References: <1462424050-16084-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33264 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbcEEEy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 00:54:28 -0400
Received: by mail-pf0-f177.google.com with SMTP id 206so33448083pfu.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 21:54:28 -0700 (PDT)
In-Reply-To: <1462424050-16084-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow udp and raw sockets to send by oif that is an enslaved interface
versus the l3mdev/VRF device. For example, this allows BFD to use ifindex
from IP_PKTINFO on a receive to send a response without the need to
convert to the VRF index. It also allows ping and ping6 to work when
specifying an enslaved interface (e.g., ping -I swp1 <ip>) which is
a natural use case.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c   |  2 ++
 net/ipv4/route.c    |  4 ++++
 net/l3mdev/l3mdev.c | 20 +++++++++++++++-----
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 4b2461ae5d3b..c8db55aa8280 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -648,6 +648,8 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 
 	fl4->flowi4_flags |= FLOWI_FLAG_SKIP_NH_OIF;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
+	/* make sure oif is set to VRF device for lookup */
+	fl4->flowi4_oif = dev->ifindex;
 	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
 	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
 			     RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8c8c655bb2c4..a1f2830d8110 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2146,6 +2146,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
+	int master_idx;
 	int orig_oif;
 	int err = -ENETUNREACH;
 
@@ -2155,6 +2156,9 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 
 	orig_oif = fl4->flowi4_oif;
 
+	master_idx = l3mdev_master_ifindex_by_index(net, fl4->flowi4_oif);
+	if (master_idx)
+		fl4->flowi4_oif = master_idx;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
 	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 0fe4211e646f..0fd8cc1417cd 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -112,12 +112,19 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
 	struct dst_entry *dst = NULL;
 	struct net_device *dev;
 
-	dev = dev_get_by_index(net, fl6->flowi6_oif);
-	if (dev) {
-		if (netif_is_l3_master(dev) &&
-		    dev->l3mdev_ops->l3mdev_get_rt6_dst)
+	if (fl6->flowi6_oif) {
+		rcu_read_lock();
+
+		dev = dev_get_by_index_rcu(net, fl6->flowi6_oif);
+		if (dev && netif_is_l3_slave(dev))
+			dev = netdev_master_upper_dev_get_rcu(dev);
+
+		if (dev && netif_is_l3_master(dev) &&
+		    dev->l3mdev_ops->l3mdev_get_rt6_dst) {
 			dst = dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6);
-		dev_put(dev);
+		}
+
+		rcu_read_unlock();
 	}
 
 	return dst;
@@ -141,6 +148,9 @@ int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4)
 		rcu_read_lock();
 
 		dev = dev_get_by_index_rcu(net, ifindex);
+		if (dev && netif_is_l3_slave(dev))
+			dev = netdev_master_upper_dev_get_rcu(dev);
+
 		if (dev && netif_is_l3_master(dev) &&
 		    dev->l3mdev_ops->l3mdev_get_saddr) {
 			rc = dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
-- 
2.1.4
