From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 02/11] net/mlx4_en: Use HW counters for rx/tx bytes/packets in PF device
Date: Tue, 23 Jun 2015 17:14:13 +0300
Message-ID: <1435068862-26488-3-git-send-email-ogerlitz@mellanox.com>
References: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41164 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933905AbbFWOOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:14:48 -0400
In-Reply-To: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Under SRIOV, the port rx/tx bytes/packets statistics should by read
from the HW instead of using the PF netdevice SW accounting. This is
needed in order to get the full port statistics and not just the PF
own ones

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 73f6277..ee99e67 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -203,6 +203,20 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 		priv->port_stats.tso_packets       += ring->tso_packets;
 		priv->port_stats.xmit_more         += ring->xmit_more;
 	}
+	if (mlx4_is_master(mdev->dev)) {
+		stats->rx_packets = en_stats_adder(&mlx4_en_stats->RTOT_prio_0,
+						   &mlx4_en_stats->RTOT_prio_1,
+						   NUM_PRIORITIES);
+		stats->tx_packets = en_stats_adder(&mlx4_en_stats->TTOT_prio_0,
+						   &mlx4_en_stats->TTOT_prio_1,
+						   NUM_PRIORITIES);
+		stats->rx_bytes = en_stats_adder(&mlx4_en_stats->ROCT_prio_0,
+						 &mlx4_en_stats->ROCT_prio_1,
+						 NUM_PRIORITIES);
+		stats->tx_bytes = en_stats_adder(&mlx4_en_stats->TOCT_prio_0,
+						 &mlx4_en_stats->TOCT_prio_1,
+						 NUM_PRIORITIES);
+	}
 
 	/* net device stats */
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
-- 
2.3.7
