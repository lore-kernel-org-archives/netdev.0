From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/4] bnx2: Add support for CNIC driver.
Date: Thu, 23 Apr 2009 17:22:40 -0700
Message-ID: <1240532563-23048-2-git-send-email-mchan@broadcom.com>
References: <1240532563-23048-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: anilgv@broadcom.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com
To: davem@davemloft.net, michaelc@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4445 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755030AbZDXBOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 21:14:43 -0400
In-Reply-To: <1240532563-23048-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add interface and functions to support a new CNIC driver to drive
the hardware for iSCSI offload.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |  193 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/bnx2.h |   18 +++++
 2 files changed, 208 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d478391..aabc030 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -49,6 +49,10 @@
 #include <linux/firmware.h>
 #include <linux/log2.h>
 
+#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
+#define BCM_CNIC 1
+#include "cnic_if.h"
+#endif
 #include "bnx2.h"
 #include "bnx2_fw.h"
 
@@ -315,6 +319,158 @@ bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 	spin_unlock_bh(&bp->indirect_lock);
 }
 
+#ifdef BCM_CNIC
+static int
+bnx2_drv_ctl(struct net_device *dev, struct drv_ctl_info *info)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	struct drv_ctl_io *io = &info->data.io;
+
+	switch (info->cmd) {
+	case DRV_CTL_IO_WR_CMD:
+		bnx2_reg_wr_ind(bp, io->offset, io->data);
+		break;
+	case DRV_CTL_IO_RD_CMD:
+		io->data = bnx2_reg_rd_ind(bp, io->offset);
+		break;
+	case DRV_CTL_CTX_WR_CMD:
+		bnx2_ctx_wr(bp, io->cid_addr, io->offset, io->data);
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void bnx2_setup_cnic_irq_info(struct bnx2 *bp)
+{
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	int sb_id;
+
+	if (bp->flags & BNX2_FLAG_USING_MSIX) {
+		cp->drv_state |= CNIC_DRV_STATE_USING_MSIX;
+		bnapi->cnic_present = 0;
+		sb_id = bp->irq_nvecs;
+		cp->irq_arr[0].irq_flags |= CNIC_IRQ_FL_MSIX;
+	} else {
+		cp->drv_state &= ~CNIC_DRV_STATE_USING_MSIX;
+		bnapi->cnic_tag = bnapi->last_status_idx;
+		bnapi->cnic_present = 1;
+		sb_id = 0;
+		cp->irq_arr[0].irq_flags &= ~CNIC_IRQ_FL_MSIX;
+	}
+
+	cp->irq_arr[0].vector = bp->irq_tbl[sb_id].vector;
+	cp->irq_arr[0].status_blk = (void *)
+		((unsigned long) bnapi->status_blk.msi +
+		(BNX2_SBLK_MSIX_ALIGN_SIZE * sb_id));
+	cp->irq_arr[0].status_blk_num = sb_id;
+	cp->num_irq = 1;
+}
+
+static int bnx2_register_cnic(struct net_device *dev, struct cnic_ops *ops,
+			      void *data)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+	if (ops == NULL)
+		return -EINVAL;
+
+	if (cp->drv_state & CNIC_DRV_STATE_REGD)
+		return -EBUSY;
+
+	bp->cnic_data = data;
+	rcu_assign_pointer(bp->cnic_ops, ops);
+
+	cp->num_irq = 0;
+	cp->drv_state = CNIC_DRV_STATE_REGD;
+
+	bnx2_setup_cnic_irq_info(bp);
+
+	return 0;
+}
+
+static int bnx2_unregister_cnic(struct net_device *dev)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+	cp->drv_state = 0;
+	bnapi->cnic_present = 0;
+	rcu_assign_pointer(bp->cnic_ops, NULL);
+	synchronize_rcu();
+	return 0;
+}
+
+struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+	cp->drv_owner = THIS_MODULE;
+	cp->chip_id = bp->chip_id;
+	cp->pdev = bp->pdev;
+	cp->io_base = bp->regview;
+	cp->drv_ctl = bnx2_drv_ctl;
+	cp->drv_register_cnic = bnx2_register_cnic;
+	cp->drv_unregister_cnic = bnx2_unregister_cnic;
+
+	return cp;
+}
+EXPORT_SYMBOL(bnx2_cnic_probe);
+
+static void
+bnx2_cnic_stop(struct bnx2 *bp)
+{
+	struct cnic_ops *c_ops;
+	struct cnic_ctl_info info;
+
+	rcu_read_lock();
+	c_ops = rcu_dereference(bp->cnic_ops);
+	if (c_ops) {
+		info.cmd = CNIC_CTL_STOP_CMD;
+		c_ops->cnic_ctl(bp->cnic_data, &info);
+	}
+	rcu_read_unlock();
+}
+
+static void
+bnx2_cnic_start(struct bnx2 *bp)
+{
+	struct cnic_ops *c_ops;
+	struct cnic_ctl_info info;
+
+	rcu_read_lock();
+	c_ops = rcu_dereference(bp->cnic_ops);
+	if (c_ops) {
+		if (!(bp->flags & BNX2_FLAG_USING_MSIX)) {
+			struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+
+			bnapi->cnic_tag = bnapi->last_status_idx;
+		}
+		info.cmd = CNIC_CTL_START_CMD;
+		c_ops->cnic_ctl(bp->cnic_data, &info);
+	}
+	rcu_read_unlock();
+}
+
+#else
+
+static void
+bnx2_cnic_stop(struct bnx2 *bp)
+{
+}
+
+static void
+bnx2_cnic_start(struct bnx2 *bp)
+{
+}
+
+#endif
+
 static int
 bnx2_read_phy(struct bnx2 *bp, u32 reg, u32 *val)
 {
@@ -488,6 +644,7 @@ bnx2_napi_enable(struct bnx2 *bp)
 static void
 bnx2_netif_stop(struct bnx2 *bp)
 {
+	bnx2_cnic_stop(bp);
 	bnx2_disable_int_sync(bp);
 	if (netif_running(bp->dev)) {
 		bnx2_napi_disable(bp);
@@ -504,6 +661,7 @@ bnx2_netif_start(struct bnx2 *bp)
 			netif_tx_wake_all_queues(bp->dev);
 			bnx2_napi_enable(bp);
 			bnx2_enable_int(bp);
+			bnx2_cnic_start(bp);
 		}
 	}
 }
