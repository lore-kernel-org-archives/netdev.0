From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V0 06/21] mlx4_core: Added FW commands and their
 wrappers for supporting SRIOV
Date: Fri, 2 Dec 2011 12:17:16 +0200
Message-ID: <4ED8A5AC.4080401@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>

The following commands are added here:
1. QUERY_FUNC_CAP and its wrapper.  This function is used by VFs when
   they start up to receive configuration information from the PF, such
   as resource quotas for this VF, which ports should be used (currently
   two), what protocol is running on the port (currently Ethernet ONLY,
   or port not active).

2. QUERY_PORT and its wrapper. Previously, this FW command was invoked directly
   by the ETH driver (en_port.c) using mlx4_cmd_box. Virtualization is now
   required here (the VF's MAC address must be substituted for the PFs
   MAC address returned by the FW). We changed the invocation
   in the ETH driver to use mlx4_QUERY_PORT, and added the wrapper.

3. QUERY_HCA. Used by the VF to determine how the HCA was initialized.
   For now, we need only the multicast table member entry size
   (log2_mc_table_entry_sz, in the ConnectX PRM).  No wrapper is needed
   here, because the data may be passed as is to the VF without modification).

   In this command, we have added a GLOBAL_CAPS field for passing required
   configuration information from FW to a VF (this field is to allow safely
                   adding new SRIOV capabilities which require support in VF drivers, too).
   Bits will set here by FW in response to PF-driver configuration commands which
   will activate as yet undefined new SRIOV features. The VF will test to see that
   all required capabilities indicated by this field are supported (i.e., if a bit
   is set and the VF driver does not recognize that bit, it must abort
   its initialization).  Currently, no bits are set.

4. Added a CLOSE_PORT wrapper.  The PF context needs to keep track of how many VF contexts
   have the port open.  The PF context will not actually issue the FW close port command
   until the last port user issues a CLOSE_PORT request.

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |  281 +++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.h   |   23 +++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |   20 ++
 3 files changed, 324 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 3586a5b..0a19112 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -32,6 +32,7 @@
  * SOFTWARE.
  */
 
+#include <linux/etherdevice.h>
 #include <linux/mlx4/cmd.h>
 #include <linux/module.h>
 #include <linux/cache.h>
@@ -145,6 +146,172 @@ int mlx4_MOD_STAT_CFG(struct mlx4_dev *dev, struct mlx4_mod_stat_cfg *cfg)
 	return err;
 }
 
