From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx5_core: Add pci error handlers to mlx5_core driver
Date: Tue, 13 Oct 2015 18:44:07 +0300
Message-ID: <1444751049-2511-3-git-send-email-ogerlitz@mellanox.com>
References: <1444751049-2511-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49502 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752962AbbJMPog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 11:44:36 -0400
In-Reply-To: <1444751049-2511-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

This patch implement the pci_error_handlers for mlx5_core which allow the
driver to recover from PCI error.

Once an error is detected in the PCI, the mlx5_pci_err_detected is called
and it:
1) Marks the device to be in 'Internal Error' state.
2) Dispatches an event to the mlx5_ib to flush all the outstanding cqes
with error.
3) Returns all the on going commands with error.
4) Unloads the driver.

Afterwards, the FW is reset and mlx5_pci_slot_reset is called and it
enables the device and restore it's pci state.

If the later succeeds, mlx5_pci_resume is called, and it loads the SW
stack.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 170 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  72 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 185 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   4 +
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  13 +-
 include/linux/mlx5/driver.h                        |  22 +++
 6 files changed, 454 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index c3e54b7..9c0446b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -256,8 +256,154 @@ static void dump_buf(void *buf, int size, int data_only, int offset)
 
 enum {
 	MLX5_DRIVER_STATUS_ABORTED = 0xfe,
+	MLX5_DRIVER_SYND = 0xbadd00de,
 };
 
