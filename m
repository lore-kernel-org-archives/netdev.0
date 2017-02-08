From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: acl: Fix mlxsw_afa_block_commit error path
Date: Wed,  8 Feb 2017 10:39:16 +0100
Message-ID: <1486546756-1950-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, dan.carpenter@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36653 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932644AbdBHJjX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 04:39:23 -0500
Received: by mail-wr0-f195.google.com with SMTP id k90so8161902wrc.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 01:39:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

No rollback is needed since the chain is in consistent state and
mlxsw_afa_block_destroy() will take care of putting it away. So remove
the one we have now which is wrong. Also move the set of 'finished' flag
to the beginning of the function, because the block is certainly unusable
for future action addition no matter if the function succeeds or not.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 4cda7d8d7098 ("mlxsw: core: Introduce flexible actions support")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/core_acl_flex_actions.c    | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index 34e2fef..42bb18f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -356,9 +356,9 @@ int mlxsw_afa_block_commit(struct mlxsw_afa_block *block)
 {
 	struct mlxsw_afa_set *set = block->cur_set;
 	struct mlxsw_afa_set *prev_set;
-	int err;
 
 	block->cur_set = NULL;
+	block->finished = true;
 
 	/* Go over all linked sets starting from last
 	 * and try to find existing set in the hash table.
@@ -368,10 +368,12 @@ int mlxsw_afa_block_commit(struct mlxsw_afa_block *block)
 	do {
 		prev_set = set->prev;
 		set = mlxsw_afa_set_get(block->afa, set);
-		if (IS_ERR(set)) {
-			err = PTR_ERR(set);
-			goto rollback;
-		}
+		if (IS_ERR(set))
+			/* No rollback is needed since the chain is
+			 * in consistent state and mlxsw_afa_block_destroy
+			 * will take care of putting it away.
+			 */
+			return PTR_ERR(set);
 		if (prev_set) {
 			prev_set->next = set;
 			mlxsw_afa_set_next_set(prev_set, set->kvdl_index);
@@ -380,13 +382,7 @@ int mlxsw_afa_block_commit(struct mlxsw_afa_block *block)
 	} while (prev_set);
 
 	block->first_set = set;
-	block->finished = true;
 	return 0;
-
-rollback:
-	while ((set = set->next))
-		mlxsw_afa_set_put(block->afa, set);
-	return err;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_commit);
 
-- 
2.7.4