+int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
+				struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox,
+				struct mlx4_cmd_info *cmd)
+{
+	u8	field;
+	u32	size;
+	int	err = 0;
+
+#define QUERY_FUNC_CAP_FLAGS_OFFSET		0x0
+#define QUERY_FUNC_CAP_NUM_PORTS_OFFSET		0x1
+#define QUERY_FUNC_CAP_FUNCTION_OFFSET		0x3
+#define QUERY_FUNC_CAP_QP_QUOTA_OFFSET		0x10
+#define QUERY_FUNC_CAP_CQ_QUOTA_OFFSET		0x14
+#define QUERY_FUNC_CAP_SRQ_QUOTA_OFFSET		0x18
+#define QUERY_FUNC_CAP_MPT_QUOTA_OFFSET		0x20
+#define QUERY_FUNC_CAP_MTT_QUOTA_OFFSET		0x24
+#define QUERY_FUNC_CAP_MCG_QUOTA_OFFSET		0x28
+#define QUERY_FUNC_CAP_MAX_EQ_OFFSET		0x2c
+#define QUERY_FUNC_CAP_RESERVED_EQ_OFFSET	0X30
+
+#define QUERY_FUNC_CAP_PHYS_PORT_OFFSET		0x3
+#define QUERY_FUNC_CAP_ETH_PROPS_OFFSET		0xc
+
+	if (vhcr->op_modifier == 1) {
+		field = vhcr->in_modifier;
+		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_PHYS_PORT_OFFSET);
+
+		field = 0; /* ensure fvl bit is not set */
+		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_ETH_PROPS_OFFSET);
+	} else if (vhcr->op_modifier == 0) {
+		field = 1 << 7; /* enable only ethernet interface */
+		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FLAGS_OFFSET);
+
+		field = slave;
+		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_FUNCTION_OFFSET);
+
+		field = dev->caps.num_ports;
+		MLX4_PUT(outbox->buf, field, QUERY_FUNC_CAP_NUM_PORTS_OFFSET);
+
+		size = dev->caps.num_qps;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_QP_QUOTA_OFFSET);
+
+		size = dev->caps.num_srqs;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_SRQ_QUOTA_OFFSET);
+
+		size = dev->caps.num_cqs;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_CQ_QUOTA_OFFSET);
+
+		size = dev->caps.num_eqs;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MAX_EQ_OFFSET);
+
+		size = dev->caps.reserved_eqs;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_RESERVED_EQ_OFFSET);
+
+		size = dev->caps.num_mpts;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MPT_QUOTA_OFFSET);
+
+		size = dev->caps.num_mtt_segs * dev->caps.mtts_per_seg;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MTT_QUOTA_OFFSET);
+
+		size = dev->caps.num_mgms + dev->caps.num_amgms;
+		MLX4_PUT(outbox->buf, size, QUERY_FUNC_CAP_MCG_QUOTA_OFFSET);
+
+	} else
+		err = -EINVAL;
+
+	return err;
+}
+
+int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, struct mlx4_func_cap *func_cap)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	u32			*outbox;
+	u8			field;
+	u32			size;
+	int			i;
+	int			err = 0;
+
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_QUERY_FUNC_CAP,
+			   MLX4_CMD_TIME_CLASS_A, 0);
+	if (err)
+		goto out;
+
+	outbox = mailbox->buf;
+
+	MLX4_GET(field, outbox, QUERY_FUNC_CAP_FLAGS_OFFSET);
+	if (!(field & (1 << 7))) {
+		mlx4_err(dev, "The host doesn't support eth interface\n");
+		err = -EPROTONOSUPPORT;
+		goto out;
+	}
+
+	MLX4_GET(field, outbox, QUERY_FUNC_CAP_FUNCTION_OFFSET);
+	func_cap->function = field;
+
+	MLX4_GET(field, outbox, QUERY_FUNC_CAP_NUM_PORTS_OFFSET);
+	func_cap->num_ports = field;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_QP_QUOTA_OFFSET);
+	func_cap->qp_quota = size & 0xFFFFFF;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_SRQ_QUOTA_OFFSET);
+	func_cap->srq_quota = size & 0xFFFFFF;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_CQ_QUOTA_OFFSET);
+	func_cap->cq_quota = size & 0xFFFFFF;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_MAX_EQ_OFFSET);
+	func_cap->max_eq = size & 0xFFFFFF;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_RESERVED_EQ_OFFSET);
+	func_cap->reserved_eq = size & 0xFFFFFF;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_MPT_QUOTA_OFFSET);
+	func_cap->mpt_quota = size & 0xFFFFFF;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_MTT_QUOTA_OFFSET);
+	func_cap->mtt_quota = size & 0xFFFFFF;
+
+	MLX4_GET(size, outbox, QUERY_FUNC_CAP_MCG_QUOTA_OFFSET);
+	func_cap->mcg_quota = size & 0xFFFFFF;
+
+	for (i = 1; i <= func_cap->num_ports; ++i) {
+		err = mlx4_cmd_box(dev, 0, mailbox->dma, i, 1,
+				   MLX4_CMD_QUERY_FUNC_CAP,
+				   MLX4_CMD_TIME_CLASS_A, 0);
+		if (err)
+			goto out;
+
+		MLX4_GET(field, outbox, QUERY_FUNC_CAP_ETH_PROPS_OFFSET);
+		if (field & (1 << 7)) {
+			mlx4_err(dev, "VLAN is enforced on this port\n");
+			err = -EPROTONOSUPPORT;
+			goto out;
+		}
+
+		if (field & (1 << 6)) {
+			mlx4_err(dev, "Force mac is enabled on this port\n");
+			err = -EPROTONOSUPPORT;
+			goto out;
+		}
+
+		MLX4_GET(field, outbox, QUERY_FUNC_CAP_PHYS_PORT_OFFSET);
+		func_cap->physical_port[i] = field;
+	}
+
+	/* All other resources are allocated by the master, but we still report
+	 * 'num' and 'reserved' capabilities as follows:
+	 * - num remains the maximum resource index
+	 * - 'num - reserved' is the total available objects of a resource, but
+	 *   resource indices may be less than 'reserved'
+	 * TODO: set per-resource quotas */
+
+out:
+	mlx4_free_cmd_mailbox(dev, mailbox);
+
+	return err;
+}
+
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -471,6 +638,52 @@ out:
 	return err;
 }
 
