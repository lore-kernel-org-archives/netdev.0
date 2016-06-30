From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 11/13] net/mlx5e: Fix select queue callback
Date: Thu, 30 Jun 2016 17:34:48 +0300
Message-ID: <1467297290-11443-12-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37713 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932081AbcF3OhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:23 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

The default fallback function used by mlx5e select queue can return
any TX queues in range [0..dev->num_real_tx_queues).

The current implementation assumes that the fallback function returns
a number in the range [0.. number of channels).  Actually
dev->num_real_tx_queues = (number of channels) * dev->num_tc;
which is more than the expected range if num_tc is configured and could
lead to crashes.

To fix this we test if num_tc is not configured we can safely return the
fallback suggestion, if not we will reciprocal_scale the fallback
result and normalize it to the desired range.

Fixes: 08fb1dacdd76 ('net/mlx5e: Support DCBNL IEEE ETS')
Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reported-by: Doug Ledford <dledford@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  5 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 16 ++++++++++++++--
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 103feab..216fe3e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1707,8 +1707,11 @@ static void mlx5e_netdev_set_tcs(struct net_device *netdev)
 
 	netdev_set_num_tc(netdev, ntc);
 
+	/* Map netdev TCs to offset 0
+	 * We have our own UP to TXQ mapping for QoS
+	 */
 	for (tc = 0; tc < ntc; tc++)
-		netdev_set_tc_queue(netdev, tc, nch, tc * nch);
+		netdev_set_tc_queue(netdev, tc, nch, 0);
 }
 
 int mlx5e_open_locked(struct net_device *netdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 42a5f06..5740b46 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -110,8 +110,20 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	int channel_ix = fallback(dev, skb);
-	int up = (netdev_get_num_tc(dev) && skb_vlan_tag_present(skb)) ?
-		 skb->vlan_tci >> VLAN_PRIO_SHIFT : 0;
+	int up = 0;
+
+	if (!netdev_get_num_tc(dev))
+		return channel_ix;
+
+	if (skb_vlan_tag_present(skb))
+		up = skb->vlan_tci >> VLAN_PRIO_SHIFT;
+
+	/* channel_ix can be larger than num_channels since
+	 * dev->num_real_tx_queues = num_channels * num_tc
+	 */
+	if (channel_ix >= priv->params.num_channels)
+		channel_ix = reciprocal_scale(channel_ix,
+					      priv->params.num_channels);
 
 	return priv->channeltc_to_txq_map[channel_ix][up];
 }
-- 
2.8.0
