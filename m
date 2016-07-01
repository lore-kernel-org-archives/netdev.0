From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V3 16/16] net/mlx5e: Introduce SRIOV VF representors
Date: Fri,  1 Jul 2016 14:51:09 +0300
Message-ID: <1467373869-22746-17-git-send-email-saeedm@mellanox.com>
References: <1467373869-22746-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52047 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751869AbcGAL6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2016 07:58:19 -0400
In-Reply-To: <1467373869-22746-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Implement the relevant profile functions to create mlx5e driver instance
serving as VF representor. When SRIOV offloads mode is enabled, each VF
will have a representor netdevice instance on the host.

To do that, we also export set of shared service functions from en_main.c,
such that they can be used by both NIC and repsresentors netdevs.

The newly created representor netdevice has a basic set of net_device_ops
which are the same ndo functions as the NIC netdevice and an ndo of it's
own for phys port name.

The profiling infrastructure allow sharing code between the NIC and the
vport representor even though the representor has only a subset of the
NIC functionality.

The VF reps and the PF which is used in that mode to represent the uplink,
expose switchdev ops. Currently the only op supposed is attr get for the
port parent ID which here serves to identify net-devices belonging to the
same HW E-Switch. Other than that, no offloading is implemented and hence
switching functionality is achieved if one sets SW switching rules, e.g
using tc, bridge or ovs.

Port phys name (ndo_get_phys_port_name) is implemented to allow exporting
to user-space the VF vport number and along with the switchdev port parent
id (phys_switch_id) enable a udev base consistent naming scheme:

SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="<phys_switch_id>", \
        ATTR{phys_port_name}!="", NAME="$PF_NIC$attr{phys_port_name}"

where phys_switch_id is exposed by the PF (and VF reps) and $PF_NIC is
the name of the PF netdevice.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  28 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  53 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 394 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  20 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  96 ++++-
 6 files changed, 574 insertions(+), 19 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 9b14dad..a574dea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -8,6 +8,6 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o
+		en_tc.o en_arfs.o en_rep.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 081259a..00643a1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -44,6 +44,7 @@
 #include <linux/mlx5/vport.h>
 #include <linux/mlx5/transobj.h>
 #include <linux/rhashtable.h>
+#include <net/switchdev.h>
 #include "wq.h"
 #include "mlx5_core.h"
 #include "en_stats.h"
@@ -816,4 +817,31 @@ int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev);
 void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev);
 int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev);
 
+struct mlx5_eswitch_rep;
+int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
+			 struct mlx5_eswitch_rep *rep);
+void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
+			    struct mlx5_eswitch_rep *rep);
+int mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep);
+void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
+			  struct mlx5_eswitch_rep *rep);
+int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv);
+void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv);
+int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
+
+int mlx5e_create_direct_rqts(struct mlx5e_priv *priv);
+void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt);
+int mlx5e_create_direct_tirs(struct mlx5e_priv *priv);
+void mlx5e_destroy_direct_tirs(struct mlx5e_priv *priv);
+int mlx5e_create_tises(struct mlx5e_priv *priv);
+void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv);
+int mlx5e_close(struct net_device *netdev);
+int mlx5e_open(struct net_device *netdev);
+void mlx5e_update_stats_work(struct work_struct *work);
+void *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
+			  const struct mlx5e_profile *profile, void *ppriv);
+void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv);
+struct rtnl_link_stats64 *
+mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats);
+
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2c9e458..96ec53a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -226,7 +226,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	mlx5e_update_sw_counters(priv);
 }
 
