From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/4] net/mlx4_core: Protect QUERY_PORT wrapper from untrusted guests
Date: Tue, 30 Sep 2014 12:03:49 +0300
Message-ID: <1412067830-30438-4-git-send-email-ogerlitz@mellanox.com>
References: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50223 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752006AbaI3JD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 05:03:59 -0400
In-Reply-To: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The function mlx4_QUERY_PORT_wrapper implements only the
QUERY_PORT "general" case (opcode modifier = 0).

Verify that the opcode modifier is zero, and also that the
input modifier contains only the port number in bits 0..7
(all other bits should be zero).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 13b2e4a..2e88a23 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -982,8 +982,13 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 	if (port < 0)
 		return -EINVAL;
 
-	vhcr->in_modifier = (vhcr->in_modifier & ~0xFF) |
-			    (port & 0xFF);
+	/* Protect against untrusted guests: enforce that this is the
+	 * QUERY_PORT general query.
+	 */
+	if (vhcr->op_modifier || vhcr->in_modifier & ~0xFF)
+		return -EINVAL;
+
+	vhcr->in_modifier = port;
 
 	err = mlx4_cmd_box(dev, 0, outbox->dma, vhcr->in_modifier, 0,
 			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B,
-- 
1.7.1
