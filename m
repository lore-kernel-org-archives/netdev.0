From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/2] cxgb3 - Parity initialization for T3C adapters
Date: Wed, 05 Dec 2007 10:15:27 -0800
Message-ID: <20071205181527.22106.73134.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:16432 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbXLESPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 13:15:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Add parity initialization for T3C adapters.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h       |    1 
 drivers/net/cxgb3/cxgb3_main.c    |   82 ++++++++++++
 drivers/net/cxgb3/cxgb3_offload.c |   15 ++
 drivers/net/cxgb3/regs.h          |  248 +++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb3/sge.c           |   24 +++-
 drivers/net/cxgb3/t3_hw.c         |  131 +++++++++++++++++---
 6 files changed, 472 insertions(+), 29 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 60a62f5..eb305a0 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -71,6 +71,7 @@ enum {				/* adapter flags */
 	USING_MSI = (1 << 1),
 	USING_MSIX = (1 << 2),
 	QUEUES_BOUND = (1 << 3),
+	TP_PARITY_INIT = (1 << 4),
 };
 
 struct fl_pg_chunk {
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 944423c..d1aa777 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -306,6 +306,77 @@ static int request_msix_data_irqs(struct adapter *adap)
 	return 0;
 }
 
+static int await_mgmt_replies(struct adapter *adap, unsigned long init_cnt,
+			      unsigned long n)
+{
+	int attempts = 5;
+
+	while (adap->sge.qs[0].rspq.offload_pkts < init_cnt + n) {
+		if (!--attempts)
+			return -ETIMEDOUT;
+		msleep(10);
+	}
+	return 0;
+}
+
+static int init_tp_parity(struct adapter *adap)
+{
+	int i;
+	struct sk_buff *skb;
+	struct cpl_set_tcb_field *greq;
+	unsigned long cnt = adap->sge.qs[0].rspq.offload_pkts;
+
+	t3_tp_set_offload_mode(adap, 1);
+
+	for (i = 0; i < 16; i++) {
+		struct cpl_smt_write_req *req;
+
+		skb = alloc_skb(sizeof(*req), GFP_KERNEL | __GFP_NOFAIL);
+		req = (struct cpl_smt_write_req *)__skb_put(skb, sizeof(*req));
+		memset(req, 0, sizeof(*req));
+		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SMT_WRITE_REQ, i));
+		req->iff = i;
+		t3_mgmt_tx(adap, skb);
+	}
+
+	for (i = 0; i < 2048; i++) {
+		struct cpl_l2t_write_req *req;
+
+		skb = alloc_skb(sizeof(*req), GFP_KERNEL | __GFP_NOFAIL);
+		req = (struct cpl_l2t_write_req *)__skb_put(skb, sizeof(*req));
+		memset(req, 0, sizeof(*req));
+		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ, i));
+		req->params = htonl(V_L2T_W_IDX(i));
+		t3_mgmt_tx(adap, skb);
+	}
+
+	for (i = 0; i < 2048; i++) {
+		struct cpl_rte_write_req *req;
+
+		skb = alloc_skb(sizeof(*req), GFP_KERNEL | __GFP_NOFAIL);
+		req = (struct cpl_rte_write_req *)__skb_put(skb, sizeof(*req));
+		memset(req, 0, sizeof(*req));
+		req->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+		OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_RTE_WRITE_REQ, i));
+		req->l2t_idx = htonl(V_L2T_W_IDX(i));
+		t3_mgmt_tx(adap, skb);
+	}
+
+	skb = alloc_skb(sizeof(*greq), GFP_KERNEL | __GFP_NOFAIL);
+	greq = (struct cpl_set_tcb_field *)__skb_put(skb, sizeof(*greq));
+	memset(greq, 0, sizeof(*greq));
+	greq->wr.wr_hi = htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+	OPCODE_TID(greq) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, 0));
+	greq->mask = cpu_to_be64(1);
+	t3_mgmt_tx(adap, skb);
+
+	i = await_mgmt_replies(adap, cnt, 16 + 2048 + 2048 + 1);
+	t3_tp_set_offload_mode(adap, 0);
+	return i;
+}
+
 /**
  *	setup_rss - configure RSS
  *	@adap: the adapter
@@ -817,6 +888,7 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto out;
 
+		t3_set_reg_field(adap, A_TP_PARA_REG5, 0, F_RXDDPOFFINIT);
 		t3_write_reg(adap, A_ULPRX_TDDP_PSZ, V_HPZ0(PAGE_SHIFT - 12));
 
 		err = setup_sge_qsets(adap);
@@ -856,6 +928,16 @@ static int cxgb_up(struct adapter *adap)
 	t3_sge_start(adap);
 	t3_intr_enable(adap);
 
+	if (adap->params.rev >= T3_REV_C && !(adap->flags & TP_PARITY_INIT) &&
+	    is_offload(adap) && init_tp_parity(adap) == 0)
+		adap->flags |= TP_PARITY_INIT;
+
+	if (adap->flags & TP_PARITY_INIT) {
+		t3_write_reg(adap, A_TP_INT_CAUSE,
+			     F_CMCACHEPERR | F_ARPLUTPERR);
+		t3_write_reg(adap, A_TP_INT_ENABLE, 0x7fbfffff);
+	}
+
 	if ((adap->flags & (USING_MSIX | QUEUES_BOUND)) == USING_MSIX)
 		bind_qsets(adap);
 	adap->flags |= QUEUES_BOUND;
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 650d06a..738de4b 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -403,8 +403,6 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
 static int rx_offload_blackhole(struct t3cdev *dev, struct sk_buff **skbs,
 				int n)
 {
-	CH_ERR(tdev2adap(dev), "%d unexpected offload packets, first data %u\n",
-	       n, ntohl(*(__be32 *)skbs[0]->data));
 	while (n--)
 		dev_kfree_skb_any(skbs[n]);
 	return 0;
@@ -634,6 +632,18 @@ static int do_l2t_write_rpl(struct t3cdev *dev, struct sk_buff *skb)
 	return CPL_RET_BUF_DONE;
 }
 
+static int do_rte_write_rpl(struct t3cdev *dev, struct sk_buff *skb)
+{
+	struct cpl_rte_write_rpl *rpl = cplhdr(skb);
+
+	if (rpl->status != CPL_ERR_NONE)
+		printk(KERN_ERR
+		       "Unexpected RTE_WRITE_RPL status %u for entry %u\n",
+		       rpl->status, GET_TID(rpl));
+
+	return CPL_RET_BUF_DONE;
+}
+
 static int do_act_open_rpl(struct t3cdev *dev, struct sk_buff *skb)
 {
 	struct cpl_act_open_rpl *rpl = cplhdr(skb);
@@ -1257,6 +1267,7 @@ void __init cxgb3_offload_init(void)
 
 	t3_register_cpl_handler(CPL_SMT_WRITE_RPL, do_smt_write_rpl);
 	t3_register_cpl_handler(CPL_L2T_WRITE_RPL, do_l2t_write_rpl);
+	t3_register_cpl_handler(CPL_RTE_WRITE_RPL, do_rte_write_rpl);
 	t3_register_cpl_handler(CPL_PASS_OPEN_RPL, do_stid_rpl);
 	t3_register_cpl_handler(CPL_CLOSE_LISTSRV_RPL, do_stid_rpl);
 	t3_register_cpl_handler(CPL_PASS_ACCEPT_REQ, do_cr);
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 70e1961..02dbbb3 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1,5 +1,17 @@
 #define A_SG_CONTROL 0x0
 
+#define S_CONGMODE    29
+#define V_CONGMODE(x) ((x) << S_CONGMODE)
+#define F_CONGMODE    V_CONGMODE(1U)
+
+#define S_TNLFLMODE    28
+#define V_TNLFLMODE(x) ((x) << S_TNLFLMODE)
+#define F_TNLFLMODE    V_TNLFLMODE(1U)
+
+#define S_FATLPERREN    27
+#define V_FATLPERREN(x) ((x) << S_FATLPERREN)
+#define F_FATLPERREN    V_FATLPERREN(1U)
+
 #define S_DROPPKT    20
 #define V_DROPPKT(x) ((x) << S_DROPPKT)
 #define F_DROPPKT    V_DROPPKT(1U)
@@ -172,6 +184,64 @@
 
 #define A_SG_INT_CAUSE 0x5c
 
+#define S_HIRCQPARITYERROR    31
+#define V_HIRCQPARITYERROR(x) ((x) << S_HIRCQPARITYERROR)
+#define F_HIRCQPARITYERROR    V_HIRCQPARITYERROR(1U)
+
+#define S_LORCQPARITYERROR    30
+#define V_LORCQPARITYERROR(x) ((x) << S_LORCQPARITYERROR)
+#define F_LORCQPARITYERROR    V_LORCQPARITYERROR(1U)
+
+#define S_HIDRBPARITYERROR    29
+#define V_HIDRBPARITYERROR(x) ((x) << S_HIDRBPARITYERROR)
+#define F_HIDRBPARITYERROR    V_HIDRBPARITYERROR(1U)
+
+#define S_LODRBPARITYERROR    28
+#define V_LODRBPARITYERROR(x) ((x) << S_LODRBPARITYERROR)
+#define F_LODRBPARITYERROR    V_LODRBPARITYERROR(1U)
+
+#define S_FLPARITYERROR    22
+#define M_FLPARITYERROR    0x3f
+#define V_FLPARITYERROR(x) ((x) << S_FLPARITYERROR)
+#define G_FLPARITYERROR(x) (((x) >> S_FLPARITYERROR) & M_FLPARITYERROR)
+
+#define S_ITPARITYERROR    20
+#define M_ITPARITYERROR    0x3
+#define V_ITPARITYERROR(x) ((x) << S_ITPARITYERROR)
+#define G_ITPARITYERROR(x) (((x) >> S_ITPARITYERROR) & M_ITPARITYERROR)
+
+#define S_IRPARITYERROR    19
+#define V_IRPARITYERROR(x) ((x) << S_IRPARITYERROR)
+#define F_IRPARITYERROR    V_IRPARITYERROR(1U)
+
+#define S_RCPARITYERROR    18
+#define V_RCPARITYERROR(x) ((x) << S_RCPARITYERROR)
+#define F_RCPARITYERROR    V_RCPARITYERROR(1U)
+
+#define S_OCPARITYERROR    17
+#define V_OCPARITYERROR(x) ((x) << S_OCPARITYERROR)
+#define F_OCPARITYERROR    V_OCPARITYERROR(1U)
+
+#define S_CPPARITYERROR    16
+#define V_CPPARITYERROR(x) ((x) << S_CPPARITYERROR)
+#define F_CPPARITYERROR    V_CPPARITYERROR(1U)
+
+#define S_R_REQ_FRAMINGERROR    15
+#define V_R_REQ_FRAMINGERROR(x) ((x) << S_R_REQ_FRAMINGERROR)
+#define F_R_REQ_FRAMINGERROR    V_R_REQ_FRAMINGERROR(1U)
+
+#define S_UC_REQ_FRAMINGERROR    14
+#define V_UC_REQ_FRAMINGERROR(x) ((x) << S_UC_REQ_FRAMINGERROR)
+#define F_UC_REQ_FRAMINGERROR    V_UC_REQ_FRAMINGERROR(1U)
+
+#define S_HICTLDRBDROPERR    13
+#define V_HICTLDRBDROPERR(x) ((x) << S_HICTLDRBDROPERR)
+#define F_HICTLDRBDROPERR    V_HICTLDRBDROPERR(1U)
+
+#define S_LOCTLDRBDROPERR    12
+#define V_LOCTLDRBDROPERR(x) ((x) << S_LOCTLDRBDROPERR)
+#define F_LOCTLDRBDROPERR    V_LOCTLDRBDROPERR(1U)
+
 #define S_HIPIODRBDROPERR    11
 #define V_HIPIODRBDROPERR(x) ((x) << S_HIPIODRBDROPERR)
 #define F_HIPIODRBDROPERR    V_HIPIODRBDROPERR(1U)
@@ -286,6 +356,10 @@
 
 #define A_PCIX_CFG 0x88
 
+#define S_DMASTOPEN    19
+#define V_DMASTOPEN(x) ((x) << S_DMASTOPEN)
+#define F_DMASTOPEN    V_DMASTOPEN(1U)
+
 #define S_CLIDECEN    18
 #define V_CLIDECEN(x) ((x) << S_CLIDECEN)
 #define F_CLIDECEN    V_CLIDECEN(1U)
@@ -313,6 +387,22 @@
 
 #define V_BISTERR(x) ((x) << S_BISTERR)
 
+#define S_TXPARERR    18
+#define V_TXPARERR(x) ((x) << S_TXPARERR)
+#define F_TXPARERR    V_TXPARERR(1U)
+
+#define S_RXPARERR    17
+#define V_RXPARERR(x) ((x) << S_RXPARERR)
+#define F_RXPARERR    V_RXPARERR(1U)
+
+#define S_RETRYLUTPARERR    16
+#define V_RETRYLUTPARERR(x) ((x) << S_RETRYLUTPARERR)
+#define F_RETRYLUTPARERR    V_RETRYLUTPARERR(1U)
+
+#define S_RETRYBUFPARERR    15
+#define V_RETRYBUFPARERR(x) ((x) << S_RETRYBUFPARERR)
+#define F_RETRYBUFPARERR    V_RETRYBUFPARERR(1U)
+
 #define S_PCIE_MSIXPARERR    12
 #define M_PCIE_MSIXPARERR    0x7
 
@@ -348,6 +438,10 @@
 
 #define A_PCIE_INT_CAUSE 0x84
 
+#define S_PCIE_DMASTOPEN    24
+#define V_PCIE_DMASTOPEN(x) ((x) << S_PCIE_DMASTOPEN)
+#define F_PCIE_DMASTOPEN    V_PCIE_DMASTOPEN(1U)
+
 #define A_PCIE_CFG 0x88
 
 #define S_PCIE_CLIDECEN    16
@@ -741,6 +835,54 @@
 
 #define A_CIM_HOST_INT_ENABLE 0x298
 
+#define S_DTAGPARERR    28
+#define V_DTAGPARERR(x) ((x) << S_DTAGPARERR)
+#define F_DTAGPARERR    V_DTAGPARERR(1U)
+
+#define S_ITAGPARERR    27
+#define V_ITAGPARERR(x) ((x) << S_ITAGPARERR)
+#define F_ITAGPARERR    V_ITAGPARERR(1U)
+
+#define S_IBQTPPARERR    26
+#define V_IBQTPPARERR(x) ((x) << S_IBQTPPARERR)
+#define F_IBQTPPARERR    V_IBQTPPARERR(1U)
+
+#define S_IBQULPPARERR    25
+#define V_IBQULPPARERR(x) ((x) << S_IBQULPPARERR)
+#define F_IBQULPPARERR    V_IBQULPPARERR(1U)
+
+#define S_IBQSGEHIPARERR    24
+#define V_IBQSGEHIPARERR(x) ((x) << S_IBQSGEHIPARERR)
+#define F_IBQSGEHIPARERR    V_IBQSGEHIPARERR(1U)
+
+#define S_IBQSGELOPARERR    23
+#define V_IBQSGELOPARERR(x) ((x) << S_IBQSGELOPARERR)
+#define F_IBQSGELOPARERR    V_IBQSGELOPARERR(1U)
+
+#define S_OBQULPLOPARERR    22
+#define V_OBQULPLOPARERR(x) ((x) << S_OBQULPLOPARERR)
+#define F_OBQULPLOPARERR    V_OBQULPLOPARERR(1U)
+
+#define S_OBQULPHIPARERR    21
+#define V_OBQULPHIPARERR(x) ((x) << S_OBQULPHIPARERR)
+#define F_OBQULPHIPARERR    V_OBQULPHIPARERR(1U)
+
+#define S_OBQSGEPARERR    20
+#define V_OBQSGEPARERR(x) ((x) << S_OBQSGEPARERR)
+#define F_OBQSGEPARERR    V_OBQSGEPARERR(1U)
+
+#define S_DCACHEPARERR    19
+#define V_DCACHEPARERR(x) ((x) << S_DCACHEPARERR)
+#define F_DCACHEPARERR    V_DCACHEPARERR(1U)
+
+#define S_ICACHEPARERR    18
+#define V_ICACHEPARERR(x) ((x) << S_ICACHEPARERR)
+#define F_ICACHEPARERR    V_ICACHEPARERR(1U)
+
+#define S_DRAMPARERR    17
+#define V_DRAMPARERR(x) ((x) << S_DRAMPARERR)
+#define F_DRAMPARERR    V_DRAMPARERR(1U)
+
 #define A_CIM_HOST_INT_CAUSE 0x29c
 
 #define S_BLKWRPLINT    12
@@ -799,8 +941,42 @@
 
 #define A_CIM_HOST_ACC_DATA 0x2b4
 
+#define A_CIM_IBQ_DBG_CFG 0x2c0
+
+#define S_IBQDBGADDR    16
+#define M_IBQDBGADDR    0x1ff
+#define V_IBQDBGADDR(x) ((x) << S_IBQDBGADDR)
+#define G_IBQDBGADDR(x) (((x) >> S_IBQDBGADDR) & M_IBQDBGADDR)
+
+#define S_IBQDBGQID    3
+#define M_IBQDBGQID    0x3
+#define V_IBQDBGQID(x) ((x) << S_IBQDBGQID)
+#define G_IBQDBGQID(x) (((x) >> S_IBQDBGQID) & M_IBQDBGQID)
+
+#define S_IBQDBGWR    2
+#define V_IBQDBGWR(x) ((x) << S_IBQDBGWR)
+#define F_IBQDBGWR    V_IBQDBGWR(1U)
+
+#define S_IBQDBGBUSY    1
+#define V_IBQDBGBUSY(x) ((x) << S_IBQDBGBUSY)
+#define F_IBQDBGBUSY    V_IBQDBGBUSY(1U)
+
+#define S_IBQDBGEN    0
+#define V_IBQDBGEN(x) ((x) << S_IBQDBGEN)
+#define F_IBQDBGEN    V_IBQDBGEN(1U)
+
+#define A_CIM_IBQ_DBG_DATA 0x2c8
+
 #define A_TP_IN_CONFIG 0x300
 
+#define S_RXFBARBPRIO    25
+#define V_RXFBARBPRIO(x) ((x) << S_RXFBARBPRIO)
+#define F_RXFBARBPRIO    V_RXFBARBPRIO(1U)
+
+#define S_TXFBARBPRIO    24
+#define V_TXFBARBPRIO(x) ((x) << S_TXFBARBPRIO)
+#define F_TXFBARBPRIO    V_TXFBARBPRIO(1U)
+
 #define S_NICMODE    14
 #define V_NICMODE(x) ((x) << S_NICMODE)
 #define F_NICMODE    V_NICMODE(1U)
@@ -973,6 +1149,22 @@
 
 #define A_TP_PC_CONFIG2 0x34c
 
+#define S_DISBLEDAPARBIT0    15
+#define V_DISBLEDAPARBIT0(x) ((x) << S_DISBLEDAPARBIT0)
+#define F_DISBLEDAPARBIT0    V_DISBLEDAPARBIT0(1U)
+
+#define S_ENABLEARPMISS    13
+#define V_ENABLEARPMISS(x) ((x) << S_ENABLEARPMISS)
+#define F_ENABLEARPMISS    V_ENABLEARPMISS(1U)
+
+#define S_ENABLENONOFDTNLSYN    12
+#define V_ENABLENONOFDTNLSYN(x) ((x) << S_ENABLENONOFDTNLSYN)
+#define F_ENABLENONOFDTNLSYN    V_ENABLENONOFDTNLSYN(1U)
+
+#define S_ENABLEIPV6RSS    11
+#define V_ENABLEIPV6RSS(x) ((x) << S_ENABLEIPV6RSS)
+#define F_ENABLEIPV6RSS    V_ENABLEIPV6RSS(1U)
+
 #define S_CHDRAFULL    4
 #define V_CHDRAFULL(x) ((x) << S_CHDRAFULL)
 #define F_CHDRAFULL    V_CHDRAFULL(1U)
@@ -1024,6 +1216,12 @@
 
 #define A_TP_PARA_REG4 0x370
 
+#define A_TP_PARA_REG5 0x374
+
+#define S_RXDDPOFFINIT    3
+#define V_RXDDPOFFINIT(x) ((x) << S_RXDDPOFFINIT)
+#define F_RXDDPOFFINIT    V_RXDDPOFFINIT(1U)
+
 #define A_TP_PARA_REG6 0x378
 
 #define S_T3A_ENABLEESND    13
@@ -1144,6 +1342,10 @@
 #define V_TNLLKPEN(x) ((x) << S_TNLLKPEN)
 #define F_TNLLKPEN    V_TNLLKPEN(1U)
 
+#define S_RRCPLMAPEN    7
+#define V_RRCPLMAPEN(x) ((x) << S_RRCPLMAPEN)
+#define F_RRCPLMAPEN    V_RRCPLMAPEN(1U)
+
 #define S_RRCPLCPUSIZE    4
 #define M_RRCPLCPUSIZE    0x7
 #define V_RRCPLCPUSIZE(x) ((x) << S_RRCPLCPUSIZE)
@@ -1216,6 +1418,14 @@
 #define V_FLMRXFLSTEMPTY(x) ((x) << S_FLMRXFLSTEMPTY)
 #define F_FLMRXFLSTEMPTY    V_FLMRXFLSTEMPTY(1U)
 
+#define S_ARPLUTPERR    26
+#define V_ARPLUTPERR(x) ((x) << S_ARPLUTPERR)
+#define F_ARPLUTPERR    V_ARPLUTPERR(1U)
+
+#define S_CMCACHEPERR    24
+#define V_CMCACHEPERR(x) ((x) << S_CMCACHEPERR)
+#define F_CMCACHEPERR    V_CMCACHEPERR(1U)
+
 #define A_TP_INT_CAUSE 0x474
 
 #define A_TP_TX_MOD_Q1_Q0_RATE_LIMIT 0x8
@@ -1259,9 +1469,37 @@
 
 #define A_ULPRX_INT_ENABLE 0x504
 
-#define S_PARERR    0
-#define V_PARERR(x) ((x) << S_PARERR)
-#define F_PARERR    V_PARERR(1U)
+#define S_DATASELFRAMEERR0    7
+#define V_DATASELFRAMEERR0(x) ((x) << S_DATASELFRAMEERR0)
+#define F_DATASELFRAMEERR0    V_DATASELFRAMEERR0(1U)
+
+#define S_DATASELFRAMEERR1    6
+#define V_DATASELFRAMEERR1(x) ((x) << S_DATASELFRAMEERR1)
+#define F_DATASELFRAMEERR1    V_DATASELFRAMEERR1(1U)
+
+#define S_PCMDMUXPERR    5
+#define V_PCMDMUXPERR(x) ((x) << S_PCMDMUXPERR)
+#define F_PCMDMUXPERR    V_PCMDMUXPERR(1U)
+
+#define S_ARBFPERR    4
+#define V_ARBFPERR(x) ((x) << S_ARBFPERR)
+#define F_ARBFPERR    V_ARBFPERR(1U)
+
+#define S_ARBPF0PERR    3
+#define V_ARBPF0PERR(x) ((x) << S_ARBPF0PERR)
+#define F_ARBPF0PERR    V_ARBPF0PERR(1U)
+
+#define S_ARBPF1PERR    2
+#define V_ARBPF1PERR(x) ((x) << S_ARBPF1PERR)
+#define F_ARBPF1PERR    V_ARBPF1PERR(1U)
+
+#define S_PARERRPCMD    1
+#define V_PARERRPCMD(x) ((x) << S_PARERRPCMD)
+#define F_PARERRPCMD    V_PARERRPCMD(1U)
+
+#define S_PARERRDATA    0
+#define V_PARERRDATA(x) ((x) << S_PARERRDATA)
+#define F_PARERRDATA    V_PARERRDATA(1U)
 
 #define A_ULPRX_INT_CAUSE 0x508
 
@@ -1559,6 +1797,10 @@
 
 #define A_CPL_INTR_ENABLE 0x650
 
+#define S_CIM_OP_MAP_PERR    5
+#define V_CIM_OP_MAP_PERR(x) ((x) << S_CIM_OP_MAP_PERR)
+#define F_CIM_OP_MAP_PERR    V_CIM_OP_MAP_PERR(1U)
+
 #define S_CIM_OVFL_ERROR    4
 #define V_CIM_OVFL_ERROR(x) ((x) << S_CIM_OVFL_ERROR)
 #define F_CIM_OVFL_ERROR    V_CIM_OVFL_ERROR(1U)
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 666c317..cef153d 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2443,6 +2443,15 @@ irq_handler_t t3_intr_handler(struct adapter *adap, int polling)
 	return t3_intr;
 }
 
+#define SGE_PARERR (F_CPPARITYERROR | F_OCPARITYERROR | F_RCPARITYERROR | \
+		    F_IRPARITYERROR | V_ITPARITYERROR(M_ITPARITYERROR) | \
+		    V_FLPARITYERROR(M_FLPARITYERROR) | F_LODRBPARITYERROR | \
+		    F_HIDRBPARITYERROR | F_LORCQPARITYERROR | \
+		    F_HIRCQPARITYERROR)
+#define SGE_FRAMINGERR (F_UC_REQ_FRAMINGERROR | F_R_REQ_FRAMINGERROR)
+#define SGE_FATALERR (SGE_PARERR | SGE_FRAMINGERR | F_RSPQCREDITOVERFOW | \
+		      F_RSPQDISABLED)
+
 /**
  *	t3_sge_err_intr_handler - SGE async event interrupt handler
  *	@adapter: the adapter
@@ -2453,6 +2462,13 @@ void t3_sge_err_intr_handler(struct adapter *adapter)
 {
 	unsigned int v, status = t3_read_reg(adapter, A_SG_INT_CAUSE);
 
+	if (status & SGE_PARERR)
+		CH_ALERT(adapter, "SGE parity error (0x%x)\n",
+			 status & SGE_PARERR);
+	if (status & SGE_FRAMINGERR)
+		CH_ALERT(adapter, "SGE framing error (0x%x)\n",
+			 status & SGE_FRAMINGERR);
+
 	if (status & F_RSPQCREDITOVERFOW)
 		CH_ALERT(adapter, "SGE response queue credit overflow\n");
 
@@ -2469,7 +2485,7 @@ void t3_sge_err_intr_handler(struct adapter *adapter)
 			 status & F_HIPIODRBDROPERR ? "high" : "lo");
 
 	t3_write_reg(adapter, A_SG_INT_CAUSE, status);
-	if (status & (F_RSPQCREDITOVERFOW | F_RSPQDISABLED))
+	if (status &  SGE_FATALERR)
 		t3_fatal_err(adapter);
 }
 
@@ -2781,7 +2797,7 @@ void t3_sge_init(struct adapter *adap, struct sge_params *p)
 	unsigned int ctrl, ups = ffs(pci_resource_len(adap->pdev, 2) >> 12);
 
 	ctrl = F_DROPPKT | V_PKTSHIFT(2) | F_FLMODE | F_AVOIDCQOVFL |
-	    F_CQCRDTCTRL |
+	    F_CQCRDTCTRL | F_CONGMODE | F_TNLFLMODE | F_FATLPERREN |
 	    V_HOSTPAGESIZE(PAGE_SHIFT - 11) | F_BIGENDIANINGRESS |
 	    V_USERSPACESIZE(ups ? ups - 1 : 0) | F_ISCSICOALESCING;
 #if SGE_NUM_GENBITS == 1
@@ -2790,7 +2806,6 @@ void t3_sge_init(struct adapter *adap, struct sge_params *p)
 	if (adap->params.rev > 0) {
 		if (!(adap->flags & (USING_MSIX | USING_MSI)))
 			ctrl |= F_ONEINTMULTQ | F_OPTONEINTMULTQ;
-		ctrl |= F_CQCRDTCTRL | F_AVOIDCQOVFL;
 	}
 	t3_write_reg(adap, A_SG_CONTROL, ctrl);
 	t3_write_reg(adap, A_SG_EGR_RCQ_DRB_THRSH, V_HIRCQDRBTHRSH(512) |
@@ -2798,7 +2813,8 @@ void t3_sge_init(struct adapter *adap, struct sge_params *p)
 	t3_write_reg(adap, A_SG_TIMER_TICK, core_ticks_per_usec(adap) / 10);
 	t3_write_reg(adap, A_SG_CMDQ_CREDIT_TH, V_THRESHOLD(32) |
 		     V_TIMEOUT(200 * core_ticks_per_usec(adap)));
-	t3_write_reg(adap, A_SG_HI_DRB_HI_THRSH, 1000);
+	t3_write_reg(adap, A_SG_HI_DRB_HI_THRSH,
+		     adap->params.rev < T3_REV_C ? 1000 : 500);
 	t3_write_reg(adap, A_SG_HI_DRB_LO_THRSH, 256);
 	t3_write_reg(adap, A_SG_LO_DRB_HI_THRSH, 1000);
 	t3_write_reg(adap, A_SG_LO_DRB_LO_THRSH, 256);
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index dfdda47..6e5b499 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -62,7 +62,7 @@ int t3_wait_op_done_val(struct adapter *adapter, int reg, u32 mask,
 			return 0;
 		}
 		if (--attempts == 0)
- 			return -EAGAIN;
+			return -EAGAIN;
 		if (delay)
 			udelay(delay);
 	}
@@ -1263,7 +1263,13 @@ static int t3_handle_intr_status(struct adapter *adapter, unsigned int reg,
 	return fatal;
 }
 
-#define SGE_INTR_MASK (F_RSPQDISABLED)
+#define SGE_INTR_MASK (F_RSPQDISABLED | \
+		       F_UC_REQ_FRAMINGERROR | F_R_REQ_FRAMINGERROR | \
+		       F_CPPARITYERROR | F_OCPARITYERROR | F_RCPARITYERROR | \
+		       F_IRPARITYERROR | V_ITPARITYERROR(M_ITPARITYERROR) | \
+		       V_FLPARITYERROR(M_FLPARITYERROR) | F_LODRBPARITYERROR | \
+		       F_HIDRBPARITYERROR | F_LORCQPARITYERROR | \
+		       F_HIRCQPARITYERROR)
 #define MC5_INTR_MASK (F_PARITYERR | F_ACTRGNFULL | F_UNKNOWNCMD | \
 		       F_REQQPARERR | F_DISPQPARERR | F_DELACTEMPTY | \
 		       F_NFASRCHFAIL)
@@ -1280,16 +1286,23 @@ static int t3_handle_intr_status(struct adapter *adapter, unsigned int reg,
 #define PCIE_INTR_MASK (F_UNXSPLCPLERRR | F_UNXSPLCPLERRC | F_PCIE_PIOPARERR |\
 			F_PCIE_WFPARERR | F_PCIE_RFPARERR | F_PCIE_CFPARERR | \
 			/* V_PCIE_MSIXPARERR(M_PCIE_MSIXPARERR) | */ \