-static void mlx5e_update_stats_work(struct work_struct *work)
+void mlx5e_update_stats_work(struct work_struct *work)
 {
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct mlx5e_priv *priv = container_of(dwork, struct mlx5e_priv,
@@ -1518,7 +1518,7 @@ static int mlx5e_create_rqt(struct mlx5e_priv *priv, int sz,
 	return err;
 }
 
-static void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt)
+void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt)
 {
 	rqt->enabled = false;
 	mlx5_core_destroy_rqt(priv->mdev, rqt->rqtn);
@@ -1531,7 +1531,7 @@ static int mlx5e_create_indirect_rqts(struct mlx5e_priv *priv)
 	return mlx5e_create_rqt(priv, MLX5E_INDIR_RQT_SIZE, 0, rqt);
 }
 
-static int mlx5e_create_direct_rqts(struct mlx5e_priv *priv)
+int mlx5e_create_direct_rqts(struct mlx5e_priv *priv)
 {
 	struct mlx5e_rqt *rqt;
 	int err;
@@ -1743,6 +1743,7 @@ static void mlx5e_netdev_set_tcs(struct net_device *netdev)
 int mlx5e_open_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
 	int num_txqs;
 	int err;
 
@@ -1778,9 +1779,14 @@ int mlx5e_open_locked(struct net_device *netdev)
 #ifdef CONFIG_RFS_ACCEL
 	priv->netdev->rx_cpu_rmap = priv->mdev->rmap;
 #endif
+	if (priv->profile->update_stats)
+		queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
 
-	queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
-
+	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
+		err = mlx5e_add_sqs_fwd_rules(priv);
+		if (err)
+			goto err_close_channels;
+	}
 	return 0;
 
 err_close_channels:
@@ -1790,7 +1796,7 @@ err_clear_state_opened_flag:
 	return err;
 }
 
