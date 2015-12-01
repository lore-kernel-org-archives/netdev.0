From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 14/18] net/mlx5: E-Switch, Introduce Vport administration functions
Date: Tue,  1 Dec 2015 18:03:21 +0200
Message-ID: <1448985805-25422-15-git-send-email-ogerlitz@mellanox.com>
References: <1448985805-25422-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34461 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755388AbbLAQEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 11:04:37 -0500
In-Reply-To: <1448985805-25422-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Implement set VF mac/link state and query VF config
to be used later in nedev VF ndos or any other management API.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 61 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  8 +++
 2 files changed, 69 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 6fa6f01..d7d6eba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1022,3 +1022,64 @@ void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe)
 		queue_work(esw->work_queue, &vport->vport_change_handler);
 	spin_unlock(&vport->lock);
 }
+
+/* Vport Administration */
+#define ESW_ALLOWED(esw) \
+	(esw && MLX5_CAP_GEN(esw->dev, vport_group_manager) && mlx5_core_is_pf(esw->dev))
+#define LEGAL_VPORT(esw, vport) (vport >= 0 && vport < esw->total_vports)
+
+int mlx5_eswitch_set_vport_mac(struct mlx5_eswitch *esw,
+			       int vport, u8 mac[ETH_ALEN])
+{
+	int err = 0;
+
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport))
+		return -EINVAL;
+
+	err = mlx5_modify_nic_vport_mac_address(esw->dev, vport, mac);
+	if (err) {
+		mlx5_core_warn(esw->dev,
+			       "Failed to mlx5_modify_nic_vport_mac vport(%d) err=(%d)\n",
+			       vport, err);
+		return err;
+	}
+
+	return err;
+}
+
+int mlx5_eswitch_set_vport_state(struct mlx5_eswitch *esw,
+				 int vport, int link_state)
+{
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport))
+		return -EINVAL;
+
+	return mlx5_modify_vport_admin_state(esw->dev,
+					     MLX5_QUERY_VPORT_STATE_IN_OP_MOD_ESW_VPORT,
+					     vport, link_state);
+}
+
+int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
+				  int vport, struct ifla_vf_info *ivi)
+{
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport))
+		return -EINVAL;
+
+	memset(ivi, 0, sizeof(*ivi));
+	ivi->vf = vport - 1;
+
+	mlx5_query_nic_vport_mac_address(esw->dev, vport, ivi->mac);
+	ivi->linkstate = mlx5_query_vport_admin_state(esw->dev,
+						      MLX5_QUERY_VPORT_STATE_IN_OP_MOD_ESW_VPORT,
+						      vport);
+	ivi->vlan = 0;
+	ivi->qos = 0;
+	ivi->spoofchk = 0;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index f222e33..43a6730d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -33,6 +33,8 @@
 #ifndef __MLX5_ESWITCH_H__
 #define __MLX5_ESWITCH_H__
 
+#include <linux/if_ether.h>
+#include <linux/if_link.h>
 #include <linux/mlx5/device.h>
 
 #define MLX5_MAX_UC_PER_VPORT(dev) \
@@ -143,5 +145,11 @@ void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw);
 void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe);
 int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs);
 void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw);
+int mlx5_eswitch_set_vport_mac(struct mlx5_eswitch *esw,
+			       int vport, u8 mac[ETH_ALEN]);
+int mlx5_eswitch_set_vport_state(struct mlx5_eswitch *esw,
+				 int vport, int link_state);
+int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
+				  int vport, struct ifla_vf_info *ivi);
 
 #endif /* __MLX5_ESWITCH_H__ */
-- 
2.3.7