-			V_BISTERR(M_BISTERR))
-#define ULPRX_INTR_MASK F_PARERR
-#define ULPTX_INTR_MASK 0
-#define CPLSW_INTR_MASK (F_TP_FRAMING_ERROR | \
+			F_RETRYBUFPARERR | F_RETRYLUTPARERR | F_RXPARERR | \
+			F_TXPARERR | V_BISTERR(M_BISTERR))
+#define ULPRX_INTR_MASK (F_PARERRDATA | F_PARERRPCMD | F_ARBPF1PERR | \
+			 F_ARBPF0PERR | F_ARBFPERR | F_PCMDMUXPERR | \
+			 F_DATASELFRAMEERR1 | F_DATASELFRAMEERR0)
+#define ULPTX_INTR_MASK 0xfc
+#define CPLSW_INTR_MASK (F_CIM_OP_MAP_PERR | F_TP_FRAMING_ERROR | \
 			 F_SGE_FRAMING_ERROR | F_CIM_FRAMING_ERROR | \
 			 F_ZERO_SWITCH_ERROR)
 #define CIM_INTR_MASK (F_BLKWRPLINT | F_BLKRDPLINT | F_BLKWRCTLINT | \
 		       F_BLKRDCTLINT | F_BLKWRFLASHINT | F_BLKRDFLASHINT | \
 		       F_SGLWRFLASHINT | F_WRBLKFLASHINT | F_BLKWRBOOTINT | \
