From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 8/9] cxgb3 - HW set up updates
Date: Fri, 16 Nov 2007 11:22:16 -0800
Message-ID: <20071116192216.31150.50259.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15565 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932581AbXKPTWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 14:22:21 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Disable PEX errors. The HW generates false positives.
Update RSS hash function to a symmetric algorithm.
Update T3C HW support

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    2 +-
 drivers/net/cxgb3/regs.h       |   22 ++++++++++++++++++++++
 drivers/net/cxgb3/t3_hw.c      |   24 +++++++++++++++++++++---
 3 files changed, 44 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index b4ee18b..f24a27b 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -336,7 +336,7 @@ static void setup_rss(struct adapter *adap)
 
 	t3_config_rss(adap, F_RQFEEDBACKENABLE | F_TNLLKPEN | F_TNLMAPEN |
 		      F_TNLPRTEN | F_TNL2TUPEN | F_TNL4TUPEN |
-		      V_RRCPLCPUSIZE(6), cpus, rspq_map);
+		      V_RRCPLCPUSIZE(6) | F_HASHTOEPLITZ, cpus, rspq_map);
 }
 
 static void init_napi(struct adapter *adap)
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 5e1bc0d..a7d5f65 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -965,6 +965,12 @@
 #define V_LOCKTID(x) ((x) << S_LOCKTID)
 #define F_LOCKTID    V_LOCKTID(1U)
 
+#define S_TABLELATENCYDELTA    0
+#define M_TABLELATENCYDELTA    0xf
+#define V_TABLELATENCYDELTA(x) ((x) << S_TABLELATENCYDELTA)
+#define G_TABLELATENCYDELTA(x) \
+	(((x) >> S_TABLELATENCYDELTA) & M_TABLELATENCYDELTA)
+
 #define A_TP_PC_CONFIG2 0x34c
 
 #define S_CHDRAFULL    4
@@ -1146,6 +1152,10 @@
 #define V_RQFEEDBACKENABLE(x) ((x) << S_RQFEEDBACKENABLE)
 #define F_RQFEEDBACKENABLE    V_RQFEEDBACKENABLE(1U)
 
+#define S_HASHTOEPLITZ    2
+#define V_HASHTOEPLITZ(x) ((x) << S_HASHTOEPLITZ)
+#define F_HASHTOEPLITZ    V_HASHTOEPLITZ(1U)
+
 #define S_DISABLE    0
 
 #define A_TP_TM_PIO_ADDR 0x418
@@ -1198,6 +1208,14 @@
 
 #define A_TP_INT_ENABLE 0x470
 
+#define S_FLMTXFLSTEMPTY    30
+#define V_FLMTXFLSTEMPTY(x) ((x) << S_FLMTXFLSTEMPTY)
+#define F_FLMTXFLSTEMPTY    V_FLMTXFLSTEMPTY(1U)
+
+#define S_FLMRXFLSTEMPTY    29
+#define V_FLMRXFLSTEMPTY(x) ((x) << S_FLMRXFLSTEMPTY)
+#define F_FLMRXFLSTEMPTY    V_FLMRXFLSTEMPTY(1U)
+
 #define A_TP_INT_CAUSE 0x474
 
 #define A_TP_TX_MOD_Q1_Q0_RATE_LIMIT 0x8
@@ -1291,6 +1309,10 @@
 
 #define A_ULPTX_CONFIG 0x580
 
