From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/5] cxgb4/cxgb4vf/csiostor: Cleanup PL, XGMAC, SF and MC related register defines
Date: Mon,  5 Jan 2015 16:30:47 +0530
Message-ID: <1420455647-23094-6-git-send-email-hariprasad@chelsio.com>
References: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15930 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753455AbbAEK4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 05:56:41 -0500
In-Reply-To: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleanups all PL, XGMAC and SF related macros/register defines
that are defined in t4_regs.h and the affected files

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   56 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |    9 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  258 +++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  538 +++++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |   33 ++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |    6 +-
 drivers/scsi/csiostor/csio_hw.c                    |  186 ++++----
 drivers/scsi/csiostor/csio_hw.h                    |    8 +-
 drivers/scsi/csiostor/csio_hw_chip.h               |    4 +-
 drivers/scsi/csiostor/csio_mb.c                    |    6 +-
 drivers/scsi/csiostor/csio_wr.c                    |    2 +-
 12 files changed, 594 insertions(+), 514 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 53ad8d3..04e675b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -834,11 +834,11 @@ static void disable_msi(struct adapter *adapter)
 static irqreturn_t t4_nondata_intr(int irq, void *cookie)
 {
 	struct adapter *adap = cookie;
+	u32 v = t4_read_reg(adap, MYPF_REG(PL_PF_INT_CAUSE_A));
 
-	u32 v = t4_read_reg(adap, MYPF_REG(PL_PF_INT_CAUSE));
-	if (v & PFSW) {
+	if (v & PFSW_F) {
 		adap->swintr = 1;
-		t4_write_reg(adap, MYPF_REG(PL_PF_INT_CAUSE), v);
+		t4_write_reg(adap, MYPF_REG(PL_PF_INT_CAUSE_A), v);
 	}
 	t4_slow_intr_handler(adap);
 	return IRQ_HANDLED;
@@ -3654,10 +3654,10 @@ void cxgb4_iscsi_init(struct net_device *dev, unsigned int tag_mask,
 {
 	struct adapter *adap = netdev2adap(dev);
 
-	t4_write_reg(adap, ULP_RX_ISCSI_TAGMASK, tag_mask);
-	t4_write_reg(adap, ULP_RX_ISCSI_PSZ, HPZ0(pgsz_order[0]) |
-		     HPZ1(pgsz_order[1]) | HPZ2(pgsz_order[2]) |
-		     HPZ3(pgsz_order[3]));
+	t4_write_reg(adap, ULP_RX_ISCSI_TAGMASK_A, tag_mask);
+	t4_write_reg(adap, ULP_RX_ISCSI_PSZ_A, HPZ0_V(pgsz_order[0]) |
+		     HPZ1_V(pgsz_order[1]) | HPZ2_V(pgsz_order[2]) |
+		     HPZ3_V(pgsz_order[3]));
 }
 EXPORT_SYMBOL(cxgb4_iscsi_init);
 
@@ -4580,13 +4580,13 @@ int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 			f->fs.val.lip[i] = val[i];
 			f->fs.mask.lip[i] = ~0;
 		}
-		if (adap->params.tp.vlan_pri_map & F_PORT) {
+		if (adap->params.tp.vlan_pri_map & PORT_F) {
 			f->fs.val.iport = port;
 			f->fs.mask.iport = mask;
 		}
 	}
 
-	if (adap->params.tp.vlan_pri_map & F_PROTOCOL) {
+	if (adap->params.tp.vlan_pri_map & PROTOCOL_F) {
 		f->fs.val.proto = IPPROTO_TCP;
 		f->fs.mask.proto = ~0;
 	}
@@ -4950,37 +4950,37 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 
 	/* tweak some settings */
 	t4_write_reg(adap, TP_SHIFT_CNT_A, 0x64f8849);
-	t4_write_reg(adap, ULP_RX_TDDP_PSZ, HPZ0(PAGE_SHIFT - 12));
+	t4_write_reg(adap, ULP_RX_TDDP_PSZ_A, HPZ0_V(PAGE_SHIFT - 12));
 	t4_write_reg(adap, TP_PIO_ADDR_A, TP_INGRESS_CONFIG_A);
 	v = t4_read_reg(adap, TP_PIO_DATA_A);
 	t4_write_reg(adap, TP_PIO_DATA_A, v & ~CSUM_HAS_PSEUDO_HDR_F);
 
 	/* first 4 Tx modulation queues point to consecutive Tx channels */
 	adap->params.tp.tx_modq_map = 0xE4;
-	t4_write_reg(adap, A_TP_TX_MOD_QUEUE_REQ_MAP,
-		     V_TX_MOD_QUEUE_REQ_MAP(adap->params.tp.tx_modq_map));
+	t4_write_reg(adap, TP_TX_MOD_QUEUE_REQ_MAP_A,
+		     TX_MOD_QUEUE_REQ_MAP_V(adap->params.tp.tx_modq_map));
 
 	/* associate each Tx modulation queue with consecutive Tx channels */
 	v = 0x84218421;
 	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			  &v, 1, A_TP_TX_SCHED_HDR);
+			  &v, 1, TP_TX_SCHED_HDR_A);
 	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			  &v, 1, A_TP_TX_SCHED_FIFO);
+			  &v, 1, TP_TX_SCHED_FIFO_A);
 	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A,
-			  &v, 1, A_TP_TX_SCHED_PCMD);
+			  &v, 1, TP_TX_SCHED_PCMD_A);
 
 #define T4_TX_MODQ_10G_WEIGHT_DEFAULT 16 /* in KB units */
 	if (is_offload(adap)) {
-		t4_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT0,
-			     V_TX_MODQ_WEIGHT0(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
-			     V_TX_MODQ_WEIGHT1(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
-			     V_TX_MODQ_WEIGHT2(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
-			     V_TX_MODQ_WEIGHT3(T4_TX_MODQ_10G_WEIGHT_DEFAULT));
-		t4_write_reg(adap, A_TP_TX_MOD_CHANNEL_WEIGHT,
-			     V_TX_MODQ_WEIGHT0(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
-			     V_TX_MODQ_WEIGHT1(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
-			     V_TX_MODQ_WEIGHT2(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
-			     V_TX_MODQ_WEIGHT3(T4_TX_MODQ_10G_WEIGHT_DEFAULT));
+		t4_write_reg(adap, TP_TX_MOD_QUEUE_WEIGHT0_A,
+			     TX_MODQ_WEIGHT0_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     TX_MODQ_WEIGHT1_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     TX_MODQ_WEIGHT2_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     TX_MODQ_WEIGHT3_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT));
+		t4_write_reg(adap, TP_TX_MOD_CHANNEL_WEIGHT_A,
+			     TX_MODQ_WEIGHT0_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     TX_MODQ_WEIGHT1_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     TX_MODQ_WEIGHT2_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT) |
+			     TX_MODQ_WEIGHT3_V(T4_TX_MODQ_10G_WEIGHT_DEFAULT));
 	}
 
 	/* get basic stuff going */
@@ -5059,7 +5059,7 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	 */
 	if (reset) {
 		ret = t4_fw_reset(adapter, adapter->mbox,
-				  PIORSTMODE | PIORST);
+				  PIORSTMODE_F | PIORST_F);
 		if (ret < 0)
 			goto bye;
 	}
@@ -5264,7 +5264,7 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 	 */
 	if (reset) {
 		ret = t4_fw_reset(adapter, adapter->mbox,
-				  PIORSTMODE | PIORST);
+				  PIORSTMODE_F | PIORST_F);
 		if (ret < 0)
 			goto bye;
 	}
@@ -6413,7 +6413,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_unmap_bar0;
 
 	/* We control everything through one PF */
-	func = SOURCEPF_GET(readl(regs + PL_WHOAMI));
+	func = SOURCEPF_G(readl(regs + PL_WHOAMI_A));
 	if (func != ent->driver_data) {
 		iounmap(regs);
 		pci_disable_device(pdev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index a047baa..5ae1445 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -46,6 +46,7 @@
 #include "t4_msg.h"
 #include "t4fw_api.h"
 #include "t4_regs.h"
+#include "t4_values.h"
 
 #define VLAN_NONE 0xfff
 
@@ -425,7 +426,7 @@ u64 cxgb4_select_ntuple(struct net_device *dev,
 	 * in the Compressed Filter Tuple.
 	 */
 	if (tp->vlan_shift >= 0 && l2t->vlan != VLAN_NONE)
-		ntuple |= (u64)(F_FT_VLAN_VLD | l2t->vlan) << tp->vlan_shift;
+		ntuple |= (u64)(FT_VLAN_VLD_F | l2t->vlan) << tp->vlan_shift;
 
 	if (tp->port_shift >= 0)
 		ntuple |= (u64)l2t->lport << tp->port_shift;
@@ -439,9 +440,9 @@ u64 cxgb4_select_ntuple(struct net_device *dev,
 		u32 pf = FW_VIID_PFN_G(viid);
 		u32 vld = FW_VIID_VIVLD_G(viid);
 
-		ntuple |= (u64)(V_FT_VNID_ID_VF(vf) |
-				V_FT_VNID_ID_PF(pf) |
-				V_FT_VNID_ID_VLD(vld)) << tp->vnic_shift;
+		ntuple |= (u64)(FT_VNID_ID_VF_V(vf) |
+				FT_VNID_ID_PF_V(pf) |
+				FT_VNID_ID_VLD_V(vld)) << tp->vnic_shift;
 	}
 
 	return ntuple;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cf0bf79..3776279 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -761,14 +761,13 @@ static int sf1_read(struct adapter *adapter, unsigned int byte_cnt, int cont,
 
 	if (!byte_cnt || byte_cnt > 4)
 		return -EINVAL;
-	if (t4_read_reg(adapter, SF_OP) & SF_BUSY)
+	if (t4_read_reg(adapter, SF_OP_A) & SF_BUSY_F)
 		return -EBUSY;
-	cont = cont ? SF_CONT : 0;
-	lock = lock ? SF_LOCK : 0;
-	t4_write_reg(adapter, SF_OP, lock | cont | BYTECNT(byte_cnt - 1));
-	ret = t4_wait_op_done(adapter, SF_OP, SF_BUSY, 0, SF_ATTEMPTS, 5);
+	t4_write_reg(adapter, SF_OP_A, SF_LOCK_V(lock) |
+		     SF_CONT_V(cont) | BYTECNT_V(byte_cnt - 1));
+	ret = t4_wait_op_done(adapter, SF_OP_A, SF_BUSY_F, 0, SF_ATTEMPTS, 5);
 	if (!ret)
-		*valp = t4_read_reg(adapter, SF_DATA);
+		*valp = t4_read_reg(adapter, SF_DATA_A);
 	return ret;
 }
 
@@ -789,14 +788,12 @@ static int sf1_write(struct adapter *adapter, unsigned int byte_cnt, int cont,
 {
 	if (!byte_cnt || byte_cnt > 4)
 		return -EINVAL;
-	if (t4_read_reg(adapter, SF_OP) & SF_BUSY)
+	if (t4_read_reg(adapter, SF_OP_A) & SF_BUSY_F)
 		return -EBUSY;
-	cont = cont ? SF_CONT : 0;
-	lock = lock ? SF_LOCK : 0;
-	t4_write_reg(adapter, SF_DATA, val);
-	t4_write_reg(adapter, SF_OP, lock |
-		     cont | BYTECNT(byte_cnt - 1) | OP_WR);
-	return t4_wait_op_done(adapter, SF_OP, SF_BUSY, 0, SF_ATTEMPTS, 5);
+	t4_write_reg(adapter, SF_DATA_A, val);
+	t4_write_reg(adapter, SF_OP_A, SF_LOCK_V(lock) |
+		     SF_CONT_V(cont) | BYTECNT_V(byte_cnt - 1) | OP_V(1));
+	return t4_wait_op_done(adapter, SF_OP_A, SF_BUSY_F, 0, SF_ATTEMPTS, 5);
 }
 
 /**
@@ -855,7 +852,7 @@ static int t4_read_flash(struct adapter *adapter, unsigned int addr,
 	for ( ; nwords; nwords--, data++) {
 		ret = sf1_read(adapter, 4, nwords > 1, nwords == 1, data);
 		if (nwords == 1)
-			t4_write_reg(adapter, SF_OP, 0);    /* unlock SF */
+			t4_write_reg(adapter, SF_OP_A, 0);    /* unlock SF */
 		if (ret)
 			return ret;
 		if (byte_oriented)
@@ -903,7 +900,7 @@ static int t4_write_flash(struct adapter *adapter, unsigned int addr,
 	if (ret)
 		goto unlock;
 
-	t4_write_reg(adapter, SF_OP, 0);    /* unlock SF */
+	t4_write_reg(adapter, SF_OP_A, 0);    /* unlock SF */
 
 	/* Read the page to verify the write succeeded */
 	ret = t4_read_flash(adapter, addr & ~0xff, ARRAY_SIZE(buf), buf, 1);
@@ -919,7 +916,7 @@ static int t4_write_flash(struct adapter *adapter, unsigned int addr,
 	return 0;
 
 unlock:
-	t4_write_reg(adapter, SF_OP, 0);    /* unlock SF */
+	t4_write_reg(adapter, SF_OP_A, 0);    /* unlock SF */
 	return ret;
 }
 
@@ -1114,7 +1111,7 @@ static int t4_flash_erase_sectors(struct adapter *adapter, int start, int end)
 		}
 		start++;
 	}
-	t4_write_reg(adapter, SF_OP, 0);    /* unlock SF */
+	t4_write_reg(adapter, SF_OP_A, 0);    /* unlock SF */
 	return ret;
 }
 
@@ -1619,7 +1616,7 @@ static void ulprx_intr_handler(struct adapter *adapter)
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adapter, ULP_RX_INT_CAUSE, ulprx_intr_info))
+	if (t4_handle_intr_status(adapter, ULP_RX_INT_CAUSE_A, ulprx_intr_info))
 		t4_fatal_err(adapter);
 }
 
