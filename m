From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 04/10] net/mlx5: Added missing check of msg length in verifying its signature
Date: Thu, 18 Aug 2016 21:09:05 +0300
Message-ID: <1471543751-24164-5-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41788 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932389AbcHSBnO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:14 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

Set and verify signature calculates the signature for each of the
mailbox nodes, even for those that are unused (from cache). Added
a missing length check to set and verify only those which are used.

While here, also moved the setting of msg's nodes token to where we
already go over them. This saves a pass because checksum is disabled,
and the only useful thing remaining that set signature does is setting
the token.

Fixes: e126ba97dba9 ('mlx5: Add driver for Mellanox Connect-IB
adapters')
Signed-off-by: Paul Blakey <paulb@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 85 +++++++++++++++++----------
 1 file changed, 54 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index d6e2a1c..c2ec01a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -143,13 +143,14 @@ static struct mlx5_cmd_layout *get_inst(struct mlx5_cmd *cmd, int idx)
 	return cmd->cmd_buf + (idx << cmd->log_stride);
 }
 
-static u8 xor8_buf(void *buf, int len)
+static u8 xor8_buf(void *buf, size_t offset, int len)
 {
 	u8 *ptr = buf;
 	u8 sum = 0;
 	int i;
+	int end = len + offset;
 
-	for (i = 0; i < len; i++)
+	for (i = offset; i < end; i++)
 		sum ^= ptr[i];
 
 	return sum;
@@ -157,41 +158,49 @@ static u8 xor8_buf(void *buf, int len)
 
 static int verify_block_sig(struct mlx5_cmd_prot_block *block)
 {
-	if (xor8_buf(block->rsvd0, sizeof(*block) - sizeof(block->data) - 1) != 0xff)
+	size_t rsvd0_off = offsetof(struct mlx5_cmd_prot_block, rsvd0);
+	int xor_len = sizeof(*block) - sizeof(block->data) - 1;
+
+	if (xor8_buf(block, rsvd0_off, xor_len) != 0xff)
 		return -EINVAL;
 
-	if (xor8_buf(block, sizeof(*block)) != 0xff)
+	if (xor8_buf(block, 0, sizeof(*block)) != 0xff)
 		return -EINVAL;
 
 	return 0;
 }
 
-static void calc_block_sig(struct mlx5_cmd_prot_block *block, u8 token,
-			   int csum)
+static void calc_block_sig(struct mlx5_cmd_prot_block *block)
 {
-	block->token = token;
-	if (csum) {
-		block->ctrl_sig = ~xor8_buf(block->rsvd0, sizeof(*block) -
-					    sizeof(block->data) - 2);
-		block->sig = ~xor8_buf(block, sizeof(*block) - 1);
-	}
+	int ctrl_xor_len = sizeof(*block) - sizeof(block->data) - 2;
+	size_t rsvd0_off = offsetof(struct mlx5_cmd_prot_block, rsvd0);
+
+	block->ctrl_sig = ~xor8_buf(block, rsvd0_off, ctrl_xor_len);
+	block->sig = ~xor8_buf(block, 0, sizeof(*block) - 1);
 }
 
-static void calc_chain_sig(struct mlx5_cmd_msg *msg, u8 token, int csum)
+static void calc_chain_sig(struct mlx5_cmd_msg *msg)
 {
 	struct mlx5_cmd_mailbox *next = msg->next;
-
-	while (next) {
-		calc_block_sig(next->buf, token, csum);
+	int size = msg->len;
+	int blen = size - min_t(int, sizeof(msg->first.data), size);
+	int n = (blen + MLX5_CMD_DATA_BLOCK_SIZE - 1)
+		/ MLX5_CMD_DATA_BLOCK_SIZE;
+	int i = 0;
+
+	for (i = 0; i < n && next; i++)  {
+		calc_block_sig(next->buf);
 		next = next->next;
 	}
 }
 
 static void set_signature(struct mlx5_cmd_work_ent *ent, int csum)
 {
-	ent->lay->sig = ~xor8_buf(ent->lay, sizeof(*ent->lay));
-	calc_chain_sig(ent->in, ent->token, csum);
-	calc_chain_sig(ent->out, ent->token, csum);
+	ent->lay->sig = ~xor8_buf(ent->lay, 0,  sizeof(*ent->lay));
+	if (csum) {
+		calc_chain_sig(ent->in);
+		calc_chain_sig(ent->out);
+	}
 }
 
 static void poll_timeout(struct mlx5_cmd_work_ent *ent)
@@ -222,12 +231,17 @@ static int verify_signature(struct mlx5_cmd_work_ent *ent)
 	struct mlx5_cmd_mailbox *next = ent->out->next;
 	int err;
 	u8 sig;
+	int size = ent->out->len;
+	int blen = size - min_t(int, sizeof(ent->out->first.data), size);
+	int n = (blen + MLX5_CMD_DATA_BLOCK_SIZE - 1)
+		/ MLX5_CMD_DATA_BLOCK_SIZE;
+	int i = 0;
 
-	sig = xor8_buf(ent->lay, sizeof(*ent->lay));
+	sig = xor8_buf(ent->lay, 0, sizeof(*ent->lay));
 	if (sig != 0xff)
 		return -EINVAL;
 
-	while (next) {
+	for (i = 0; i < n && next; i++) {
 		err = verify_block_sig(next->buf);
 		if (err)
 			return err;
@@ -656,7 +670,6 @@ static void cmd_work_handler(struct work_struct *work)
 		spin_unlock_irqrestore(&cmd->alloc_lock, flags);
 	}
 
-	ent->token = alloc_token(cmd);
 	cmd->ent_arr[ent->idx] = ent;
 	lay = get_inst(cmd, ent->idx);
 	ent->lay = lay;
@@ -766,7 +779,8 @@ static u8 *get_status_ptr(struct mlx5_outbox_hdr *out)
 static int mlx5_cmd_invoke(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *in,
 			   struct mlx5_cmd_msg *out, void *uout, int uout_size,
 			   mlx5_cmd_cbk_t callback,
-			   void *context, int page_queue, u8 *status)
+			   void *context, int page_queue, u8 *status,
+			   u8 token)
 {
 	struct mlx5_cmd *cmd = &dev->cmd;
 	struct mlx5_cmd_work_ent *ent;
@@ -783,6 +797,8 @@ static int mlx5_cmd_invoke(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *in,
 	if (IS_ERR(ent))
 		return PTR_ERR(ent);
 
+	ent->token = token;
+
 	if (!callback)
 		init_completion(&ent->done);
 
@@ -854,7 +870,8 @@ static const struct file_operations fops = {
 	.write	= dbg_write,
 };
 
-static int mlx5_copy_to_msg(struct mlx5_cmd_msg *to, void *from, int size)
+static int mlx5_copy_to_msg(struct mlx5_cmd_msg *to, void *from, int size,
+			    u8 token)
 {
 	struct mlx5_cmd_prot_block *block;
 	struct mlx5_cmd_mailbox *next;
@@ -880,6 +897,7 @@ static int mlx5_copy_to_msg(struct mlx5_cmd_msg *to, void *from, int size)
 		memcpy(block->data, from, copy);
 		from += copy;
 		size -= copy;
+		block->token = token;
 		next = next->next;
 	}
 
@@ -949,7 +967,8 @@ static void free_cmd_box(struct mlx5_core_dev *dev,
 }
 
 static struct mlx5_cmd_msg *mlx5_alloc_cmd_msg(struct mlx5_core_dev *dev,
-					       gfp_t flags, int size)
+					       gfp_t flags, int size,
+					       u8 token)
 {
 	struct mlx5_cmd_mailbox *tmp, *head = NULL;
 	struct mlx5_cmd_prot_block *block;
@@ -978,6 +997,7 @@ static struct mlx5_cmd_msg *mlx5_alloc_cmd_msg(struct mlx5_core_dev *dev,
 		tmp->next = head;
 		block->next = cpu_to_be64(tmp->next ? tmp->next->dma : 0);
 		block->block_num = cpu_to_be32(n - i - 1);
+		block->token = token;
 		head = tmp;
 	}
 	msg->next = head;
@@ -1352,7 +1372,7 @@ static struct mlx5_cmd_msg *alloc_msg(struct mlx5_core_dev *dev, int in_size,
 	}
 
 	if (IS_ERR(msg))
-		msg = mlx5_alloc_cmd_msg(dev, gfp, in_size);
+		msg = mlx5_alloc_cmd_msg(dev, gfp, in_size, 0);
 
 	return msg;
 }
@@ -1377,6 +1397,7 @@ static int cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 	int err;
 	u8 status = 0;
 	u32 drv_synd;
+	u8 token;
 
 	if (pci_channel_offline(dev->pdev) ||
 	    dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
@@ -1395,20 +1416,22 @@ static int cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 		return err;
 	}
 
-	err = mlx5_copy_to_msg(inb, in, in_size);
+	token = alloc_token(&dev->cmd);
+
+	err = mlx5_copy_to_msg(inb, in, in_size, token);
 	if (err) {
 		mlx5_core_warn(dev, "err %d\n", err);
 		goto out_in;
 	}
 
-	outb = mlx5_alloc_cmd_msg(dev, gfp, out_size);
+	outb = mlx5_alloc_cmd_msg(dev, gfp, out_size, token);
 	if (IS_ERR(outb)) {
 		err = PTR_ERR(outb);
 		goto out_in;
 	}
 
 	err = mlx5_cmd_invoke(dev, inb, outb, out, out_size, callback, context,
-			      pages_queue, &status);
+			      pages_queue, &status, token);
 	if (err)
 		goto out_out;
 
@@ -1476,7 +1499,7 @@ static int create_msg_cache(struct mlx5_core_dev *dev)
 	INIT_LIST_HEAD(&cmd->cache.med.head);
 
 	for (i = 0; i < NUM_LONG_LISTS; i++) {
-		msg = mlx5_alloc_cmd_msg(dev, GFP_KERNEL, LONG_LIST_SIZE);
+		msg = mlx5_alloc_cmd_msg(dev, GFP_KERNEL, LONG_LIST_SIZE, 0);
 		if (IS_ERR(msg)) {
 			err = PTR_ERR(msg);
 			goto ex_err;
@@ -1486,7 +1509,7 @@ static int create_msg_cache(struct mlx5_core_dev *dev)
 	}
 
 	for (i = 0; i < NUM_MED_LISTS; i++) {
-		msg = mlx5_alloc_cmd_msg(dev, GFP_KERNEL, MED_LIST_SIZE);
+		msg = mlx5_alloc_cmd_msg(dev, GFP_KERNEL, MED_LIST_SIZE, 0);
 		if (IS_ERR(msg)) {
 			err = PTR_ERR(msg);
 			goto ex_err;
-- 
2.7.4
