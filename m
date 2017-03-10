From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/5] net/mlx5e: Fix loopback selftest
Date: Fri, 10 Mar 2017 14:33:05 +0200
Message-ID: <20170310123305.2185-6-saeedm@mellanox.com>
References: <20170310123305.2185-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38698 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S937263AbdCJMdd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:33:33 -0500
In-Reply-To: <20170310123305.2185-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Change packet type handler to ETH_P_IP instead of ETH_P_ALL
since we are already expecting an IP packet.

Also, using ETH_P_ALL will cause the loopback test packet type handler
to be called on all outgoing packets, especially our own self loopback
test SKB, which will be validated on xmit as well, and we don't want that.

Tested with:
ethtool -t ethX
validated that the loopback test passes.

Fixes: 0952da791c97 ('net/mlx5e: Add support for loopback selftest')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index 31e3cb7ee5fe..5621dcfda4f1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -204,9 +204,6 @@ mlx5e_test_loopback_validate(struct sk_buff *skb,
 	struct iphdr *iph;
 
 	/* We are only going to peek, no need to clone the SKB */
-	if (skb->protocol != htons(ETH_P_IP))
-		goto out;
-
 	if (MLX5E_TEST_PKT_SIZE - ETH_HLEN > skb_headlen(skb))
 		goto out;
 
@@ -249,7 +246,7 @@ static int mlx5e_test_loopback_setup(struct mlx5e_priv *priv,
 	lbtp->loopback_ok = false;
 	init_completion(&lbtp->comp);
 
-	lbtp->pt.type = htons(ETH_P_ALL);
+	lbtp->pt.type = htons(ETH_P_IP);
 	lbtp->pt.func = mlx5e_test_loopback_validate;
 	lbtp->pt.dev = priv->netdev;
 	lbtp->pt.af_packet_priv = lbtp;
-- 
2.11.0
