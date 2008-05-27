From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 10/12]bnx2x: Add CNIC support
Date: Tue, 27 May 2008 10:17:41 -0400
Message-ID: <1211897861.6967.83.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Eliezer Tamir" <eliezert@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4924 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236AbYE0OR5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:17:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Add CNIC support

=EF=BB=BFSigned-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   30 +++--
 drivers/net/bnx2x_main.c |  319 +++++++++++++++++++++++++++++++++++++-=
-------
 2 files changed, 282 insertions(+), 67 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4e3e18d..4fb4962 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -705,7 +705,11 @@ struct bnx2x {
 	struct pci_dev		*pdev;
=20
 	atomic_t		intr_sem;
-	struct msix_entry       msix_table[MAX_CONTEXT+1];
+#ifdef BCM_CNIC
+	struct msix_entry	msix_table[MAX_CONTEXT+2];
+#else
+	struct msix_entry	msix_table[MAX_CONTEXT+1];
+#endif
=20
 	int			tx_ring_size;
=20
@@ -844,15 +848,21 @@ struct bnx2x {
 	struct bnx2x_slowpath	*slowpath;
 	dma_addr_t		slowpath_mapping;
=20
-#ifdef BCM_ISCSI
-	void    		*t1;
-	dma_addr_t      	t1_mapping;
-	void    		*t2;
-	dma_addr_t      	t2_mapping;
-	void    		*timers;
-	dma_addr_t      	timers_mapping;
-	void    		*qm;
-	dma_addr_t      	qm_mapping;
+#ifdef BCM_CNIC
+	void			*t1;
+	dma_addr_t		t1_mapping;
+	void			*t2;
+	dma_addr_t		t2_mapping;
+	void			*timers;
+	dma_addr_t		timers_mapping;
+	void			*qm;
+	dma_addr_t		qm_mapping;
+	struct cnic_ops		*cnic_ops;
+	void			*cnic_data;
+	u32			cnic_tag;
+	struct cnic_eth_dev	cnic_eth_dev;
+	struct host_status_block *cnic_sb;
+	dma_addr_t		cnic_sb_mapping;
 #endif
=20
 	int			dmae_ready;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5ab6013..8c99fa6 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -20,6 +20,10 @@
  */
 /* #define BNX2X_STOP_ON_ERROR */
=20
+#ifdef CONFIG_BNX2X_CNIC
+#define BCM_CNIC
+#endif
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -58,6 +62,9 @@
 #include <linux/zlib.h>
 #include <linux/io.h>
=20
+#ifdef BCM_CNIC
+#include "cnic_drv.h"
+#endif
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
 #include "bnx2x_hsi.h"
@@ -1575,6 +1582,20 @@ static irqreturn_t bnx2x_interrupt(int irq, void=
 *dev_instance)
 		status &=3D ~mask;
 	}
=20
+#ifdef BCM_CNIC
+	mask =3D 0x2 << CNIC_SB_ID;
+	if (status & mask) {
+		struct cnic_ops *c_ops =3D NULL;
+
+		rcu_read_lock();
+		c_ops =3D rcu_dereference(bp->cnic_ops);
+		if (c_ops)
+			c_ops->cnic_handler(bp->cnic_data, NULL);
+		rcu_read_unlock();
+
+		status &=3D ~mask;
+	}
+#endif
=20
 	if (unlikely(status & 0x1)) {
 		schedule_work(&bp->sp_task);
@@ -4582,7 +4603,11 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 		fp->state =3D BNX2X_FP_STATE_CLOSED;
 		fp->index =3D i;
 		fp->cl_id =3D BP_L_ID(bp) + i;
+#ifdef BCM_CNIC
+		fp->sb_id =3D fp->cl_id + 1;
+#else
 		fp->sb_id =3D fp->cl_id;
+#endif
 		DP(NETIF_MSG_IFUP,
 		   "bnx2x_init_sb(%p,%p) index %d  cl_id %d  sb %d\n",
 		   bp, fp->status_blk, i, FP_CL_ID(fp), FP_SB_ID(fp));
@@ -4860,7 +4885,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	msleep(50);
 	bnx2x_init_block(bp, BRB1_COMMON_START, BRB1_COMMON_END);
 	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
-#ifndef BCM_ISCSI
+#ifndef BCM_CNIC
 	/* set NIC mode */
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 #endif
@@ -4918,6 +4943,9 @@ static void enable_blocks_attention(struct bnx2x =
*bp)
 static int bnx2x_init_common(struct bnx2x *bp)
 {
 	u32 val, i;
+#ifdef BCM_CNIC
+	u32 wb_write[2];
+#endif
=20
 	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_FUNC(bp));
=20
@@ -4957,13 +4985,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_RD_CDURD_SWAP_MODE, 1);
 #endif
=20
-#ifndef BCM_ISCSI
-		/* set NIC mode */
-		REG_WR(bp, PRS_REG_NIC_MODE, 1);
-#endif
-
-		REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 5);
-#ifdef BCM_ISCSI
+	REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 2);
+#ifdef BCM_CNIC
 	REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
 	REG_WR(bp, PXP2_REG_RQ_QM_P_SIZE, 5);
 	REG_WR(bp, PXP2_REG_RQ_SRC_P_SIZE, 5);
