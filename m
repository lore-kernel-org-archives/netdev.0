From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 05/10] net/mlx4: Add a check if there are too many reserved QPs
Date: Thu, 11 Dec 2014 10:57:55 +0200
Message-ID: <1418288280-334-6-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Dotan Barak <dotanb@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40511 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934168AbaLKI7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:59:11 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.co.il>

The number of reserved QPs is affected both from the firmware and
from the driver's requirements. This patch adds a check that
validates that this number is indeed feasable.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.co.il>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/qp.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 40e82ed..8720428 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -478,6 +478,7 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 	struct mlx4_qp_table *qp_table = &mlx4_priv(dev)->qp_table;
 	int err;
 	int reserved_from_top = 0;
+	int reserved_from_bot;
 	int k;
 
 	spin_lock_init(&qp_table->lock);
@@ -534,9 +535,14 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 	* b. All the proxy SQPs (8 per function)
 	* c. All the tunnel QPs (8 per function)
 	*/
+	reserved_from_bot = mlx4_num_reserved_sqps(dev);
+	if (reserved_from_bot + reserved_from_top > dev->caps.num_qps) {
+		mlx4_err(dev, "Number of reserved QPs is higher than number of QPs\n");
+		return -EINVAL;
+	}
 
 	err = mlx4_bitmap_init(&qp_table->bitmap, dev->caps.num_qps,
-			       (1 << 23) - 1, mlx4_num_reserved_sqps(dev),
+			       (1 << 23) - 1, reserved_from_bot,
 			       reserved_from_top);
 	if (err)
 		return err;
-- 
1.7.1
