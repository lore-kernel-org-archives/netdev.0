From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] mlxsw: spectrum_router: Don't check state when refreshing offload indication
Date: Wed,  2 Aug 2017 09:56:04 +0200
Message-ID: <20170802075606.1090-5-jiri@resnulli.us>
References: <20170802075606.1090-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37473 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752084AbdHBH4Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:16 -0400
Received: by mail-wm0-f67.google.com with SMTP id t138so6117944wmt.4
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:16 -0700 (PDT)
In-Reply-To: <20170802075606.1090-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Previous patch removed the reliance on the counter in the FIB info to
set the offload indication, so we no longer need to keep an offload
state on each FIB entry and can just set or unset the RTNH_F_OFFLOAD
flag in each nexthop.

This is also necessary because we're going to need to refresh the
offload indication whenever the nexthop group associated with the FIB
entry is refreshed. Current check would prevent us from marking a newly
resolved nexthop as offloaded if the FIB entry is already marked as
offloaded.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 4cdeedf..40aecbc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -394,7 +394,6 @@ struct mlxsw_sp_fib_entry {
 	enum mlxsw_sp_fib_entry_type type;
 	struct list_head nexthop_group_node;
 	struct mlxsw_sp_nexthop_group *nh_group;
-	bool offloaded;
 };
 
 struct mlxsw_sp_fib4_entry {
@@ -2139,8 +2138,6 @@ mlxsw_sp_fib4_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
 
 static void mlxsw_sp_fib_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 {
-	fib_entry->offloaded = true;
-
 	switch (fib_entry->fib_node->fib->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		mlxsw_sp_fib4_entry_offload_set(fib_entry);
@@ -2160,8 +2157,6 @@ mlxsw_sp_fib_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
 	case MLXSW_SP_L3_PROTO_IPV6:
 		WARN_ON_ONCE(1);
 	}
-
-	fib_entry->offloaded = false;
 }
 
 static void
@@ -2170,17 +2165,13 @@ mlxsw_sp_fib_entry_offload_refresh(struct mlxsw_sp_fib_entry *fib_entry,
 {
 	switch (op) {
 	case MLXSW_REG_RALUE_OP_WRITE_DELETE:
-		if (!fib_entry->offloaded)
-			return;
 		return mlxsw_sp_fib_entry_offload_unset(fib_entry);
 	case MLXSW_REG_RALUE_OP_WRITE_WRITE:
 		if (err)
 			return;
-		if (mlxsw_sp_fib_entry_should_offload(fib_entry) &&
-		    !fib_entry->offloaded)
+		if (mlxsw_sp_fib_entry_should_offload(fib_entry))
 			mlxsw_sp_fib_entry_offload_set(fib_entry);
-		else if (!mlxsw_sp_fib_entry_should_offload(fib_entry) &&
-			 fib_entry->offloaded)
+		else if (!mlxsw_sp_fib_entry_should_offload(fib_entry))
 			mlxsw_sp_fib_entry_offload_unset(fib_entry);
 		return;
 	default:
-- 
2.9.3
