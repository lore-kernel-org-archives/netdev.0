From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V3 3/9] net/mlx5: Mellanox Connect-IB, core driver part 3/3
Date: Sun,  7 Jul 2013 17:25:51 +0300
Message-ID: <1373207157-13914-4-git-send-email-ogerlitz@mellanox.com>
References: <1373207157-13914-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jackm@dev.mellanox.co.il,
	eli@dev.mellanox.co.il, moshel@mellanox.com,
	Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40478 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752480Ab3GGO0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jul 2013 10:26:18 -0400
In-Reply-To: <1373207157-13914-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 MAINTAINERS                                      |   12 +
 drivers/net/ethernet/mellanox/Kconfig            |    1 +
 drivers/net/ethernet/mellanox/Makefile           |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig  |   18 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile |    5 +
 drivers/net/ethernet/mellanox/mlx5/core/srq.c    |  223 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/uar.c    |  223 ++++++
 include/linux/mlx5/cmd.h                         |   51 ++
 include/linux/mlx5/cq.h                          |  165 ++++
 include/linux/mlx5/device.h                      |  893 ++++++++++++++++++++++
 include/linux/mlx5/doorbell.h                    |   79 ++
 include/linux/mlx5/driver.h                      |  769 +++++++++++++++++++
 include/linux/mlx5/qp.h                          |  467 +++++++++++
 include/linux/mlx5/srq.h                         |   41 +
 14 files changed, 2948 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/srq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/uar.c
 create mode 100644 include/linux/mlx5/cmd.h
 create mode 100644 include/linux/mlx5/cq.h
 create mode 100644 include/linux/mlx5/device.h
 create mode 100644 include/linux/mlx5/doorbell.h
 create mode 100644 include/linux/mlx5/driver.h
 create mode 100644 include/linux/mlx5/qp.h
 create mode 100644 include/linux/mlx5/srq.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 60d6a33..6e82fb5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5365,6 +5365,18 @@ W:	http://linuxtv.org
 S:	Odd Fixes
 F:	drivers/media/radio/radio-miropcm20*
 
+Mellanox MLX5 core VPI driver
+M:	Eli Cohen <eli@mellanox.com>
+L:	netdev@vger.kernel.org
+L:	linux-rdma@vger.kernel.org
+W:	http://www.mellanox.com
+Q:	http://patchwork.ozlabs.org/project/netdev/list/
+Q:	http://patchwork.kernel.org/project/linux-rdma/list/
+T:	git://openfabrics.org/~eli/connect-ib.git
+S:	Supported
+F:	drivers/net/ethernet/mellanox/mlx5/core/
+F:	include/linux/mlx5/
+
 MODULE SUPPORT
 M:	Rusty Russell <rusty@rustcorp.com.au>
 S:	Maintained
diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index bcdbc14..8cf7563 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -19,5 +19,6 @@ config NET_VENDOR_MELLANOX
 if NET_VENDOR_MELLANOX
 
 source "drivers/net/ethernet/mellanox/mlx4/Kconfig"
+source "drivers/net/ethernet/mellanox/mlx5/core/Kconfig"
 
 endif # NET_VENDOR_MELLANOX