+static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
+				       u32 *synd, u8 *status)
+{
+	*synd = 0;
+	*status = 0;
+
+	switch (op) {
+	case MLX5_CMD_OP_TEARDOWN_HCA:
+	case MLX5_CMD_OP_DISABLE_HCA:
+	case MLX5_CMD_OP_MANAGE_PAGES:
+	case MLX5_CMD_OP_DESTROY_MKEY:
+	case MLX5_CMD_OP_DESTROY_EQ:
+	case MLX5_CMD_OP_DESTROY_CQ:
+	case MLX5_CMD_OP_DESTROY_QP:
+	case MLX5_CMD_OP_DESTROY_PSV:
+	case MLX5_CMD_OP_DESTROY_SRQ:
+	case MLX5_CMD_OP_DESTROY_XRC_SRQ:
+	case MLX5_CMD_OP_DESTROY_DCT:
+	case MLX5_CMD_OP_DEALLOC_Q_COUNTER:
+	case MLX5_CMD_OP_DEALLOC_PD:
+	case MLX5_CMD_OP_DEALLOC_UAR:
+	case MLX5_CMD_OP_DETTACH_FROM_MCG:
+	case MLX5_CMD_OP_DEALLOC_XRCD:
+	case MLX5_CMD_OP_DEALLOC_TRANSPORT_DOMAIN:
+	case MLX5_CMD_OP_DELETE_VXLAN_UDP_DPORT:
+	case MLX5_CMD_OP_DELETE_L2_TABLE_ENTRY:
+	case MLX5_CMD_OP_DESTROY_TIR:
+	case MLX5_CMD_OP_DESTROY_SQ:
+	case MLX5_CMD_OP_DESTROY_RQ:
+	case MLX5_CMD_OP_DESTROY_RMP:
+	case MLX5_CMD_OP_DESTROY_TIS:
+	case MLX5_CMD_OP_DESTROY_RQT:
+	case MLX5_CMD_OP_DESTROY_FLOW_TABLE:
+	case MLX5_CMD_OP_DESTROY_FLOW_GROUP:
+	case MLX5_CMD_OP_DELETE_FLOW_TABLE_ENTRY:
+		return MLX5_CMD_STAT_OK;
+
+	case MLX5_CMD_OP_QUERY_HCA_CAP:
+	case MLX5_CMD_OP_QUERY_ADAPTER:
+	case MLX5_CMD_OP_INIT_HCA:
+	case MLX5_CMD_OP_ENABLE_HCA:
+	case MLX5_CMD_OP_QUERY_PAGES:
+	case MLX5_CMD_OP_SET_HCA_CAP:
+	case MLX5_CMD_OP_QUERY_ISSI:
+	case MLX5_CMD_OP_SET_ISSI:
+	case MLX5_CMD_OP_CREATE_MKEY:
+	case MLX5_CMD_OP_QUERY_MKEY:
+	case MLX5_CMD_OP_QUERY_SPECIAL_CONTEXTS:
+	case MLX5_CMD_OP_PAGE_FAULT_RESUME:
+	case MLX5_CMD_OP_CREATE_EQ:
+	case MLX5_CMD_OP_QUERY_EQ:
+	case MLX5_CMD_OP_GEN_EQE:
+	case MLX5_CMD_OP_CREATE_CQ:
+	case MLX5_CMD_OP_QUERY_CQ:
+	case MLX5_CMD_OP_MODIFY_CQ:
+	case MLX5_CMD_OP_CREATE_QP:
+	case MLX5_CMD_OP_RST2INIT_QP:
+	case MLX5_CMD_OP_INIT2RTR_QP:
+	case MLX5_CMD_OP_RTR2RTS_QP:
+	case MLX5_CMD_OP_RTS2RTS_QP:
+	case MLX5_CMD_OP_SQERR2RTS_QP:
+	case MLX5_CMD_OP_2ERR_QP:
+	case MLX5_CMD_OP_2RST_QP:
+	case MLX5_CMD_OP_QUERY_QP:
+	case MLX5_CMD_OP_SQD_RTS_QP:
+	case MLX5_CMD_OP_INIT2INIT_QP:
+	case MLX5_CMD_OP_CREATE_PSV:
+	case MLX5_CMD_OP_CREATE_SRQ:
+	case MLX5_CMD_OP_QUERY_SRQ:
+	case MLX5_CMD_OP_ARM_RQ:
+	case MLX5_CMD_OP_CREATE_XRC_SRQ:
+	case MLX5_CMD_OP_QUERY_XRC_SRQ:
+	case MLX5_CMD_OP_ARM_XRC_SRQ:
+	case MLX5_CMD_OP_CREATE_DCT:
+	case MLX5_CMD_OP_DRAIN_DCT:
+	case MLX5_CMD_OP_QUERY_DCT:
+	case MLX5_CMD_OP_ARM_DCT_FOR_KEY_VIOLATION:
+	case MLX5_CMD_OP_QUERY_VPORT_STATE:
+	case MLX5_CMD_OP_MODIFY_VPORT_STATE:
+	case MLX5_CMD_OP_QUERY_ESW_VPORT_CONTEXT:
+	case MLX5_CMD_OP_MODIFY_ESW_VPORT_CONTEXT:
+	case MLX5_CMD_OP_QUERY_NIC_VPORT_CONTEXT:
+	case MLX5_CMD_OP_MODIFY_NIC_VPORT_CONTEXT:
+	case MLX5_CMD_OP_QUERY_ROCE_ADDRESS:
+	case MLX5_CMD_OP_SET_ROCE_ADDRESS:
+	case MLX5_CMD_OP_QUERY_HCA_VPORT_CONTEXT:
+	case MLX5_CMD_OP_MODIFY_HCA_VPORT_CONTEXT:
+	case MLX5_CMD_OP_QUERY_HCA_VPORT_GID:
+	case MLX5_CMD_OP_QUERY_HCA_VPORT_PKEY:
+	case MLX5_CMD_OP_QUERY_VPORT_COUNTER:
+	case MLX5_CMD_OP_ALLOC_Q_COUNTER:
+	case MLX5_CMD_OP_QUERY_Q_COUNTER:
+	case MLX5_CMD_OP_ALLOC_PD:
+	case MLX5_CMD_OP_ALLOC_UAR:
+	case MLX5_CMD_OP_CONFIG_INT_MODERATION:
+	case MLX5_CMD_OP_ACCESS_REG:
+	case MLX5_CMD_OP_ATTACH_TO_MCG:
+	case MLX5_CMD_OP_GET_DROPPED_PACKET_LOG:
+	case MLX5_CMD_OP_MAD_IFC:
+	case MLX5_CMD_OP_QUERY_MAD_DEMUX:
+	case MLX5_CMD_OP_SET_MAD_DEMUX:
+	case MLX5_CMD_OP_NOP:
+	case MLX5_CMD_OP_ALLOC_XRCD:
+	case MLX5_CMD_OP_ALLOC_TRANSPORT_DOMAIN:
+	case MLX5_CMD_OP_QUERY_CONG_STATUS:
+	case MLX5_CMD_OP_MODIFY_CONG_STATUS:
+	case MLX5_CMD_OP_QUERY_CONG_PARAMS:
+	case MLX5_CMD_OP_MODIFY_CONG_PARAMS:
+	case MLX5_CMD_OP_QUERY_CONG_STATISTICS:
+	case MLX5_CMD_OP_ADD_VXLAN_UDP_DPORT:
+	case MLX5_CMD_OP_SET_L2_TABLE_ENTRY:
+	case MLX5_CMD_OP_QUERY_L2_TABLE_ENTRY:
+	case MLX5_CMD_OP_CREATE_TIR:
+	case MLX5_CMD_OP_MODIFY_TIR:
+	case MLX5_CMD_OP_QUERY_TIR:
+	case MLX5_CMD_OP_CREATE_SQ:
+	case MLX5_CMD_OP_MODIFY_SQ:
+	case MLX5_CMD_OP_QUERY_SQ:
+	case MLX5_CMD_OP_CREATE_RQ:
+	case MLX5_CMD_OP_MODIFY_RQ:
+	case MLX5_CMD_OP_QUERY_RQ:
+	case MLX5_CMD_OP_CREATE_RMP:
+	case MLX5_CMD_OP_MODIFY_RMP:
+	case MLX5_CMD_OP_QUERY_RMP:
+	case MLX5_CMD_OP_CREATE_TIS:
+	case MLX5_CMD_OP_MODIFY_TIS:
+	case MLX5_CMD_OP_QUERY_TIS:
+	case MLX5_CMD_OP_CREATE_RQT:
+	case MLX5_CMD_OP_MODIFY_RQT:
+	case MLX5_CMD_OP_QUERY_RQT:
+	case MLX5_CMD_OP_CREATE_FLOW_TABLE:
+	case MLX5_CMD_OP_QUERY_FLOW_TABLE:
+	case MLX5_CMD_OP_CREATE_FLOW_GROUP:
+	case MLX5_CMD_OP_QUERY_FLOW_GROUP:
+	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
+	case MLX5_CMD_OP_QUERY_FLOW_TABLE_ENTRY:
+		*status = MLX5_DRIVER_STATUS_ABORTED;
+		*synd = MLX5_DRIVER_SYND;
+		return -EIO;
+	default:
+		mlx5_core_err(dev, "Unknown FW command (%d)\n", op);
+		return -EINVAL;
+	}
+}
+
 const char *mlx5_command_str(int command)
 {
 	switch (command) {
@@ -592,6 +738,16 @@ static int wait_func(struct mlx5_core_dev *dev, struct mlx5_cmd_work_ent *ent)
 	return err;
 }
 
+static __be32 *get_synd_ptr(struct mlx5_outbox_hdr *out)
+{
+	return &out->syndrome;
+}
+
+static u8 *get_status_ptr(struct mlx5_outbox_hdr *out)
+{
+	return &out->status;
+}
+
 /*  Notes:
  *    1. Callback functions may not sleep
  *    2. page queue commands do not support asynchrous completion
@@ -1200,6 +1356,11 @@ static struct mlx5_cmd_msg *alloc_msg(struct mlx5_core_dev *dev, int in_size,
 	return msg;
 }
 
+static u16 opcode_from_in(struct mlx5_inbox_hdr *in)
+{
+	return be16_to_cpu(in->opcode);
+}
+
 static int is_manage_pages(struct mlx5_inbox_hdr *in)
 {
 	return be16_to_cpu(in->opcode) == MLX5_CMD_OP_MANAGE_PAGES;
@@ -1214,6 +1375,15 @@ static int cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 	gfp_t gfp;
 	int err;
 	u8 status = 0;
+	u32 drv_synd;
+
+	if (pci_channel_offline(dev->pdev) ||
+	    dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
+		err = mlx5_internal_err_ret_value(dev, opcode_from_in(in), &drv_synd, &status);
+		*get_synd_ptr(out) = drv_synd;
+		*get_status_ptr(out) = status;
+		return err;
+	}
 
 	pages_queue = is_manage_pages(in);
 	gfp = callback ? GFP_ATOMIC : GFP_KERNEL;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index b007e83..4089c8f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -34,6 +34,7 @@
 #include <linux/module.h>
 #include <linux/random.h>
 #include <linux/vmalloc.h>
+#include <linux/hardirq.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
@@ -68,6 +69,29 @@ static u8 get_nic_interface(struct mlx5_core_dev *dev)
 	return (ioread32be(&dev->iseg->cmdq_addr_l_sz) >> 8) & 3;
 }
 
+static void trigger_cmd_completions(struct mlx5_core_dev *dev)
+{
+	unsigned long flags;
+	u64 vector;
+
+	/* wait for pending handlers to complete */
+	synchronize_irq(dev->priv.msix_arr[MLX5_EQ_VEC_CMD].vector);
+	spin_lock_irqsave(&dev->cmd.alloc_lock, flags);
+	vector = ~dev->cmd.bitmask & ((1ul << (1 << dev->cmd.log_sz)) - 1);
+	if (!vector)
+		goto no_trig;
+
+	vector |= MLX5_TRIGGERED_CMD_COMP;
+	spin_unlock_irqrestore(&dev->cmd.alloc_lock, flags);
+
+	mlx5_core_dbg(dev, "vector 0x%llx\n", vector);
+	mlx5_cmd_comp_handler(dev, vector);
+	return;
+
+no_trig:
+	spin_unlock_irqrestore(&dev->cmd.alloc_lock, flags);
+}
+
 static int in_fatal(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
@@ -82,6 +106,43 @@ static int in_fatal(struct mlx5_core_dev *dev)
 	return 0;
 }
 
