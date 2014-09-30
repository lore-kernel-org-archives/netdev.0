From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx4_core: Deprecate error message at ConnectX-2 cards startup to debug
Date: Tue, 30 Sep 2014 12:03:50 +0300
Message-ID: <1412067830-30438-5-git-send-email-ogerlitz@mellanox.com>
References: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42473 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751963AbaI3JD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 05:03:59 -0400
In-Reply-To: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

ConnectX2 HCAs have max_mtu=4k and max_vl=8 vls. However, if you specify
a 4K mtu, the max_vl supported for 4K is 4 vls. The driver at startup
attempts to set a 4K mtu using the max_vl value obtained from QUERY_PORT.

Since the max_vl value is 8 vls (which is supported up to 2K mtu size),
the first attempt to set the mtl/vl port value will fail, generating
the following error message in the log:

  mlx4_core 0000:06:00.0: command 0xc failed: fw status = 0x40

The driver then tries again, using mtu=4k, vls=4, and this succeeds.

Since we do not want to have this error message always displayed at driver
start when there are ConnectX2 HCAs on the host, we deprecate the error
message for this specific command/input_modifier/opcode_modifier/fw-status
to be debug.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 02a2e90..436c82f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -580,8 +580,18 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 
 	err = context->result;
 	if (err) {
-		mlx4_err(dev, "command 0x%x failed: fw status = 0x%x\n",
-			 op, context->fw_status);
+		/* Since we do not want to have this error message always
+		 * displayed at driver start when there are ConnectX2 HCAs
+		 * on the host, we deprecate the error message for this
+		 * specific command/input_mod/opcode_mod/fw-status to be debug.
+		 */
+		if (op == MLX4_CMD_SET_PORT && in_modifier == 1 &&
+		    op_modifier == 0 && context->fw_status == CMD_STAT_BAD_SIZE)
+			mlx4_dbg(dev, "command 0x%x failed: fw status = 0x%x\n",
+				 op, context->fw_status);
+		else
+			mlx4_err(dev, "command 0x%x failed: fw status = 0x%x\n",
+				 op, context->fw_status);
 		goto out;
 	}
 
-- 
1.7.1