+int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
+			    struct mlx4_vhcr *vhcr,
+			    struct mlx4_cmd_mailbox *inbox,
+			    struct mlx4_cmd_mailbox *outbox,
+			    struct mlx4_cmd_info *cmd)
+{
+	u64 def_mac;
+	u8 port_type;
+	int err;
+
+	err = mlx4_cmd_box(dev, 0, outbox->dma, vhcr->in_modifier, 0,
+			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B, 1);
+
+	if (!err && dev->caps.function != slave) {
+		/* set slave default_mac address */
+		MLX4_GET(def_mac, outbox->buf, QUERY_PORT_MAC_OFFSET);
+		def_mac += slave << 8;
+		MLX4_PUT(outbox->buf, def_mac, QUERY_PORT_MAC_OFFSET);
+
+		/* get port type - currently only eth is enabled */
+		MLX4_GET(port_type, outbox->buf,
+			 QUERY_PORT_SUPPORTED_TYPE_OFFSET);
+
+		/* disable ib */
+		port_type &= 0xFE;
+
+		/* check eth is enabled for this port */
+		if (!(port_type & 2))
+			mlx4_dbg(dev, "QUERY PORT: eth not supported by host");
+
+		MLX4_PUT(outbox->buf, port_type,
+			 QUERY_PORT_SUPPORTED_TYPE_OFFSET);
+	}
+
+	return err;
+}
+
+static int mlx4_QUERY_PORT(struct mlx4_dev *dev, void *ptr, u8 port)
+{
+	struct mlx4_cmd_mailbox *outbox = ptr;
+
+	return mlx4_cmd_box(dev, 0, outbox->dma, port, 0,
+			    MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B, 0);
+}
+EXPORT_SYMBOL_GPL(mlx4_QUERY_PORT);
+
 int mlx4_map_cmd(struct mlx4_dev *dev, u16 op, struct mlx4_icm *icm, u64 virt)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -583,6 +796,7 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 
 #define QUERY_FW_OUT_SIZE             0x100
 #define QUERY_FW_VER_OFFSET            0x00
+#define QUERY_FW_PPF_ID		       0x09
 #define QUERY_FW_CMD_IF_REV_OFFSET     0x0a
 #define QUERY_FW_MAX_CMD_OFFSET        0x0f
 #define QUERY_FW_ERR_START_OFFSET      0x30
@@ -593,6 +807,9 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 #define QUERY_FW_CLR_INT_BASE_OFFSET   0x20
 #define QUERY_FW_CLR_INT_BAR_OFFSET    0x28
 
+#define QUERY_FW_COMM_BASE_OFFSET      0x40
+#define QUERY_FW_COMM_BAR_OFFSET       0x48
+
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
@@ -612,6 +829,9 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 		((fw_ver & 0xffff0000ull) >> 16) |
 		((fw_ver & 0x0000ffffull) << 16);
 
+	MLX4_GET(lg, outbox, QUERY_FW_PPF_ID);
+	dev->caps.function = lg;
+
 	MLX4_GET(cmd_if_rev, outbox, QUERY_FW_CMD_IF_REV_OFFSET);
 	if (cmd_if_rev < MLX4_COMMAND_INTERFACE_MIN_REV ||
 	    cmd_if_rev > MLX4_COMMAND_INTERFACE_MAX_REV) {
@@ -653,6 +873,11 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 	MLX4_GET(fw->clr_int_bar,  outbox, QUERY_FW_CLR_INT_BAR_OFFSET);
 	fw->clr_int_bar = (fw->clr_int_bar >> 6) * 2;
 
+	MLX4_GET(fw->comm_base, outbox, QUERY_FW_COMM_BASE_OFFSET);
+	MLX4_GET(fw->comm_bar,  outbox, QUERY_FW_COMM_BAR_OFFSET);
+	fw->comm_bar = (fw->comm_bar >> 6) * 2;
+	mlx4_dbg(dev, "Communication vector bar:%d offset:0x%llx\n",
+		 fw->comm_bar, fw->comm_base);
 	mlx4_dbg(dev, "FW size %d KB\n", fw->fw_pages >> 2);
 
 	/*
@@ -747,6 +972,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 #define	 INIT_HCA_LOG_SRQ_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x2f)
 #define	 INIT_HCA_CQC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x30)
 #define	 INIT_HCA_LOG_CQ_OFFSET		 (INIT_HCA_QPC_OFFSET + 0x37)
+#define	 INIT_HCA_EQE_CQE_OFFSETS	 (INIT_HCA_QPC_OFFSET + 0x38)
 #define	 INIT_HCA_ALTC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x40)
 #define	 INIT_HCA_AUXC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x50)
 #define	 INIT_HCA_EQC_BASE_OFFSET	 (INIT_HCA_QPC_OFFSET + 0x60)
@@ -847,6 +1073,35 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	return err;
 }
 
+int mlx4_INIT_PORT_wrapper(struct mlx4_dev *dev, int slave,
+			   struct mlx4_vhcr *vhcr,
+			   struct mlx4_cmd_mailbox *inbox,
+			   struct mlx4_cmd_mailbox *outbox,
+			   struct mlx4_cmd_info *cmd)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port = vhcr->in_modifier;
+	int err;
+
+	if (priv->mfunc.master.slave_state[slave].init_port_mask & (1 << port))
+		return 0;
+
+	if (dev->caps.port_mask[port] == MLX4_PORT_TYPE_IB)
+		return -ENODEV;
+
+	/* Enable port only if it was previously disabled */
+	if (!priv->mfunc.master.init_port_ref[port]) {
+		err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_INIT_PORT,
+			       MLX4_CMD_TIME_CLASS_A, 1);
+		if (err)
+			return err;
+		priv->mfunc.master.slave_state[slave].init_port_mask |=
+			(1 << port);
+	}
+	++priv->mfunc.master.init_port_ref[port];
+	return 0;
+}
+
 int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -901,6 +1156,32 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 }
 EXPORT_SYMBOL_GPL(mlx4_INIT_PORT);
 