+void mlx5_enter_error_state(struct mlx5_core_dev *dev)
+{
+	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR)
+		return;
+
+	mlx5_core_err(dev, "start\n");
+	if (pci_channel_offline(dev->pdev) || in_fatal(dev))
+		dev->state = MLX5_DEVICE_STATE_INTERNAL_ERROR;
+
+	mlx5_core_event(dev, MLX5_DEV_EVENT_SYS_ERROR, 0);
+	mlx5_core_err(dev, "end\n");
+}
+
+static void mlx5_handle_bad_state(struct mlx5_core_dev *dev)
+{
+	u8 nic_interface = get_nic_interface(dev);
+
+	switch (nic_interface) {
+	case MLX5_NIC_IFC_FULL:
+		mlx5_core_warn(dev, "Expected to see disabled NIC but it is full driver\n");
+		break;
+
+	case MLX5_NIC_IFC_DISABLED:
+		mlx5_core_warn(dev, "starting teardown\n");
+		break;
+
+	case MLX5_NIC_IFC_NO_DRAM_NIC:
+		mlx5_core_warn(dev, "Expected to see disabled NIC but it is no dram nic\n");
+		break;
+	default:
+		mlx5_core_warn(dev, "Expected to see disabled NIC but it is has invalid value %d\n",
+			       nic_interface);
+	}
+
+	mlx5_disable_device(dev);
+}
+
 static void health_care(struct work_struct *work)
 {
 	struct mlx5_core_health *health;
@@ -92,6 +153,7 @@ static void health_care(struct work_struct *work)
 	priv = container_of(health, struct mlx5_priv, health);
 	dev = container_of(priv, struct mlx5_core_dev, priv);
 	mlx5_core_warn(dev, "handling bad device here\n");
+	mlx5_handle_bad_state(dev);
 }
 
 static const char *hsynd_str(u8 synd)