@@ -5006,11 +5029,23 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_read_dmae(bp, USEM_REG_PASSIVE_BUFFER, 3);
=20
 	bnx2x_init_block(bp, QM_COMMON_START, QM_COMMON_END);
+#ifdef BCM_CNIC
+	wb_write[0] =3D 0;
+	wb_write[1] =3D 0;
+	for (i =3D 0; i < 64; i++) {
+		REG_WR(bp, QM_REG_BASEADDR + i*4, 1024 * 4 * (i%32));
+		bnx2x_init_ind_wr(bp, QM_REG_PTRTBL + i*8, wb_write, 2);
+
+		if (CHIP_IS_E1H(bp))
+			bnx2x_init_ind_wr(bp, QM_REG_PTRTBL_EXT_A + i*8,
+					  wb_write, 2);
+	}
+#endif
 	/* soft reset pulse */
 	REG_WR(bp, QM_REG_SOFT_RESET, 1);
 	REG_WR(bp, QM_REG_SOFT_RESET, 0);
=20
-#ifdef BCM_ISCSI
+#ifdef BCM_CNIC
 	bnx2x_init_block(bp, TIMERS_COMMON_START, TIMERS_COMMON_END);
 #endif
=20
@@ -5031,6 +5066,10 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	}
=20
 	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
+#ifndef BCM_CNIC
+	/* set NIC mode */
+	REG_WR(bp, PRS_REG_NIC_MODE, 1);
+#endif
 	if (CHIP_IS_E1H(bp))
 		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_E1HMF(bp));
=20
@@ -5215,40 +5254,16 @@ static int bnx2x_init_port(struct bnx2x *bp)
=20
 	/* Port PXP comes here */
 	/* Port PXP2 comes here */
-#ifdef BCM_ISCSI
-	/* Port0  1
-	 * Port1  385 */
-	i++;
-	wb_write[0] =3D ONCHIP_ADDR1(bp->timers_mapping);
-	wb_write[1] =3D ONCHIP_ADDR2(bp->timers_mapping);
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-	REG_WR(bp, PXP2_REG_PSWRQ_TM0_L2P + func*4, PXP_ONE_ILT(i));
-
-	/* Port0  2
-	 * Port1  386 */
-	i++;
-	wb_write[0] =3D ONCHIP_ADDR1(bp->qm_mapping);
-	wb_write[1] =3D ONCHIP_ADDR2(bp->qm_mapping);
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-	REG_WR(bp, PXP2_REG_PSWRQ_QM0_L2P + func*4, PXP_ONE_ILT(i));
-
-	/* Port0  3
-	 * Port1  387 */
-	i++;
-	wb_write[0] =3D ONCHIP_ADDR1(bp->t1_mapping);
-	wb_write[1] =3D ONCHIP_ADDR2(bp->t1_mapping);
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-	REG_WR(bp, PXP2_REG_PSWRQ_SRC0_L2P + func*4, PXP_ONE_ILT(i));
-#endif
 	/* Port CMs come here */
