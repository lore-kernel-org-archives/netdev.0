From: "Karen Xie" <kxie@chelsio.com>
Subject: [PATCH 1/3 2.6.27] cxgb3 - Add iSCSI support
Date: Wed, 18 Jun 2008 22:10:08 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334D71286@maui.asicdesigners.com>
References: <200806190256.m5J2u1FB021005@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<security@kernel.org>, <open-iscsi@googlegroups.com>,
	<linux-kernel@vger.kernel.org>
To: <michaelc@cs.wisc.edu>, "Divy Le Ray" <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:19851 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498AbYFSFoA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 01:44:00 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karen Xie <kxie@chelsio.com>

Add iSCSI support:
- read and write iSCSI related registers
- additional types of chelsio-protocol-language used by iscsi. 

Signed-off-by: Karen Xie <kxie@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_ctl_defs.h |    5 +---
 drivers/net/cxgb3/cxgb3_offload.c  |   11 ++++++++++
 drivers/net/cxgb3/regs.h           |   10 +++++----
 drivers/net/cxgb3/t3_cpl.h         |   41 ++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb3/t3cdev.h         |    4 +++-
 5 files changed, 62 insertions(+), 9 deletions(-)


diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxgb3_ctl_defs.h
index 6c4f320..d38e6cc 100644
--- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
+++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
@@ -110,10 +110,7 @@ struct ulp_iscsi_info {
 	unsigned int llimit;
 	unsigned int ulimit;
 	unsigned int tagmask;
-	unsigned int pgsz3;
-	unsigned int pgsz2;
-	unsigned int pgsz1;
-	unsigned int pgsz0;
+	u8 pgsz_factor[4];
 	unsigned int max_rxsz;
 	unsigned int max_txsz;
 	struct pci_dev *pdev;
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index ff9c013..ddf3d2d 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -207,6 +207,17 @@ static int cxgb_ulp_iscsi_ctl(struct adapter *adapter, unsigned int req,
 		break;
 	case ULP_ISCSI_SET_PARAMS:
 		t3_write_reg(adapter, A_ULPRX_ISCSI_TAGMASK, uiip->tagmask);
+		/* set MaxRxData and MaxCoalesceSize to 16224 */
+		t3_write_reg(adapter, A_TP_PARA_REG2, 0x3f603f60);
+		/* program the ddp page sizes */
+		{
+			int i;
+			unsigned int val = 0;
+			for (i = 0; i < 4; i++)
+				val |= (uiip->pgsz_factor[i] & 0xF) << (8 * i);
+			if (val)
+				t3_write_reg(adapter, A_ULPRX_ISCSI_PSZ, val);
+		}
 		break;
 	default:
 		ret = -EOPNOTSUPP;
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 5671788..4bda27c 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1517,16 +1517,18 @@
 
 #define A_ULPRX_ISCSI_TAGMASK 0x514
 
-#define S_HPZ0    0
-#define M_HPZ0    0xf
-#define V_HPZ0(x) ((x) << S_HPZ0)
-#define G_HPZ0(x) (((x) >> S_HPZ0) & M_HPZ0)
+#define A_ULPRX_ISCSI_PSZ 0x518
 
 #define A_ULPRX_TDDP_LLIMIT 0x51c
 
 #define A_ULPRX_TDDP_ULIMIT 0x520
 #define A_ULPRX_TDDP_PSZ 0x528
 
+#define S_HPZ0    0
+#define M_HPZ0    0xf
+#define V_HPZ0(x) ((x) << S_HPZ0)
+#define G_HPZ0(x) (((x) >> S_HPZ0) & M_HPZ0)
+
 #define A_ULPRX_STAG_LLIMIT 0x52c
 
 #define A_ULPRX_STAG_ULIMIT 0x530
diff --git a/drivers/net/cxgb3/t3_cpl.h b/drivers/net/cxgb3/t3_cpl.h
index b7a1a31..db25ada 100644
--- a/drivers/net/cxgb3/t3_cpl.h
+++ b/drivers/net/cxgb3/t3_cpl.h
@@ -184,6 +184,9 @@ union opcode_tid {
 #define G_OPCODE(x) (((x) >> S_OPCODE) & 0xFF)
 #define G_TID(x)    ((x) & 0xFFFFFF)
 
+#define S_QNUM 0
+#define G_QNUM(x) (((x) >> S_QNUM) & 0xFFFF)
+
 /* tid is assumed to be 24-bits */
 #define MK_OPCODE_TID(opcode, tid) (V_OPCODE(opcode) | (tid))
 
@@ -768,6 +771,12 @@ struct tx_data_wr {
 	__be32 param;
 };
 
+/* tx_data_wr.flags fields */
+#define S_TX_ACK_PAGES	  21
+#define M_TX_ACK_PAGES    0x7
+#define V_TX_ACK_PAGES(x) ((x) << S_TX_ACK_PAGES)
+#define G_TX_ACK_PAGES(x) (((x) >> S_TX_ACK_PAGES) & M_TX_ACK_PAGES)
+
 /* tx_data_wr.param fields */
 #define S_TX_PORT    0
 #define M_TX_PORT    0x7
@@ -1441,4 +1450,36 @@ struct cpl_rdma_terminate {
 #define M_TERM_TID    0xFFFFF
 #define V_TERM_TID(x) ((x) << S_TERM_TID)
 #define G_TERM_TID(x) (((x) >> S_TERM_TID) & M_TERM_TID)
+
+/* ULP_TX opcodes */
+enum { ULP_MEM_READ = 2, ULP_MEM_WRITE = 3, ULP_TXPKT = 4 };
+
+#define S_ULPTX_CMD	  28
+#define M_ULPTX_CMD	  0xF
+#define V_ULPTX_CMD(x)    ((x) << S_ULPTX_CMD)
+
+#define S_ULPTX_NFLITS    0
+#define M_ULPTX_NFLITS    0xFF
+#define V_ULPTX_NFLITS(x) ((x) << S_ULPTX_NFLITS)
+
+struct ulp_mem_io {
+	WR_HDR;
+	__be32 cmd_lock_addr;
+	__be32 len;
+};
+
+/* ulp_mem_io.cmd_lock_addr fields */
+#define S_ULP_MEMIO_ADDR    0
+#define M_ULP_MEMIO_ADDR    0x7FFFFFF
+#define V_ULP_MEMIO_ADDR(x) ((x) << S_ULP_MEMIO_ADDR)
+
+#define S_ULP_MEMIO_LOCK    27
+#define V_ULP_MEMIO_LOCK(x) ((x) << S_ULP_MEMIO_LOCK)
+#define F_ULP_MEMIO_LOCK    V_ULP_MEMIO_LOCK(1U)
+
+/* ulp_mem_io.len fields */
+#define S_ULP_MEMIO_DATA_LEN    28
+#define M_ULP_MEMIO_DATA_LEN    0xF
+#define V_ULP_MEMIO_DATA_LEN(x) ((x) << S_ULP_MEMIO_DATA_LEN)
+
 #endif				/* T3_CPL_H */
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/cxgb3/t3cdev.h
index a18c8a1..0a21cfb 100644
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -45,7 +45,8 @@ struct cxgb3_client;
 
 enum t3ctype {
 	T3A = 0,
-	T3B
+	T3B,
+	T3C,
 };
 
 struct t3cdev {
@@ -63,6 +64,7 @@ struct t3cdev {
 	void *l3opt;		/* optional layer 3 data */
 	void *l4opt;		/* optional layer 4 data */
 	void *ulp;		/* ulp stuff */
+	void *ulp_iscsi;	/* ulp iscsi */
 };
 
 #endif				/* _T3CDEV_H_ */