@@ -3162,6 +3320,11 @@ bnx2_has_work(struct bnx2_napi *bnapi)
 	if (bnx2_has_fast_work(bnapi))
 		return 1;
 
+#ifdef BCM_CNIC
+	if (bnapi->cnic_present && (bnapi->cnic_tag != sblk->status_idx))
+		return 1;
+#endif
+
 	if ((sblk->status_attn_bits & STATUS_ATTN_EVENTS) !=
 	    (sblk->status_attn_bits_ack & STATUS_ATTN_EVENTS))
 		return 1;
@@ -3191,6 +3354,23 @@ bnx2_chk_missed_msi(struct bnx2 *bp)
 	bp->idle_chk_status_idx = bnapi->last_status_idx;
 }
 
+#ifdef BCM_CNIC
+static void bnx2_poll_cnic(struct bnx2 *bp, struct bnx2_napi *bnapi)
+{
+	struct cnic_ops *c_ops;
+
+	if (!bnapi->cnic_present)
+		return;
+
+	rcu_read_lock();
+	c_ops = rcu_dereference(bp->cnic_ops);
+	if (c_ops)
+		bnapi->cnic_tag = c_ops->cnic_handler(bp->cnic_data,
+						      bnapi->status_blk.msi);
+	rcu_read_unlock();
+}
+#endif
+
 static void bnx2_poll_link(struct bnx2 *bp, struct bnx2_napi *bnapi)
 {
 	struct status_block *sblk = bnapi->status_blk.msi;
@@ -3265,6 +3445,10 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 
 		work_done = bnx2_poll_work(bp, bnapi, work_done, budget);
 
+#ifdef BCM_CNIC
+		bnx2_poll_cnic(bp, bnapi);
+#endif
+
 		/* bnapi->last_status_idx is used below to tell the hw how
 		 * much work has been processed, so we must read it before
 		 * checking for more work.
@@ -4630,8 +4814,11 @@ bnx2_init_chip(struct bnx2 *bp)
 	val = REG_RD(bp, BNX2_MQ_CONFIG);
 	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
 	val |= BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE_256;
-	if (CHIP_ID(bp) == CHIP_ID_5709_A0 || CHIP_ID(bp) == CHIP_ID_5709_A1)
-		val |= BNX2_MQ_CONFIG_HALT_DIS;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		val |= BNX2_MQ_CONFIG_BIN_MQ_MODE;
+		if (CHIP_REV(bp) == CHIP_REV_Ax)
+			val |= BNX2_MQ_CONFIG_HALT_DIS;
+	}
 
 	REG_WR(bp, BNX2_MQ_CONFIG, val);
 
@@ -7469,7 +7656,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	INIT_WORK(&bp->reset_task, bnx2_reset_task);
 
 	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);
-	mem_len = MB_GET_CID_ADDR(TX_TSS_CID + TX_MAX_TSS_RINGS);
+	mem_len = MB_GET_CID_ADDR(TX_TSS_CID + TX_MAX_TSS_RINGS + 1);
 	dev->mem_end = dev->mem_start + mem_len;
 	dev->irq = pdev->irq;
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 5b570e1..a1ff739 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -361,6 +361,9 @@ struct l2_fhdr {
 #define BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE	 (1<<28)
 
 #define BNX2_L2CTX_HOST_BDIDX				0x00000004
+#define BNX2_L2CTX_STATUSB_NUM_SHIFT			 16
+#define BNX2_L2CTX_STATUSB_NUM(sb_id)			 \
+	(((sb_id) > 0) ? (((sb_id) + 7) << BNX2_L2CTX_STATUSB_NUM_SHIFT) : 0)
 #define BNX2_L2CTX_HOST_BSEQ				0x00000008
 #define BNX2_L2CTX_NX_BSEQ				0x0000000c
 #define BNX2_L2CTX_NX_BDHADDR_HI			0x00000010
@@ -5900,6 +5903,7 @@ struct l2_fhdr {
 #define BNX2_RXP_FTQ_CTL_CUR_DEPTH			 (0x3ffL<<22)
 
 #define BNX2_RXP_SCRATCH				0x000e0000
+#define BNX2_RXP_SCRATCH_RXP_FLOOD			 0x000e0024
 #define BNX2_RXP_SCRATCH_RSS_TBL_SZ			 0x000e0038
 #define BNX2_RXP_SCRATCH_RSS_TBL			 0x000e003c
 #define BNX2_RXP_SCRATCH_RSS_TBL_MAX_ENTRIES		 128
@@ -6678,6 +6682,11 @@ struct bnx2_napi {
 	u32 			last_status_idx;
 	u32			int_num;
 
+#ifdef BCM_CNIC
+	u32			cnic_tag;
+	int			cnic_present;
+#endif
+
 	struct bnx2_rx_ring_info	rx_ring;
 	struct bnx2_tx_ring_info	tx_ring;
 };
@@ -6727,6 +6736,11 @@ struct bnx2 {
 	int		tx_ring_size;
 	u32		tx_wake_thresh;
 
+#ifdef BCM_CNIC
+	struct cnic_ops		*cnic_ops;
+	void			*cnic_data;
+#endif
+
 	/* End of fields used in the performance code paths. */
 
 	unsigned int		current_interval;
@@ -6885,6 +6899,10 @@ struct bnx2 {
 
 	u32			idle_chk_status_idx;
 
+#ifdef BCM_CNIC
+	struct cnic_eth_dev	cnic_eth_dev;
+#endif
+
 	const struct firmware	*mips_firmware;
 	const struct firmware	*rv2p_firmware;
 };
-- 
1.5.6.GIT