@@ -1694,16 +1691,16 @@ static void pmrx_intr_handler(struct adapter *adapter)
 static void cplsw_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info cplsw_intr_info[] = {
-		{ CIM_OP_MAP_PERR, "CPLSW CIM op_map parity error", -1, 1 },
-		{ CIM_OVFL_ERROR, "CPLSW CIM overflow", -1, 1 },
-		{ TP_FRAMING_ERROR, "CPLSW TP framing error", -1, 1 },
-		{ SGE_FRAMING_ERROR, "CPLSW SGE framing error", -1, 1 },
-		{ CIM_FRAMING_ERROR, "CPLSW CIM framing error", -1, 1 },
-		{ ZERO_SWITCH_ERROR, "CPLSW no-switch error", -1, 1 },
+		{ CIM_OP_MAP_PERR_F, "CPLSW CIM op_map parity error", -1, 1 },
+		{ CIM_OVFL_ERROR_F, "CPLSW CIM overflow", -1, 1 },
+		{ TP_FRAMING_ERROR_F, "CPLSW TP framing error", -1, 1 },
+		{ SGE_FRAMING_ERROR_F, "CPLSW SGE framing error", -1, 1 },
+		{ CIM_FRAMING_ERROR_F, "CPLSW CIM framing error", -1, 1 },
+		{ ZERO_SWITCH_ERROR_F, "CPLSW no-switch error", -1, 1 },
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adapter, CPL_INTR_CAUSE, cplsw_intr_info))
+	if (t4_handle_intr_status(adapter, CPL_INTR_CAUSE_A, cplsw_intr_info))
 		t4_fatal_err(adapter);
 }
 
@@ -1713,15 +1710,15 @@ static void cplsw_intr_handler(struct adapter *adapter)
 static void le_intr_handler(struct adapter *adap)
 {
 	static const struct intr_info le_intr_info[] = {
-		{ LIPMISS, "LE LIP miss", -1, 0 },
-		{ LIP0, "LE 0 LIP error", -1, 0 },
-		{ PARITYERR, "LE parity error", -1, 1 },
-		{ UNKNOWNCMD, "LE unknown command", -1, 1 },
-		{ REQQPARERR, "LE request queue parity error", -1, 1 },
+		{ LIPMISS_F, "LE LIP miss", -1, 0 },
+		{ LIP0_F, "LE 0 LIP error", -1, 0 },
+		{ PARITYERR_F, "LE parity error", -1, 1 },
+		{ UNKNOWNCMD_F, "LE unknown command", -1, 1 },
+		{ REQQPARERR_F, "LE request queue parity error", -1, 1 },
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adap, LE_DB_INT_CAUSE, le_intr_info))
+	if (t4_handle_intr_status(adap, LE_DB_INT_CAUSE_A, le_intr_info))
 		t4_fatal_err(adap);
 }
 
@@ -1879,13 +1876,13 @@ static void ma_intr_handler(struct adapter *adap)
 static void smb_intr_handler(struct adapter *adap)
 {
 	static const struct intr_info smb_intr_info[] = {
-		{ MSTTXFIFOPARINT, "SMB master Tx FIFO parity error", -1, 1 },
-		{ MSTRXFIFOPARINT, "SMB master Rx FIFO parity error", -1, 1 },
-		{ SLVFIFOPARINT, "SMB slave FIFO parity error", -1, 1 },
+		{ MSTTXFIFOPARINT_F, "SMB master Tx FIFO parity error", -1, 1 },
+		{ MSTRXFIFOPARINT_F, "SMB master Rx FIFO parity error", -1, 1 },
+		{ SLVFIFOPARINT_F, "SMB slave FIFO parity error", -1, 1 },
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adap, SMB_INT_CAUSE, smb_intr_info))
+	if (t4_handle_intr_status(adap, SMB_INT_CAUSE_A, smb_intr_info))
 		t4_fatal_err(adap);
 }
 
@@ -1895,14 +1892,14 @@ static void smb_intr_handler(struct adapter *adap)
 static void ncsi_intr_handler(struct adapter *adap)
 {
 	static const struct intr_info ncsi_intr_info[] = {
-		{ CIM_DM_PRTY_ERR, "NC-SI CIM parity error", -1, 1 },
-		{ MPS_DM_PRTY_ERR, "NC-SI MPS parity error", -1, 1 },
-		{ TXFIFO_PRTY_ERR, "NC-SI Tx FIFO parity error", -1, 1 },
-		{ RXFIFO_PRTY_ERR, "NC-SI Rx FIFO parity error", -1, 1 },
+		{ CIM_DM_PRTY_ERR_F, "NC-SI CIM parity error", -1, 1 },
+		{ MPS_DM_PRTY_ERR_F, "NC-SI MPS parity error", -1, 1 },
+		{ TXFIFO_PRTY_ERR_F, "NC-SI Tx FIFO parity error", -1, 1 },
+		{ RXFIFO_PRTY_ERR_F, "NC-SI Rx FIFO parity error", -1, 1 },
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adap, NCSI_INT_CAUSE, ncsi_intr_info))
+	if (t4_handle_intr_status(adap, NCSI_INT_CAUSE_A, ncsi_intr_info))
 		t4_fatal_err(adap);
 }
 
@@ -1914,23 +1911,23 @@ static void xgmac_intr_handler(struct adapter *adap, int port)
 	u32 v, int_cause_reg;
 
 	if (is_t4(adap->params.chip))
-		int_cause_reg = PORT_REG(port, XGMAC_PORT_INT_CAUSE);
+		int_cause_reg = PORT_REG(port, XGMAC_PORT_INT_CAUSE_A);
 	else
-		int_cause_reg = T5_PORT_REG(port, MAC_PORT_INT_CAUSE);
+		int_cause_reg = T5_PORT_REG(port, MAC_PORT_INT_CAUSE_A);
 
 	v = t4_read_reg(adap, int_cause_reg);
 
-	v &= TXFIFO_PRTY_ERR | RXFIFO_PRTY_ERR;
+	v &= TXFIFO_PRTY_ERR_F | RXFIFO_PRTY_ERR_F;
 	if (!v)
 		return;
 
-	if (v & TXFIFO_PRTY_ERR)
+	if (v & TXFIFO_PRTY_ERR_F)
 		dev_alert(adap->pdev_dev, "XGMAC %d Tx FIFO parity error\n",
 			  port);
-	if (v & RXFIFO_PRTY_ERR)
+	if (v & RXFIFO_PRTY_ERR_F)
 		dev_alert(adap->pdev_dev, "XGMAC %d Rx FIFO parity error\n",
 			  port);
-	t4_write_reg(adap, PORT_REG(port, XGMAC_PORT_INT_CAUSE), v);
+	t4_write_reg(adap, PORT_REG(port, XGMAC_PORT_INT_CAUSE_A), v);
 	t4_fatal_err(adap);
 }
 
@@ -1940,19 +1937,19 @@ static void xgmac_intr_handler(struct adapter *adap, int port)
 static void pl_intr_handler(struct adapter *adap)
 {
 	static const struct intr_info pl_intr_info[] = {
-		{ FATALPERR, "T4 fatal parity error", -1, 1 },
-		{ PERRVFID, "PL VFID_MAP parity error", -1, 1 },
+		{ FATALPERR_F, "T4 fatal parity error", -1, 1 },
+		{ PERRVFID_F, "PL VFID_MAP parity error", -1, 1 },
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adap, PL_PL_INT_CAUSE, pl_intr_info))
+	if (t4_handle_intr_status(adap, PL_PL_INT_CAUSE_A, pl_intr_info))
 		t4_fatal_err(adap);
 }
 
-#define PF_INTR_MASK (PFSW)
-#define GLBL_INTR_MASK (CIM | MPS | PL | PCIE | MC | EDC0 | \
-		EDC1 | LE | TP | MA | PM_TX | PM_RX | ULP_RX | \
-		CPL_SWITCH | SGE | ULP_TX)
+#define PF_INTR_MASK (PFSW_F)
+#define GLBL_INTR_MASK (CIM_F | MPS_F | PL_F | PCIE_F | MC_F | EDC0_F | \
+		EDC1_F | LE_F | TP_F | MA_F | PM_TX_F | PM_RX_F | ULP_RX_F | \
+		CPL_SWITCH_F | SGE_F | ULP_TX_F)
 
 /**
  *	t4_slow_intr_handler - control path interrupt handler
@@ -1964,60 +1961,60 @@ static void pl_intr_handler(struct adapter *adap)
  */
 int t4_slow_intr_handler(struct adapter *adapter)
 {
-	u32 cause = t4_read_reg(adapter, PL_INT_CAUSE);
+	u32 cause = t4_read_reg(adapter, PL_INT_CAUSE_A);
 
 	if (!(cause & GLBL_INTR_MASK))
 		return 0;
-	if (cause & CIM)
+	if (cause & CIM_F)
 		cim_intr_handler(adapter);
-	if (cause & MPS)
+	if (cause & MPS_F)
 		mps_intr_handler(adapter);
-	if (cause & NCSI)
+	if (cause & NCSI_F)
 		ncsi_intr_handler(adapter);
-	if (cause & PL)
+	if (cause & PL_F)
 		pl_intr_handler(adapter);
-	if (cause & SMB)
+	if (cause & SMB_F)
 		smb_intr_handler(adapter);
-	if (cause & XGMAC0)
+	if (cause & XGMAC0_F)
 		xgmac_intr_handler(adapter, 0);
-	if (cause & XGMAC1)
+	if (cause & XGMAC1_F)
 		xgmac_intr_handler(adapter, 1);
-	if (cause & XGMAC_KR0)
+	if (cause & XGMAC_KR0_F)
 		xgmac_intr_handler(adapter, 2);
-	if (cause & XGMAC_KR1)
+	if (cause & XGMAC_KR1_F)
 		xgmac_intr_handler(adapter, 3);
-	if (cause & PCIE)
+	if (cause & PCIE_F)
 		pcie_intr_handler(adapter);
-	if (cause & MC)
+	if (cause & MC_F)
 		mem_intr_handler(adapter, MEM_MC);
-	if (!is_t4(adapter->params.chip) && (cause & MC1))
+	if (!is_t4(adapter->params.chip) && (cause & MC1_S))
 		mem_intr_handler(adapter, MEM_MC1);
-	if (cause & EDC0)
+	if (cause & EDC0_F)
 		mem_intr_handler(adapter, MEM_EDC0);
-	if (cause & EDC1)
+	if (cause & EDC1_F)
 		mem_intr_handler(adapter, MEM_EDC1);
-	if (cause & LE)
+	if (cause & LE_F)
 		le_intr_handler(adapter);
-	if (cause & TP)
+	if (cause & TP_F)
 		tp_intr_handler(adapter);
-	if (cause & MA)
+	if (cause & MA_F)
 		ma_intr_handler(adapter);
-	if (cause & PM_TX)
+	if (cause & PM_TX_F)
 		pmtx_intr_handler(adapter);
-	if (cause & PM_RX)
+	if (cause & PM_RX_F)
 		pmrx_intr_handler(adapter);
-	if (cause & ULP_RX)
+	if (cause & ULP_RX_F)
 		ulprx_intr_handler(adapter);
-	if (cause & CPL_SWITCH)
+	if (cause & CPL_SWITCH_F)
 		cplsw_intr_handler(adapter);
-	if (cause & SGE)
+	if (cause & SGE_F)
 		sge_intr_handler(adapter);
-	if (cause & ULP_TX)
+	if (cause & ULP_TX_F)
 		ulptx_intr_handler(adapter);
 
 	/* Clear the interrupts just processed for which we are the master. */
-	t4_write_reg(adapter, PL_INT_CAUSE, cause & GLBL_INTR_MASK);
-	(void) t4_read_reg(adapter, PL_INT_CAUSE); /* flush */
+	t4_write_reg(adapter, PL_INT_CAUSE_A, cause & GLBL_INTR_MASK);
+	(void)t4_read_reg(adapter, PL_INT_CAUSE_A); /* flush */
 	return 1;
 }
 
