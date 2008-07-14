From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH RFC 09/10] mlx4_en: Helper functions
Date: Mon, 14 Jul 2008 17:42:17 +0300
Message-ID: <487B65C9.8050504@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45169 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754572AbYGNOt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 10:49:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file includes some helper functions to assist in resources
allocation and bringing them to required state.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_resources.c |   99 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 99 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mlx4/en_resources.c

diff --git a/drivers/net/mlx4/en_resources.c b/drivers/net/mlx4/en_resources.c
new file mode 100644
index 0000000..4f2e96c
--- /dev/null
+++ b/drivers/net/mlx4/en_resources.c
@@ -0,0 +1,99 @@
+/*
+ * Copyright (c) 2007 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/mlx4/cq.h>
+#include <linux/mlx4/qp.h>
+#include <linux/mlx4/srq.h>
+
+#include "mlx4_en.h"
+
+void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
+			     int is_tx, int rss, int qpn, int cqn, int srqn,
+			     struct mlx4_qp_context *context)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+
+	memset(context, 0, sizeof *context);
+	context->flags = cpu_to_be32(7 << 16 | rss << 13);
+	context->pd = cpu_to_be32(mdev->priv_pdn);
+	context->mtu_msgmax = 0xff;
+	context->rq_size_stride = 0;
+	if (is_tx)
+		context->sq_size_stride = ilog2(size) << 3 | (ilog2(stride) - 4);
+	else
+		context->sq_size_stride = 1;
+	context->usr_page = cpu_to_be32(mdev->priv_uar.index);
+	context->local_qpn = cpu_to_be32(qpn);
+	context->pri_path.ackto = 1 & 0x07;
+	context->pri_path.sched_queue = 0x83 | (priv->port - 1) << 6;
+	context->pri_path.counter_index = 0xff;
+	context->cqn_send = cpu_to_be32(cqn);
+	context->cqn_recv = cpu_to_be32(cqn);
+	context->db_rec_addr = cpu_to_be64(priv->res.db.dma << 2);
+	if (!rss)
+		context->srqn = cpu_to_be32(MLX4_EN_USE_SRQ | srqn);
+
+	/* header separation */
+	if (!is_tx && !rss)
+		context->param3 = cpu_to_be32(priv->rx_buf << 23);
+}
+
+static u32 convert_access(int acc)
+{
+	return (acc & MLX4_EN_ACCESS_REMOTE_ATOMIC ? MLX4_PERM_ATOMIC       : 0) |
+	       (acc & MLX4_EN_ACCESS_REMOTE_WRITE  ? MLX4_PERM_REMOTE_WRITE : 0) |
+	       (acc & MLX4_EN_ACCESS_REMOTE_READ   ? MLX4_PERM_REMOTE_READ  : 0) |
+	       (acc & MLX4_EN_ACCESS_LOCAL_WRITE   ? MLX4_PERM_LOCAL_WRITE  : 0) |
+	       MLX4_PERM_LOCAL_READ;
+}
+
+int mlx4_en_get_dma_mr(struct mlx4_en_dev *mdev, int acc)
+{
+	int err;
+
+	err = mlx4_mr_alloc(mdev->dev, mdev->priv_pdn, 0, ~0ull,
+			    convert_access(acc), 0, 0, &mdev->mr);
+	if (err)
+		return err;
+
+	err = mlx4_mr_enable(mdev->dev, &mdev->mr);
+	if (err)
+		goto err_mr;
+
+	return 0;
+
+err_mr:
+	mlx4_mr_free(mdev->dev, &mdev->mr);
+	return err;
+}
+
-- 
1.5.3.7