@@ -147,6 +209,10 @@ static void print_health_info(struct mlx5_core_dev *dev)
 	u32 fw;
 	int i;
 
+	/* If the syndrom is 0, the device is OK and no need to print buffer */
+	if (!ioread8(&h->synd))
+		return;
+
 	for (i = 0; i < ARRAY_SIZE(h->assert_var); i++)
 		dev_err(&dev->pdev->dev, "assert_var[%d] 0x%08x\n", i, ioread32be(h->assert_var + i));
 
@@ -178,6 +244,12 @@ static void poll_health(unsigned long data)
 	struct mlx5_core_health *health = &dev->priv.health;
 	u32 count;
 
+	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
+		trigger_cmd_completions(dev);
+		mod_timer(&health->timer, get_next_poll_jiffies());
+		return;
+	}
+
 	count = ioread32be(health->health_counter);
 	if (count == health->prev)
 		++health->miss_counter;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index b6edc58..368c2ea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -45,6 +45,7 @@
 #include <linux/mlx5/srq.h>
 #include <linux/debugfs.h>
 #include <linux/kmod.h>
+#include <linux/delay.h>
 #include <linux/mlx5/mlx5_ifc.h>
 #include "mlx5_core.h"
 
@@ -181,6 +182,34 @@ static int set_dma_caps(struct pci_dev *pdev)
 	return err;
 }
 
