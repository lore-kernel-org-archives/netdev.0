From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 11/25 v2] mlx4_core: per-function capabilities
Date: Fri, 06 Nov 2009 05:09:01 +0200
Message-ID: <4AF3934D.5000402@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>

The master function builds a HW profile, and manages all resources.
Other functions query the master for function-specific capabilities.
EQs, MSI-X vectors, and UARs are statically divided among all functions,
while other resources are dynamically assigned later upon request.

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/cmd.c      |    9 +++++
 drivers/net/mlx4/fw.c       |   78 +++++++++++++++++++++++++++++++++++++++++-
 drivers/net/mlx4/fw.h       |    4 ++
 drivers/net/mlx4/main.c     |   70 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/mlx4/mlx4.h     |    4 ++-
 drivers/net/mlx4/profile.c  |   26 ++++++++++++--
 include/linux/mlx4/cmd.h    |    1 +
 include/linux/mlx4/device.h |    3 ++
 8 files changed, 187 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 485e976..d68d0e1 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -39,6 +39,7 @@
 #include <asm/io.h>
 
 #include "mlx4.h"
+#include "fw.h"
 
 #define CMD_POLL_TOKEN 0xffff
 
@@ -532,6 +533,14 @@ static struct mlx4_cmd_info {
 		.wrapper = NULL
 	},
 	{
+		.opcode = MLX4_CMD_QUERY_SLAVE_CAP,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.verify = NULL,
+		.wrapper = mlx4_QUERY_SLAVE_CAP_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_QUERY_ADAPTER,
 		.has_inbox = false,
 		.has_outbox = true,
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 87eb2d4..60889d3 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -143,6 +143,76 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *v
 					   MLX4_CMD_TIME_CLASS_B);
 }
 
+int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						       struct mlx4_cmd_mailbox *inbox,
+						       struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_caps *caps = outbox->buf;
+	int i;
+
+	memcpy(caps, &dev->caps, sizeof *caps);
+
+	/* CX1: blue-flame not supported in vfs */
+	caps->bf_reg_size = 0;
+	caps->bf_regs_per_page = 0;
+
+	/* CX1:
+	 * On ingress, slave0 gets full ownership over qp1, and demultiplexes GSI mads
+	 * on behalf of other slaves.
+	 * On egress, slave>0 must tunnel their GSI mads for validation by the qp1 owner */
+	if (slave) {
+		caps->sqp_demux = 0;
+		for (i = 1; i <= dev->caps.num_ports; ++i) {
+			caps->gid_table_len[i] = 1;
+			caps->pkey_table_len[i] = 1;
+		}
+	} else {
+		caps->sqp_demux = dev->num_slaves;
+		for (i = 1; i <= dev->caps.num_ports; ++i) {
+			caps->gid_table_len[i] = dev->num_slaves;
+			caps->pkey_table_len[i] = 1;
+		}
+	}
+
+	/* Slave functions allocate themselves EQs, UARs, and PDs.
+	 * - num is the maximum resource index
+	 * - reserved is the minimum resource index */
+	caps->num_eqs = dev->caps.reserved_eqs + MLX4_MFUNC_EQ_NUM * (slave + 2);
+	caps->reserved_eqs = dev->caps.reserved_eqs + MLX4_MFUNC_EQ_NUM * (slave + 1);
+	caps->num_uars = dev->caps.num_uars * (slave + 1);
+	caps->reserved_uars = max_t(int, dev->caps.num_uars * slave, dev->caps.reserved_uars);
+
+	/* PDs have the same range in every guest; the distinction is in the msbs,
+	 * which contains the guest ID (vf + 1) */
+	caps->pd_base = slave + 1;
+
+	/* All other resources are allocated by the master, but we still report
+	 * 'num' and 'reserved' capabilities as follows:
+	 * - num remains the maximum resource index
+	 * - 'num - reserved' is the total available objects of a resource, but
+	 *   resource indices may be less than 'reserved'
+	 * TODO: set per-resource quotas */
+	return 0;
+}
+
+int mlx4_QUERY_SLAVE_CAP(struct mlx4_dev *dev, struct mlx4_caps *caps)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_QUERY_SLAVE_CAP,
+			   MLX4_CMD_TIME_CLASS_A);
+	if (!err)
+		memcpy(caps, mailbox->buf, sizeof *caps);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -405,9 +475,13 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	 * Each UAR has 4 EQ doorbells; so if a UAR is reserved, then
 	 * we can't use any EQs whose doorbell falls on that page,
 	 * even if the EQ itself isn't reserved.
+	 * CX1: in multi-function mode, EQ doorbells are virtualized so the whole EQ
+	 * range is available: the master and each of the slaves get 4 EQ doorbells
+	 * starting from the first non-reserved EQ.
 	 */
