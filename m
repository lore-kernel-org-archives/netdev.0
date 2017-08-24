From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/12] mlxsw: spectrum_router: Add helpers for neighbor access
Date: Thu, 24 Aug 2017 08:40:04 +0200
Message-ID: <20170824064010.1646-7-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36598 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdHXGkY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:24 -0400
Received: by mail-wm0-f68.google.com with SMTP id f127so1700228wmf.3
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:23 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This is done as a preparation before introducing the ability to dump the
host table via dpipe, and to count the table size. The mlxsw's neighbor
representative struct stays private to the router module.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 36 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  | 13 ++++++++
 2 files changed, 49 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index a0a9728..0b989e1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -909,6 +909,42 @@ static const struct rhashtable_params mlxsw_sp_neigh_ht_params = {
 	.key_len = sizeof(struct mlxsw_sp_neigh_key),
 };
 
+struct mlxsw_sp_neigh_entry *
+mlxsw_sp_rif_neigh_next(struct mlxsw_sp_rif *rif,
+			struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	if (!neigh_entry) {
+		if (list_empty(&rif->neigh_list))
+			return NULL;
+		else
+			return list_first_entry(&rif->neigh_list,
+						typeof(*neigh_entry),
+						rif_list_node);
+	}
+	if (neigh_entry->rif_list_node.next == &rif->neigh_list)
+		return NULL;
+	return list_next_entry(neigh_entry, rif_list_node);
+}
+
+int mlxsw_sp_neigh_entry_type(struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	return neigh_entry->key.n->tbl->family;
+}
+
+unsigned char *
+mlxsw_sp_neigh_entry_ha(struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	return neigh_entry->ha;
+}
+
+u32 mlxsw_sp_neigh4_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	struct neighbour *n;
+
+	n = neigh_entry->key.n;
+	return ntohl(*((__be32 *) n->primary_key));
+}
+
 static struct mlxsw_sp_neigh_entry *
 mlxsw_sp_neigh_entry_alloc(struct mlxsw_sp *mlxsw_sp, struct neighbour *n,
 			   u16 rif)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index a3e8d2b..80ac032 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -42,6 +42,8 @@ enum mlxsw_sp_rif_counter_dir {
 	MLXSW_SP_RIF_COUNTER_EGRESS,
 };
 
+struct mlxsw_sp_neigh_entry;
+
 struct mlxsw_sp_rif *mlxsw_sp_rif_by_index(const struct mlxsw_sp *mlxsw_sp,
 					   u16 rif_index);
 u16 mlxsw_sp_rif_index(const struct mlxsw_sp_rif *rif);
@@ -56,5 +58,16 @@ void mlxsw_sp_rif_counter_free(struct mlxsw_sp *mlxsw_sp,
 int mlxsw_sp_rif_counter_alloc(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_rif *rif,
 			       enum mlxsw_sp_rif_counter_dir dir);
+struct mlxsw_sp_neigh_entry *
+mlxsw_sp_rif_neigh_next(struct mlxsw_sp_rif *rif,
+			struct mlxsw_sp_neigh_entry *neigh_entry);
+int mlxsw_sp_neigh_entry_type(struct mlxsw_sp_neigh_entry *neigh_entry);
+unsigned char *
+mlxsw_sp_neigh_entry_ha(struct mlxsw_sp_neigh_entry *neigh_entry);
+u32 mlxsw_sp_neigh4_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry);
+
+#define mlxsw_sp_rif_neigh_for_each(neigh_entry, rif)				\
+	for (neigh_entry = mlxsw_sp_rif_neigh_next(rif, NULL); neigh_entry;	\
+	     neigh_entry = mlxsw_sp_rif_neigh_next(rif, neigh_entry))
 
 #endif /* _MLXSW_ROUTER_H_*/
-- 
2.9.3
