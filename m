From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 8/8 net-next] cnic: Add support for 57712 device
Date: Wed, 13 Oct 2010 17:06:51 -0700
Message-ID: <1287014811-10979-9-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
 <1287014811-10979-2-git-send-email-mchan@broadcom.com>
 <1287014811-10979-3-git-send-email-mchan@broadcom.com>
 <1287014811-10979-4-git-send-email-mchan@broadcom.com>
 <1287014811-10979-5-git-send-email-mchan@broadcom.com>
 <1287014811-10979-6-git-send-email-mchan@broadcom.com>
 <1287014811-10979-7-git-send-email-mchan@broadcom.com>
 <1287014811-10979-8-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1650 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752878Ab0JNBEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:04:01 -0400
In-Reply-To: <1287014811-10979-8-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new interrupt ack functions and other hardware interface logic to
support the new device.

Update version to 2.2.6.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c    |   94 +++++++++++++++++++++++++++++++++++++++++--------
 drivers/net/cnic.h    |   22 +++++++++++
 drivers/net/cnic_if.h |    4 +-
 3 files changed, 103 insertions(+), 17 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 3f923a7..92bac19 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1077,7 +1077,7 @@ static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 
 	cp->ctx_blks = blks;
 	cp->ctx_blk_size = ctx_blk_size;
-	if (BNX2X_CHIP_IS_E1H(cp->chip_id))
+	if (!BNX2X_CHIP_IS_57710(cp->chip_id))
 		cp->ctx_align = 0;
 	else
 		cp->ctx_align = ctx_blk_size;
@@ -2406,6 +2406,22 @@ static inline void cnic_ack_bnx2x_int(struct cnic_dev *dev, u8 id, u8 storm,
 	CNIC_WR(dev, hc_addr, (*(u32 *)&igu_ack));
 }
 
+static void cnic_ack_igu_sb(struct cnic_dev *dev, u8 igu_sb_id, u8 segment,
+			    u16 index, u8 op, u8 update)
+{
+	struct igu_regular cmd_data;
+	u32 igu_addr = BAR_IGU_INTMEM + (IGU_CMD_INT_ACK_BASE + igu_sb_id) * 8;
+
+	cmd_data.sb_id_and_flags =
+		(index << IGU_REGULAR_SB_INDEX_SHIFT) |
+		(segment << IGU_REGULAR_SEGMENT_ACCESS_SHIFT) |
+		(update << IGU_REGULAR_BUPDATE_SHIFT) |
+		(op << IGU_REGULAR_ENABLE_INT_SHIFT);
+
+
+	CNIC_WR(dev, igu_addr, cmd_data.sb_id_and_flags);
+}
+
 static void cnic_ack_bnx2x_msix(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -2414,6 +2430,14 @@ static void cnic_ack_bnx2x_msix(struct cnic_dev *dev)
 			   IGU_INT_DISABLE, 0);
 }
 
+static void cnic_ack_bnx2x_e2_msix(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	cnic_ack_igu_sb(dev, cp->bnx2x_igu_sb_id, IGU_SEG_ACCESS_DEF, 0,
+			IGU_INT_DISABLE, 0);
+}
+
 static u32 cnic_service_bnx2x_kcq(struct cnic_dev *dev, struct kcq_info *info)
 {
 	u32 last_status = *info->status_idx_ptr;
@@ -2445,8 +2469,12 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 	status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq1);
 
 	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
-	cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, USTORM_ID,
-			   status_idx, IGU_INT_ENABLE, 1);
+	if (BNX2X_CHIP_IS_E2(cp->chip_id))
+		cnic_ack_igu_sb(dev, cp->bnx2x_igu_sb_id, IGU_SEG_ACCESS_DEF,
+				status_idx, IGU_INT_ENABLE, 1);
+	else
+		cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, USTORM_ID,
+				   status_idx, IGU_INT_ENABLE, 1);
 }
 
 static int cnic_service_bnx2x(void *data, void *status_blk)
@@ -4208,7 +4236,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	u32 base, addr, val;
+	u32 base, base2, addr, val;
 	int port = CNIC_PORT(cp);
 
 	dev->max_iscsi_conn = 0;
@@ -4216,6 +4244,8 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 	if (base == 0)
 		return;
 