-	 	       F_FLASHRANGEINT | F_SDRAMRANGEINT | F_RSVDSPACEINT)
+	 	       F_FLASHRANGEINT | F_SDRAMRANGEINT | F_RSVDSPACEINT | \
+		       F_DRAMPARERR | F_ICACHEPARERR | F_DCACHEPARERR | \
+		       F_OBQSGEPARERR | F_OBQULPHIPARERR | F_OBQULPLOPARERR | \
+		       F_IBQSGELOPARERR | F_IBQSGEHIPARERR | F_IBQULPPARERR | \
+		       F_IBQTPPARERR | F_ITAGPARERR | F_DTAGPARERR)
 #define PMTX_INTR_MASK (F_ZERO_C_CMD_ERROR | ICSPI_FRM_ERR | OESPI_FRM_ERR | \
 			V_ICSPI_PAR_ERROR(M_ICSPI_PAR_ERROR) | \
 			V_OESPI_PAR_ERROR(M_OESPI_PAR_ERROR))
@@ -1358,6 +1371,10 @@ static void pcie_intr_handler(struct adapter *adapter)
 		{F_PCIE_CFPARERR, "PCI command FIFO parity error", -1, 1},
 		{V_PCIE_MSIXPARERR(M_PCIE_MSIXPARERR),
 		 "PCI MSI-X table/PBA parity error", -1, 1},
