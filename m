From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 08/10] net/mlx4_core: Add explicit error message when rule doesn't meet configuration
Date: Thu, 11 Dec 2014 10:57:58 +0200
Message-ID: <1418288280-334-9-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40558 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934176AbaLKI7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:59:31 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

When a given flow steering rule is invalid in respect to the current
steering configuration, print the correct error message to the system log.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 8728431..a3867e7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -999,12 +999,27 @@ int mlx4_flow_attach(struct mlx4_dev *dev,
 	}
 
 	ret = mlx4_QP_FLOW_STEERING_ATTACH(dev, mailbox, size >> 2, reg_id);
-	if (ret == -ENOMEM)
+	if (ret == -ENOMEM) {
 		mlx4_err_rule(dev,
 			      "mcg table is full. Fail to register network rule\n",
 			      rule);
-	else if (ret)
-		mlx4_err_rule(dev, "Fail to register network rule\n", rule);
+	} else if (ret) {
+		if (ret == -ENXIO) {
+			if (dev->caps.steering_mode != MLX4_STEERING_MODE_DEVICE_MANAGED)
+				mlx4_err_rule(dev,
+					      "DMFS is not enabled, "
+					      "failed to register network rule.\n",
+					      rule);
+			else
+				mlx4_err_rule(dev,
+					      "Rule exceeds the dmfs_high_rate_mode limitations, "
+					      "failed to register network rule.\n",
+					      rule);
+
+		} else {
+			mlx4_err_rule(dev, "Fail to register network rule.\n", rule);
+		}
+	}
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 
-- 
1.7.1