+	base2 = CNIC_RD(dev, (CNIC_PATH(cp) ? MISC_REG_GENERIC_CR_1 :
+					      MISC_REG_GENERIC_CR_0));
 	addr = BNX2X_SHMEM_ADDR(base,
 		dev_info.port_hw_config[port].iscsi_mac_upper);
 
@@ -4248,11 +4278,15 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 			val16 ^= 0x1e1e;
 		dev->max_iscsi_conn = val16;
 	}
-	if (BNX2X_CHIP_IS_E1H(cp->chip_id)) {
+	if (BNX2X_CHIP_IS_E1H(cp->chip_id) || BNX2X_CHIP_IS_E2(cp->chip_id)) {
 		int func = CNIC_FUNC(cp);
 		u32 mf_cfg_addr;
 
-		mf_cfg_addr = base + BNX2X_SHMEM_MF_BLK_OFFSET;
+		if (BNX2X_SHMEM2_HAS(base2, mf_cfg_addr))
+			mf_cfg_addr = CNIC_RD(dev, BNX2X_SHMEM2_ADDR(base2,
+					      mf_cfg_addr));
+		else
+			mf_cfg_addr = base + BNX2X_SHMEM_MF_BLK_OFFSET;
 
 		addr = mf_cfg_addr +
 			offsetof(struct mf_cfg, func_mf_config[func].e1hov_tag);
@@ -4277,9 +4311,22 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	int func = CNIC_FUNC(cp), ret, i;
 	u32 pfid;
-	struct host_hc_status_block_e1x *sb = cp->status_blk.gen;
 
-	cp->pfid = func;
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		u32 val = CNIC_RD(dev, MISC_REG_PORT4MODE_EN_OVWR);
+
+		if (!(val & 1))
+			val = CNIC_RD(dev, MISC_REG_PORT4MODE_EN);
+		else
+			val = (val >> 1) & 1;
+
+		if (val)
+			cp->pfid = func >> 1;
+		else
+			cp->pfid = func & 0x6;
+	} else {
+		cp->pfid = func;
+	}
 	pfid = cp->pfid;
 
 	ret = cnic_init_id_tbl(&cp->cid_tbl, MAX_ISCSI_TBL_SZ,
@@ -4294,10 +4341,21 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 			  CSTORM_ISCSI_EQ_PROD_OFFSET(pfid, 0);
 	cp->kcq1.sw_prod_idx = 0;
 
-	cp->kcq1.hw_prod_idx_ptr =
-		&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
-	cp->kcq1.status_idx_ptr =
-		&sb->sb.running_index[SM_RX_ID];
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		struct host_hc_status_block_e2 *sb = cp->status_blk.gen;
+
+		cp->kcq1.hw_prod_idx_ptr =
+			&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
+		cp->kcq1.status_idx_ptr =
+			&sb->sb.running_index[SM_RX_ID];
+	} else {
+		struct host_hc_status_block_e1x *sb = cp->status_blk.gen;
+
+		cp->kcq1.hw_prod_idx_ptr =
+			&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
+		cp->kcq1.status_idx_ptr =
+			&sb->sb.running_index[SM_RX_ID];
+	}
 
 	cnic_get_bnx2x_iscsi_info(dev);
 
@@ -4380,7 +4438,9 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		cl_qzone_id = BNX2X_CL_QZONE_ID(cp, cli);
 
 		off = BAR_USTRORM_INTMEM +
-			 USTORM_RX_PRODS_E1X_OFFSET(CNIC_PORT(cp), cli);
+			(BNX2X_CHIP_IS_E2(cp->chip_id) ?
+			 USTORM_RX_PRODS_E2_OFFSET(cl_qzone_id) :
+			 USTORM_RX_PRODS_E1X_OFFSET(CNIC_PORT(cp), cli));
 
 		for (i = 0; i < sizeof(struct ustorm_eth_rx_producers) / 4; i++)
 			CNIC_WR(dev, off + i * 4, ((u32 *) &rx_prods)[i]);
@@ -4506,7 +4566,6 @@ static int cnic_start_hw(struct cnic_dev *dev)
 		return -EALREADY;
 
 	dev->regview = ethdev->io_base;
-	cp->chip_id = ethdev->chip_id;
 	pci_dev_get(dev->pcidev);
 	cp->func = PCI_FUNC(dev->pcidev->devfn);
 	cp->status_blk.gen = ethdev->irq_arr[0].status_blk;
@@ -4683,6 +4742,7 @@ static struct cnic_dev *init_bnx2_cnic(struct net_device *dev)
 	cp = cdev->cnic_priv;
 	cp->ethdev = ethdev;
 	cdev->pcidev = pdev;
+	cp->chip_id = ethdev->chip_id;
 
 	cp->cnic_ops = &cnic_bnx2_ops;
 	cp->start_hw = cnic_start_bnx2_hw;
@@ -4737,6 +4797,7 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	cp = cdev->cnic_priv;
 	cp->ethdev = ethdev;
 	cdev->pcidev = pdev;
+	cp->chip_id = ethdev->chip_id;
 
 	cp->cnic_ops = &cnic_bnx2x_ops;
 	cp->start_hw = cnic_start_bnx2x_hw;
@@ -4748,7 +4809,10 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	cp->stop_cm = cnic_cm_stop_bnx2x_hw;
 	cp->enable_int = cnic_enable_bnx2x_int;
 	cp->disable_int_sync = cnic_disable_bnx2x_int_sync;
-	cp->ack_int = cnic_ack_bnx2x_msix;
+	if (BNX2X_CHIP_IS_E2(cp->chip_id))
+		cp->ack_int = cnic_ack_bnx2x_e2_msix;
+	else
+		cp->ack_int = cnic_ack_bnx2x_msix;
 	cp->close_conn = cnic_close_bnx2x_conn;
 	cp->next_idx = cnic_bnx2x_next_idx;
 	cp->hw_idx = cnic_bnx2x_hw_idx;
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 928af9e..6a4a0ae 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -372,15 +372,35 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_ISCSI_PBL_NOT_CACHED	0xff
 #define BNX2X_ISCSI_PDU_HEADER_NOT_CACHED	0xff
 
+#define BNX2X_CHIP_NUM_57710		0x164e
 #define BNX2X_CHIP_NUM_57711		0x164f
 #define BNX2X_CHIP_NUM_57711E		0x1650
+#define BNX2X_CHIP_NUM_57712		0x1662
+#define BNX2X_CHIP_NUM_57712E		0x1663
+#define BNX2X_CHIP_NUM_57713		0x1651
+#define BNX2X_CHIP_NUM_57713E		0x1652
+
 #define BNX2X_CHIP_NUM(x)		(x >> 16)
+#define BNX2X_CHIP_IS_57710(x)		\
+	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57710)
 #define BNX2X_CHIP_IS_57711(x)		\
 	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57711)
 #define BNX2X_CHIP_IS_57711E(x)		\
 	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57711E)
 #define BNX2X_CHIP_IS_E1H(x)		\
 	(BNX2X_CHIP_IS_57711(x) || BNX2X_CHIP_IS_57711E(x))