+		{F_RETRYBUFPARERR, "PCI retry buffer parity error", -1, 1},
+		{F_RETRYLUTPARERR, "PCI retry LUT parity error", -1, 1},
+		{F_RXPARERR, "PCI Rx parity error", -1, 1},
+		{F_TXPARERR, "PCI Tx parity error", -1, 1},
 		{V_BISTERR(M_BISTERR), "PCI BIST error", -1, 1},
 		{0}
 	};
@@ -1384,15 +1401,15 @@ static void tp_intr_handler(struct adapter *adapter)
 	};
 
 	static struct intr_info tp_intr_info_t3c[] = {
-		{ 0x1ffffff,  "TP parity error", -1, 1 },
-		{ F_FLMRXFLSTEMPTY, "TP out of Rx pages", -1, 1 },
-		{ F_FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1 },
-		{ 0 }
+		{0x1fffffff, "TP parity error", -1, 1},
+		{F_FLMRXFLSTEMPTY, "TP out of Rx pages", -1, 1},
+		{F_FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1},
+		{0}
 	};
 
 	if (t3_handle_intr_status(adapter, A_TP_INT_CAUSE, 0xffffffff,
 				  adapter->params.rev < T3_REV_C ?
-					tp_intr_info : tp_intr_info_t3c, NULL))
+				  tp_intr_info : tp_intr_info_t3c, NULL))
 		t3_fatal_err(adapter);
 }
 