@@ -2036,7 +2033,7 @@ int t4_slow_intr_handler(struct adapter *adapter)
  */
 void t4_intr_enable(struct adapter *adapter)
 {
-	u32 pf = SOURCEPF_GET(t4_read_reg(adapter, PL_WHOAMI));
+	u32 pf = SOURCEPF_G(t4_read_reg(adapter, PL_WHOAMI_A));
 
 	t4_write_reg(adapter, SGE_INT_ENABLE3_A, ERR_CPL_EXCEED_IQE_SIZE_F |
 		     ERR_INVALID_CIDX_INC_F | ERR_CPL_OPCODE_0_F |
@@ -2047,8 +2044,8 @@ void t4_intr_enable(struct adapter *adapter)
 		     ERR_EGR_CTXT_PRIO_F | INGRESS_SIZE_ERR_F |
 		     DBFIFO_HP_INT_F | DBFIFO_LP_INT_F |
 		     EGRESS_SIZE_ERR_F);
-	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE), PF_INTR_MASK);
-	t4_set_reg_field(adapter, PL_INT_MAP0, 0, 1 << pf);
+	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE_A), PF_INTR_MASK);
+	t4_set_reg_field(adapter, PL_INT_MAP0_A, 0, 1 << pf);
 }
 
 /**
@@ -2061,10 +2058,10 @@ void t4_intr_enable(struct adapter *adapter)
  */
 void t4_intr_disable(struct adapter *adapter)
 {
-	u32 pf = SOURCEPF_GET(t4_read_reg(adapter, PL_WHOAMI));
+	u32 pf = SOURCEPF_G(t4_read_reg(adapter, PL_WHOAMI_A));
 
-	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE), 0);
-	t4_set_reg_field(adapter, PL_INT_MAP0, 1 << pf, 0);
+	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE_A), 0);
+	t4_set_reg_field(adapter, PL_INT_MAP0_A, 1 << pf, 0);
 }
 
 /**
@@ -2498,7 +2495,7 @@ void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
 	if (is_t4(adap->params.chip)) {
 		mag_id_reg_l = PORT_REG(port, XGMAC_PORT_MAGIC_MACID_LO);
 		mag_id_reg_h = PORT_REG(port, XGMAC_PORT_MAGIC_MACID_HI);
-		port_cfg_reg = PORT_REG(port, XGMAC_PORT_CFG2);
+		port_cfg_reg = PORT_REG(port, XGMAC_PORT_CFG2_A);
 	} else {
 		mag_id_reg_l = T5_PORT_REG(port, MAC_PORT_MAGIC_MACID_LO);
 		mag_id_reg_h = T5_PORT_REG(port, MAC_PORT_MAGIC_MACID_HI);
@@ -2512,8 +2509,8 @@ void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
 		t4_write_reg(adap, mag_id_reg_h,
 			     (addr[0] << 8) | addr[1]);
 	}
-	t4_set_reg_field(adap, port_cfg_reg, MAGICEN,
-			 addr ? MAGICEN : 0);
+	t4_set_reg_field(adap, port_cfg_reg, MAGICEN_F,
+			 addr ? MAGICEN_F : 0);
 }
 
 /**
@@ -2538,20 +2535,21 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 	u32 port_cfg_reg;
 
 	if (is_t4(adap->params.chip))
-		port_cfg_reg = PORT_REG(port, XGMAC_PORT_CFG2);
+		port_cfg_reg = PORT_REG(port, XGMAC_PORT_CFG2_A);
 	else
 		port_cfg_reg = T5_PORT_REG(port, MAC_PORT_CFG2_A);
 
 	if (!enable) {
-		t4_set_reg_field(adap, port_cfg_reg, PATEN, 0);
+		t4_set_reg_field(adap, port_cfg_reg, PATEN_F, 0);
 		return 0;
 	}
 	if (map > 0xff)
 		return -EINVAL;
 
 #define EPIO_REG(name) \
-	(is_t4(adap->params.chip) ? PORT_REG(port, XGMAC_PORT_EPIO_##name) : \
-	T5_PORT_REG(port, MAC_PORT_EPIO_##name##_A))
+	(is_t4(adap->params.chip) ? \
+	 PORT_REG(port, XGMAC_PORT_EPIO_##name##_A) : \
+	 T5_PORT_REG(port, MAC_PORT_EPIO_##name##_A))
 
 	t4_write_reg(adap, EPIO_REG(DATA1), mask0 >> 32);
 	t4_write_reg(adap, EPIO_REG(DATA2), mask1);
@@ -2563,21 +2561,21 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 
 		/* write byte masks */
 		t4_write_reg(adap, EPIO_REG(DATA0), mask0);
-		t4_write_reg(adap, EPIO_REG(OP), ADDRESS(i) | EPIOWR);
+		t4_write_reg(adap, EPIO_REG(OP), ADDRESS_V(i) | EPIOWR_F);
 		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
-		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY)
+		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY_F)
 			return -ETIMEDOUT;
 
 		/* write CRC */
 		t4_write_reg(adap, EPIO_REG(DATA0), crc);
-		t4_write_reg(adap, EPIO_REG(OP), ADDRESS(i + 32) | EPIOWR);
+		t4_write_reg(adap, EPIO_REG(OP), ADDRESS_V(i + 32) | EPIOWR_F);
 		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
-		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY)
+		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY_F)
 			return -ETIMEDOUT;
 	}
 #undef EPIO_REG
 
-	t4_set_reg_field(adap, PORT_REG(port, XGMAC_PORT_CFG2), 0, PATEN);
+	t4_set_reg_field(adap, PORT_REG(port, XGMAC_PORT_CFG2_A), 0, PATEN_F);
 	return 0;
 }
 
@@ -2998,7 +2996,7 @@ static int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
 
 		memset(&c, 0, sizeof(c));
 		INIT_CMD(c, RESET, WRITE);
-		c.val = htonl(PIORST | PIORSTMODE);
+		c.val = htonl(PIORST_F | PIORSTMODE_F);
 		c.halt_pkd = htonl(FW_RESET_CMD_HALT_F);
 		ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 	}
@@ -3071,11 +3069,11 @@ static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
 			t4_set_reg_field(adap, CIM_BOOT_CFG_A, UPCRST_F, 0);
 			msleep(100);
 			if (t4_fw_reset(adap, mbox,
-					PIORST | PIORSTMODE) == 0)
+					PIORST_F | PIORSTMODE_F) == 0)
 				return 0;
 		}
 
-		t4_write_reg(adap, PL_RST, PIORST | PIORSTMODE);
+		t4_write_reg(adap, PL_RST_A, PIORST_F | PIORSTMODE_F);
 		msleep(2000);
 	} else {
 		int ms;
@@ -3246,7 +3244,7 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 		     (t4_read_reg(adap, SGE_FL_BUFFER_SIZE3_A) + fl_align-1)
 		     & ~(fl_align-1));
 
-	t4_write_reg(adap, ULP_RX_TDDP_PSZ, HPZ0(page_shift - 12));
+	t4_write_reg(adap, ULP_RX_TDDP_PSZ_A, HPZ0_V(page_shift - 12));
 
 	return 0;
 }
@@ -3931,12 +3929,12 @@ int t4_wait_dev_ready(void __iomem *regs)
 {
 	u32 whoami;
 
-	whoami = readl(regs + PL_WHOAMI);
+	whoami = readl(regs + PL_WHOAMI_A);
 	if (whoami != 0xffffffff && whoami != CIM_PF_NOACCESS)
 		return 0;
 
 	msleep(500);
-	whoami = readl(regs + PL_WHOAMI);
+	whoami = readl(regs + PL_WHOAMI_A);
 	return (whoami != 0xffffffff && whoami != CIM_PF_NOACCESS ? 0 : -EIO);
 }
 
@@ -3960,7 +3958,7 @@ static int get_flash_params(struct adapter *adap)
 	ret = sf1_write(adap, 1, 1, 0, SF_RD_ID);
 	if (!ret)
 		ret = sf1_read(adap, 3, 0, 1, &info);
-	t4_write_reg(adap, SF_OP, 0);                    /* unlock SF */
+	t4_write_reg(adap, SF_OP_A, 0);                    /* unlock SF */
 	if (ret)
 		return ret;
 
@@ -4007,7 +4005,7 @@ int t4_prep_adapter(struct adapter *adapter)
 	u32 pl_rev;
 
 	get_pci_mode(adapter, &adapter->params.pci);
-	pl_rev = G_REV(t4_read_reg(adapter, PL_REV));
+	pl_rev = REV_G(t4_read_reg(adapter, PL_REV_A));
 
 	ret = get_flash_params(adapter);
 	if (ret < 0) {
@@ -4197,16 +4195,16 @@ int t4_init_tp_params(struct adapter *adap)
 	 * shift positions of several elements of the Compressed Filter Tuple
 	 * for this adapter which we need frequently ...
 	 */
-	adap->params.tp.vlan_shift = t4_filter_field_shift(adap, F_VLAN);
-	adap->params.tp.vnic_shift = t4_filter_field_shift(adap, F_VNIC_ID);
-	adap->params.tp.port_shift = t4_filter_field_shift(adap, F_PORT);
+	adap->params.tp.vlan_shift = t4_filter_field_shift(adap, VLAN_F);
+	adap->params.tp.vnic_shift = t4_filter_field_shift(adap, VNIC_ID_F);
+	adap->params.tp.port_shift = t4_filter_field_shift(adap, PORT_F);
 	adap->params.tp.protocol_shift = t4_filter_field_shift(adap,
-							       F_PROTOCOL);
+							       PROTOCOL_F);
 
 	/* If TP_INGRESS_CONFIG.VNID == 0, then TP_VLAN_PRI_MAP.VNIC_ID
 	 * represents the presense of an Outer VLAN instead of a VNIC ID.
 	 */
-	if ((adap->params.tp.ingress_config & F_VNIC) == 0)
+	if ((adap->params.tp.ingress_config & VNIC_F) == 0)
 		adap->params.tp.vnic_shift = -1;
 
 	return 0;