+static int mlx5_pci_enable_device(struct mlx5_core_dev *dev)
+{
+	struct pci_dev *pdev = dev->pdev;
+	int err = 0;
+
+	mutex_lock(&dev->pci_status_mutex);
+	if (dev->pci_status == MLX5_PCI_STATUS_DISABLED) {
+		err = pci_enable_device(pdev);
+		if (!err)
+			dev->pci_status = MLX5_PCI_STATUS_ENABLED;
+	}
+	mutex_unlock(&dev->pci_status_mutex);
+
+	return err;
+}
+
+static void mlx5_pci_disable_device(struct mlx5_core_dev *dev)
+{
+	struct pci_dev *pdev = dev->pdev;
+
+	mutex_lock(&dev->pci_status_mutex);
+	if (dev->pci_status == MLX5_PCI_STATUS_ENABLED) {
+		pci_disable_device(pdev);
+		dev->pci_status = MLX5_PCI_STATUS_DISABLED;
+	}
+	mutex_unlock(&dev->pci_status_mutex);
+}
+
 static int request_bar(struct pci_dev *pdev)
 {
 	int err = 0;
@@ -807,7 +836,7 @@ static int mlx5_pci_init(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	if (!priv->dbg_root)
 		return -ENOMEM;
 
-	err = pci_enable_device(pdev);
+	err = mlx5_pci_enable_device(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot enable PCI device, aborting\n");
 		goto err_dbg;
@@ -841,7 +870,7 @@ err_clr_master:
 	pci_clear_master(dev->pdev);
 	release_bar(dev->pdev);
 err_disable:
-	pci_disable_device(dev->pdev);
+	mlx5_pci_disable_device(dev);
 
 err_dbg:
 	debugfs_remove(priv->dbg_root);
@@ -853,7 +882,7 @@ static void mlx5_pci_close(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	iounmap(dev->iseg);
 	pci_clear_master(dev->pdev);
 	release_bar(dev->pdev);
-	pci_disable_device(dev->pdev);
+	mlx5_pci_disable_device(dev);
 	debugfs_remove(priv->dbg_root);
 }
 
@@ -863,13 +892,25 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	struct pci_dev *pdev = dev->pdev;
 	int err;
 
+	mutex_lock(&dev->intf_state_mutex);
+	if (dev->interface_state == MLX5_INTERFACE_STATE_UP) {
+		dev_warn(&dev->pdev->dev, "%s: interface is up, NOP\n",
+			 __func__);
+		goto out;
+	}
+
 	dev_info(&pdev->dev, "firmware version: %d.%d.%d\n", fw_rev_maj(dev),
 		 fw_rev_min(dev), fw_rev_sub(dev));
 
+	/* on load removing any previous indication of internal error, device is
+	 * up
+	 */
+	dev->state = MLX5_DEVICE_STATE_UP;
+
 	err = mlx5_cmd_init(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed initializing command interface, aborting\n");
-		return err;
+		goto out_err;
 	}
 
 	mlx5_pagealloc_init(dev);
@@ -994,6 +1035,10 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	if (err)
 		pr_info("failed request module on %s\n", MLX5_IB_MOD);
 
+	dev->interface_state = MLX5_INTERFACE_STATE_UP;
+out:
+	mutex_unlock(&dev->intf_state_mutex);
+
 	return 0;
 
 err_reg_dev:
@@ -1024,7 +1069,7 @@ err_stop_poll:
 	mlx5_stop_health_poll(dev);
 	if (mlx5_cmd_teardown_hca(dev)) {
 		dev_err(&dev->pdev->dev, "tear_down_hca failed, skip cleanup\n");
-		return err;
+		goto out_err;
 	}
 
 err_pagealloc_stop:
@@ -1040,13 +1085,23 @@ err_pagealloc_cleanup:
 	mlx5_pagealloc_cleanup(dev);
 	mlx5_cmd_cleanup(dev);
 
+out_err:
+	dev->state = MLX5_DEVICE_STATE_INTERNAL_ERROR;
+	mutex_unlock(&dev->intf_state_mutex);
+
 	return err;
 }
 
 static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 {
-	int err;
+	int err = 0;
 
+	mutex_lock(&dev->intf_state_mutex);
+	if (dev->interface_state == MLX5_INTERFACE_STATE_DOWN) {
+		dev_warn(&dev->pdev->dev, "%s: interface is down, NOP\n",
+			 __func__);
+		goto out;
+	}
 	mlx5_unregister_device(dev);
 	mlx5_cleanup_mr_table(dev);
 	mlx5_cleanup_srq_table(dev);
@@ -1072,10 +1127,12 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	mlx5_cmd_cleanup(dev);
 
 out:
+	dev->interface_state = MLX5_INTERFACE_STATE_DOWN;
+	mutex_unlock(&dev->intf_state_mutex);
 	return err;
 }
 
-static void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
+void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 		     unsigned long param)
 {
 	struct mlx5_priv *priv = &dev->priv;
@@ -1125,6 +1182,8 @@ static int init_one(struct pci_dev *pdev,
 
 	INIT_LIST_HEAD(&priv->ctx_list);
 	spin_lock_init(&priv->ctx_lock);
+	mutex_init(&dev->pci_status_mutex);
+	mutex_init(&dev->intf_state_mutex);
 	err = mlx5_pci_init(dev, priv);
 	if (err) {
 		dev_err(&pdev->dev, "mlx5_pci_init failed with error code %d\n", err);
@@ -1172,6 +1231,115 @@ static void remove_one(struct pci_dev *pdev)
 	kfree(dev);
 }
 
+static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
+					      pci_channel_state_t state)
+{
+	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
+	struct mlx5_priv *priv = &dev->priv;
+
+	dev_info(&pdev->dev, "%s was called\n", __func__);
+	mlx5_enter_error_state(dev);
+	mlx5_unload_one(dev, priv);
+	mlx5_pci_disable_device(dev);
+	return state == pci_channel_io_perm_failure ?
+		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
+}
+
+static pci_ers_result_t mlx5_pci_slot_reset(struct pci_dev *pdev)
+{
+	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
+	int err = 0;
+
+	dev_info(&pdev->dev, "%s was called\n", __func__);
+
+	err = mlx5_pci_enable_device(dev);
+	if (err) {
+		dev_err(&pdev->dev, "%s: mlx5_pci_enable_device failed with error code: %d\n"
+			, __func__, err);
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	pci_set_master(pdev);
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+
+	return err ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
+}
+
+void mlx5_disable_device(struct mlx5_core_dev *dev)
+{
+	mlx5_pci_err_detected(dev->pdev, 0);
+}
+
+/* wait for the device to show vital signs. For now we check
+ * that we can read the device ID and that the health buffer
+ * shows a non zero value which is different than 0xffffffff
+ */
+static void wait_vital(struct pci_dev *pdev)
+{
+	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
+	struct mlx5_core_health *health = &dev->priv.health;
+	const int niter = 100;
+	u32 count;
+	u16 did;
+	int i;
+
+	/* let's be on the safe side */
+	msleep(1000);
+	for (i = 0; i < niter; i++) {
+		if (pci_read_config_word(pdev, 2, &did)) {
+			dev_warn(&pdev->dev, "failed reading config word\n");
+			break;
+		}
+		if (did == pdev->device) {
+			dev_info(&pdev->dev, "device ID correctly read after %d iterations\n", i);
+			break;
+		}
+		msleep(50);
+	}
+	if (i == niter)
+		dev_warn(&pdev->dev, "%s-%d: could not read device ID\n", __func__, __LINE__);
+
+	for (i = 0; i < niter; i++) {
+		count = ioread32be(health->health_counter);
+		if (count && count != 0xffffffff) {
+			dev_info(&pdev->dev, "Counter value 0x%x after %d iterations\n", count, i);
+			break;
+		}
+		msleep(50);
+	}
+
+	if (i == niter)
+		dev_warn(&pdev->dev, "%s-%d: could not read device ID\n", __func__, __LINE__);
+
+	/* let's be on the safe side */
+	msleep(1000);
+}
+
+static void mlx5_pci_resume(struct pci_dev *pdev)
+{
+	struct mlx5_core_dev *dev = pci_get_drvdata(pdev);
+	struct mlx5_priv *priv = &dev->priv;
+	int err;
+
+	dev_info(&pdev->dev, "%s was called\n", __func__);
+
+	pci_save_state(pdev);
+	wait_vital(pdev);
+
+	err = mlx5_load_one(dev, priv);
+	if (err)
+		dev_err(&pdev->dev, "%s: mlx5_load_one failed with error code: %d\n"
+			, __func__, err);
+	else
+		dev_info(&pdev->dev, "%s: device recovered\n", __func__);
+}
+
+static const struct pci_error_handlers mlx5_err_handler = {
+	.error_detected = mlx5_pci_err_detected,
+	.slot_reset	= mlx5_pci_slot_reset,
+	.resume		= mlx5_pci_resume
+};
+
 static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x1011) }, /* Connect-IB */
 	{ PCI_VDEVICE(MELLANOX, 0x1012) }, /* Connect-IB VF */
@@ -1188,7 +1356,8 @@ static struct pci_driver mlx5_core_driver = {
 	.name           = DRIVER_NAME,
 	.id_table       = mlx5_core_pci_table,
 	.probe          = init_one,
-	.remove         = remove_one
+	.remove         = remove_one,
+	.err_handler	= &mlx5_err_handler
 };
 
 static int __init init(void)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 30c0be7..cee5b7a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -86,6 +86,10 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev);
 int mlx5_query_board_id(struct mlx5_core_dev *dev);
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
+void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
+		     unsigned long param);
+void mlx5_enter_error_state(struct mlx5_core_dev *dev);
+void mlx5_disable_device(struct mlx5_core_dev *dev);
 
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index 76432a5..1cda5d2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -493,15 +493,20 @@ int mlx5_reclaim_startup_pages(struct mlx5_core_dev *dev)
 	struct fw_page *fwp;
 	struct rb_node *p;
 	int nclaimed = 0;
