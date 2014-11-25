From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Limit count field to 24 bits in qp_alloc_res
Date: Tue, 25 Nov 2014 11:54:31 +0200
Message-ID: <1416909271-28840-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43221 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751837AbaKYJyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 04:54:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Some VF drivers use the upper byte of "param1" (the qp count field)
in mlx4_qp_reserve_range() to pass flags which are used to optimize
the range allocation.

Under the current code, if any of these flags are set, the 32-bit
count field yields a count greater than 2^24, which is out of range,
and this VF fails.

As these flags represent a "best-effort" allocation hint anyway, they may
safely be ignored. Therefore, the PF driver may simply mask out the bits.

Fixes: c82e9aa0a8 "mlx4_core: resource tracking for HCA resources used by guests"
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Hi Dave, 

This fix goes way backi down to kernel 3.3... I think we will be good 
if it pushed to -stable of >= 3.10

 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 5d2498d..cd5cf6d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1546,7 +1546,7 @@ static int qp_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 
 	switch (op) {
 	case RES_OP_RESERVE:
-		count = get_param_l(&in_param);
+		count = get_param_l(&in_param) & 0xffffff;
 		align = get_param_h(&in_param);
 		err = mlx4_grant_resource(dev, slave, RES_QP, count, 0);
 		if (err)
-- 
1.7.1
