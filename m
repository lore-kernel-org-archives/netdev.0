From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/8] mlxsw: spectrum: Add definition for egress rif table
Date: Sat, 25 Mar 2017 08:35:38 +0100
Message-ID: <1490427342-2061-5-git-send-email-jiri@resnulli.us>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32773 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdCYHfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 03:35:52 -0400
Received: by mail-wr0-f196.google.com with SMTP id 20so1394991wrx.0
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 00:35:50 -0700 (PDT)
In-Reply-To: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add definition for egress router interface table. This table describes
the final part in the routing pipeline. This table matches the egress
interface index (rif index, which is set by the previous stages and
determine the out port) and makes the decision of forwarding the packet
towards the L2 logic or dropping it.

The metadata header is added to represent this internal information.
The rif index field is mapped logically to netdevice ifindex.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 117 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |   2 +
 2 files changed, 115 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 7c87bc8..60f2207 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -38,20 +38,129 @@
 #include "spectrum.h"
 #include "spectrum_dpipe.h"
 
-static struct devlink_dpipe_header *mlxsw_dpipe_headers[] = {};
+enum mlxsw_sp_field_metadata_id {
+	MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
+	MLXSW_SP_DPIPE_FIELD_METADATA_L3_FORWARD,
+	MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP,
+};
+
+static struct devlink_dpipe_field mlxsw_sp_dpipe_fields_metadata[] = {
+	{ .name = "erif_port",
+	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
+	  .bitwidth = 32,
+	  .mapping_type = DEVLINK_DPIPE_FIELD_MAPPING_TYPE_IFINDEX,
+	},
+	{ .name = "l3_forward",
+	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_FORWARD,
+	  .bitwidth = 1,
+	},
+	{ .name = "l2_drop",
+	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP,
+	  .bitwidth = 1,
+	},
+};
+
+enum mlxsw_sp_dpipe_header_id {
+	MLXSW_SP_DPIPE_HEADER_METADATA,
+};
+
+static struct devlink_dpipe_header mlxsw_sp_dpipe_header_metadata = {
+	.name = "mlxsw_meta",
+	.id = MLXSW_SP_DPIPE_HEADER_METADATA,
+	.fields = mlxsw_sp_dpipe_fields_metadata,
+	.fields_count = ARRAY_SIZE(mlxsw_sp_dpipe_fields_metadata),
+};
+
+static struct devlink_dpipe_header *mlxsw_dpipe_headers[] = {
+	&mlxsw_sp_dpipe_header_metadata,
+};
 
 static struct devlink_dpipe_headers mlxsw_sp_dpipe_headers = {
 	.headers = mlxsw_dpipe_headers,
 	.headers_count = ARRAY_SIZE(mlxsw_dpipe_headers),
 };
 
+static int mlxsw_sp_dpipe_table_erif_actions_dump(void *priv,
+						  struct sk_buff *skb)
+{
+	struct devlink_dpipe_action action = {0};
+	int err;
+
+	action.type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
+	action.header = &mlxsw_sp_dpipe_header_metadata;
+	action.field_id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_FORWARD;
+
+	err = devlink_dpipe_action_put(skb, &action);
+	if (err)
+		return err;
+
+	action.type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
+	action.header = &mlxsw_sp_dpipe_header_metadata;
+	action.field_id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP;
+
+	return devlink_dpipe_action_put(skb, &action);
+}
+
+static int mlxsw_sp_dpipe_table_erif_matches_dump(void *priv,
+						  struct sk_buff *skb)
+{
+	struct devlink_dpipe_match match = {0};
+
+	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match.header = &mlxsw_sp_dpipe_header_metadata;
+	match.field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT;
+
+	return devlink_dpipe_match_put(skb, &match);
+}
+
+static struct devlink_dpipe_table_ops mlxsw_sp_erif_ops = {
+	.matches_dump = mlxsw_sp_dpipe_table_erif_matches_dump,
+	.actions_dump = mlxsw_sp_dpipe_table_erif_actions_dump,
+};
+
+static int mlxsw_sp_dpipe_erif_table_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+	u64 table_size;
+
+	table_size = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
+	return devlink_dpipe_table_register(devlink,
+					    MLXSW_SP_DPIPE_TABLE_NAME_ERIF,
+					    &mlxsw_sp_erif_ops,
+					    mlxsw_sp, table_size,
+					    false);
+}
+
+static void mlxsw_sp_dpipe_erif_table_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+
+	devlink_dpipe_table_unregister(devlink, MLXSW_SP_DPIPE_TABLE_NAME_ERIF);
+}
+
 int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
 {
-	return devlink_dpipe_headers_register(priv_to_devlink(mlxsw_sp->core),
-					      &mlxsw_sp_dpipe_headers);
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+	int err;
+
+	err = devlink_dpipe_headers_register(devlink,
+					     &mlxsw_sp_dpipe_headers);
+	if (err)
+		return err;
+	err = mlxsw_sp_dpipe_erif_table_init(mlxsw_sp);
+	if (err)
+		goto err_erif_register;
+	return 0;
+
+err_erif_register:
+	devlink_dpipe_headers_unregister(priv_to_devlink(mlxsw_sp->core));
+	return err;
 }
 
 void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp)
 {
-	devlink_dpipe_headers_unregister(priv_to_devlink(mlxsw_sp->core));
+	struct devlink *devlink = priv_to_devlink(mlxsw_sp->core);
+
+	mlxsw_sp_dpipe_erif_table_fini(mlxsw_sp);
+	devlink_dpipe_headers_unregister(devlink);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
index ad16259..d208929 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
@@ -38,4 +38,6 @@
 int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp);
 
+#define MLXSW_SP_DPIPE_TABLE_NAME_ERIF "mlxsw_erif"
+
 #endif /* _MLXSW_PIPELINE_H_*/
-- 
2.7.4
