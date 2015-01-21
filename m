From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 8/9] net/mlx4_core: Enable device recovery flow with SRIOV
Date: Wed, 21 Jan 2015 16:45:56 +0200
Message-ID: <1421851557-12084-9-git-send-email-ogerlitz@mellanox.com>
References: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43049 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753315AbbAUOqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 09:46:45 -0500
In-Reply-To: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

In SRIOV, both the PF and the VF may attempt device recovery whenever they
assume that the device is not functioning.  When the PF driver resets the
device, the VF should detect this and attempt to reinitialize itself.

The VF must be able to reset itself under all circumstances, even
if the PF is not responsive.

The VF shall reset itself in the following cases:

1. Commands are not processed within reasonable time over the communication channel.
This is done considering device state and the correct return code based on
the command as was done in the native mode, done in the next patch.

2. The VF driver receives an internal error event reported by the PF on the
communication channel. This occurs when the PF driver resets the device or
when VF is out of sync with the PF.

Add 'VF reset' capability, which allows the VF to reinitialize itself even when the
PF is not responsive.

As PF and VF may run their reset flow simulantanisly, there are several cases
that are handled:
- Prevent freeing VF resources upon FLR, when PF is in its unloading stage.
- Prevent PF getting VF commands before it has finished initializing its resources.
- Upon VF startup, check that comm-channel is online before sending
  commands to the PF and getting timed-out.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/catas.c |  120 +++++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/cmd.c   |   75 ++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/eq.c    |   10 ++-
 drivers/net/ethernet/mellanox/mlx4/intf.c  |    6 +-
 drivers/net/ethernet/mellanox/mlx4/main.c  |  135 ++++++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |    7 ++-
 include/linux/mlx4/cmd.h                   |    2 +
 include/linux/mlx4/device.h                |    5 +
 8 files changed, 291 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index 3fcf3cf..715de8a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -45,8 +45,7 @@ enum {
 int mlx4_internal_err_reset = 1;
 module_param_named(internal_err_reset, mlx4_internal_err_reset,  int, 0644);
 MODULE_PARM_DESC(internal_err_reset,
-		 "Reset device on internal errors if non-zero"
-		 " (default 1, in SRIOV mode default is 0)");
+		 "Reset device on internal errors if non-zero (default 1)");
 
 static int read_vendor_id(struct mlx4_dev *dev)
 {
@@ -71,6 +70,9 @@ static int mlx4_reset_master(struct mlx4_dev *dev)
 {
 	int err = 0;
 
+	if (mlx4_is_master(dev))
+		mlx4_report_internal_err_comm_event(dev);
+
 	if (!pci_channel_offline(dev->persist->pdev)) {
 		err = read_vendor_id(dev);
 		/* If PCI can't be accessed to read vendor ID we assume that its
@@ -87,6 +89,81 @@ static int mlx4_reset_master(struct mlx4_dev *dev)
 	return err;
 }
 
+static int mlx4_reset_slave(struct mlx4_dev *dev)
+{
+#define COM_CHAN_RST_REQ_OFFSET 0x10
+#define COM_CHAN_RST_ACK_OFFSET 0x08
+
+	u32 comm_flags;
+	u32 rst_req;
+	u32 rst_ack;
+	unsigned long end;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	if (pci_channel_offline(dev->persist->pdev))
+		return 0;
+
+	comm_flags = swab32(readl((__iomem char *)priv->mfunc.comm +
+				  MLX4_COMM_CHAN_FLAGS));
+	if (comm_flags == 0xffffffff) {
+		mlx4_err(dev, "VF reset is not needed\n");
+		return 0;
+	}
+
+	if (!(dev->caps.vf_caps & MLX4_VF_CAP_FLAG_RESET)) {
+		mlx4_err(dev, "VF reset is not supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	rst_req = (comm_flags & (u32)(1 << COM_CHAN_RST_REQ_OFFSET)) >>
+		COM_CHAN_RST_REQ_OFFSET;
+	rst_ack = (comm_flags & (u32)(1 << COM_CHAN_RST_ACK_OFFSET)) >>
+		COM_CHAN_RST_ACK_OFFSET;
+	if (rst_req != rst_ack) {
+		mlx4_err(dev, "Communication channel isn't sync, fail to send reset\n");
+		return -EIO;
+	}
+
+	rst_req ^= 1;
+	mlx4_warn(dev, "VF is sending reset request to Firmware\n");
+	comm_flags = rst_req << COM_CHAN_RST_REQ_OFFSET;
+	__raw_writel((__force u32)cpu_to_be32(comm_flags),
+		     (__iomem char *)priv->mfunc.comm + MLX4_COMM_CHAN_FLAGS);
+	/* Make sure that our comm channel write doesn't
+	 * get mixed in with writes from another CPU.
+	 */
+	mmiowb();
+
+	end = msecs_to_jiffies(MLX4_COMM_TIME) + jiffies;
+	while (time_before(jiffies, end)) {
+		comm_flags = swab32(readl((__iomem char *)priv->mfunc.comm +
+					  MLX4_COMM_CHAN_FLAGS));
+		rst_ack = (comm_flags & (u32)(1 << COM_CHAN_RST_ACK_OFFSET)) >>
+			COM_CHAN_RST_ACK_OFFSET;
+
+		/* Reading rst_req again since the communication channel can
+		 * be reset at any time by the PF and all its bits will be
+		 * set to zero.
+		 */
+		rst_req = (comm_flags & (u32)(1 << COM_CHAN_RST_REQ_OFFSET)) >>
+			COM_CHAN_RST_REQ_OFFSET;
+
+		if (rst_ack == rst_req) {
+			mlx4_warn(dev, "VF Reset succeed\n");
+			return 0;
+		}
+		cond_resched();
+	}
+	mlx4_err(dev, "Fail to send reset over the communication channel\n");
+	return -ETIMEDOUT;
+}
+
+static int mlx4_comm_internal_err(u32 slave_read)
+{
+	return (u32)COMM_CHAN_EVENT_INTERNAL_ERR ==
+		(slave_read & (u32)COMM_CHAN_EVENT_INTERNAL_ERR) ? 1 : 0;
+}
+
 void mlx4_enter_error_state(struct mlx4_dev_persistent *persist)
 {
 	int err;
@@ -101,7 +178,10 @@ void mlx4_enter_error_state(struct mlx4_dev_persistent *persist)
 
 	dev = persist->dev;
 	mlx4_err(dev, "device is going to be reset\n");
-	err = mlx4_reset_master(dev);
+	if (mlx4_is_slave(dev))
+		err = mlx4_reset_slave(dev);
+	else
+		err = mlx4_reset_master(dev);
 	BUG_ON(err != 0);
 
 	dev->persist->state |= MLX4_DEVICE_STATE_INTERNAL_ERROR;
@@ -148,8 +228,15 @@ static void poll_catas(unsigned long dev_ptr)
 {
 	struct mlx4_dev *dev = (struct mlx4_dev *) dev_ptr;
 	struct mlx4_priv *priv = mlx4_priv(dev);
-
-	if (readl(priv->catas_err.map)) {
+	u32 slave_read;
+
+	if (mlx4_is_slave(dev)) {
+		slave_read = swab32(readl(&priv->mfunc.comm->slave_read));
+		if (mlx4_comm_internal_err(slave_read)) {
+			mlx4_warn(dev, "Internal error detected on the communication channel\n");
+			goto internal_err;
+		}
+	} else if (readl(priv->catas_err.map)) {
 		dump_err_buf(dev);
 		goto internal_err;
 	}
@@ -182,22 +269,21 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	phys_addr_t addr;
 
-	/*If we are in SRIOV the default of the module param must be 0*/
-	if (mlx4_is_mfunc(dev))
-		mlx4_internal_err_reset = 0;
-
 	INIT_LIST_HEAD(&priv->catas_err.list);
 	init_timer(&priv->catas_err.timer);
 	priv->catas_err.map = NULL;
 
-	addr = pci_resource_start(dev->persist->pdev, priv->fw.catas_bar) +
-		priv->fw.catas_offset;
-
-	priv->catas_err.map = ioremap(addr, priv->fw.catas_size * 4);
-	if (!priv->catas_err.map) {
-		mlx4_warn(dev, "Failed to map internal error buffer at 0x%llx\n",
-			  (unsigned long long) addr);
-		return;
+	if (!mlx4_is_slave(dev)) {
+		addr = pci_resource_start(dev->persist->pdev,
+					  priv->fw.catas_bar) +
+					  priv->fw.catas_offset;
+
+		priv->catas_err.map = ioremap(addr, priv->fw.catas_size * 4);
+		if (!priv->catas_err.map) {
+			mlx4_warn(dev, "Failed to map internal error buffer at 0x%llx\n",
+				  (unsigned long long)addr);
+			return;
+		}
 	}
 
 	priv->catas_err.timer.data     = (unsigned long) dev;
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 3895b2b..e3d6f7f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -42,6 +42,7 @@
 #include <linux/mlx4/device.h>
 #include <linux/semaphore.h>
 #include <rdma/ib_smi.h>
+#include <linux/delay.h>
 
 #include <asm/io.h>
 
@@ -729,7 +730,7 @@ int __mlx4_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 EXPORT_SYMBOL_GPL(__mlx4_cmd);
 
 
-static int mlx4_ARM_COMM_CHANNEL(struct mlx4_dev *dev)
+int mlx4_ARM_COMM_CHANNEL(struct mlx4_dev *dev)
 {
 	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_ARM_COMM_CHANNEL,
 			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
@@ -1945,8 +1946,11 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 		break;
 	case MLX4_COMM_CMD_VHCR_POST:
 		if ((slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR_EN) &&
-		    (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR_POST))
+		    (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR_POST)) {
+			mlx4_warn(dev, "slave:%d is out of sync, cmd=0x%x, last command=0x%x, reset is needed\n",
+				  slave, cmd, slave_state[slave].last_cmd);
 			goto reset_slave;
+		}
 
 		mutex_lock(&priv->cmd.slave_cmd_mutex);
 		if (mlx4_master_process_vhcr(dev, slave, NULL)) {
@@ -1980,7 +1984,18 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 
 reset_slave:
 	/* cleanup any slave resources */
-	mlx4_delete_all_resources_for_slave(dev, slave);
+	if (dev->persist->interface_state & MLX4_INTERFACE_STATE_UP)
+		mlx4_delete_all_resources_for_slave(dev, slave);
+
+	if (cmd != MLX4_COMM_CMD_RESET) {
+		mlx4_warn(dev, "Turn on internal error to force reset, slave=%d, cmd=0x%x\n",
+			  slave, cmd);
+		/* Turn on internal error letting slave reset itself immeditaly,
+		 * otherwise it might take till timeout on command is passed
+		 */
+		reply |= ((u32)COMM_CHAN_EVENT_INTERNAL_ERR);
+	}
+
 	spin_lock_irqsave(&priv->mfunc.master.slave_state_lock, flags);
 	if (!slave_state[slave].is_slave_going_down)
 		slave_state[slave].last_cmd = MLX4_COMM_CMD_RESET;
@@ -2056,16 +2071,27 @@ void mlx4_master_comm_channel(struct work_struct *work)
 static int sync_toggles(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	int wr_toggle;
-	int rd_toggle;
+	u32 wr_toggle;
+	u32 rd_toggle;
 	unsigned long end;
 
-	wr_toggle = swab32(readl(&priv->mfunc.comm->slave_write)) >> 31;
-	end = jiffies + msecs_to_jiffies(5000);
+	wr_toggle = swab32(readl(&priv->mfunc.comm->slave_write));
+	if (wr_toggle == 0xffffffff)
+		end = jiffies + msecs_to_jiffies(30000);
+	else
+		end = jiffies + msecs_to_jiffies(5000);
 
 	while (time_before(jiffies, end)) {
-		rd_toggle = swab32(readl(&priv->mfunc.comm->slave_read)) >> 31;
-		if (rd_toggle == wr_toggle) {
+		rd_toggle = swab32(readl(&priv->mfunc.comm->slave_read));
+		if (wr_toggle == 0xffffffff || rd_toggle == 0xffffffff) {
+			/* PCI might be offline */
+			msleep(100);
+			wr_toggle = swab32(readl(&priv->mfunc.comm->
+					   slave_write));
+			continue;
+		}
+
+		if (rd_toggle >> 31 == wr_toggle >> 31) {
 			priv->cmd.comm_toggle = rd_toggle;
 			return 0;
 		}
@@ -2172,13 +2198,6 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 		if (mlx4_init_resource_tracker(dev))
 			goto err_thread;
 
-		err = mlx4_ARM_COMM_CHANNEL(dev);
-		if (err) {
-			mlx4_err(dev, " Failed to arm comm channel eq: %x\n",
-				 err);
-			goto err_resource;
-		}
-
 	} else {
 		err = sync_toggles(dev);
 		if (err) {
@@ -2188,8 +2207,6 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 	}
 	return 0;
 
-err_resource:
-	mlx4_free_resource_tracker(dev, RES_TR_FREE_ALL);
 err_thread:
 	flush_workqueue(priv->mfunc.master.comm_wq);
 	destroy_workqueue(priv->mfunc.master.comm_wq);
@@ -2266,6 +2283,27 @@ err:
 	return -ENOMEM;
 }
 
+void mlx4_report_internal_err_comm_event(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int slave;
+	u32 slave_read;
+
+	/* Report an internal error event to all
+	 * communication channels.
+	 */
+	for (slave = 0; slave < dev->num_slaves; slave++) {
+		slave_read = swab32(readl(&priv->mfunc.comm[slave].slave_read));
+		slave_read |= (u32)COMM_CHAN_EVENT_INTERNAL_ERR;
+		__raw_writel((__force u32)cpu_to_be32(slave_read),
+			     &priv->mfunc.comm[slave].slave_read);
+		/* Make sure that our comm channel write doesn't
+		 * get mixed in with writes from another CPU.
+		 */
+		mmiowb();
+	}
+}
+
 void mlx4_multi_func_cleanup(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2281,6 +2319,7 @@ void mlx4_multi_func_cleanup(struct mlx4_dev *dev)
 		kfree(priv->mfunc.master.slave_state);
 		kfree(priv->mfunc.master.vf_admin);
 		kfree(priv->mfunc.master.vf_oper);
+		dev->num_slaves = 0;
 	}
 
 	iounmap(priv->mfunc.comm);
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 7538c9c..2f2e606 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -429,8 +429,14 @@ void mlx4_master_handle_slave_flr(struct work_struct *work)
 		if (MLX4_COMM_CMD_FLR == slave_state[i].last_cmd) {
 			mlx4_dbg(dev, "mlx4_handle_slave_flr: clean slave: %d\n",
 				 i);
-
-			mlx4_delete_all_resources_for_slave(dev, i);
+			/* In case of 'Reset flow' FLR can be generated for
+			 * a slave before mlx4_load_one is done.
+			 * make sure interface is up before trying to delete
+			 * slave resources which weren't allocated yet.
+			 */
+			if (dev->persist->interface_state &
+			    MLX4_INTERFACE_STATE_UP)
+				mlx4_delete_all_resources_for_slave(dev, i);
 			/*return the slave to running mode*/
 			spin_lock_irqsave(&priv->mfunc.master.slave_state_lock, flags);
 			slave_state[i].last_cmd = MLX4_COMM_CMD_RESET;
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index fba0b96..68d2bad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -144,8 +144,7 @@ int mlx4_register_device(struct mlx4_dev *dev)
 		mlx4_add_device(intf, priv);
 
 	mutex_unlock(&intf_mutex);
-	if (!mlx4_is_slave(dev))
-		mlx4_start_catas_poll(dev);
+	mlx4_start_catas_poll(dev);
 
 	return 0;
 }
@@ -155,8 +154,7 @@ void mlx4_unregister_device(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_interface *intf;
 
-	if (!mlx4_is_slave(dev))
-		mlx4_stop_catas_poll(dev);
+	mlx4_stop_catas_poll(dev);
 	mutex_lock(&intf_mutex);
 
 	list_for_each_entry(intf, &intf_list, list)
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 01d12f7..496d6e7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -108,6 +108,8 @@ MODULE_PARM_DESC(enable_64b_cqe_eqe,
 					 MLX4_FUNC_CAP_EQE_CQE_STRIDE | \
 					 MLX4_FUNC_CAP_DMFS_A0_STATIC)
 
+#define RESET_PERSIST_MASK_FLAGS	(MLX4_FLAG_SRIOV)
+
 static char mlx4_version[] =
 	DRV_NAME ": Mellanox ConnectX core driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
@@ -1579,6 +1581,50 @@ static void mlx4_close_fw(struct mlx4_dev *dev)
 	}
 }
 
+static int mlx4_comm_check_offline(struct mlx4_dev *dev)
+{
+#define COMM_CHAN_OFFLINE_OFFSET 0x09
+
+	u32 comm_flags;
+	u32 offline_bit;
+	unsigned long end;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	end = msecs_to_jiffies(MLX4_COMM_OFFLINE_TIME_OUT) + jiffies;
+	while (time_before(jiffies, end)) {
+		comm_flags = swab32(readl((__iomem char *)priv->mfunc.comm +
+					  MLX4_COMM_CHAN_FLAGS));
+		offline_bit = (comm_flags &
+			       (u32)(1 << COMM_CHAN_OFFLINE_OFFSET));
+		if (!offline_bit)
+			return 0;
+		/* There are cases as part of AER/Reset flow that PF needs
+		 * around 100 msec to load. We therefore sleep for 100 msec
+		 * to allow other tasks to make use of that CPU during this
+		 * time interval.
+		 */
+		msleep(100);
+	}
+	mlx4_err(dev, "Communication channel is offline.\n");
+	return -EIO;
+}
+
+static void mlx4_reset_vf_support(struct mlx4_dev *dev)
+{
+#define COMM_CHAN_RST_OFFSET 0x1e
+
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	u32 comm_rst;
+	u32 comm_caps;
+
+	comm_caps = swab32(readl((__iomem char *)priv->mfunc.comm +
+				 MLX4_COMM_CHAN_CAPS));
+	comm_rst = (comm_caps & (u32)(1 << COMM_CHAN_RST_OFFSET));
+
+	if (comm_rst)
+		dev->caps.vf_caps |= MLX4_VF_CAP_FLAG_RESET;
+}
+
 static int mlx4_init_slave(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -1594,6 +1640,12 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
 
 	mutex_lock(&priv->cmd.slave_cmd_mutex);
 	priv->cmd.max_cmds = 1;
+	if (mlx4_comm_check_offline(dev)) {
+		mlx4_err(dev, "PF is not responsive, skipping initialization\n");
+		goto err_offline;
+	}
+
+	mlx4_reset_vf_support(dev);
 	mlx4_warn(dev, "Sending reset\n");
 	ret_from_reset = mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0,
 				       MLX4_COMM_TIME);
@@ -1637,6 +1689,7 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
 
 err:
 	mlx4_comm_cmd(dev, MLX4_COMM_CMD_RESET, 0, 0);
+err_offline:
 	mutex_unlock(&priv->cmd.slave_cmd_mutex);
 	return -EIO;
 }
@@ -2494,11 +2547,19 @@ static void mlx4_free_ownership(struct mlx4_dev *dev)
 				  !!((flags) & MLX4_FLAG_MASTER))
 
 static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
-			     u8 total_vfs, int existing_vfs)
+			     u8 total_vfs, int existing_vfs, int reset_flow)
 {
 	u64 dev_flags = dev->flags;
 	int err = 0;
 
+	if (reset_flow) {
+		dev->dev_vfs = kcalloc(total_vfs, sizeof(*dev->dev_vfs),
+				       GFP_KERNEL);
+		if (!dev->dev_vfs)
+			goto free_mem;
+		return dev_flags;
+	}
+
 	atomic_inc(&pf_loading);
 	if (dev->flags &  MLX4_FLAG_SRIOV) {
 		if (existing_vfs != total_vfs) {
@@ -2533,6 +2594,7 @@ static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
 
 disable_sriov:
 	atomic_dec(&pf_loading);
+free_mem:
 	dev->persist->num_vfs = 0;
 	kfree(dev->dev_vfs);
 	return dev_flags & ~MLX4_FLAG_MASTER;
@@ -2557,7 +2619,8 @@ static int mlx4_check_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap
 }
 
 static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
-			 int total_vfs, int *nvfs, struct mlx4_priv *priv)
+			 int total_vfs, int *nvfs, struct mlx4_priv *priv,
+			 int reset_flow)
 {
 	struct mlx4_dev *dev;
 	unsigned sum = 0;
@@ -2679,8 +2742,10 @@ slave_start:
 				goto err_fw;
 
 			if (!(dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS)) {
-				u64 dev_flags = mlx4_enable_sriov(dev, pdev, total_vfs,
-								  existing_vfs);
+				u64 dev_flags = mlx4_enable_sriov(dev, pdev,
+								  total_vfs,
+								  existing_vfs,
+								  reset_flow);
 
 				mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
 				dev->flags = dev_flags;
@@ -2722,7 +2787,7 @@ slave_start:
 			if (dev->flags & MLX4_FLAG_SRIOV) {
 				if (!existing_vfs)
 					pci_disable_sriov(pdev);
-				if (mlx4_is_master(dev))
+				if (mlx4_is_master(dev) && !reset_flow)
 					atomic_dec(&pf_loading);
 				dev->flags &= ~MLX4_FLAG_SRIOV;
 			}
@@ -2736,7 +2801,8 @@ slave_start:
 	}
 
 	if (mlx4_is_master(dev) && (dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_SYS_EQS)) {
-		u64 dev_flags = mlx4_enable_sriov(dev, pdev, total_vfs, existing_vfs);
+		u64 dev_flags = mlx4_enable_sriov(dev, pdev, total_vfs,
+						  existing_vfs, reset_flow);
 
 		if ((dev->flags ^ dev_flags) & (MLX4_FLAG_MASTER | MLX4_FLAG_SLAVE)) {
 			mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_VHCR);
@@ -2848,6 +2914,17 @@ slave_start:
 		goto err_steer;
 
 	mlx4_init_quotas(dev);
+	/* When PF resources are ready arm its comm channel to enable
+	 * getting commands
+	 */
+	if (mlx4_is_master(dev)) {
+		err = mlx4_ARM_COMM_CHANNEL(dev);
+		if (err) {
+			mlx4_err(dev, " Failed to arm comm channel eq: %x\n",
+				 err);
+			goto err_steer;
+		}
+	}
 
 	for (port = 1; port <= dev->caps.num_ports; port++) {
 		err = mlx4_init_port_info(dev, port);
@@ -2866,7 +2943,7 @@ slave_start:
 
 	priv->removed = 0;
 
-	if (mlx4_is_master(dev) && dev->persist->num_vfs)
+	if (mlx4_is_master(dev) && dev->persist->num_vfs && !reset_flow)
 		atomic_dec(&pf_loading);
 
 	kfree(dev_cap);
@@ -2925,10 +3002,12 @@ err_cmd:
 	mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
 
 err_sriov:
-	if (dev->flags & MLX4_FLAG_SRIOV && !existing_vfs)
+	if (dev->flags & MLX4_FLAG_SRIOV && !existing_vfs) {
 		pci_disable_sriov(pdev);
+		dev->flags &= ~MLX4_FLAG_SRIOV;
+	}
 
-	if (mlx4_is_master(dev) && dev->persist->num_vfs)
+	if (mlx4_is_master(dev) && dev->persist->num_vfs && !reset_flow)
 		atomic_dec(&pf_loading);
 
 	kfree(priv->dev.dev_vfs);
@@ -3073,7 +3152,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 	if (err)
 		goto err_release_regions;
 
-	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv);
+	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv, 0);
 	if (err)
 		goto err_catas;
 
@@ -3131,9 +3210,11 @@ static void mlx4_clean_dev(struct mlx4_dev *dev)
 {
 	struct mlx4_dev_persistent *persist = dev->persist;
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	unsigned long	flags = (dev->flags & RESET_PERSIST_MASK_FLAGS);
 
 	memset(priv, 0, sizeof(*priv));
 	priv->dev.persist = persist;
+	priv->dev.flags = flags;
 }
 
 static void mlx4_unload_one(struct pci_dev *pdev)
@@ -3143,7 +3224,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int               pci_dev_data;
 	int p, i;
-	int active_vfs = 0;
 
 	if (priv->removed)
 		return;
@@ -3157,14 +3237,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 
 	pci_dev_data = priv->pci_dev_data;
 
-	/* Disabling SR-IOV is not allowed while there are active vf's */
-	if (mlx4_is_master(dev)) {
-		active_vfs = mlx4_how_many_lives_vf(dev);
-		if (active_vfs) {
-			pr_warn("Removing PF when there are active VF's !!\n");
-			pr_warn("Will not disable SR-IOV.\n");
-		}
-	}
 	mlx4_stop_sense(dev);
 	mlx4_unregister_device(dev);
 
@@ -3208,12 +3280,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 
 	if (dev->flags & MLX4_FLAG_MSI_X)
 		pci_disable_msix(pdev);
-	if (dev->flags & MLX4_FLAG_SRIOV && !active_vfs) {
-		mlx4_warn(dev, "Disabling SR-IOV\n");
-		pci_disable_sriov(pdev);
-		dev->flags &= ~MLX4_FLAG_SRIOV;
-		dev->persist->num_vfs = 0;
-	}
 
 	if (!mlx4_is_slave(dev))
 		mlx4_free_ownership(dev);
@@ -3235,11 +3301,21 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	struct mlx4_dev_persistent *persist = pci_get_drvdata(pdev);
 	struct mlx4_dev  *dev  = persist->dev;
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	int active_vfs = 0;
 
 	mutex_lock(&persist->interface_state_mutex);
 	persist->interface_state |= MLX4_INTERFACE_STATE_DELETION;
 	mutex_unlock(&persist->interface_state_mutex);
 
+	/* Disabling SR-IOV is not allowed while there are active vf's */
+	if (mlx4_is_master(dev) && dev->flags & MLX4_FLAG_SRIOV) {
+		active_vfs = mlx4_how_many_lives_vf(dev);
+		if (active_vfs) {
+			pr_warn("Removing PF when there are active VF's !!\n");
+			pr_warn("Will not disable SR-IOV.\n");
+		}
+	}
+
 	/* device marked to be under deletion running now without the lock
 	 * letting other tasks to be terminated
 	 */
@@ -3248,6 +3324,11 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	else
 		mlx4_info(dev, "%s: interface is down\n", __func__);
 	mlx4_catas_end(dev);
+	if (dev->flags & MLX4_FLAG_SRIOV && !active_vfs) {
+		mlx4_warn(dev, "Disabling SR-IOV\n");
+		pci_disable_sriov(pdev);
+	}
+
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	kfree(dev->persist);
@@ -3287,7 +3368,7 @@ int mlx4_restart_one(struct pci_dev *pdev)
 	memcpy(nvfs, dev->persist->nvfs, sizeof(dev->persist->nvfs));
 
 	mlx4_unload_one(pdev);
-	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv);
+	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv, 1);
 	if (err) {
 		mlx4_err(dev, "%s: ERROR: mlx4_load_one failed, pci_name=%s, err=%d\n",
 			 __func__, pci_name(pdev), err);
@@ -3396,7 +3477,7 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 	mutex_lock(&persist->interface_state_mutex);
 	if (!(persist->interface_state & MLX4_INTERFACE_STATE_UP)) {
 		ret = mlx4_load_one(pdev, priv->pci_dev_data, total_vfs, nvfs,
-				    priv);
+				    priv, 1);
 		if (ret) {
 			mlx4_err(dev, "%s: mlx4_load_one failed, ret=%d\n",
 				 __func__,  ret);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 5c772ea..2a15b82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -85,7 +85,9 @@ enum {
 	MLX4_CLR_INT_SIZE	= 0x00008,
 	MLX4_SLAVE_COMM_BASE	= 0x0,
 	MLX4_COMM_PAGESIZE	= 0x1000,
-	MLX4_CLOCK_SIZE		= 0x00008
+	MLX4_CLOCK_SIZE		= 0x00008,
+	MLX4_COMM_CHAN_CAPS	= 0x8,
+	MLX4_COMM_CHAN_FLAGS	= 0xc
 };
 
 enum {
@@ -120,6 +122,8 @@ enum mlx4_mpt_state {
 };
 
 #define MLX4_COMM_TIME		10000
+#define MLX4_COMM_OFFLINE_TIME_OUT 30000
+
 enum {
 	MLX4_COMM_CMD_RESET,
 	MLX4_COMM_CMD_VHCR0,
@@ -1162,6 +1166,7 @@ enum {
 int mlx4_cmd_init(struct mlx4_dev *dev);
 void mlx4_cmd_cleanup(struct mlx4_dev *dev, int cleanup_mask);
 int mlx4_multi_func_init(struct mlx4_dev *dev);
+int mlx4_ARM_COMM_CHANNEL(struct mlx4_dev *dev);
 void mlx4_multi_func_cleanup(struct mlx4_dev *dev);
 void mlx4_cmd_event(struct mlx4_dev *dev, u16 token, u8 status, u64 out_param);
 int mlx4_cmd_use_events(struct mlx4_dev *dev);
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index e754384..c989442 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -280,6 +280,7 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_stat
 int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
 			      struct mlx4_config_dev_params *params);
 void mlx4_cmd_wake_completions(struct mlx4_dev *dev);
+void mlx4_report_internal_err_comm_event(struct mlx4_dev *dev);
 /*
  * mlx4_get_slave_default_vlan -
  * return true if VST ( default vlan)
@@ -289,5 +290,6 @@ bool mlx4_get_slave_default_vlan(struct mlx4_dev *dev, int port, int slave,
 				 u16 *vlan, u8 *qos);
 
 #define MLX4_COMM_GET_IF_REV(cmd_chan_ver) (u8)((cmd_chan_ver) >> 8)
+#define COMM_CHAN_EVENT_INTERNAL_ERR (1 << 17)
 
 #endif /* MLX4_CMD_H */
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 33f9ca7..5ef54e1 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -208,6 +208,10 @@ enum {
 	MLX4_QUERY_FUNC_FLAGS_A0_RES_QP		= 1LL << 1
 };
 
+enum {
+	MLX4_VF_CAP_FLAG_RESET			= 1 << 0
+};
+
 /* bit enums for an 8-bit flags field indicating special use
  * QPs which require special handling in qp_reserve_range.
  * Currently, this only includes QPs used by the ETH interface,
@@ -545,6 +549,7 @@ struct mlx4_caps {
 	u8			alloc_res_qp_mask;
 	u32			dmfs_high_rate_qpn_base;
 	u32			dmfs_high_rate_qpn_range;
+	u32			vf_caps;
 };
 
 struct mlx4_buf_list {
-- 
1.7.1
