From: Amir Vadai <amirv@mellanox.com>
Subject: [RFC 2/2] net/mlx4_en: Use pm_qos API to avoid packet loss in high CPU c-states
Date: Tue, 25 Mar 2014 15:18:25 +0200
Message-ID: <1395753505-13180-3-git-send-email-amirv@mellanox.com>
References: <1395753505-13180-1-git-send-email-amirv@mellanox.com>
Cc: linux-pm@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, yuvali@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, idos@mellanox.com,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49057 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753121AbaCYNTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 09:19:07 -0400
In-Reply-To: <1395753505-13180-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TODO: change this patch to use the new per core api

In order to avoid packet loss during traffic, we need to limit the CPU
wake up time, as long as we have work to do.
We restore the system default when there's no traffic.

Feature could be enabled/disabled using a private flag in ethtool:
$ ethtool --set-priv-flags eth10 pm_qos_request_low_latency on
$ ethtool --show-priv-flags eth10
Private flags for eth10:
pm_qos_request_low_latency: on


Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 37 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 40 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  7 +++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 13 ++++++++
 4 files changed, 97 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 3e8d336..5a43992 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -34,6 +34,7 @@
 #include <linux/kernel.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/pm_qos.h>
 #include <linux/mlx4/driver.h>
 #include <linux/in.h>
 #include <net/ip.h>
@@ -98,6 +99,10 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	drvinfo->eedump_len = 0;
 }
 
+static const char mlx4_en_priv_flags[][ETH_GSTRING_LEN] = {
+	"pm_qos_request_low_latency",
+};
+
 static const char main_strings[][ETH_GSTRING_LEN] = {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
@@ -235,6 +240,8 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_TEST:
 		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UC_LOOPBACK) * 2;
+	case ETH_SS_PRIV_FLAGS:
+		return ARRAY_SIZE(mlx4_en_priv_flags);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -358,6 +365,10 @@ static void mlx4_en_get_strings(struct net_device *dev,
 #endif
 		}
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		for (i = 0; i < ARRAY_SIZE(mlx4_en_priv_flags); i++)
+			strcpy(data + i * ETH_GSTRING_LEN, mlx4_en_priv_flags[i]);
+		break;
 	}
 }
 
@@ -1201,6 +1212,29 @@ static int mlx4_en_get_ts_info(struct net_device *dev,
 	return ret;
 }
 
+int mlx4_en_set_priv_flags(struct net_device *dev, u32 flag)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int cpu = smp_processor_id();
+	u32 flags = priv->pflags;
+
+	if (flags & MLX4_EN_PRIV_FLAGS_PM_QOS) {
+		priv->pflags |= MLX4_EN_PRIV_FLAGS_PM_QOS;
+	} else {
+		pm_qos_update_request(&priv->pm_qos_req, PM_QOS_DEFAULT_VALUE);
+		priv->last_cpu_dma_latency = PM_QOS_DEFAULT_VALUE;
+		priv->pflags &= ~MLX4_EN_PRIV_FLAGS_PM_QOS;
+	}
+
+	return 0;
+}
+
+u32 mlx4_en_get_priv_flags(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	return priv->pflags;
+}
+
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -1228,6 +1262,9 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_channels = mlx4_en_get_channels,
 	.set_channels = mlx4_en_set_channels,
 	.get_ts_info = mlx4_en_get_ts_info,
+
+	.set_priv_flags = mlx4_en_set_priv_flags,
+	.get_priv_flags = mlx4_en_get_priv_flags,
 };
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 84a96f7..fb3fe6d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1404,6 +1404,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	priv->sample_interval = MLX4_EN_SAMPLE_INTERVAL;
 	priv->adaptive_rx_coal = 1;
 	priv->last_moder_jiffies = 0;
+	priv->last_cstate_jiffies = 0;
 	priv->last_moder_tx_packets = 0;
 }
 
@@ -1470,6 +1471,33 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 	priv->last_moder_jiffies = jiffies;
 }
 