-static int mlx5e_open(struct net_device *netdev)
+int mlx5e_open(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
@@ -1805,6 +1811,7 @@ static int mlx5e_open(struct net_device *netdev)
 int mlx5e_close_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
 
 	/* May already be CLOSED in case a previous configuration operation
 	 * (e.g RX/TX queue size change) that involves close&open failed.
@@ -1814,6 +1821,9 @@ int mlx5e_close_locked(struct net_device *netdev)
 
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		mlx5e_remove_sqs_fwd_rules(priv);
+
 	mlx5e_timestamp_cleanup(priv);
 	netif_carrier_off(priv->netdev);
 	mlx5e_redirect_rqts(priv);
@@ -1822,7 +1832,7 @@ int mlx5e_close_locked(struct net_device *netdev)
 	return 0;
 }
 
-static int mlx5e_close(struct net_device *netdev)
+int mlx5e_close(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
@@ -1957,7 +1967,7 @@ static void mlx5e_destroy_tis(struct mlx5e_priv *priv, int tc)
 	mlx5_core_destroy_tis(priv->mdev, priv->tisn[tc]);
 }
 
-static int mlx5e_create_tises(struct mlx5e_priv *priv)
+int mlx5e_create_tises(struct mlx5e_priv *priv)
 {
 	int err;
 	int tc;
@@ -1977,7 +1987,7 @@ err_close_tises:
 	return err;
 }
 
-static void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv)
+void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv)
 {
 	int tc;
 
@@ -2143,7 +2153,7 @@ err_destroy_tirs:
 	return err;
 }
 
-static int mlx5e_create_direct_tirs(struct mlx5e_priv *priv)
+int mlx5e_create_direct_tirs(struct mlx5e_priv *priv)
 {
 	int nch = priv->profile->max_nch(priv->mdev);
 	struct mlx5e_tir *tir;
@@ -2190,7 +2200,7 @@ static void mlx5e_destroy_indirect_tirs(struct mlx5e_priv *priv)
 		mlx5e_destroy_tir(priv->mdev, &priv->indir_tir[i]);
 }
 
-static void mlx5e_destroy_direct_tirs(struct mlx5e_priv *priv)
+void mlx5e_destroy_direct_tirs(struct mlx5e_priv *priv)
 {
 	int nch = priv->profile->max_nch(priv->mdev);
 	int i;
@@ -2270,7 +2280,7 @@ mqprio:
 	return mlx5e_setup_tc(dev, tc->tc);
 }
 
-static struct rtnl_link_stats64 *
+struct rtnl_link_stats64 *
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -2988,6 +2998,10 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
 	}
 }
 
+static const struct switchdev_ops mlx5e_switchdev_ops = {
+	.switchdev_port_attr_get	= mlx5e_attr_get,
+};
+
 static void mlx5e_build_nic_netdev(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -3069,6 +3083,11 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	netdev->priv_flags       |= IFF_UNICAST_FLT;
 
 	mlx5e_set_netdev_dev_addr(netdev);
+
+#ifdef CONFIG_NET_SWITCHDEV
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		netdev->switchdev_ops = &mlx5e_switchdev_ops;
+#endif
 }
 
 static void mlx5e_create_q_counter(struct mlx5e_priv *priv)
@@ -3251,6 +3270,8 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 	queue_work(priv->wq, &priv->set_rx_mode_work);
 
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
+		rep.load = mlx5e_nic_rep_load;
+		rep.unload = mlx5e_nic_rep_unload;
 		rep.vport = 0;
 		rep.priv_data = priv;
 		mlx5_eswitch_register_vport_rep(esw, &rep);
@@ -3277,8 +3298,8 @@ static const struct mlx5e_profile mlx5e_nic_profile = {
 	.max_tc		   = MLX5E_MAX_NUM_TC,
 };
 
-static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
-				 const struct mlx5e_profile *profile, void *ppriv)
+void *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
+			  const struct mlx5e_profile *profile, void *ppriv)
 {
 	struct net_device *netdev;
 	struct mlx5e_priv *priv;
@@ -3372,6 +3393,8 @@ static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
 	for (vport = 1; vport < total_vfs; vport++) {
 		struct mlx5_eswitch_rep rep;
 
+		rep.load = mlx5e_vport_rep_load;
+		rep.unload = mlx5e_vport_rep_unload;
 		rep.vport = vport;
 		mlx5_eswitch_register_vport_rep(esw, &rep);
 	}
@@ -3402,7 +3425,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	return ret;
 }
 
-static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
+void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
 {
 	const struct mlx5e_profile *profile = priv->profile;
 	struct net_device *netdev = priv->netdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
new file mode 100644
index 0000000..5ef02f0
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -0,0 +1,394 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <generated/utsrelease.h>
+#include <linux/mlx5/fs.h>
+#include <net/switchdev.h>
+
+#include "eswitch.h"
+#include "en.h"
+
+static const char mlx5e_rep_driver_name[] = "mlx5e_rep";
+
+static void mlx5e_rep_get_drvinfo(struct net_device *dev,
+				  struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->driver, mlx5e_rep_driver_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
+}
+
+static const struct counter_desc sw_rep_stats_desc[] = {
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_bytes) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_packets) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_bytes) },
+};
+
+#define NUM_VPORT_REP_COUNTERS	ARRAY_SIZE(sw_rep_stats_desc)
+
+static void mlx5e_rep_get_strings(struct net_device *dev,
+				  u32 stringset, uint8_t *data)
+{
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < NUM_VPORT_REP_COUNTERS; i++)
+			strcpy(data + (i * ETH_GSTRING_LEN),
+			       sw_rep_stats_desc[i].format);
+		break;
+	}
+}
+
+static void mlx5e_update_sw_rep_counters(struct mlx5e_priv *priv)
+{
+	struct mlx5e_sw_stats *s = &priv->stats.sw;
+	struct mlx5e_rq_stats *rq_stats;
+	struct mlx5e_sq_stats *sq_stats;
+	int i, j;
+
+	memset(s, 0, sizeof(*s));
+	for (i = 0; i < priv->params.num_channels; i++) {
+		rq_stats = &priv->channel[i]->rq.stats;
+
+		s->rx_packets	+= rq_stats->packets;
+		s->rx_bytes	+= rq_stats->bytes;
+
+		for (j = 0; j < priv->params.num_tc; j++) {
+			sq_stats = &priv->channel[i]->sq[j].stats;
+
+			s->tx_packets		+= sq_stats->packets;
+			s->tx_bytes		+= sq_stats->bytes;
+		}
+	}
+}
+
+static void mlx5e_rep_get_ethtool_stats(struct net_device *dev,
+					struct ethtool_stats *stats, u64 *data)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	int i;
+
+	if (!data)
+		return;
+
+	mutex_lock(&priv->state_lock);
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		mlx5e_update_sw_rep_counters(priv);
+	mutex_unlock(&priv->state_lock);
+
+	for (i = 0; i < NUM_VPORT_REP_COUNTERS; i++)
+		data[i] = MLX5E_READ_CTR64_CPU(&priv->stats.sw,
+					       sw_rep_stats_desc, i);
+}
+
+static int mlx5e_rep_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return NUM_VPORT_REP_COUNTERS;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static const struct ethtool_ops mlx5e_rep_ethtool_ops = {
+	.get_drvinfo	   = mlx5e_rep_get_drvinfo,
+	.get_link	   = ethtool_op_get_link,
+	.get_strings       = mlx5e_rep_get_strings,
+	.get_sset_count    = mlx5e_rep_get_sset_count,
+	.get_ethtool_stats = mlx5e_rep_get_ethtool_stats,
+};
+
+int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	u8 mac[ETH_ALEN];
+
+	if (esw->mode == SRIOV_NONE)
+		return -EOPNOTSUPP;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		mlx5_query_nic_vport_mac_address(priv->mdev, 0, mac);
+		attr->u.ppid.id_len = ETH_ALEN;
+		memcpy(&attr->u.ppid.id, &mac, ETH_ALEN);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
+
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_channel *c;
+	int n, tc, err, num_sqs = 0;
+	u16 *sqs;
+
+	sqs = kcalloc(priv->params.num_channels * priv->params.num_tc, sizeof(u16), GFP_KERNEL);
+	if (!sqs)
+		return -ENOMEM;
+
+	for (n = 0; n < priv->params.num_channels; n++) {
+		c = priv->channel[n];
+		for (tc = 0; tc < c->num_tc; tc++)
+			sqs[num_sqs++] = c->sq[tc].sqn;
+	}
+
+	err = mlx5_eswitch_sqs2vport_start(esw, rep, sqs, num_sqs);
+
+	kfree(sqs);
+	return err;
+}
+
+int mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
+{
+	struct mlx5e_priv *priv = rep->priv_data;
+
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		return mlx5e_add_sqs_fwd_rules(priv);
+	return 0;
+}
+
+void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv)
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+
+	mlx5_eswitch_sqs2vport_stop(esw, rep);
+}
+
+void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
+			  struct mlx5_eswitch_rep *rep)
+{
+	struct mlx5e_priv *priv = rep->priv_data;
+
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		mlx5e_remove_sqs_fwd_rules(priv);
+}
+
+static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
+					char *buf, size_t len)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	int ret;
+
+	ret = snprintf(buf, len, "%d", rep->vport - 1);
+	if (ret >= len)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
+static const struct switchdev_ops mlx5e_rep_switchdev_ops = {
+	.switchdev_port_attr_get	= mlx5e_attr_get,
+};
+
+static const struct net_device_ops mlx5e_netdev_ops_rep = {
+	.ndo_open                = mlx5e_open,
+	.ndo_stop                = mlx5e_close,
+	.ndo_start_xmit          = mlx5e_xmit,
+	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
+	.ndo_get_stats64         = mlx5e_get_stats,
+};
+
+static void mlx5e_build_rep_netdev_priv(struct mlx5_core_dev *mdev,
+					struct net_device *netdev,
+					const struct mlx5e_profile *profile,
+					void *ppriv)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	u8 cq_period_mode = MLX5_CAP_GEN(mdev, cq_period_start_from_cqe) ?
+					 MLX5_CQ_PERIOD_MODE_START_FROM_CQE :
+					 MLX5_CQ_PERIOD_MODE_START_FROM_EQE;
+
+	priv->params.log_sq_size           =
+		MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
+	priv->params.rq_wq_type = MLX5_WQ_TYPE_LINKED_LIST;
+	priv->params.log_rq_size = MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE;
+
+	priv->params.min_rx_wqes = mlx5_min_rx_wqes(priv->params.rq_wq_type,
+					    BIT(priv->params.log_rq_size));
+
+	priv->params.rx_am_enabled = MLX5_CAP_GEN(mdev, cq_moderation);
+	mlx5e_set_rx_cq_mode_params(&priv->params, cq_period_mode);
+
+	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
+	priv->params.num_tc                = 1;
+
+	priv->params.lro_wqe_sz            =
+		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
+
+	priv->mdev                         = mdev;
+	priv->netdev                       = netdev;
+	priv->params.num_channels          = profile->max_nch(mdev);
+	priv->profile                      = profile;
+	priv->ppriv                        = ppriv;
+
+	mutex_init(&priv->state_lock);
+
+	INIT_DELAYED_WORK(&priv->update_stats_work, mlx5e_update_stats_work);
+}
+
+static void mlx5e_build_rep_netdev(struct net_device *netdev)
+{
+	netdev->netdev_ops = &mlx5e_netdev_ops_rep;
+
+	netdev->watchdog_timeo    = 15 * HZ;
+
+	netdev->ethtool_ops	  = &mlx5e_rep_ethtool_ops;
+
+#ifdef CONFIG_NET_SWITCHDEV
+	netdev->switchdev_ops = &mlx5e_rep_switchdev_ops;
+#endif
+
+	netdev->features	 |= NETIF_F_VLAN_CHALLENGED;
+
+	eth_hw_addr_random(netdev);
+}
+
+static void mlx5e_init_rep(struct mlx5_core_dev *mdev,
+			   struct net_device *netdev,
+			   const struct mlx5e_profile *profile,
+			   void *ppriv)
+{
+	mlx5e_build_rep_netdev_priv(mdev, netdev, profile, ppriv);
+	mlx5e_build_rep_netdev(netdev);
+}
+
+static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_flow_rule *flow_rule;
+	int err;
+	int i;
+
+	err = mlx5e_create_direct_rqts(priv);
+	if (err) {
+		mlx5_core_warn(mdev, "create direct rqts failed, %d\n", err);
+		return err;
+	}
+
+	err = mlx5e_create_direct_tirs(priv);
+	if (err) {
+		mlx5_core_warn(mdev, "create direct tirs failed, %d\n", err);
+		goto err_destroy_direct_rqts;
+	}
+
+	flow_rule = mlx5_eswitch_create_vport_rx_rule(esw,
+						      rep->vport,
+						      priv->direct_tir[0].tirn);
+	if (IS_ERR(flow_rule)) {
+		err = PTR_ERR(flow_rule);
+		goto err_destroy_direct_tirs;
+	}
+	rep->vport_rx_rule = flow_rule;
+
+	return 0;
+
+err_destroy_direct_tirs:
+	mlx5e_destroy_direct_tirs(priv);
+err_destroy_direct_rqts:
+	for (i = 0; i < priv->params.num_channels; i++)
+		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
+	return err;
+}
+
+static void mlx5e_cleanup_rep_rx(struct mlx5e_priv *priv)
+{
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	int i;
+
+	mlx5_del_flow_rule(rep->vport_rx_rule);
+	mlx5e_destroy_direct_tirs(priv);
+	for (i = 0; i < priv->params.num_channels; i++)
+		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
+}
+
+static int mlx5e_init_rep_tx(struct mlx5e_priv *priv)
+{
+	int err;
+
+	err = mlx5e_create_tises(priv);
+	if (err) {
+		mlx5_core_warn(priv->mdev, "create tises failed, %d\n", err);
+		return err;
+	}
+	return 0;
+}
+
+static int mlx5e_get_rep_max_num_channels(struct mlx5_core_dev *mdev)
+{
+#define	MLX5E_PORT_REPRESENTOR_NCH 1
+	return MLX5E_PORT_REPRESENTOR_NCH;
+}
+
+static struct mlx5e_profile mlx5e_rep_profile = {
+	.init			= mlx5e_init_rep,
+	.init_rx		= mlx5e_init_rep_rx,
+	.cleanup_rx		= mlx5e_cleanup_rep_rx,
+	.init_tx		= mlx5e_init_rep_tx,
+	.cleanup_tx		= mlx5e_cleanup_nic_tx,
+	.update_stats           = mlx5e_update_sw_rep_counters,
+	.max_nch		= mlx5e_get_rep_max_num_channels,
+	.max_tc			= 1,
+};
+
+int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
+			 struct mlx5_eswitch_rep *rep)
+{
+	rep->priv_data = mlx5e_create_netdev(esw->dev, &mlx5e_rep_profile, rep);
+	if (!rep->priv_data) {
+		pr_warn("Failed to create representor for vport %d\n",
+			rep->vport);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
+			    struct mlx5_eswitch_rep *rep)
+{
+	struct mlx5e_priv *priv = rep->priv_data;
+
+	mlx5e_destroy_netdev(esw->dev, priv);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index ffe5eab..7b45e6a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -47,6 +47,8 @@
 #define MLX5_L2_ADDR_HASH_SIZE (BIT(BITS_PER_BYTE))
 #define MLX5_L2_ADDR_HASH(addr) (addr[5])
 
+#define FDB_UPLINK_VPORT 0xffff
+
 /* L2 -mac address based- hash helpers */
 struct l2addr_node {
 	struct hlist_node hlist;
@@ -156,10 +158,20 @@ enum {
 	SRIOV_OFFLOADS
 };
 
+struct mlx5_esw_sq {
+	struct mlx5_flow_rule	*send_to_vport_rule;
+	struct list_head	 list;
+};
 
 struct mlx5_eswitch_rep {
+	int		       (*load)(struct mlx5_eswitch *esw,
+				       struct mlx5_eswitch_rep *rep);
+	void		       (*unload)(struct mlx5_eswitch *esw,
+					 struct mlx5_eswitch_rep *rep);
 	u16		       vport;
+	struct mlx5_flow_rule *vport_rx_rule;
 	void		      *priv_data;
+	struct list_head       vport_sqs_list;
 	bool		       valid;
 };
 
@@ -208,12 +220,16 @@ int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 int vport,
 				 struct ifla_vf_stats *vf_stats);
-struct mlx5_flow_rule *
-mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn);
 
 struct mlx5_flow_rule *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
 
