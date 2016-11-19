From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v3 3/4] bpf, mlx5: drop priv->xdp_prog reference on netdev cleanup
Date: Sat, 19 Nov 2016 01:45:02 +0100
Message-ID: <29469b54bfddfe218266b8b902a3735034d28226.1479514784.git.daniel@iogearbox.net>
References: <cover.1479514784.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        zhiyisun@gmail.com, ranas@mellanox.com, saeedm@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58649 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752532AbcKSApZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 19:45:25 -0500
In-Reply-To: <cover.1479514784.git.daniel@iogearbox.net>
In-Reply-To: <cover.1479514784.git.daniel@iogearbox.net>
References: <cover.1479514784.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx5e_xdp_set() is currently the only place where we drop reference on the
prog sitting in priv->xdp_prog when it's exchanged by a new one. We also
need to make sure that we eventually release that reference, for example,
in case the netdev is dismantled, otherwise we leak the program.

Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 491cff9..6957608 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3705,6 +3705,9 @@ static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 
 	if (MLX5_CAP_GEN(mdev, vport_group_manager))
 		mlx5_eswitch_unregister_vport_rep(esw, 0);
+
+	if (priv->xdp_prog)
+		bpf_prog_put(priv->xdp_prog);
 }
 
 static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
-- 
1.9.3