@@ -1414,6 +1431,18 @@ static void cim_intr_handler(struct adapter *adapter)
 		{F_BLKWRCTLINT, "CIM block write to CTL space", -1, 1},
 		{F_BLKRDPLINT, "CIM block read from PL space", -1, 1},
 		{F_BLKWRPLINT, "CIM block write to PL space", -1, 1},
+		{F_DRAMPARERR, "CIM DRAM parity error", -1, 1},
+		{F_ICACHEPARERR, "CIM icache parity error", -1, 1},
+		{F_DCACHEPARERR, "CIM dcache parity error", -1, 1},
+		{F_OBQSGEPARERR, "CIM OBQ SGE parity error", -1, 1},
+		{F_OBQULPHIPARERR, "CIM OBQ ULPHI parity error", -1, 1},
+		{F_OBQULPLOPARERR, "CIM OBQ ULPLO parity error", -1, 1},
+		{F_IBQSGELOPARERR, "CIM IBQ SGELO parity error", -1, 1},
+		{F_IBQSGEHIPARERR, "CIM IBQ SGEHI parity error", -1, 1},
+		{F_IBQULPPARERR, "CIM IBQ ULP parity error", -1, 1},
+		{F_IBQTPPARERR, "CIM IBQ TP parity error", -1, 1},
+		{F_ITAGPARERR, "CIM itag parity error", -1, 1},
+		{F_DTAGPARERR, "CIM dtag parity error", -1, 1},
 		{0}
 	};
 
