From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 03/23 v3] mlx4_core: add WRITE_MTT support
Date: Thu, 04 Feb 2010 17:54:43 +0200
Message-ID: <4B6AEDC3.8070007@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:46839 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933079Ab0BDPyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:54:45 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used by vfs to modify mtts, since they cannot access in-memory mtts directly.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c  |   10 +++++-
 drivers/net/mlx4/mlx4.h |    5 +++
 drivers/net/mlx4/mr.c   |   67 ++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 74 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 6c3d25c..9e85330 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -36,8 +36,6 @@
 #include <linux/pci.h>
 #include <linux/errno.h>
 
-#include <linux/mlx4/cmd.h>
-
 #include <asm/io.h>
 
 #include "mlx4.h"
@@ -497,6 +495,14 @@ static struct mlx4_cmd_info {
 		.wrapper = NULL
 	},
 	{
+		.opcode = MLX4_CMD_WRITE_MTT,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.verify = NULL, /* need verifier */
+		.wrapper = mlx4_WRITE_MTT_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_SYNC_TPT,
 		.has_inbox = true,
 		.has_outbox = false,
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 92d0682..18ac62d 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -45,6 +45,7 @@
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/doorbell.h>
+#include <linux/mlx4/cmd.h>
 
 #define DRV_NAME	"mlx4_core"
 #define PFX		DRV_NAME ": "
@@ -419,6 +420,10 @@ void mlx4_cleanup_qp_table(struct mlx4_dev *dev);
 void mlx4_cleanup_srq_table(struct mlx4_dev *dev);
 void mlx4_cleanup_mcg_table(struct mlx4_dev *dev);
 
+int mlx4_WRITE_MTT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						 struct mlx4_cmd_mailbox *inbox,
+						 struct mlx4_cmd_mailbox *outbox);
+
 void mlx4_start_catas_poll(struct mlx4_dev *dev);
 void mlx4_stop_catas_poll(struct mlx4_dev *dev);
 void mlx4_catas_init(void);
diff --git a/drivers/net/mlx4/mr.c b/drivers/net/mlx4/mr.c
index ca7ab8e..9e4ab0f 100644
--- a/drivers/net/mlx4/mr.c
+++ b/drivers/net/mlx4/mr.c
@@ -262,6 +262,35 @@ static int mlx4_HW2SW_MPT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			    !mailbox, MLX4_CMD_HW2SW_MPT, MLX4_CMD_TIME_CLASS_B);
 }
 
+int mlx4_WRITE_MTT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						 struct mlx4_cmd_mailbox *inbox,
+						 struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_mtt mtt;
+	u64 *page_list = inbox->buf;
+	int i;
+
+	/* Call the SW implementation of write_mtt:
+	 * - Prepare a dummy mtt struct
+	 * - Translate inbox contents to simple addresses in host endianess */
+	mtt.first_seg = 0;
+	mtt.order = 0;
+	mtt.page_shift = 0;
+	for (i = 0; i < vhcr->in_modifier; ++i)
+		page_list[i + 2] = be64_to_cpu(page_list[i + 2]) & ~1ULL;
+	vhcr->errno = mlx4_write_mtt(dev, &mtt, be64_to_cpu(page_list[0]),
+						vhcr->in_modifier,
+						page_list + 2);
+	return 0;
+}
+
+static int mlx4_WRITE_MTT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
+			  int num_entries)
+{
+	return mlx4_cmd(dev, mailbox->dma, num_entries, 0, MLX4_CMD_WRITE_MTT,
+			MLX4_CMD_TIME_CLASS_A);
+}
+
 int mlx4_mr_alloc(struct mlx4_dev *dev, u32 pd, u64 iova, u64 size, u32 access,
 		  int npages, int page_shift, struct mlx4_mr *mr)
 {
@@ -413,24 +442,50 @@ static int mlx4_write_mtt_chunk(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 int mlx4_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		   int start_index, int npages, u64 *page_list)
 {
+	struct mlx4_cmd_mailbox *mailbox = NULL;
 	int chunk;
-	int err;
+	int err = 0;
+	__be64 *inbox = NULL;
+	int i;
 
 	if (mtt->order < 0)
 		return -EINVAL;
 
+	if (mlx4_is_slave(dev)) {
+		mailbox = mlx4_alloc_cmd_mailbox(dev);
+		if (IS_ERR(mailbox))
+			return PTR_ERR(mailbox);
+		inbox = mailbox->buf;
+	}
+
 	while (npages > 0) {
-		chunk = min_t(int, PAGE_SIZE / sizeof(u64), npages);
-		err = mlx4_write_mtt_chunk(dev, mtt, start_index, chunk, page_list);
+		if (mlx4_is_slave(dev)) {
+			int s = mtt->first_seg * dev->caps.mtts_per_seg + start_index;
+			chunk = min_t(int, MLX4_MAILBOX_SIZE / sizeof(u64) - dev->caps.mtts_per_seg, npages);
+			if (s / (PAGE_SIZE / sizeof (u64)) !=
+			    (s + chunk - 1) / (PAGE_SIZE / sizeof (u64)))
+				chunk = PAGE_SIZE / sizeof (u64) - (s % (PAGE_SIZE / sizeof (u64)));
+
+			inbox[0] = cpu_to_be64(mtt->first_seg * dev->caps.mtts_per_seg + start_index);
+			inbox[1] = 0;
+			for (i = 0; i < chunk; ++i)
+				inbox[i + 2] = cpu_to_be64(page_list[i] | MLX4_MTT_FLAG_PRESENT);
+			err = mlx4_WRITE_MTT(dev, mailbox, chunk);
+		} else {
+			chunk = min_t(int, PAGE_SIZE / sizeof(u64), npages);
+			err = mlx4_write_mtt_chunk(dev, mtt, start_index, chunk, page_list);
+		}
 		if (err)
-			return err;
+			goto out;
 
 		npages      -= chunk;
 		start_index += chunk;
 		page_list   += chunk;
 	}
-
-	return 0;
+out:
+	if (mlx4_is_slave(dev))
+		mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
 }
 EXPORT_SYMBOL_GPL(mlx4_write_mtt);
 
-- 
1.6.1.3


