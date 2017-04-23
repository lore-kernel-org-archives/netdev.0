From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 5/7] net/mlx5: Fix UAR memory leak
Date: Sun, 23 Apr 2017 13:08:00 +0300
Message-ID: <20170423100802.27630-6-saeedm@mellanox.com>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48692 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044747AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

When UAR is released, we deallocate the device resource, but
don't unmmap the UAR mapping memory.
Fix the leak by unmapping this memory.

Fixes: a6d51b68611e9 ('net/mlx5: Introduce blue flame register allocator)
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/uar.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index 2e6b0f290ddc..222b25908d01 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -87,6 +87,7 @@ static void up_rel_func(struct kref *kref)
 	struct mlx5_uars_page *up = container_of(kref, struct mlx5_uars_page, ref_count);
 
 	list_del(&up->list);
+	iounmap(up->map);
 	if (mlx5_cmd_free_uar(up->mdev, up->index))
 		mlx5_core_warn(up->mdev, "failed to free uar index %d\n", up->index);
 	kfree(up->reg_bitmap);
-- 
2.11.0