@@ -4232,35 +4230,35 @@ int t4_filter_field_shift(const struct adapter *adap, int filter_sel)
 
 	for (sel = 1, field_shift = 0; sel < filter_sel; sel <<= 1) {
 		switch (filter_mode & sel) {
-		case F_FCOE:
-			field_shift += W_FT_FCOE;
+		case FCOE_F:
+			field_shift += FT_FCOE_W;
 			break;
-		case F_PORT:
-			field_shift += W_FT_PORT;
+		case PORT_F:
+			field_shift += FT_PORT_W;
 			break;
-		case F_VNIC_ID:
-			field_shift += W_FT_VNIC_ID;
+		case VNIC_ID_F:
+			field_shift += FT_VNIC_ID_W;
 			break;
-		case F_VLAN:
-			field_shift += W_FT_VLAN;
+		case VLAN_F:
+			field_shift += FT_VLAN_W;
 			break;
-		case F_TOS:
-			field_shift += W_FT_TOS;
+		case TOS_F:
+			field_shift += FT_TOS_W;
 			break;
-		case F_PROTOCOL:
-			field_shift += W_FT_PROTOCOL;
+		case PROTOCOL_F:
+			field_shift += FT_PROTOCOL_W;
 			break;
-		case F_ETHERTYPE:
-			field_shift += W_FT_ETHERTYPE;
+		case ETHERTYPE_F:
+			field_shift += FT_ETHERTYPE_W;
 			break;
-		case F_MACMATCH:
-			field_shift += W_FT_MACMATCH;
+		case MACMATCH_F:
+			field_shift += FT_MACMATCH_W;
 			break;
-		case F_MPSHITTYPE:
-			field_shift += W_FT_MPSHITTYPE;
+		case MPSHITTYPE_F:
+			field_shift += FT_MPSHITTYPE_W;
 			break;
-		case F_FRAGMENTATION:
-			field_shift += W_FT_FRAGMENTATION;
+		case FRAGMENTATION_F:
+			field_shift += FT_FRAGMENTATION_W;
 			break;
 		}
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index ec0addc..4077227 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1708,233 +1708,323 @@
 
 #define MPS_RX_PERR_INT_CAUSE_A 0x11074
 
-#define CPL_INTR_CAUSE 0x19054
-#define  CIM_OP_MAP_PERR   0x00000020U
-#define  CIM_OVFL_ERROR    0x00000010U
-#define  TP_FRAMING_ERROR  0x00000008U
-#define  SGE_FRAMING_ERROR 0x00000004U
-#define  CIM_FRAMING_ERROR 0x00000002U
-#define  ZERO_SWITCH_ERROR 0x00000001U
-
-#define SMB_INT_CAUSE 0x19090
-#define  MSTTXFIFOPARINT 0x00200000U
-#define  MSTRXFIFOPARINT 0x00100000U
-#define  SLVFIFOPARINT   0x00080000U
-
-#define ULP_RX_INT_CAUSE 0x19158
-#define ULP_RX_ISCSI_TAGMASK 0x19164
-#define ULP_RX_ISCSI_PSZ 0x19168
-#define  HPZ3_MASK   0x0f000000U
-#define  HPZ3_SHIFT  24
-#define  HPZ3(x)     ((x) << HPZ3_SHIFT)
-#define  HPZ2_MASK   0x000f0000U
-#define  HPZ2_SHIFT  16
-#define  HPZ2(x)     ((x) << HPZ2_SHIFT)
-#define  HPZ1_MASK   0x00000f00U
-#define  HPZ1_SHIFT  8
-#define  HPZ1(x)     ((x) << HPZ1_SHIFT)
-#define  HPZ0_MASK   0x0000000fU
-#define  HPZ0_SHIFT  0
-#define  HPZ0(x)     ((x) << HPZ0_SHIFT)
-
-#define ULP_RX_TDDP_PSZ 0x19178
-
-#define SF_DATA 0x193f8
-#define SF_OP 0x193fc
-#define  SF_BUSY       0x80000000U
-#define  SF_LOCK       0x00000010U
-#define  SF_CONT       0x00000008U
-#define  BYTECNT_MASK  0x00000006U
-#define  BYTECNT_SHIFT 1
-#define  BYTECNT(x)    ((x) << BYTECNT_SHIFT)
-#define  OP_WR         0x00000001U
-
-#define PL_PF_INT_CAUSE 0x3c0
-#define  PFSW  0x00000008U
-#define  PFSGE 0x00000004U
-#define  PFCIM 0x00000002U
-#define  PFMPS 0x00000001U
-
-#define PL_PF_INT_ENABLE 0x3c4
-#define PL_PF_CTL 0x3c8
-#define  SWINT 0x00000001U
-
-#define PL_WHOAMI 0x19400
-#define  SOURCEPF_MASK   0x00000700U
-#define  SOURCEPF_SHIFT  8
-#define  SOURCEPF(x)     ((x) << SOURCEPF_SHIFT)
-#define  SOURCEPF_GET(x) (((x) & SOURCEPF_MASK) >> SOURCEPF_SHIFT)
-#define  ISVF            0x00000080U
-#define  VFID_MASK       0x0000007fU
-#define  VFID_SHIFT      0
-#define  VFID(x)         ((x) << VFID_SHIFT)
-#define  VFID_GET(x)     (((x) & VFID_MASK) >> VFID_SHIFT)
-
-#define PL_INT_CAUSE 0x1940c
-#define  ULP_TX     0x08000000U
-#define  SGE        0x04000000U
-#define  HMA        0x02000000U
-#define  CPL_SWITCH 0x01000000U
-#define  ULP_RX     0x00800000U
-#define  PM_RX      0x00400000U
-#define  PM_TX      0x00200000U
-#define  MA         0x00100000U
-#define  TP         0x00080000U
-#define  LE         0x00040000U
-#define  EDC1       0x00020000U
-#define  EDC0       0x00010000U
-#define  MC         0x00008000U
-#define  PCIE       0x00004000U
-#define  PMU        0x00002000U
-#define  XGMAC_KR1  0x00001000U
-#define  XGMAC_KR0  0x00000800U
-#define  XGMAC1     0x00000400U
-#define  XGMAC0     0x00000200U
-#define  SMB        0x00000100U
-#define  SF         0x00000080U
-#define  PL         0x00000040U
-#define  NCSI       0x00000020U
-#define  MPS        0x00000010U
-#define  MI         0x00000008U
-#define  DBG        0x00000004U
-#define  I2CM       0x00000002U
-#define  CIM        0x00000001U
-
-#define MC1 0x31
-#define PL_INT_ENABLE 0x19410
-#define PL_INT_MAP0 0x19414
-#define PL_RST 0x19428
-#define  PIORST     0x00000002U
-#define  PIORSTMODE 0x00000001U
-
-#define PL_PL_INT_CAUSE 0x19430
-#define  FATALPERR 0x00000010U
-#define  PERRVFID  0x00000001U
-
-#define PL_REV 0x1943c
-
-#define S_REV    0
-#define M_REV    0xfU
-#define V_REV(x) ((x) << S_REV)
-#define G_REV(x) (((x) >> S_REV) & M_REV)
-
-#define LE_DB_CONFIG 0x19c04
-#define  HASHEN 0x00100000U
-
-#define LE_DB_SERVER_INDEX 0x19c18
-#define LE_DB_ACT_CNT_IPV4 0x19c20
-#define LE_DB_ACT_CNT_IPV6 0x19c24
-
-#define LE_DB_INT_CAUSE 0x19c3c
-#define  REQQPARERR 0x00010000U
-#define  UNKNOWNCMD 0x00008000U
-#define  PARITYERR  0x00000040U
-#define  LIPMISS    0x00000020U
-#define  LIP0       0x00000010U
-
-#define LE_DB_TID_HASHBASE 0x19df8
-
-#define NCSI_INT_CAUSE 0x1a0d8
-#define  CIM_DM_PRTY_ERR 0x00000100U
-#define  MPS_DM_PRTY_ERR 0x00000080U
-#define  TXFIFO_PRTY_ERR 0x00000002U
-#define  RXFIFO_PRTY_ERR 0x00000001U
-
-#define XGMAC_PORT_CFG2 0x1018
-#define  PATEN   0x00040000U
-#define  MAGICEN 0x00020000U
+#define CPL_INTR_CAUSE_A 0x19054
 
-#define XGMAC_PORT_MAGIC_MACID_LO 0x1024
-#define XGMAC_PORT_MAGIC_MACID_HI 0x1028
+#define CIM_OP_MAP_PERR_S    5
+#define CIM_OP_MAP_PERR_V(x) ((x) << CIM_OP_MAP_PERR_S)
+#define CIM_OP_MAP_PERR_F    CIM_OP_MAP_PERR_V(1U)
+
+#define CIM_OVFL_ERROR_S    4
+#define CIM_OVFL_ERROR_V(x) ((x) << CIM_OVFL_ERROR_S)
+#define CIM_OVFL_ERROR_F    CIM_OVFL_ERROR_V(1U)
+
+#define TP_FRAMING_ERROR_S    3
+#define TP_FRAMING_ERROR_V(x) ((x) << TP_FRAMING_ERROR_S)
+#define TP_FRAMING_ERROR_F    TP_FRAMING_ERROR_V(1U)
+
+#define SGE_FRAMING_ERROR_S    2
+#define SGE_FRAMING_ERROR_V(x) ((x) << SGE_FRAMING_ERROR_S)
+#define SGE_FRAMING_ERROR_F    SGE_FRAMING_ERROR_V(1U)
+
+#define CIM_FRAMING_ERROR_S    1
+#define CIM_FRAMING_ERROR_V(x) ((x) << CIM_FRAMING_ERROR_S)
+#define CIM_FRAMING_ERROR_F    CIM_FRAMING_ERROR_V(1U)
+
+#define ZERO_SWITCH_ERROR_S    0
+#define ZERO_SWITCH_ERROR_V(x) ((x) << ZERO_SWITCH_ERROR_S)
+#define ZERO_SWITCH_ERROR_F    ZERO_SWITCH_ERROR_V(1U)
+
+#define SMB_INT_CAUSE_A 0x19090
+
+#define MSTTXFIFOPARINT_S    21
+#define MSTTXFIFOPARINT_V(x) ((x) << MSTTXFIFOPARINT_S)
+#define MSTTXFIFOPARINT_F    MSTTXFIFOPARINT_V(1U)
+
+#define MSTRXFIFOPARINT_S    20
+#define MSTRXFIFOPARINT_V(x) ((x) << MSTRXFIFOPARINT_S)
+#define MSTRXFIFOPARINT_F    MSTRXFIFOPARINT_V(1U)
+
+#define SLVFIFOPARINT_S    19
+#define SLVFIFOPARINT_V(x) ((x) << SLVFIFOPARINT_S)
+#define SLVFIFOPARINT_F    SLVFIFOPARINT_V(1U)
+
+#define ULP_RX_INT_CAUSE_A 0x19158
+#define ULP_RX_ISCSI_TAGMASK_A 0x19164
+#define ULP_RX_ISCSI_PSZ_A 0x19168
+
+#define HPZ3_S    24
+#define HPZ3_V(x) ((x) << HPZ3_S)
+
+#define HPZ2_S    16
+#define HPZ2_V(x) ((x) << HPZ2_S)
+
+#define HPZ1_S    8
+#define HPZ1_V(x) ((x) << HPZ1_S)
+
+#define HPZ0_S    0
+#define HPZ0_V(x) ((x) << HPZ0_S)
+
+#define ULP_RX_TDDP_PSZ_A 0x19178
+
+/* registers for module SF */
+#define SF_DATA_A 0x193f8
+#define SF_OP_A 0x193fc
+
+#define SF_BUSY_S    31
+#define SF_BUSY_V(x) ((x) << SF_BUSY_S)
+#define SF_BUSY_F    SF_BUSY_V(1U)
+
+#define SF_LOCK_S    4
+#define SF_LOCK_V(x) ((x) << SF_LOCK_S)
+#define SF_LOCK_F    SF_LOCK_V(1U)
+
+#define SF_CONT_S    3
+#define SF_CONT_V(x) ((x) << SF_CONT_S)
+#define SF_CONT_F    SF_CONT_V(1U)
+
+#define BYTECNT_S    1
+#define BYTECNT_V(x) ((x) << BYTECNT_S)
+
+#define OP_S    0
+#define OP_V(x) ((x) << OP_S)
+#define OP_F    OP_V(1U)
+
+#define PL_PF_INT_CAUSE_A 0x3c0
+
+#define PFSW_S    3
+#define PFSW_V(x) ((x) << PFSW_S)
+#define PFSW_F    PFSW_V(1U)
+
+#define PFCIM_S    1
+#define PFCIM_V(x) ((x) << PFCIM_S)
+#define PFCIM_F    PFCIM_V(1U)
+
+#define PL_PF_INT_ENABLE_A 0x3c4
+#define PL_PF_CTL_A 0x3c8
+
+#define PL_WHOAMI_A 0x19400
+
+#define SOURCEPF_S    8
+#define SOURCEPF_M    0x7U
+#define SOURCEPF_G(x) (((x) >> SOURCEPF_S) & SOURCEPF_M)
+
+#define PL_INT_CAUSE_A 0x1940c
+
+#define ULP_TX_S    27
+#define ULP_TX_V(x) ((x) << ULP_TX_S)
+#define ULP_TX_F    ULP_TX_V(1U)
+
+#define SGE_S    26
+#define SGE_V(x) ((x) << SGE_S)
+#define SGE_F    SGE_V(1U)
+
+#define CPL_SWITCH_S    24
+#define CPL_SWITCH_V(x) ((x) << CPL_SWITCH_S)
+#define CPL_SWITCH_F    CPL_SWITCH_V(1U)
+
+#define ULP_RX_S    23
+#define ULP_RX_V(x) ((x) << ULP_RX_S)
+#define ULP_RX_F    ULP_RX_V(1U)
+
+#define PM_RX_S    22
+#define PM_RX_V(x) ((x) << PM_RX_S)
+#define PM_RX_F    PM_RX_V(1U)
+
+#define PM_TX_S    21
+#define PM_TX_V(x) ((x) << PM_TX_S)
+#define PM_TX_F    PM_TX_V(1U)
+
+#define MA_S    20
+#define MA_V(x) ((x) << MA_S)
+#define MA_F    MA_V(1U)
 
-#define XGMAC_PORT_EPIO_DATA0 0x10c0
-#define XGMAC_PORT_EPIO_DATA1 0x10c4
-#define XGMAC_PORT_EPIO_DATA2 0x10c8
-#define XGMAC_PORT_EPIO_DATA3 0x10cc
-#define XGMAC_PORT_EPIO_OP 0x10d0
-#define  EPIOWR         0x00000100U
-#define  ADDRESS_MASK   0x000000ffU
-#define  ADDRESS_SHIFT  0
-#define  ADDRESS(x)     ((x) << ADDRESS_SHIFT)
+#define TP_S    19
+#define TP_V(x) ((x) << TP_S)
+#define TP_F    TP_V(1U)
 
-#define MAC_PORT_INT_CAUSE 0x8dc
-#define XGMAC_PORT_INT_CAUSE 0x10dc
+#define LE_S    18
+#define LE_V(x) ((x) << LE_S)
+#define LE_F    LE_V(1U)
 
-#define A_TP_TX_MOD_QUEUE_REQ_MAP 0x7e28
+#define EDC1_S    17
+#define EDC1_V(x) ((x) << EDC1_S)
+#define EDC1_F    EDC1_V(1U)
 
-#define A_TP_TX_MOD_CHANNEL_WEIGHT 0x7e34
+#define EDC0_S    16
+#define EDC0_V(x) ((x) << EDC0_S)
+#define EDC0_F    EDC0_V(1U)
 
-#define S_TX_MOD_QUEUE_REQ_MAP    0
-#define M_TX_MOD_QUEUE_REQ_MAP    0xffffU
-#define V_TX_MOD_QUEUE_REQ_MAP(x) ((x) << S_TX_MOD_QUEUE_REQ_MAP)
+#define MC_S    15
+#define MC_V(x) ((x) << MC_S)
+#define MC_F    MC_V(1U)
 
-#define A_TP_TX_MOD_QUEUE_WEIGHT0 0x7e30
+#define PCIE_S    14
+#define PCIE_V(x) ((x) << PCIE_S)
+#define PCIE_F    PCIE_V(1U)
 
-#define S_TX_MODQ_WEIGHT3    24
-#define M_TX_MODQ_WEIGHT3    0xffU
-#define V_TX_MODQ_WEIGHT3(x) ((x) << S_TX_MODQ_WEIGHT3)
+#define XGMAC_KR1_S    12
+#define XGMAC_KR1_V(x) ((x) << XGMAC_KR1_S)
+#define XGMAC_KR1_F    XGMAC_KR1_V(1U)
 
-#define S_TX_MODQ_WEIGHT2    16
-#define M_TX_MODQ_WEIGHT2    0xffU
-#define V_TX_MODQ_WEIGHT2(x) ((x) << S_TX_MODQ_WEIGHT2)
+#define XGMAC_KR0_S    11
+#define XGMAC_KR0_V(x) ((x) << XGMAC_KR0_S)
+#define XGMAC_KR0_F    XGMAC_KR0_V(1U)
 
-#define S_TX_MODQ_WEIGHT1    8
-#define M_TX_MODQ_WEIGHT1    0xffU
-#define V_TX_MODQ_WEIGHT1(x) ((x) << S_TX_MODQ_WEIGHT1)
+#define XGMAC1_S    10
+#define XGMAC1_V(x) ((x) << XGMAC1_S)
+#define XGMAC1_F    XGMAC1_V(1U)
 
-#define S_TX_MODQ_WEIGHT0    0
-#define M_TX_MODQ_WEIGHT0    0xffU
-#define V_TX_MODQ_WEIGHT0(x) ((x) << S_TX_MODQ_WEIGHT0)
+#define XGMAC0_S    9
+#define XGMAC0_V(x) ((x) << XGMAC0_S)
+#define XGMAC0_F    XGMAC0_V(1U)
 
-#define A_TP_TX_SCHED_HDR 0x23
+#define SMB_S    8
+#define SMB_V(x) ((x) << SMB_S)
+#define SMB_F    SMB_V(1U)
 
-#define A_TP_TX_SCHED_FIFO 0x24
+#define SF_S    7
+#define SF_V(x) ((x) << SF_S)
+#define SF_F    SF_V(1U)
 
-#define A_TP_TX_SCHED_PCMD 0x25
+#define PL_S    6
+#define PL_V(x) ((x) << PL_S)
+#define PL_F    PL_V(1U)
 
-#define S_VNIC    11
-#define V_VNIC(x) ((x) << S_VNIC)
-#define F_VNIC    V_VNIC(1U)
+#define NCSI_S    5
+#define NCSI_V(x) ((x) << NCSI_S)
+#define NCSI_F    NCSI_V(1U)
 
-#define S_FRAGMENTATION    9
-#define V_FRAGMENTATION(x) ((x) << S_FRAGMENTATION)
-#define F_FRAGMENTATION    V_FRAGMENTATION(1U)
+#define MPS_S    4
+#define MPS_V(x) ((x) << MPS_S)
+#define MPS_F    MPS_V(1U)
 
-#define S_MPSHITTYPE    8
-#define V_MPSHITTYPE(x) ((x) << S_MPSHITTYPE)
-#define F_MPSHITTYPE    V_MPSHITTYPE(1U)
+#define CIM_S    0
+#define CIM_V(x) ((x) << CIM_S)
+#define CIM_F    CIM_V(1U)
 
-#define S_MACMATCH    7
-#define V_MACMATCH(x) ((x) << S_MACMATCH)
-#define F_MACMATCH    V_MACMATCH(1U)
+#define MC1_S    31
 
-#define S_ETHERTYPE    6
-#define V_ETHERTYPE(x) ((x) << S_ETHERTYPE)
-#define F_ETHERTYPE    V_ETHERTYPE(1U)
+#define PL_INT_ENABLE_A 0x19410
+#define PL_INT_MAP0_A 0x19414
+#define PL_RST_A 0x19428
 
-#define S_PROTOCOL    5
-#define V_PROTOCOL(x) ((x) << S_PROTOCOL)
-#define F_PROTOCOL    V_PROTOCOL(1U)
+#define PIORST_S    1
+#define PIORST_V(x) ((x) << PIORST_S)
+#define PIORST_F    PIORST_V(1U)
 
-#define S_TOS    4
-#define V_TOS(x) ((x) << S_TOS)
-#define F_TOS    V_TOS(1U)
+#define PIORSTMODE_S    0
+#define PIORSTMODE_V(x) ((x) << PIORSTMODE_S)
+#define PIORSTMODE_F    PIORSTMODE_V(1U)
 
-#define S_VLAN    3
-#define V_VLAN(x) ((x) << S_VLAN)
-#define F_VLAN    V_VLAN(1U)
+#define PL_PL_INT_CAUSE_A 0x19430
 
-#define S_VNIC_ID    2
-#define V_VNIC_ID(x) ((x) << S_VNIC_ID)
-#define F_VNIC_ID    V_VNIC_ID(1U)
+#define FATALPERR_S    4
+#define FATALPERR_V(x) ((x) << FATALPERR_S)
+#define FATALPERR_F    FATALPERR_V(1U)
 
-#define S_PORT    1
-#define V_PORT(x) ((x) << S_PORT)
-#define F_PORT    V_PORT(1U)
+#define PERRVFID_S    0
+#define PERRVFID_V(x) ((x) << PERRVFID_S)
+#define PERRVFID_F    PERRVFID_V(1U)
 
-#define S_FCOE    0
-#define V_FCOE(x) ((x) << S_FCOE)
-#define F_FCOE    V_FCOE(1U)
+#define PL_REV_A 0x1943c
+
+#define REV_S    0
+#define REV_M    0xfU
+#define REV_V(x) ((x) << REV_S)
+#define REV_G(x) (((x) >> REV_S) & REV_M)
+
+#define LE_DB_INT_CAUSE_A 0x19c3c
+
+#define REQQPARERR_S    16
+#define REQQPARERR_V(x) ((x) << REQQPARERR_S)
+#define REQQPARERR_F    REQQPARERR_V(1U)
+
+#define UNKNOWNCMD_S    15
+#define UNKNOWNCMD_V(x) ((x) << UNKNOWNCMD_S)
+#define UNKNOWNCMD_F    UNKNOWNCMD_V(1U)
+
+#define PARITYERR_S    6
+#define PARITYERR_V(x) ((x) << PARITYERR_S)
+#define PARITYERR_F    PARITYERR_V(1U)
+
+#define LIPMISS_S    5
+#define LIPMISS_V(x) ((x) << LIPMISS_S)
+#define LIPMISS_F    LIPMISS_V(1U)
+
+#define LIP0_S    4
+#define LIP0_V(x) ((x) << LIP0_S)
+#define LIP0_F    LIP0_V(1U)
+
+#define NCSI_INT_CAUSE_A 0x1a0d8
+
+#define CIM_DM_PRTY_ERR_S    8
+#define CIM_DM_PRTY_ERR_V(x) ((x) << CIM_DM_PRTY_ERR_S)
+#define CIM_DM_PRTY_ERR_F    CIM_DM_PRTY_ERR_V(1U)
+
+#define MPS_DM_PRTY_ERR_S    7
+#define MPS_DM_PRTY_ERR_V(x) ((x) << MPS_DM_PRTY_ERR_S)
+#define MPS_DM_PRTY_ERR_F    MPS_DM_PRTY_ERR_V(1U)
+
+#define TXFIFO_PRTY_ERR_S    1
+#define TXFIFO_PRTY_ERR_V(x) ((x) << TXFIFO_PRTY_ERR_S)
+#define TXFIFO_PRTY_ERR_F    TXFIFO_PRTY_ERR_V(1U)
+
+#define RXFIFO_PRTY_ERR_S    0
+#define RXFIFO_PRTY_ERR_V(x) ((x) << RXFIFO_PRTY_ERR_S)
+#define RXFIFO_PRTY_ERR_F    RXFIFO_PRTY_ERR_V(1U)
+
+#define XGMAC_PORT_CFG2_A 0x1018
+
+#define PATEN_S    18
+#define PATEN_V(x) ((x) << PATEN_S)
+#define PATEN_F    PATEN_V(1U)
+
+#define MAGICEN_S    17
+#define MAGICEN_V(x) ((x) << MAGICEN_S)
+#define MAGICEN_F    MAGICEN_V(1U)
+
+#define XGMAC_PORT_MAGIC_MACID_LO 0x1024
+#define XGMAC_PORT_MAGIC_MACID_HI 0x1028
+
+#define XGMAC_PORT_EPIO_DATA0_A 0x10c0
+#define XGMAC_PORT_EPIO_DATA1_A 0x10c4
+#define XGMAC_PORT_EPIO_DATA2_A 0x10c8
+#define XGMAC_PORT_EPIO_DATA3_A 0x10cc
+#define XGMAC_PORT_EPIO_OP_A 0x10d0
+
+#define EPIOWR_S    8
+#define EPIOWR_V(x) ((x) << EPIOWR_S)
+#define EPIOWR_F    EPIOWR_V(1U)
+
+#define ADDRESS_S    0
+#define ADDRESS_V(x) ((x) << ADDRESS_S)
+
+#define MAC_PORT_INT_CAUSE_A 0x8dc
+#define XGMAC_PORT_INT_CAUSE_A 0x10dc
+
+#define TP_TX_MOD_QUEUE_REQ_MAP_A 0x7e28
+
+#define TP_TX_MOD_QUEUE_WEIGHT0_A 0x7e30
+#define TP_TX_MOD_CHANNEL_WEIGHT_A 0x7e34
+
+#define TX_MOD_QUEUE_REQ_MAP_S    0
+#define TX_MOD_QUEUE_REQ_MAP_V(x) ((x) << TX_MOD_QUEUE_REQ_MAP_S)
+
+#define TX_MODQ_WEIGHT3_S    24
+#define TX_MODQ_WEIGHT3_V(x) ((x) << TX_MODQ_WEIGHT3_S)
+
+#define TX_MODQ_WEIGHT2_S    16
+#define TX_MODQ_WEIGHT2_V(x) ((x) << TX_MODQ_WEIGHT2_S)
+
+#define TX_MODQ_WEIGHT1_S    8
+#define TX_MODQ_WEIGHT1_V(x) ((x) << TX_MODQ_WEIGHT1_S)
+
+#define TX_MODQ_WEIGHT0_S    0
+#define TX_MODQ_WEIGHT0_V(x) ((x) << TX_MODQ_WEIGHT0_S)
+
+#define TP_TX_SCHED_HDR_A 0x23
+#define TP_TX_SCHED_FIFO_A 0x24
+#define TP_TX_SCHED_PCMD_A 0x25
 
 #define NUM_MPS_CLS_SRAM_L_INSTANCES 336
 #define NUM_MPS_T5_CLS_SRAM_L_INSTANCES 512
@@ -1968,46 +2058,8 @@
 #define EDC_STRIDE_T5 (EDC_T51_BASE_ADDR - EDC_T50_BASE_ADDR)
 #define EDC_REG_T5(reg, idx) (reg + EDC_STRIDE_T5 * idx)
 
-#define A_PL_VF_REV 0x4
-#define A_PL_VF_WHOAMI 0x0
-#define A_PL_VF_REVISION 0x8
-
-#define S_CHIPID    4
-#define M_CHIPID    0xfU
-#define V_CHIPID(x) ((x) << S_CHIPID)
-#define G_CHIPID(x) (((x) >> S_CHIPID) & M_CHIPID)
-
-/* TP_VLAN_PRI_MAP controls which subset of fields will be present in the
- * Compressed Filter Tuple for LE filters.  Each bit set in TP_VLAN_PRI_MAP
- * selects for a particular field being present.  These fields, when present
- * in the Compressed Filter Tuple, have the following widths in bits.
- */
-#define W_FT_FCOE                       1
-#define W_FT_PORT                       3
-#define W_FT_VNIC_ID                    17
-#define W_FT_VLAN                       17
-#define W_FT_TOS                        8
-#define W_FT_PROTOCOL                   8
-#define W_FT_ETHERTYPE                  16
-#define W_FT_MACMATCH                   9
-#define W_FT_MPSHITTYPE                 3
-#define W_FT_FRAGMENTATION              1
-
-/* Some of the Compressed Filter Tuple fields have internal structure.  These
- * bit shifts/masks describe those structures.  All shifts are relative to the
- * base position of the fields within the Compressed Filter Tuple
- */
-#define S_FT_VLAN_VLD                   16
-#define V_FT_VLAN_VLD(x)                ((x) << S_FT_VLAN_VLD)
-#define F_FT_VLAN_VLD                   V_FT_VLAN_VLD(1U)
-
-#define S_FT_VNID_ID_VF                 0
-#define V_FT_VNID_ID_VF(x)              ((x) << S_FT_VNID_ID_VF)
-
-#define S_FT_VNID_ID_PF                 7
-#define V_FT_VNID_ID_PF(x)              ((x) << S_FT_VNID_ID_PF)
-
-#define S_FT_VNID_ID_VLD                16
-#define V_FT_VNID_ID_VLD(x)             ((x) << S_FT_VNID_ID_VLD)
+#define PL_VF_REV_A 0x4
+#define PL_VF_WHOAMI_A 0x0
+#define PL_VF_REVISION_A 0x8
 
 #endif /* __T4_REGS_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index ecf7459..a404844 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -82,4 +82,37 @@
 #define WINDOW_SHIFT_X		10
 #define PCIEOFST_SHIFT_X	10
 
+/* TP_VLAN_PRI_MAP controls which subset of fields will be present in the
+ * Compressed Filter Tuple for LE filters.  Each bit set in TP_VLAN_PRI_MAP
+ * selects for a particular field being present.  These fields, when present
+ * in the Compressed Filter Tuple, have the following widths in bits.
+ */
+#define FT_FCOE_W                       1
+#define FT_PORT_W                       3
+#define FT_VNIC_ID_W                    17
+#define FT_VLAN_W                       17
+#define FT_TOS_W                        8
+#define FT_PROTOCOL_W                   8
+#define FT_ETHERTYPE_W                  16
+#define FT_MACMATCH_W                   9
+#define FT_MPSHITTYPE_W                 3
+#define FT_FRAGMENTATION_W              1
+
+/* Some of the Compressed Filter Tuple fields have internal structure.  These
+ * bit shifts/masks describe those structures.  All shifts are relative to the
+ * base position of the fields within the Compressed Filter Tuple
+ */
+#define FT_VLAN_VLD_S                   16
+#define FT_VLAN_VLD_V(x)                ((x) << FT_VLAN_VLD_S)
+#define FT_VLAN_VLD_F                   FT_VLAN_VLD_V(1U)
+
+#define FT_VNID_ID_VF_S                 0
+#define FT_VNID_ID_VF_V(x)              ((x) << FT_VNID_ID_VF_S)
+
+#define FT_VNID_ID_PF_S                 7
+#define FT_VNID_ID_PF_V(x)              ((x) << FT_VNID_ID_PF_S)
+
+#define FT_VNID_ID_VLD_S                16
+#define FT_VNID_ID_VLD_V(x)             ((x) << FT_VNID_ID_VLD_S)
+
 #endif /* __T4_VALUES_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index aa9f9cd..7bfbacd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1673,7 +1673,7 @@ static void cxgb4vf_get_regs(struct net_device *dev,
 	reg_block_dump(adapter, regbuf,
 		       T4VF_PL_BASE_ADDR + T4VF_MOD_MAP_PL_FIRST,
 		       T4VF_PL_BASE_ADDR + (is_t4(adapter->params.chip)
-		       ? A_PL_VF_WHOAMI : A_PL_VF_REVISION));
+		       ? PL_VF_WHOAMI_A : PL_VF_REVISION_A));
 	reg_block_dump(adapter, regbuf,
 		       T4VF_CIM_BASE_ADDR + T4VF_MOD_MAP_CIM_FIRST,
 		       T4VF_CIM_BASE_ADDR + T4VF_MOD_MAP_CIM_LAST);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 5e83c18..fcc6108 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -616,8 +616,8 @@ int t4vf_get_sge_params(struct adapter *adapter)
 		 * the driver can just use it.
 		 */
 		whoami = t4_read_reg(adapter,
-				     T4VF_PL_BASE_ADDR + A_PL_VF_WHOAMI);
-		pf = SOURCEPF_GET(whoami);
+				     T4VF_PL_BASE_ADDR + PL_VF_WHOAMI_A);
+		pf = SOURCEPF_G(whoami);
 
 		s_hps = (HOSTPAGESIZEPF0_S +
 			 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * pf);
