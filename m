From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx4_en: Add accelerated RFS support
Date: Wed, 18 Jul 2012 17:19:22 +0300
Message-ID: <1342621162-18498-5-git-send-email-ogerlitz@mellanox.com>
References: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:46207 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752745Ab2GROTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 10:19:32 -0400
In-Reply-To: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Use RFS infrastructure and flow steering in HW to keep CPU
affinity of rx interrupts and application per TCP stream.

A flow steering filter is added to the HW whenever the RFS
ndo callback is invoked by core networking code.

Because the invocation takes place in interrupt context, the
actual setup of HW is done using workqueue. Whenever new filter
is added, the driver checks for expiry of existing filters.

Since there's window in time between the point where the core
RFS code invoked the ndo callback, to the point where the HW
is configured from the workqueue context, the 2nd, 3rd etc
packets from that stream will cause the net core to invoke
the callback again and again.

To prevent inefficient/double configuration of the HW, the filters
are kept in a database which is indexed using hash function to enable
fast access.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |    8 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  316 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    3 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   16 ++
 4 files changed, 342 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 0ef6156..2d6f1ba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -77,6 +77,12 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err = 0;
 	char name[25];
+	struct cpu_rmap *rmap =
+#ifdef CONFIG_CPU_RMAP
+		priv->dev->rx_cpu_rmap;
+#else
+		NULL;
+#endif
 
 	cq->dev = mdev->pndev[priv->port];
 	cq->mcq.set_ci_db  = cq->wqres.db.db;
@@ -91,7 +97,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 				sprintf(name, "%s-%d", priv->dev->name,
 					cq->ring);
 				/* Set IRQ for specific name (per ring) */
