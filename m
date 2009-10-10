From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/7] bnx2x: Add main CNIC interface functions.
Date: Sat, 10 Oct 2009 16:46:56 -0700
Message-ID: <1255218419-17320-4-git-send-email-mchan@broadcom.com>
References: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	shmulikr@broadcom.com, eilong@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1959 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755013AbZJJXjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 19:39:07 -0400
In-Reply-To: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the main CNIC registration, callback, MAC addr. setup functions.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Shmulik Ravid - Rabinovitz <shmulikr@broadcom.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    4 +
 drivers/net/bnx2x_main.c |  388 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/cnic_if.h    |   14 ++-
 3 files changed, 404 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index e94ce83..60fa14f 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -24,6 +24,10 @@
 #define BCM_VLAN			1
 #endif
 
+#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
+#define BCM_CNIC 1
+#include "cnic_if.h"
+#endif
 
 #define BNX2X_MULTI_QUEUE
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f7b7110..b4e9c6e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -969,6 +969,9 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	}
 }
 
+#ifdef BCM_CNIC
+static void bnx2x_cnic_cfc_comp(struct bnx2x *bp, int cid);
+#endif
 
 static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 			   union eth_rx_cqe *rr_cqe)
@@ -1025,6 +1028,12 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		bnx2x_fp(bp, cid, state) = BNX2X_FP_STATE_CLOSED;
 		break;
 
+#ifdef BCM_CNIC
+	case (RAMROD_CMD_ID_ETH_CFC_DEL | BNX2X_STATE_OPEN):
+		DP(NETIF_MSG_IFDOWN, "got delete ramrod for CID %d\n", cid);
+		bnx2x_cnic_cfc_comp(bp, cid);
+		break;
+#endif
 
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DIAG):
@@ -1810,6 +1819,20 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		}
 	}
 
+#ifdef BCM_CNIC
+	mask = 0x2 << CNIC_SB_ID(bp);
+	if (status & (mask | 0x1)) {
+		struct cnic_ops *c_ops = NULL;
+
+		rcu_read_lock();
+		c_ops = rcu_dereference(bp->cnic_ops);
+		if (c_ops)
+			c_ops->cnic_handler(bp->cnic_data, NULL);
+		rcu_read_unlock();
+
+		status &= ~mask;
+	}
+#endif
 
 	if (unlikely(status & 0x1)) {
 		queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);
@@ -3247,6 +3270,17 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 #endif
 
+#ifdef BCM_CNIC
+	{
+		struct cnic_ops *c_ops;
+
+		rcu_read_lock();
+		c_ops = rcu_dereference(bp->cnic_ops);
+		if (c_ops)
+			c_ops->cnic_handler(bp->cnic_data, NULL);
+		rcu_read_unlock();
+	}
+#endif
 	queue_delayed_work(bnx2x_wq, &bp->sp_task, 0);
 
 	return IRQ_HANDLED;
@@ -7291,6 +7325,44 @@ static void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set)
 	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
 }
 
+#ifdef BCM_CNIC
+/**
+ * Set iSCSI MAC(s) at the next enties in the CAM after the ETH
+ * MAC(s). This function will wait until the ramdord completion
+ * returns.
+ *
+ * @param bp driver handle
+ * @param set set or clear the CAM entry
+ *
+ * @return 0 if cussess, -ENODEV if ramrod doesn't return.
+ */
+static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
+{
+	u32 cl_bit_vec = (1 << BCM_ISCSI_ETH_CL_ID);
+
+	bp->set_mac_pending++;
+	smp_wmb();
+
+	/* Send a SET_MAC ramrod */
+	if (CHIP_IS_E1(bp))
+		bnx2x_set_mac_addr_e1_gen(bp, set, bp->iscsi_mac,
+				  cl_bit_vec, (BP_PORT(bp) ? 32 : 0) + 2,
+				  1);
+	else
+		/* CAM allocation for E1H
+		* unicasts: by func number
+		* multicast: 20+FUNC*20, 20 each
+		*/
+		bnx2x_set_mac_addr_e1h_gen(bp, set, bp->iscsi_mac,
+				   cl_bit_vec, E1H_FUNC_MAX + BP_FUNC(bp));
+
+	/* Wait for a completion when setting */
+	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
+
+	return 0;
+}
+#endif
+
 static int bnx2x_setup_leading(struct bnx2x *bp)
 {
 	int rc;
@@ -7416,6 +7488,10 @@ static int bnx2x_set_int_mode(struct bnx2x *bp)
 	return rc;
 }
 
+#ifdef BCM_CNIC
+static int bnx2x_cnic_notify(struct bnx2x *bp, int cmd);
+static void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
+#endif
 
 /* must be called with rtnl_lock */
 static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