@@ -1591,7 +1591,7 @@ int t4vf_prep_adapter(struct adapter *adapter)
 		break;
 
 	case CHELSIO_T5:
-		chipid = G_REV(t4_read_reg(adapter, A_PL_VF_REV));
+		chipid = REV_G(t4_read_reg(adapter, PL_VF_REV_A));
 		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, chipid);
 		break;
 	}
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index c641931..6602835 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -421,17 +421,15 @@ csio_hw_sf1_read(struct csio_hw *hw, uint32_t byte_cnt, int32_t cont,
 
 	if (!byte_cnt || byte_cnt > 4)
 		return -EINVAL;
-	if (csio_rd_reg32(hw, SF_OP) & SF_BUSY)
+	if (csio_rd_reg32(hw, SF_OP_A) & SF_BUSY_F)
 		return -EBUSY;
 
-	cont = cont ? SF_CONT : 0;
-	lock = lock ? SF_LOCK : 0;
-
-	csio_wr_reg32(hw, lock | cont | BYTECNT(byte_cnt - 1), SF_OP);
-	ret = csio_hw_wait_op_done_val(hw, SF_OP, SF_BUSY, 0, SF_ATTEMPTS,
-					 10, NULL);
+	csio_wr_reg32(hw,  SF_LOCK_V(lock) | SF_CONT_V(cont) |
+		      BYTECNT_V(byte_cnt - 1), SF_OP_A);
+	ret = csio_hw_wait_op_done_val(hw, SF_OP_A, SF_BUSY_F, 0, SF_ATTEMPTS,
+				       10, NULL);
 	if (!ret)
-		*valp = csio_rd_reg32(hw, SF_DATA);
+		*valp = csio_rd_reg32(hw, SF_DATA_A);
 	return ret;
 }
 