+#define BNX2X_CHIP_IS_57712(x)		\
+	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57712)
+#define BNX2X_CHIP_IS_57712E(x)		\
+	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57712E)
+#define BNX2X_CHIP_IS_57713(x)		\
+	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57713)
+#define BNX2X_CHIP_IS_57713E(x)		\
+	(BNX2X_CHIP_NUM(x) == BNX2X_CHIP_NUM_57713E)
+#define BNX2X_CHIP_IS_E2(x)		\
+	(BNX2X_CHIP_IS_57712(x) || BNX2X_CHIP_IS_57712E(x) || \
+	 BNX2X_CHIP_IS_57713(x) || BNX2X_CHIP_IS_57713E(x))
+
 #define IS_E1H_OFFSET       		BNX2X_CHIP_IS_E1H(cp->chip_id)
 
 #define BNX2X_RX_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_rx_bd))
@@ -409,6 +429,8 @@ struct bnx2x_bd_chain_next {
 
 #define CNIC_PORT(cp)			((cp)->pfid & 1)
 #define CNIC_FUNC(cp)			((cp)->func)
+#define CNIC_PATH(cp)			(!BNX2X_CHIP_IS_E2(cp->chip_id) ? 0 :\
+					 (CNIC_FUNC(cp) & 1))
 #define CNIC_E1HVN(cp)			((cp)->pfid >> 1)
 
 #define BNX2X_HW_CID(cp, x)		((CNIC_PORT(cp) << 23) | \
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 98ebac5..0dbeaec 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.2.5"
-#define CNIC_MODULE_RELDATE	"September 29, 2010"
+#define CNIC_MODULE_VERSION	"2.2.6"
+#define CNIC_MODULE_RELDATE	"Oct 12, 2010"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT


