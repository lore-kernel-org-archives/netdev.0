From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [Patch v3 2/5] fsl/qe: setup clock source for TDM mode
Date: Mon, 6 Jun 2016 14:29:59 +0800
Message-ID: <1465194602-43209-2-git-send-email-qiang.zhao@nxp.com>
References: <1465194602-43209-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <xiaobo.xie@nxp.com>,
	Zhao Qiang <qiang.zhao@nxp.com>
To: <oss@buserror.net>, <davem@davemloft.net>,
	<Joakim.Tjernlund@infinera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465194602-43209-1-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add tdm clock configuration in both qe clock system and ucc
fast controller.

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
Changes for v2:
	- break codes getting clock_bits and source to smaller functions.
	- add __iomem to qe_mux_reg
	- add bits operation functions for qe and use it
	- retrun -EINVAL when clock_bits is invalid
Changes for v3:
	- adjust some incorrect indentations

 drivers/soc/fsl/qe/ucc.c      | 450 ++++++++++++++++++++++++++++++++++++++++++
 drivers/soc/fsl/qe/ucc_fast.c |  36 ++++
 include/soc/fsl/qe/qe.h       |  16 ++
 include/soc/fsl/qe/ucc.h      |   4 +
 include/soc/fsl/qe/ucc_fast.h |   1 +
 5 files changed, 507 insertions(+)

diff --git a/drivers/soc/fsl/qe/ucc.c b/drivers/soc/fsl/qe/ucc.c
index b59d335..c646d87 100644
--- a/drivers/soc/fsl/qe/ucc.c
+++ b/drivers/soc/fsl/qe/ucc.c
@@ -25,6 +25,12 @@
 #include <soc/fsl/qe/qe.h>
 #include <soc/fsl/qe/ucc.h>
 
