From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 6/6] net/mlx5e: Avoid doing a cleanup call if the profile doesn't have it
Date: Thu, 15 Jun 2017 23:55:30 +0300
Message-ID: <20170615205530.26674-7-saeedm@mellanox.com>
References: <20170615205530.26674-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52485 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750820AbdFOU4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:56:33 -0400
In-Reply-To: <20170615205530.26674-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The error flow of mlx5e_create_netdev calls the cleanup call
of the given profile without checking if it exists, fix that.

Currently the VF reps don't register that callback and we crash
if getting into error -- can be reproduced by the user doing ctrl^C
while attempting to change the sriov mode from legacy to switchdev.

Fixes: 26e59d8077a3 '(net/mlx5e: Implement mlx5e interface attach/detach callbacks')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 41cd22a223dc..277f4de30375 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -4241,7 +4241,8 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 	return netdev;
 
 err_cleanup_nic:
-	profile->cleanup(priv);
+	if (profile->cleanup)
+		profile->cleanup(priv);
 	free_netdev(netdev);
 
 	return NULL;
-- 
2.11.0