+static void mlx4_en_default_cstate(struct mlx4_en_priv *priv)
+{
+	unsigned long period = (unsigned long)
+				(jiffies - priv->last_cstate_jiffies);
+	unsigned long packets = 0;
+	unsigned long global_rate = 0;
+	int ring;
+
+	if (!(priv->pflags & MLX4_EN_PRIV_FLAGS_PM_QOS) ||
+	    period < priv->sample_interval * HZ)
+		return;
+
+	for (ring = 0; ring < priv->rx_ring_num; ring++)
+		packets += priv->rx_ring[ring]->packets;
+
+	global_rate = (packets - priv->last_packets) * HZ / period;
+	priv->last_packets = packets;
+
+	if ((global_rate < MLX4_EN_RX_RATE_THRESH) &&
+	    (priv->last_cpu_dma_latency == 0)) {
+		pm_qos_update_request(&priv->pm_qos_req,
+				      PM_QOS_DEFAULT_VALUE);
+		priv->last_cpu_dma_latency = PM_QOS_DEFAULT_VALUE;
+	}
+	priv->last_cstate_jiffies = jiffies;
+}
+
 static void mlx4_en_do_get_stats(struct work_struct *work)
 {
 	struct delayed_work *delay = to_delayed_work(work);
@@ -1486,6 +1514,7 @@ static void mlx4_en_do_get_stats(struct work_struct *work)
 				en_dbg(HW, priv, "Could not update stats\n");
 
 			mlx4_en_auto_moderation(priv);
+			mlx4_en_default_cstate(priv);
 		}
 
 		queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
@@ -2073,6 +2102,10 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	mdev->pndev[priv->port] = NULL;
 	mutex_unlock(&mdev->state_lock);
 
+	/* Remove pm_qos request, after reseting to default value */
+	pm_qos_update_request(&priv->pm_qos_req, PM_QOS_DEFAULT_VALUE);
+	pm_qos_remove_request(&priv->pm_qos_req);
+
 	mlx4_en_free_resources(priv);
 
 	kfree(priv->tx_ring);
@@ -2452,6 +2485,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		en_err(priv, "Failed to allocate page for rx qps\n");
 		goto out;
 	}
+
+	/* Initialize pm_qos request object */
+	priv->last_cpu_dma_latency = PM_QOS_DEFAULT_VALUE;
+	pm_qos_add_request(&priv->pm_qos_req,
+			   PM_QOS_CPU_DMA_LATENCY,
+			   PM_QOS_DEFAULT_VALUE);
+
 	priv->allocated = 1;
 
 	/*
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 890922c..1823119 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -865,6 +865,13 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	if (!mlx4_en_cq_lock_napi(cq))
 		return budget;
 
+	/* Request best DMA latency possible from CPU while in traffic */
+	if (priv->pflags & MLX4_EN_PRIV_FLAGS_PM_QOS &&
+	    priv->last_cpu_dma_latency != 0) {
+		pm_qos_update_request(&priv->pm_qos_req, 0);
+		priv->last_cpu_dma_latency = 0;
+	}
+
 	done = mlx4_en_process_rx_cq(dev, cq, budget);
 
 	mlx4_en_cq_unlock_napi(cq);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index b57e8c8..72f0337 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -41,6 +41,8 @@
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/net_tstamp.h>
+#include <linux/pm_qos.h>
+
 #ifdef CONFIG_MLX4_EN_DCB
 #include <linux/dcbnl.h>
 #endif
@@ -478,6 +480,10 @@ enum {
 	MLX4_EN_FLAG_FORCE_PROMISC	= (1 << 4)
 };
 
+enum {
+       MLX4_EN_PRIV_FLAGS_PM_QOS = (1 << 0)
+};
+
 #define MLX4_EN_MAC_HASH_SIZE (1 << BITS_PER_BYTE)
 #define MLX4_EN_MAC_HASH_IDX 5
 
@@ -513,6 +519,12 @@ struct mlx4_en_priv {
 	u32 loopback_ok;
 	u32 validate_loopback;
 
+	/* pm_qos related variables */
+	unsigned long last_cstate_jiffies;
+	unsigned long last_packets;
+	int last_cpu_dma_latency;
+	struct pm_qos_request pm_qos_req;
+
 	struct mlx4_hwq_resources res;
 	int link_state;
 	int last_link_state;
@@ -530,6 +542,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_rss_map rss_map;
 	__be32 ctrl_flags;
 	u32 flags;
+	u32 pflags;
 	u8 num_tx_rings_p_up;
 	u32 tx_ring_num;
 	u32 rx_ring_num;
-- 
1.8.3.4
