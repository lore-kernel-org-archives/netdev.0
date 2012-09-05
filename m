From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: [V2 PATCH 8/9] cxgb4: Chelsio FCoE offload driver submission (cxgb4 common header updates).
Date: Wed,  5 Sep 2012 18:04:01 +0530
Message-ID: <1346848442-4573-9-git-send-email-naresh@chelsio.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
Cc: netdev@vger.kernel.org, naresh@chelsio.com, chethan@chelsio.com
To: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains updates to firmware/hardware header files shared
between csiostor and cxgb4/cxgb4vf, and the resulting changes to the cxgb4
source files.

Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   10 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   16 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   69 ++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  104 +++++++++++++++++++---
 6 files changed, 170 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5ed49af..b56d96c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3102,7 +3102,7 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	memset(c, 0, sizeof(*c));
 	c->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
 			       FW_CMD_REQUEST | FW_CMD_READ);
-	c->retval_len16 = htonl(FW_LEN16(*c));
+	c->cfvalid_to_len16 = htonl(FW_LEN16(*c));
 	ret = t4_wr_mbox(adap, adap->fn, c, sizeof(*c), c);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index d49933e..121b1e9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -455,7 +455,7 @@ static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
 {
 	if (q->pend_cred >= 8) {
 		wmb();
-		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL), DBPRIO |
+		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL), DBPRIO(1) |
 			     QID(q->cntxt_id) | PIDX(q->pend_cred / 8));
 		q->pend_cred &= 7;
 	}
@@ -2020,10 +2020,10 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 			goto fl_nomem;
 
 		flsz = fl->size / 8 + STAT_LEN / sizeof(struct tx_desc);
-		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_FL0PACKEN |
+		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_FL0PACKEN(1) |
 					    FW_IQ_CMD_FL0FETCHRO(1) |
 					    FW_IQ_CMD_FL0DATARO(1) |
-					    FW_IQ_CMD_FL0PADEN);
+					    FW_IQ_CMD_FL0PADEN(1));
 		c.fl0dcaen_to_fl0cidxfthresh = htons(FW_IQ_CMD_FL0FBMIN(2) |
 				FW_IQ_CMD_FL0FBMAX(3));
 		c.fl0size = htons(flsz);
@@ -2416,10 +2416,10 @@ void t4_sge_init(struct adapter *adap)
 	unsigned int fl_align_log = ilog2(FL_ALIGN);
 
 	t4_set_reg_field(adap, SGE_CONTROL, PKTSHIFT_MASK |
-			 INGPADBOUNDARY_MASK | EGRSTATUSPAGESIZE,
+			 INGPADBOUNDARY_MASK | EGRSTATUSPAGESIZE(1),
 			 INGPADBOUNDARY(fl_align_log - 5) | PKTSHIFT(2) |
 			 RXPKTCPLMODE |
-			 (STAT_LEN == 128 ? EGRSTATUSPAGESIZE : 0));
+			 (STAT_LEN == 128 ? EGRSTATUSPAGESIZE(1) : 0));
 
 	/*
 	 * Set up to drop DOORBELL writes when the DOORBELL FIFO overflows
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index fa947df..a943faa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -456,12 +456,12 @@ static int sf1_read(struct adapter *adapter, unsigned int byte_cnt, int cont,
 
 	if (!byte_cnt || byte_cnt > 4)
 		return -EINVAL;
-	if (t4_read_reg(adapter, SF_OP) & BUSY)
+	if (t4_read_reg(adapter, SF_OP) & SF_BUSY)
 		return -EBUSY;
 	cont = cont ? SF_CONT : 0;
 	lock = lock ? SF_LOCK : 0;
 	t4_write_reg(adapter, SF_OP, lock | cont | BYTECNT(byte_cnt - 1));
-	ret = t4_wait_op_done(adapter, SF_OP, BUSY, 0, SF_ATTEMPTS, 5);
+	ret = t4_wait_op_done(adapter, SF_OP, SF_BUSY, 0, SF_ATTEMPTS, 5);
 	if (!ret)
 		*valp = t4_read_reg(adapter, SF_DATA);
 	return ret;
@@ -484,14 +484,14 @@ static int sf1_write(struct adapter *adapter, unsigned int byte_cnt, int cont,
 {
 	if (!byte_cnt || byte_cnt > 4)
 		return -EINVAL;
-	if (t4_read_reg(adapter, SF_OP) & BUSY)
+	if (t4_read_reg(adapter, SF_OP) & SF_BUSY)
 		return -EBUSY;
 	cont = cont ? SF_CONT : 0;
 	lock = lock ? SF_LOCK : 0;
 	t4_write_reg(adapter, SF_DATA, val);
 	t4_write_reg(adapter, SF_OP, lock |
 		     cont | BYTECNT(byte_cnt - 1) | OP_WR);
-	return t4_wait_op_done(adapter, SF_OP, BUSY, 0, SF_ATTEMPTS, 5);
+	return t4_wait_op_done(adapter, SF_OP, SF_BUSY, 0, SF_ATTEMPTS, 5);
 }
 
 /**
@@ -1972,14 +1972,14 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 		t4_write_reg(adap, EPIO_REG(DATA0), mask0);
 		t4_write_reg(adap, EPIO_REG(OP), ADDRESS(i) | EPIOWR);
 		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
-		if (t4_read_reg(adap, EPIO_REG(OP)) & BUSY)
+		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY)
 			return -ETIMEDOUT;
 
 		/* write CRC */
 		t4_write_reg(adap, EPIO_REG(DATA0), crc);
 		t4_write_reg(adap, EPIO_REG(OP), ADDRESS(i + 32) | EPIOWR);
 		t4_read_reg(adap, EPIO_REG(OP));                /* flush */
