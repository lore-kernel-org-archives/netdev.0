From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/4] net/mlx4_core: Adjust port number in qp_attach wrapper when detaching
Date: Thu,  1 May 2014 15:51:53 +0300
Message-ID: <1398948716-6765-2-git-send-email-ogerlitz@mellanox.com>
References: <1398948716-6765-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, matanb@mellanox.com, amirv@mellanox.com,
	Jack Morgenstein <jackm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60870 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751963AbaEAMwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 08:52:14 -0400
In-Reply-To: <1398948716-6765-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

When using single ported VFs and the VF is using port 2, we need
to adjust the port accordingly (change it from 1 to 2).

Fixes: 449fc48 ('net/mlx4: Adapt code for N-Port VF')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   23 ++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 3b5f53e..3f27cba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3733,6 +3733,25 @@ static int qp_detach(struct mlx4_dev *dev, struct mlx4_qp *qp,
 	}
 }
 
+static int mlx4_adjust_port(struct mlx4_dev *dev, int slave,
+			    u8 *gid, enum mlx4_protocol prot)
+{
+	int real_port;
+
+	if (prot != MLX4_PROT_ETH)
+		return 0;
+
+	if (dev->caps.steering_mode == MLX4_STEERING_MODE_B0 ||
+	    (dev->caps.steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED)) {
+		real_port = mlx4_slave_convert_port(dev, slave, gid[5]);
+		if (real_port < 0)
+			return -EINVAL;
+		gid[5] = real_port;
+	}
+
+	return 0;
+}
+
 int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 			       struct mlx4_vhcr *vhcr,
 			       struct mlx4_cmd_mailbox *inbox,
@@ -3768,6 +3787,10 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 		if (err)
 			goto ex_detach;
 	} else {
+		err = mlx4_adjust_port(dev, slave, gid, prot);
+		if (err)
+			goto ex_put;
+
 		err = rem_mcg_res(dev, slave, rqp, gid, prot, type, &reg_id);
 		if (err)
 			goto ex_put;
-- 
1.7.1
