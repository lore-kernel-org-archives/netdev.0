From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 7/9] net/mlx5e: Fix memory leak if refreshing TIRs fails
Date: Mon, 29 Aug 2016 01:13:48 +0300
Message-ID: <1472422430-21583-8-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53059 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756160AbcH1WOe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:34 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Free 'in' command object also when mlx5_core_modify_tir fails.

Fixes: 724b2aa15126 ("net/mlx5e: TIRs management refactoring")
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_common.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index 673043c..9cce153 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -139,7 +139,7 @@ int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev)
 	struct mlx5e_tir *tir;
 	void *in;
 	int inlen;
-	int err;
+	int err = 0;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
 	in = mlx5_vzalloc(inlen);
@@ -151,10 +151,11 @@ int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev)
 	list_for_each_entry(tir, &mdev->mlx5e_res.td.tirs_list, list) {
 		err = mlx5_core_modify_tir(mdev, tir->tirn, in, inlen);
 		if (err)
-			return err;
+			goto out;
 	}
 
+out:
 	kvfree(in);
 
-	return 0;
+	return err;
 }
-- 
2.7.4
