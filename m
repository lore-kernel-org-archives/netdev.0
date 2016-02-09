From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 3/5] net/mlx4: fix some error handling in mlx4_multi_func_init()
Date: Tue,  9 Feb 2016 21:11:14 +0100
Message-ID: <1455048677-19882-4-git-send-email-linux@rasmusvillemoes.dk>
References: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Yishai Hadas <yishaih@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The while loop after err_slaves should use post-decrement; otherwise
we'll fail to do the kfrees for i==0, and will run into out-of-bounds
accesses if the setup above failed already at i==0.

The predecrement in the --port is ok, since ->vlan_filter is
(bizarrely) 1-indexed. But I'm changing 'if' to 'while' since it's a
bit ugly to rely on MLX4_MAX_PORTS being 2.

[I'm not sure why one even bothers populating the ->vlan_filter array:
mlx4.h isn't #included by anything outside
drivers/net/ethernet/mellanox/mlx4/, and "git grep -C2 -w vlan_filter
drivers/net/ethernet/mellanox/mlx4/" seems to suggest that the
vlan_filter elements aren't used at all.]

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index d48d5793407d..bfe8234abbba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2369,7 +2369,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 					kzalloc(sizeof(struct mlx4_vlan_fltr),
 						GFP_KERNEL);
 				if (!s_state->vlan_filter[port]) {
-					if (--port)
+					while (--port)
 						kfree(s_state->vlan_filter[port]);
 					goto err_slaves;
 				}
@@ -2429,7 +2429,7 @@ err_thread:
 	flush_workqueue(priv->mfunc.master.comm_wq);
 	destroy_workqueue(priv->mfunc.master.comm_wq);
 err_slaves:
-	while (--i) {
+	while (i--) {
 		for (port = 1; port <= MLX4_MAX_PORTS; port++)
 			kfree(priv->mfunc.master.slave_state[i].vlan_filter[port]);
 	}
-- 
2.1.4