@@ -1428,7 +1457,14 @@ static void cim_intr_handler(struct adapter *adapter)
 static void ulprx_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info ulprx_intr_info[] = {
-		{F_PARERR, "ULP RX parity error", -1, 1},
+		{F_PARERRDATA, "ULP RX data parity error", -1, 1},
+		{F_PARERRPCMD, "ULP RX command parity error", -1, 1},
+		{F_ARBPF1PERR, "ULP RX ArbPF1 parity error", -1, 1},
+		{F_ARBPF0PERR, "ULP RX ArbPF0 parity error", -1, 1},
+		{F_ARBFPERR, "ULP RX ArbF parity error", -1, 1},
+		{F_PCMDMUXPERR, "ULP RX PCMDMUX parity error", -1, 1},
+		{F_DATASELFRAMEERR1, "ULP RX frame error", -1, 1},
+		{F_DATASELFRAMEERR0, "ULP RX frame error", -1, 1},
 		{0}
 	};
 
@@ -1447,6 +1483,7 @@ static void ulptx_intr_handler(struct adapter *adapter)
 		 STAT_ULP_CH0_PBL_OOB, 0},
 		{F_PBL_BOUND_ERR_CH1, "ULP TX channel 1 PBL out of bounds",
 		 STAT_ULP_CH1_PBL_OOB, 0},