+int mlx4_CLOSE_PORT_wrapper(struct mlx4_dev *dev, int slave,
+			    struct mlx4_vhcr *vhcr,
+			    struct mlx4_cmd_mailbox *inbox,
+			    struct mlx4_cmd_mailbox *outbox,
+			    struct mlx4_cmd_info *cmd)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port = vhcr->in_modifier;
+	int err;
+
+	if (!(priv->mfunc.master.slave_state[slave].init_port_mask &
+	    (1 << port)))
+		return 0;
+
+	if (dev->caps.port_mask[port] == MLX4_PORT_TYPE_IB)
+		return -ENODEV;
+	if (priv->mfunc.master.init_port_ref[port] == 1) {
+		err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000, 1);
+		if (err)
+			return err;
+	}
+	priv->mfunc.master.slave_state[slave].init_port_mask &= ~(1 << port);
+	--priv->mfunc.master.init_port_ref[port];
+	return 0;
+}
+
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port)
 {
 	return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000, 0);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index bf5ec22..d9a0032 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -116,6 +116,22 @@ struct mlx4_dev_cap {
 	u32 max_counters;
 };
 
+struct mlx4_func_cap {
+	u8	function;
+	u8	num_ports;
+	u8	flags;
+	int	qp_quota;
+	int	cq_quota;
+	int	srq_quota;
+	int	mpt_quota;
+	int	mtt_quota;
+	int	max_eq;
+	int	reserved_eq;
+	int	mcg_quota;
+	u8	physical_port[MLX4_MAX_PORTS + 1];
+	u8	port_flags[MLX4_MAX_PORTS + 1];
+};
+
 struct mlx4_adapter {
 	char board_id[MLX4_BOARD_ID_LEN];
 	u8   inta_pin;
@@ -133,6 +149,7 @@ struct mlx4_init_hca_param {
 	u64 dmpt_base;
 	u64 cmpt_base;
 	u64 mtt_base;
+	u64 global_caps;
 	u16 log_mc_entry_sz;
 	u16 log_mc_hash_sz;
 	u8  log_num_qps;
@@ -167,6 +184,12 @@ struct mlx4_set_ib_param {
 };
 
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap);
+int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, struct mlx4_func_cap *func_cap);
+int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
+				struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox,
+				struct mlx4_cmd_info *cmd);
 int mlx4_MAP_FA(struct mlx4_dev *dev, struct mlx4_icm *icm);
 int mlx4_UNMAP_FA(struct mlx4_dev *dev);
 int mlx4_RUN_FW(struct mlx4_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 51cba26..ab06e2c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -915,6 +915,26 @@ int mlx4_QUERY_IF_STAT_wrapper(struct mlx4_dev *dev, int slave,
 			       struct mlx4_cmd_mailbox *outbox,
 			       struct mlx4_cmd_info *cmd);
 
+static inline void set_param_l(u64 *arg, u32 val)
+{
+	*((u32 *)arg) = val;
+}
+
+static inline void set_param_h(u64 *arg, u32 val)
+{
+	*arg = (*arg & 0xffffffff) | ((u64) val << 32);
+}
+
+static inline u32 get_param_l(u64 *arg)
+{
+	return (u32) (*arg & 0xffffffff);
+}
+
+static inline u32 get_param_h(u64 *arg)
+{
+	return (u32)(*arg >> 32);
+}
+
 #define NOT_MASKED_PD_BITS 17
 
 #endif /* MLX4_H */
-- 
1.7.7





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