+int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
+				 struct mlx5_eswitch_rep *rep,
+				 u16 *sqns_array, int sqns_num);
+void mlx5_eswitch_sqs2vport_stop(struct mlx5_eswitch *esw,
+				 struct mlx5_eswitch_rep *rep);
+
 int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode);
 int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index f84aa79..ed8ad98 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -38,7 +38,7 @@
 #include "mlx5_core.h"
 #include "eswitch.h"
 
-struct mlx5_flow_rule *
+static struct mlx5_flow_rule *
 mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn)
 {
 	struct mlx5_flow_destination dest;
@@ -77,6 +77,63 @@ out:
 	return flow_rule;
 }
 
+void mlx5_eswitch_sqs2vport_stop(struct mlx5_eswitch *esw,
+				 struct mlx5_eswitch_rep *rep)
+{
+	struct mlx5_esw_sq *esw_sq, *tmp;
+
+	if (esw->mode != SRIOV_OFFLOADS)
+		return;
+
+	list_for_each_entry_safe(esw_sq, tmp, &rep->vport_sqs_list, list) {
+		mlx5_del_flow_rule(esw_sq->send_to_vport_rule);
+		list_del(&esw_sq->list);
+		kfree(esw_sq);
+	}
+}
+
+int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
+				 struct mlx5_eswitch_rep *rep,
+				 u16 *sqns_array, int sqns_num)
+{
+	struct mlx5_flow_rule *flow_rule;
+	struct mlx5_esw_sq *esw_sq;
+	int vport;
+	int err;
+	int i;
+
+	if (esw->mode != SRIOV_OFFLOADS)
+		return 0;
+
+	vport = rep->vport == 0 ?
+		FDB_UPLINK_VPORT : rep->vport;
+
+	for (i = 0; i < sqns_num; i++) {
+		esw_sq = kzalloc(sizeof(*esw_sq), GFP_KERNEL);
+		if (!esw_sq) {
+			err = -ENOMEM;
+			goto out_err;
+		}
+
+		/* Add re-inject rule to the PF/representor sqs */
+		flow_rule = mlx5_eswitch_add_send_to_vport_rule(esw,
+								vport,
+								sqns_array[i]);
+		if (IS_ERR(flow_rule)) {
+			err = PTR_ERR(flow_rule);
+			kfree(esw_sq);
+			goto out_err;
+		}
+		esw_sq->send_to_vport_rule = flow_rule;
+		list_add(&esw_sq->list, &rep->vport_sqs_list);
+	}
+	return 0;
+
+out_err:
+	mlx5_eswitch_sqs2vport_stop(esw, rep);
+	return err;
+}
+
 static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 {
 	struct mlx5_flow_destination dest;
@@ -347,6 +404,8 @@ static int esw_offloads_start(struct mlx5_eswitch *esw)
 
 int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 {
+	struct mlx5_eswitch_rep *rep;
+	int vport;
 	int err;
 
 	err = esw_create_offloads_fdb_table(esw, nvports);
@@ -361,8 +420,26 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 	if (err)
 		goto create_fg_err;
 
+	for (vport = 0; vport < nvports; vport++) {
+		rep = &esw->offloads.vport_reps[vport];
+		if (!rep->valid)
+			continue;
+
+		err = rep->load(esw, rep);
+		if (err)
+			goto err_reps;
+	}
 	return 0;
 
+err_reps:
+	for (vport--; vport >= 0; vport--) {
+		rep = &esw->offloads.vport_reps[vport];
+		if (!rep->valid)
+			continue;
+		rep->unload(esw, rep);
+	}
+	esw_destroy_vport_rx_group(esw);
+
 create_fg_err:
 	esw_destroy_offloads_table(esw);
 
@@ -385,6 +462,16 @@ static int esw_offloads_stop(struct mlx5_eswitch *esw)
 
 void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 {
+	struct mlx5_eswitch_rep *rep;
+	int vport;
+
+	for (vport = 0; vport < nvports; vport++) {
+		rep = &esw->offloads.vport_reps[vport];
+		if (!rep->valid)
+			continue;
+		rep->unload(esw, rep);
+	}
+
 	esw_destroy_vport_rx_group(esw);
 	esw_destroy_offloads_table(esw);
 	esw_destroy_offloads_fdb_table(esw);
@@ -460,6 +547,7 @@ void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 	memcpy(&offloads->vport_reps[rep->vport], rep,
 	       sizeof(struct mlx5_eswitch_rep));
 
+	INIT_LIST_HEAD(&offloads->vport_reps[rep->vport].vport_sqs_list);
 	offloads->vport_reps[rep->vport].valid = true;
 }
 
@@ -467,6 +555,12 @@ void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
 				       int vport)
 {
 	struct mlx5_esw_offload *offloads = &esw->offloads;
+	struct mlx5_eswitch_rep *rep;
+
+	rep = &offloads->vport_reps[vport];
+
+	if (esw->mode == SRIOV_OFFLOADS && esw->vports[vport].enabled)
+		rep->unload(esw, rep);
 
 	offloads->vport_reps[vport].valid = false;
 }
-- 
2.8.0