+		{0xfc, "ULP TX parity error", -1, 1},
 		{0}
 	};
 
@@ -1521,7 +1558,8 @@ static void pmrx_intr_handler(struct adapter *adapter)
 static void cplsw_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info cplsw_intr_info[] = {
-/*		{ F_CIM_OVFL_ERROR, "CPL switch CIM overflow", -1, 1 }, */
+		{F_CIM_OP_MAP_PERR, "CPL switch CIM parity error", -1, 1},
+		{F_CIM_OVFL_ERROR, "CPL switch CIM overflow", -1, 1},
 		{F_TP_FRAMING_ERROR, "CPL switch TP framing error", -1, 1},
 		{F_SGE_FRAMING_ERROR, "CPL switch SGE framing error", -1, 1},
 		{F_CIM_FRAMING_ERROR, "CPL switch CIM framing error", -1, 1},
@@ -1907,6 +1945,16 @@ static int t3_sge_write_context(struct adapter *adapter, unsigned int id,
 			       0, SG_CONTEXT_CMD_ATTEMPTS, 1);
 }
 
+static int clear_sge_ctxt(struct adapter *adap, unsigned int id,
+			  unsigned int type)
+{
+	t3_write_reg(adap, A_SG_CONTEXT_DATA0, 0);
+	t3_write_reg(adap, A_SG_CONTEXT_DATA1, 0);
+	t3_write_reg(adap, A_SG_CONTEXT_DATA2, 0);
+	t3_write_reg(adap, A_SG_CONTEXT_DATA3, 0);
+	return t3_sge_write_context(adap, id, type);
+}
+
 /**
  *	t3_sge_init_ecntxt - initialize an SGE egress context
  *	@adapter: the adapter to configure
@@ -2408,7 +2456,7 @@ static inline unsigned int pm_num_pages(unsigned int mem_size,
 	t3_write_reg((adap), A_ ## reg, (start)); \
 	start += size
 
-/*
+/**
  *	partition_mem - partition memory and configure TP memory settings
  *	@adap: the adapter
  *	@p: the TP parameters
@@ -2493,7 +2541,7 @@ static void tp_config(struct adapter *adap, const struct tp_params *p)
 		     V_AUTOSTATE2(1) | V_AUTOSTATE1(0) |
 		     V_BYTETHRESHOLD(16384) | V_MSSTHRESHOLD(2) |
 		     F_AUTOCAREFUL | F_AUTOENABLE | V_DACK_MODE(1));
-	t3_set_reg_field(adap, A_TP_IN_CONFIG, F_IPV6ENABLE | F_NICMODE,
+	t3_set_reg_field(adap, A_TP_IN_CONFIG, F_RXFBARBPRIO | F_TXFBARBPRIO,
 			 F_IPV6ENABLE | F_NICMODE);
 	t3_write_reg(adap, A_TP_TX_RESOURCE_LIMIT, 0x18141814);
 	t3_write_reg(adap, A_TP_PARA_REG4, 0x5050105);
@@ -2505,7 +2553,9 @@ static void tp_config(struct adapter *adap, const struct tp_params *p)
 			 F_ENABLEEPCMDAFULL,
 			 F_ENABLEOCSPIFULL |F_TXDEFERENABLE | F_HEARBEATDACK |
 			 F_TXCONGESTIONMODE | F_RXCONGESTIONMODE);
-	t3_set_reg_field(adap, A_TP_PC_CONFIG2, F_CHDRAFULL, 0);
+	t3_set_reg_field(adap, A_TP_PC_CONFIG2, F_CHDRAFULL,
+			 F_ENABLEIPV6RSS | F_ENABLENONOFDTNLSYN |
+			 F_ENABLEARPMISS | F_DISBLEDAPARBIT0);
 	t3_write_reg(adap, A_TP_PROXY_FLOW_CNTL, 1080);
 	t3_write_reg(adap, A_TP_PROXY_FLOW_CNTL, 1000);
 
@@ -3212,7 +3262,8 @@ static void config_pcie(struct adapter *adap)
 			 V_REPLAYLMT(rpllmt));
 
 	t3_write_reg(adap, A_PCIE_PEX_ERR, 0xffffffff);
-	t3_set_reg_field(adap, A_PCIE_CFG, F_PCIE_CLIDECEN, F_PCIE_CLIDECEN);
+	t3_set_reg_field(adap, A_PCIE_CFG, 0,
+			 F_PCIE_DMASTOPEN | F_PCIE_CLIDECEN);
 }
 
 /*
@@ -3225,7 +3276,7 @@ static void config_pcie(struct adapter *adap)
  */
 int t3_init_hw(struct adapter *adapter, u32 fw_params)
 {
-	int err = -EIO, attempts = 100;
+	int err = -EIO, attempts, i;
 	const struct vpd_params *vpd = &adapter->params.vpd;
 
 	if (adapter->params.rev > 0)
@@ -3243,6 +3294,10 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 				adapter->params.mc5.nfilters,
 				adapter->params.mc5.nroutes))
 			goto out_err;