@@ -7576,6 +7652,15 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			bnx2x_set_eth_mac_addr_e1(bp, 1);
 		else
 			bnx2x_set_eth_mac_addr_e1h(bp, 1);
+#ifdef BCM_CNIC
+		/* Set iSCSI L2 MAC */
+		mutex_lock(&bp->cnic_mutex);
+		if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD) {
+			bnx2x_set_iscsi_eth_mac_addr(bp, 1);
+			bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
+		}
+		mutex_unlock(&bp->cnic_mutex);
+#endif
 	}
 
 	if (bp->port.pmf)
@@ -7616,6 +7701,11 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* start the timer */
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 
+#ifdef BCM_CNIC
+	bnx2x_setup_cnic_irq_info(bp);
+	if (bp->state == BNX2X_STATE_OPEN)
+		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
+#endif
 
 	return 0;
 
@@ -7810,6 +7900,9 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	u32 reset_code = 0;
 	int i, cnt, rc;
 
+#ifdef BCM_CNIC
+	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
+#endif
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
 	/* Set "drop all" */
@@ -7886,6 +7979,15 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 		REG_WR(bp, MISC_REG_E1HMF_MODE, 0);
 	}
+#ifdef BCM_CNIC
+	/* Clear iSCSI L2 MAC */
+	mutex_lock(&bp->cnic_mutex);
+	if (bp->cnic_flags & BNX2X_CNIC_FLAG_MAC_SET) {
+		bnx2x_set_iscsi_eth_mac_addr(bp, 0);
+		bp->cnic_flags &= ~BNX2X_CNIC_FLAG_MAC_SET;
+	}
+	mutex_unlock(&bp->cnic_mutex);
+#endif
 
 	if (unload_mode == UNLOAD_NORMAL)
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
@@ -8855,6 +8957,9 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
 
 	mutex_init(&bp->port.phy_mutex);
+#ifdef BCM_CNIC
+	mutex_init(&bp->cnic_mutex);
+#endif
 
 	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
 	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
@@ -12448,4 +12553,287 @@ static void __exit bnx2x_cleanup(void)
 module_init(bnx2x_init);
 module_exit(bnx2x_cleanup);
 
