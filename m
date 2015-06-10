From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 13/13] net/mlx4_en: Support ndo_get_vf_stats
Date: Wed, 10 Jun 2015 17:59:38 +0300
Message-ID: <1433948378-17570-14-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37941 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932161AbbFJPAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:00:53 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Implement function to gather vf statistics through the PF. The function
is provided in the master net device ops.

All VFs counters are stored in list per slave, run over the slave's list
and collect all statistics.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   29 ++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   10 ++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    2 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   48 ++++++++++++++++++++
 include/linux/mlx4/cmd.h                           |    3 +
 5 files changed, 92 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 4495bbd..c438e56 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -3223,6 +3223,35 @@ if_stat_out:
 }
 EXPORT_SYMBOL_GPL(mlx4_get_counter_stats);
 
+int mlx4_get_vf_stats(struct mlx4_dev *dev, int port, int vf_idx,
+		      struct rtnl_link_vf_stats64 *vf_stats)
+{
+	struct mlx4_counter tmp_vf_stats;
+	int slave;
+	int err = 0;
+
+	if (!vf_stats)
+		return -EINVAL;
+
+	if (!mlx4_is_master(dev))
+		return -EPROTONOSUPPORT;
+
+	slave = mlx4_get_slave_indx(dev, vf_idx);
+	if (slave < 0)
+		return -EINVAL;
+
+	err = mlx4_calc_vf_counters(dev, slave, port, &tmp_vf_stats);
+	if (!err && tmp_vf_stats.counter_mode == 0) {
+		vf_stats->rx_packets = be64_to_cpu(tmp_vf_stats.rx_frames);
+		vf_stats->tx_packets = be64_to_cpu(tmp_vf_stats.tx_frames);
+		vf_stats->rx_bytes = be64_to_cpu(tmp_vf_stats.rx_bytes);
+		vf_stats->tx_bytes = be64_to_cpu(tmp_vf_stats.tx_bytes);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_get_vf_stats);
+
 int mlx4_vf_smi_enabled(struct mlx4_dev *dev, int slave, int port)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f9142f2..6b816aa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2292,6 +2292,15 @@ static int mlx4_en_set_vf_link_state(struct net_device *dev, int vf, int link_st
 	return mlx4_set_vf_link_state(mdev->dev, en_priv->port, vf, link_state);
 }
 
+static int mlx4_en_get_vf_stats(struct net_device *dev, int vf,
+				struct rtnl_link_vf_stats64 *vf_stats)
+{
+	struct mlx4_en_priv *en_priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = en_priv->mdev;
+
+	return mlx4_get_vf_stats(mdev->dev, en_priv->port, vf, vf_stats);
+}
+
 #define PORT_ID_BYTE_LEN 8
 static int mlx4_en_get_phys_port_id(struct net_device *dev,
 				    struct netdev_phys_item_id *ppid)
@@ -2489,6 +2498,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_set_vf_rate	= mlx4_en_set_vf_rate,
 	.ndo_set_vf_spoofchk	= mlx4_en_set_vf_spoofchk,
 	.ndo_set_vf_link_state	= mlx4_en_set_vf_link_state,
+	.ndo_get_vf_stats       = mlx4_en_get_vf_stats,
 	.ndo_get_vf_config	= mlx4_en_get_vf_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= mlx4_en_netpoll,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index e9e94bc..a092c5c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1010,6 +1010,8 @@ int __mlx4_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		     int start_index, int npages, u64 *page_list);
 int __mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx);
 void __mlx4_counter_free(struct mlx4_dev *dev, u32 idx);
+int mlx4_calc_vf_counters(struct mlx4_dev *dev, int slave, int port,
+			  struct mlx4_counter *data);
 int __mlx4_xrcd_alloc(struct mlx4_dev *dev, u32 *xrcdn);
 void __mlx4_xrcd_free(struct mlx4_dev *dev, u32 xrcdn);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 73db584..731423c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -46,6 +46,7 @@
 
 #include "mlx4.h"
 #include "fw.h"
+#include "mlx4_stats.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
 #define MLX4_PF_COUNTERS_PER_PORT	2
@@ -1147,6 +1148,53 @@ static struct res_common *alloc_tr(u64 id, enum mlx4_resource type, int slave,
 	return ret;
 }
 
+int mlx4_calc_vf_counters(struct mlx4_dev *dev, int slave, int port,
+			  struct mlx4_counter *data)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
+	struct res_common *tmp;
+	struct res_counter *counter;
+	int *counters_arr;
+	int i = 0, err = 0;
+
+	memset(data, 0, sizeof(*data));
+
+	counters_arr = kmalloc_array(dev->caps.max_counters,
+				     sizeof(*counters_arr), GFP_KERNEL);
+	if (!counters_arr)
+		return -ENOMEM;
+
+	spin_lock_irq(mlx4_tlock(dev));
+	list_for_each_entry(tmp,
+			    &tracker->slave_list[slave].res_list[RES_COUNTER],
+			    list) {
+		counter = container_of(tmp, struct res_counter, com);
+		if (counter->port == port) {
+			counters_arr[i] = (int)tmp->res_id;
+			i++;
+		}
+	}
+	spin_unlock_irq(mlx4_tlock(dev));
+	counters_arr[i] = -1;
+
+	i = 0;
+
+	while (counters_arr[i] != -1) {
+		err = mlx4_get_counter_stats(dev, counters_arr[i], data,
+					     0);
+		if (err) {
+			memset(data, 0, sizeof(*data));
+			goto table_changed;
+		}
+		i++;
+	}
+
+table_changed:
+	kfree(counters_arr);
+	return 0;
+}
+
 static int add_res_range(struct mlx4_dev *dev, int slave, u64 base, int count,
 			 enum mlx4_resource type, int extra)
 {
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 5dffc86..53b9023 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -36,6 +36,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/if_link.h>
 #include <linux/mlx4/device.h>
+#include <linux/netdevice.h>
 
 enum {
 	/* initialization and general commands */
@@ -303,6 +304,8 @@ void mlx4_free_cmd_mailbox(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbo
 
 int mlx4_get_counter_stats(struct mlx4_dev *dev, int counter_index,
 			   struct mlx4_counter *counter_stats, int reset);
+int mlx4_get_vf_stats(struct mlx4_dev *dev, int port, int vf_idx,
+		      struct rtnl_link_vf_stats64 *vf_stats);
 u32 mlx4_comm_get_version(void);
 int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan, u8 qos);
-- 
1.7.1
