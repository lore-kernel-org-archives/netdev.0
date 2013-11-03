From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 6/9] net/mlx4_core: Fix checking order in MR table init
Date: Sun,  3 Nov 2013 10:03:22 +0200
Message-ID: <1383465805-28640-7-git-send-email-ogerlitz@mellanox.com>
References: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37910 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752631Ab3KCIDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Nov 2013 03:03:41 -0500
In-Reply-To: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In procedure mlx4_init_mr_table(), slaves should do no processing,
but should return success. This initialization is hypervisor-only.

However, the check for num_mpts being a power-of-2 was performed
before the check to return immediately if the driver is for a slave.
This resulted in spurious failures.

The order of performing the checks is reversed, so that if the
driver is for a slave, no processing is done and success is returned.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index f91719a..63391a1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -755,14 +755,14 @@ int mlx4_init_mr_table(struct mlx4_dev *dev)
 	struct mlx4_mr_table *mr_table = &priv->mr_table;
 	int err;
 
-	if (!is_power_of_2(dev->caps.num_mpts))
-		return -EINVAL;
-
 	/* Nothing to do for slaves - all MR handling is forwarded
 	* to the master */
 	if (mlx4_is_slave(dev))
 		return 0;
 
+	if (!is_power_of_2(dev->caps.num_mpts))
+		return -EINVAL;
+
 	err = mlx4_bitmap_init(&mr_table->mpt_bitmap, dev->caps.num_mpts,
 			       ~0, dev->caps.reserved_mrws, 0);
 	if (err)
-- 
1.7.1