+#ifdef BCM_CNIC
+
+/* count denotes the number of new completions we have seen */
+static void bnx2x_cnic_sp_post(struct bnx2x *bp, int count)
+{
+	struct eth_spe *spe;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return;
+#endif
+
+	spin_lock_bh(&bp->spq_lock);
+	bp->cnic_spq_pending -= count;
+
+	for (; bp->cnic_spq_pending < bp->cnic_eth_dev.max_kwqe_pending;
+	     bp->cnic_spq_pending++) {
+
+		if (!bp->cnic_kwq_pending)
+			break;
+
+		spe = bnx2x_sp_get_next(bp);
+		*spe = *bp->cnic_kwq_cons;
+
+		bp->cnic_kwq_pending--;
+
+		DP(NETIF_MSG_TIMER, "pending on SPQ %d, on KWQ %d count %d\n",
+		   bp->cnic_spq_pending, bp->cnic_kwq_pending, count);
+
+		if (bp->cnic_kwq_cons == bp->cnic_kwq_last)
+			bp->cnic_kwq_cons = bp->cnic_kwq;
+		else
+			bp->cnic_kwq_cons++;
+	}
+	bnx2x_sp_prod_update(bp);
+	spin_unlock_bh(&bp->spq_lock);
+}
+
+static int bnx2x_cnic_sp_queue(struct net_device *dev,
+			       struct kwqe_16 *kwqes[], u32 count)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int i;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return -EIO;
+#endif
+
+	spin_lock_bh(&bp->spq_lock);
+
+	for (i = 0; i < count; i++) {
+		struct eth_spe *spe = (struct eth_spe *)kwqes[i];
+
+		if (bp->cnic_kwq_pending == MAX_SP_DESC_CNT)
+			break;
+
+		*bp->cnic_kwq_prod = *spe;
+
+		bp->cnic_kwq_pending++;
+
+		DP(NETIF_MSG_TIMER, "L5 SPQE %x %x %x:%x pos %d\n",
+		   spe->hdr.conn_and_cmd_data, spe->hdr.type,
+		   spe->data.mac_config_addr.hi,
+		   spe->data.mac_config_addr.lo,
+		   bp->cnic_kwq_pending);
+
+		if (bp->cnic_kwq_prod == bp->cnic_kwq_last)
+			bp->cnic_kwq_prod = bp->cnic_kwq;
+		else
+			bp->cnic_kwq_prod++;
+	}
+
+	spin_unlock_bh(&bp->spq_lock);
+
+	if (bp->cnic_spq_pending < bp->cnic_eth_dev.max_kwqe_pending)
+		bnx2x_cnic_sp_post(bp, 0);
+
+	return i;
+}
+
+static int bnx2x_cnic_ctl_send(struct bnx2x *bp, struct cnic_ctl_info *ctl)
+{
+	struct cnic_ops *c_ops;
+	int rc = 0;
+
+	mutex_lock(&bp->cnic_mutex);
+	c_ops = bp->cnic_ops;
+	if (c_ops)
+		rc = c_ops->cnic_ctl(bp->cnic_data, ctl);
+	mutex_unlock(&bp->cnic_mutex);
+
+	return rc;
+}
+
+static int bnx2x_cnic_ctl_send_bh(struct bnx2x *bp, struct cnic_ctl_info *ctl)
+{
+	struct cnic_ops *c_ops;
+	int rc = 0;
+
+	rcu_read_lock();
+	c_ops = rcu_dereference(bp->cnic_ops);
+	if (c_ops)
+		rc = c_ops->cnic_ctl(bp->cnic_data, ctl);
+	rcu_read_unlock();
+
+	return rc;
+}
+
+/*
+ * for commands that have no data
+ */
+static int bnx2x_cnic_notify(struct bnx2x *bp, int cmd)
+{
+	struct cnic_ctl_info ctl = {0};
+
+	ctl.cmd = cmd;
+
+	return bnx2x_cnic_ctl_send(bp, &ctl);
+}
+
+static void bnx2x_cnic_cfc_comp(struct bnx2x *bp, int cid)
+{
+	struct cnic_ctl_info ctl;
+
+	/* first we tell CNIC and only then we count this as a completion */
+	ctl.cmd = CNIC_CTL_COMPLETION_CMD;
+	ctl.data.comp.cid = cid;
+
+	bnx2x_cnic_ctl_send_bh(bp, &ctl);
+	bnx2x_cnic_sp_post(bp, 1);
+}
+
+static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int rc = 0;
+
+	switch (ctl->cmd) {
+	case DRV_CTL_CTXTBL_WR_CMD: {
+		u32 index = ctl->data.io.offset;
+		dma_addr_t addr = ctl->data.io.dma_addr;
+
+		bnx2x_ilt_wr(bp, index, addr);
+		break;
+	}
+
+	case DRV_CTL_COMPLETION_CMD: {
+		int count = ctl->data.comp.comp_count;
+
+		bnx2x_cnic_sp_post(bp, count);
+		break;
+	}
+
+	/* rtnl_lock is held.  */
+	case DRV_CTL_START_L2_CMD: {
+		u32 cli = ctl->data.ring.client_id;
+
+		bp->rx_mode_cl_mask |= (1 << cli);
+		bnx2x_set_storm_rx_mode(bp);
+		break;
+	}
+
+	/* rtnl_lock is held.  */
+	case DRV_CTL_STOP_L2_CMD: {
+		u32 cli = ctl->data.ring.client_id;
+
+		bp->rx_mode_cl_mask &= ~(1 << cli);
+		bnx2x_set_storm_rx_mode(bp);
+		break;
+	}
+
+	default:
+		BNX2X_ERR("unknown command %x\n", ctl->cmd);
+		rc = -EINVAL;
+	}
+
+	return rc;
+}
+
+static void bnx2x_setup_cnic_irq_info(struct bnx2x *bp)
+{
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+	if (bp->flags & USING_MSIX_FLAG) {
+		cp->drv_state |= CNIC_DRV_STATE_USING_MSIX;
+		cp->irq_arr[0].irq_flags |= CNIC_IRQ_FL_MSIX;
+		cp->irq_arr[0].vector = bp->msix_table[1].vector;
+	} else {
+		cp->drv_state &= ~CNIC_DRV_STATE_USING_MSIX;
+		cp->irq_arr[0].irq_flags &= ~CNIC_IRQ_FL_MSIX;
+	}
+	cp->irq_arr[0].status_blk = bp->cnic_sb;
+	cp->irq_arr[0].status_blk_num = CNIC_SB_ID(bp);
+	cp->irq_arr[1].status_blk = bp->def_status_blk;
+	cp->irq_arr[1].status_blk_num = DEF_SB_ID;
+
+	cp->num_irq = 2;
+}
+
+static int bnx2x_register_cnic(struct net_device *dev, struct cnic_ops *ops,
+			       void *data)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+	if (ops == NULL)
+		return -EINVAL;
+
+	if (atomic_read(&bp->intr_sem) != 0)
+		return -EBUSY;
+
+	bp->cnic_kwq = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!bp->cnic_kwq)
+		return -ENOMEM;
+
+	bp->cnic_kwq_cons = bp->cnic_kwq;
+	bp->cnic_kwq_prod = bp->cnic_kwq;
+	bp->cnic_kwq_last = bp->cnic_kwq + MAX_SP_DESC_CNT;
+
+	bp->cnic_spq_pending = 0;
+	bp->cnic_kwq_pending = 0;
+
+	bp->cnic_data = data;
+
+	cp->num_irq = 0;
+	cp->drv_state = CNIC_DRV_STATE_REGD;
+
+	bnx2x_init_sb(bp, bp->cnic_sb, bp->cnic_sb_mapping, CNIC_SB_ID(bp));
+
+	bnx2x_setup_cnic_irq_info(bp);
+	bnx2x_set_iscsi_eth_mac_addr(bp, 1);
+	bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
+	rcu_assign_pointer(bp->cnic_ops, ops);
+
+	return 0;
+}
+
+static int bnx2x_unregister_cnic(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+	mutex_lock(&bp->cnic_mutex);
+	if (bp->cnic_flags & BNX2X_CNIC_FLAG_MAC_SET) {
+		bp->cnic_flags &= ~BNX2X_CNIC_FLAG_MAC_SET;
+		bnx2x_set_iscsi_eth_mac_addr(bp, 0);
+	}
+	cp->drv_state = 0;
+	rcu_assign_pointer(bp->cnic_ops, NULL);
+	mutex_unlock(&bp->cnic_mutex);
+	synchronize_rcu();
+	kfree(bp->cnic_kwq);
+	bp->cnic_kwq = NULL;
+
+	return 0;
+}
+
+struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+	cp->drv_owner = THIS_MODULE;
+	cp->chip_id = CHIP_ID(bp);
+	cp->pdev = bp->pdev;
+	cp->io_base = bp->regview;
+	cp->io_base2 = bp->doorbells;
+	cp->max_kwqe_pending = 8;
+	cp->ctx_blk_size = CNIC_CTX_PER_ILT * sizeof(union cdu_context);
+	cp->ctx_tbl_offset = FUNC_ILT_BASE(BP_FUNC(bp)) + 1;
+	cp->ctx_tbl_len = CNIC_ILT_LINES;
+	cp->starting_cid = BCM_CNIC_CID_START;
+	cp->drv_submit_kwqes_16 = bnx2x_cnic_sp_queue;
+	cp->drv_ctl = bnx2x_drv_ctl;
+	cp->drv_register_cnic = bnx2x_register_cnic;
+	cp->drv_unregister_cnic = bnx2x_unregister_cnic;
+
+	return cp;
+}
+EXPORT_SYMBOL(bnx2x_cnic_probe);
+
+#endif /* BCM_CNIC */
 
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index d8b09ef..8aaf98b 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.0.1"
-#define CNIC_MODULE_RELDATE	"Oct 01, 2009"
+#define CNIC_MODULE_VERSION	"2.1.0"
+#define CNIC_MODULE_RELDATE	"Oct 10, 2009"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -81,6 +81,8 @@ struct kcqe {
 #define DRV_CTL_CTX_WR_CMD		0x103
 #define DRV_CTL_CTXTBL_WR_CMD		0x104
 #define DRV_CTL_COMPLETION_CMD		0x105
+#define DRV_CTL_START_L2_CMD		0x106
+#define DRV_CTL_STOP_L2_CMD		0x107
 
 struct cnic_ctl_completion {
 	u32	cid;
@@ -105,11 +107,17 @@ struct drv_ctl_io {
 	dma_addr_t	dma_addr;
 };
 
+struct drv_ctl_l2_ring {
+	u32		client_id;
+	u32		cid;
+};
+
 struct drv_ctl_info {
 	int	cmd;
 	union {
 		struct drv_ctl_completion comp;
 		struct drv_ctl_io io;
+		struct drv_ctl_l2_ring ring;
 		char bytes[MAX_DRV_CTL_DATA];
 	} data;
 };
@@ -143,6 +151,7 @@ struct cnic_eth_dev {
 	u32		max_kwqe_pending;
 	struct pci_dev	*pdev;
 	void __iomem	*io_base;
+	void __iomem	*io_base2;
 
 	u32		ctx_tbl_offset;
 	u32		ctx_tbl_len;
@@ -298,5 +307,6 @@ extern int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops);
 extern int cnic_unregister_driver(int ulp_type);
 
 extern struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev);
+extern struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev);
 
 #endif
-- 
1.6.4.GIT