diff --git a/drivers/net/ethernet/mellanox/Makefile b/drivers/net/ethernet/mellanox/Makefile
index 37afb96..38fe32e 100644
--- a/drivers/net/ethernet/mellanox/Makefile
+++ b/drivers/net/ethernet/mellanox/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_MLX4_CORE) += mlx4/
+obj-$(CONFIG_MLX5_CORE) += mlx5/core/
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
new file mode 100644
index 0000000..2196282
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -0,0 +1,18 @@
+#
+# Mellanox driver configuration
+#
+
+config MLX5_CORE
+	tristate
+	depends on PCI && X86
+	default n
+
+config MLX5_DEBUG
+	bool "Verbose debugging output" if (MLX5_CORE && EXPERT)
+	depends on MLX5_CORE
+	default y
+	---help---
+	  This option causes debugging code to be compiled into the
+	  mlx5_core driver.  The output can be turned on via the
+	  debug_mask module parameter (which can also be set after
+	  the driver is loaded through sysfs).
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
new file mode 100644
index 0000000..105780b
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_MLX5_CORE)		+= mlx5_core.o
+
+mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
+		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o   \
+		mad.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/srq.c b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
new file mode 100644
index 0000000..38bce93
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
@@ -0,0 +1,223 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cmd.h>
+#include <linux/mlx5/srq.h>
+#include <rdma/ib_verbs.h>
+#include "mlx5_core.h"
+
+void mlx5_srq_event(struct mlx5_core_dev *dev, u32 srqn, int event_type)
+{
+	struct mlx5_srq_table *table = &dev->priv.srq_table;
+	struct mlx5_core_srq *srq;
+
+	spin_lock(&table->lock);
+
+	srq = radix_tree_lookup(&table->tree, srqn);
+	if (srq)
+		atomic_inc(&srq->refcount);
+
+	spin_unlock(&table->lock);
+
+	if (!srq) {
+		mlx5_core_warn(dev, "Async event for bogus SRQ 0x%08x\n", srqn);
+		return;
+	}
+
+	srq->event(srq, event_type);
+
+	if (atomic_dec_and_test(&srq->refcount))
+		complete(&srq->free);
+}
+
+struct mlx5_core_srq *mlx5_core_get_srq(struct mlx5_core_dev *dev, u32 srqn)
+{
+	struct mlx5_srq_table *table = &dev->priv.srq_table;
+	struct mlx5_core_srq *srq;
+
+	spin_lock(&table->lock);
+
+	srq = radix_tree_lookup(&table->tree, srqn);
+	if (srq)
+		atomic_inc(&srq->refcount);
+
+	spin_unlock(&table->lock);
+
+	return srq;
+}
+EXPORT_SYMBOL(mlx5_core_get_srq);
+
+int mlx5_core_create_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
+			 struct mlx5_create_srq_mbox_in *in, int inlen)
+{
+	struct mlx5_create_srq_mbox_out out;
+	struct mlx5_srq_table *table = &dev->priv.srq_table;
+	struct mlx5_destroy_srq_mbox_in din;
+	struct mlx5_destroy_srq_mbox_out dout;
+	int err;
+
+	memset(&out, 0, sizeof(out));
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_CREATE_SRQ);
+	err = mlx5_cmd_exec(dev, in, inlen, &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	srq->srqn = be32_to_cpu(out.srqn) & 0xffffff;
+
+	atomic_set(&srq->refcount, 1);
+	init_completion(&srq->free);
+
+	spin_lock_irq(&table->lock);
+	err = radix_tree_insert(&table->tree, srq->srqn, srq);
+	spin_unlock_irq(&table->lock);
+	if (err) {
+		mlx5_core_warn(dev, "err %d, srqn 0x%x\n", err, srq->srqn);
+		goto err_cmd;
+	}
+
+	return 0;
+
+err_cmd:
+	memset(&din, 0, sizeof(din));
+	memset(&dout, 0, sizeof(dout));
+	din.srqn = cpu_to_be32(srq->srqn);
+	din.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_SRQ);
+	mlx5_cmd_exec(dev, &din, sizeof(din), &dout, sizeof(dout));
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_create_srq);
+
+int mlx5_core_destroy_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq)
+{
+	struct mlx5_destroy_srq_mbox_in in;
+	struct mlx5_destroy_srq_mbox_out out;
+	struct mlx5_srq_table *table = &dev->priv.srq_table;
+	struct mlx5_core_srq *tmp;
+	int err;
+
+	spin_lock_irq(&table->lock);
+	tmp = radix_tree_delete(&table->tree, srq->srqn);
+	spin_unlock_irq(&table->lock);
+	if (!tmp) {
+		mlx5_core_warn(dev, "srq 0x%x not found in tree\n", srq->srqn);
+		return -EINVAL;
+	}
+	if (tmp != srq) {
+		mlx5_core_warn(dev, "corruption on srqn 0x%x\n", srq->srqn);
+		return -EINVAL;
+	}
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_SRQ);
+	in.srqn = cpu_to_be32(srq->srqn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	if (atomic_dec_and_test(&srq->refcount))
+		complete(&srq->free);
+	wait_for_completion(&srq->free);
+
+	return 0;
+}
+EXPORT_SYMBOL(mlx5_core_destroy_srq);
+
+int mlx5_core_query_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
+			struct mlx5_query_srq_mbox_out *out)
+{
+	struct mlx5_query_srq_mbox_in in;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(out, 0, sizeof(*out));
+
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_SRQ);
+	in.srqn = cpu_to_be32(srq->srqn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, sizeof(*out));
+	if (err)
+		return err;
+
+	if (out->hdr.status)
+		return mlx5_cmd_status_to_err(&out->hdr);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_query_srq);
+
+int mlx5_core_arm_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
+		      u16 lwm, int is_srq)
+{
+	struct mlx5_arm_srq_mbox_in	in;
+	struct mlx5_arm_srq_mbox_out	out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ARM_RQ);
+	in.hdr.opmod = cpu_to_be16(!!is_srq);
+	in.srqn = cpu_to_be32(srq->srqn);
+	in.lwm = cpu_to_be16(lwm);
+
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_arm_srq);
+
+void mlx5_init_srq_table(struct mlx5_core_dev *dev)
+{
+	struct mlx5_srq_table *table = &dev->priv.srq_table;
+
+	spin_lock_init(&table->lock);
+	INIT_RADIX_TREE(&table->tree, GFP_ATOMIC);
+}
+
+void mlx5_cleanup_srq_table(struct mlx5_core_dev *dev)
+{
+	/* nothing */
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
new file mode 100644
index 0000000..71d4a39
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -0,0 +1,223 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cmd.h>
+#include "mlx5_core.h"
+
+enum {
+	NUM_DRIVER_UARS		= 4,
+	NUM_LOW_LAT_UUARS	= 4,
+};
+
+
+struct mlx5_alloc_uar_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_alloc_uar_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			uarn;
+	u8			rsvd[4];
+};
+
+struct mlx5_free_uar_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			uarn;
+	u8			rsvd[4];
+};
+
+struct mlx5_free_uar_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn)
+{
+	struct mlx5_alloc_uar_mbox_in	in;
+	struct mlx5_alloc_uar_mbox_out	out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ALLOC_UAR);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		goto ex;
+
+	if (out.hdr.status) {
+		err = mlx5_cmd_status_to_err(&out.hdr);
+		goto ex;
+	}
+
+	*uarn = be32_to_cpu(out.uarn) & 0xffffff;
+
+ex:
+	return err;
+}
+EXPORT_SYMBOL(mlx5_cmd_alloc_uar);
+
+int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn)
+{
+	struct mlx5_free_uar_mbox_in	in;
+	struct mlx5_free_uar_mbox_out	out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DEALLOC_UAR);
+	in.uarn = cpu_to_be32(uarn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		goto ex;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+ex:
+	return err;
+}
+EXPORT_SYMBOL(mlx5_cmd_free_uar);
+
+static int need_uuar_lock(int uuarn)
+{
+	int tot_uuars = NUM_DRIVER_UARS * MLX5_BF_REGS_PER_PAGE;
+
+	if (uuarn == 0 || tot_uuars - NUM_LOW_LAT_UUARS)
+		return 0;
+
+	return 1;
+}
+
+int mlx5_alloc_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari)
+{
+	int tot_uuars = NUM_DRIVER_UARS * MLX5_BF_REGS_PER_PAGE;
+	struct mlx5_bf *bf;
+	phys_addr_t addr;
+	int err;
+	int i;
+
+	uuari->num_uars = NUM_DRIVER_UARS;
+	uuari->num_low_latency_uuars = NUM_LOW_LAT_UUARS;
+
+	mutex_init(&uuari->lock);
+	uuari->uars = kcalloc(uuari->num_uars, sizeof(*uuari->uars), GFP_KERNEL);
+	if (!uuari->uars)
+		return -ENOMEM;
+
+	uuari->bfs = kcalloc(tot_uuars, sizeof(*uuari->bfs), GFP_KERNEL);
+	if (!uuari->bfs) {
+		err = -ENOMEM;
+		goto out_uars;
+	}
+
+	uuari->bitmap = kcalloc(BITS_TO_LONGS(tot_uuars), sizeof(*uuari->bitmap),
+				GFP_KERNEL);
+	if (!uuari->bitmap) {
+		err = -ENOMEM;
+		goto out_bfs;
+	}
+
+	uuari->count = kcalloc(tot_uuars, sizeof(*uuari->count), GFP_KERNEL);
+	if (!uuari->count) {
+		err = -ENOMEM;
+		goto out_bitmap;
+	}
+
+	for (i = 0; i < uuari->num_uars; i++) {
+		err = mlx5_cmd_alloc_uar(dev, &uuari->uars[i].index);
+		if (err)
+			goto out_count;
+
+		addr = dev->iseg_base + ((phys_addr_t)(uuari->uars[i].index) << PAGE_SHIFT);
+		uuari->uars[i].map = ioremap(addr, PAGE_SIZE);
+		if (!uuari->uars[i].map) {
+			mlx5_cmd_free_uar(dev, uuari->uars[i].index);
+			goto out_count;
+		}
+		mlx5_core_dbg(dev, "allocated uar index 0x%x, mmaped at %p\n",
+			      uuari->uars[i].index, uuari->uars[i].map);
+	}
+
+	for (i = 0; i < tot_uuars; i++) {
+		bf = &uuari->bfs[i];
+
+		bf->buf_size = dev->caps.bf_reg_size / 2;
+		bf->uar = &uuari->uars[i / MLX5_BF_REGS_PER_PAGE];
+		bf->regreg = uuari->uars[i / MLX5_BF_REGS_PER_PAGE].map;
+		bf->reg = NULL; /* Add WC support */
+		bf->offset = (i % MLX5_BF_REGS_PER_PAGE) * dev->caps.bf_reg_size +
+			MLX5_BF_OFFSET;
+		bf->need_lock = need_uuar_lock(i);
+		spin_lock_init(&bf->lock);
+		spin_lock_init(&bf->lock32);
+		bf->uuarn = i;
+	}
+
+	return 0;
+
+out_count:
+	for (i--; i >= 0; i--) {
+		iounmap(uuari->uars[i].map);
+		mlx5_cmd_free_uar(dev, uuari->uars[i].index);
+	}
+	kfree(uuari->count);
+
+out_bitmap:
+	kfree(uuari->bitmap);
+
+out_bfs:
+	kfree(uuari->bfs);
+
+out_uars:
+	kfree(uuari->uars);
+	return err;
+}
+
+int mlx5_free_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari)
+{
+	int i = uuari->num_uars;
+
+	for (i--; i >= 0; i--) {
+		iounmap(uuari->uars[i].map);
+		mlx5_cmd_free_uar(dev, uuari->uars[i].index);
+	}
+
+	kfree(uuari->count);
+	kfree(uuari->bitmap);
+	kfree(uuari->bfs);
+	kfree(uuari->uars);
+
+	return 0;
+}
diff --git a/include/linux/mlx5/cmd.h b/include/linux/mlx5/cmd.h
new file mode 100644
index 0000000..2826a4b
--- /dev/null
+++ b/include/linux/mlx5/cmd.h
@@ -0,0 +1,51 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#ifndef MLX5_CMD_H
+#define MLX5_CMD_H
+
+#include <linux/types.h>
+
+struct manage_pages_layout {
+	u64	ptr;
+	u32	reserved;
+	u16	num_entries;
+	u16	func_id;
+};
+
+
+struct mlx5_cmd_alloc_uar_imm_out {
+	u32	rsvd[3];
+	u32	uarn;
+};
+
+#endif /* MLX5_CMD_H */
diff --git a/include/linux/mlx5/cq.h b/include/linux/mlx5/cq.h
new file mode 100644
index 0000000..3db67f7
--- /dev/null
+++ b/include/linux/mlx5/cq.h
@@ -0,0 +1,165 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#ifndef MLX5_CORE_CQ_H
+#define MLX5_CORE_CQ_H
+
+#include <rdma/ib_verbs.h>
+#include <linux/mlx5/driver.h>
+
+
+struct mlx5_core_cq {
+	u32			cqn;
+	int			cqe_sz;
+	__be32		       *set_ci_db;
+	__be32		       *arm_db;
+	atomic_t		refcount;
+	struct completion	free;
+	unsigned		vector;
+	int			irqn;
+	void (*comp)		(struct mlx5_core_cq *);
+	void (*event)		(struct mlx5_core_cq *, enum mlx5_event);
+	struct mlx5_uar	       *uar;
+	u32			cons_index;
+	unsigned		arm_sn;
+	struct mlx5_rsc_debug	*dbg;
+	int			pid;
+};
+
+
+enum {
+	MLX5_CQE_SYNDROME_LOCAL_LENGTH_ERR		= 0x01,
+	MLX5_CQE_SYNDROME_LOCAL_QP_OP_ERR		= 0x02,
+	MLX5_CQE_SYNDROME_LOCAL_PROT_ERR		= 0x04,
+	MLX5_CQE_SYNDROME_WR_FLUSH_ERR			= 0x05,
+	MLX5_CQE_SYNDROME_MW_BIND_ERR			= 0x06,
+	MLX5_CQE_SYNDROME_BAD_RESP_ERR			= 0x10,
+	MLX5_CQE_SYNDROME_LOCAL_ACCESS_ERR		= 0x11,
+	MLX5_CQE_SYNDROME_REMOTE_INVAL_REQ_ERR		= 0x12,
+	MLX5_CQE_SYNDROME_REMOTE_ACCESS_ERR		= 0x13,
+	MLX5_CQE_SYNDROME_REMOTE_OP_ERR			= 0x14,
+	MLX5_CQE_SYNDROME_TRANSPORT_RETRY_EXC_ERR	= 0x15,
+	MLX5_CQE_SYNDROME_RNR_RETRY_EXC_ERR		= 0x16,
+	MLX5_CQE_SYNDROME_REMOTE_ABORTED_ERR		= 0x22,
+};
+
+enum {
+	MLX5_CQE_OWNER_MASK	= 1,
+	MLX5_CQE_REQ		= 0,
+	MLX5_CQE_RESP_WR_IMM	= 1,
+	MLX5_CQE_RESP_SEND	= 2,
+	MLX5_CQE_RESP_SEND_IMM	= 3,
+	MLX5_CQE_RESP_SEND_INV	= 4,
+	MLX5_CQE_RESIZE_CQ	= 0xff, /* TBD */
+	MLX5_CQE_REQ_ERR	= 13,
+	MLX5_CQE_RESP_ERR	= 14,
+};
+
+enum {
+	MLX5_CQ_MODIFY_RESEIZE = 0,
+	MLX5_CQ_MODIFY_MODER = 1,
+	MLX5_CQ_MODIFY_MAPPING = 2,
+};
+
+struct mlx5_cq_modify_params {
+	int	type;
+	union {
+		struct {
+			u32	page_offset;
+			u8	log_cq_size;
+		} resize;
+
+		struct {
+		} moder;
+
+		struct {
+		} mapping;
+	} params;
+};
+
+enum {
+	CQE_SIZE_64 = 0,
+	CQE_SIZE_128 = 1,
+};
+
+static inline int cqe_sz_to_mlx_sz(u8 size)
+{
+	return size == 64 ? CQE_SIZE_64 : CQE_SIZE_128;
+}
+
+static inline void mlx5_cq_set_ci(struct mlx5_core_cq *cq)
+{
+	*cq->set_ci_db = cpu_to_be32(cq->cons_index & 0xffffff);
+}
+
+enum {
+	MLX5_CQ_DB_REQ_NOT_SOL		= 1 << 24,
+	MLX5_CQ_DB_REQ_NOT		= 0 << 24
+};
+
+static inline void mlx5_cq_arm(struct mlx5_core_cq *cq, u32 cmd,
+			       void __iomem *uar_page,
+			       spinlock_t *doorbell_lock)
+{
+	__be32 doorbell[2];
+	u32 sn;
+	u32 ci;
+
+	sn = cq->arm_sn & 3;
+	ci = cq->cons_index & 0xffffff;
+
+	*cq->arm_db = cpu_to_be32(sn << 28 | cmd | ci);
+
+	/* Make sure that the doorbell record in host memory is
+	 * written before ringing the doorbell via PCI MMIO.
+	 */
+	wmb();
+
+	doorbell[0] = cpu_to_be32(sn << 28 | cmd | ci);
+	doorbell[1] = cpu_to_be32(cq->cqn);
+
+	mlx5_write64(doorbell, uar_page + MLX5_CQ_DOORBELL, doorbell_lock);
+}
+
+int mlx5_init_cq_table(struct mlx5_core_dev *dev);
+void mlx5_cleanup_cq_table(struct mlx5_core_dev *dev);
+int mlx5_core_create_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
+			struct mlx5_create_cq_mbox_in *in, int inlen);
+int mlx5_core_destroy_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
+int mlx5_core_query_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
+		       struct mlx5_query_cq_mbox_out *out);
+int mlx5_core_modify_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
+			int type, struct mlx5_cq_modify_params *params);
+int mlx5_debug_cq_add(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
+void mlx5_debug_cq_remove(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
+
+#endif /* MLX5_CORE_CQ_H */
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
new file mode 100644
index 0000000..5139091
--- /dev/null
+++ b/include/linux/mlx5/device.h
@@ -0,0 +1,893 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#ifndef MLX5_DEVICE_H
+#define MLX5_DEVICE_H
+
+#include <linux/types.h>
+#include <rdma/ib_verbs.h>
+
+#if defined(__LITTLE_ENDIAN)
+#define MLX5_SET_HOST_ENDIANNESS	0
+#elif defined(__BIG_ENDIAN)
+#define MLX5_SET_HOST_ENDIANNESS	0x80
+#else
+#error Host endianness not defined
+#endif
+
+enum {
+	MLX5_MAX_COMMANDS		= 32,
+	MLX5_CMD_DATA_BLOCK_SIZE	= 512,
+	MLX5_PCI_CMD_XPORT		= 7,
+};
+
+enum {
+	MLX5_EXTENDED_UD_AV		= 0x80000000,
+};
+
+enum {
+	MLX5_CQ_STATE_ARMED		= 9,
+	MLX5_CQ_STATE_ALWAYS_ARMED	= 0xb,
+	MLX5_CQ_STATE_FIRED		= 0xa,
+};
+
+enum {
+	MLX5_STAT_RATE_OFFSET	= 5,
+};
+
+enum {
+	MLX5_INLINE_SEG = 0x80000000,
+};
+
+enum {
+	MLX5_PERM_LOCAL_READ	= 1 << 2,
+	MLX5_PERM_LOCAL_WRITE	= 1 << 3,
+	MLX5_PERM_REMOTE_READ	= 1 << 4,
+	MLX5_PERM_REMOTE_WRITE	= 1 << 5,
+	MLX5_PERM_ATOMIC	= 1 << 6,
+	MLX5_PERM_UMR_EN	= 1 << 7,
+};
+
+enum {
+	MLX5_PCIE_CTRL_SMALL_FENCE	= 1 << 0,
+	MLX5_PCIE_CTRL_RELAXED_ORDERING	= 1 << 2,
+	MLX5_PCIE_CTRL_NO_SNOOP		= 1 << 3,
+	MLX5_PCIE_CTRL_TLP_PROCE_EN	= 1 << 6,
+	MLX5_PCIE_CTRL_TPH_MASK		= 3 << 4,
+};
+
+enum {
+	MLX5_ACCESS_MODE_PA	= 0,
+	MLX5_ACCESS_MODE_MTT	= 1,
+	MLX5_ACCESS_MODE_KLM	= 2
+};
+
+enum {
+	MLX5_MKEY_REMOTE_INVAL	= 1 << 24,
+	MLX5_MKEY_FLAG_SYNC_UMR = 1 << 29,
+	MLX5_MKEY_BSF_EN	= 1 << 30,
+	MLX5_MKEY_LEN64		= 1 << 31,
+};
+
+enum {
+	MLX5_EN_RD	= (u64)1,
+	MLX5_EN_WR	= (u64)2
+};
+
+enum {
+	MLX5_BF_REGS_PER_PAGE	= 4,
+	MLX5_MAX_UAR_PAGES	= 1 << 8,
+	MLX5_MAX_UUARS		= MLX5_MAX_UAR_PAGES * MLX5_BF_REGS_PER_PAGE,
+};
+
+enum {
+	MLX5_MKEY_MASK_LEN		= 1ull << 0,
+	MLX5_MKEY_MASK_PAGE_SIZE	= 1ull << 1,
+	MLX5_MKEY_MASK_START_ADDR	= 1ull << 6,
+	MLX5_MKEY_MASK_PD		= 1ull << 7,
+	MLX5_MKEY_MASK_EN_RINVAL	= 1ull << 8,
+	MLX5_MKEY_MASK_BSF_EN		= 1ull << 12,
+	MLX5_MKEY_MASK_KEY		= 1ull << 13,
+	MLX5_MKEY_MASK_QPN		= 1ull << 14,
+	MLX5_MKEY_MASK_LR		= 1ull << 17,
+	MLX5_MKEY_MASK_LW		= 1ull << 18,
+	MLX5_MKEY_MASK_RR		= 1ull << 19,
+	MLX5_MKEY_MASK_RW		= 1ull << 20,
+	MLX5_MKEY_MASK_A		= 1ull << 21,
+	MLX5_MKEY_MASK_SMALL_FENCE	= 1ull << 23,
+	MLX5_MKEY_MASK_FREE		= 1ull << 29,
+};
+
+enum mlx5_event {
+	MLX5_EVENT_TYPE_COMP		   = 0x0,
+
+	MLX5_EVENT_TYPE_PATH_MIG	   = 0x01,
+	MLX5_EVENT_TYPE_COMM_EST	   = 0x02,
+	MLX5_EVENT_TYPE_SQ_DRAINED	   = 0x03,
+	MLX5_EVENT_TYPE_SRQ_LAST_WQE	   = 0x13,
+	MLX5_EVENT_TYPE_SRQ_RQ_LIMIT	   = 0x14,
+
+	MLX5_EVENT_TYPE_CQ_ERROR	   = 0x04,
+	MLX5_EVENT_TYPE_WQ_CATAS_ERROR	   = 0x05,
+	MLX5_EVENT_TYPE_PATH_MIG_FAILED	   = 0x07,
+	MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR = 0x10,
+	MLX5_EVENT_TYPE_WQ_ACCESS_ERROR	   = 0x11,
+	MLX5_EVENT_TYPE_SRQ_CATAS_ERROR	   = 0x12,
+
+	MLX5_EVENT_TYPE_INTERNAL_ERROR	   = 0x08,
+	MLX5_EVENT_TYPE_PORT_CHANGE	   = 0x09,
+	MLX5_EVENT_TYPE_GPIO_EVENT	   = 0x15,
+	MLX5_EVENT_TYPE_REMOTE_CONFIG	   = 0x19,
+
+	MLX5_EVENT_TYPE_DB_BF_CONGESTION   = 0x1a,
+	MLX5_EVENT_TYPE_STALL_EVENT	   = 0x1b,
+
+	MLX5_EVENT_TYPE_CMD		   = 0x0a,
+	MLX5_EVENT_TYPE_PAGE_REQUEST	   = 0xb,
+};
+
+enum {
+	MLX5_PORT_CHANGE_SUBTYPE_DOWN		= 1,
+	MLX5_PORT_CHANGE_SUBTYPE_ACTIVE		= 4,
+	MLX5_PORT_CHANGE_SUBTYPE_INITIALIZED	= 5,
+	MLX5_PORT_CHANGE_SUBTYPE_LID		= 6,
+	MLX5_PORT_CHANGE_SUBTYPE_PKEY		= 7,
+	MLX5_PORT_CHANGE_SUBTYPE_GUID		= 8,
+	MLX5_PORT_CHANGE_SUBTYPE_CLIENT_REREG	= 9,
+};
+
+enum {
+	MLX5_DEV_CAP_FLAG_RC		= 1LL <<  0,
+	MLX5_DEV_CAP_FLAG_UC		= 1LL <<  1,
+	MLX5_DEV_CAP_FLAG_UD		= 1LL <<  2,
+	MLX5_DEV_CAP_FLAG_XRC		= 1LL <<  3,
+	MLX5_DEV_CAP_FLAG_SRQ		= 1LL <<  6,
+	MLX5_DEV_CAP_FLAG_BAD_PKEY_CNTR	= 1LL <<  8,
+	MLX5_DEV_CAP_FLAG_BAD_QKEY_CNTR	= 1LL <<  9,
+	MLX5_DEV_CAP_FLAG_APM		= 1LL << 17,
+	MLX5_DEV_CAP_FLAG_ATOMIC	= 1LL << 18,
+	MLX5_DEV_CAP_FLAG_ON_DMND_PG	= 1LL << 24,
+	MLX5_DEV_CAP_FLAG_RESIZE_SRQ	= 1LL << 32,
+	MLX5_DEV_CAP_FLAG_REMOTE_FENCE	= 1LL << 38,
+	MLX5_DEV_CAP_FLAG_TLP_HINTS	= 1LL << 39,
+	MLX5_DEV_CAP_FLAG_SIG_HAND_OVER	= 1LL << 40,
+	MLX5_DEV_CAP_FLAG_DCT		= 1LL << 41,
+	MLX5_DEV_CAP_FLAG_CMDIF_CSUM	= 1LL << 46,
+};
+
+enum {
+	MLX5_OPCODE_NOP			= 0x00,
+	MLX5_OPCODE_SEND_INVAL		= 0x01,
+	MLX5_OPCODE_RDMA_WRITE		= 0x08,
+	MLX5_OPCODE_RDMA_WRITE_IMM	= 0x09,
+	MLX5_OPCODE_SEND		= 0x0a,
+	MLX5_OPCODE_SEND_IMM		= 0x0b,
+	MLX5_OPCODE_RDMA_READ		= 0x10,
+	MLX5_OPCODE_ATOMIC_CS		= 0x11,
+	MLX5_OPCODE_ATOMIC_FA		= 0x12,
+	MLX5_OPCODE_ATOMIC_MASKED_CS	= 0x14,
+	MLX5_OPCODE_ATOMIC_MASKED_FA	= 0x15,
+	MLX5_OPCODE_BIND_MW		= 0x18,
+	MLX5_OPCODE_CONFIG_CMD		= 0x1f,
+
+	MLX5_RECV_OPCODE_RDMA_WRITE_IMM	= 0x00,
+	MLX5_RECV_OPCODE_SEND		= 0x01,
+	MLX5_RECV_OPCODE_SEND_IMM	= 0x02,
+	MLX5_RECV_OPCODE_SEND_INVAL	= 0x03,
+
+	MLX5_CQE_OPCODE_ERROR		= 0x1e,
+	MLX5_CQE_OPCODE_RESIZE		= 0x16,
+
+	MLX5_OPCODE_SET_PSV		= 0x20,
+	MLX5_OPCODE_GET_PSV		= 0x21,
+	MLX5_OPCODE_CHECK_PSV		= 0x22,
+	MLX5_OPCODE_RGET_PSV		= 0x26,
+	MLX5_OPCODE_RCHECK_PSV		= 0x27,
+
+	MLX5_OPCODE_UMR			= 0x25,
+
+};
+
+enum {
+	MLX5_SET_PORT_RESET_QKEY	= 0,
+	MLX5_SET_PORT_GUID0		= 16,
+	MLX5_SET_PORT_NODE_GUID		= 17,
+	MLX5_SET_PORT_SYS_GUID		= 18,
+	MLX5_SET_PORT_GID_TABLE		= 19,
+	MLX5_SET_PORT_PKEY_TABLE	= 20,
+};
+
+enum {
+	MLX5_MAX_PAGE_SHIFT		= 31
+};
+
+struct mlx5_inbox_hdr {
+	__be16		opcode;
+	u8		rsvd[4];
+	__be16		opmod;
+};
+
+struct mlx5_outbox_hdr {
+	u8		status;
+	u8		rsvd[3];
+	__be32		syndrome;
+};
+
+struct mlx5_cmd_query_adapter_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_cmd_query_adapter_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[24];
+	u8			intapin;
+	u8			rsvd1[13];
+	__be16			vsd_vendor_id;
+	u8			vsd[208];
+	u8			vsd_psid[16];
+};
+
+struct mlx5_hca_cap {
+	u8	rsvd1[16];
+	u8	log_max_srq_sz;
+	u8	log_max_qp_sz;
+	u8	rsvd2;
+	u8	log_max_qp;
+	u8	log_max_strq_sz;
+	u8	log_max_srqs;
+	u8	rsvd4[2];
+	u8	rsvd5;
+	u8	log_max_cq_sz;
+	u8	rsvd6;
+	u8	log_max_cq;
+	u8	log_max_eq_sz;
+	u8	log_max_mkey;
+	u8	rsvd7;
+	u8	log_max_eq;
+	u8	max_indirection;
+	u8	log_max_mrw_sz;
+	u8	log_max_bsf_list_sz;
+	u8	log_max_klm_list_sz;
+	u8	rsvd_8_0;
+	u8	log_max_ra_req_dc;
+	u8	rsvd_8_1;
+	u8	log_max_ra_res_dc;
+	u8	rsvd9;
+	u8	log_max_ra_req_qp;
+	u8	rsvd10;
+	u8	log_max_ra_res_qp;
+	u8	rsvd11[4];
+	__be16	max_qp_count;
+	__be16	rsvd12;
+	u8	rsvd13;
+	u8	local_ca_ack_delay;
+	u8	rsvd14;
+	u8	num_ports;
+	u8	log_max_msg;
+	u8	rsvd15[3];
+	__be16	stat_rate_support;
+	u8	rsvd16[2];
+	__be64	flags;
+	u8	rsvd17;
+	u8	uar_sz;
+	u8	rsvd18;
+	u8	log_pg_sz;
+	__be16	bf_log_bf_reg_size;
+	u8	rsvd19[4];
+	__be16	max_desc_sz_sq;
+	u8	rsvd20[2];
+	__be16	max_desc_sz_rq;
+	u8	rsvd21[2];
+	__be16	max_desc_sz_sq_dc;
+	u8	rsvd22[4];
+	__be16	max_qp_mcg;
+	u8	rsvd23;
+	u8	log_max_mcg;
+	u8	rsvd24;
+	u8	log_max_pd;
+	u8	rsvd25;
+	u8	log_max_xrcd;
+	u8	rsvd26[40];
+	__be32  uar_page_sz;
+	u8	rsvd27[28];
+	u8	log_msx_atomic_size_qp;
+	u8	rsvd28[2];
+	u8	log_msx_atomic_size_dc;
+	u8	rsvd29[76];
+};
+
+
+struct mlx5_cmd_query_hca_cap_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+
+struct mlx5_cmd_query_hca_cap_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[8];
+	struct mlx5_hca_cap     hca_cap;
+};
+
+
+struct mlx5_cmd_set_hca_cap_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+	struct mlx5_hca_cap     hca_cap;
+};
+
+
+struct mlx5_cmd_set_hca_cap_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[8];
+};
+
+
+struct mlx5_cmd_init_hca_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd0[2];
+	__be16			profile;
+	u8			rsvd1[4];
+};
+
+struct mlx5_cmd_init_hca_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_cmd_teardown_hca_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd0[2];
+	__be16			profile;
+	u8			rsvd1[4];
+};
+
+struct mlx5_cmd_teardown_hca_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_cmd_layout {
+	u8		type;
+	u8		rsvd0[3];
+	__be32		inlen;
+	__be64		in_ptr;
+	__be32		in[4];
+	__be32		out[4];
+	__be64		out_ptr;
+	__be32		outlen;
+	u8		token;
+	u8		sig;
+	u8		rsvd1;
+	u8		status_own;
+};
+
+
+struct health_buffer {
+	__be32		assert_var[5];
+	__be32		rsvd0[3];
+	__be32		assert_exit_ptr;
+	__be32		assert_callra;
+	__be32		rsvd1[2];
+	__be32		fw_ver;
+	__be32		hw_id;
+	__be32		rsvd2;
+	u8		irisc_index;
+	u8		synd;
+	__be16		ext_sync;
+};
+
+struct mlx5_init_seg {
+	__be32			fw_rev;
+	__be32			cmdif_rev_fw_sub;
+	__be32			rsvd0[2];
+	__be32			cmdq_addr_h;
+	__be32			cmdq_addr_l_sz;
+	__be32			cmd_dbell;
+	__be32			rsvd1[121];
+	struct health_buffer	health;
+	__be32			rsvd2[884];
+	__be32			health_counter;
+	__be32			rsvd3[1023];
+	__be64			ieee1588_clk;
+	__be32			ieee1588_clk_type;
+	__be32			clr_intx;
+};
+
+struct mlx5_eqe_comp {
+	__be32	reserved[6];
+	__be32	cqn;
+};
+
+struct mlx5_eqe_qp_srq {
+	__be32	reserved[6];
+	__be32	qp_srq_n;
+};
+
+struct mlx5_eqe_cq_err {
+	__be32	cqn;
+	u8	reserved1[7];
+	u8	syndrome;
+};
+
+struct mlx5_eqe_dropped_packet {
+};
+
+struct mlx5_eqe_port_state {
+	u8	reserved0[8];
+	u8	port;
+};
+
+struct mlx5_eqe_gpio {
+	__be32	reserved0[2];
+	__be64	gpio_event;
+};
+
+struct mlx5_eqe_congestion {
+	u8	type;
+	u8	rsvd0;
+	u8	congestion_level;
+};
+
+struct mlx5_eqe_stall_vl {
+	u8	rsvd0[3];
+	u8	port_vl;
+};
+
+struct mlx5_eqe_cmd {
+	__be32	vector;
+	__be32	rsvd[6];
+};
+
+struct mlx5_eqe_page_req {
+	u8		rsvd0[2];
+	__be16		func_id;
+	u8		rsvd1[2];
+	__be16		num_pages;
+	__be32		rsvd2[5];
+};
+
+union ev_data {
+	__be32				raw[7];
+	struct mlx5_eqe_cmd		cmd;
+	struct mlx5_eqe_comp		comp;
+	struct mlx5_eqe_qp_srq		qp_srq;
+	struct mlx5_eqe_cq_err		cq_err;
+	struct mlx5_eqe_dropped_packet	dp;
+	struct mlx5_eqe_port_state	port;
+	struct mlx5_eqe_gpio		gpio;
+	struct mlx5_eqe_congestion	cong;
+	struct mlx5_eqe_stall_vl	stall_vl;
+	struct mlx5_eqe_page_req	req_pages;
+} __packed;
+
+struct mlx5_eqe {
+	u8		rsvd0;
+	u8		type;
+	u8		rsvd1;
+	u8		sub_type;
+	__be32		rsvd2[7];
+	union ev_data	data;
+	__be16		rsvd3;
+	u8		signature;
+	u8		owner;
+} __packed;
+
+struct mlx5_cmd_prot_block {
+	u8		data[MLX5_CMD_DATA_BLOCK_SIZE];
+	u8		rsvd0[48];
+	__be64		next;
+	__be32		block_num;
+	u8		rsvd1;
+	u8		token;
+	u8		ctrl_sig;
+	u8		sig;
+};
+
+struct mlx5_err_cqe {
+	u8	rsvd0[32];
+	__be32	srqn;
+	u8	rsvd1[18];
+	u8	vendor_err_synd;
+	u8	syndrome;
+	__be32	s_wqe_opcode_qpn;
+	__be16	wqe_counter;
+	u8	signature;
+	u8	op_own;
+};
+
+struct mlx5_cqe64 {
+	u8		rsvd0[17];
+	u8		ml_path;
+	u8		rsvd20[4];
+	__be16		slid;
+	__be32		flags_rqpn;
+	u8		rsvd28[4];
+	__be32		srqn;
+	__be32		imm_inval_pkey;
+	u8		rsvd40[4];
+	__be32		byte_cnt;
+	__be64		timestamp;
+	__be32		sop_drop_qpn;
+	__be16		wqe_counter;
+	u8		signature;
+	u8		op_own;
+};
+
+struct mlx5_wqe_srq_next_seg {
+	u8			rsvd0[2];
+	__be16			next_wqe_index;
+	u8			signature;
+	u8			rsvd1[11];
+};
+
+union mlx5_ext_cqe {
+	struct ib_grh	grh;
+	u8		inl[64];
+};
+
+struct mlx5_cqe128 {
+	union mlx5_ext_cqe	inl_grh;
+	struct mlx5_cqe64	cqe64;
+};
+
+struct mlx5_srq_ctx {
+	u8			state_log_sz;
+	u8			rsvd0[3];
+	__be32			flags_xrcd;
+	__be32			pgoff_cqn;
+	u8			rsvd1[4];
+	u8			log_pg_sz;
+	u8			rsvd2[7];
+	__be32			pd;
+	__be16			lwm;
+	__be16			wqe_cnt;
+	u8			rsvd3[8];
+	__be64			db_record;
+};
+
+struct mlx5_create_srq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			input_srqn;
+	u8			rsvd0[4];
+	struct mlx5_srq_ctx	ctx;
+	u8			rsvd1[208];
+	__be64			pas[0];
+};
+
+struct mlx5_create_srq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			srqn;
+	u8			rsvd[4];
+};
+
+struct mlx5_destroy_srq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			srqn;
+	u8			rsvd[4];
+};
+
+struct mlx5_destroy_srq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_query_srq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			srqn;
+	u8			rsvd0[4];
+};
+
+struct mlx5_query_srq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[8];
+	struct mlx5_srq_ctx	ctx;
+	u8			rsvd1[32];
+	__be64			pas[0];
+};
+
+struct mlx5_arm_srq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			srqn;
+	__be16			rsvd;
+	__be16			lwm;
+};
+
+struct mlx5_arm_srq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_cq_context {
+	u8			status;
+	u8			cqe_sz_flags;
+	u8			st;
+	u8			rsvd3;
+	u8			rsvd4[6];
+	__be16			page_offset;
+	__be32			log_sz_usr_page;
+	__be16			cq_period;
+	__be16			cq_max_count;
+	__be16			rsvd20;
+	__be16			c_eqn;
+	u8			log_pg_sz;
+	u8			rsvd25[7];
+	__be32			last_notified_index;
+	__be32			solicit_producer_index;
+	__be32			consumer_counter;
+	__be32			producer_counter;
+	u8			rsvd48[8];
+	__be64			db_record_addr;
+};
+
+struct mlx5_create_cq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			input_cqn;
+	u8			rsvdx[4];
+	struct mlx5_cq_context	ctx;
+	u8			rsvd6[192];
+	__be64			pas[0];
+};
+
+struct mlx5_create_cq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			cqn;
+	u8			rsvd0[4];
+};
+
+struct mlx5_destroy_cq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			cqn;
+	u8			rsvd0[4];
+};
+
+struct mlx5_destroy_cq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[8];
+};
+
+struct mlx5_query_cq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			cqn;
+	u8			rsvd0[4];
+};
+
+struct mlx5_query_cq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[8];
+	struct mlx5_cq_context	ctx;
+	u8			rsvd6[16];
+	__be64			pas[0];
+};
+
+struct mlx5_eq_context {
+	u8			status;
+	u8			ec_oi;
+	u8			st;
+	u8			rsvd2[7];
+	__be16			page_pffset;
+	__be32			log_sz_usr_page;
+	u8			rsvd3[7];
+	u8			intr;
+	u8			log_page_size;
+	u8			rsvd4[15];
+	__be32			consumer_counter;
+	__be32			produser_counter;
+	u8			rsvd5[16];
+};
+
+struct mlx5_create_eq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd0[3];
+	u8			input_eqn;
+	u8			rsvd1[4];
+	struct mlx5_eq_context	ctx;
+	u8			rsvd2[8];
+	__be64			events_mask;
+	u8			rsvd3[176];
+	__be64			pas[0];
+};
+
+struct mlx5_create_eq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[3];
+	u8			eq_number;
+	u8			rsvd1[4];
+};
+
+struct mlx5_destroy_eq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd0[3];
+	u8			eqn;
+	u8			rsvd1[4];
+};
+
+struct mlx5_destroy_eq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_map_eq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be64			mask;
+	u8			mu;
+	u8			rsvd0[2];
+	u8			eqn;
+	u8			rsvd1[24];
+};
+
+struct mlx5_map_eq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_query_eq_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd0[3];
+	u8			eqn;
+	u8			rsvd1[4];
+};
+
+struct mlx5_query_eq_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+	struct mlx5_eq_context	ctx;
+};
+
+struct mlx5_mkey_seg {
+	/* This is a two bit field occupying bits 31-30.
+	 * bit 31 is always 0,
+	 * bit 30 is zero for regular MRs and 1 (e.g free) for UMRs that do not have tanslation
+	 */
+	u8		status;
+	u8		pcie_control;
+	u8		flags;
+	u8		version;
+	__be32		qpn_mkey7_0;
+	u8		rsvd1[4];
+	__be32		flags_pd;
+	__be64		start_addr;
+	__be64		len;
+	__be32		bsfs_octo_size;
+	u8		rsvd2[16];
+	__be32		xlt_oct_size;
+	u8		rsvd3[3];
+	u8		log2_page_size;
+	u8		rsvd4[4];
+};
+
+struct mlx5_query_special_ctxs_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_query_special_ctxs_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			dump_fill_mkey;
+	__be32			reserved_lkey;
+};
+
+struct mlx5_create_mkey_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			input_mkey_index;
+	u8			rsvd0[4];
+	struct mlx5_mkey_seg	seg;
+	u8			rsvd1[16];
+	__be32			xlat_oct_act_size;
+	__be32			bsf_coto_act_size;
+	u8			rsvd2[168];
+	__be64			pas[0];
+};
+
+struct mlx5_create_mkey_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			mkey;
+	u8			rsvd[4];
+};
+
+struct mlx5_destroy_mkey_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			mkey;
+	u8			rsvd[4];
+};
+
+struct mlx5_destroy_mkey_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_query_mkey_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			mkey;
+};
+
+struct mlx5_query_mkey_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be64			pas[0];
+};
+
+struct mlx5_modify_mkey_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			mkey;
+	__be64			pas[0];
+};
+
+struct mlx5_modify_mkey_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+};
+
+struct mlx5_dump_mkey_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+};
+
+struct mlx5_dump_mkey_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			mkey;
+};
+
+struct mlx5_mad_ifc_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be16			remote_lid;
+	u8			rsvd0;
+	u8			port;
+	u8			rsvd1[4];
+	u8			data[256];
+};
+
+struct mlx5_mad_ifc_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+	u8			data[256];
+};
+
+struct mlx5_access_reg_mbox_in {
+	struct mlx5_inbox_hdr		hdr;
+	u8				rsvd0[2];
+	__be16				register_id;
+	__be32				arg;
+	__be32				data[0];
+};
+
+struct mlx5_access_reg_mbox_out {
+	struct mlx5_outbox_hdr		hdr;
+	u8				rsvd[8];
+	__be32				data[0];
+};
+
+#define MLX5_ATTR_EXTENDED_PORT_INFO	cpu_to_be16(0xff90)
+
+enum {
+	MLX_EXT_PORT_CAP_FLAG_EXTENDED_PORT_INFO	= 1 <<  0
+};
+
+#endif /* MLX5_DEVICE_H */
diff --git a/include/linux/mlx5/doorbell.h b/include/linux/mlx5/doorbell.h
new file mode 100644
index 0000000..163a818
--- /dev/null
+++ b/include/linux/mlx5/doorbell.h
@@ -0,0 +1,79 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#ifndef MLX5_DOORBELL_H
+#define MLX5_DOORBELL_H
+
+#define MLX5_BF_OFFSET	      0x800
+#define MLX5_CQ_DOORBELL      0x20
+
+#if BITS_PER_LONG == 64
+/* Assume that we can just write a 64-bit doorbell atomically.  s390
+ * actually doesn't have writeq() but S/390 systems don't even have
+ * PCI so we won't worry about it.
+ */
+
+#define MLX5_DECLARE_DOORBELL_LOCK(name)
+#define MLX5_INIT_DOORBELL_LOCK(ptr)    do { } while (0)
+#define MLX5_GET_DOORBELL_LOCK(ptr)      (NULL)
+
+static inline void mlx5_write64(__be32 val[2], void __iomem *dest,
+				spinlock_t *doorbell_lock)
+{
+	__raw_writeq(*(u64 *)val, dest);
+}
+
+#else
+
+/* Just fall back to a spinlock to protect the doorbell if
+ * BITS_PER_LONG is 32 -- there's no portable way to do atomic 64-bit
+ * MMIO writes.
+ */
+
+#define MLX5_DECLARE_DOORBELL_LOCK(name) spinlock_t name;
+#define MLX5_INIT_DOORBELL_LOCK(ptr)     spin_lock_init(ptr)
+#define MLX5_GET_DOORBELL_LOCK(ptr)      (ptr)
+
+static inline void mlx5_write64(__be32 val[2], void __iomem *dest,
+				spinlock_t *doorbell_lock)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(doorbell_lock, flags);
+	__raw_writel((__force u32) val[0], dest);
+	__raw_writel((__force u32) val[1], dest + 4);
+	spin_unlock_irqrestore(doorbell_lock, flags);
+}
+
+#endif
+
+#endif /* MLX5_DOORBELL_H */
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
new file mode 100644
index 0000000..e47f1e4
--- /dev/null
+++ b/include/linux/mlx5/driver.h
@@ -0,0 +1,769 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#ifndef MLX5_DRIVER_H
+#define MLX5_DRIVER_H
+
+#include <linux/kernel.h>
+#include <linux/completion.h>
+#include <linux/pci.h>
+#include <linux/spinlock_types.h>
+#include <linux/semaphore.h>
+#include <linux/vmalloc.h>
+#include <linux/radix-tree.h>
+#include <linux/mlx5/device.h>
+#include <linux/mlx5/doorbell.h>
+
+enum {
+	MLX5_BOARD_ID_LEN = 64,
+	MLX5_MAX_NAME_LEN = 16,
+};
+
+enum {
+	/* one minute for the sake of bringup. Generally, commands must always
+	 * complete and we may need to increase this timeout value
+	 */
+	MLX5_CMD_TIMEOUT_MSEC	= 7200 * 1000,
+	MLX5_CMD_WQ_MAX_NAME	= 32,
+};
+
+enum {
+	CMD_OWNER_SW		= 0x0,
+	CMD_OWNER_HW		= 0x1,
+	CMD_STATUS_SUCCESS	= 0,
+};
+
+enum mlx5_sqp_t {
+	MLX5_SQP_SMI		= 0,
+	MLX5_SQP_GSI		= 1,
+	MLX5_SQP_IEEE_1588	= 2,
+	MLX5_SQP_SNIFFER	= 3,
+	MLX5_SQP_SYNC_UMR	= 4,
+};
+
+enum {
+	MLX5_MAX_PORTS	= 2,
+};
+
+enum {
+	MLX5_EQ_VEC_PAGES	 = 0,
+	MLX5_EQ_VEC_CMD		 = 1,
+	MLX5_EQ_VEC_ASYNC	 = 2,
+	MLX5_EQ_VEC_COMP_BASE,
+};
+
+enum {
+	MLX5_MAX_EQ_NAME	= 20
+};
+
+enum {
+	MLX5_ATOMIC_MODE_IB_COMP	= 1 << 16,
+	MLX5_ATOMIC_MODE_CX		= 2 << 16,
+	MLX5_ATOMIC_MODE_8B		= 3 << 16,
+	MLX5_ATOMIC_MODE_16B		= 4 << 16,
+	MLX5_ATOMIC_MODE_32B		= 5 << 16,
+	MLX5_ATOMIC_MODE_64B		= 6 << 16,
+	MLX5_ATOMIC_MODE_128B		= 7 << 16,
+	MLX5_ATOMIC_MODE_256B		= 8 << 16,
+};
+
+enum {
+	MLX5_CMD_OP_QUERY_HCA_CAP		= 0x100,
+	MLX5_CMD_OP_QUERY_ADAPTER		= 0x101,
+	MLX5_CMD_OP_INIT_HCA			= 0x102,
+	MLX5_CMD_OP_TEARDOWN_HCA		= 0x103,
+	MLX5_CMD_OP_QUERY_PAGES			= 0x107,
+	MLX5_CMD_OP_MANAGE_PAGES		= 0x108,
+	MLX5_CMD_OP_SET_HCA_CAP			= 0x109,
+
+	MLX5_CMD_OP_CREATE_MKEY			= 0x200,
+	MLX5_CMD_OP_QUERY_MKEY			= 0x201,
+	MLX5_CMD_OP_DESTROY_MKEY		= 0x202,
+	MLX5_CMD_OP_QUERY_SPECIAL_CONTEXTS	= 0x203,
+
+	MLX5_CMD_OP_CREATE_EQ			= 0x301,
+	MLX5_CMD_OP_DESTROY_EQ			= 0x302,
+	MLX5_CMD_OP_QUERY_EQ			= 0x303,
+
+	MLX5_CMD_OP_CREATE_CQ			= 0x400,
+	MLX5_CMD_OP_DESTROY_CQ			= 0x401,
+	MLX5_CMD_OP_QUERY_CQ			= 0x402,
+	MLX5_CMD_OP_MODIFY_CQ			= 0x403,
+
+	MLX5_CMD_OP_CREATE_QP			= 0x500,
+	MLX5_CMD_OP_DESTROY_QP			= 0x501,
+	MLX5_CMD_OP_RST2INIT_QP			= 0x502,
+	MLX5_CMD_OP_INIT2RTR_QP			= 0x503,
+	MLX5_CMD_OP_RTR2RTS_QP			= 0x504,
+	MLX5_CMD_OP_RTS2RTS_QP			= 0x505,
+	MLX5_CMD_OP_SQERR2RTS_QP		= 0x506,
+	MLX5_CMD_OP_2ERR_QP			= 0x507,
+	MLX5_CMD_OP_RTS2SQD_QP			= 0x508,
+	MLX5_CMD_OP_SQD2RTS_QP			= 0x509,
+	MLX5_CMD_OP_2RST_QP			= 0x50a,
+	MLX5_CMD_OP_QUERY_QP			= 0x50b,
+	MLX5_CMD_OP_CONF_SQP			= 0x50c,
+	MLX5_CMD_OP_MAD_IFC			= 0x50d,
+	MLX5_CMD_OP_INIT2INIT_QP		= 0x50e,
+	MLX5_CMD_OP_SUSPEND_QP			= 0x50f,
+	MLX5_CMD_OP_UNSUSPEND_QP		= 0x510,
+	MLX5_CMD_OP_SQD2SQD_QP			= 0x511,
+	MLX5_CMD_OP_ALLOC_QP_COUNTER_SET	= 0x512,
+	MLX5_CMD_OP_DEALLOC_QP_COUNTER_SET	= 0x513,
+	MLX5_CMD_OP_QUERY_QP_COUNTER_SET	= 0x514,
+
+	MLX5_CMD_OP_CREATE_PSV			= 0x600,
+	MLX5_CMD_OP_DESTROY_PSV			= 0x601,
+	MLX5_CMD_OP_QUERY_PSV			= 0x602,
+	MLX5_CMD_OP_QUERY_SIG_RULE_TABLE	= 0x603,
+	MLX5_CMD_OP_QUERY_BLOCK_SIZE_TABLE	= 0x604,
+
+	MLX5_CMD_OP_CREATE_SRQ			= 0x700,
+	MLX5_CMD_OP_DESTROY_SRQ			= 0x701,
+	MLX5_CMD_OP_QUERY_SRQ			= 0x702,
+	MLX5_CMD_OP_ARM_RQ			= 0x703,
+	MLX5_CMD_OP_RESIZE_SRQ			= 0x704,
+
+	MLX5_CMD_OP_ALLOC_PD			= 0x800,
+	MLX5_CMD_OP_DEALLOC_PD			= 0x801,
+	MLX5_CMD_OP_ALLOC_UAR			= 0x802,
+	MLX5_CMD_OP_DEALLOC_UAR			= 0x803,
+
+	MLX5_CMD_OP_ATTACH_TO_MCG		= 0x806,
+	MLX5_CMD_OP_DETACH_FROM_MCG		= 0x807,
+
+
+	MLX5_CMD_OP_ALLOC_XRCD			= 0x80e,
+	MLX5_CMD_OP_DEALLOC_XRCD		= 0x80f,
+
+	MLX5_CMD_OP_ACCESS_REG			= 0x805,
+	MLX5_CMD_OP_MAX				= 0x810,
+};
+
+enum {
+	MLX5_REG_PCAP		 = 0x5001,
+	MLX5_REG_PMTU		 = 0x5003,
+	MLX5_REG_PTYS		 = 0x5004,
+	MLX5_REG_PAOS		 = 0x5006,
+	MLX5_REG_PMAOS		 = 0x5012,
+	MLX5_REG_PUDE		 = 0x5009,
+	MLX5_REG_PMPE		 = 0x5010,
+	MLX5_REG_PELC		 = 0x500e,
+	MLX5_REG_PMLP		 = 0, /* TBD */
+	MLX5_REG_NODE_DESC	 = 0x6001,
+	MLX5_REG_HOST_ENDIANNESS = 0x7004,
+};
+
+enum dbg_rsc_type {
+	MLX5_DBG_RSC_QP,
+	MLX5_DBG_RSC_EQ,
+	MLX5_DBG_RSC_CQ,
+};
+
+struct mlx5_field_desc {
+	struct dentry	       *dent;
+	int			i;
+};
+
+struct mlx5_rsc_debug {
+	struct mlx5_core_dev   *dev;
+	void		       *object;
+	enum dbg_rsc_type	type;
+	struct dentry	       *root;
+	struct mlx5_field_desc	fields[0];
+};
+
+enum mlx5_dev_event {
+	MLX5_DEV_EVENT_SYS_ERROR,
+	MLX5_DEV_EVENT_PORT_UP,
+	MLX5_DEV_EVENT_PORT_DOWN,
+	MLX5_DEV_EVENT_PORT_INITIALIZED,
+	MLX5_DEV_EVENT_LID_CHANGE,
+	MLX5_DEV_EVENT_PKEY_CHANGE,
+	MLX5_DEV_EVENT_GUID_CHANGE,
+	MLX5_DEV_EVENT_CLIENT_REREG,
+};
+
+struct mlx5_uuar_info {
+	struct mlx5_uar	       *uars;
+	int			num_uars;
+	int			num_low_latency_uuars;
+	unsigned long	       *bitmap;
+	unsigned int	       *count;
+	struct mlx5_bf	       *bfs;
+
+	/*
+	 * protect uuar allocation data structs
+	 */
+	struct mutex		lock;
+};
+
+struct mlx5_bf {
+	void __iomem	       *reg;
+	void __iomem	       *regreg;
+	int			buf_size;
+	struct mlx5_uar	       *uar;
+	unsigned long		offset;
+	int			need_lock;
+	/* protect blue flame buffer selection when needed
+	 */
+	spinlock_t		lock;
+
+	/* serialize 64 bit writes when done as two 32 bit accesses
+	 */
+	spinlock_t		lock32;
+	int			uuarn;
+};
+
+struct mlx5_cmd_first {
+	__be32		data[4];
+};
+
+struct mlx5_cmd_msg {
+	struct list_head		list;
+	struct cache_ent	       *cache;
+	u32				len;
+	struct mlx5_cmd_first		first;
+	struct mlx5_cmd_mailbox	       *next;
+};
+
+struct mlx5_cmd_debug {
+	struct dentry	       *dbg_root;
+	struct dentry	       *dbg_in;
+	struct dentry	       *dbg_out;
+	struct dentry	       *dbg_outlen;
+	struct dentry	       *dbg_status;
+	struct dentry	       *dbg_run;
+	void		       *in_msg;
+	void		       *out_msg;
+	u8			status;
+	u16			inlen;
+	u16			outlen;
+};
+
+struct cache_ent {
+	/* protect block chain allocations
+	 */
+	spinlock_t		lock;
+	struct list_head	head;
+};
+
+struct cmd_msg_cache {
+	struct cache_ent	large;
+	struct cache_ent	med;
+
+};
+
+struct mlx5_cmd_stats {
+	u64		sum;
+	u64		n;
+	struct dentry  *root;
+	struct dentry  *avg;
+	struct dentry  *count;
+	/* protect command average calculations */
+	spinlock_t	lock;
+};
+
+struct mlx5_cmd {
+	void	       *cmd_buf;
+	dma_addr_t	dma;
+	u16		cmdif_rev;
+	u8		log_sz;
+	u8		log_stride;
+	int		max_reg_cmds;
+	int		events;
+	u32 __iomem    *vector;
+
+	/* protect command queue allocations
+	 */
+	spinlock_t	alloc_lock;
+
+	/* protect token allocations
+	 */
+	spinlock_t	token_lock;
+	u8		token;
+	unsigned long	bitmask;
+	char		wq_name[MLX5_CMD_WQ_MAX_NAME];
+	struct workqueue_struct *wq;
+	struct semaphore sem;
+	struct semaphore pages_sem;
+	int	mode;
+	struct mlx5_cmd_work_ent *ent_arr[MLX5_MAX_COMMANDS];
+	struct pci_pool *pool;
+	struct mlx5_cmd_debug dbg;
+	struct cmd_msg_cache cache;
+	int checksum_disabled;
+	struct mlx5_cmd_stats stats[MLX5_CMD_OP_MAX];
+};
+
+struct mlx5_port_caps {
+	int	gid_table_len;
+	int	pkey_table_len;
+};
+
+struct mlx5_caps {
+	u8	log_max_eq;
+	u8	log_max_cq;
+	u8	log_max_qp;
+	u8	log_max_mkey;
+	u8	log_max_pd;
+	u8	log_max_srq;
+	u32	max_cqes;
+	int	max_wqes;
+	int	max_sq_desc_sz;
+	int	max_rq_desc_sz;
+	u64	flags;
+	u16	stat_rate_support;
+	int	log_max_msg;
+	int	num_ports;
+	int	max_ra_res_qp;
+	int	max_ra_req_qp;
+	int	max_srq_wqes;
+	int	bf_reg_size;
+	int	bf_regs_per_page;
+	struct mlx5_port_caps	port[MLX5_MAX_PORTS];
+	u8			ext_port_cap[MLX5_MAX_PORTS];
+	int	max_vf;
+	u32	reserved_lkey;
+	u8	local_ca_ack_delay;
+	u8	log_max_mcg;
+	u16	max_qp_mcg;
+	int	min_page_sz;
+};
+
+struct mlx5_cmd_mailbox {
+	void	       *buf;
+	dma_addr_t	dma;
+	struct mlx5_cmd_mailbox *next;
+};
+
+struct mlx5_buf_list {
+	void		       *buf;
+	dma_addr_t		map;
+};
+
+struct mlx5_buf {
+	struct mlx5_buf_list	direct;
+	struct mlx5_buf_list   *page_list;
+	int			nbufs;
+	int			npages;
+	int			page_shift;
+	int			size;
+};
+
+struct mlx5_eq {
+	struct mlx5_core_dev   *dev;
+	__be32 __iomem	       *doorbell;
+	u32			cons_index;
+	struct mlx5_buf		buf;
+	int			size;
+	u8			irqn;
+	u8			eqn;
+	int			nent;
+	u64			mask;
+	char			name[MLX5_MAX_EQ_NAME];
+	struct list_head	list;
+	int			index;
+	struct mlx5_rsc_debug	*dbg;
+};
+
+
+struct mlx5_core_mr {
+	u64			iova;
+	u64			size;
+	u32			key;
+	u32			pd;
+	u32			access;
+};
+
+struct mlx5_core_srq {
+	u32		srqn;
+	int		max;
+	int		max_gs;
+	int		max_avail_gather;
+	int		wqe_shift;
+	void (*event)	(struct mlx5_core_srq *, enum mlx5_event);
+
+	atomic_t		refcount;
+	struct completion	free;
+};
+
+struct mlx5_eq_table {
+	void __iomem	       *update_ci;
+	void __iomem	       *update_arm_ci;
+	struct list_head       *comp_eq_head;
+	struct mlx5_eq		pages_eq;
+	struct mlx5_eq		async_eq;
+	struct mlx5_eq		cmd_eq;
+	struct msix_entry	*msix_arr;
+	int			num_comp_vectors;
+	/* protect EQs list
+	 */
+	spinlock_t		lock;
+};
+
+struct mlx5_uar {
+	u32			index;
+	struct list_head	bf_list;
+	unsigned		free_bf_bmap;
+	void __iomem	       *wc_map;
+	void __iomem	       *map;
+};
+
+
+struct mlx5_core_health {
+	struct health_buffer __iomem   *health;
+	__be32 __iomem		       *health_counter;
+	struct timer_list		timer;
+	struct list_head		list;
+	u32				prev;
+	int				miss_counter;
+};
+
+struct mlx5_cq_table {
+	/* protect radix tree
+	 */
+	spinlock_t		lock;
+	struct radix_tree_root	tree;
+};
+
+struct mlx5_qp_table {
+	/* protect radix tree
+	 */
+	spinlock_t		lock;
+	struct radix_tree_root	tree;
+};
+
+struct mlx5_srq_table {
+	/* protect radix tree
+	 */
+	spinlock_t		lock;
+	struct radix_tree_root	tree;
+};
+
+struct mlx5_priv {
+	char			name[MLX5_MAX_NAME_LEN];
+	struct mlx5_eq_table	eq_table;
+	struct mlx5_uuar_info	uuari;
+	MLX5_DECLARE_DOORBELL_LOCK(cq_uar_lock);
+
+	/* pages stuff */
+	struct workqueue_struct *pg_wq;
+	struct rb_root		page_root;
+	int			fw_pages;
+	int			reg_pages;
+
+	struct mlx5_core_health health;
+
+	struct mlx5_srq_table	srq_table;
+
+	/* start: qp staff */
+	struct mlx5_qp_table	qp_table;
+	struct dentry	       *qp_debugfs;
+	struct dentry	       *eq_debugfs;
+	struct dentry	       *cq_debugfs;
+	struct dentry	       *cmdif_debugfs;
+	/* end: qp staff */
+
+	/* start: cq staff */
+	struct mlx5_cq_table	cq_table;
+	/* end: cq staff */
+
+	/* start: alloc staff */
+	struct mutex            pgdir_mutex;
+	struct list_head        pgdir_list;
+	/* end: alloc staff */
+	struct dentry	       *dbg_root;
+
+	/* protect mkey key part */
+	spinlock_t		mkey_lock;
+	u8			mkey_key;
+};
+
+struct mlx5_core_dev {
+	struct pci_dev	       *pdev;
+	u8			rev_id;
+	char			board_id[MLX5_BOARD_ID_LEN];
+	struct mlx5_cmd		cmd;
+	struct mlx5_caps	caps;
+	phys_addr_t		iseg_base;
+	struct mlx5_init_seg __iomem *iseg;
+	void			(*event) (struct mlx5_core_dev *dev,
+					  enum mlx5_dev_event event,
+					  void *data);
+	struct mlx5_priv	priv;
+	struct mlx5_profile	*profile;
+	atomic_t		num_qps;
+};
+
+struct mlx5_db {
+	__be32			*db;
+	union {
+		struct mlx5_db_pgdir		*pgdir;
+		struct mlx5_ib_user_db_page	*user_page;
+	}			u;
+	dma_addr_t		dma;
+	int			index;
+};
+
+enum {
+	MLX5_DB_PER_PAGE = PAGE_SIZE / L1_CACHE_BYTES,
+};
+
+enum {
+	MLX5_COMP_EQ_SIZE = 1024,
+};
+
+struct mlx5_db_pgdir {
+	struct list_head	list;
+	DECLARE_BITMAP(bitmap, MLX5_DB_PER_PAGE);
+	__be32		       *db_page;
+	dma_addr_t		db_dma;
+};
+
+typedef void (*mlx5_cmd_cbk_t)(int status, void *context);
+
+struct mlx5_cmd_work_ent {
+	struct mlx5_cmd_msg    *in;
+	struct mlx5_cmd_msg    *out;
+	mlx5_cmd_cbk_t		callback;
+	void		       *context;
+	int idx;
+	struct completion	done;
+	struct mlx5_cmd        *cmd;
+	struct work_struct	work;
+	struct mlx5_cmd_layout *lay;
+	int			ret;
+	int			page_queue;
+	u8			status;
+	u8			token;
+	struct timespec		ts1;
+	struct timespec		ts2;
+};
+
+struct mlx5_pas {
+	u64	pa;
+	u8	log_sz;
+};
+
+static inline void *mlx5_buf_offset(struct mlx5_buf *buf, int offset)
+{
+	if (likely(BITS_PER_LONG == 64 || buf->nbufs == 1))
+		return buf->direct.buf + offset;
+	else
+		return buf->page_list[offset >> PAGE_SHIFT].buf +
+			(offset & (PAGE_SIZE - 1));
+}
+
+extern struct workqueue_struct *mlx5_core_wq;
+
+#define STRUCT_FIELD(header, field) \
+	.struct_offset_bytes = offsetof(struct ib_unpacked_ ## header, field),      \
+	.struct_size_bytes   = sizeof((struct ib_unpacked_ ## header *)0)->field
+
+struct ib_field {
+	size_t struct_offset_bytes;
+	size_t struct_size_bytes;
+	int    offset_bits;
+	int    size_bits;
+};
+
+static inline struct mlx5_core_dev *pci2mlx5_core_dev(struct pci_dev *pdev)
+{
+	return pci_get_drvdata(pdev);
+}
+
+extern struct dentry *mlx5_debugfs_root;
+
+static inline u16 fw_rev_maj(struct mlx5_core_dev *dev)
+{
+	return ioread32be(&dev->iseg->fw_rev) & 0xffff;
+}
+
+static inline u16 fw_rev_min(struct mlx5_core_dev *dev)
+{
+	return ioread32be(&dev->iseg->fw_rev) >> 16;
+}
+
+static inline u16 fw_rev_sub(struct mlx5_core_dev *dev)
+{
+	return ioread32be(&dev->iseg->cmdif_rev_fw_sub) & 0xffff;
+}
+
+static inline u16 cmdif_rev(struct mlx5_core_dev *dev)
+{
+	return ioread32be(&dev->iseg->cmdif_rev_fw_sub) >> 16;
+}
+
+static inline void *mlx5_vzalloc(unsigned long size)
+{
+	void *rtn;
+
+	rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+	if (!rtn)
+		rtn = vzalloc(size);
+	return rtn;
+}
+
+static inline void mlx5_vfree(const void *addr)
+{
+	if (addr && is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
+
+int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev);
+void mlx5_dev_cleanup(struct mlx5_core_dev *dev);
+int mlx5_cmd_init(struct mlx5_core_dev *dev);
+void mlx5_cmd_cleanup(struct mlx5_core_dev *dev);
+void mlx5_cmd_use_events(struct mlx5_core_dev *dev);
+void mlx5_cmd_use_polling(struct mlx5_core_dev *dev);
+int mlx5_cmd_status_to_err(struct mlx5_outbox_hdr *hdr);
+int mlx5_cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
+		  int out_size);
+int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn);
+int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn);
+int mlx5_alloc_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
+int mlx5_free_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
+void mlx5_health_cleanup(void);
+void  __init mlx5_health_init(void);
+void mlx5_start_health_poll(struct mlx5_core_dev *dev);
+void mlx5_stop_health_poll(struct mlx5_core_dev *dev);
+int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, int max_direct,
+		   struct mlx5_buf *buf);
+void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf);
+struct mlx5_cmd_mailbox *mlx5_alloc_cmd_mailbox_chain(struct mlx5_core_dev *dev,
+						      gfp_t flags, int npages);
+void mlx5_free_cmd_mailbox_chain(struct mlx5_core_dev *dev,
+				 struct mlx5_cmd_mailbox *head);
+int mlx5_core_create_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
+			 struct mlx5_create_srq_mbox_in *in, int inlen);
+int mlx5_core_destroy_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq);
+int mlx5_core_query_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
+			struct mlx5_query_srq_mbox_out *out);
+int mlx5_core_arm_srq(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
+		      u16 lwm, int is_srq);
+int mlx5_core_create_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+			  struct mlx5_create_mkey_mbox_in *in, int inlen);
+int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr);
+int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+			 struct mlx5_query_mkey_mbox_out *out, int outlen);
+int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+			     u32 *mkey);
+int mlx5_core_alloc_pd(struct mlx5_core_dev *dev, u32 *pdn);
+int mlx5_core_dealloc_pd(struct mlx5_core_dev *dev, u32 pdn);
+int mlx5_core_mad_ifc(struct mlx5_core_dev *dev, void *inb, void *outb,
+		      u16 opmod, int port);
+void mlx5_pagealloc_init(struct mlx5_core_dev *dev);
+void mlx5_pagealloc_cleanup(struct mlx5_core_dev *dev);
+int mlx5_pagealloc_start(struct mlx5_core_dev *dev);
+void mlx5_pagealloc_stop(struct mlx5_core_dev *dev);
+void mlx5_core_req_pages_handler(struct mlx5_core_dev *dev, u16 func_id,
+				 s16 npages);
+int mlx5_satisfy_startup_pages(struct mlx5_core_dev *dev);
+int mlx5_reclaim_startup_pages(struct mlx5_core_dev *dev);
+void mlx5_register_debugfs(void);
+void mlx5_unregister_debugfs(void);
+int mlx5_eq_init(struct mlx5_core_dev *dev);
+void mlx5_eq_cleanup(struct mlx5_core_dev *dev);
+void mlx5_fill_page_array(struct mlx5_buf *buf, __be64 *pas);
+void mlx5_cq_completion(struct mlx5_core_dev *dev, u32 cqn);
+void mlx5_qp_event(struct mlx5_core_dev *dev, u32 qpn, int event_type);
+void mlx5_srq_event(struct mlx5_core_dev *dev, u32 srqn, int event_type);
+struct mlx5_core_srq *mlx5_core_get_srq(struct mlx5_core_dev *dev, u32 srqn);
+void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector);
+void mlx5_cq_event(struct mlx5_core_dev *dev, u32 cqn, int event_type);
+int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
+		       int nent, u64 mask, const char *name, struct mlx5_uar *uar);
+int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
+int mlx5_start_eqs(struct mlx5_core_dev *dev);
+int mlx5_stop_eqs(struct mlx5_core_dev *dev);
+int mlx5_core_attach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn);
+int mlx5_core_detach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn);
+
+int mlx5_qp_debugfs_init(struct mlx5_core_dev *dev);
+void mlx5_qp_debugfs_cleanup(struct mlx5_core_dev *dev);
+int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
+			 int size_in, void *data_out, int size_out,
+			 u16 reg_num, int arg, int write);
+int mlx5_set_port_caps(struct mlx5_core_dev *dev, int port_num, u32 caps);
+
+int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
+void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
+int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
+		       struct mlx5_query_eq_mbox_out *out, int outlen);
+int mlx5_eq_debugfs_init(struct mlx5_core_dev *dev);
+void mlx5_eq_debugfs_cleanup(struct mlx5_core_dev *dev);
+int mlx5_cq_debugfs_init(struct mlx5_core_dev *dev);
+void mlx5_cq_debugfs_cleanup(struct mlx5_core_dev *dev);
+int mlx5_db_alloc(struct mlx5_core_dev *dev, struct mlx5_db *db);
+void mlx5_db_free(struct mlx5_core_dev *dev, struct mlx5_db *db);
+
+typedef void (*health_handler_t)(struct pci_dev *pdev, void *buf, int size);
+int mlx5_register_health_report_handler(health_handler_t handler);
+void mlx5_unregister_health_report_handler(void);
+const char *mlx5_command_str(int command);
+int mlx5_cmdif_debugfs_init(struct mlx5_core_dev *dev);
+void mlx5_cmdif_debugfs_cleanup(struct mlx5_core_dev *dev);
+
+static inline u32 mlx5_mkey_to_idx(u32 mkey)
+{
+	return mkey >> 8;
+}
+
+static inline u32 mlx5_idx_to_mkey(u32 mkey_idx)
+{
+	return mkey_idx << 8;
+}
+
+enum {
+	MLX5_PROF_MASK_QP_SIZE		= (u64)1 << 0,
+	MLX5_PROF_MASK_CMDIF_CSUM	= (u64)1 << 1,
+	MLX5_PROF_MASK_MR_CACHE		= (u64)1 << 2,
+};
+
+enum {
+	MAX_MR_CACHE_ENTRIES    = 16,
+};
+
+struct mlx5_profile {
+	u64	mask;
+	u32	log_max_qp;
+	int	cmdif_csum;
+	struct {
+		int	size;
+		int	limit;
+	} mr_cache[MAX_MR_CACHE_ENTRIES];
+};
+
+#endif /* MLX5_DRIVER_H */
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
new file mode 100644
index 0000000..d9e3eac
--- /dev/null
+++ b/include/linux/mlx5/qp.h
@@ -0,0 +1,467 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#ifndef MLX5_QP_H
+#define MLX5_QP_H
+
+#include <linux/mlx5/device.h>
+#include <linux/mlx5/driver.h>
+
+#define MLX5_INVALID_LKEY	0x100
+
+enum mlx5_qp_optpar {
+	MLX5_QP_OPTPAR_ALT_ADDR_PATH		= 1 << 0,
+	MLX5_QP_OPTPAR_RRE			= 1 << 1,
+	MLX5_QP_OPTPAR_RAE			= 1 << 2,
+	MLX5_QP_OPTPAR_RWE			= 1 << 3,
+	MLX5_QP_OPTPAR_PKEY_INDEX		= 1 << 4,
+	MLX5_QP_OPTPAR_Q_KEY			= 1 << 5,
+	MLX5_QP_OPTPAR_RNR_TIMEOUT		= 1 << 6,
+	MLX5_QP_OPTPAR_PRIMARY_ADDR_PATH	= 1 << 7,
+	MLX5_QP_OPTPAR_SRA_MAX			= 1 << 8,
+	MLX5_QP_OPTPAR_RRA_MAX			= 1 << 9,
+	MLX5_QP_OPTPAR_PM_STATE			= 1 << 10,
+	MLX5_QP_OPTPAR_RETRY_COUNT		= 1 << 12,
+	MLX5_QP_OPTPAR_RNR_RETRY		= 1 << 13,
+	MLX5_QP_OPTPAR_ACK_TIMEOUT		= 1 << 14,
+	MLX5_QP_OPTPAR_PRI_PORT			= 1 << 16,
+	MLX5_QP_OPTPAR_SRQN			= 1 << 18,
+	MLX5_QP_OPTPAR_CQN_RCV			= 1 << 19,
+	MLX5_QP_OPTPAR_DC_HS			= 1 << 20,
+	MLX5_QP_OPTPAR_DC_KEY			= 1 << 21,
+};
+
+enum mlx5_qp_state {
+	MLX5_QP_STATE_RST			= 0,
+	MLX5_QP_STATE_INIT			= 1,
+	MLX5_QP_STATE_RTR			= 2,
+	MLX5_QP_STATE_RTS			= 3,
+	MLX5_QP_STATE_SQER			= 4,
+	MLX5_QP_STATE_SQD			= 5,
+	MLX5_QP_STATE_ERR			= 6,
+	MLX5_QP_STATE_SQ_DRAINING		= 7,
+	MLX5_QP_STATE_SUSPENDED			= 9,
+	MLX5_QP_NUM_STATE
+};
+
+enum {
+	MLX5_QP_ST_RC				= 0x0,
+	MLX5_QP_ST_UC				= 0x1,
+	MLX5_QP_ST_UD				= 0x2,
+	MLX5_QP_ST_XRC				= 0x3,
+	MLX5_QP_ST_MLX				= 0x4,
+	MLX5_QP_ST_DCI				= 0x5,
+	MLX5_QP_ST_DCT				= 0x6,
+	MLX5_QP_ST_QP0				= 0x7,
+	MLX5_QP_ST_QP1				= 0x8,
+	MLX5_QP_ST_RAW_ETHERTYPE		= 0x9,
+	MLX5_QP_ST_RAW_IPV6			= 0xa,
+	MLX5_QP_ST_SNIFFER			= 0xb,
+	MLX5_QP_ST_SYNC_UMR			= 0xe,
+	MLX5_QP_ST_PTP_1588			= 0xd,
+	MLX5_QP_ST_REG_UMR			= 0xc,
+	MLX5_QP_ST_MAX
+};
+
+enum {
+	MLX5_QP_PM_MIGRATED			= 0x3,
+	MLX5_QP_PM_ARMED			= 0x0,
+	MLX5_QP_PM_REARM			= 0x1
+};
+
+enum {
+	MLX5_NON_ZERO_RQ	= 0 << 24,
+	MLX5_SRQ_RQ		= 1 << 24,
+	MLX5_CRQ_RQ		= 2 << 24,
+	MLX5_ZERO_LEN_RQ	= 3 << 24
+};
+
+enum {
+	/* params1 */
+	MLX5_QP_BIT_SRE				= 1 << 15,
+	MLX5_QP_BIT_SWE				= 1 << 14,
+	MLX5_QP_BIT_SAE				= 1 << 13,
+	/* params2 */
+	MLX5_QP_BIT_RRE				= 1 << 15,
+	MLX5_QP_BIT_RWE				= 1 << 14,
+	MLX5_QP_BIT_RAE				= 1 << 13,
+	MLX5_QP_BIT_RIC				= 1 <<	4,
+};
+
+enum {
+	MLX5_WQE_CTRL_CQ_UPDATE		= 2 << 2,
+	MLX5_WQE_CTRL_SOLICITED		= 1 << 1,
+};
+
+enum {
+	MLX5_SEND_WQE_BB	= 64,
+};
+
+enum {
+	MLX5_WQE_FMR_PERM_LOCAL_READ	= 1 << 27,
+	MLX5_WQE_FMR_PERM_LOCAL_WRITE	= 1 << 28,
+	MLX5_WQE_FMR_PERM_REMOTE_READ	= 1 << 29,
+	MLX5_WQE_FMR_PERM_REMOTE_WRITE	= 1 << 30,
+	MLX5_WQE_FMR_PERM_ATOMIC	= 1 << 31
+};
+
+enum {
+	MLX5_FENCE_MODE_NONE			= 0 << 5,
+	MLX5_FENCE_MODE_INITIATOR_SMALL		= 1 << 5,
+	MLX5_FENCE_MODE_STRONG_ORDERING		= 3 << 5,
+	MLX5_FENCE_MODE_SMALL_AND_FENCE		= 4 << 5,
+};
+
+enum {
+	MLX5_QP_LAT_SENSITIVE	= 1 << 28,
+	MLX5_QP_ENABLE_SIG	= 1 << 31,
+};
+
+enum {
+	MLX5_RCV_DBR	= 0,
+	MLX5_SND_DBR	= 1,
+};
+
+struct mlx5_wqe_fmr_seg {
+	__be32			flags;
+	__be32			mem_key;
+	__be64			buf_list;
+	__be64			start_addr;
+	__be64			reg_len;
+	__be32			offset;
+	__be32			page_size;
+	u32			reserved[2];
+};
+
+struct mlx5_wqe_ctrl_seg {
+	__be32			opmod_idx_opcode;
+	__be32			qpn_ds;
+	u8			signature;
+	u8			rsvd[2];
+	u8			fm_ce_se;
+	__be32			imm;
+};
+
+struct mlx5_wqe_xrc_seg {
+	__be32			xrc_srqn;
+	u8			rsvd[12];
+};
+
+struct mlx5_wqe_masked_atomic_seg {
+	__be64			swap_add;
+	__be64			compare;
+	__be64			swap_add_mask;
+	__be64			compare_mask;
+};
+
+struct mlx5_av {
+	union {
+		struct {
+			__be32	qkey;
+			__be32	reserved;
+		} qkey;
+		__be64	dc_key;
+	} key;
+	__be32	dqp_dct;
+	u8	stat_rate_sl;
+	u8	fl_mlid;
+	__be16	rlid;
+	u8	reserved0[10];
+	u8	tclass;
+	u8	hop_limit;
+	__be32	grh_gid_fl;
+	u8	rgid[16];
+};
+
+struct mlx5_wqe_datagram_seg {
+	struct mlx5_av	av;
+};
+
+struct mlx5_wqe_raddr_seg {
+	__be64			raddr;
+	__be32			rkey;
+	u32			reserved;
+};
+
+struct mlx5_wqe_atomic_seg {
+	__be64			swap_add;
+	__be64			compare;
+};
+
+struct mlx5_wqe_data_seg {
+	__be32			byte_count;
+	__be32			lkey;
+	__be64			addr;
+};
+
+struct mlx5_wqe_umr_ctrl_seg {
+	u8		flags;
+	u8		rsvd0[3];
+	__be16		klm_octowords;
+	__be16		bsf_octowords;
+	__be64		mkey_mask;
+	u8		rsvd1[32];
+};
+
+struct mlx5_seg_set_psv {
+	__be32		psv_num;
+	__be16		syndrome;
+	__be16		status;
+	__be32		transient_sig;
+	__be32		ref_tag;
+};
+
+struct mlx5_seg_get_psv {
+	u8		rsvd[19];
+	u8		num_psv;
+	__be32		l_key;
+	__be64		va;
+	__be32		psv_index[4];
+};
+
+struct mlx5_seg_check_psv {
+	u8		rsvd0[2];
+	__be16		err_coalescing_op;
+	u8		rsvd1[2];
+	__be16		xport_err_op;
+	u8		rsvd2[2];
+	__be16		xport_err_mask;
+	u8		rsvd3[7];
+	u8		num_psv;
+	__be32		l_key;
+	__be64		va;
+	__be32		psv_index[4];
+};
+
+struct mlx5_rwqe_sig {
+	u8	rsvd0[4];
+	u8	signature;
+	u8	rsvd1[11];
+};
+
+struct mlx5_wqe_signature_seg {
+	u8	rsvd0[4];
+	u8	signature;
+	u8	rsvd1[11];
+};
+
+struct mlx5_wqe_inline_seg {
+	__be32	byte_count;
+};
+
+struct mlx5_core_qp {
+	void (*event)		(struct mlx5_core_qp *, int);
+	int			qpn;
+	atomic_t		refcount;
+	struct completion	free;
+	struct mlx5_rsc_debug	*dbg;
+	int			pid;
+};
+
+struct mlx5_qp_path {
+	u8			fl;
+	u8			rsvd3;
+	u8			free_ar;
+	u8			pkey_index;
+	u8			rsvd0;
+	u8			grh_mlid;
+	__be16			rlid;
+	u8			ackto_lt;
+	u8			mgid_index;
+	u8			static_rate;
+	u8			hop_limit;
+	__be32			tclass_flowlabel;
+	u8			rgid[16];
+	u8			rsvd1[4];
+	u8			sl;
+	u8			port;
+	u8			rsvd2[6];
+};
+
+struct mlx5_qp_context {
+	__be32			flags;
+	__be32			flags_pd;
+	u8			mtu_msgmax;
+	u8			rq_size_stride;
+	__be16			sq_crq_size;
+	__be32			qp_counter_set_usr_page;
+	__be32			wire_qpn;
+	__be32			log_pg_sz_remote_qpn;
+	struct			mlx5_qp_path pri_path;
+	struct			mlx5_qp_path alt_path;
+	__be32			params1;
+	u8			reserved2[4];
+	__be32			next_send_psn;
+	__be32			cqn_send;
+	u8			reserved3[8];
+	__be32			last_acked_psn;
+	__be32			ssn;
+	__be32			params2;
+	__be32			rnr_nextrecvpsn;
+	__be32			xrcd;
+	__be32			cqn_recv;
+	__be64			db_rec_addr;
+	__be32			qkey;
+	__be32			rq_type_srqn;
+	__be32			rmsn;
+	__be16			hw_sq_wqe_counter;
+	__be16			sw_sq_wqe_counter;
+	__be16			hw_rcyclic_byte_counter;
+	__be16			hw_rq_counter;
+	__be16			sw_rcyclic_byte_counter;
+	__be16			sw_rq_counter;
+	u8			rsvd0[5];
+	u8			cgs;
+	u8			cs_req;
+	u8			cs_res;
+	__be64			dc_access_key;
+	u8			rsvd1[24];
+};
+
+struct mlx5_create_qp_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			input_qpn;
+	u8			rsvd0[4];
+	__be32			opt_param_mask;
+	u8			rsvd1[4];
+	struct mlx5_qp_context	ctx;
+	u8			rsvd3[16];
+	__be64			pas[0];
+};
+
+struct mlx5_create_qp_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			qpn;
+	u8			rsvd0[4];
+};
+
+struct mlx5_destroy_qp_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			qpn;
+	u8			rsvd0[4];
+};
+
+struct mlx5_destroy_qp_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[8];
+};
+
+struct mlx5_modify_qp_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			qpn;
+	u8			rsvd1[4];
+	__be32			optparam;
+	u8			rsvd0[4];
+	struct mlx5_qp_context	ctx;
+};
+
+struct mlx5_modify_qp_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[8];
+};
+
+struct mlx5_query_qp_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			qpn;
+	u8			rsvd[4];
+};
+
+struct mlx5_query_qp_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd1[8];
+	__be32			optparam;
+	u8			rsvd0[4];
+	struct mlx5_qp_context	ctx;
+	u8			rsvd2[16];
+	__be64			pas[0];
+};
+
+struct mlx5_conf_sqp_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			qpn;
+	u8			rsvd[3];
+	u8			type;
+};
+
+struct mlx5_conf_sqp_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_alloc_xrcd_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_alloc_xrcd_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			xrcdn;
+	u8			rsvd[4];
+};
+
+struct mlx5_dealloc_xrcd_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			xrcdn;
+	u8			rsvd[4];
+};
+
+struct mlx5_dealloc_xrcd_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+static inline struct mlx5_core_qp *__mlx5_qp_lookup(struct mlx5_core_dev *dev, u32 qpn)
+{
+	return radix_tree_lookup(&dev->priv.qp_table.tree, qpn);
+}
+
+int mlx5_core_create_qp(struct mlx5_core_dev *dev,
+			struct mlx5_core_qp *qp,
+			struct mlx5_create_qp_mbox_in *in,
+			int inlen);
+int mlx5_core_qp_modify(struct mlx5_core_dev *dev, enum mlx5_qp_state cur_state,
+			enum mlx5_qp_state new_state,
+			struct mlx5_modify_qp_mbox_in *in, int sqd_event,
+			struct mlx5_core_qp *qp);
+int mlx5_core_destroy_qp(struct mlx5_core_dev *dev,
+			 struct mlx5_core_qp *qp);
+int mlx5_core_qp_query(struct mlx5_core_dev *dev, struct mlx5_core_qp *qp,
+		       struct mlx5_query_qp_mbox_out *out, int outlen);
+
+int mlx5_core_xrcd_alloc(struct mlx5_core_dev *dev, u32 *xrcdn);
+int mlx5_core_xrcd_dealloc(struct mlx5_core_dev *dev, u32 xrcdn);
+void mlx5_init_qp_table(struct mlx5_core_dev *dev);
+void mlx5_cleanup_qp_table(struct mlx5_core_dev *dev);
+int mlx5_debug_qp_add(struct mlx5_core_dev *dev, struct mlx5_core_qp *qp);
+void mlx5_debug_qp_remove(struct mlx5_core_dev *dev, struct mlx5_core_qp *qp);
+
+#endif /* MLX5_QP_H */
diff --git a/include/linux/mlx5/srq.h b/include/linux/mlx5/srq.h
new file mode 100644
index 0000000..e1a363a
--- /dev/null
+++ b/include/linux/mlx5/srq.h
@@ -0,0 +1,41 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
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
+ */
+
+#ifndef MLX5_SRQ_H
+#define MLX5_SRQ_H
+
+#include <linux/mlx5/driver.h>
+
+void mlx5_init_srq_table(struct mlx5_core_dev *dev);
+void mlx5_cleanup_srq_table(struct mlx5_core_dev *dev);
+
+#endif /* MLX5_SRQ_H */
-- 
1.7.1