@@ -453,16 +451,14 @@ csio_hw_sf1_write(struct csio_hw *hw, uint32_t byte_cnt, uint32_t cont,
 {
 	if (!byte_cnt || byte_cnt > 4)
 		return -EINVAL;
-	if (csio_rd_reg32(hw, SF_OP) & SF_BUSY)
+	if (csio_rd_reg32(hw, SF_OP_A) & SF_BUSY_F)
 		return -EBUSY;
 
-	cont = cont ? SF_CONT : 0;
-	lock = lock ? SF_LOCK : 0;
-
-	csio_wr_reg32(hw, val, SF_DATA);
-	csio_wr_reg32(hw, cont | BYTECNT(byte_cnt - 1) | OP_WR | lock, SF_OP);
+	csio_wr_reg32(hw, val, SF_DATA_A);
+	csio_wr_reg32(hw, SF_CONT_V(cont) | BYTECNT_V(byte_cnt - 1) |
+		      OP_V(1) | SF_LOCK_V(lock), SF_OP_A);
 
-	return csio_hw_wait_op_done_val(hw, SF_OP, SF_BUSY, 0, SF_ATTEMPTS,
+	return csio_hw_wait_op_done_val(hw, SF_OP_A, SF_BUSY_F, 0, SF_ATTEMPTS,
 					10, NULL);
 }
 
@@ -533,7 +529,7 @@ csio_hw_read_flash(struct csio_hw *hw, uint32_t addr, uint32_t nwords,
 	for ( ; nwords; nwords--, data++) {
 		ret = csio_hw_sf1_read(hw, 4, nwords > 1, nwords == 1, data);
 		if (nwords == 1)
-			csio_wr_reg32(hw, 0, SF_OP);    /* unlock SF */
+			csio_wr_reg32(hw, 0, SF_OP_A);    /* unlock SF */
 		if (ret)
 			return ret;
 		if (byte_oriented)
@@ -586,7 +582,7 @@ csio_hw_write_flash(struct csio_hw *hw, uint32_t addr,
 	if (ret)
 		goto unlock;
 
-	csio_wr_reg32(hw, 0, SF_OP);    /* unlock SF */
+	csio_wr_reg32(hw, 0, SF_OP_A);    /* unlock SF */
 
 	/* Read the page to verify the write succeeded */
 	ret = csio_hw_read_flash(hw, addr & ~0xff, ARRAY_SIZE(buf), buf, 1);
@@ -603,7 +599,7 @@ csio_hw_write_flash(struct csio_hw *hw, uint32_t addr,
 	return 0;
 
 unlock:
-	csio_wr_reg32(hw, 0, SF_OP);    /* unlock SF */
+	csio_wr_reg32(hw, 0, SF_OP_A);    /* unlock SF */
 	return ret;
 }
 
@@ -641,7 +637,7 @@ out:
 	if (ret)
 		csio_err(hw, "erase of flash sector %d failed, error %d\n",
 			 start, ret);
-	csio_wr_reg32(hw, 0, SF_OP);    /* unlock SF */
+	csio_wr_reg32(hw, 0, SF_OP_A);    /* unlock SF */
 	return 0;
 }
 
@@ -833,7 +829,7 @@ csio_hw_get_flash_params(struct csio_hw *hw)
 	ret = csio_hw_sf1_write(hw, 1, 1, 0, SF_RD_ID);
 	if (!ret)
 		ret = csio_hw_sf1_read(hw, 3, 0, 1, &info);
-	csio_wr_reg32(hw, 0, SF_OP);    /* unlock SF */
+	csio_wr_reg32(hw, 0, SF_OP_A);    /* unlock SF */
 	if (ret != 0)
 		return ret;
 
@@ -861,17 +857,17 @@ csio_hw_dev_ready(struct csio_hw *hw)
 	uint32_t reg;
 	int cnt = 6;
 
-	while (((reg = csio_rd_reg32(hw, PL_WHOAMI)) == 0xFFFFFFFF) &&
-								(--cnt != 0))
+	while (((reg = csio_rd_reg32(hw, PL_WHOAMI_A)) == 0xFFFFFFFF) &&
+	       (--cnt != 0))
 		mdelay(100);
 
-	if ((cnt == 0) && (((int32_t)(SOURCEPF_GET(reg)) < 0) ||
-			    (SOURCEPF_GET(reg) >= CSIO_MAX_PFN))) {
+	if ((cnt == 0) && (((int32_t)(SOURCEPF_G(reg)) < 0) ||
+			   (SOURCEPF_G(reg) >= CSIO_MAX_PFN))) {
 		csio_err(hw, "PL_WHOAMI returned 0x%x, cnt:%d\n", reg, cnt);
 		return -EIO;
 	}
 
-	hw->pfn = SOURCEPF_GET(reg);
+	hw->pfn = SOURCEPF_G(reg);
 
 	return 0;
 }
@@ -1078,7 +1074,7 @@ csio_do_reset(struct csio_hw *hw, bool fw_rst)
 
 	if (!fw_rst) {
 		/* PIO reset */
-		csio_wr_reg32(hw, PIORSTMODE | PIORST, PL_RST);
+		csio_wr_reg32(hw, PIORSTMODE_F | PIORST_F, PL_RST_A);
 		mdelay(2000);
 		return 0;
 	}
@@ -1090,7 +1086,7 @@ csio_do_reset(struct csio_hw *hw, bool fw_rst)
 	}
 
 	csio_mb_reset(hw, mbp, CSIO_MB_DEFAULT_TMO,
-		      PIORSTMODE | PIORST, 0, NULL);
+		      PIORSTMODE_F | PIORST_F, 0, NULL);
 
 	if (csio_mb_issue(hw, mbp)) {
 		csio_err(hw, "Issue of RESET command failed.n");
@@ -1166,7 +1162,7 @@ csio_hw_fw_halt(struct csio_hw *hw, uint32_t mbox, int32_t force)
 		}
 
 		csio_mb_reset(hw, mbp, CSIO_MB_DEFAULT_TMO,
-			      PIORSTMODE | PIORST, FW_RESET_CMD_HALT_F,
+			      PIORSTMODE_F | PIORST_F, FW_RESET_CMD_HALT_F,
 			      NULL);
 
 		if (csio_mb_issue(hw, mbp)) {
@@ -1251,7 +1247,7 @@ csio_hw_fw_restart(struct csio_hw *hw, uint32_t mbox, int32_t reset)
 				return 0;
 		}
 
-		csio_wr_reg32(hw, PIORSTMODE | PIORST, PL_RST);
+		csio_wr_reg32(hw, PIORSTMODE_F | PIORST_F, PL_RST_A);
 		msleep(2000);
 	} else {
 		int ms;
@@ -2040,7 +2036,7 @@ csio_hw_configure(struct csio_hw *hw)
 	}
 
 	/* HW version */
-	hw->chip_ver = (char)csio_rd_reg32(hw, PL_REV);
+	hw->chip_ver = (char)csio_rd_reg32(hw, PL_REV_A);
 
 	/* Needed for FW download */
 	rv = csio_hw_get_flash_params(hw);
@@ -2218,7 +2214,7 @@ out:
 	return;
 }
 
