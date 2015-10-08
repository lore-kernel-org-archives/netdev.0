From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx4_core: Fix mailbox leak in error flow when performing update qp
Date: Thu,  8 Oct 2015 17:14:02 +0300
Message-ID: <1444313643-15284-7-git-send-email-ogerlitz@mellanox.com>
References: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45267 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932227AbbJHOOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:32 -0400
In-Reply-To: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The procedure mlx4_update_qp leaks mailboxes in its error-flow, fix that.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/qp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 2026863..3311f35 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -422,15 +422,15 @@ int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
 	u64 qp_mask = 0;
 	int err = 0;
 
+	if (!attr || (attr & ~MLX4_UPDATE_QP_SUPPORTED_ATTRS))
+		return -EINVAL;
+
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 
 	cmd = (struct mlx4_update_qp_context *)mailbox->buf;
 
-	if (!attr || (attr & ~MLX4_UPDATE_QP_SUPPORTED_ATTRS))
-		return -EINVAL;
-
 	if (attr & MLX4_UPDATE_QP_SMAC) {
 		pri_addr_path_mask |= 1ULL << MLX4_UPD_QP_PATH_MASK_MAC_INDEX;
 		cmd->qp_context.pri_path.grh_mylmc = params->smac_index;
-- 
2.3.7