-				if (mlx4_assign_eq(mdev->dev, name, NULL,
+				if (mlx4_assign_eq(mdev->dev, name, rmap,
 						   &cq->vector)) {
 					cq->vector = (cq->ring + 1 + priv->port)
 					    % mdev->dev->caps.num_comp_vectors;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4ce5ca8..8864d8b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -36,6 +36,8 @@
 #include <linux/if_vlan.h>
 #include <linux/delay.h>
 #include <linux/slab.h>
+#include <linux/hash.h>
+#include <net/ip.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
@@ -66,6 +68,299 @@ static int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	return 0;
 }
 
+#ifdef CONFIG_RFS_ACCEL
+
+struct mlx4_en_filter {
+	struct list_head next;
+	struct work_struct work;
+
+	__be32 src_ip;
+	__be32 dst_ip;
+	__be16 src_port;
+	__be16 dst_port;
+
+	int rxq_index;
+	struct mlx4_en_priv *priv;
+	u32 flow_id;			/* RFS infrastructure id */
+	int id;				/* mlx4_en driver id */
+	u64 reg_id;			/* Flow steering API id */
+	u8 activated;			/* Used to prevent expiry before filter
+					 * is attached
+					 */
+	struct hlist_node filter_chain;
+};
+
+static void mlx4_en_filter_rfs_expire(struct mlx4_en_priv *priv);
+
+static void mlx4_en_filter_work(struct work_struct *work)
+{
+	struct mlx4_en_filter *filter = container_of(work,
+						     struct mlx4_en_filter,
+						     work);
+	struct mlx4_en_priv *priv = filter->priv;
+	struct mlx4_spec_list spec_tcp = {
+		.id = MLX4_NET_TRANS_RULE_ID_TCP,
+		{
+			.tcp_udp = {
+				.dst_port = filter->dst_port,
+				.dst_port_msk = (__force __be16)-1,
+				.src_port = filter->src_port,
+				.src_port_msk = (__force __be16)-1,
+			},
+		},
+	};
+	struct mlx4_spec_list spec_ip = {
+		.id = MLX4_NET_TRANS_RULE_ID_IPV4,
+		{
+			.ipv4 = {
+				.dst_ip = filter->dst_ip,
+				.dst_ip_msk = (__force __be32)-1,
+				.src_ip = filter->src_ip,
+				.src_ip_msk = (__force __be32)-1,
+			},
+		},
+	};
+	struct mlx4_spec_list spec_eth = {
+		.id = MLX4_NET_TRANS_RULE_ID_ETH,
+	};
+	struct mlx4_net_trans_rule rule = {
+		.list = LIST_HEAD_INIT(rule.list),
+		.queue_mode = MLX4_NET_TRANS_Q_LIFO,
+		.exclusive = 1,
+		.allow_loopback = 1,
+		.promisc_mode = MLX4_FS_PROMISC_NONE,
+		.port = priv->port,
+		.priority = MLX4_DOMAIN_RFS,
+	};
+	int rc;
+	__be64 mac;
+	__be64 mac_mask = cpu_to_be64(MLX4_MAC_MASK << 16);
+
+	list_add_tail(&spec_eth.list, &rule.list);
+	list_add_tail(&spec_ip.list, &rule.list);
+	list_add_tail(&spec_tcp.list, &rule.list);
+
+	mac = cpu_to_be64((priv->mac & MLX4_MAC_MASK) << 16);
+
+	rule.qpn = priv->rss_map.qps[filter->rxq_index].qpn;
+	memcpy(spec_eth.eth.dst_mac, &mac, ETH_ALEN);
+	memcpy(spec_eth.eth.dst_mac_msk, &mac_mask, ETH_ALEN);
+
+	filter->activated = 0;
+
+	if (filter->reg_id) {
+		rc = mlx4_flow_detach(priv->mdev->dev, filter->reg_id);
+		if (rc && rc != -ENOENT)
+			en_err(priv, "Error detaching flow. rc = %d\n", rc);
+	}
+
+	rc = mlx4_flow_attach(priv->mdev->dev, &rule, &filter->reg_id);
+	if (rc)
+		en_err(priv, "Error attaching flow. err = %d\n", rc);
+
+	mlx4_en_filter_rfs_expire(priv);
+
+	filter->activated = 1;
+}
+
+static inline struct hlist_head *
+filter_hash_bucket(struct mlx4_en_priv *priv, __be32 src_ip, __be32 dst_ip,
+		   __be16 src_port, __be16 dst_port)
+{
+	unsigned long l;
+	int bucket_idx;
+
+	l = (__force unsigned long)src_port |
+	    ((__force unsigned long)dst_port << 2);
+	l ^= (__force unsigned long)(src_ip ^ dst_ip);
+
+	bucket_idx = hash_long(l, MLX4_EN_FILTER_HASH_SHIFT);
+
+	return &priv->filter_hash[bucket_idx];
+}
+
+static struct mlx4_en_filter *
+mlx4_en_filter_alloc(struct mlx4_en_priv *priv, int rxq_index, __be32 src_ip,
+		     __be32 dst_ip, __be16 src_port, __be16 dst_port,
+		     u32 flow_id)
+{
+	struct mlx4_en_filter *filter = NULL;
+
+	filter = kzalloc(sizeof(struct mlx4_en_filter), GFP_ATOMIC);
+	if (!filter)
+		return NULL;
+
+	filter->priv = priv;
+	filter->rxq_index = rxq_index;
+	INIT_WORK(&filter->work, mlx4_en_filter_work);
+
+	filter->src_ip = src_ip;
+	filter->dst_ip = dst_ip;
+	filter->src_port = src_port;
+	filter->dst_port = dst_port;
+
+	filter->flow_id = flow_id;
+
+	filter->id = priv->last_filter_id++;
+
+	list_add_tail(&filter->next, &priv->filters);
+	hlist_add_head(&filter->filter_chain,
+		       filter_hash_bucket(priv, src_ip, dst_ip, src_port,
+					  dst_port));
+
+	return filter;
+}
+
+static void mlx4_en_filter_free(struct mlx4_en_filter *filter)
+{
+	struct mlx4_en_priv *priv = filter->priv;
+	int rc;
+
+	list_del(&filter->next);
+
+	rc = mlx4_flow_detach(priv->mdev->dev, filter->reg_id);
+	if (rc && rc != -ENOENT)
+		en_err(priv, "Error detaching flow. rc = %d\n", rc);
+
+	kfree(filter);
+}
+
+static inline struct mlx4_en_filter *
+mlx4_en_filter_find(struct mlx4_en_priv *priv, __be32 src_ip, __be32 dst_ip,
+		    __be16 src_port, __be16 dst_port)
+{
+	struct hlist_node *elem;
+	struct mlx4_en_filter *filter;
+	struct mlx4_en_filter *ret = NULL;
+
+	hlist_for_each_entry(filter, elem,
+			     filter_hash_bucket(priv, src_ip, dst_ip,
+						src_port, dst_port),
+			     filter_chain) {
+		if (filter->src_ip == src_ip &&
+		    filter->dst_ip == dst_ip &&
+		    filter->src_port == src_port &&
+		    filter->dst_port == dst_port) {
+			ret = filter;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+static int
+mlx4_en_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+		   u16 rxq_index, u32 flow_id)
+{
+	struct mlx4_en_priv *priv = netdev_priv(net_dev);
+	struct mlx4_en_filter *filter;
+	const struct iphdr *ip;
+	const __be16 *ports;
+	__be32 src_ip;
+	__be32 dst_ip;
+	__be16 src_port;
+	__be16 dst_port;
+	int nhoff = skb_network_offset(skb);
+	int ret = 0;
+
+	if (skb->protocol != htons(ETH_P_IP))
+		return -EPROTONOSUPPORT;
+
+	ip = (const struct iphdr *)(skb->data + nhoff);
+	if (ip_is_fragment(ip))
+		return -EPROTONOSUPPORT;
+
+	ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
+
+	src_ip = ip->saddr;
+	dst_ip = ip->daddr;
+	src_port = ports[0];
+	dst_port = ports[1];
+
+	if (ip->protocol != IPPROTO_TCP)
+		return -EPROTONOSUPPORT;
+
+	spin_lock_bh(&priv->filters_lock);
+	filter = mlx4_en_filter_find(priv, src_ip, dst_ip, src_port, dst_port);
+	if (filter) {
+		if (filter->rxq_index == rxq_index)
+			goto out;
+
+		filter->rxq_index = rxq_index;
+	} else {
+		filter = mlx4_en_filter_alloc(priv, rxq_index,
+					      src_ip, dst_ip,
+					      src_port, dst_port, flow_id);
+		if (!filter) {
+			ret = -ENOMEM;
+			goto err;
+		}
+	}
+
+	queue_work(priv->mdev->workqueue, &filter->work);
+
+out:
+	ret = filter->id;
+err:
+	spin_unlock_bh(&priv->filters_lock);
+
+	return ret;
+}
+
+void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv,
+			     struct mlx4_en_rx_ring *rx_ring)
+{
+	struct mlx4_en_filter *filter, *tmp;
+	LIST_HEAD(del_list);
+
+	spin_lock_bh(&priv->filters_lock);
+	list_for_each_entry_safe(filter, tmp, &priv->filters, next) {
+		list_move(&filter->next, &del_list);
+		hlist_del(&filter->filter_chain);
+	}
+	spin_unlock_bh(&priv->filters_lock);
+
+	list_for_each_entry_safe(filter, tmp, &del_list, next) {
+		cancel_work_sync(&filter->work);
+		mlx4_en_filter_free(filter);
+	}
+}
+
+static void mlx4_en_filter_rfs_expire(struct mlx4_en_priv *priv)
+{
+	struct mlx4_en_filter *filter = NULL, *tmp, *last_filter = NULL;
+	LIST_HEAD(del_list);
+	int i = 0;
+
+	spin_lock_bh(&priv->filters_lock);
+	list_for_each_entry_safe(filter, tmp, &priv->filters, next) {
+		if (i > MLX4_EN_FILTER_EXPIRY_QUOTA)
+			break;
+
+		if (filter->activated &&
+		    !work_pending(&filter->work) &&
+		    rps_may_expire_flow(priv->dev,
+					filter->rxq_index, filter->flow_id,
+					filter->id)) {
+			list_move(&filter->next, &del_list);
+			hlist_del(&filter->filter_chain);
+		} else
+			last_filter = filter;
+
+		i++;
+	}
+
+	if (last_filter && (&last_filter->next != priv->filters.next))
+		list_move(&priv->filters, &last_filter->next);
+
+	spin_unlock_bh(&priv->filters_lock);
+
+	list_for_each_entry_safe(filter, tmp, &del_list, next)
+		mlx4_en_filter_free(filter);
+}
+#endif
+
 static int mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -1079,6 +1374,11 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 {
 	int i;
 
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(priv->dev->rx_cpu_rmap);
+	priv->dev->rx_cpu_rmap = NULL;
+#endif
+
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		if (priv->tx_ring[i].tx_info)
 			mlx4_en_destroy_tx_ring(priv, &priv->tx_ring[i]);
@@ -1134,6 +1434,15 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 			goto err;
 	}
 
+#ifdef CONFIG_RFS_ACCEL
+	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->rx_ring_num);
+	if (!priv->dev->rx_cpu_rmap)
+		goto err;
+
+	INIT_LIST_HEAD(&priv->filters);
+	spin_lock_init(&priv->filters_lock);
+#endif
+
 	return 0;
 
 err:
@@ -1241,6 +1550,9 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
 	.ndo_setup_tc		= mlx4_en_setup_tc,
+#ifdef CONFIG_RFS_ACCEL
+	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
+#endif
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
@@ -1358,6 +1670,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			NETIF_F_HW_VLAN_FILTER;
 	dev->hw_features |= NETIF_F_LOOPBACK;
 
+	if (mdev->dev->caps.steering_mode ==
+	    MLX4_STEERING_MODE_DEVICE_MANAGED)
+		dev->hw_features |= NETIF_F_NTUPLE;
+
 	mdev->pndev[port] = dev;
 
 	netif_carrier_off(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a04cbf7..796cd58 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -389,6 +389,9 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
+#ifdef CONFIG_RFS_ACCEL
+	mlx4_en_cleanup_filters(priv, ring);
+#endif
 }
 
 void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a126321..af34c98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -43,6 +43,7 @@
 #ifdef CONFIG_MLX4_EN_DCB
 #include <linux/dcbnl.h>
 #endif
+#include <linux/cpu_rmap.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/qp.h>
@@ -77,6 +78,9 @@
 #define STATS_DELAY		(HZ / 4)
 #define MAX_NUM_OF_FS_RULES	256
 
+#define MLX4_EN_FILTER_HASH_SHIFT 4
+#define MLX4_EN_FILTER_EXPIRY_QUOTA 60
+
 /* Typical TSO descriptor with 16 gather entries is 352 bytes... */
 #define MAX_DESC_SIZE		512
 #define MAX_DESC_TXBBS		(MAX_DESC_SIZE / TXBB_SIZE)
@@ -523,6 +527,13 @@ struct mlx4_en_priv {
 	struct ieee_ets ets;
 	u16 maxrate[IEEE_8021QAZ_MAX_TCS];
 #endif
+#ifdef CONFIG_RFS_ACCEL
+	spinlock_t filters_lock;
+	int last_filter_id;
+	struct list_head filters;
+	struct hlist_head filter_hash[1 << MLX4_EN_FILTER_HASH_SHIFT];
+#endif
+
 };
 
 enum mlx4_en_wol {
@@ -602,6 +613,11 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops;
 #endif
 
+#ifdef CONFIG_RFS_ACCEL
+void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv,
+			     struct mlx4_en_rx_ring *rx_ring);
+#endif
+
 #define MLX4_EN_NUM_SELF_TEST	5
 void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf);
 u64 mlx4_en_mac_to_u64(u8 *addr);
-- 
1.7.1