-	dev_cap->reserved_eqs = max(dev_cap->reserved_uars * 4,
-				    dev_cap->reserved_eqs);
+	if (!mlx4_is_mfunc(dev))
+		dev_cap->reserved_eqs = max(dev_cap->reserved_uars * 4,
+					    dev_cap->reserved_eqs);
 
 	mlx4_dbg(dev, "Max ICM size %lld MB\n",
 		 (unsigned long long) dev_cap->max_icm_sz >> 20);
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index 526d7f3..d066c69 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -160,6 +160,10 @@ struct mlx4_set_ib_param {
 };
 
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap);
+int mlx4_QUERY_SLAVE_CAP(struct mlx4_dev *dev, struct mlx4_caps *caps);
+int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+						    struct mlx4_cmd_mailbox *inbox,
+						    struct mlx4_cmd_mailbox *outbox);
 int mlx4_MAP_FA(struct mlx4_dev *dev, struct mlx4_icm *icm);
 int mlx4_UNMAP_FA(struct mlx4_dev *dev);
 int mlx4_RUN_FW(struct mlx4_dev *dev);
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 291a505..4edc8d7 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -141,6 +141,7 @@ static void mlx4_set_port_mask(struct mlx4_dev *dev)
 		if (dev->caps.port_type[i] == MLX4_PORT_TYPE_IB)
 			dev->caps.port_mask |= 1 << (i - 1);
 }
+
 static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
 	int err;
@@ -185,6 +186,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.supported_type[i] = dev_cap->supported_port_types[i];
 	}
 
+	dev->caps.uar_page_size	     = PAGE_SIZE;
 	dev->caps.num_uars	     = dev_cap->uar_size / PAGE_SIZE;
 	dev->caps.local_ca_ack_delay = dev_cap->local_ca_ack_delay;
 	dev->caps.bf_reg_size	     = dev_cap->bf_reg_size;
@@ -211,7 +213,9 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.reserved_mtts	     = DIV_ROUND_UP(dev_cap->reserved_mtts,
 						    dev->caps.mtts_per_seg);
 	dev->caps.reserved_mrws	     = dev_cap->reserved_mrws;
-	dev->caps.reserved_uars	     = dev_cap->reserved_uars;
+
+	/* The first 128 UARs are used for EQ doorbells */
+	dev->caps.reserved_uars	     = max_t(int, 128, dev_cap->reserved_uars);
 	dev->caps.reserved_pds	     = dev_cap->reserved_pds;
 	dev->caps.mtt_entry_sz	     = dev->caps.mtts_per_seg * dev_cap->mtt_entry_sz;
 	dev->caps.max_msg_sz         = dev_cap->max_msg_sz;
@@ -265,6 +269,70 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_ADDR] +
 		dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_EXCH];
 
