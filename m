From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/3] net/mlx5: Fix flow counter bulk command out mailbox allocation
Date: Sun, 18 Sep 2016 18:20:27 +0300
Message-ID: <1474212029-1052-2-git-send-email-ogerlitz@mellanox.com>
References: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56223 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S935017AbcIRPUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:20:41 -0400
In-Reply-To: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

The FW command output length should be only the length of struct
mlx5_cmd_fc_bulk out field. Failing to do so will cause the memcpy
call which is invoked later in the driver to write over wrong memory
address and corrupt kernel memory which results in random crashes.

This bug was found using the kernel address sanitizer (kasan).

Fixes: a351a1b03bf1 ('net/mlx5: Introduce bulk reading of flow counters')
Signed-off-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 9134010..287ade1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -425,11 +425,11 @@ struct mlx5_cmd_fc_bulk *
 mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u16 id, int num)
 {
 	struct mlx5_cmd_fc_bulk *b;
-	int outlen = sizeof(*b) +
+	int outlen =
 		MLX5_ST_SZ_BYTES(query_flow_counter_out) +
 		MLX5_ST_SZ_BYTES(traffic_counter) * num;
 
-	b = kzalloc(outlen, GFP_KERNEL);
+	b = kzalloc(sizeof(*b) + outlen, GFP_KERNEL);
 	if (!b)
 		return NULL;
 
-- 
2.3.7