-#define PF_INTR_MASK (PFSW | PFCIM)
+#define PF_INTR_MASK (PFSW_F | PFCIM_F)
 
 /*
  * csio_hw_intr_enable - Enable HW interrupts
@@ -2230,8 +2226,8 @@ static void
 csio_hw_intr_enable(struct csio_hw *hw)
 {
 	uint16_t vec = (uint16_t)csio_get_mb_intr_idx(csio_hw_to_mbm(hw));
-	uint32_t pf = SOURCEPF_GET(csio_rd_reg32(hw, PL_WHOAMI));
-	uint32_t pl = csio_rd_reg32(hw, PL_INT_ENABLE);
+	uint32_t pf = SOURCEPF_G(csio_rd_reg32(hw, PL_WHOAMI_A));
+	uint32_t pl = csio_rd_reg32(hw, PL_INT_ENABLE_A);
 
 	/*
 	 * Set aivec for MSI/MSIX. PCIE_PF_CFG.INTXType is set up
@@ -2244,7 +2240,7 @@ csio_hw_intr_enable(struct csio_hw *hw)
 		csio_set_reg_field(hw, MYPF_REG(PCIE_PF_CFG_A),
 				   AIVEC_V(AIVEC_M), 0);
 
-	csio_wr_reg32(hw, PF_INTR_MASK, MYPF_REG(PL_PF_INT_ENABLE));
+	csio_wr_reg32(hw, PF_INTR_MASK, MYPF_REG(PL_PF_INT_ENABLE_A));
 
 	/* Turn on MB interrupts - this will internally flush PIO as well */
 	csio_mb_intr_enable(hw);
@@ -2254,8 +2250,8 @@ csio_hw_intr_enable(struct csio_hw *hw)
 		/*
 		 * Disable the Serial FLASH interrupt, if enabled!
 		 */
-		pl &= (~SF);
-		csio_wr_reg32(hw, pl, PL_INT_ENABLE);
+		pl &= (~SF_F);
+		csio_wr_reg32(hw, pl, PL_INT_ENABLE_A);
 
 		csio_wr_reg32(hw, ERR_CPL_EXCEED_IQE_SIZE_F |
 			      EGRESS_SIZE_ERR_F | ERR_INVALID_CIDX_INC_F |
@@ -2266,7 +2262,7 @@ csio_hw_intr_enable(struct csio_hw *hw)
 			      ERR_BAD_DB_PIDX0_F | ERR_ING_CTXT_PRIO_F |
 			      ERR_EGR_CTXT_PRIO_F | INGRESS_SIZE_ERR_F,
 			      SGE_INT_ENABLE3_A);
-		csio_set_reg_field(hw, PL_INT_MAP0, 0, 1 << pf);
+		csio_set_reg_field(hw, PL_INT_MAP0_A, 0, 1 << pf);
 	}
 
 	hw->flags |= CSIO_HWF_HW_INTR_ENABLED;