+	/* CX1: vf0 takes role of GSI multiplexing instead of master */
+	dev->caps.sqp_demux = 0;
+	return 0;
+}
+
+static int mlx4_slave_cap(struct mlx4_dev *dev)
+{
+	int err;
+	u32 page_size;
+
+	err = mlx4_QUERY_SLAVE_CAP(dev, &dev->caps);
+	if (err)
+		return err;
+
+	page_size = ~dev->caps.page_size_cap + 1;
+	mlx4_warn(dev, "HCA minimum page size:%d\n", page_size);
+	if (page_size > PAGE_SIZE) {
+		mlx4_err(dev, "HCA minimum page size of %d bigger than "
+			 "kernel PAGE_SIZE of %ld, aborting.\n",
+			 page_size, PAGE_SIZE);
+		return -ENODEV;
+	}
+
+	/* TODO: relax this assumption */
+	if (dev->caps.uar_page_size != PAGE_SIZE) {
+		mlx4_err(dev, "UAR size:%d != kernel PAGE_SIZE of %ld\n",
+			 dev->caps.uar_page_size, PAGE_SIZE);
+		return -ENODEV;
+	}
+
+	if (dev->caps.num_ports > MLX4_MAX_PORTS) {
+		mlx4_err(dev, "HCA has %d ports, but we only support %d, "
+			 "aborting.\n", dev->caps.num_ports, MLX4_MAX_PORTS);
+		return -ENODEV;
+	}
+
+	if (dev->caps.uar_page_size * (dev->caps.num_uars -
+				       dev->caps.reserved_uars) >
+				       pci_resource_len(dev->pdev, 2)) {
+		mlx4_err(dev, "HCA reported UAR region size of 0x%x bigger than "
+			 "PCI resource 2 size of 0x%llx, aborting.\n",
+			 dev->caps.uar_page_size * dev->caps.num_uars,
+			 (unsigned long long) pci_resource_len(dev->pdev, 2));
+		return -ENODEV;
+	}
+
+	/* Adjust eq number */
+	if (dev->caps.num_eqs - dev->caps.reserved_eqs > num_possible_cpus() + 1)
+		dev->caps.num_eqs = dev->caps.reserved_eqs + num_possible_cpus() + 1;
+
+#if 0
+	mlx4_warn(dev, "sqp_demux:%d\n", dev->caps.sqp_demux);
+	mlx4_warn(dev, "num_uars:%d reserved_uars:%d uar region:0x%x bar2:0x%llx\n",
+					  dev->caps.num_uars, dev->caps.reserved_uars,
+					  dev->caps.uar_page_size * dev->caps.num_uars,
+					  pci_resource_len(dev->pdev, 2));
+	mlx4_warn(dev, "num_eqs:%d reserved_eqs:%d\n", dev->caps.num_eqs,
+						       dev->caps.reserved_eqs);
+	mlx4_warn(dev, "num_pds:%d reserved_pds:%d slave_pd_shift:%d pd_base:%d\n",
+							dev->caps.num_pds,
+							dev->caps.reserved_pds,
+							dev->caps.slave_pd_shift,
+							dev->caps.pd_base);
+#endif
 	return 0;
 }
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index e2d80c6..0686856 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -69,7 +69,8 @@ enum {
 };
 
 enum {
-	MLX4_NUM_PDS		= 1 << 15
+	MLX4_NUM_PDS		= 1 << 15,
+	MLX4_SLAVE_PD_SHIFT	= 17, /* the 7 msbs encode the slave id */
 };
 
 enum {
@@ -112,6 +113,7 @@ enum mlx4_alloc_mode {
 
 enum {
 	MLX4_MFUNC_MAX		= 64,
+	MLX4_MFUNC_EQ_NUM	= 4,
 	MLX4_MFUNC_MAX_EQES     = 8,
 	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
 };
diff --git a/drivers/net/mlx4/profile.c b/drivers/net/mlx4/profile.c
index ca25b9d..f6197e9 100644
--- a/drivers/net/mlx4/profile.c
+++ b/drivers/net/mlx4/profile.c
@@ -105,9 +105,19 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	profile[MLX4_RES_AUXC].num    = request->num_qp;
 	profile[MLX4_RES_SRQ].num     = request->num_srq;
 	profile[MLX4_RES_CQ].num      = request->num_cq;
-	profile[MLX4_RES_EQ].num      = min_t(unsigned, dev_cap->max_eqs,
-					      dev_cap->reserved_eqs +
-					      num_possible_cpus() + 1);
+	if (mlx4_is_master(dev)) {
+		profile[MLX4_RES_EQ].num = dev_cap->reserved_eqs +
+					   MLX4_MFUNC_EQ_NUM *
+					   (dev->num_slaves + 1);
+		if (profile[MLX4_RES_EQ].num > dev_cap->max_eqs) {
+			mlx4_warn(dev, "Not enough eqs for:%ld slave functions\n", dev->num_slaves);
+			kfree(profile);
+			return -ENOMEM;
+		}
+	} else
+		profile[MLX4_RES_EQ].num = min_t(unsigned, dev_cap->max_eqs,
+						 dev_cap->reserved_eqs +
+						 num_possible_cpus() + 1);
 	profile[MLX4_RES_DMPT].num    = request->num_mpt;
 	profile[MLX4_RES_CMPT].num    = MLX4_NUM_CMPTS;
 	profile[MLX4_RES_MTT].num     = request->num_mtt;
@@ -196,7 +206,13 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 			init_hca->log_num_cqs = profile[i].log_num;
 			break;
 		case MLX4_RES_EQ:
-			dev->caps.num_eqs     = profile[i].num;
+			if (mlx4_is_master(dev)) {
+				dev->caps.num_eqs = dev_cap->reserved_eqs +
+						    min_t(unsigned,
+							  MLX4_MFUNC_EQ_NUM,
+							  num_possible_cpus() + 1);
+			} else
+				dev->caps.num_eqs     = profile[i].num;
 			init_hca->eqc_base    = profile[i].start;
 			init_hca->log_num_eqs = profile[i].log_num;
 			break;
@@ -232,6 +248,8 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	 * of the HCA profile anyway.
 	 */
 	dev->caps.num_pds = MLX4_NUM_PDS;
+	dev->caps.slave_pd_shift = MLX4_SLAVE_PD_SHIFT;
+	dev->caps.pd_base = 0;
 
 	kfree(profile);
 	return total_size;
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 8444b89..99145d4 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -128,6 +128,7 @@ enum {
 	MLX4_CMD_ALLOC_RES	 = 0x50,
 	MLX4_CMD_FREE_RES	 = 0x51,
 	MLX4_CMD_GET_EVENT	 = 0x52,
+	MLX4_CMD_QUERY_SLAVE_CAP = 0x53,
 	MLX4_CMD_MCAST_ATTACH	 = 0x54,
 	MLX4_CMD_GET_SLAVE_SQP	 = 0x55,
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b20c8d8..4b9091a 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -192,6 +192,7 @@ struct mlx4_caps {
 	int			pkey_table_len[MLX4_MAX_PORTS + 1];
 	int			local_ca_ack_delay;
 	int			num_uars;
+	int			uar_page_size;
 	int			bf_reg_size;
 	int			bf_regs_per_page;
 	int			max_sq_sg;
@@ -226,6 +227,8 @@ struct mlx4_caps {
 	int			num_qp_per_mgm;
 	int			num_pds;
 	int			reserved_pds;
+	int			slave_pd_shift;
+	int			pd_base;
 	int			mtt_entry_sz;
 	u32			max_msg_sz;
 	u32			page_size_cap;
-- 
1.5.3.7

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