+
+		for (i = 0; i < 32; i++)
+			if (clear_sge_ctxt(adapter, i, F_CQ))
+				goto out_err;
 	}
 
 	if (tp_init(adapter, &adapter->params.tp))
@@ -3258,7 +3313,8 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 	if (is_pcie(adapter))
 		config_pcie(adapter);
 	else
-		t3_set_reg_field(adapter, A_PCIX_CFG, 0, F_CLIDECEN);
+		t3_set_reg_field(adapter, A_PCIX_CFG, 0,
+				 F_DMASTOPEN | F_CLIDECEN);
 
 	if (adapter->params.rev == T3_REV_C)
 		t3_set_reg_field(adapter, A_ULPTX_CONFIG, 0,
@@ -3275,6 +3331,7 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 		     V_BOOTADDR(FW_FLASH_BOOT_ADDR >> 2));
 	t3_read_reg(adapter, A_CIM_BOOT_CFG);	/* flush */
 
+	attempts = 100;
 	do {			/* wait for uP to initialize */
 		msleep(20);
 	} while (t3_read_reg(adapter, A_CIM_HOST_ACC_DATA) && --attempts);
@@ -3409,6 +3466,7 @@ void early_hw_init(struct adapter *adapter, const struct adapter_info *ai)
 	t3_write_reg(adapter, A_T3DBG_GPIO_EN,
 		     ai->gpio_out | F_GPIO0_OEN | F_GPIO0_OUT_VAL);
 	t3_write_reg(adapter, A_MC5_DB_SERVER_INDEX, 0);
+	t3_write_reg(adapter, A_SG_OCO_BASE, V_BASE1(0xfff));
 
 	if (adapter->params.rev == 0 || !uses_xaui(adapter))
 		val |= F_ENRGMII;
@@ -3458,6 +3516,36 @@ static int t3_reset_adapter(struct adapter *adapter)
 	return 0;
 }
 
+static int __devinit init_parity(struct adapter *adap)
+{
+		int i, err, addr;
+
+	if (t3_read_reg(adap, A_SG_CONTEXT_CMD) & F_CONTEXT_CMD_BUSY)
+		return -EBUSY;
+
+	for (err = i = 0; !err && i < 16; i++)
+		err = clear_sge_ctxt(adap, i, F_EGRESS);
+	for (i = 0xfff0; !err && i <= 0xffff; i++)
+		err = clear_sge_ctxt(adap, i, F_EGRESS);
+	for (i = 0; !err && i < SGE_QSETS; i++)
+		err = clear_sge_ctxt(adap, i, F_RESPONSEQ);
+	if (err)
+		return err;
+
+	t3_write_reg(adap, A_CIM_IBQ_DBG_DATA, 0);
+	for (i = 0; i < 4; i++)
+		for (addr = 0; addr <= M_IBQDBGADDR; addr++) {
+			t3_write_reg(adap, A_CIM_IBQ_DBG_CFG, F_IBQDBGEN |
+				     F_IBQDBGWR | V_IBQDBGQID(i) |
+				     V_IBQDBGADDR(addr));
+			err = t3_wait_op_done(adap, A_CIM_IBQ_DBG_CFG,
+					      F_IBQDBGBUSY, 0, 2, 1);
+			if (err)
+				return err;
+		}
+	return 0;
+}
+
 /*
  * Initialize adapter SW state for the various HW modules, set initial values
  * for some adapter tunables, take PHYs out of reset, and initialize the MDIO
@@ -3525,6 +3613,9 @@ int __devinit t3_prep_adapter(struct adapter *adapter,
 	}
 
 	early_hw_init(adapter, ai);
+	ret = init_parity(adapter);
+	if (ret)
+		return ret;
 
 	for_each_port(adapter, i) {
 		u8 hw_addr[6];
