From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V3 7/9] net/mlx5e: Don't modify CQ before it was created
Date: Wed,  2 Mar 2016 00:13:38 +0200
Message-ID: <1456870420-23655-8-git-send-email-saeedm@mellanox.com>
References: <1456870420-23655-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59513 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752144AbcCAWWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 17:22:10 -0500
In-Reply-To: <1456870420-23655-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Calling mlx5e_set_coalesce while the interface is down will result in
modifying CQs that don't exist.

Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4
Ethernet functionality')
Signed-off-by: Gal Pressman <galp@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index a1b3bb4..0959656 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -423,11 +423,15 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 	if (!MLX5_CAP_GEN(mdev, cq_moderation))
 		return -ENOTSUPP;
 
+	mutex_lock(&priv->state_lock);
 	priv->params.tx_cq_moderation_usec = coal->tx_coalesce_usecs;
 	priv->params.tx_cq_moderation_pkts = coal->tx_max_coalesced_frames;
 	priv->params.rx_cq_moderation_usec = coal->rx_coalesce_usecs;
 	priv->params.rx_cq_moderation_pkts = coal->rx_max_coalesced_frames;
 
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+		goto out;
+
 	for (i = 0; i < priv->params.num_channels; ++i) {
 		c = priv->channel[i];
 
@@ -443,6 +447,8 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 					       coal->rx_max_coalesced_frames);
 	}
 
+out:
+	mutex_unlock(&priv->state_lock);
 	return 0;
 }
 
-- 
1.7.1