=20
 	/* Port QM comes here */
-#ifdef BCM_ISCSI
-	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + func*4, 1024/64*20);
-	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + func*4, 31);
+#ifdef BCM_CNIC
+	REG_WR(bp, QM_REG_CONNNUM_0 + port*4, 1024/16 - 1);
=20
-	bnx2x_init_block(bp, func ? TIMERS_PORT1_START : TIMERS_PORT0_START,
-			     func ? TIMERS_PORT1_END : TIMERS_PORT0_END);
+	bnx2x_init_block(bp, port ? TIMERS_PORT1_START : TIMERS_PORT0_START,
+			     port ? TIMERS_PORT1_END : TIMERS_PORT0_END);
+	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 1024/64*20);
+	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
 #endif
 	/* Port DQ comes here */
 	/* Port BRB1 comes here */
@@ -5284,18 +5299,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	msleep(5);
 	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
=20
-#ifdef BCM_ISCSI
-	/* tell the searcher where the T2 table is */
-	REG_WR(bp, SRC_REG_COUNTFREE0 + func*4, 16*1024/64);
-
-	wb_write[0] =3D U64_LO(bp->t2_mapping);
-	wb_write[1] =3D U64_HI(bp->t2_mapping);
-	REG_WR_DMAE(bp, SRC_REG_FIRSTFREE0 + func*4, wb_write, 2);
-	wb_write[0] =3D U64_LO((u64)bp->t2_mapping + 16*1024 - 64);
-	wb_write[1] =3D U64_HI((u64)bp->t2_mapping + 16*1024 - 64);
-	REG_WR_DMAE(bp, SRC_REG_LASTFREE0 + func*4, wb_write, 2);
-
-	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + func*4, 10);
+#ifdef BCM_CNIC
 	/* Port SRCH comes here */
 #endif
 	/* Port CDU comes here */
@@ -5378,7 +5382,12 @@ static int bnx2x_init_port(struct bnx2x *bp)
 #define PXP_ONE_ILT(x)		(((x) << 10) | x)
 #define PXP_ILT_RANGE(f, l)	(((l) << 10) | f)
=20
+#ifdef BCM_CNIC
+#define CNIC_ILT_LINES		127
+#define CNIC_CTX_PER_ILT	16
+#else
 #define CNIC_ILT_LINES		0
