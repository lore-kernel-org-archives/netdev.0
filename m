From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 5/8] mlxsw: spectrum: Add definition for egress rif table
Date: Thu, 16 Feb 2017 16:22:41 +0100
Message-ID: <1487258564-3775-6-git-send-email-jiri@resnulli.us>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34815 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932434AbdBPPWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:22:53 -0500
Received: by mail-wr0-f196.google.com with SMTP id c4so2447299wrd.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:22:52 -0800 (PST)
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
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
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 89 +++++++++++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |  2 +
 2 files changed, 87 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 7c87bc8..41e8e33 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -38,20 +38,101 @@
 #include "spectrum.h"
 #include "spectrum_dpipe.h"
 
-static struct devlink_dpipe_header *mlxsw_dpipe_headers[] = {};
+enum mlxsw_sp_field_metadata_id {
+	MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
+	MLXSW_SP_DPIPE_FIELD_METADATA_FORWARD_OUT,
+	MLXSW_SP_DPIPE_FIELD_METADATA_DROP,
+};
+
+static struct devlink_dpipe_field mlxsw_sp_dpipe_fields_metadata[] = {
+	{ .name = "egress_rif_port",
+	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
+	  .bitwidth = 32,
+	  .mapping_type = DEVLINK_DPIPE_FIELD_MAPPING_TYPE_IFINDEX,
+	},
+	{ .name = "forward_out",
+	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_FORWARD_OUT,
+	  .bitwidth = 1,
+	},
+	{ .name = "drop",
+	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_DROP,
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
 
+static struct devlink_dpipe_hfield mlxsw_sp_dpipe_matches_erif[] = {
+	{ .header = &mlxsw_sp_dpipe_header_metadata,
+	  .field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
+	},
+};
+
+enum mlxsw_dp_dpipe_actions_erif_id {
+	MLXSW_SP_DPIPE_TABLE_ERIF_ACTION_DROP,
+	MLXSW_SP_DPIPE_TABLE_ERIF_ACTION_FOWARD,
+};
+
+static struct devlink_dpipe_hfield mlxsw_sp_dpipe_actions_erif[] = {
+	{ .header = &mlxsw_sp_dpipe_header_metadata,
+	  .field_id = MLXSW_SP_DPIPE_FIELD_METADATA_DROP,
+	},
+	{ .header =  &mlxsw_sp_dpipe_header_metadata,
+	  .field_id = MLXSW_SP_DPIPE_FIELD_METADATA_FORWARD_OUT,
+	},
+};
+
+static struct devlink_dpipe_table_ops mlxsw_sp_erif_ops = {};
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
+	err = devlink_dpipe_table_register(devlink,
+					   MLXSW_SP_DPIPE_TABLE_NAME_ERIF,
+					   &mlxsw_sp_erif_ops,
+					   mlxsw_sp,
+					   mlxsw_sp_dpipe_matches_erif,
+					   ARRAY_SIZE(mlxsw_sp_dpipe_matches_erif),
+					   mlxsw_sp_dpipe_actions_erif,
+					   ARRAY_SIZE(mlxsw_sp_dpipe_actions_erif),
+					   false);
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
+	devlink_dpipe_table_unregister(devlink, MLXSW_SP_DPIPE_TABLE_NAME_ERIF);
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
