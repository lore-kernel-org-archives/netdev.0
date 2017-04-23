From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 7/7] net/mlx5e: Fix ETHTOOL_GRXCLSRLALL handling
Date: Sun, 23 Apr 2017 13:08:02 +0300
Message-ID: <20170423100802.27630-8-saeedm@mellanox.com>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48693 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044742AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Handler for ETHTOOL_GRXCLSRLALL must set info->data to the size
of the table, regardless of the amount of entries in it.
Existing code does not do that, and this breaks all usage of ethtool -N
or -n without explicit location, with this error:
rmgr: Invalid RX class rules table size: Success

Set info->data to the table size.

Tested:
ethtool -n ens8
ethtool -N ens8 flow-type ip4 src-ip 1.1.1.1 dst-ip 2.2.2.2 action 1
ethtool -N ens8 flow-type ip4 src-ip 1.1.1.1 dst-ip 2.2.2.2 action 1 loc 55
ethtool -n ens8
ethtool -N ens8 delete 1023
ethtool -N ens8 delete 55

Fixes: f913a72aa008 ("net/mlx5e: Add support to get ethtool flow rules")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index d55fff0ba388..26fc77e80f7b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -564,6 +564,7 @@ int mlx5e_ethtool_get_all_flows(struct mlx5e_priv *priv, struct ethtool_rxnfc *i
 	int idx = 0;
 	int err = 0;
 
+	info->data = MAX_NUM_OF_ETHTOOL_RULES;
 	while ((!err || err == -ENOENT) && idx < info->rule_cnt) {
 		err = mlx5e_ethtool_get_flow(priv, info, location);
 		if (!err)
-- 
2.11.0