@@ -2282,16 +2278,16 @@ csio_hw_intr_enable(struct csio_hw *hw)
 void
 csio_hw_intr_disable(struct csio_hw *hw)
 {
-	uint32_t pf = SOURCEPF_GET(csio_rd_reg32(hw, PL_WHOAMI));
+	uint32_t pf = SOURCEPF_G(csio_rd_reg32(hw, PL_WHOAMI_A));
 
 	if (!(hw->flags & CSIO_HWF_HW_INTR_ENABLED))
 		return;
 
 	hw->flags &= ~CSIO_HWF_HW_INTR_ENABLED;
 
-	csio_wr_reg32(hw, 0, MYPF_REG(PL_PF_INT_ENABLE));
+	csio_wr_reg32(hw, 0, MYPF_REG(PL_PF_INT_ENABLE_A));
 	if (csio_is_hw_master(hw))
-		csio_set_reg_field(hw, PL_INT_MAP0, 1 << pf, 0);
+		csio_set_reg_field(hw, PL_INT_MAP0_A, 1 << pf, 0);
 
 	/* Turn off MB interrupts */
 	csio_mb_intr_disable(hw);
@@ -2595,7 +2591,7 @@ csio_hws_removing(struct csio_hw *hw, enum csio_hw_ev evt)
 		 * register directly.
 		 */
 		csio_err(hw, "Resetting HW and waiting 2 seconds...\n");
-		csio_wr_reg32(hw, PIORSTMODE | PIORST, PL_RST);
+		csio_wr_reg32(hw, PIORSTMODE_F | PIORST_F, PL_RST_A);
 		mdelay(2000);
 		break;
 
@@ -2814,7 +2810,7 @@ static void csio_ulprx_intr_handler(struct csio_hw *hw)
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, ULP_RX_INT_CAUSE, ulprx_intr_info))
+	if (csio_handle_intr_status(hw, ULP_RX_INT_CAUSE_A, ulprx_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -2889,16 +2885,16 @@ static void csio_pmrx_intr_handler(struct csio_hw *hw)
 static void csio_cplsw_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info cplsw_intr_info[] = {
-		{ CIM_OP_MAP_PERR, "CPLSW CIM op_map parity error", -1, 1 },
-		{ CIM_OVFL_ERROR, "CPLSW CIM overflow", -1, 1 },
-		{ TP_FRAMING_ERROR, "CPLSW TP framing error", -1, 1 },
-		{ SGE_FRAMING_ERROR, "CPLSW SGE framing error", -1, 1 },
-		{ CIM_FRAMING_ERROR, "CPLSW CIM framing error", -1, 1 },
-		{ ZERO_SWITCH_ERROR, "CPLSW no-switch error", -1, 1 },
+		{ CIM_OP_MAP_PERR_F, "CPLSW CIM op_map parity error", -1, 1 },
+		{ CIM_OVFL_ERROR_F, "CPLSW CIM overflow", -1, 1 },
+		{ TP_FRAMING_ERROR_F, "CPLSW TP framing error", -1, 1 },
+		{ SGE_FRAMING_ERROR_F, "CPLSW SGE framing error", -1, 1 },
+		{ CIM_FRAMING_ERROR_F, "CPLSW CIM framing error", -1, 1 },
+		{ ZERO_SWITCH_ERROR_F, "CPLSW no-switch error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, CPL_INTR_CAUSE, cplsw_intr_info))
+	if (csio_handle_intr_status(hw, CPL_INTR_CAUSE_A, cplsw_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -2908,15 +2904,15 @@ static void csio_cplsw_intr_handler(struct csio_hw *hw)
 static void csio_le_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info le_intr_info[] = {
-		{ LIPMISS, "LE LIP miss", -1, 0 },
-		{ LIP0, "LE 0 LIP error", -1, 0 },
-		{ PARITYERR, "LE parity error", -1, 1 },
-		{ UNKNOWNCMD, "LE unknown command", -1, 1 },
-		{ REQQPARERR, "LE request queue parity error", -1, 1 },
+		{ LIPMISS_F, "LE LIP miss", -1, 0 },
+		{ LIP0_F, "LE 0 LIP error", -1, 0 },
+		{ PARITYERR_F, "LE parity error", -1, 1 },
+		{ UNKNOWNCMD_F, "LE unknown command", -1, 1 },
+		{ REQQPARERR_F, "LE request queue parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, LE_DB_INT_CAUSE, le_intr_info))
+	if (csio_handle_intr_status(hw, LE_DB_INT_CAUSE_A, le_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -3054,13 +3050,13 @@ static void csio_ma_intr_handler(struct csio_hw *hw)
 static void csio_smb_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info smb_intr_info[] = {
-		{ MSTTXFIFOPARINT, "SMB master Tx FIFO parity error", -1, 1 },
-		{ MSTRXFIFOPARINT, "SMB master Rx FIFO parity error", -1, 1 },
-		{ SLVFIFOPARINT, "SMB slave FIFO parity error", -1, 1 },
+		{ MSTTXFIFOPARINT_F, "SMB master Tx FIFO parity error", -1, 1 },
+		{ MSTRXFIFOPARINT_F, "SMB master Rx FIFO parity error", -1, 1 },
+		{ SLVFIFOPARINT_F, "SMB slave FIFO parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, SMB_INT_CAUSE, smb_intr_info))
+	if (csio_handle_intr_status(hw, SMB_INT_CAUSE_A, smb_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -3070,14 +3066,14 @@ static void csio_smb_intr_handler(struct csio_hw *hw)
 static void csio_ncsi_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info ncsi_intr_info[] = {
-		{ CIM_DM_PRTY_ERR, "NC-SI CIM parity error", -1, 1 },
-		{ MPS_DM_PRTY_ERR, "NC-SI MPS parity error", -1, 1 },
-		{ TXFIFO_PRTY_ERR, "NC-SI Tx FIFO parity error", -1, 1 },
-		{ RXFIFO_PRTY_ERR, "NC-SI Rx FIFO parity error", -1, 1 },
+		{ CIM_DM_PRTY_ERR_F, "NC-SI CIM parity error", -1, 1 },
+		{ MPS_DM_PRTY_ERR_F, "NC-SI MPS parity error", -1, 1 },
+		{ TXFIFO_PRTY_ERR_F, "NC-SI Tx FIFO parity error", -1, 1 },
+		{ RXFIFO_PRTY_ERR_F, "NC-SI Rx FIFO parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, NCSI_INT_CAUSE, ncsi_intr_info))
+	if (csio_handle_intr_status(hw, NCSI_INT_CAUSE_A, ncsi_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -3088,13 +3084,13 @@ static void csio_xgmac_intr_handler(struct csio_hw *hw, int port)
 {
 	uint32_t v = csio_rd_reg32(hw, CSIO_MAC_INT_CAUSE_REG(hw, port));
 
-	v &= TXFIFO_PRTY_ERR | RXFIFO_PRTY_ERR;
+	v &= TXFIFO_PRTY_ERR_F | RXFIFO_PRTY_ERR_F;
 	if (!v)
 		return;
 
-	if (v & TXFIFO_PRTY_ERR)
+	if (v & TXFIFO_PRTY_ERR_F)
 		csio_fatal(hw, "XGMAC %d Tx FIFO parity error\n", port);
-	if (v & RXFIFO_PRTY_ERR)
+	if (v & RXFIFO_PRTY_ERR_F)
 		csio_fatal(hw, "XGMAC %d Rx FIFO parity error\n", port);
 	csio_wr_reg32(hw, v, CSIO_MAC_INT_CAUSE_REG(hw, port));
 	csio_hw_fatal_err(hw);
@@ -3106,12 +3102,12 @@ static void csio_xgmac_intr_handler(struct csio_hw *hw, int port)
 static void csio_pl_intr_handler(struct csio_hw *hw)
 {
 	static struct intr_info pl_intr_info[] = {
-		{ FATALPERR, "T4 fatal parity error", -1, 1 },
-		{ PERRVFID, "PL VFID_MAP parity error", -1, 1 },
+		{ FATALPERR_F, "T4 fatal parity error", -1, 1 },
+		{ PERRVFID_F, "PL VFID_MAP parity error", -1, 1 },
 		{ 0, NULL, 0, 0 }
 	};
 
-	if (csio_handle_intr_status(hw, PL_PL_INT_CAUSE, pl_intr_info))
+	if (csio_handle_intr_status(hw, PL_PL_INT_CAUSE_A, pl_intr_info))
 		csio_hw_fatal_err(hw);
 }
 
@@ -3126,7 +3122,7 @@ static void csio_pl_intr_handler(struct csio_hw *hw)
 int
 csio_hw_slow_intr_handler(struct csio_hw *hw)
 {
-	uint32_t cause = csio_rd_reg32(hw, PL_INT_CAUSE);
+	uint32_t cause = csio_rd_reg32(hw, PL_INT_CAUSE_A);
 
 	if (!(cause & CSIO_GLBL_INTR_MASK)) {
 		CSIO_INC_STATS(hw, n_plint_unexp);
@@ -3137,75 +3133,75 @@ csio_hw_slow_intr_handler(struct csio_hw *hw)
 
 	CSIO_INC_STATS(hw, n_plint_cnt);
 
-	if (cause & CIM)
+	if (cause & CIM_F)
 		csio_cim_intr_handler(hw);
 
-	if (cause & MPS)
+	if (cause & MPS_F)
 		csio_mps_intr_handler(hw);
 
-	if (cause & NCSI)
+	if (cause & NCSI_F)
 		csio_ncsi_intr_handler(hw);
 
-	if (cause & PL)
+	if (cause & PL_F)
 		csio_pl_intr_handler(hw);
 
-	if (cause & SMB)
+	if (cause & SMB_F)
 		csio_smb_intr_handler(hw);
 
-	if (cause & XGMAC0)
+	if (cause & XGMAC0_F)
 		csio_xgmac_intr_handler(hw, 0);
 
-	if (cause & XGMAC1)
+	if (cause & XGMAC1_F)
 		csio_xgmac_intr_handler(hw, 1);
 
-	if (cause & XGMAC_KR0)
+	if (cause & XGMAC_KR0_F)
 		csio_xgmac_intr_handler(hw, 2);
 
-	if (cause & XGMAC_KR1)
+	if (cause & XGMAC_KR1_F)
 		csio_xgmac_intr_handler(hw, 3);
 
-	if (cause & PCIE)
+	if (cause & PCIE_F)
 		hw->chip_ops->chip_pcie_intr_handler(hw);
 
-	if (cause & MC)
+	if (cause & MC_F)
 		csio_mem_intr_handler(hw, MEM_MC);
 
-	if (cause & EDC0)
+	if (cause & EDC0_F)
 		csio_mem_intr_handler(hw, MEM_EDC0);
 
-	if (cause & EDC1)
+	if (cause & EDC1_F)
 		csio_mem_intr_handler(hw, MEM_EDC1);
 
-	if (cause & LE)
+	if (cause & LE_F)
 		csio_le_intr_handler(hw);
 
-	if (cause & TP)
+	if (cause & TP_F)
 		csio_tp_intr_handler(hw);
 
-	if (cause & MA)
+	if (cause & MA_F)
 		csio_ma_intr_handler(hw);
 
-	if (cause & PM_TX)
+	if (cause & PM_TX_F)
 		csio_pmtx_intr_handler(hw);
 
-	if (cause & PM_RX)
+	if (cause & PM_RX_F)
 		csio_pmrx_intr_handler(hw);
 
-	if (cause & ULP_RX)
+	if (cause & ULP_RX_F)
 		csio_ulprx_intr_handler(hw);
 
-	if (cause & CPL_SWITCH)
+	if (cause & CPL_SWITCH_F)
 		csio_cplsw_intr_handler(hw);
 
-	if (cause & SGE)
+	if (cause & SGE_F)
 		csio_sge_intr_handler(hw);
 
-	if (cause & ULP_TX)
+	if (cause & ULP_TX_F)
 		csio_ulptx_intr_handler(hw);
 
 	/* Clear the interrupts just processed for which we are the master. */
-	csio_wr_reg32(hw, cause & CSIO_GLBL_INTR_MASK, PL_INT_CAUSE);
-	csio_rd_reg32(hw, PL_INT_CAUSE); /* flush */
+	csio_wr_reg32(hw, cause & CSIO_GLBL_INTR_MASK, PL_INT_CAUSE_A);
+	csio_rd_reg32(hw, PL_INT_CAUSE_A); /* flush */
 
 	return 1;
 }
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
index 68248da..bd97204 100644
--- a/drivers/scsi/csiostor/csio_hw.h
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -117,10 +117,10 @@ extern int csio_msi;
 #define CSIO_ASIC_DEVID_PROTO_MASK		0xFF00
 #define CSIO_ASIC_DEVID_TYPE_MASK		0x00FF
 
-#define CSIO_GLBL_INTR_MASK		(CIM | MPS | PL | PCIE | MC | EDC0 | \
-					 EDC1 | LE | TP | MA | PM_TX | PM_RX | \
-					 ULP_RX | CPL_SWITCH | SGE | \
-					 ULP_TX | SF)
+#define CSIO_GLBL_INTR_MASK	(CIM_F | MPS_F | PL_F | PCIE_F | MC_F | \
+				 EDC0_F | EDC1_F | LE_F | TP_F | MA_F | \
+				 PM_TX_F | PM_RX_F | ULP_RX_F | \
+				 CPL_SWITCH_F | SGE_F | ULP_TX_F | SF_F)
 
 /*
  * Hard parameters used to initialize the card in the absence of a
diff --git a/drivers/scsi/csiostor/csio_hw_chip.h b/drivers/scsi/csiostor/csio_hw_chip.h
index 0198662..70c0bdd 100644
--- a/drivers/scsi/csiostor/csio_hw_chip.h
+++ b/drivers/scsi/csiostor/csio_hw_chip.h
@@ -77,8 +77,8 @@ static inline int csio_is_t5(uint16_t chip)
 	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH_M) : (LP_INT_THRESH_T5_M))
 
 #define CSIO_MAC_INT_CAUSE_REG(hw, port)				\
-	(csio_is_t4(hw->chip_id) ? (PORT_REG(port, XGMAC_PORT_INT_CAUSE)) : \
-				(T5_PORT_REG(port, MAC_PORT_INT_CAUSE)))
+	(csio_is_t4(hw->chip_id) ? (PORT_REG(port, XGMAC_PORT_INT_CAUSE_A)) : \
+				(T5_PORT_REG(port, MAC_PORT_INT_CAUSE_A)))
 
 #define FW_VERSION_MAJOR(hw) (csio_is_t4(hw->chip_id) ? 1 : 0)
 #define FW_VERSION_MINOR(hw) (csio_is_t4(hw->chip_id) ? 2 : 0)
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index cb53985..1132c41 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -1464,10 +1464,10 @@ csio_mb_isr_handler(struct csio_hw *hw)
 	__be64			hdr;
 	struct fw_cmd_hdr	*fw_hdr;
 
-	pl_cause = csio_rd_reg32(hw, MYPF_REG(PL_PF_INT_CAUSE));
+	pl_cause = csio_rd_reg32(hw, MYPF_REG(PL_PF_INT_CAUSE_A));
 	cim_cause = csio_rd_reg32(hw, MYPF_REG(CIM_PF_HOST_INT_CAUSE_A));
 
-	if (!(pl_cause & PFCIM) || !(cim_cause & MBMSGRDYINT_F)) {
+	if (!(pl_cause & PFCIM_F) || !(cim_cause & MBMSGRDYINT_F)) {
 		CSIO_INC_STATS(hw, n_mbint_unexp);
 		return -EINVAL;
 	}
@@ -1479,7 +1479,7 @@ csio_mb_isr_handler(struct csio_hw *hw)
 	 * first followed by PL-Cause next.
 	 */
 	csio_wr_reg32(hw, MBMSGRDYINT_F, MYPF_REG(CIM_PF_HOST_INT_CAUSE_A));
-	csio_wr_reg32(hw, PFCIM, MYPF_REG(PL_PF_INT_CAUSE));
+	csio_wr_reg32(hw, PFCIM_F, MYPF_REG(PL_PF_INT_CAUSE_A));
 
 	ctl = csio_rd_reg32(hw, ctl_reg);
 
diff --git a/drivers/scsi/csiostor/csio_wr.c b/drivers/scsi/csiostor/csio_wr.c
index e22503b..b47ea33 100644
--- a/drivers/scsi/csiostor/csio_wr.c
+++ b/drivers/scsi/csiostor/csio_wr.c
@@ -1343,7 +1343,7 @@ csio_wr_fixup_host_params(struct csio_hw *hw)
 			SGE_FL_BUFFER_SIZE3_A);
 	}
 
-	csio_wr_reg32(hw, HPZ0(PAGE_SHIFT - 12), ULP_RX_TDDP_PSZ);
+	csio_wr_reg32(hw, HPZ0_V(PAGE_SHIFT - 12), ULP_RX_TDDP_PSZ_A);
 
 	/* default value of rx_dma_offset of the NIC driver */
 	csio_set_reg_field(hw, SGE_CONTROL_A,
-- 
1.7.1