+#define UCC_TDM_NUM 8
+#define RX_SYNC_SHIFT_BASE 30
+#define TX_SYNC_SHIFT_BASE 14
+#define RX_CLK_SHIFT_BASE 28
+#define TX_CLK_SHIFT_BASE 12
+
 int ucc_set_qe_mux_mii_mng(unsigned int ucc_num)
 {
 	unsigned long flags;
@@ -210,3 +216,447 @@ int ucc_set_qe_mux_rxtx(unsigned int ucc_num, enum qe_clock clock,
 
 	return 0;
 }
+
+static int ucc_get_tdm_common_clk(u32 tdm_num, enum qe_clock clock)
+{
+	int clock_bits = -EINVAL;
+
+	/*
+	 * for TDM[0, 1, 2, 3], TX and RX use  common
+	 * clock source BRG3,4 and CLK1,2
+	 * for TDM[4, 5, 6, 7], TX and RX use  common
+	 * clock source BRG12,13 and CLK23,24
+	 */
+	switch (tdm_num) {
+	case 0:
+	case 1:
+	case 2:
+	case 3:
+		switch (clock) {
+		case QE_BRG3:
+			clock_bits = 1;
+			break;
+		case QE_BRG4:
+			clock_bits = 2;
+			break;
+		case QE_CLK1:
+			clock_bits = 4;
+			break;
+		case QE_CLK2:
+			clock_bits = 5;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 4:
+	case 5:
+	case 6:
+	case 7:
+		switch (clock) {
+		case QE_BRG12:
+			clock_bits = 1;
+			break;
+		case QE_BRG13:
+			clock_bits = 2;
+			break;
+		case QE_CLK23:
+			clock_bits = 4;
+			break;
+		case QE_CLK24:
+			clock_bits = 5;
+			break;
+		default:
+			break;
+		}
+		break;
+	default:
+		break;
+	}
+
+	return clock_bits;
+}
+
+static int ucc_get_tdm_rx_clk(u32 tdm_num, enum qe_clock clock)
+{
+	int clock_bits = -EINVAL;
+
+	switch (tdm_num) {
+	case 0:
+		switch (clock) {
+		case QE_CLK3:
+			clock_bits = 6;
+			break;
+		case QE_CLK8:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 1:
+		switch (clock) {
+		case QE_CLK5:
+			clock_bits = 6;
+			break;
+		case QE_CLK10:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 2:
+		switch (clock) {
+		case QE_CLK7:
+			clock_bits = 6;
+			break;
+		case QE_CLK12:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 3:
+		switch (clock) {
+		case QE_CLK9:
+			clock_bits = 6;
+			break;
+		case QE_CLK14:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 4:
+		switch (clock) {
+		case QE_CLK11:
+			clock_bits = 6;
+			break;
+		case QE_CLK16:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 5:
+		switch (clock) {
+		case QE_CLK13:
+			clock_bits = 6;
+			break;
+		case QE_CLK18:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 6:
+		switch (clock) {
+		case QE_CLK15:
+			clock_bits = 6;
+			break;
+		case QE_CLK20:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 7:
+		switch (clock) {
+		case QE_CLK17:
+			clock_bits = 6;
+			break;
+		case QE_CLK22:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	}
+
+	return clock_bits;
+}
+
+static int ucc_get_tdm_tx_clk(u32 tdm_num, enum qe_clock clock)
+{
+	int clock_bits = -EINVAL;
+
+	switch (tdm_num) {
+	case 0:
+		switch (clock) {
+		case QE_CLK4:
+			clock_bits = 6;
+			break;
+		case QE_CLK9:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 1:
+		switch (clock) {
+		case QE_CLK6:
+			clock_bits = 6;
+			break;
+		case QE_CLK11:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 2:
+		switch (clock) {
+		case QE_CLK8:
+			clock_bits = 6;
+			break;
+		case QE_CLK13:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 3:
+		switch (clock) {
+		case QE_CLK10:
+			clock_bits = 6;
+			break;
+		case QE_CLK15:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 4:
+		switch (clock) {
+		case QE_CLK12:
+			clock_bits = 6;
+			break;
+		case QE_CLK17:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 5:
+		switch (clock) {
+		case QE_CLK14:
+			clock_bits = 6;
+			break;
+		case QE_CLK19:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 6:
+		switch (clock) {
+		case QE_CLK16:
+			clock_bits = 6;
+			break;
+		case QE_CLK21:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 7:
+		switch (clock) {
+		case QE_CLK18:
+			clock_bits = 6;
+			break;
+		case QE_CLK3:
+			clock_bits = 7;
+			break;
+		default:
+			break;
+		}
+		break;
+	}
+
+	return clock_bits;
+}
+
+/* tdm_num: TDM A-H port num is 0-7 */
+static int ucc_get_tdm_rxtx_clk(enum comm_dir mode, u32 tdm_num,
+				enum qe_clock clock)
+{
+	int clock_bits;
+
+	clock_bits = ucc_get_tdm_common_clk(tdm_num, clock);
+	if (clock_bits > 0)
+		return clock_bits;
+	if (mode == COMM_DIR_RX)
+		clock_bits = ucc_get_tdm_rx_clk(tdm_num, clock);
+	if (mode == COMM_DIR_TX)
+		clock_bits = ucc_get_tdm_tx_clk(tdm_num, clock);
+	return clock_bits;
+}
+
+static u32 ucc_get_tdm_clk_shift(enum comm_dir mode, u32 tdm_num)
+{
+	u32 shift;
+
+	shift = (mode == COMM_DIR_RX) ? RX_CLK_SHIFT_BASE : TX_CLK_SHIFT_BASE;
+	if (tdm_num < 4)
+		shift -= tdm_num * 4;
+	else
+		shift -= (tdm_num - 4) * 4;
+
+	return shift;
+}
+
+int ucc_set_tdm_rxtx_clk(u32 tdm_num, enum qe_clock clock,
+			 enum comm_dir mode)
+{
+	int clock_bits;
+	u32 shift;
+	struct qe_mux __iomem *qe_mux_reg;
+	 __be32 __iomem *cmxs1cr;
+
+	qe_mux_reg = &qe_immr->qmx;
+
+	if (tdm_num > 7 || tdm_num < 0)
+		return -EINVAL;
+
+	/* The communications direction must be RX or TX */
+	if (mode != COMM_DIR_RX && mode != COMM_DIR_TX)
+		return -EINVAL;
+
+	clock_bits = ucc_get_tdm_rxtx_clk(mode, tdm_num, clock);
+	if (clock_bits < 0)
+		return -EINVAL;
+
+	shift = ucc_get_tdm_clk_shift(mode, tdm_num);
+
+	cmxs1cr = (tdm_num < 4) ? &qe_mux_reg->cmxsi1cr_l :
+				  &qe_mux_reg->cmxsi1cr_h;
+
+	qe_clrsetbits32(cmxs1cr, QE_CMXUCR_TX_CLK_SRC_MASK << shift,
+			clock_bits << shift);
+
+	return 0;
+}
+
+static int ucc_get_tdm_sync_source(u32 tdm_num, enum qe_clock clock,
+				   enum comm_dir mode)
+{
+	int source = -EINVAL;
+
+	if (mode == COMM_DIR_RX && clock == QE_RSYNC_PIN) {
+		source = 0;
+		return source;
+	}
+	if (mode == COMM_DIR_TX && clock == QE_TSYNC_PIN) {
+		source = 0;
+		return source;
+	}
+
+	switch (tdm_num) {
+	case 0:
+	case 1:
+		switch (clock) {
+		case QE_BRG9:
+			source = 1;
+			break;
+		case QE_BRG10:
+			source = 2;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 2:
+	case 3:
+		switch (clock) {
+		case QE_BRG9:
+			source = 1;
+			break;
+		case QE_BRG11:
+			source = 2;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 4:
+	case 5:
+		switch (clock) {
+		case QE_BRG13:
+			source = 1;
+			break;
+		case QE_BRG14:
+			source = 2;
+			break;
+		default:
+			break;
+		}
+		break;
+	case 6:
+	case 7:
+		switch (clock) {
+		case QE_BRG13:
+			source = 1;
+			break;
+		case QE_BRG15:
+			source = 2;
+			break;
+		default:
+			break;
+		}
+		break;
+	}
+
+	return source;
+}
+
+static u32 ucc_get_tdm_sync_shift(enum comm_dir mode, u32 tdm_num)
+{
+	u32 shift;
+
+	shift = (mode == COMM_DIR_RX) ? RX_SYNC_SHIFT_BASE : RX_SYNC_SHIFT_BASE;
+	shift -= tdm_num * 2;
+
+	return shift;
+}
+
+int ucc_set_tdm_rxtx_sync(u32 tdm_num, enum qe_clock clock,
+			  enum comm_dir mode)
+{
+	int source;
+	u32 shift;
+	struct qe_mux *qe_mux_reg;
+
+	qe_mux_reg = &qe_immr->qmx;
+
+	if (tdm_num >= UCC_TDM_NUM)
+		return -EINVAL;
+
+	/* The communications direction must be RX or TX */
+	if (mode != COMM_DIR_RX && mode != COMM_DIR_TX)
+		return -EINVAL;
+
+	source = ucc_get_tdm_sync_source(tdm_num, clock, mode);
+	if (source < 0)
+		return -EINVAL;
+
+	shift = ucc_get_tdm_sync_shift(mode, tdm_num);
+
+	qe_clrsetbits32(&qe_mux_reg->cmxsi1syr,
+			QE_CMXUCR_TX_CLK_SRC_MASK << shift,
+			source << shift);
+
+	return 0;
+}
diff --git a/drivers/soc/fsl/qe/ucc_fast.c b/drivers/soc/fsl/qe/ucc_fast.c
index a768931..83d8d16 100644
--- a/drivers/soc/fsl/qe/ucc_fast.c
+++ b/drivers/soc/fsl/qe/ucc_fast.c
@@ -327,6 +327,42 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, struct ucc_fast_private ** ucc
 			ucc_fast_free(uccf);
 			return -EINVAL;
 		}
+	} else {
+		/* tdm Rx clock routing */
+		if ((uf_info->rx_clock != QE_CLK_NONE) &&
+		    ucc_set_tdm_rxtx_clk(uf_info->tdm_num, uf_info->rx_clock,
+					 COMM_DIR_RX)) {
+			pr_err("%s: illegal value for RX clock", __func__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
+
+		/* tdm Tx clock routing */
+		if ((uf_info->tx_clock != QE_CLK_NONE) &&
+		    ucc_set_tdm_rxtx_clk(uf_info->tdm_num, uf_info->tx_clock,
+					 COMM_DIR_TX)) {
+			pr_err("%s: illegal value for TX clock", __func__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
+
+		/* tdm Rx sync clock routing */
+		if ((uf_info->rx_sync != QE_CLK_NONE) &&
+		    ucc_set_tdm_rxtx_sync(uf_info->tdm_num, uf_info->rx_sync,
+					  COMM_DIR_RX)) {
+			pr_err("%s: illegal value for RX clock", __func__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
+
+		/* tdm Tx sync clock routing */
+		if ((uf_info->tx_sync != QE_CLK_NONE) &&
+		    ucc_set_tdm_rxtx_sync(uf_info->tdm_num, uf_info->tx_sync,
+					  COMM_DIR_TX)) {
+			pr_err("%s: illegal value for TX clock", __func__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
 	}
 
 	/* Set interrupt mask register at UCC level. */
diff --git a/include/soc/fsl/qe/qe.h b/include/soc/fsl/qe/qe.h
index f918745..c3b1dc8 100644
--- a/include/soc/fsl/qe/qe.h
+++ b/include/soc/fsl/qe/qe.h
@@ -244,6 +244,22 @@ static inline int qe_alive_during_sleep(void)
 #define qe_muram_addr cpm_muram_addr
 #define qe_muram_offset cpm_muram_offset
 
+#define qe_setbits32(_addr, _v) iowrite32be(ioread32be(_addr) |  (_v), (_addr))
+#define qe_clrbits32(_addr, _v) iowrite32be(ioread32be(_addr) & ~(_v), (_addr))
+
+#define qe_setbits16(_addr, _v) iowrite16be(ioread16be(_addr) |  (_v), (_addr))
+#define qe_clrbits16(_addr, _v) iowrite16be(ioread16be(_addr) & ~(_v), (_addr))
+
+#define qe_setbits8(_addr, _v) iowrite8(ioread8(_addr) |  (_v), (_addr))
+#define qe_clrbits8(_addr, _v) iowrite8(ioread8(_addr) & ~(_v), (_addr))
+
+#define qe_clrsetbits32(addr, clear, set) \
+	iowrite32be((ioread32be(addr) & ~(clear)) | (set), (addr))
+#define qe_clrsetbits16(addr, clear, set) \
+	iowrite16be((ioread16be(addr) & ~(clear)) | (set), (addr))
+#define qe_clrsetbits8(addr, clear, set) \
+	iowrite8((ioread8(addr) & ~(clear)) | (set), (addr))
+
 /* Structure that defines QE firmware binary files.
  *
  * See Documentation/powerpc/qe_firmware.txt for a description of these
diff --git a/include/soc/fsl/qe/ucc.h b/include/soc/fsl/qe/ucc.h
index 894f14c..6bbbb59 100644
--- a/include/soc/fsl/qe/ucc.h
+++ b/include/soc/fsl/qe/ucc.h
@@ -41,6 +41,10 @@ int ucc_set_qe_mux_mii_mng(unsigned int ucc_num);
 
 int ucc_set_qe_mux_rxtx(unsigned int ucc_num, enum qe_clock clock,
 	enum comm_dir mode);
+int ucc_set_tdm_rxtx_clk(unsigned int tdm_num, enum qe_clock clock,
+			 enum comm_dir mode);
+int ucc_set_tdm_rxtx_sync(unsigned int tdm_num, enum qe_clock clock,
+			  enum comm_dir mode);
 
 int ucc_mux_set_grant_tsa_bkpt(unsigned int ucc_num, int set, u32 mask);
 
diff --git a/include/soc/fsl/qe/ucc_fast.h b/include/soc/fsl/qe/ucc_fast.h
index 31548b7..b2633b7 100644
--- a/include/soc/fsl/qe/ucc_fast.h
+++ b/include/soc/fsl/qe/ucc_fast.h
@@ -118,6 +118,7 @@ enum ucc_fast_transparent_tcrc {
 /* Fast UCC initialization structure */
 struct ucc_fast_info {
 	int ucc_num;
+	int tdm_num;
 	enum qe_clock rx_clock;
 	enum qe_clock tx_clock;
 	enum qe_clock rx_sync;
-- 
2.1.0.27.g96db324
