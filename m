From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 11/11] net/mlx4_core: Update the HCA core clock frequency after INIT_PORT
Date: Tue, 27 Jan 2015 15:58:09 +0200
Message-ID: <1422367089-13419-12-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46337 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757611AbbA0N7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:12 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

The firmware might change the hca core clock frequency after the driver
issues the INIT_PORT command. Therefore we need to query the new
value again and save in to the cached dev caps.

Fixes: ddd8a6c1 ('net/mlx4_core: Read HCA frequency and map internal clock')
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 0ab81a9..dbabfae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1897,6 +1897,36 @@ out:
 	return err;
 }
 
+static int mlx4_hca_core_clock_update(struct mlx4_dev *dev)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	__be32 *outbox;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox)) {
+		mlx4_warn(dev, "hca_core_clock mailbox allocation failed\n");
+		return PTR_ERR(mailbox);
+	}
+	outbox = mailbox->buf;
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0,
+			   MLX4_CMD_QUERY_HCA,
+			   MLX4_CMD_TIME_CLASS_B,
+			   !mlx4_is_slave(dev));
+	if (err) {
+		mlx4_warn(dev, "hca_core_clock update failed\n");
+		goto out;
+	}
+
+	MLX4_GET(dev->caps.hca_core_clock, outbox, QUERY_HCA_CORE_CLOCK_OFFSET);
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+
+	return err;
+}
+
 /* for IB-type ports only in SRIOV mode. Checks that both proxy QP0
  * and real QP0 are active, so that the paravirtualized QP0 is ready
  * to operate */
@@ -2001,6 +2031,9 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 		err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_INIT_PORT,
 			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 
+	if (!err)
+		mlx4_hca_core_clock_update(dev);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx4_INIT_PORT);
-- 
1.9.3
