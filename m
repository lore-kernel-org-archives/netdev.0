From: David Ahern <dsahern@gmail.com>
Subject: [PATCH RFC net-next 2/6] net: Add flags argument to alloc_netdev_mqs
Date: Sat,  6 May 2017 10:07:30 -0600
Message-ID: <20170506160734.47084-3-dsahern@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32817 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbdEFQHp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:07:45 -0400
Received: by mail-pf0-f195.google.com with SMTP id b23so4395356pfc.0
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:07:44 -0700 (PDT)
In-Reply-To: <20170506160734.47084-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used in a later patch to pass in flags at create time

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 2 +-
 drivers/net/ethernet/tile/tilegx.c              | 2 +-
 drivers/net/tun.c                               | 2 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c | 2 +-
 include/linux/netdevice.h                       | 7 ++++---
 net/core/dev.c                                  | 5 ++++-
 net/core/rtnetlink.c                            | 2 +-
 net/ethernet/eth.c                              | 2 +-
 net/mac80211/iface.c                            | 2 +-
 9 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index 3c84e36af018..f5aaa92726a2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -446,7 +446,7 @@ static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 				  name, NET_NAME_UNKNOWN,
 				  setup,
 				  nch * MLX5E_MAX_NUM_TC,
-				  nch);
+				  nch, 0);
 	if (!netdev) {
 		mlx5_core_warn(mdev, "alloc_netdev_mqs failed\n");
 		goto free_mdev_resources;
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 7c634bc75615..f38067e260bd 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2198,7 +2198,7 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 	 * template, instantiated by register_netdev(), but not for us.
 	 */
 	dev = alloc_netdev_mqs(sizeof(*priv), name, NET_NAME_UNKNOWN,
-			       tile_net_setup, NR_CPUS, 1);
+			       tile_net_setup, NR_CPUS, 1, 0);
 	if (!dev) {
 		pr_err("alloc_netdev_mqs(%s) failed\n", name);
 		return;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bbd707b9ef7a..030621621ea8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1804,7 +1804,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		dev = alloc_netdev_mqs(sizeof(struct tun_struct), name,
 				       NET_NAME_UNKNOWN, tun_setup, queues,
-				       queues);
+				       queues, 0);
 
 		if (!dev)
 			return -ENOMEM;
diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index 7ec06bf13413..38b6570ff1cd 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -2960,7 +2960,7 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 
 	dev = alloc_netdev_mqs(sizeof(struct mwifiex_private *), name,
 			       name_assign_type, ether_setup,
-			       IEEE80211_NUM_ACS, 1);
+			       IEEE80211_NUM_ACS, 1, 0);
 	if (!dev) {
 		mwifiex_dbg(adapter, ERROR,
 			    "no memory available for netdevice\n");
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 305d2d42b349..f47c8712398a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3699,13 +3699,14 @@ void ether_setup(struct net_device *dev);
 struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 				    unsigned char name_assign_type,
 				    void (*setup)(struct net_device *),
-				    unsigned int txqs, unsigned int rxqs);
+				    unsigned int txqs, unsigned int rxqs,
+				    unsigned int flags);
 #define alloc_netdev(sizeof_priv, name, name_assign_type, setup) \
-	alloc_netdev_mqs(sizeof_priv, name, name_assign_type, setup, 1, 1)
+	alloc_netdev_mqs(sizeof_priv, name, name_assign_type, setup, 1, 1, 0)
 
 #define alloc_netdev_mq(sizeof_priv, name, name_assign_type, setup, count) \
 	alloc_netdev_mqs(sizeof_priv, name, name_assign_type, setup, count, \
-			 count)
+			 count, 0)
 
 int register_netdev(struct net_device *dev);
 void unregister_netdev(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index f166b3bf1895..48a0252037d5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7829,6 +7829,7 @@ void netdev_freemem(struct net_device *dev)
  * @setup: callback to initialize device
  * @txqs: the number of TX subqueues to allocate
  * @rxqs: the number of RX subqueues to allocate
+ * @flags: flags to 'or' with priv_flags
  *
  * Allocates a struct net_device with private data area for driver use
  * and performs basic initialization.  Also allocates subqueue structs
@@ -7837,7 +7838,8 @@ void netdev_freemem(struct net_device *dev)
 struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		unsigned char name_assign_type,
 		void (*setup)(struct net_device *),
-		unsigned int txqs, unsigned int rxqs)
+		unsigned int txqs, unsigned int rxqs,
+		unsigned int flags)
 {
 	struct net_device *dev;
 	size_t alloc_size;
@@ -7920,6 +7922,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	if (netif_alloc_rx_queues(dev))
 		goto free_all;
 #endif
+	dev->priv_flags |= flags;
 
 	strcpy(dev->name, name);
 	dev->name_assign_type = name_assign_type;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index bcb0f610ee42..a4db1cd91c4a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2390,7 +2390,7 @@ struct net_device *rtnl_create_link(struct net *net,
 		num_rx_queues = ops->get_num_rx_queues();
 
 	dev = alloc_netdev_mqs(ops->priv_size, ifname, name_assign_type,
-			       ops->setup, num_tx_queues, num_rx_queues);
+			       ops->setup, num_tx_queues, num_rx_queues, 0);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 1446810047f5..d8f489e134f0 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -389,7 +389,7 @@ struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 				      unsigned int rxqs)
 {
 	return alloc_netdev_mqs(sizeof_priv, "eth%d", NET_NAME_UNKNOWN,
-				ether_setup, txqs, rxqs);
+				ether_setup, txqs, rxqs, 0);
 }
 EXPORT_SYMBOL(alloc_etherdev_mqs);
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 3bd5b81f5d81..54891601e3d1 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1802,7 +1802,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 
 		ndev = alloc_netdev_mqs(size + txq_size,
 					name, name_assign_type,
-					if_setup, txqs, 1);
+					if_setup, txqs, 1, 0);
 		if (!ndev)
 			return -ENOMEM;
 		dev_net_set(ndev, wiphy_net(local->hw.wiphy));
-- 
2.11.0 (Apple Git-81)
