From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 3/9] net/mlx5: E-Switch, Set vport representor fields explicitly on registration
Date: Thu, 22 Sep 2016 20:01:43 +0300
Message-ID: <1474563709-17943-4-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49003 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964989AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The structure we use for the eswitch vport representor (mlx5_eswitch_rep)
has some fields which are set from upper layers in the driver when they
register the rep. Use explicit setting on registration time for them and
avoid global memcpy. This patch doesn't add new functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h          | 5 +++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 8 +++++++-
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 6d8c5a2..ebfcde0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -178,11 +178,12 @@ struct mlx5_eswitch_rep {
 	void		       (*unload)(struct mlx5_eswitch *esw,
 					 struct mlx5_eswitch_rep *rep);
 	u16		       vport;
-	struct mlx5_flow_rule *vport_rx_rule;
+	u8		       hw_id[ETH_ALEN];
 	void		      *priv_data;
+
+	struct mlx5_flow_rule *vport_rx_rule;
 	struct list_head       vport_sqs_list;
 	bool		       valid;
-	u8		       hw_id[ETH_ALEN];
 };
 
 struct mlx5_esw_offload {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index a73721b..b901cd4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -616,7 +616,13 @@ void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 
 	rep = &offloads->vport_reps[vport_index];
 
-	memcpy(rep, __rep, sizeof(struct mlx5_eswitch_rep));
+	memset(rep, 0, sizeof(*rep));
+
+	rep->load   = __rep->load;
+	rep->unload = __rep->unload;
+	rep->vport  = __rep->vport;
+	rep->priv_data = __rep->priv_data;
+	ether_addr_copy(rep->hw_id, __rep->hw_id);
 
 	INIT_LIST_HEAD(&rep->vport_sqs_list);
 	rep->valid = true;
-- 
2.7.4