+#endif
=20
 static void bnx2x_ilt_wr(struct bnx2x *bp, u32 index, dma_addr_t addr)
 {
@@ -5410,6 +5419,43 @@ static int bnx2x_init_func(struct bnx2x *bp)
 		REG_WR(bp, PXP2_REG_PSWRQ_CDU0_L2P + func*4,
 		       PXP_ILT_RANGE(i, i + CNIC_ILT_LINES));
=20
+#ifdef BCM_CNIC
+	i +=3D 1 + CNIC_ILT_LINES;
+	bnx2x_ilt_wr(bp, i, bp->timers_mapping);
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, PXP2_REG_RQ_TM_FIRST_ILT, i);
+		REG_WR(bp, PXP2_REG_RQ_TM_LAST_ILT, i);
+	} else /* E1 */
+		REG_WR(bp, PXP2_REG_PSWRQ_TM0_L2P + func*4, PXP_ONE_ILT(i));
+
+	i++;
+	bnx2x_ilt_wr(bp, i, bp->qm_mapping);
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, PXP2_REG_RQ_QM_FIRST_ILT, i);
+		REG_WR(bp, PXP2_REG_RQ_QM_LAST_ILT, i);
+	} else /* E1 */
+		REG_WR(bp, PXP2_REG_PSWRQ_QM0_L2P + func*4, PXP_ONE_ILT(i));
+
+	i++;
+	bnx2x_ilt_wr(bp, i, bp->t1_mapping);
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, PXP2_REG_RQ_SRC_FIRST_ILT, i);
+		REG_WR(bp, PXP2_REG_RQ_SRC_LAST_ILT, i);
+	} else /* E1 */
+		REG_WR(bp, PXP2_REG_PSWRQ_SRC0_L2P + func*4, PXP_ONE_ILT(i));
+
+	/* tell the searcher where the T2 table is */
+	REG_WR(bp, SRC_REG_COUNTFREE0 + func*4, 16*1024/64);
+
+	bnx2x_wb_wr(bp, SRC_REG_FIRSTFREE0 + func*4,
+		    U64_HI(bp->t2_mapping), U64_LO(bp->t2_mapping));
+
+	bnx2x_wb_wr(bp, SRC_REG_LASTFREE0 + func*4,
+		    U64_HI((u64)bp->t2_mapping + 16*1024 - 64),
+		    U64_LO((u64)bp->t2_mapping + 16*1024 - 64));
+
+	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + func*4, 10);
+#endif
=20
 	if (CHIP_IS_E1H(bp)) {
 		for (i =3D 0; i < 9; i++)
@@ -5492,6 +5538,9 @@ static int bnx2x_init_hw(struct bnx2x *bp, u32 lo=
ad_code)
 	bnx2x_zero_def_sb(bp);
 	for_each_queue(bp, i)
 		bnx2x_zero_sb(bp, BP_L_ID(bp) + i);
+#ifdef BCM_CNIC
+	bnx2x_zero_sb(bp, BP_L_ID(bp) + i);
+#endif
=20
 init_hw_err:
 	bnx2x_gunzip_end(bp);
@@ -5593,11 +5642,13 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
 		       sizeof(struct bnx2x_slowpath));
=20
-#ifdef BCM_ISCSI
+#ifdef BCM_CNIC
 	BNX2X_PCI_FREE(bp->t1, bp->t1_mapping, 64*1024);
 	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, 16*1024);
 	BNX2X_PCI_FREE(bp->timers, bp->timers_mapping, 8*1024);
 	BNX2X_PCI_FREE(bp->qm, bp->qm_mapping, 128*1024);
+	BNX2X_PCI_FREE(bp->cnic_sb, bp->cnic_sb_mapping,
+		       sizeof(struct host_status_block));
 #endif
 	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, PAGE_SIZE);
=20
@@ -5677,7 +5728,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
 			sizeof(struct bnx2x_slowpath));
=20
-#ifdef BCM_ISCSI
+#ifdef BCM_CNIC
 	BNX2X_PCI_ALLOC(bp->t1, &bp->t1_mapping, 64*1024);
=20
 	/* Initialize T1 */
@@ -5691,18 +5742,21 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	  (which is not entered into the ILT) */
 	BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, 16*1024);
=20
-	/* Initialize T2 */
+	/* Initialize T2 (for 1024 connections) */
 	for (i =3D 0; i < 16*1024; i +=3D 64)
-		* (u64 *)((char *)bp->t2 + i + 56) =3D bp->t2_mapping + i + 64;
+		*(u64 *)((char *)bp->t2 + i + 56) =3D bp->t2_mapping + i + 64;
=20
 	/* now fixup the last line in the block to point to the next block */
-	*(u64 *)((char *)bp->t2 + 1024*16-8) =3D bp->t2_mapping;
+	*(u64 *)((char *)bp->t2 + 1024*16 - 8) =3D bp->t2_mapping;
=20
-	/* Timer block array (MAX_CONN*8) phys uncached for now 1024 conns */
+	/* Timer block array (8*MAX_CONN) phys uncached for now 1024 conns */
 	BNX2X_PCI_ALLOC(bp->timers, &bp->timers_mapping, 8*1024);