-		if (t4_read_reg(adap, EPIO_REG(OP)) & BUSY)
+		if (t4_read_reg(adap, EPIO_REG(OP)) & SF_BUSY)
 			return -ETIMEDOUT;
 	}
 #undef EPIO_REG
@@ -2118,7 +2118,7 @@ int t4_fw_hello(struct adapter *adap, unsigned int mbox, unsigned int evt_mbox,
 	struct fw_hello_cmd c;
 
 	INIT_CMD(c, HELLO, WRITE);
-	c.err_to_mbasyncnot = htonl(
+	c.err_to_clearinit = htonl(
 		FW_HELLO_CMD_MASTERDIS(master == MASTER_CANT) |
 		FW_HELLO_CMD_MASTERFORCE(master == MASTER_MUST) |
 		FW_HELLO_CMD_MBMASTER(master == MASTER_MUST ? mbox : 0xff) |
@@ -2126,7 +2126,7 @@ int t4_fw_hello(struct adapter *adap, unsigned int mbox, unsigned int evt_mbox,
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 	if (ret == 0 && state) {
-		u32 v = ntohl(c.err_to_mbasyncnot);
+		u32 v = ntohl(c.err_to_clearinit);
 		if (v & FW_HELLO_CMD_INIT)
 			*state = DEV_STATE_INIT;
 		else if (v & FW_HELLO_CMD_ERR)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index eb71b82..b760808 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -658,6 +658,7 @@ struct ulptx_sgl {
 	__be32 cmd_nsge;
 #define ULPTX_CMD(x) ((x) << 24)
 #define ULPTX_NSGE(x) ((x) << 0)
+#define ULPTX_MORE (1U << 23)
 	__be32 len0;
 	__be64 addr0;
 	struct ulptx_sge_pair sge[0];
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 111fc32..6bace75 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -67,7 +67,7 @@
 #define  QID_MASK    0xffff8000U
 #define  QID_SHIFT   15
 #define  QID(x)      ((x) << QID_SHIFT)
-#define  DBPRIO      0x00004000U
+#define  DBPRIO(x)   ((x) << 14)
 #define  PIDX_MASK   0x00003fffU
 #define  PIDX_SHIFT  0
 #define  PIDX(x)     ((x) << PIDX_SHIFT)
@@ -89,7 +89,7 @@
 #define SGE_CONTROL 0x1008
 #define  DCASYSTYPE             0x00080000U
 #define  RXPKTCPLMODE           0x00040000U
-#define  EGRSTATUSPAGESIZE      0x00020000U
+#define  EGRSTATUSPAGESIZE(x)   ((x) << 17)
 #define  PKTSHIFT_MASK          0x00001c00U
 #define  PKTSHIFT_SHIFT         10
 #define  PKTSHIFT(x)            ((x) << PKTSHIFT_SHIFT)
@@ -111,6 +111,13 @@
 #define  HOSTPAGESIZEPF0_MASK   0x0000000fU
 #define  HOSTPAGESIZEPF0_SHIFT  0
 #define  HOSTPAGESIZEPF0(x)     ((x) << HOSTPAGESIZEPF0_SHIFT)
+#define  HOSTPAGESIZEPF1(x)     ((x) << 4)
+#define  HOSTPAGESIZEPF2(x)     ((x) << 8)
+#define  HOSTPAGESIZEPF3(x)     ((x) << 12)
+#define  HOSTPAGESIZEPF4(x)     ((x) << 16)
+#define  HOSTPAGESIZEPF5(x)     ((x) << 20)
+#define  HOSTPAGESIZEPF6(x)     ((x) << 24)
+#define  HOSTPAGESIZEPF7(x)     ((x) << 28)
 
 #define SGE_EGRESS_QUEUES_PER_PAGE_PF 0x1010
 #define  QUEUESPERPAGEPF0_MASK   0x0000000fU
@@ -155,6 +162,14 @@
 #define SGE_INT_ENABLE3 0x1040
 #define SGE_FL_BUFFER_SIZE0 0x1044
 #define SGE_FL_BUFFER_SIZE1 0x1048
+#define SGE_FL_BUFFER_SIZE2 0x104c
+#define SGE_FL_BUFFER_SIZE3 0x1050
+#define SGE_FL_BUFFER_SIZE4 0x1054
+#define SGE_FL_BUFFER_SIZE5 0x1058
+#define SGE_FL_BUFFER_SIZE6 0x105c
+#define SGE_FL_BUFFER_SIZE7 0x1060
+#define SGE_FL_BUFFER_SIZE8 0x1064
+
 #define SGE_INGRESS_RX_THRESHOLD 0x10a0
 #define  THRESHOLD_0_MASK   0x3f000000U
 #define  THRESHOLD_0_SHIFT  24
@@ -173,6 +188,17 @@
 #define  THRESHOLD_3(x)     ((x) << THRESHOLD_3_SHIFT)
 #define  THRESHOLD_3_GET(x) (((x) & THRESHOLD_3_MASK) >> THRESHOLD_3_SHIFT)
 
+#define SGE_DBFIFO_STATUS 0x10a4
+#define  HP_INT_THRESH_SHIFT 28
+#define  HP_INT_THRESH_MASK  0xfU
+#define  HP_INT_THRESH(x)    ((x) << HP_INT_THRESH_SHIFT)
+#define  LP_INT_THRESH_SHIFT 12
+#define  LP_INT_THRESH_MASK  0xfU
+#define  LP_INT_THRESH(x)    ((x) << LP_INT_THRESH_SHIFT)
+
+#define SGE_DOORBELL_CONTROL 0x10a8
+#define  ENABLE_DROP        (1 << 13)
+
 #define SGE_TIMER_VALUE_0_AND_1 0x10b8
 #define  TIMERVALUE0_MASK   0xffff0000U
 #define  TIMERVALUE0_SHIFT  16
@@ -184,7 +210,25 @@
 #define  TIMERVALUE1_GET(x) (((x) & TIMERVALUE1_MASK) >> TIMERVALUE1_SHIFT)
 
 #define SGE_TIMER_VALUE_2_AND_3 0x10bc
+#define  TIMERVALUE2_MASK   0xffff0000U
+#define  TIMERVALUE2_SHIFT  16
+#define  TIMERVALUE2(x)     ((x) << TIMERVALUE0_SHIFT)
+#define  TIMERVALUE2_GET(x) (((x) & TIMERVALUE0_MASK) >> TIMERVALUE0_SHIFT)
+#define  TIMERVALUE3_MASK   0x0000ffffU
+#define  TIMERVALUE3_SHIFT  0
+#define  TIMERVALUE3(x)     ((x) << TIMERVALUE1_SHIFT)
+#define  TIMERVALUE3_GET(x) (((x) & TIMERVALUE1_MASK) >> TIMERVALUE1_SHIFT)
+
 #define SGE_TIMER_VALUE_4_AND_5 0x10c0
+#define  TIMERVALUE4_MASK   0xffff0000U
+#define  TIMERVALUE4_SHIFT  16
+#define  TIMERVALUE4(x)     ((x) << TIMERVALUE0_SHIFT)
+#define  TIMERVALUE4_GET(x) (((x) & TIMERVALUE0_MASK) >> TIMERVALUE0_SHIFT)
+#define  TIMERVALUE5_MASK   0x0000ffffU
+#define  TIMERVALUE5_SHIFT  0
+#define  TIMERVALUE5(x)     ((x) << TIMERVALUE1_SHIFT)
+#define  TIMERVALUE5_GET(x) (((x) & TIMERVALUE1_MASK) >> TIMERVALUE1_SHIFT)
+
 #define SGE_DEBUG_INDEX 0x10cc
 #define SGE_DEBUG_DATA_HIGH 0x10d0
 #define SGE_DEBUG_DATA_LOW 0x10d4
@@ -243,6 +287,10 @@
 #define M_HP_INT_THRESH 0xfU
 #define M_LP_INT_THRESH 0xfU
 
+#define PCIE_PF_CFG 0x40
+#define  AIVEC(x)	((x) << 4)
+#define  AIVEC_MASK	0x3ffU
+
 #define PCIE_PF_CLI 0x44
 #define PCIE_INT_CAUSE 0x3004
 #define  UNXSPLCPLERR  0x20000000U
@@ -287,6 +335,15 @@
 #define  WINDOW(x)       ((x) << WINDOW_SHIFT)
 #define PCIE_MEM_ACCESS_OFFSET 0x306c
 
+#define PCIE_FW 0x30b8
+#define  PCIE_FW_ERR		0x80000000U
+#define  PCIE_FW_INIT		0x40000000U
+#define  PCIE_FW_HALT		0x20000000U
+#define  PCIE_FW_MASTER_VLD	0x00008000U
+#define  PCIE_FW_MASTER(x)	((x) << 12)
+#define  PCIE_FW_MASTER_MASK	0x7
+#define  PCIE_FW_MASTER_GET(x)	(((x) >> 12) & PCIE_FW_MASTER_MASK)
+
 #define PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS 0x5908
 #define  RNPP 0x80000000U
 #define  RPCP 0x20000000U
@@ -384,6 +441,8 @@
 #define EDC_1_BASE_ADDR 0x7980
 
 #define CIM_BOOT_CFG 0x7b00
+#define  UPCRST		0x00000001U
+
 #define  BOOTADDR_MASK 0xffffff00U
 
 #define CIM_PF_MAILBOX_DATA 0x240
@@ -395,6 +454,9 @@
 #define  MBOWNER(x)     ((x) << MBOWNER_SHIFT)
 #define  MBOWNER_GET(x) (((x) & MBOWNER_MASK) >> MBOWNER_SHIFT)
 
+#define CIM_PF_HOST_INT_ENABLE 0x288
+#define  MBMSGRDYINTEN(x) ((x) << 19)
+
 #define CIM_PF_HOST_INT_CAUSE 0x28c
 #define  MBMSGRDYINT 0x00080000U
 
@@ -825,7 +887,7 @@
 
 #define SF_DATA 0x193f8
 #define SF_OP 0x193fc
-#define  BUSY          0x80000000U
+#define  SF_BUSY       0x80000000U
 #define  SF_LOCK       0x00000010U
 #define  SF_CONT       0x00000008U
 #define  BYTECNT_MASK  0x00000006U
@@ -884,6 +946,7 @@
 #define  I2CM       0x00000002U
 #define  CIM        0x00000001U
 
+#define PL_INT_ENABLE 0x19410
 #define PL_INT_MAP0 0x19414
 #define PL_RST 0x19428
 #define  PIORST     0x00000002U
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index ad53f79..034ca39 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -68,6 +68,7 @@ struct fw_wr_hdr {
 };
 
 #define FW_WR_OP(x)	 ((x) << 24)
+#define FW_WR_OP_GET(x)	 (((x) >> 24) & 0xff)
 #define FW_WR_ATOMIC(x)	 ((x) << 23)
 #define FW_WR_FLUSH(x)   ((x) << 22)
 #define FW_WR_COMPL(x)   ((x) << 21)
@@ -155,6 +156,9 @@ struct fw_eth_tx_pkt_vm_wr {
 
 #define FW_CMD_MAX_TIMEOUT 3000
 
+#define FW_CMD_HELLO_TIMEOUT (3 * FW_CMD_MAX_TIMEOUT)
+#define FW_CMD_HELLO_RETRIES 3
+
 enum fw_cmd_opcodes {
 	FW_LDST_CMD                    = 0x01,
 	FW_RESET_CMD                   = 0x03,
@@ -209,6 +213,7 @@ struct fw_cmd_hdr {
 #define FW_CMD_OP(x)		((x) << 24)
 #define FW_CMD_OP_GET(x)        (((x) >> 24) & 0xff)
 #define FW_CMD_REQUEST          (1U << 23)
+#define FW_CMD_REQUEST_GET(x)   (((x) >> 23) & 0x1)
 #define FW_CMD_READ		(1U << 22)
 #define FW_CMD_WRITE		(1U << 21)
 #define FW_CMD_EXEC		(1U << 20)
@@ -216,6 +221,7 @@ struct fw_cmd_hdr {
 #define FW_CMD_RETVAL(x)	((x) << 8)
 #define FW_CMD_RETVAL_GET(x)	(((x) >> 8) & 0xff)
 #define FW_CMD_LEN16(x)         ((x) << 0)
+#define FW_LEN16(fw_struct)	FW_CMD_LEN16(sizeof(fw_struct) / 16)
 
 enum fw_ldst_addrspc {
 	FW_LDST_ADDRSPC_FIRMWARE  = 0x0001,
@@ -228,7 +234,8 @@ enum fw_ldst_addrspc {
 	FW_LDST_ADDRSPC_TP_MIB    = 0x0012,
 	FW_LDST_ADDRSPC_MDIO      = 0x0018,
 	FW_LDST_ADDRSPC_MPS       = 0x0020,
-	FW_LDST_ADDRSPC_FUNC      = 0x0028
+	FW_LDST_ADDRSPC_FUNC      = 0x0028,
+	FW_LDST_ADDRSPC_FUNC_PCIE = 0x0029,
 };
 
 enum fw_ldst_mps_fid {
@@ -290,6 +297,16 @@ struct fw_ldst_cmd {
 			__be64 data0;
 			__be64 data1;
 		} func;
+		struct fw_ldst_pcie {
+			u8 ctrl_to_fn;
+			u8 bnum;
+			u8 r;
+			u8 ext_r;
+			u8 select_naccess;
+			u8 pcie_fn;
+			__be16 nset_pkd;
+			__be32 data[12];
+		} pcie;
 	} u;
 };
 
@@ -299,24 +316,42 @@ struct fw_ldst_cmd {
 #define FW_LDST_CMD_FID(x)	((x) << 15)
 #define FW_LDST_CMD_CTL(x)	((x) << 0)
 #define FW_LDST_CMD_RPLCPF(x)	((x) << 0)
+#define FW_LDST_CMD_LC		(1U << 4)
+#define FW_LDST_CMD_NACCESS(x)	((x) << 0)
+#define FW_LDST_CMD_FN(x)	((x) << 0)
 
 struct fw_reset_cmd {
 	__be32 op_to_write;
 	__be32 retval_len16;
 	__be32 val;
-	__be32 r3;
+	__be32 halt_pkd;
+};
+
+#define FW_RESET_CMD_HALT	(1U << 31)
+
+enum {
+	FW_HELLO_CMD_STAGE_OS		= 0,
+	FW_HELLO_CMD_STAGE_PREOS0	= 1,
+	FW_HELLO_CMD_STAGE_PREOS1	= 2,
+	FW_HELLO_CMD_STAGE_POSTOS	= 3,
 };
 
 struct fw_hello_cmd {
 	__be32 op_to_write;
 	__be32 retval_len16;
-	__be32 err_to_mbasyncnot;
-#define FW_HELLO_CMD_ERR	    (1U << 31)
-#define FW_HELLO_CMD_INIT	    (1U << 30)
-#define FW_HELLO_CMD_MASTERDIS(x)   ((x) << 29)
-#define FW_HELLO_CMD_MASTERFORCE(x) ((x) << 28)
-#define FW_HELLO_CMD_MBMASTER(x)    ((x) << 24)
-#define FW_HELLO_CMD_MBASYNCNOT(x)  ((x) << 20)
+	__be32 err_to_clearinit;
+#define FW_HELLO_CMD_ERR	        (1U << 31)
+#define FW_HELLO_CMD_INIT	        (1U << 30)
+#define FW_HELLO_CMD_MASTERDIS(x)	((x) << 29)
+#define FW_HELLO_CMD_MASTERFORCE(x)	((x) << 28)
+#define FW_HELLO_CMD_MBMASTER_MASK	0xf
+#define FW_HELLO_CMD_MBMASTER(x)	((x) << 24)
+#define FW_HELLO_CMD_MBMASTER_GET(x)	\
+		(((x) >> 24) & FW_HELLO_CMD_MBMASTER_MASK)
+#define FW_HELLO_CMD_MBASYNCNOTINT(x)	((x) << 23)
+#define FW_HELLO_CMD_MBASYNCNOT(x)	((x) << 20)
+#define FW_HELLO_CMD_STAGE(x)		((x) << 17)
+#define FW_HELLO_CMD_CLEARINIT		(1U << 16)
 	__be32 fwrev;
 };
 
@@ -399,11 +434,20 @@ enum fw_caps_config_iscsi {
 enum fw_caps_config_fcoe {
 	FW_CAPS_CONFIG_FCOE_INITIATOR	= 0x00000001,
 	FW_CAPS_CONFIG_FCOE_TARGET	= 0x00000002,
+	FW_CAPS_CONFIG_FCOE_CTRL_OFLD	= 0x00000004,
+};
+
+enum fw_memtype_cf {
+	FW_MEMTYPE_CF_EDC0		= 0x0,
+	FW_MEMTYPE_CF_EDC1		= 0x1,
+	FW_MEMTYPE_CF_EXTMEM		= 0x2,
+	FW_MEMTYPE_CF_FLASH		= 0x4,
+	FW_MEMTYPE_CF_INTERNAL		= 0x5,
 };
 
 struct fw_caps_config_cmd {
 	__be32 op_to_write;
-	__be32 retval_len16;
+	__be32 cfvalid_to_len16;
 	__be32 r2;
 	__be32 hwmbitmap;
 	__be16 nbmcaps;
@@ -416,10 +460,15 @@ struct fw_caps_config_cmd {
 	__be16 r4;
 	__be16 iscsicaps;
 	__be16 fcoecaps;
-	__be32 r5;
-	__be64 r6;
+	__be32 cfcsum;
+	__be32 finiver;
+	__be32 finicsum;
 };
 
+#define FW_CAPS_CONFIG_CMD_CFVALID (1U << 27)
+#define FW_CAPS_CONFIG_CMD_MEMTYPE_CF(x) ((x) << 24)
+#define FW_CAPS_CONFIG_CMD_MEMADDR64K_CF(x) ((x) << 16)
+
 /*
  * params command mnemonics
  */
@@ -451,6 +500,7 @@ enum fw_params_param_dev {
 	FW_PARAMS_PARAM_DEV_INTVER_FCOE = 0x0A,
 	FW_PARAMS_PARAM_DEV_FWREV = 0x0B,
 	FW_PARAMS_PARAM_DEV_TPREV = 0x0C,
+	FW_PARAMS_PARAM_DEV_CF = 0x0D,
 };
 
 /*
@@ -511,6 +561,9 @@ enum fw_params_param_dmaq {
 #define FW_PARAMS_PARAM_Z(x)   ((x) << 0)
 #define FW_PARAMS_PARAM_XYZ(x) ((x) << 0)
 #define FW_PARAMS_PARAM_YZ(x)  ((x) << 0)
+#define FW_PARAMS_PARAM_X_GET(x) (((x) >> 16) & 0xff)
+#define FW_PARAMS_PARAM_Y_GET(x) (((x) >> 8) & 0xff)
+#define FW_PARAMS_PARAM_Z_GET(x) (((x) >> 0) & 0xff)
 
 struct fw_params_cmd {
 	__be32 op_to_vfn;
@@ -648,8 +701,8 @@ struct fw_iq_cmd {
 #define FW_IQ_CMD_FL0FETCHRO(x) ((x) << 6)
 #define FW_IQ_CMD_FL0HOSTFCMODE(x) ((x) << 4)
 #define FW_IQ_CMD_FL0CPRIO(x) ((x) << 3)
-#define FW_IQ_CMD_FL0PADEN (1U << 2)
-#define FW_IQ_CMD_FL0PACKEN (1U << 1)
+#define FW_IQ_CMD_FL0PADEN(x) ((x) << 2)
+#define FW_IQ_CMD_FL0PACKEN(x) ((x) << 1)
 #define FW_IQ_CMD_FL0CONGEN (1U << 0)
 
 #define FW_IQ_CMD_FL0DCAEN(x) ((x) << 15)
@@ -1137,6 +1190,14 @@ enum fw_port_dcb_cfg_rc {
 	FW_PORT_DCB_CFG_ERROR	= 0x1
 };
 
+enum fw_port_dcb_type {
+	FW_PORT_DCB_TYPE_PGID		= 0x00,
+	FW_PORT_DCB_TYPE_PGRATE		= 0x01,
+	FW_PORT_DCB_TYPE_PRIORATE	= 0x02,
+	FW_PORT_DCB_TYPE_PFC		= 0x03,
+	FW_PORT_DCB_TYPE_APP_ID		= 0x04,
+};
+
 struct fw_port_cmd {
 	__be32 op_to_portid;
 	__be32 action_to_len16;
@@ -1204,6 +1265,7 @@ struct fw_port_cmd {
 #define FW_PORT_CMD_TXIPG(x) ((x) << 19)
 
 #define FW_PORT_CMD_LSTATUS (1U << 31)
+#define FW_PORT_CMD_LSTATUS_GET(x) (((x) >> 31) & 0x1)
 #define FW_PORT_CMD_LSPEED(x) ((x) << 24)
 #define FW_PORT_CMD_LSPEED_GET(x) (((x) >> 24) & 0x3f)
 #define FW_PORT_CMD_TXPAUSE (1U << 23)
@@ -1252,6 +1314,9 @@ enum fw_port_module_type {
 	FW_PORT_MOD_TYPE_TWINAX_PASSIVE,
 	FW_PORT_MOD_TYPE_TWINAX_ACTIVE,
 	FW_PORT_MOD_TYPE_LRM,
+	FW_PORT_MOD_TYPE_ERROR		= FW_PORT_CMD_MODTYPE_MASK - 3,
+	FW_PORT_MOD_TYPE_UNKNOWN	= FW_PORT_CMD_MODTYPE_MASK - 2,
+	FW_PORT_MOD_TYPE_NOTSUPPORTED	= FW_PORT_CMD_MODTYPE_MASK - 1,
 
 	FW_PORT_MOD_TYPE_NONE = FW_PORT_CMD_MODTYPE_MASK
 };
@@ -1613,7 +1678,11 @@ struct fw_hdr {
 	u8 intfver_iscsi;
 	u8 intfver_fcoe;
 	u8 reserved2;
-	__be32  reserved3[27];
+	__u32   reserved3;
+	__u32   reserved4;
+	__u32   reserved5;
+	__be32  flags;
+	__be32  reserved6[23];
 };
 
 #define FW_HDR_FW_VER_MAJOR_GET(x) (((x) >> 24) & 0xff)
@@ -1621,6 +1690,11 @@ struct fw_hdr {
 #define FW_HDR_FW_VER_MICRO_GET(x) (((x) >> 8) & 0xff)
 #define FW_HDR_FW_VER_BUILD_GET(x) (((x) >> 0) & 0xff)
 
+enum fw_hdr_flags {
+	FW_HDR_FLAGS_RESET_HALT	= 0x00000001,
+};
+
+
 #define S_FW_CMD_OP 24
 #define V_FW_CMD_OP(x) ((x) << S_FW_CMD_OP)
 
-- 
1.7.1

