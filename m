From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/4] net/mlx4_core: Use sink counter for the VF default as fallback
Date: Wed, 22 Jul 2015 16:53:46 +0300
Message-ID: <1437573229-13127-2-git-send-email-ogerlitz@mellanox.com>
References: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54935 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932937AbbGVNyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 09:54:16 -0400
In-Reply-To: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some old PF drivers don't let VFs allocate counters, in that case, use
the sink counter so the VF can load and operate properly.

Fixes: 6de5f7f6a1fa ('net/mlx4_core: Allocate default counter per port')
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 12fbfcb..29c2a01 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2273,6 +2273,11 @@ static int mlx4_allocate_default_counters(struct mlx4_dev *dev)
 		} else if (err == -ENOENT) {
 			err = 0;
 			continue;
+		} else if (mlx4_is_slave(dev) && err == -EINVAL) {
+			priv->def_counter[port] = MLX4_SINK_COUNTER_INDEX(dev);
+			mlx4_warn(dev, "can't allocate counter from old PF driver, using index %d\n",
+				  MLX4_SINK_COUNTER_INDEX(dev));
+			err = 0;
 		} else {
 			mlx4_err(dev, "%s: failed to allocate default counter port %d err %d\n",
 				 __func__, port + 1, err);
-- 
2.3.7
