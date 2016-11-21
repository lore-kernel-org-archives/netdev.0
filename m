From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 1/7] net: Add net-device param to the get offloaded stats ndo
Date: Mon, 21 Nov 2016 15:05:55 +0200
Message-ID: <1479733561-26601-2-git-send-email-saeedm@mellanox.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46919 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932291AbcKUNHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:07:11 -0500
In-Reply-To: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Some drivers would need to check few internal matters for
that. To be used in downstream mlx5 commit.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 include/linux/netdevice.h                      | 4 ++--
 net/core/rtnetlink.c                           | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4a1f9d5..be32f47 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -857,7 +857,7 @@ mlxsw_sp_port_get_sw_stats64(const struct net_device *dev,
 	return 0;
 }
 
-static bool mlxsw_sp_port_has_offload_stats(int attr_id)
+static bool mlxsw_sp_port_has_offload_stats(struct net_device *dev, int attr_id)
 {
 	switch (attr_id) {
 	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e84800e..ae32a27 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -925,7 +925,7 @@ struct netdev_xdp {
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
  *
- * bool (*ndo_has_offload_stats)(int attr_id)
+ * bool (*ndo_has_offload_stats)(const struct net_device *dev, int attr_id)
  *	Return true if this device supports offload stats of this attr_id.
  *
  * int (*ndo_get_offload_stats)(int attr_id, const struct net_device *dev,
@@ -1165,7 +1165,7 @@ struct net_device_ops {
 
 	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
 						     struct rtnl_link_stats64 *storage);
-	bool			(*ndo_has_offload_stats)(int attr_id);
+	bool			(*ndo_has_offload_stats)(const struct net_device *dev, int attr_id);
 	int			(*ndo_get_offload_stats)(int attr_id,
 							 const struct net_device *dev,
 							 void *attr_data);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index db313ec..f5a8d8a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3665,7 +3665,7 @@ static int rtnl_get_offload_stats(struct sk_buff *skb, struct net_device *dev,
 		if (!size)
 			continue;
 
-		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
+		if (!dev->netdev_ops->ndo_has_offload_stats(dev, attr_id))
 			continue;
 
 		attr = nla_reserve_64bit(skb, attr_id, size,
@@ -3706,7 +3706,7 @@ static int rtnl_get_offload_stats_size(const struct net_device *dev)
 
 	for (attr_id = IFLA_OFFLOAD_XSTATS_FIRST;
 	     attr_id <= IFLA_OFFLOAD_XSTATS_MAX; attr_id++) {
-		if (!dev->netdev_ops->ndo_has_offload_stats(attr_id))
+		if (!dev->netdev_ops->ndo_has_offload_stats(dev, attr_id))
 			continue;
 		size = rtnl_get_offload_stats_attr_size(attr_id);
 		nla_size += nla_total_size_64bit(size);
-- 
2.7.4
