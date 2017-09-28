From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 06/11] net/mlx5e: Check encap entry state when offloading tunneled flows
Date: Thu, 28 Sep 2017 07:41:27 +0300
Message-ID: <20170928044132.30940-7-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Vlad Buslov <vladbu@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54398 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751626AbdI1EmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:06 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Buslov <vladbu@mellanox.com>

Encap entries cached by the driver could be invalidated due to
tunnel destination neighbour state changes.
When attempting to offload a flow that uses a cached encap entry,
we must check the entry validity and defer the offloading
if the entry exists but not valid.

When EAGAIN is returned, the flow offloading to hardware takes place
by the neigh update code when the tunnel destination neighbour
becomes connected.

Fixes: 232c001398ae ("net/mlx5e: Add support to neighbour update flow")
Signed-off-by: Vlad Buslov <vladbu@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index d3786005fba7..1aa2028ed995 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1859,6 +1859,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 		}
 	}
 
+	/* must verify if encap is valid or not */
 	if (found)
 		goto attach_flow;
 
@@ -1885,6 +1886,8 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	*encap_dev = e->out_dev;
 	if (e->flags & MLX5_ENCAP_ENTRY_VALID)
 		attr->encap_id = e->encap_id;
+	else
+		err = -EAGAIN;
 
 	return err;
 
-- 
2.13.0
