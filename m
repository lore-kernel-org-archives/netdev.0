From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/5] net/mlx4_core: Make sure the max number of QPs per MCG isn't exceeded
Date: Wed, 16 Jul 2014 11:57:49 +0300
Message-ID: <1405501071-9340-4-git-send-email-amirv@mellanox.com>
References: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alexander Guller <alexg@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50768 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756699AbaGPI6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 04:58:12 -0400
In-Reply-To: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Guller <alexg@mellanox.com>

In B0 steering mode when adding QPs to the default MCG entry need
to check that maximal number of QPs per MCG entry was not exceeded.


Signed-off-by: Alexander Guller <alexg@mellanox.com>
Reviewed-by: Aviad Yehezkel <aviadye@mellanox.co.il>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 04a8636..39ab85a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -477,8 +477,14 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 	/* now need to add all the promisc qps to default entry */
 	memset(mgm, 0, sizeof *mgm);
 	members_count = 0;
-	list_for_each_entry(dqp, &s_steer->promisc_qps[steer], list)
+	list_for_each_entry(dqp, &s_steer->promisc_qps[steer], list) {
+		if (members_count == dev->caps.num_qp_per_mgm) {
+			/* entry is full */
+			err = -ENOMEM;
+			goto out_list;
+		}
 		mgm->qp[members_count++] = cpu_to_be32(dqp->qpn & MGM_QPN_MASK);
+	}
 	mgm->members_count = cpu_to_be32(members_count | MLX4_PROT_ETH << 30);
 
 	err = mlx4_WRITE_PROMISC(dev, port, steer, mailbox);
-- 
1.8.3.4
