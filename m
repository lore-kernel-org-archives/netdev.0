From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 21/23 v3] mlx4_core: Adding VEP number in resource allocation
Date: Thu, 04 Feb 2010 17:57:09 +0200
Message-ID: <4B6AEE55.8030606@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49908 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933240Ab0BDP5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:57:12 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each slave would have its relative range of resources.
Specifying the function number at resource allocation allows the firmware
to calculate the absolute resource number

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c |   58 ++++++++++++++++++++++++++++++++++-------------
 drivers/net/mlx4/fw.c  |    2 +-
 2 files changed, 43 insertions(+), 17 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 2605344..7eab34d 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -533,6 +533,32 @@ static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 	return 0;
 }
 
+static int mlx4_DMA_wrapper(struct mlx4_dev *dev, int slave,
+			    struct mlx4_vhcr *vhcr,
+			    struct mlx4_cmd_mailbox *inbox,
+			    struct mlx4_cmd_mailbox *outbox)
+{
+	u64 in_param = inbox ? inbox->dma : vhcr->in_param;
+
+	in_param |= (u64) slave;
+	return mlx4_cmd(dev, in_param, vhcr->in_modifier,
+			vhcr->op_modifier, vhcr->op, MLX4_CMD_TIME_CLASS_C);
+}
+
+static int mlx4_DMA_outbox_wrapper(struct mlx4_dev *dev, int slave,
+				   struct mlx4_vhcr *vhcr,
+				   struct mlx4_cmd_mailbox *inbox,
+				   struct mlx4_cmd_mailbox *outbox)
+{
+	u64 in_param = inbox ? inbox->dma : vhcr->in_param;
+	u64 out_param = outbox ? outbox->dma : vhcr->out_param;
+
+	in_param |= (u64) slave;
+	return mlx4_cmd_box(dev, in_param, out_param,
+			    vhcr->in_modifier, vhcr->op_modifier, vhcr->op,
+			    MLX4_CMD_TIME_CLASS_C);
+}
+
 static struct mlx4_cmd_info {
 	u16 opcode;
 	bool has_inbox;
@@ -615,7 +641,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /*need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_NOP,
@@ -664,7 +690,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL,
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_QUERY_MPT,
@@ -710,10 +736,10 @@ static struct mlx4_cmd_info {
 	{
 		.opcode = MLX4_CMD_HW2SW_EQ,
 		.has_inbox = false,
-		.has_outbox = false,
+		.has_outbox = true,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_outbox_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_QUERY_EQ,
@@ -729,7 +755,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_HW2SW_CQ,
@@ -737,7 +763,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_QUERY_CQ,
@@ -761,7 +787,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_HW2SW_SRQ,
@@ -793,7 +819,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_INIT2RTR_QP,
@@ -801,7 +827,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_RTR2RTS_QP,
@@ -809,7 +835,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_RTS2RTS_QP,
@@ -817,7 +843,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_SQERR2RTS_QP,
@@ -825,7 +851,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_2ERR_QP,
@@ -833,7 +859,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_RTS2SQD_QP,
@@ -841,7 +867,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_SQD2SQD_QP,
@@ -849,7 +875,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_SQD2RTS_QP,
@@ -857,7 +883,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL, /* need verifier */
-		.wrapper = NULL
+		.wrapper = mlx4_DMA_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_2RST_QP,
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 18294c3..18a35af 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -300,7 +300,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MPT_OFFSET);
 	dev_cap->max_mpts = 1 << (field & 0x3f);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_EQ_OFFSET);
-	dev_cap->reserved_eqs = field & 0xf;
+	dev_cap->reserved_eqs = field & 0xff;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_EQ_OFFSET);
 	dev_cap->max_eqs = 1 << (field & 0xf);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_MTT_OFFSET);
-- 
1.6.1.3