=20
 	/* QM queues (128*MAX_CONN) */
 	BNX2X_PCI_ALLOC(bp->qm, &bp->qm_mapping, 128*1024);
+
+	BNX2X_PCI_ALLOC(bp->cnic_sb, &bp->cnic_sb_mapping,
+			sizeof(struct host_status_block));
 #endif
=20
 	/* Slow path ring */
@@ -5778,6 +5832,9 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp=
)
 	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
 	   bp->msix_table[0].vector);
=20
+#ifdef BCM_CNIC
+	offset++;
+#endif
 	for_each_queue(bp, i) {
 		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
 		   "state %x\n", i, bp->msix_table[i + offset].vector,
@@ -5810,6 +5867,11 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 	offset =3D 1;
 	DP(NETIF_MSG_IFUP, "msix_table[0].entry =3D 0 (slowpath)\n");
=20
+#ifdef BCM_CNIC
+	bp->msix_table[1].entry =3D 1;
+	DP(NETIF_MSG_IFUP, "msix_table[1].entry =3D 1 (CNIC)\n");
+	offset++;
+#endif
 	for_each_queue(bp, i) {
 		int igu_vec =3D offset + i + BP_L_ID(bp);
=20
@@ -5840,6 +5902,10 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 		return -EBUSY;
 	}
=20
+#ifdef BCM_CNIC
+	/* leave FP 1 for CNIC */
+	offset++;
+#endif
 	for_each_queue(bp, i) {
 		rc =3D request_irq(bp->msix_table[i + offset].vector,
 				 bnx2x_msix_fp_int, 0,
@@ -6029,6 +6095,29 @@ static int bnx2x_setup_multi(struct bnx2x *bp, i=
nt index)
 				 &(bp->fp[index].state), 0);
 }
=20
+#ifdef BCM_CNIC
+static void bnx2x_cnic_start(struct bnx2x *bp)
+{
+	struct cnic_ops *c_ops;
+
+	rcu_read_lock();
+	c_ops =3D rcu_dereference(bp->cnic_ops);
+	if (c_ops)
+		c_ops->cnic_start(bp->cnic_data);
+	rcu_read_unlock();
+}
+
+static void bnx2x_cnic_stop(struct bnx2x *bp)
+{
+	struct cnic_ops *c_ops;
+
+	rcu_read_lock();
+	c_ops =3D rcu_dereference(bp->cnic_ops);
+	if (c_ops)
+		c_ops->cnic_stop(bp->cnic_data);
+	rcu_read_unlock();
+}
+#endif
=20
 static int bnx2x_poll(struct napi_struct *napi, int budget);
 static void bnx2x_set_rx_mode(struct net_device *dev);
@@ -6233,6 +6322,10 @@ static int bnx2x_nic_load(struct bnx2x *bp, int =
load_mode)
 	/* start the timer */
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
=20
+#ifdef BCM_CNIC
+	if (bp->state =3D=3D BNX2X_STATE_OPEN)
+		bnx2x_cnic_start(bp);
+#endif
=20
 	return 0;
=20
@@ -6404,6 +6497,10 @@ static int bnx2x_nic_unload(struct bnx2x *bp, in=
t unload_mode)
 	u32 reset_code =3D 0;
 	int i, cnt;
=20
+#ifdef BCM_CNIC
+	bnx2x_cnic_stop(bp);
+#endif
+
 	bp->state =3D BNX2X_STATE_CLOSING_WAIT4_HALT;
=20
 	bp->rx_mode =3D BNX2X_RX_MODE_NONE;
@@ -10094,3 +10191,111 @@ static void __exit bnx2x_cleanup(void)
 module_init(bnx2x_init);
 module_exit(bnx2x_cleanup);
=20
+#ifdef BCM_CNIC
+static int bnx2x_cnic_ilt_wr(struct net_device *dev, u32 index,
+			     dma_addr_t addr)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+
+	bnx2x_ilt_wr(bp, index, addr);
+
+	return 0;
+}
+
+static int bnx2x_cnic_sp_post(struct net_device *dev,
+			      struct kwqe_16 *kwqes[], u32 count)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+	int i, func =3D BP_FUNC(bp);
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return -EIO;
+#endif
+
+	spin_lock(&bp->spq_lock);
+
+	for (i =3D 0; i < count; i++) {
+		struct eth_spe *spe =3D (struct eth_spe *)kwqes[i];
+
+		*bp->spq_prod_bd =3D *spe;
+
+		DP(NETIF_MSG_TIMER, "L5 SPQE %x %x %x:%x @spq idx %d\n",
+		   spe->hdr.conn_and_cmd_data, spe->hdr.type,
+		   spe->data.mac_config_addr.hi,
+		   spe->data.mac_config_addr.lo,
+		   bp->spq_prod_idx);
+
+		if (bp->spq_prod_bd =3D=3D bp->spq_last_bd) {
+			bp->spq_prod_bd =3D bp->spq;
+			bp->spq_prod_idx =3D 0;
+			DP(NETIF_MSG_TIMER, "end of spq\n");
+
+		} else {
+			bp->spq_prod_bd++;
+			bp->spq_prod_idx++;
+		}
+	}
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
+	       bp->spq_prod_idx);
+
+	spin_unlock(&bp->spq_lock);
+
+	return count;
+}
+
+struct cnic_eth_dev *bnx2x_register_cnic(struct net_device *dev,
+					 struct cnic_ops *ops, void *data)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+	struct cnic_eth_dev *cp =3D &bp->cnic_eth_dev;
+
+	if (ops =3D=3D NULL)
+		return NULL;
+
+	if (!try_module_get(ops->cnic_owner))
+		return NULL;
+
+	bp->cnic_data =3D data;
+	rcu_assign_pointer(bp->cnic_ops, ops);
+
+	cp->chip_id =3D CHIP_ID(bp);
+	cp->pdev =3D bp->pdev;
+	cp->io_base =3D bp->regview;
+	cp->num_irq =3D 0;
+	cp->drv_flags =3D 0;
+	if (bp->flags & USING_MSIX_FLAG)
+		cp->drv_flags =3D CNIC_DRV_FL_USING_MSIX;
+	cp->max_kwqe_pending =3D 8;
+	cp->ctx_blk_size =3D CNIC_CTX_PER_ILT * sizeof(union cdu_context);
+	cp->ctx_tbl_offset =3D FUNC_ILT_BASE(bp->func) + 1;
+	cp->ctx_tbl_len =3D CNIC_ILT_LINES;
+
+	cp->drv_ctx_tbl_wr =3D bnx2x_cnic_ilt_wr;
+	cp->drv_submit_kwqes_16 =3D bnx2x_cnic_sp_post;
+
+	bnx2x_init_sb(bp, CNIC_SB_ID, bp->cnic_sb, bp->cnic_sb_mapping);
+
+	cp->irq_arr[0].irq_flags =3D CNIC_IRQ_FL_MSIX;
+	cp->irq_arr[0].status_blk =3D bp->cnic_sb;
+	cp->irq_arr[0].status_blk_num =3D CNIC_SB_ID;
+	cp->irq_arr[0].vector =3D bp->msix_table[CNIC_SB_ID + 1].vector;
+
+	cp->num_irq =3D 1;
+	cp->starting_cid =3D 16;
+	return cp;
+}
+EXPORT_SYMBOL(bnx2x_register_cnic);
+
+int bnx2x_unregister_cnic(struct net_device *dev)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+
+	module_put(bp->cnic_ops->cnic_owner);
+	rcu_assign_pointer(bp->cnic_ops, NULL);
+	synchronize_rcu();
+	return 0;
+}
+EXPORT_SYMBOL(bnx2x_unregister_cnic);
+
+#endif /* BCM_CNIC */
--=20
1.5.5