-	int err;
+	int err = 0;
 
 	do {
 		p = rb_first(&dev->priv.page_root);
 		if (p) {
 			fwp = rb_entry(p, struct fw_page, rb_node);
-			err = reclaim_pages(dev, fwp->func_id,
-					    optimal_reclaimed_pages(),
-					    &nclaimed);
+			if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
+				free_4k(dev, fwp->addr);
+				nclaimed = 1;
+			} else {
+				err = reclaim_pages(dev, fwp->func_id,
+						    optimal_reclaimed_pages(),
+						    &nclaimed);
+			}
 			if (err) {
 				mlx5_core_warn(dev, "failed reclaiming pages (%d)\n",
 					       err);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index cd469b9..9d77b8d 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -487,8 +487,26 @@ struct mlx5_priv {
 	spinlock_t              ctx_lock;
 };
 
+enum mlx5_device_state {
+	MLX5_DEVICE_STATE_UP,
+	MLX5_DEVICE_STATE_INTERNAL_ERROR,
+};
+
+enum mlx5_interface_state {
+	MLX5_INTERFACE_STATE_DOWN,
+	MLX5_INTERFACE_STATE_UP,
+};
+
+enum mlx5_pci_status {
+	MLX5_PCI_STATUS_DISABLED,
+	MLX5_PCI_STATUS_ENABLED,
+};
+
 struct mlx5_core_dev {
 	struct pci_dev	       *pdev;
+	/* sync pci state */
+	struct mutex		pci_status_mutex;
+	enum mlx5_pci_status	pci_status;
 	u8			rev_id;
 	char			board_id[MLX5_BOARD_ID_LEN];
 	struct mlx5_cmd		cmd;
@@ -497,6 +515,10 @@ struct mlx5_core_dev {
 	u32 hca_caps_max[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
 	phys_addr_t		iseg_base;
 	struct mlx5_init_seg __iomem *iseg;
+	enum mlx5_device_state	state;
+	/* sync interface state */
+	struct mutex		intf_state_mutex;
+	enum mlx5_interface_state interface_state;
 	void			(*event) (struct mlx5_core_dev *dev,
 					  enum mlx5_dev_event event,
 					  unsigned long param);
-- 
2.3.7
