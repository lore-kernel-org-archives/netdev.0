From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V2 2/9] net/mlx5: Mellanox Connect-IB, core driver part 2/3
Date: Wed,  3 Jul 2013 20:13:05 +0300
Message-ID: <1372871592-32033-3-git-send-email-ogerlitz@mellanox.com>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372871592-32033-1-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  522 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |  185 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  225 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/mad.c      |   78 +++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  475 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |  106 ++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   75 +++
 drivers/net/ethernet/mellanox/mlx5/core/mr.c       |  136 +++++
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  436 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/pd.c       |  101 ++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  104 ++++
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |  301 +++++++++++
 12 files changed, 2744 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/eq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fw.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/health.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mad.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/main.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mcg.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mr.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/pd.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/port.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/qp.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
new file mode 100644
index 0000000..c40845c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -0,0 +1,522 @@
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
+#include <linux/interrupt.h>
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cmd.h>
+#include "mlx5_core.h"
+
+enum {
+	MLX5_EQE_SIZE 		= sizeof(struct mlx5_eqe),
+	MLX5_EQE_OWNER_INIT_VAL	= 0x1,
+};
+
+enum {
+	MLX5_EQ_STATE_ARMED		= 0x9,
+	MLX5_EQ_STATE_FIRED		= 0xa,
+	MLX5_EQ_STATE_ALWAYS_ARMED	= 0xb,
+};
+
+enum {
+	MLX5_NUM_SPARE_EQE	= 0x80,
+	MLX5_NUM_ASYNC_EQE	= 0x100,
+	MLX5_NUM_CMD_EQE	= 32,
+};
+
+enum {
+	MLX5_EQ_DOORBEL_OFFSET	= 0x40,
+};
+
+#define MLX5_ASYNC_EVENT_MASK ((1ull << MLX5_EVENT_TYPE_PATH_MIG)	    | \
+			       (1ull << MLX5_EVENT_TYPE_COMM_EST)	    | \
+			       (1ull << MLX5_EVENT_TYPE_SQ_DRAINED)	    | \
+			       (1ull << MLX5_EVENT_TYPE_CQ_ERROR)	    | \
+			       (1ull << MLX5_EVENT_TYPE_WQ_CATAS_ERROR)	    | \
+			       (1ull << MLX5_EVENT_TYPE_PATH_MIG_FAILED)    | \
+			       (1ull << MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR) | \
+			       (1ull << MLX5_EVENT_TYPE_WQ_ACCESS_ERROR)    | \
+			       (1ull << MLX5_EVENT_TYPE_PORT_CHANGE)	    | \
+			       (1ull << MLX5_EVENT_TYPE_SRQ_CATAS_ERROR)    | \
+			       (1ull << MLX5_EVENT_TYPE_SRQ_LAST_WQE)	    | \
+			       (1ull << MLX5_EVENT_TYPE_SRQ_RQ_LIMIT))
+
+struct map_eq_in {
+	u64	mask;
+	u32	reserved;
+	u32	unmap_eqn;
+};
+
+struct cre_des_eq {
+	u8	reserved[15];
+	u8	eqn;
+};
+
+static int mlx5_cmd_destroy_eq(struct mlx5_core_dev *dev, u8 eqn)
+{
+	struct mlx5_destroy_eq_mbox_in in;
+	struct mlx5_destroy_eq_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_EQ);
+	in.eqn = eqn;
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (!err)
+		goto ex;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+ex:
+	return err;
+}
+
+static struct mlx5_eqe *get_eqe(struct mlx5_eq *eq, u32 entry)
+{
+	return mlx5_buf_offset(&eq->buf, entry * MLX5_EQE_SIZE);
+}
+
+static struct mlx5_eqe *next_eqe_sw(struct mlx5_eq *eq)
+{
+	struct mlx5_eqe *eqe = get_eqe(eq, eq->cons_index & (eq->nent - 1));
+
+	return ((eqe->owner & 1) ^ !!(eq->cons_index & eq->nent)) ? NULL : eqe;
+}
+
+static const char *eqe_type_str(u8 type)
+{
+	switch (type) {
+	case MLX5_EVENT_TYPE_COMP:
+		return "MLX5_EVENT_TYPE_COMP";
+	case MLX5_EVENT_TYPE_PATH_MIG:
+		return "MLX5_EVENT_TYPE_PATH_MIG";
+	case MLX5_EVENT_TYPE_COMM_EST:
+		return "MLX5_EVENT_TYPE_COMM_EST";
+	case MLX5_EVENT_TYPE_SQ_DRAINED:
+		return "MLX5_EVENT_TYPE_SQ_DRAINED";
+	case MLX5_EVENT_TYPE_SRQ_LAST_WQE:
+		return "MLX5_EVENT_TYPE_SRQ_LAST_WQE";
+	case MLX5_EVENT_TYPE_SRQ_RQ_LIMIT:
+		return "MLX5_EVENT_TYPE_SRQ_RQ_LIMIT";
+	case MLX5_EVENT_TYPE_CQ_ERROR:
+		return "MLX5_EVENT_TYPE_CQ_ERROR";
+	case MLX5_EVENT_TYPE_WQ_CATAS_ERROR:
+		return "MLX5_EVENT_TYPE_WQ_CATAS_ERROR";
+	case MLX5_EVENT_TYPE_PATH_MIG_FAILED:
+		return "MLX5_EVENT_TYPE_PATH_MIG_FAILED";
+	case MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR:
+		return "MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR";
+	case MLX5_EVENT_TYPE_WQ_ACCESS_ERROR:
+		return "MLX5_EVENT_TYPE_WQ_ACCESS_ERROR";
+	case MLX5_EVENT_TYPE_SRQ_CATAS_ERROR:
+		return "MLX5_EVENT_TYPE_SRQ_CATAS_ERROR";
+	case MLX5_EVENT_TYPE_INTERNAL_ERROR:
+		return "MLX5_EVENT_TYPE_INTERNAL_ERROR";
+	case MLX5_EVENT_TYPE_PORT_CHANGE:
+		return "MLX5_EVENT_TYPE_PORT_CHANGE";
+	case MLX5_EVENT_TYPE_GPIO_EVENT:
+		return "MLX5_EVENT_TYPE_GPIO_EVENT";
+	case MLX5_EVENT_TYPE_REMOTE_CONFIG:
+		return "MLX5_EVENT_TYPE_REMOTE_CONFIG";
+	case MLX5_EVENT_TYPE_DB_BF_CONGESTION:
+		return "MLX5_EVENT_TYPE_DB_BF_CONGESTION";
+	case MLX5_EVENT_TYPE_STALL_EVENT:
+		return "MLX5_EVENT_TYPE_STALL_EVENT";
+	case MLX5_EVENT_TYPE_CMD:
+		return "MLX5_EVENT_TYPE_CMD";
+	case MLX5_EVENT_TYPE_PAGE_REQUEST:
+		return "MLX5_EVENT_TYPE_PAGE_REQUEST";
+	default:
+		return "Unrecognized event";
+	}
+}
+
+static enum mlx5_dev_event port_subtype_event(u8 subtype)
+{
+	switch (subtype) {
+	case MLX5_PORT_CHANGE_SUBTYPE_DOWN:
+		return MLX5_DEV_EVENT_PORT_DOWN;
+	case MLX5_PORT_CHANGE_SUBTYPE_ACTIVE:
+		return MLX5_DEV_EVENT_PORT_UP;
+	case MLX5_PORT_CHANGE_SUBTYPE_INITIALIZED:
+		return MLX5_DEV_EVENT_PORT_INITIALIZED;
+	case MLX5_PORT_CHANGE_SUBTYPE_LID:
+		return MLX5_DEV_EVENT_LID_CHANGE;
+	case MLX5_PORT_CHANGE_SUBTYPE_PKEY:
+		return MLX5_DEV_EVENT_PKEY_CHANGE;
+	case MLX5_PORT_CHANGE_SUBTYPE_GUID:
+		return MLX5_DEV_EVENT_GUID_CHANGE;
+	case MLX5_PORT_CHANGE_SUBTYPE_CLIENT_REREG:
+		return MLX5_DEV_EVENT_CLIENT_REREG;
+	}
+	return -1;
+}
+
+static void eq_update_ci(struct mlx5_eq *eq, int arm)
+{
+	__be32 __iomem *addr = eq->doorbell + (arm ? 0 : 2);
+	u32 val = (eq->cons_index & 0xffffff) | (eq->eqn << 24);
+	__raw_writel((__force u32) cpu_to_be32(val), addr);
+	/* We still want ordering, just not swabbing, so add a barrier */
+	mb();
+}
+
+static int mlx5_eq_int(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
+{
+	struct mlx5_eqe *eqe;
+	int eqes_found = 0;
+	int set_ci = 0;
+	u32 cqn;
+	u32 srqn;
+	u8 port;
+
+	while ((eqe = next_eqe_sw(eq))) {
+		/*
+		 * Make sure we read EQ entry contents after we've
+		 * checked the ownership bit.
+		 */
+		rmb();
+
+		mlx5_core_dbg(eq->dev, "eqn %d, eqe type %s\n", eq->eqn, eqe_type_str(eqe->type));
+		switch (eqe->type) {
+		case MLX5_EVENT_TYPE_COMP:
+			cqn = be32_to_cpu(eqe->data.comp.cqn) & 0xffffff;
+			mlx5_cq_completion(dev, cqn);
+			break;
+
+		case MLX5_EVENT_TYPE_PATH_MIG:
+		case MLX5_EVENT_TYPE_COMM_EST:
+		case MLX5_EVENT_TYPE_SQ_DRAINED:
+		case MLX5_EVENT_TYPE_SRQ_LAST_WQE:
+		case MLX5_EVENT_TYPE_WQ_CATAS_ERROR:
+		case MLX5_EVENT_TYPE_PATH_MIG_FAILED:
+		case MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR:
+		case MLX5_EVENT_TYPE_WQ_ACCESS_ERROR:
+			mlx5_core_dbg(dev, "event %s(%d) arrived\n",
+				      eqe_type_str(eqe->type), eqe->type);
+			mlx5_qp_event(dev, be32_to_cpu(eqe->data.qp_srq.qp_srq_n) & 0xffffff,
+				      eqe->type);
+			break;
+
+		case MLX5_EVENT_TYPE_SRQ_RQ_LIMIT:
+		case MLX5_EVENT_TYPE_SRQ_CATAS_ERROR:
+			srqn = be32_to_cpu(eqe->data.qp_srq.qp_srq_n) & 0xffffff;
+			mlx5_core_dbg(dev, "SRQ event %s(%d): srqn 0x%x\n",
+				      eqe_type_str(eqe->type), eqe->type, srqn);
+			mlx5_srq_event(dev, srqn, eqe->type);
+			break;
+
+		case MLX5_EVENT_TYPE_CMD:
+			mlx5_cmd_comp_handler(dev, be32_to_cpu(eqe->data.cmd.vector));
+			break;
+
+		case MLX5_EVENT_TYPE_PORT_CHANGE:
+			port = (eqe->data.port.port >> 4) & 0xf;
+			switch (eqe->sub_type) {
+			case MLX5_PORT_CHANGE_SUBTYPE_DOWN:
+			case MLX5_PORT_CHANGE_SUBTYPE_ACTIVE:
+			case MLX5_PORT_CHANGE_SUBTYPE_LID:
+			case MLX5_PORT_CHANGE_SUBTYPE_PKEY:
+			case MLX5_PORT_CHANGE_SUBTYPE_GUID:
+			case MLX5_PORT_CHANGE_SUBTYPE_CLIENT_REREG:
+			case MLX5_PORT_CHANGE_SUBTYPE_INITIALIZED:
+				dev->event(dev, port_subtype_event(eqe->sub_type), &port);
+				break;
+			default:
+				mlx5_core_warn(dev, "Port event with unrecognized subtype: port %d, sub_type %d\n",
+					       port, eqe->sub_type);
+			}
+			break;
+		case MLX5_EVENT_TYPE_CQ_ERROR:
+			cqn = be32_to_cpu(eqe->data.cq_err.cqn) & 0xffffff;
+			mlx5_core_warn(dev, "CQ error on CQN 0x%x, syndrom 0x%x\n",
+				       cqn, eqe->data.cq_err.syndrome);
+			mlx5_cq_event(dev, cqn, eqe->type);
+			break;
+
+		case MLX5_EVENT_TYPE_PAGE_REQUEST:
+			{
+				u16 func_id = be16_to_cpu(eqe->data.req_pages.func_id);
+				s16 npages = be16_to_cpu(eqe->data.req_pages.num_pages);
+
+				mlx5_core_dbg(dev, "page request for func 0x%x, napges %d\n", func_id, npages);
+				mlx5_core_req_pages_handler(dev, func_id, npages);
+			}
+			break;
+
+
+		default:
+			mlx5_core_warn(dev, "Unhandled event 0x%x on EQ 0x%x\n", eqe->type, eq->eqn);
+			break;
+		}
+
+		++eq->cons_index;
+		eqes_found = 1;
+		++set_ci;
+
+		/* The HCA will think the queue has overflowed if we
+		 * don't tell it we've been processing events.  We
+		 * create our EQs with MLX5_NUM_SPARE_EQE extra
+		 * entries, so we must update our consumer index at
+		 * least that often.
+		 */
+		if (unlikely(set_ci >= MLX5_NUM_SPARE_EQE)) {
+			eq_update_ci(eq, 0);
+			set_ci = 0;
+		}
+	}
+
+	eq_update_ci(eq, 1);
+
+	return eqes_found;
+}
+
+static irqreturn_t mlx5_msix_handler(int irq, void *eq_ptr)
+{
+	struct mlx5_eq *eq = eq_ptr;
+	struct mlx5_core_dev *dev = eq->dev;
+
+	mlx5_eq_int(dev, eq);
+
+	/* MSI-X vectors always belong to us */
+	return IRQ_HANDLED;
+}
+
+static void init_eq_buf(struct mlx5_eq *eq)
+{
+	struct mlx5_eqe *eqe;
+	int i;
+
+	for (i = 0; i < eq->nent; i++) {
+		eqe = get_eqe(eq, i);
+		eqe->owner = MLX5_EQE_OWNER_INIT_VAL;
+	}
+}
+
+int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
+		       int nent, u64 mask, const char *name, struct mlx5_uar *uar)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	struct mlx5_create_eq_mbox_in *in;
+	struct mlx5_create_eq_mbox_out out;
+	int err;
+	int inlen;
+
+	eq->nent = roundup_pow_of_two(nent + MLX5_NUM_SPARE_EQE);
+	err = mlx5_buf_alloc(dev, eq->nent * MLX5_EQE_SIZE, 2 * PAGE_SIZE,
+			     &eq->buf);
+	if (err)
+		return err;
+
+	init_eq_buf(eq);
+
+	inlen = sizeof(*in) + sizeof(in->pas[0]) * eq->buf.npages;
+	in = vzalloc(inlen);
+	if (!in) {
+		err = -ENOMEM;
+		goto err_buf;
+	}
+	memset(&out, 0, sizeof(out));
+
+	mlx5_fill_page_array(&eq->buf, in->pas);
+
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_CREATE_EQ);
+	in->ctx.log_sz_usr_page = cpu_to_be32(ilog2(eq->nent) << 24 | uar->index);
+	in->ctx.intr = vecidx;
+	in->ctx.log_page_size = PAGE_SHIFT - 12;
+	in->events_mask = cpu_to_be64(mask);
+
+	err = mlx5_cmd_exec(dev, in, inlen, &out, sizeof(out));
+	if (err)
+		goto err_in;
+
+	if (out.hdr.status) {
+		err = mlx5_cmd_status_to_err(&out.hdr);
+		goto err_in;
+	}
+
+	eq->eqn = out.eq_number;
+	err = request_irq(table->msix_arr[vecidx].vector, mlx5_msix_handler, 0,
+			  name, eq);
+	if (err)
+		goto err_eq;
+
+	eq->irqn = vecidx;
+	eq->dev = dev;
+	eq->doorbell = uar->map + MLX5_EQ_DOORBEL_OFFSET;
+
+	err = mlx5_debug_eq_add(dev, eq);
+	if (err)
+		goto err_irq;
+
+	/* EQs are created in ARMED state
+	 */
+	eq_update_ci(eq, 1);
+
+	vfree(in);
+	return 0;
+
+err_irq:
+	free_irq(table->msix_arr[vecidx].vector, eq);
+
+err_eq:
+	mlx5_cmd_destroy_eq(dev, eq->eqn);
+
+err_in:
+	vfree(in);
+
+err_buf:
+	mlx5_buf_free(dev, &eq->buf);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_create_map_eq);
+
+int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	int err;
+
+	mlx5_debug_eq_remove(dev, eq);
+	free_irq(table->msix_arr[eq->irqn].vector, eq);
+	err = mlx5_cmd_destroy_eq(dev, eq->eqn);
+	if (err)
+		mlx5_core_warn(dev, "failed to destroy a previously created eq: eqn %d\n",
+			       eq->eqn);
+	mlx5_buf_free(dev, &eq->buf);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_destroy_unmap_eq);
+
+int mlx5_eq_init(struct mlx5_core_dev *dev)
+{
+	int err;
+
+	spin_lock_init(&dev->priv.eq_table.lock);
+
+	err = mlx5_eq_debugfs_init(dev);
+
+	return err;
+}
+
+
+void mlx5_eq_cleanup(struct mlx5_core_dev *dev)
+{
+	mlx5_eq_debugfs_cleanup(dev);
+}
+
+int mlx5_start_eqs(struct mlx5_core_dev *dev)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	int err;
+
+	err = mlx5_create_map_eq(dev, &table->cmd_eq, MLX5_EQ_VEC_CMD,
+				 MLX5_NUM_CMD_EQE, 1ull << MLX5_EVENT_TYPE_CMD,
+				 "mlx5_cmd_eq", &dev->priv.uuari.uars[0]);
+	if (err) {
+		mlx5_core_warn(dev, "failed to create cmd EQ %d\n", err);
+		return err;
+	}
+
+	mlx5_cmd_use_events(dev);
+
+	err = mlx5_create_map_eq(dev, &table->async_eq, MLX5_EQ_VEC_ASYNC,
+				 MLX5_NUM_ASYNC_EQE, MLX5_ASYNC_EVENT_MASK,
+				 "mlx5_async_eq", &dev->priv.uuari.uars[0]);
+	if (err) {
+		mlx5_core_warn(dev, "failed to create async EQ %d\n", err);
+		goto err1;
+	}
+
+	err = mlx5_create_map_eq(dev, &table->pages_eq,
+				 MLX5_EQ_VEC_PAGES,
+				 dev->caps.max_vf + 1,
+				 1 << MLX5_EVENT_TYPE_PAGE_REQUEST, "mlx5_pages_eq",
+				 &dev->priv.uuari.uars[0]);
+	if (err) {
+		mlx5_core_warn(dev, "failed to create pages EQ %d\n", err);
+		goto err2;
+	}
+
+	return err;
+
+err2:
+	mlx5_destroy_unmap_eq(dev, &table->async_eq);
+
+err1:
+	mlx5_cmd_use_polling(dev);
+	mlx5_destroy_unmap_eq(dev, &table->cmd_eq);
+	return err;
+}
+
+int mlx5_stop_eqs(struct mlx5_core_dev *dev)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	int err;
+
+	err = mlx5_destroy_unmap_eq(dev, &table->pages_eq);
+	if (err)
+		return err;
+
+	mlx5_destroy_unmap_eq(dev, &table->async_eq);
+	mlx5_cmd_use_polling(dev);
+
+	err = mlx5_destroy_unmap_eq(dev, &table->cmd_eq);
+	if (err)
+		mlx5_cmd_use_events(dev);
+
+	return err;
+}
+
+int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
+		       struct mlx5_query_eq_mbox_out *out, int outlen)
+{
+	struct mlx5_query_eq_mbox_in in;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(out, 0, outlen);
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_EQ);
+	in.eqn = eq->eqn;
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
+	if (err)
+		return err;
+
+	if (out->hdr.status)
+		err = mlx5_cmd_status_to_err(&out->hdr);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_eq_query);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
new file mode 100644
index 0000000..72a5222
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -0,0 +1,185 @@
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
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cmd.h>
+#include <linux/module.h>
+#include "mlx5_core.h"
+
+int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev)
+{
+	struct mlx5_cmd_query_adapter_mbox_out *out;
+	struct mlx5_cmd_query_adapter_mbox_in in;
+	int err;
+
+	out = kzalloc(sizeof(*out), GFP_KERNEL);
+	if (!out)
+		return -ENOMEM;
+
+	memset(&in, 0, sizeof(in));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_ADAPTER);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, sizeof(*out));
+	if (err)
+		goto out_out;
+
+	if (out->hdr.status) {
+		err = mlx5_cmd_status_to_err(&out->hdr);
+		goto out_out;
+	}
+
+	memcpy(dev->board_id, out->vsd_psid, sizeof(out->vsd_psid));
+
+out_out:
+	kfree(out);
+
+	return err;
+}
+
+int mlx5_cmd_query_hca_cap(struct mlx5_core_dev *dev,
+			   struct mlx5_caps *caps)
+{
+	struct mlx5_cmd_query_hca_cap_mbox_out *out;
+	struct mlx5_cmd_query_hca_cap_mbox_in in;
+	struct mlx5_query_special_ctxs_mbox_out ctx_out;
+	struct mlx5_query_special_ctxs_mbox_in ctx_in;
+	int err;
+	u16 t16;
+
+	out = kzalloc(sizeof(*out), GFP_KERNEL);
+	if (!out)
+		return -ENOMEM;
+
+	memset(&in, 0, sizeof(in));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_HCA_CAP);
+	in.hdr.opmod  = cpu_to_be16(0x1);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, sizeof(*out));
+	if (err)
+		goto out_out;
+
+	if (out->hdr.status) {
+		err = mlx5_cmd_status_to_err(&out->hdr);
+		goto out_out;
+	}
+
+
+	caps->log_max_eq = out->hca_cap.log_max_eq & 0xf;
+	caps->max_cqes = 1 << out->hca_cap.log_max_cq_sz;
+	caps->max_wqes = 1 << out->hca_cap.log_max_qp_sz;
+	caps->max_sq_desc_sz = be16_to_cpu(out->hca_cap.max_desc_sz_sq);
+	caps->max_rq_desc_sz = be16_to_cpu(out->hca_cap.max_desc_sz_rq);
+	caps->flags = be64_to_cpu(out->hca_cap.flags);
+	caps->stat_rate_support = be16_to_cpu(out->hca_cap.stat_rate_support);
+	caps->log_max_msg = out->hca_cap.log_max_msg & 0x1f;
+	caps->num_ports = out->hca_cap.num_ports & 0xf;
+	caps->log_max_cq = out->hca_cap.log_max_cq & 0x1f;
+	if (caps->num_ports > MLX5_MAX_PORTS) {
+		mlx5_core_err(dev, "device has %d ports while the driver supports max %d ports\n",
+			      caps->num_ports, MLX5_MAX_PORTS);
+		err = -EINVAL;
+		goto out_out;
+	}
+	caps->log_max_qp = out->hca_cap.log_max_qp & 0x1f;
+	caps->log_max_mkey = out->hca_cap.log_max_mkey & 0x3f;
+	caps->log_max_pd = out->hca_cap.log_max_pd & 0x1f;
+	caps->log_max_srq = out->hca_cap.log_max_srqs & 0x1f;
+	caps->local_ca_ack_delay = out->hca_cap.local_ca_ack_delay & 0x1f;
+	caps->log_max_mcg = out->hca_cap.log_max_mcg;
+	caps->max_qp_mcg = be16_to_cpu(out->hca_cap.max_qp_mcg);
+	caps->max_ra_res_qp = 1 << (out->hca_cap.log_max_ra_res_qp & 0x3f);
+	caps->max_ra_req_qp = 1 << (out->hca_cap.log_max_ra_req_qp & 0x3f);
+	caps->max_srq_wqes = 1 << out->hca_cap.log_max_srq_sz;
+	t16 = be16_to_cpu(out->hca_cap.bf_log_bf_reg_size);
+	if (t16 & 0x8000) {
+		caps->bf_reg_size = 1 << (t16 & 0x1f);
+		caps->bf_regs_per_page = MLX5_BF_REGS_PER_PAGE;
+	} else {
+		caps->bf_reg_size = 0;
+		caps->bf_regs_per_page = 0;
+	}
+	caps->min_page_sz = ~(u32)((1 << out->hca_cap.log_pg_sz) - 1);
+
+	memset(&ctx_in, 0, sizeof(ctx_in));
+	memset(&ctx_out, 0, sizeof(ctx_out));
+	ctx_in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_SPECIAL_CONTEXTS);
+	err = mlx5_cmd_exec(dev, &ctx_in, sizeof(ctx_in),
+				 &ctx_out, sizeof(ctx_out));
+	if (err)
+		goto out_out;
+
+	if (ctx_out.hdr.status)
+		err = mlx5_cmd_status_to_err(&ctx_out.hdr);
+
+	caps->reserved_lkey = be32_to_cpu(ctx_out.reserved_lkey);
+
+out_out:
+	kfree(out);
+
+	return err;
+}
+
+int mlx5_cmd_init_hca(struct mlx5_core_dev *dev)
+{
+	struct mlx5_cmd_init_hca_mbox_in in;
+	struct mlx5_cmd_init_hca_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_INIT_HCA);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
+
+int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev)
+{
+	struct mlx5_cmd_teardown_hca_mbox_in in;
+	struct mlx5_cmd_teardown_hca_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_TEARDOWN_HCA);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
new file mode 100644
index 0000000..cca3a7b
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -0,0 +1,225 @@
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
+#include <linux/random.h>
+#include <linux/vmalloc.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cmd.h>
+#include "mlx5_core.h"
+
+enum {
+	MLX5_HEALTH_POLL_INTERVAL	= 2 * HZ,
+	MAX_MISSES			= 3,
+};
+
+enum {
+	MLX5_HEALTH_SYNDR_FW_ERR		= 0x1,
+	MLX5_HEALTH_SYNDR_IRISC_ERR		= 0x7,
+	MLX5_HEALTH_SYNDR_CRC_ERR		= 0x9,
+	MLX5_HEALTH_SYNDR_FETCH_PCI_ERR		= 0xa,
+	MLX5_HEALTH_SYNDR_HW_FTL_ERR		= 0xb,
+	MLX5_HEALTH_SYNDR_ASYNC_EQ_OVERRUN_ERR	= 0xc,
+	MLX5_HEALTH_SYNDR_EQ_ERR		= 0xd,
+	MLX5_HEALTH_SYNDR_FFSER_ERR		= 0xf,
+};
+
+static DEFINE_SPINLOCK(health_lock);
+
+static LIST_HEAD(health_list);
+static struct work_struct health_work;
+
+static health_handler_t reg_handler;
+int mlx5_register_health_report_handler(health_handler_t handler)
+{
+	spin_lock_irq(&health_lock);
+	if (reg_handler) {
+		spin_unlock_irq(&health_lock);
+		return -EEXIST;
+	}
+	reg_handler = handler;
+	spin_unlock_irq(&health_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(mlx5_register_health_report_handler);
+
+void mlx5_unregister_health_report_handler(void)
+{
+	spin_lock_irq(&health_lock);
+	reg_handler = NULL;
+	spin_unlock_irq(&health_lock);
+}
+EXPORT_SYMBOL(mlx5_unregister_health_report_handler);
+
+static void health_care(struct work_struct *work)
+{
+	struct mlx5_core_health *health, *n;
+	struct mlx5_core_dev *dev;
+	struct mlx5_priv *priv;
+	LIST_HEAD(tlist);
+
+	spin_lock_irq(&health_lock);
+	list_splice_init(&health_list, &tlist);
+
+	spin_unlock_irq(&health_lock);
+
+	list_for_each_entry_safe(health, n, &tlist, list) {
+		priv = container_of(health, struct mlx5_priv, health);
+		dev = container_of(priv, struct mlx5_core_dev, priv);
+		mlx5_core_warn(dev, "handling bad device here\n");
+		spin_lock_irq(&health_lock);
+		if (reg_handler)
+			reg_handler(dev->pdev, health->health,
+				    sizeof(health->health));
+
+		list_del_init(&health->list);
+		spin_unlock_irq(&health_lock);
+	}
+}
+
+static const char *hsynd_str(u8 synd)
+{
+	switch (synd) {
+	case MLX5_HEALTH_SYNDR_FW_ERR:
+		return "firmware internal error";
+	case MLX5_HEALTH_SYNDR_IRISC_ERR:
+		return "irisc not responding";
+	case MLX5_HEALTH_SYNDR_CRC_ERR:
+		return "firmware CRC error";
+	case MLX5_HEALTH_SYNDR_FETCH_PCI_ERR:
+		return "ICM fetch PCI error";
+	case MLX5_HEALTH_SYNDR_HW_FTL_ERR:
+		return "HW fatal error\n";
+	case MLX5_HEALTH_SYNDR_ASYNC_EQ_OVERRUN_ERR:
+		return "async EQ buffer overrun";
+	case MLX5_HEALTH_SYNDR_EQ_ERR:
+		return "EQ error";
+	case MLX5_HEALTH_SYNDR_FFSER_ERR:
+		return "FFSER error";
+	default:
+		return "unrecognized error";
+	}
+}
+
+static void print_health_info(struct mlx5_core_dev *dev)
+{
+	struct mlx5_core_health *health = &dev->priv.health;
+	struct health_buffer __iomem *h = health->health;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(h->assert_var); i++)
+		pr_info("assert_var[%d] 0x%08x\n", i, be32_to_cpu(h->assert_var[i]));
+
+	pr_info("assert_exit_ptr 0x%08x\n", be32_to_cpu(h->assert_exit_ptr));
+	pr_info("assert_callra 0x%08x\n", be32_to_cpu(h->assert_callra));
+	pr_info("fw_ver 0x%08x\n", be32_to_cpu(h->fw_ver));
+	pr_info("hw_id 0x%08x\n", be32_to_cpu(h->hw_id));
+	pr_info("irisc_index %d\n", h->irisc_index);
+	pr_info("synd 0x%x: %s\n", h->synd, hsynd_str(h->synd));
+	pr_info("ext_sync 0x%04x\n", be16_to_cpu(h->ext_sync));
+}
+
+static void poll_health(unsigned long data)
+{
+	struct mlx5_core_dev *dev = (struct mlx5_core_dev *)data;
+	struct mlx5_core_health *health = &dev->priv.health;
+	unsigned long next;
+	u32 count;
+
+	count = ioread32be(health->health_counter);
+	if (count == health->prev)
+		++health->miss_counter;
+	else
+		health->miss_counter = 0;
+
+	health->prev = count;
+	if (health->miss_counter == MAX_MISSES) {
+		mlx5_core_err(dev, "device's health compromised\n");
+		print_health_info(dev);
+		spin_lock_irq(&health_lock);
+		list_add_tail(&health->list, &health_list);
+		spin_unlock_irq(&health_lock);
+
+		queue_work(mlx5_core_wq, &health_work);
+	} else {
+		spin_lock_irq(&health_lock);
+		if (health->active) {
+			get_random_bytes(&next, sizeof(next));
+			next %= HZ;
+			next += jiffies + MLX5_HEALTH_POLL_INTERVAL;
+			mod_timer(&health->timer, next);
+		}
+		spin_unlock_irq(&health_lock);
+	}
+}
+
+void mlx5_start_health_poll(struct mlx5_core_dev *dev)
+{
+	struct mlx5_core_health *health = &dev->priv.health;
+
+	INIT_LIST_HEAD(&health->list);
+	init_timer(&health->timer);
+	health->health = &dev->iseg->health;
+	health->health_counter = &dev->iseg->health_counter;
+
+	health->timer.data = (unsigned long)dev;
+	health->timer.function = poll_health;
+	health->timer.expires = round_jiffies(jiffies + MLX5_HEALTH_POLL_INTERVAL);
+	health->active = 1;
+	add_timer(&health->timer);
+}
+
+void mlx5_stop_health_poll(struct mlx5_core_dev *dev)
+{
+	struct mlx5_core_health *health = &dev->priv.health;
+
+	spin_lock_irq(&health_lock);
+	health->active = 0;
+	spin_unlock_irq(&health_lock);
+	del_timer_sync(&health->timer);
+
+	spin_lock_irq(&health_lock);
+	if (!list_empty(&health->list))
+		list_del_init(&health->list);
+	spin_unlock_irq(&health_lock);
+}
+
+void mlx5_health_cleanup(void)
+{
+}
+
+void  __init mlx5_health_init(void)
+{
+	INIT_WORK(&health_work, health_care);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mad.c b/drivers/net/ethernet/mellanox/mlx5/core/mad.c
new file mode 100644
index 0000000..18d6fd5
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mad.c
@@ -0,0 +1,78 @@
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
+int mlx5_core_mad_ifc(struct mlx5_core_dev *dev, void *inb, void *outb,
+		      u16 opmod, int port)
+{
+	struct mlx5_mad_ifc_mbox_in *in = NULL;
+	struct mlx5_mad_ifc_mbox_out *out = NULL;
+	int err;
+
+	in = kzalloc(sizeof(*in), GFP_KERNEL);
+	if (!in)
+		return -ENOMEM;
+
+	out = kzalloc(sizeof(*out), GFP_KERNEL);
+	if (!out) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_MAD_IFC);
+	in->hdr.opmod = cpu_to_be16(opmod);
+	in->port = port;
+
+	memcpy(in->data, inb, sizeof(in->data));
+
+	err = mlx5_cmd_exec(dev, in, sizeof(*in), out, sizeof(*out));
+	if (err)
+		goto out;
+
+	if (out->hdr.status) {
+		err = mlx5_cmd_status_to_err(&out->hdr);
+		goto out;
+	}
+
+	memcpy(outb, out->data, sizeof(out->data));
+
+out:
+	kfree(out);
+	kfree(in);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_mad_ifc);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
new file mode 100644
index 0000000..f21cc39
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -0,0 +1,475 @@
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
+#include <asm-generic/kmap_types.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/pci.h>
+#include <linux/dma-mapping.h>
+#include <linux/slab.h>
+#include <linux/io-mapping.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cq.h>
+#include <linux/mlx5/qp.h>
+#include <linux/mlx5/srq.h>
+#include <linux/debugfs.h>
+#include "mlx5_core.h"
+
+#define DRIVER_NAME "mlx5_core"
+#define DRIVER_VERSION "1.0"
+#define DRIVER_RELDATE	"June 2013"
+
+MODULE_AUTHOR("Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>");
+MODULE_DESCRIPTION("Mellanox ConnectX-IB HCA core library");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(DRIVER_VERSION);
+
+int mlx5_core_debug_mask;
+module_param_named(debug_mask, mlx5_core_debug_mask, int, 0644);
+MODULE_PARM_DESC(debug_mask, "debug mask: 1 = dump cmd data, 2 = dump cmd exec time, 3 = both. Default=0");
+
+struct workqueue_struct *mlx5_core_wq;
+
+static int set_dma_caps(struct pci_dev *pdev)
+{
+	int err;
+
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
+	if (err) {
+		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit PCI DMA mask.\n");
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev, "Can't set PCI DMA mask, aborting.\n");
+			return err;
+		}
+	}
+
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
+	if (err) {
+		dev_warn(&pdev->dev,
+			 "Warning: couldn't set 64-bit consistent PCI DMA mask.\n");
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev,
+				"Can't set consistent PCI DMA mask, aborting.\n");
+			return err;
+		}
+	}
+
+	dma_set_max_seg_size(&pdev->dev, 2u * 1024 * 1024 * 1024);
+	return err;
+}
+
+static int request_bar(struct pci_dev *pdev)
+{
+	int err = 0;
+
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+		dev_err(&pdev->dev, "Missing registers BAR, aborting.\n");
+		return -ENODEV;
+	}
+
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err)
+		dev_err(&pdev->dev, "Couldn't get PCI resources, aborting\n");
+
+	return err;
+}
+
+static void release_bar(struct pci_dev *pdev)
+{
+	pci_release_regions(pdev);
+}
+
+static int mlx5_enable_msix(struct mlx5_core_dev *dev)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+	int num_eqs = 1 << dev->caps.log_max_eq;
+	int nvec;
+	int err;
+	int i;
+
+	nvec = dev->caps.num_ports * num_online_cpus() + MLX5_EQ_VEC_COMP_BASE;
+	nvec = min_t(int, nvec, num_eqs);
+	if (nvec <= MLX5_EQ_VEC_COMP_BASE)
+		return -ENOMEM;
+
+	table->msix_arr = kzalloc(nvec * sizeof(*table->msix_arr), GFP_KERNEL);
+	if (!table->msix_arr)
+		return -ENOMEM;
+
+	for (i = 0; i < nvec; i++)
+		table->msix_arr[i].entry = i;
+
+retry:
+	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
+	err = pci_enable_msix(dev->pdev, table->msix_arr, nvec);
+	if (err <= 0) {
+		return err;
+	} else if (err > 2) {
+		nvec = err;
+		goto retry;
+	}
+
+	mlx5_core_dbg(dev, "received %d MSI vectors out of %d requested\n", err, nvec);
+
+	return 0;
+}
+
+static void mlx5_disable_msix(struct mlx5_core_dev *dev)
+{
+	struct mlx5_eq_table *table = &dev->priv.eq_table;
+
+	pci_disable_msix(dev->pdev);
+	kfree(table->msix_arr);
+}
+
+struct mlx5_reg_host_endianess {
+	u8	he;
+	u8      rsvd[15];
+};
+
+static int handle_hca_cap(struct mlx5_core_dev *dev)
+{
+	struct mlx5_cmd_query_hca_cap_mbox_out *query_out = NULL;
+	struct mlx5_cmd_set_hca_cap_mbox_in *set_ctx = NULL;
+	struct mlx5_cmd_query_hca_cap_mbox_in query_ctx;
+	struct mlx5_cmd_set_hca_cap_mbox_out set_out;
+	struct mlx5_profile *prof = dev->profile;
+	u64 flags;
+	int csum = 1;
+	int err;
+
+	memset(&query_ctx, 0, sizeof(query_ctx));
+	query_out = kzalloc(sizeof(*query_out), GFP_KERNEL);
+	if (!query_out)
+		return -ENOMEM;
+
+	set_ctx = kzalloc(sizeof(*set_ctx), GFP_KERNEL);
+	if (!set_ctx) {
+		err = -ENOMEM;
+		goto query_ex;
+	}
+
+	query_ctx.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_HCA_CAP);
+	query_ctx.hdr.opmod  = cpu_to_be16(0x1);
+	err = mlx5_cmd_exec(dev, &query_ctx, sizeof(query_ctx),
+				 query_out, sizeof(*query_out));
+	if (err)
+		goto query_ex;
+
+	err = mlx5_cmd_status_to_err(&query_out->hdr);
+	if (err) {
+		mlx5_core_warn(dev, "query hca cap failed, %d\n", err);
+		goto query_ex;
+	}
+
+	memcpy(&set_ctx->hca_cap, &query_out->hca_cap,
+	       sizeof(set_ctx->hca_cap));
+
+	if (prof->mask & MLX5_PROF_MASK_CMDIF_CSUM) {
+		csum = !!prof->cmdif_csum;
+		flags = be64_to_cpu(set_ctx->hca_cap.flags);
+		if (csum)
+			flags |= MLX5_DEV_CAP_FLAG_CMDIF_CSUM;
+		else
+			flags &= ~MLX5_DEV_CAP_FLAG_CMDIF_CSUM;
+
+		set_ctx->hca_cap.flags = cpu_to_be64(flags);
+	}
+
+	if (dev->profile->mask & MLX5_PROF_MASK_QP_SIZE)
+		set_ctx->hca_cap.log_max_qp = dev->profile->log_max_qp;
+
+	memset(&set_out, 0, sizeof(set_out));
+	set_ctx->hca_cap.uar_page_sz = cpu_to_be16(PAGE_SHIFT - 12);
+	set_ctx->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_SET_HCA_CAP);
+	err = mlx5_cmd_exec(dev, set_ctx, sizeof(*set_ctx),
+				 &set_out, sizeof(set_out));
+	if (err) {
+		mlx5_core_warn(dev, "set hca cap failed, %d\n", err);
+		goto query_ex;
+	}
+
+	err = mlx5_cmd_status_to_err(&set_out.hdr);
+	if (err)
+		goto query_ex;
+
+	if (!csum)
+		dev->cmd.checksum_disabled = 1;
+
+query_ex:
+	kfree(query_out);
+	kfree(set_ctx);
+
+	return err;
+}
+
+static int set_hca_ctrl(struct mlx5_core_dev *dev)
+{
+	struct mlx5_reg_host_endianess he_in;
+	struct mlx5_reg_host_endianess he_out;
+	int err;
+
+	memset(&he_in, 0, sizeof(he_in));
+	he_in.he = MLX5_SET_HOST_ENDIANNESS;
+	err = mlx5_core_access_reg(dev, &he_in,  sizeof(he_in),
+					&he_out, sizeof(he_out),
+					MLX5_REG_HOST_ENDIANNESS, 0, 1);
+	return err;
+}
+
+int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
+{
+	struct mlx5_priv *priv = &dev->priv;
+	int err;
+
+	dev->pdev = pdev;
+	pci_set_drvdata(dev->pdev, dev);
+	strncpy(priv->name, dev_name(&pdev->dev), MLX5_MAX_NAME_LEN);
+	priv->name[MLX5_MAX_NAME_LEN - 1] = 0;
+
+	mutex_init(&priv->pgdir_mutex);
+	INIT_LIST_HEAD(&priv->pgdir_list);
+	spin_lock_init(&priv->mkey_lock);
+
+	priv->dbg_root = debugfs_create_dir(dev_name(&pdev->dev), mlx5_debugfs_root);
+	if (!priv->dbg_root)
+		return -ENOMEM;
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot enable PCI device, aborting.\n");
+		goto err_dbg;
+	}
+
+	err = request_bar(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "error requesting BARs, aborting.\n");
+		goto err_disable;
+	}
+
+	pci_set_master(pdev);
+
+	err = set_dma_caps(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed setting DMA capabilities mask, aborting\n");
+		goto err_clr_master;
+	}
+
+	dev->iseg_base = pci_resource_start(dev->pdev, 0);
+	dev->iseg = ioremap(dev->iseg_base, sizeof(*dev->iseg));
+	if (!dev->iseg) {
+		err = -ENOMEM;
+		dev_err(&pdev->dev, "Failed mapping initialization segment, aborting\n");
+		goto err_clr_master;
+	}
+	dev_info(&pdev->dev, "firmware version: %d.%d.%d\n", fw_rev_maj(dev),
+		 fw_rev_min(dev), fw_rev_sub(dev));
+
+	err = mlx5_cmd_init(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed initializing command interface, aborting\n");
+		goto err_unmap;
+	}
+
+	mlx5_pagealloc_init(dev);
+	err = set_hca_ctrl(dev);
+	if (err) {
+		dev_err(&pdev->dev, "set_hca_ctrl failed\n");
+		goto err_pagealloc_cleanup;
+	}
+
+	err = handle_hca_cap(dev);
+	if (err) {
+		dev_err(&pdev->dev, "handle_hca_cap failed\n");
+		goto err_pagealloc_cleanup;
+	}
+
+	err = mlx5_satisfy_startup_pages(dev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to allocate startup pages\n");
+		goto err_pagealloc_cleanup;
+	}
+
+	err = mlx5_pagealloc_start(dev);
+	if (err) {
+		dev_err(&pdev->dev, "mlx5_pagealloc_start failed\n");
+		goto err_reclaim_pages;
+	}
+
+	err = mlx5_cmd_init_hca(dev);
+	if (err) {
+		dev_err(&pdev->dev, "init hca failed\n");
+		goto err_pagealloc_stop;
+	}
+
+	mlx5_start_health_poll(dev);
+
+	err = mlx5_cmd_query_hca_cap(dev, &dev->caps);
+	if (err) {
+		dev_err(&pdev->dev, "query hca failed\n");
+		goto err_stop_poll;
+	}
+
+	err = mlx5_cmd_query_adapter(dev);
+	if (err) {
+		dev_err(&pdev->dev, "query adapter failed\n");
+		goto err_stop_poll;
+	}
+
+	err = mlx5_enable_msix(dev);
+	if (err) {
+		dev_err(&pdev->dev, "enable msix failed\n");
+		goto err_stop_poll;
+	}
+
+	err = mlx5_eq_init(dev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to initialize eq\n");
+		goto disable_msix;
+	}
+
+	err = mlx5_alloc_uuars(dev, &priv->uuari);
+	if (err) {
+		dev_err(&pdev->dev, "Failed allocating uar, aborting\n");
+		goto err_eq_cleanup;
+	}
+
+	err = mlx5_start_eqs(dev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to start pages and async EQs\n");
+		goto err_free_uar;
+	}
+
+	MLX5_INIT_DOORBELL_LOCK(&priv->cq_uar_lock);
+
+	mlx5_init_cq_table(dev);
+	mlx5_init_qp_table(dev);
+	mlx5_init_srq_table(dev);
+
+	return 0;
+
+err_free_uar:
+	mlx5_free_uuars(dev, &priv->uuari);
+
+err_eq_cleanup:
+	mlx5_eq_cleanup(dev);
+
+disable_msix:
+	mlx5_disable_msix(dev);
+
+err_stop_poll:
+	mlx5_stop_health_poll(dev);
+	mlx5_cmd_teardown_hca(dev);
+
+err_pagealloc_stop:
+	mlx5_pagealloc_stop(dev);
+
+err_reclaim_pages:
+	mlx5_reclaim_startup_pages(dev);
+
+err_pagealloc_cleanup:
+	mlx5_pagealloc_cleanup(dev);
+	mlx5_cmd_cleanup(dev);
+
+err_unmap:
+	iounmap(dev->iseg);
+
+err_clr_master:
+	pci_clear_master(dev->pdev);
+	release_bar(dev->pdev);
+
+err_disable:
+	pci_disable_device(dev->pdev);
+
+err_dbg:
+	debugfs_remove(priv->dbg_root);
+	return err;
+}
+EXPORT_SYMBOL(mlx5_dev_init);
+
+void mlx5_dev_cleanup(struct mlx5_core_dev *dev)
+{
+	struct mlx5_priv *priv = &dev->priv;
+
+	mlx5_cleanup_srq_table(dev);
+	mlx5_cleanup_qp_table(dev);
+	mlx5_cleanup_cq_table(dev);
+	mlx5_stop_eqs(dev);
+	mlx5_free_uuars(dev, &priv->uuari);
+	mlx5_eq_cleanup(dev);
+	mlx5_disable_msix(dev);
+	mlx5_stop_health_poll(dev);
+	mlx5_cmd_teardown_hca(dev);
+	mlx5_pagealloc_stop(dev);
+	mlx5_reclaim_startup_pages(dev);
+	mlx5_pagealloc_cleanup(dev);
+	mlx5_cmd_cleanup(dev);
+	iounmap(dev->iseg);
+	pci_clear_master(dev->pdev);
+	release_bar(dev->pdev);
+	pci_disable_device(dev->pdev);
+	debugfs_remove(priv->dbg_root);
+}
+EXPORT_SYMBOL(mlx5_dev_cleanup);
+
+static int __init init(void)
+{
+	int err;
+
+	mlx5_register_debugfs();
+	mlx5_core_wq = create_singlethread_workqueue("mlx5_core_wq");
+	if (!mlx5_core_wq) {
+		err = -ENOMEM;
+		goto err_debug;
+	}
+	mlx5_health_init();
+
+	return 0;
+
+	mlx5_health_cleanup();
+err_debug:
+	mlx5_unregister_debugfs();
+	return err;
+}
+
+static void __exit cleanup(void)
+{
+	mlx5_health_cleanup();
+	destroy_workqueue(mlx5_core_wq);
+	mlx5_unregister_debugfs();
+}
+
+module_init(init);
+module_exit(cleanup);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mcg.c b/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
new file mode 100644
index 0000000..4483764
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
@@ -0,0 +1,106 @@
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
+#include <rdma/ib_verbs.h>
+#include "mlx5_core.h"
+
+struct mlx5_attach_mcg_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			qpn;
+	__be32			rsvd;
+	u8			gid[16];
+};
+
+struct mlx5_attach_mcg_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvf[8];
+};
+
+struct mlx5_detach_mcg_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			qpn;
+	__be32			rsvd;
+	u8			gid[16];
+};
+
+struct mlx5_detach_mcg_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvf[8];
+};
+
+int mlx5_core_attach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn)
+{
+	struct mlx5_attach_mcg_mbox_in in;
+	struct mlx5_attach_mcg_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ATTACH_TO_MCG);
+	memcpy(in.gid, mgid, sizeof(*mgid));
+	in.qpn = cpu_to_be32(qpn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_attach_mcg);
+
+int mlx5_core_detach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn)
+{
+	struct mlx5_detach_mcg_mbox_in in;
+	struct mlx5_detach_mcg_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DETACH_FROM_MCG);
+	memcpy(in.gid, mgid, sizeof(*mgid));
+	in.qpn = cpu_to_be32(qpn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_detach_mcg);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
new file mode 100644
index 0000000..7092490
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -0,0 +1,75 @@
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
+#ifndef __MLX5_CORE_H__
+#define __MLX5_CORE_H__
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+
+extern int mlx5_core_debug_mask;
+
+#define mlx5_core_dbg(dev, format, arg...)				\
+do {									\
+	pr_debug("%s:%s:%d:(pid %d): " format, (dev)->priv.name,	\
+		 __func__, __LINE__, current->pid, ##arg);		\
+} while (0)
+
+#define mlx5_core_dbg_mask(dev, mask, format, arg...)			       \
+do {									       \
+	if ((mask) & mlx5_core_debug_mask)				       \
+		pr_debug("%s:%s:%d:(pid %d): " format, (dev)->priv.name,       \
+			 __func__, __LINE__, current->pid, ##arg);	       \
+} while (0)
+
+#define mlx5_core_err(dev, format, arg...) \
+pr_err("%s:%s:%d:(pid %d): " format, (dev)->priv.name, __func__, __LINE__,     \
+	current->pid, ##arg)
+
+#define mlx5_core_warn(dev, format, arg...) \
+pr_warn("%s:%s:%d:(pid %d): " format, (dev)->priv.name, __func__, __LINE__,    \
+	current->pid, ##arg)
+
+enum {
+	MLX5_CMD_DATA, /* print command payload only */
+	MLX5_CMD_TIME, /* print command execution time */
+};
+
+
+int mlx5_cmd_query_hca_cap(struct mlx5_core_dev *dev,
+			   struct mlx5_caps *caps);
+int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev);
+int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
+int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
+
+#endif /* __MLX5_CORE_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mr.c b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
new file mode 100644
index 0000000..5b44e2e
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
@@ -0,0 +1,136 @@
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
+int mlx5_core_create_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+			  struct mlx5_create_mkey_mbox_in *in, int inlen)
+{
+	struct mlx5_create_mkey_mbox_out out;
+	int err;
+	u8 key;
+
+	memset(&out, 0, sizeof(out));
+	spin_lock(&dev->priv.mkey_lock);
+	key = dev->priv.mkey_key++;
+	spin_unlock(&dev->priv.mkey_lock);
+	in->seg.qpn_mkey7_0 |= cpu_to_be32(key);
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_CREATE_MKEY);
+	err = mlx5_cmd_exec(dev, in, inlen, &out, sizeof(out));
+	if (err) {
+		mlx5_core_dbg(dev, "cmd exec faile %d\n", err);
+		return err;
+	}
+
+	if (out.hdr.status) {
+		mlx5_core_dbg(dev, "status %d\n", out.hdr.status);
+		return mlx5_cmd_status_to_err(&out.hdr);
+	}
+
+	mr->key = mlx5_idx_to_mkey(be32_to_cpu(out.mkey) & 0xffffff) | key;
+	mlx5_core_dbg(dev, "out 0x%x, key 0x%x, mkey 0x%x\n", be32_to_cpu(out.mkey), key, mr->key);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_create_mkey);
+
+int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr)
+{
+	struct mlx5_destroy_mkey_mbox_in in;
+	struct mlx5_destroy_mkey_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_MKEY);
+	in.mkey = cpu_to_be32(mlx5_mkey_to_idx(mr->key));
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_destroy_mkey);
+
+int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+			 struct mlx5_query_mkey_mbox_out *out, int outlen)
+{
+	struct mlx5_destroy_mkey_mbox_in in;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(out, 0, outlen);
+
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_MKEY);
+	in.mkey = cpu_to_be32(mlx5_mkey_to_idx(mr->key));
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
+	if (err)
+		return err;
+
+	if (out->hdr.status)
+		return mlx5_cmd_status_to_err(&out->hdr);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_query_mkey);
+
+int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
+			     u32 *mkey)
+{
+	struct mlx5_query_special_ctxs_mbox_in in;
+	struct mlx5_query_special_ctxs_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_SPECIAL_CONTEXTS);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	*mkey = be32_to_cpu(out.dump_fill_mkey);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_dump_fill_mkey);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
new file mode 100644
index 0000000..10cca1a
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -0,0 +1,436 @@
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
+#include <asm-generic/kmap_types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cmd.h>
+#include "mlx5_core.h"
+
+enum {
+	MLX5_PAGES_CANT_GIVE	= 0,
+	MLX5_PAGES_GIVE		= 1,
+	MLX5_PAGES_TAKE		= 2
+};
+
+struct mlx5_pages_req {
+	struct mlx5_core_dev *dev;
+	u32	func_id;
+	s16	npages;
+	struct work_struct work;
+};
+
+struct fw_page {
+	struct rb_node	rb_node;
+	u64		addr;
+	struct page	*page;
+	u16		func_id;
+};
+
+struct mlx5_query_pages_inbox {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_query_pages_outbox {
+	struct mlx5_outbox_hdr	hdr;
+	u8			reserved[2];
+	__be16			func_id;
+	__be16			init_pages;
+	__be16			num_pages;
+};
+
+struct mlx5_manage_pages_inbox {
+	struct mlx5_inbox_hdr	hdr;
+	__be16			rsvd0;
+	__be16			func_id;
+	__be16			rsvd1;
+	__be16			num_entries;
+	u8			rsvd2[16];
+	__be64			pas[0];
+};
+
+struct mlx5_manage_pages_outbox {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd0[2];
+	__be16			num_entries;
+	u8			rsvd1[20];
+	__be64			pas[0];
+};
+
+static int insert_page(struct mlx5_core_dev *dev, u64 addr, struct page *page, u16 func_id)
+{
+	struct rb_root *root = &dev->priv.page_root;
+	struct rb_node **new = &root->rb_node;
+	struct rb_node *parent = NULL;
+	struct fw_page *nfp;
+	struct fw_page *tfp;
+
+	while (*new) {
+		parent = *new;
+		tfp = rb_entry(parent, struct fw_page, rb_node);
+		if (tfp->addr < addr)
+			new = &parent->rb_left;
+		else if (tfp->addr > addr)
+			new = &parent->rb_right;
+		else
+			return -EEXIST;
+	}
+
+	nfp = kmalloc(sizeof(*nfp), GFP_KERNEL);
+	if (!nfp)
+		return -ENOMEM;
+
+	nfp->addr = addr;
+	nfp->page = page;
+	nfp->func_id = func_id;
+
+	rb_link_node(&nfp->rb_node, parent, new);
+	rb_insert_color(&nfp->rb_node, root);
+
+	return 0;
+}
+
+static struct page *remove_page(struct mlx5_core_dev *dev, u64 addr)
+{
+	struct rb_root *root = &dev->priv.page_root;
+	struct rb_node *tmp = root->rb_node;
+	struct page *result = NULL;
+	struct fw_page *tfp;
+
+	while (tmp) {
+		tfp = rb_entry(tmp, struct fw_page, rb_node);
+		if (tfp->addr < addr) {
+			tmp = tmp->rb_left;
+		} else if (tfp->addr > addr) {
+			tmp = tmp->rb_right;
+		} else {
+			rb_erase(&tfp->rb_node, root);
+			result = tfp->page;
+			kfree(tfp);
+			break;
+		}
+	}
+
+	return result;
+}
+
+static int mlx5_cmd_query_pages(struct mlx5_core_dev *dev, u16 *func_id,
+				s16 *pages, s16 *init_pages)
+{
+	struct mlx5_query_pages_inbox	in;
+	struct mlx5_query_pages_outbox	out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_PAGES);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	if (pages)
+		*pages = be16_to_cpu(out.num_pages);
+	if (init_pages)
+		*init_pages = be16_to_cpu(out.init_pages);
+	*func_id = be16_to_cpu(out.func_id);
+
+	return err;
+}
+
+static int give_pages(struct mlx5_core_dev *dev, u16 func_id, int npages,
+		      int notify_fail)
+{
+	struct mlx5_manage_pages_inbox *in;
+	struct mlx5_manage_pages_outbox out;
+	struct page *page;
+	int inlen;
+	u64 addr;
+	int err;
+	int i;
+
+	inlen = sizeof(*in) + npages * sizeof(in->pas[0]);
+	in = vzalloc(inlen);
+	if (!in) {
+		mlx5_core_warn(dev, "vzalloc failed %d\n", inlen);
+		return -ENOMEM;
+	}
+	memset(&out, 0, sizeof(out));
+
+	for (i = 0; i < npages; i++) {
+		page = alloc_page(GFP_HIGHUSER);
+		if (!page) {
+			err = -ENOMEM;
+			mlx5_core_warn(dev, "failed to allocate page\n");
+			goto out_alloc;
+		}
+		addr = dma_map_page(&dev->pdev->dev, page, 0,
+				    PAGE_SIZE, DMA_BIDIRECTIONAL);
+		if (dma_mapping_error(&dev->pdev->dev, addr)) {
+			mlx5_core_warn(dev, "failed dma mapping page\n");
+			__free_page(page);
+			err = -ENOMEM;
+			goto out_alloc;
+		}
+		err = insert_page(dev, addr, page, func_id);
+		if (err) {
+			mlx5_core_err(dev, "failed to track allocated page\n");
+			dma_unmap_page(&dev->pdev->dev, addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
+			__free_page(page);
+			err = -ENOMEM;
+			goto out_alloc;
+		}
+		in->pas[i] = cpu_to_be64(addr);
+	}
+
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_MANAGE_PAGES);
+	in->hdr.opmod = cpu_to_be16(MLX5_PAGES_GIVE);
+	in->func_id = cpu_to_be16(func_id);
+	in->num_entries = cpu_to_be16(npages);
+	err = mlx5_cmd_exec(dev, in, inlen, &out, sizeof(out));
+	mlx5_core_dbg(dev, "err %d\n", err);
+	if (err) {
+		mlx5_core_warn(dev, "func_id 0x%x, npages %d, err %d\n", func_id, npages, err);
+		goto out_alloc;
+	}
+	dev->priv.fw_pages += npages;
+
+	if (out.hdr.status) {
+		err = mlx5_cmd_status_to_err(&out.hdr);
+		if (err) {
+			mlx5_core_warn(dev, "func_id 0x%x, npages %d, status %d\n", func_id, npages, out.hdr.status);
+			goto out_alloc;
+		}
+	}
+
+	mlx5_core_dbg(dev, "err %d\n", err);
+
+	goto out_free;
+
+out_alloc:
+	if (notify_fail) {
+		memset(in, 0, inlen);
+		memset(&out, 0, sizeof(out));
+		in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_MANAGE_PAGES);
+		in->hdr.opmod = cpu_to_be16(MLX5_PAGES_CANT_GIVE);
+		if (mlx5_cmd_exec(dev, in, sizeof(*in), &out, sizeof(out)))
+			mlx5_core_warn(dev, "\n");
+	}
+	for (i--; i >= 0; i--) {
+		addr = be64_to_cpu(in->pas[i]);
+		page = remove_page(dev, addr);
+		if (!page) {
+			mlx5_core_err(dev, "BUG: can't remove page at addr 0x%llx\n",
+				      addr);
+			continue;
+		}
+		dma_unmap_page(&dev->pdev->dev, addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
+		__free_page(page);
+	}
+
+out_free:
+	vfree(in);
+	return err;
+}
+
+static int reclaim_pages(struct mlx5_core_dev *dev, u32 func_id, int npages,
+			 int *nclaimed)
+{
+	struct mlx5_manage_pages_inbox   in;
+	struct mlx5_manage_pages_outbox *out;
+	struct page *page;
+	int num_claimed;
+	int outlen;
+	u64 addr;
+	int err;
+	int i;
+
+	memset(&in, 0, sizeof(in));
+	outlen = sizeof(*out) + npages * sizeof(out->pas[0]);
+	out = vzalloc(outlen);
+	if (!out)
+		return -ENOMEM;
+
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_MANAGE_PAGES);
+	in.hdr.opmod = cpu_to_be16(MLX5_PAGES_TAKE);
+	in.func_id = cpu_to_be16(func_id);
+	in.num_entries = cpu_to_be16(npages);
+	mlx5_core_dbg(dev, "npages %d, outlen %d\n", npages, outlen);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
+	if (err) {
+		mlx5_core_err(dev, "failed recliaming pages\n");
+		goto out_free;
+	}
+	dev->priv.fw_pages -= npages;
+
+	if (out->hdr.status) {
+		err = mlx5_cmd_status_to_err(&out->hdr);
+		goto out_free;
+	}
+
+	num_claimed = be16_to_cpu(out->num_entries);
+	if (nclaimed)
+		*nclaimed = num_claimed;
+
+	for (i = 0; i < num_claimed; i++) {
+		addr = be64_to_cpu(out->pas[i]);
+		page = remove_page(dev, addr);
+		if (!page) {
+			mlx5_core_warn(dev, "FW reported unknown DMA address 0x%llx\n", addr);
+		} else {
+			dma_unmap_page(&dev->pdev->dev, addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
+			__free_page(page);
+		}
+	}
+
+out_free:
+	vfree(out);
+	return err;
+}
+
+static void pages_work_handler(struct work_struct *work)
+{
+	struct mlx5_pages_req *req = container_of(work, struct mlx5_pages_req, work);
+	struct mlx5_core_dev *dev = req->dev;
+	int err = 0;
+
+	if (req->npages < 0)
+		err = reclaim_pages(dev, req->func_id, -1 * req->npages, NULL);
+	else if (req->npages > 0)
+		err = give_pages(dev, req->func_id, req->npages, 1);
+
+	if (err)
+		mlx5_core_warn(dev, "%s fail %d\n", req->npages < 0 ?
+			       "reclaim" : "give", err);
+
+	kfree(req);
+}
+
+void mlx5_core_req_pages_handler(struct mlx5_core_dev *dev, u16 func_id,
+				 s16 npages)
+{
+	struct mlx5_pages_req *req;
+
+	req = kzalloc(sizeof(*req), GFP_ATOMIC);
+	if (!req) {
+		mlx5_core_warn(dev, "failed to allocate pages request\n");
+		return;
+	}
+
+	req->dev = dev;
+	req->func_id = func_id;
+	req->npages = npages;
+	INIT_WORK(&req->work, pages_work_handler);
+	queue_work(dev->priv.pg_wq, &req->work);
+}
+
+int mlx5_satisfy_startup_pages(struct mlx5_core_dev *dev)
+{
+	s16 uninitialized_var(init_pages);
+	u16 uninitialized_var(func_id);
+	int err;
+
+	err = mlx5_cmd_query_pages(dev, &func_id, NULL, &init_pages);
+	if (err)
+		return err;
+
+	mlx5_core_dbg(dev, "requested %d init pages for func_id 0x%x\n", init_pages, func_id);
+
+	return give_pages(dev, func_id, init_pages, 0);
+}
+
+static int optimal_reclaimed_pages(void)
+{
+	struct mlx5_cmd_prot_block *block;
+	struct mlx5_cmd_layout *lay;
+	int ret;
+
+	ret = (sizeof(lay->in) + sizeof(block->data) -
+	       sizeof(struct mlx5_manage_pages_outbox)) / 8;
+
+	return ret;
+}
+
+int mlx5_reclaim_startup_pages(struct mlx5_core_dev *dev)
+{
+	unsigned long end = jiffies + msecs_to_jiffies(5000);
+	struct fw_page *fwp;
+	struct rb_node *p;
+	int err;
+
+	do {
+		p = rb_first(&dev->priv.page_root);
+		if (p) {
+			fwp = rb_entry(p, struct fw_page, rb_node);
+			err = reclaim_pages(dev, fwp->func_id, optimal_reclaimed_pages(), NULL);
+			if (err) {
+				mlx5_core_warn(dev, "failed reclaiming pages (%d)\n", err);
+				return err;
+			}
+		}
+		if (time_after(jiffies, end)) {
+			mlx5_core_warn(dev, "FW did not return all pages. giving up...\n");
+			break;
+		}
+	} while (p);
+
+	return 0;
+}
+
+void mlx5_pagealloc_init(struct mlx5_core_dev *dev)
+{
+	dev->priv.page_root = RB_ROOT;
+}
+
+void mlx5_pagealloc_cleanup(struct mlx5_core_dev *dev)
+{
+	/* nothing */
+}
+
+int mlx5_pagealloc_start(struct mlx5_core_dev *dev)
+{
+	dev->priv.pg_wq = create_singlethread_workqueue("mlx5_page_allocator");
+	if (!dev->priv.pg_wq)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void mlx5_pagealloc_stop(struct mlx5_core_dev *dev)
+{
+	destroy_workqueue(dev->priv.pg_wq);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pd.c b/drivers/net/ethernet/mellanox/mlx5/core/pd.c
new file mode 100644
index 0000000..790da5c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pd.c
@@ -0,0 +1,101 @@
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
+struct mlx5_alloc_pd_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+struct mlx5_alloc_pd_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	__be32			pdn;
+	u8			rsvd[4];
+};
+
+struct mlx5_dealloc_pd_mbox_in {
+	struct mlx5_inbox_hdr	hdr;
+	__be32			pdn;
+	u8			rsvd[4];
+};
+
+struct mlx5_dealloc_pd_mbox_out {
+	struct mlx5_outbox_hdr	hdr;
+	u8			rsvd[8];
+};
+
+int mlx5_core_alloc_pd(struct mlx5_core_dev *dev, u32 *pdn)
+{
+	struct mlx5_alloc_pd_mbox_in	in;
+	struct mlx5_alloc_pd_mbox_out	out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ALLOC_PD);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	*pdn = be32_to_cpu(out.pdn) & 0xffffff;
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_alloc_pd);
+
+int mlx5_core_dealloc_pd(struct mlx5_core_dev *dev, u32 pdn)
+{
+	struct mlx5_dealloc_pd_mbox_in	in;
+	struct mlx5_dealloc_pd_mbox_out	out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DEALLOC_PD);
+	in.pdn = cpu_to_be32(pdn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_core_dealloc_pd);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
new file mode 100644
index 0000000..7d352ab
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -0,0 +1,104 @@
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
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/cmd.h>
+#include "mlx5_core.h"
+
+int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
+			 int size_in, void *data_out, int size_out,
+			 u16 reg_num, int arg, int write)
+{
+	struct mlx5_access_reg_mbox_in *in = NULL;
+	struct mlx5_access_reg_mbox_out *out = NULL;
+	int err = -ENOMEM;
+
+	in = vzalloc(sizeof(*in) + size_in);
+	if (!in)
+		goto ex;
+
+	out = vzalloc(sizeof(*out) + size_out);
+	if (!out)
+		goto ex;
+
+	memcpy(in->data, data_in, size_in);
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ACCESS_REG);
+	in->hdr.opmod = cpu_to_be16(!write);
+	in->arg = cpu_to_be32(arg);
+	in->register_id = cpu_to_be16(reg_num);
+	err = mlx5_cmd_exec(dev, in, sizeof(*in) + size_in, out,
+			    sizeof(out) + size_out);
+	if (err)
+		goto ex;
+
+	if (out->hdr.status)
+		err = mlx5_cmd_status_to_err(&out->hdr);
+
+	if (!err)
+		memcpy(data_out, out->data, size_out);
+
+ex:
+	vfree(out);
+	vfree(in);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_access_reg);
+
+
+struct mlx5_reg_pcap {
+	u8			rsvd0;
+	u8			port_num;
+	u8			rsvd1[2];
+	__be32			caps_127_96;
+	__be32			caps_95_64;
+	__be32			caps_63_32;
+	__be32			caps_31_0;
+};
+
+int mlx5_set_port_caps(struct mlx5_core_dev *dev, int port_num, u32 caps)
+{
+	struct mlx5_reg_pcap in;
+	struct mlx5_reg_pcap out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	in.caps_127_96 = cpu_to_be32(caps);
+	in.port_num = port_num;
+
+	err = mlx5_core_access_reg(dev, &in, sizeof(in), &out,
+				   sizeof(out), MLX5_REG_PCAP, 0, 1);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_caps);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
new file mode 100644
index 0000000..54faf8b
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -0,0 +1,301 @@
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
+
+#include <linux/gfp.h>
+#include <linux/export.h>
+#include <linux/mlx5/cmd.h>
+#include <linux/mlx5/qp.h>
+#include <linux/mlx5/driver.h>
+
+#include "mlx5_core.h"
+
+void mlx5_qp_event(struct mlx5_core_dev *dev, u32 qpn, int event_type)
+{
+	struct mlx5_qp_table *table = &dev->priv.qp_table;
+	struct mlx5_core_qp *qp;
+
+	spin_lock(&table->lock);
+
+	qp = radix_tree_lookup(&table->tree, qpn);
+	if (qp)
+		atomic_inc(&qp->refcount);
+
+	spin_unlock(&table->lock);
+
+	if (!qp) {
+		mlx5_core_warn(dev, "Async event for bogus QP 0x%x\n", qpn);
+		return;
+	}
+
+	qp->event(qp, event_type);
+
+	if (atomic_dec_and_test(&qp->refcount))
+		complete(&qp->free);
+}
+
+int mlx5_core_create_qp(struct mlx5_core_dev *dev,
+			struct mlx5_core_qp *qp,
+			struct mlx5_create_qp_mbox_in *in,
+			int inlen)
+{
+	struct mlx5_qp_table *table = &dev->priv.qp_table;
+	struct mlx5_create_qp_mbox_out out;
+	struct mlx5_destroy_qp_mbox_in din;
+	struct mlx5_destroy_qp_mbox_out dout;
+	int err;
+
+	memset(&dout, 0, sizeof(dout));
+	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_CREATE_QP);
+
+	err = mlx5_cmd_exec(dev, in, inlen, &out, sizeof(out));
+	if (err) {
+		mlx5_core_warn(dev, "ret %d", err);
+		return err;
+	}
+
+	if (out.hdr.status) {
+		pr_warn("current num of QPs 0x%x\n", atomic_read(&dev->num_qps));
+		return mlx5_cmd_status_to_err(&out.hdr);
+	}
+
+	qp->qpn = be32_to_cpu(out.qpn) & 0xffffff;
+	mlx5_core_dbg(dev, "qpn = 0x%x\n", qp->qpn);
+
+	spin_lock_irq(&table->lock);
+	err = radix_tree_insert(&table->tree, qp->qpn, qp);
+	spin_unlock_irq(&table->lock);
+	if (err) {
+		mlx5_core_warn(dev, "err %d", err);
+		goto err_cmd;
+	}
+
+	err = mlx5_debug_qp_add(dev, qp);
+	if (err)
+		mlx5_core_dbg(dev, "failed adding QP 0x%x to debug file system\n",
+			      qp->qpn);
+
+	qp->pid = current->pid;
+	atomic_set(&qp->refcount, 1);
+	atomic_inc(&dev->num_qps);
+	init_completion(&qp->free);
+
+	return 0;
+
+err_cmd:
+	memset(&din, 0, sizeof(din));
+	memset(&dout, 0, sizeof(dout));
+	din.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_QP);
+	din.qpn = cpu_to_be32(qp->qpn);
+	mlx5_cmd_exec(dev, &din, sizeof(din), &out, sizeof(dout));
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_create_qp);
+
+int mlx5_core_destroy_qp(struct mlx5_core_dev *dev,
+			 struct mlx5_core_qp *qp)
+{
+	struct mlx5_destroy_qp_mbox_in in;
+	struct mlx5_destroy_qp_mbox_out out;
+	struct mlx5_qp_table *table = &dev->priv.qp_table;
+	unsigned long flags;
+	int err;
+
+	mlx5_debug_qp_remove(dev, qp);
+
+	spin_lock_irqsave(&table->lock, flags);
+	radix_tree_delete(&table->tree, qp->qpn);
+	spin_unlock_irqrestore(&table->lock, flags);
+
+	if (atomic_dec_and_test(&qp->refcount))
+		complete(&qp->free);
+	wait_for_completion(&qp->free);
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_QP);
+	in.qpn = cpu_to_be32(qp->qpn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		return mlx5_cmd_status_to_err(&out.hdr);
+
+	atomic_dec(&dev->num_qps);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_destroy_qp);
+
+int mlx5_core_qp_modify(struct mlx5_core_dev *dev, enum mlx5_qp_state cur_state,
+			enum mlx5_qp_state new_state,
+			struct mlx5_modify_qp_mbox_in *in, int sqd_event,
+			struct mlx5_core_qp *qp)
+{
+	static const u16 optab[MLX5_QP_NUM_STATE][MLX5_QP_NUM_STATE] = {
+		[MLX5_QP_STATE_RST] = {
+			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
+			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
+			[MLX5_QP_STATE_INIT]	= MLX5_CMD_OP_RST2INIT_QP,
+		},
+		[MLX5_QP_STATE_INIT]  = {
+			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
+			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
+			[MLX5_QP_STATE_INIT]	= MLX5_CMD_OP_INIT2INIT_QP,
+			[MLX5_QP_STATE_RTR]	= MLX5_CMD_OP_INIT2RTR_QP,
+		},
+		[MLX5_QP_STATE_RTR]   = {
+			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
+			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
+			[MLX5_QP_STATE_RTS]	= MLX5_CMD_OP_RTR2RTS_QP,
+		},
+		[MLX5_QP_STATE_RTS]   = {
+			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
+			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
+			[MLX5_QP_STATE_RTS]	= MLX5_CMD_OP_RTS2RTS_QP,
+			[MLX5_QP_STATE_SQD]	= MLX5_CMD_OP_RTS2SQD_QP,
+		},
+		[MLX5_QP_STATE_SQD] = {
+			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
+			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
+			[MLX5_QP_STATE_RTS]	= MLX5_CMD_OP_SQD2RTS_QP,
+			[MLX5_QP_STATE_SQD]	= MLX5_CMD_OP_SQD2SQD_QP,
+		},
+		[MLX5_QP_STATE_SQER] = {
+			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
+			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
+			[MLX5_QP_STATE_RTS]	= MLX5_CMD_OP_SQERR2RTS_QP,
+		},
+		[MLX5_QP_STATE_ERR] = {
+			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
+			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
+		}
+	};
+
+	struct mlx5_modify_qp_mbox_out out;
+	int err = 0;
+	u16 op;
+
+	if (cur_state >= MLX5_QP_NUM_STATE || new_state >= MLX5_QP_NUM_STATE ||
+	    !optab[cur_state][new_state])
+		return -EINVAL;
+
+	memset(&out, 0, sizeof(out));
+	op = optab[cur_state][new_state];
+	in->hdr.opcode = cpu_to_be16(op);
+	in->qpn = cpu_to_be32(qp->qpn);
+	err = mlx5_cmd_exec(dev, in, sizeof(*in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	return mlx5_cmd_status_to_err(&out.hdr);
+}
+EXPORT_SYMBOL_GPL(mlx5_core_qp_modify);
+
+void mlx5_init_qp_table(struct mlx5_core_dev *dev)
+{
+	struct mlx5_qp_table *table = &dev->priv.qp_table;
+
+	spin_lock_init(&table->lock);
+	INIT_RADIX_TREE(&table->tree, GFP_ATOMIC);
+	mlx5_qp_debugfs_init(dev);
+}
+
+void mlx5_cleanup_qp_table(struct mlx5_core_dev *dev)
+{
+	mlx5_qp_debugfs_cleanup(dev);
+}
+
+int mlx5_core_qp_query(struct mlx5_core_dev *dev, struct mlx5_core_qp *qp,
+		       struct mlx5_query_qp_mbox_out *out, int outlen)
+{
+	struct mlx5_query_qp_mbox_in in;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(out, 0, outlen);
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_QP);
+	in.qpn = cpu_to_be32(qp->qpn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
+	if (err)
+		return err;
+
+	if (out->hdr.status)
+		return mlx5_cmd_status_to_err(&out->hdr);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_qp_query);
+
+int mlx5_core_xrcd_alloc(struct mlx5_core_dev *dev, u32 *xrcdn)
+{
+	struct mlx5_alloc_xrcd_mbox_in in;
+	struct mlx5_alloc_xrcd_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ALLOC_XRCD);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+	else
+		*xrcdn = be32_to_cpu(out.xrcdn);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_xrcd_alloc);
+
+int mlx5_core_xrcd_dealloc(struct mlx5_core_dev *dev, u32 xrcdn)
+{
+	struct mlx5_dealloc_xrcd_mbox_in in;
+	struct mlx5_dealloc_xrcd_mbox_out out;
+	int err;
+
+	memset(&in, 0, sizeof(in));
+	memset(&out, 0, sizeof(out));
+	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DEALLOC_XRCD);
+	in.xrcdn = cpu_to_be32(xrcdn);
+	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	if (err)
+		return err;
+
+	if (out.hdr.status)
+		err = mlx5_cmd_status_to_err(&out.hdr);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_xrcd_dealloc);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
