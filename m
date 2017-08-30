From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 09/11] net/mlx5: E-Switch, Unload the representors in the correct order
Date: Thu, 31 Aug 2017 01:21:08 +0300
Message-ID: <20170830222110.15737-10-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Shahar Klein <shahark@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53280 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751382AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahar Klein <shahark@mellanox.com>

When changing from switchdev to legacy mode, all the representor port
devices (uplink nic and reps) are cleaned up. Part of this cleaning
process is removing the neigh entries and the hash table containing them.
However, a representor neigh entry might be linked to the uplink port
hash table and if the uplink nic is cleaned first the cleaning of the
representor will end up in null deref.
Fix that by unloading the representors in the opposite order of load.

Fixes: cb67b832921c ("net/mlx5e: Introduce SRIOV VF representors")
Signed-off-by: Shahar Klein <shahark@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 95b64025ce36..5bc0593bd76e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -815,7 +815,7 @@ void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 	struct mlx5_eswitch_rep *rep;
 	int vport;
 
-	for (vport = 0; vport < nvports; vport++) {
+	for (vport = nvports - 1; vport >= 0; vport--) {
 		rep = &esw->offloads.vport_reps[vport];
 		if (!rep->valid)
 			continue;
-- 
2.13.0
