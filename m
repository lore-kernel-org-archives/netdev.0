From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] mlxsw: spectrum_router: Provide offload indication using nexthop flags
Date: Wed,  2 Aug 2017 09:56:03 +0200
Message-ID: <20170802075606.1090-4-jiri@resnulli.us>
References: <20170802075606.1090-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33368 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdHBH4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:14 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so3049686wrd.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:14 -0700 (PDT)
In-Reply-To: <20170802075606.1090-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In a similar fashion to previous patch, use the nexthop flags to provide
offload indication instead of the FIB info's flags.

In case a nexthop in a multipath route can't be offloaded (gateway's MAC
can't be resolved, for example), then its offload flag isn't set.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 38 ++++++++++++++++++++--
 1 file changed, 36 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index add03fa..4cdeedf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2103,13 +2103,47 @@ mlxsw_sp_fib_entry_should_offload(const struct mlxsw_sp_fib_entry *fib_entry)
 	}
 }
 
+static void
+mlxsw_sp_fib4_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp = fib_entry->nh_group;
+	int i;
+
+	if (fib_entry->type == MLXSW_SP_FIB_ENTRY_TYPE_LOCAL) {
+		nh_grp->nexthops->key.fib_nh->nh_flags |= RTNH_F_OFFLOAD;
+		return;
+	}
+
+	for (i = 0; i < nh_grp->count; i++) {
+		struct mlxsw_sp_nexthop *nh = &nh_grp->nexthops[i];
+
+		if (nh->offloaded)
+			nh->key.fib_nh->nh_flags |= RTNH_F_OFFLOAD;
+		else
+			nh->key.fib_nh->nh_flags &= ~RTNH_F_OFFLOAD;
+	}
+}
+
+static void
+mlxsw_sp_fib4_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp = fib_entry->nh_group;
+	int i;
+
+	for (i = 0; i < nh_grp->count; i++) {
+		struct mlxsw_sp_nexthop *nh = &nh_grp->nexthops[i];
+
+		nh->key.fib_nh->nh_flags &= ~RTNH_F_OFFLOAD;
+	}
+}
+
 static void mlxsw_sp_fib_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 {
 	fib_entry->offloaded = true;
 
 	switch (fib_entry->fib_node->fib->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
-		fib_info_offload_inc(fib_entry->nh_group->key.fi);
+		mlxsw_sp_fib4_entry_offload_set(fib_entry);
 		break;
 	case MLXSW_SP_L3_PROTO_IPV6:
 		WARN_ON_ONCE(1);
@@ -2121,7 +2155,7 @@ mlxsw_sp_fib_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
 {
 	switch (fib_entry->fib_node->fib->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
-		fib_info_offload_dec(fib_entry->nh_group->key.fi);
+		mlxsw_sp_fib4_entry_offload_unset(fib_entry);
 		break;
 	case MLXSW_SP_L3_PROTO_IPV6:
 		WARN_ON_ONCE(1);
-- 
2.9.3
