From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 05/10] net/mlx5: Update last-use statistics for flow rules
Date: Thu, 18 Aug 2016 21:09:06 +0300
Message-ID: <1471543751-24164-6-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amir@vadai.me>, Amir Vadai <amirva@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41784 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754211AbcHSBnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:09 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

Set lastuse statistic, when number of packets is changed compared to
last query. This was wrongly dropped when bulk counter reading was added.

Fixes: a351a1b03bf1 ('net/mlx5: Introduce bulk reading of flow counters')
Signed-off-by: Amir Vadai <amirva@mellanox.com>
Reported-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index c2877e9..3a9195b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -126,12 +126,21 @@ static struct rb_node *mlx5_fc_stats_query(struct mlx5_core_dev *dev,
 	for (node = &first->node; node; node = rb_next(node)) {
 		struct mlx5_fc *counter = rb_entry(node, struct mlx5_fc, node);
 		struct mlx5_fc_cache *c = &counter->cache;
+		u64 packets;
+		u64 bytes;
 
 		if (counter->id > last_id)
 			break;
 
 		mlx5_cmd_fc_bulk_get(dev, b,
-				     counter->id, &c->packets, &c->bytes);
+				     counter->id, &packets, &bytes);
+
+		if (c->packets == packets)
+			continue;
+
+		c->packets = packets;
+		c->bytes = bytes;
+		c->lastuse = jiffies;
 	}
 
 out:
-- 
2.7.4