+#define S_CFG_CQE_SOP_MASK    1
+#define V_CFG_CQE_SOP_MASK(x) ((x) << S_CFG_CQE_SOP_MASK)
+#define F_CFG_CQE_SOP_MASK    V_CFG_CQE_SOP_MASK(1U)
+
 #define S_CFG_RR_ARB    0
 #define V_CFG_RR_ARB(x) ((x) << S_CFG_RR_ARB)
 #define F_CFG_RR_ARB    V_CFG_RR_ARB(1U)
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 4b6087a..b8ae12d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1280,7 +1280,7 @@ static int t3_handle_intr_status(struct adapter *adapter, unsigned int reg,
 #define PCIE_INTR_MASK (F_UNXSPLCPLERRR | F_UNXSPLCPLERRC | F_PCIE_PIOPARERR |\
 			F_PCIE_WFPARERR | F_PCIE_RFPARERR | F_PCIE_CFPARERR | \
 			/* V_PCIE_MSIXPARERR(M_PCIE_MSIXPARERR) | */ \
-			V_BISTERR(M_BISTERR) | F_PEXERR)
+			V_BISTERR(M_BISTERR))
 #define ULPRX_INTR_MASK F_PARERR
 #define ULPTX_INTR_MASK 0
 #define CPLSW_INTR_MASK (F_TP_FRAMING_ERROR | \
@@ -1383,8 +1383,16 @@ static void tp_intr_handler(struct adapter *adapter)
 		{0}
 	};
 
+	static struct intr_info tp_intr_info_t3c[] = {
+		{ 0x1ffffff,  "TP parity error", -1, 1 },
+		{ F_FLMRXFLSTEMPTY, "TP out of Rx pages", -1, 1 },
+		{ F_FLMTXFLSTEMPTY, "TP out of Tx pages", -1, 1 },
+		{ 0 }
+	};
+
 	if (t3_handle_intr_status(adapter, A_TP_INT_CAUSE, 0xffffffff,
-				  tp_intr_info, NULL))
+				  adapter->params.rev < T3_REV_C ?
+					tp_intr_info : tp_intr_info_t3c, NULL))
 		t3_fatal_err(adapter);
 }
 
@@ -1734,7 +1742,6 @@ void t3_intr_enable(struct adapter *adapter)
 		 MC7_INTR_MASK},
 		{A_MC5_DB_INT_ENABLE, MC5_INTR_MASK},
 		{A_ULPRX_INT_ENABLE, ULPRX_INTR_MASK},
-		{A_TP_INT_ENABLE, 0x3bfffff},
 		{A_PM1_TX_INT_ENABLE, PMTX_INTR_MASK},
 		{A_PM1_RX_INT_ENABLE, PMRX_INTR_MASK},
 		{A_CIM_HOST_INT_ENABLE, CIM_INTR_MASK},
@@ -1744,6 +1751,8 @@ void t3_intr_enable(struct adapter *adapter)
 	adapter->slow_intr_mask = PL_INTR_MASK;
 
 	t3_write_regs(adapter, intr_en_avp, ARRAY_SIZE(intr_en_avp), 0);
+	t3_write_reg(adapter, A_TP_INT_ENABLE,
+		     adapter->params.rev >= T3_REV_C ? 0x2bfffff : 0x3bfffff);
 
 	if (adapter->params.rev > 0) {
 		t3_write_reg(adapter, A_CPL_INTR_ENABLE,
@@ -2509,6 +2518,11 @@ static void tp_config(struct adapter *adap, const struct tp_params *p)
 	} else
 		t3_set_reg_field(adap, A_TP_PARA_REG3, 0, F_TXPACEFIXED);
 
+	if (adap->params.rev == T3_REV_C)
+		t3_set_reg_field(adap, A_TP_PC_CONFIG,
+				 V_TABLELATENCYDELTA(M_TABLELATENCYDELTA),
+				 V_TABLELATENCYDELTA(4));
+
 	t3_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT1, 0);
 	t3_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT0, 0);
 	t3_write_reg(adap, A_TP_MOD_CHANNEL_WEIGHT, 0);
@@ -3246,6 +3260,10 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 	else
 		t3_set_reg_field(adapter, A_PCIX_CFG, 0, F_CLIDECEN);
 
+	if (adapter->params.rev == T3_REV_C)
+		t3_set_reg_field(adapter, A_ULPTX_CONFIG, 0,
+				 F_CFG_CQE_SOP_MASK);
+
 	t3_write_reg(adapter, A_PM1_RX_CFG, 0xffffffff);
 	t3_write_reg(adapter, A_PM1_RX_MODE, 0);
 	t3_write_reg(adapter, A_PM1_TX_MODE, 0);
