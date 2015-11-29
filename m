From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 14/18] net/mlx5: E-Switch, Introduce Vport administration functions
Date: Sun, 29 Nov 2015 17:37:22 +0200
Message-ID: <1448811446-18598-15-git-send-email-ogerlitz@mellanox.com>
References: <1448811446-18598-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34985 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751825AbbK2Pia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 10:38:30 -0500
In-Reply-To: <1448811446-18598-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Implement set VF mac/link state and query VF config
to be used later in nedev VF ndos or any other management API.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 61 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 10 +++-
 2 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index a208be7..590a06c 100644
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
index aec1ec0..c5827ad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -33,6 +33,8 @@
 #ifndef __MLX5_ESWITCH_H__
 #define __MLX5_ESWITCH_H__
 
+#include <linux/if_ether.h>
+#include <linux/if_link.h>
 #include <linux/mlx5/device.h>
 
 #define MLX5_MAX_UC_PER_VPORT(dev) \
@@ -139,10 +141,16 @@ struct mlx5_eswitch {
 
 /* E-Switch API */
 int mlx5_eswitch_init(struct mlx5_core_dev *dev);
+
 void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw);
 void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe);
 int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs);
 void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw);
-
+int mlx5_eswitch_set_vport_mac(struct mlx5_eswitch *esw,
+			       int vport, u8 mac[ETH_ALEN]);
+int mlx5_eswitch_set_vport_state(struct mlx5_eswitch *esw,
+				 int vport, int link_state);
+int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
+				  int vport, struct ifla_vf_info *ivi);
 #endif /* __MLX5_ESWITCH_H__ */
 
-- 
2.3.7
