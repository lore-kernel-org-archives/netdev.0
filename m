From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 08/10] net/mlx5e: Add TC drop and mirred/redirect action parsing for SRIOV offloads
Date: Thu, 14 Jul 2016 10:32:44 +0300
Message-ID: <1468481566-29859-9-git-send-email-saeedm@mellanox.com>
References: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43389 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751121AbcGNHdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:33:20 -0400
In-Reply-To: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add the setup code that parses the TC actions needed to support offloading drop
and mirred/redirect for SRIOV e-switch. We can redirect between two devices if
they belong to the same HW switch, compare the switchdev HW ID attribute to
enforce that.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 53 +++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 57b76f7..9a66441 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -37,8 +37,11 @@
 #include <linux/mlx5/fs.h>
 #include <linux/mlx5/device.h>
 #include <linux/rhashtable.h>
+#include <net/switchdev.h>
+#include <net/tc_act/tc_mirred.h>
 #include "en.h"
 #include "en_tc.h"
+#include "eswitch.h"
 
 struct mlx5e_tc_flow {
 	struct rhash_head	node;
@@ -339,6 +342,56 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	return 0;
 }
 
+static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
+				u32 *action, u32 *dest_vport)
+{
+	const struct tc_action *a;
+
+	if (tc_no_actions(exts))
+		return -EINVAL;
+
+	*action = 0;
+
+	tc_for_each_action(a, exts) {
+		/* Only support a single action per rule */
+		if (*action)
+			return -EINVAL;
+
+		if (is_tcf_gact_shot(a)) {
+			*action = MLX5_FLOW_CONTEXT_ACTION_DROP |
+				  MLX5_FLOW_CONTEXT_ACTION_COUNT;
+			continue;
+		}
+
+		if (is_tcf_mirred_redirect(a)) {
+			int ifindex = tcf_mirred_ifindex(a);
+			struct net_device *out_dev;
+			struct mlx5e_priv *out_priv;
+			struct mlx5_eswitch_rep *out_rep;
+
+			out_dev = __dev_get_by_index(dev_net(priv->netdev), ifindex);
+
+			if (!switchdev_port_same_parent_id(priv->netdev, out_dev)) {
+				pr_err("devices %s %s not on same switch HW, can't offload forwarding\n",
+				       priv->netdev->name, out_dev->name);
+				return -EINVAL;
+			}
+
+			out_priv = netdev_priv(out_dev);
+			out_rep  = out_priv->ppriv;
+			if (out_rep->vport == 0)
+				*dest_vport = FDB_UPLINK_VPORT;
+			else
+				*dest_vport = out_rep->vport;
+			*action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+			continue;
+		}
+
+		return -EINVAL;
+	}
+	return 0;
+}
+
 int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 			   struct tc_cls_flower_offload *f)
 {
-- 
2.8.0
