From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: acl: Use PBS type for forward action
Date: Wed, 15 Feb 2017 12:09:51 +0100
Message-ID: <1487156991-11182-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33929 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751455AbdBOLJy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 06:09:54 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so7646588wmi.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 03:09:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Current behaviour of "mirred redirect" action (forward) offload is a bit
odd. For matched packets the action forwards them to the desired
destination, but it also lets the packet duplicates to go the original
way down (bridge, router, etc). That is more like "mirred mirror".
Fix this by using PBS type which behaves exactly like "mirred redirect".
Note that PBS does not support loopback mode.

Fixes: 4cda7d8d7098 ("mlxsw: core: Introduce flexible actions support")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/core_acl_flex_actions.c  | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index 42bb18f..5f337715 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -651,17 +651,16 @@ int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 			       u8 local_port, bool in_port)
 {
 	struct mlxsw_afa_fwd_entry_ref *fwd_entry_ref;
-	u32 kvdl_index = 0;
+	u32 kvdl_index;
 	char *act;
 	int err;
 
-	if (!in_port) {
-		fwd_entry_ref = mlxsw_afa_fwd_entry_ref_create(block,
-							       local_port);
-		if (IS_ERR(fwd_entry_ref))
-			return PTR_ERR(fwd_entry_ref);
-		kvdl_index = fwd_entry_ref->fwd_entry->kvdl_index;
-	}
+	if (in_port)
+		return -EOPNOTSUPP;
+	fwd_entry_ref = mlxsw_afa_fwd_entry_ref_create(block, local_port);
+	if (IS_ERR(fwd_entry_ref))
+		return PTR_ERR(fwd_entry_ref);
+	kvdl_index = fwd_entry_ref->fwd_entry->kvdl_index;
 
 	act = mlxsw_afa_block_append_action(block, MLXSW_AFA_FORWARD_CODE,
 					    MLXSW_AFA_FORWARD_SIZE);
@@ -669,13 +668,12 @@ int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 		err = -ENOBUFS;
 		goto err_append_action;
 	}
-	mlxsw_afa_forward_pack(act, MLXSW_AFA_FORWARD_TYPE_OUTPUT,
+	mlxsw_afa_forward_pack(act, MLXSW_AFA_FORWARD_TYPE_PBS,
 			       kvdl_index, in_port);
 	return 0;
 
 err_append_action:
-	if (!in_port)
-		mlxsw_afa_fwd_entry_ref_destroy(block, fwd_entry_ref);
+	mlxsw_afa_fwd_entry_ref_destroy(block, fwd_entry_ref);
 	return err;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_fwd);
-- 
2.7.4
