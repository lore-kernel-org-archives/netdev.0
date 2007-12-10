From: Poonam_Aggrwal-b10812 <b10812@freescale.com>
Subject: [PATCH 2/3] arch/ : Platform changes for UCC TDM driver for
 MPC8323ERDB.Also includes related QE changes.
Date: Mon, 10 Dec 2007 17:39:22 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0712101734490.29623@linux121>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: michael.barkowski@freescale.com, kim.phillips@freescale.com,
	ashish.kalra@freescale.com, rich.cutler@freescale.com
To: rubini@vision.unipv.it, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kumar.gala@freescale.com,
	linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757362AbXLJMJp@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Poonam Aggrwal <b10812@freescale.com>

This patch makes necessary changes in the QE and UCC framework to support 
TDM. It also adds support to configure the BRG properly through device 
tree entries. Includes the device tree changes for UCC TDM driver as well.
It also includes device tree entries for UCC TDM driver.

Tested on MPC8323ERDB platform.

Signed-off-by: Poonam Aggrwal <b10812@freescale.com>
Signed-off-by: Ashish Kalra <ashish.kalra@freescale.com>
Signed-off-by: Kim Phillips <Kim.Phillips@freescale.com>
Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
---
 arch/powerpc/boot/dts/mpc832x_rdb.dts |   58 +++++++
 arch/powerpc/sysdev/qe_lib/qe.c       |  128 ++++++++++++++--
 arch/powerpc/sysdev/qe_lib/ucc.c      |  265 +++++++++++++++++++++++++++++++++
 arch/powerpc/sysdev/qe_lib/ucc_fast.c |   37 +++++
 include/asm-powerpc/qe.h              |    8 +
 include/asm-powerpc/ucc.h             |    4 +
 include/asm-powerpc/ucc_fast.h        |    4 +
 7 files changed, 492 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/boot/dts/mpc832x_rdb.dts b/arch/powerpc/boot/dts/mpc832x_rdb.dts
index 388c8a7..333408c 100644
--- a/arch/powerpc/boot/dts/mpc832x_rdb.dts
+++ b/arch/powerpc/boot/dts/mpc832x_rdb.dts
@@ -105,6 +105,17 @@
 			device_type = "par_io";
 			num-ports = <7>;
 
+			ucc1pio:ucc_pin@01 {
+				pio-map = <
+			/* port  pin  dir  open_drain  assignment  has_irq */
+					0  e  2  0  1  0	/* CLK11 */
+					3 16  1  0  2  0	/* BRG9 */
+					3 1b  1  0  2  0	/* BRG3 */
+					0  0  3  0  2  0	/* TDMATxD0 */
+					0  4  3  0  2  0	/* TDMARxD0 */
+					3 1b  2  0  1  0>;	/* CLK1 */
+			};
+
 			ucc2pio:ucc_pin@02 {
 				pio-map = <
 			/* port  pin  dir  open_drain  assignment  has_irq */
@@ -169,6 +180,36 @@
 			};
 		};
 
+		clocks {
+			compatible = "fsl,cpm-clocks";
+			/* clock freqs in Hz(for CLK1~CLK24).
+			 * CLK11 is 1024KHz,
+			 * all other clocks unused
+			 * #clock-cells define number of cells
+			 * used by the clock-frequency.
+			 * right now only #clock cells=1 is
+			 * implemented. Provision is there to
+			 * handle frequencies >4Gig
+			 */
+			#clock-cells = <1>;
+			clock-frequency = <0 0 0 0 0 0
+					   0 0 0 0 d#1024000 0
+					   0 0 0 0 0 0
+					   0 0 0 0 0 0>;
+		};
+
+		brg@640 {
+			compatible = "fsl,cpm-brg";
+			/* input clock sources for all the 16 BRGs.
+			 * 1-24 for CLK1 to CLK24.
+			 * BRG9 uses CLK11,BRG1 and BRG2-8 use
+			 * the QE clock.
+			 */
+			fsl,brg-sources = <0 0 0 0 0 0 0 0
+					   b 0 0 0 0 0 0 0>;
+			reg = <640 7f>;
+		};
+
 		spi@4c0 {
 			device_type = "spi";
 			compatible = "fsl_spi";
@@ -187,6 +228,23 @@
 			mode = "cpu";
 		};
 
+		ucc@2000 {
+			device_type = "tdm";
+			compatible = "fsl,ucc-tdm";
+			model = "UCC";
+			device-id = <1>;
+			fsl,tdm-num = <1>;
+			fsl,si-num = <1>;
+			fsl,tdm-tx-clk = "CLK1";
+			fsl,tdm-rx-clk = "CLK1";
+			fsl,tdm-tx-sync = "BRG9";
+			fsl,tdm-rx-sync = "BRG9";
+			reg = <2000 200>;
+			interrupts = <20>;
+			interrupt-parent = <&qeic>;
+			pio-handle = <&ucc1pio>;
+		};
+
 		ucc@3000 {
 			device_type = "network";
 			compatible = "ucc_geth";
diff --git a/arch/powerpc/sysdev/qe_lib/qe.c b/arch/powerpc/sysdev/qe_lib/qe.c
index 1df3b4a..abcf0b4 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -149,22 +149,116 @@ EXPORT_SYMBOL(qe_issue_cmd);
  */
 static unsigned int brg_clk = 0;
 
-unsigned int get_brg_clk(void)
+u32 get_brg_clk(enum qe_clock brgclk, enum qe_clock *brg_source)
 {
-	struct device_node *qe;
-	if (brg_clk)
-		return brg_clk;
+	struct device_node *qe, *brg, *clocks;
+	enum qe_clock brg_src;
+	u32 brg_input_freq = 0;
+	u32 brg_num;
+	const unsigned int *prop;
 
-	qe = of_find_node_by_type(NULL, "qe");
-	if (qe) {
+	*brg_source = 0;
+
+	brg_num = brgclk - QE_BRG1;
+	brg = of_find_compatible_node(NULL, NULL, "fsl,cpm-brg");
+	if (brg) {
 		unsigned int size;
-		const u32 *prop = of_get_property(qe, "brg-frequency", &size);
-		brg_clk = *prop;
-		of_node_put(qe);
-	};
+		prop = of_get_property(brg,
+					"fsl,brg-sources", &size);
+
+		brg_src = *(prop + brg_num);
+		if (brg_src == 0) {
+			*brg_source = 0;
+			if (brg_clk > 0) {
+				of_node_put(brg);
+				return brg_clk;
+			}
+			qe = of_find_node_by_type(NULL, "qe");
+			if (qe) {
+				unsigned int size;
+				prop = of_get_property
+						(qe, "brg-frequency", &size);
+				of_node_put(qe);
+				of_node_put(brg);
+				return *prop;
+			}
+		} else {
+			*brg_source = brg_src + QE_CLK1 - 1;
+			clocks = of_find_compatible_node(NULL, NULL,
+							"fsl,cpm-clocks");
+			prop = of_get_property(clocks,
+						"#clock-cells", &size);
+			/*
+			 * clock-cells = 1 only supported right now.
+			 */
+			if (*prop != 1)
+				return 0;
+			prop = of_get_property(clocks,
+						"clock-frequency", &size);
+
+			brg_input_freq = *(prop+(brg_src - 1));
+			of_node_put(clocks);
+			of_node_put(brg);
+			return brg_input_freq;
+		}
+	}
 	return brg_clk;
 }
 
+u32 qe_brg_src(int brg_num, enum qe_clock brg_src)
+{
+	u32 clock_bits, shift;
+
+	clock_bits = 0;
+
+	switch (brg_num) {
+	case 1:
+	case 2:
+	case 5:
+	case 6:
+		switch (brg_src) {
+		case QE_CLK3:   clock_bits = 1; break;
+		case QE_CLK5:   clock_bits = 2; break;
+		default: break;
+		}
+		break;
+	case 3:
+	case 4:
+	case 7:
+	case 8:
+		switch (brg_src) {
+		case QE_CLK9:    clock_bits = 1; break;
+		case QE_CLK15:   clock_bits = 2; break;
+		default: break;
+		}
+		break;
+	case 9:
+	case 10:
+		switch (brg_src) {
+		case QE_CLK11:    clock_bits = 1; break;
+		default: break;
+		}
+		break;
+	case 11:
+	case 15:
+	case 16:
+		switch (brg_src) {
+		case QE_CLK13:    clock_bits = 1; break;
+		default: break;
+		}
+		break;
+	default: clock_bits = 0; break;
+	}
+	shift = 14;
+
+	if (!clock_bits)
+		return -ENOENT;
+
+	clock_bits <<= shift;
+
+	return clock_bits;
+}
+
 /* Program the BRG to the given sampling rate and multiplier
  *
  * @brg: the BRG, QE_BRG1 - QE_BRG16
@@ -177,11 +271,18 @@ int qe_setbrg(enum qe_clock brg, unsigned int rate, unsigned int multiplier)
 {
 	u32 divisor, tempval;
 	u32 div16 = 0;
+	u32 brg_clock;
+	enum qe_clock brgsrc;
+	u32 src_bits = 0;
 
 	if ((brg < QE_BRG1) || (brg > QE_BRG16))
 		return -EINVAL;
 
-	divisor = get_brg_clk() / (rate * multiplier);
+	brg_clock = get_brg_clk(brg, &brgsrc);
+	if (!brg_clock)
+		return -EINVAL;
+
+	divisor = brg_clock / (rate * multiplier);
 
 	if (divisor > QE_BRGC_DIVISOR_MAX + 1) {
 		div16 = QE_BRGC_DIV16;
@@ -194,8 +295,11 @@ int qe_setbrg(enum qe_clock brg, unsigned int rate, unsigned int multiplier)
 	if (!div16 && (divisor & 1))
 		divisor++;
 
+	if (brgsrc > 0)
+		src_bits = qe_brg_src(brg - QE_BRG1 + 1, brgsrc);
+
 	tempval = ((divisor - 1) << QE_BRGC_DIVISOR_SHIFT) |
-		QE_BRGC_ENABLE | div16;
+		QE_BRGC_ENABLE | div16 | src_bits;
 
 	out_be32(&qe_immr->brg.brgc[brg - QE_BRG1], tempval);
 
diff --git a/arch/powerpc/sysdev/qe_lib/ucc.c b/arch/powerpc/sysdev/qe_lib/ucc.c
index 0e348d9..f2de0ed 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc.c
+++ b/arch/powerpc/sysdev/qe_lib/ucc.c
@@ -213,3 +213,268 @@ int ucc_set_qe_mux_rxtx(unsigned int ucc_num, enum qe_clock clock,
 
 	return 0;
 }
+
+int ucc_set_tdm_rxtx_clk(int tdm_num, char *clk_src, enum comm_dir mode)
+{
+	enum qe_clock clock;
+	u32 clock_bits, shift;
+	struct qe_mux *qe_mux_reg = NULL;
+
+	clock_bits = 0;
+	qe_mux_reg = &qe_immr->qmx;
+
+	if ((tdm_num > 3 || tdm_num < 0))
+		return -EINVAL;
+
+	/* The communications direction must be RX or TX */
+	if (!((mode == COMM_DIR_RX) || (mode == COMM_DIR_TX)))
+		return -EINVAL;
+
+	clock = qe_clock_source(clk_src);
+	switch (mode) {
+	case COMM_DIR_RX:
+		switch (tdm_num) {
+		case 0:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK3:   clock_bits = 6; break;
+			case QE_CLK8:   clock_bits = 7; break;
+			default: break;
+			}
+			shift = 28;
+			break;
+		case 1:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK5:   clock_bits = 6; break;
+			case QE_CLK10:  clock_bits = 7; break;
+			default: break;
+			}
+			shift = 24;
+			break;
+		case 2:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK7:   clock_bits = 6; break;
+			case QE_CLK12:  clock_bits = 7; break;
+			default: break;
+			}
+			shift = 20;
+			break;
+		case 3:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK9:   clock_bits = 6; break;
+			case QE_CLK14:  clock_bits = 7; break;
+			default: break;
+			}
+			shift = 16;
+			break;
+		default:
+			break;
+		}
+		break;
+	case COMM_DIR_TX:
+		switch (tdm_num) {
+		case 0:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK4:   clock_bits = 6; break;
+			case QE_CLK9:   clock_bits = 7; break;
+			default: break;
+			}
+			shift = 12;
+			break;
+		case 1:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK6:   clock_bits = 6; break;
+			case QE_CLK11:  clock_bits = 7; break;
+			default: break;
+			}
+			shift = 8;
+			break;
+		case 2:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK8:   clock_bits = 6; break;
+			case QE_CLK13:  clock_bits = 7; break;
+			default: break;
+			}
+			shift = 4;
+			break;
+		case 3:
+			switch (clock) {
+			case QE_BRG3:   clock_bits = 1; break;
+			case QE_BRG4:   clock_bits = 2; break;
+			case QE_CLK1:   clock_bits = 4; break;
+			case QE_CLK2:   clock_bits = 5; break;
+			case QE_CLK10:  clock_bits = 6; break;
+			case QE_CLK15:  clock_bits = 7; break;
+			default: break;
+			}
+			shift = 0;
+			break;
+		default:
+			break;
+		}
+		break;
+	default:
+		break;
+	}
+
+	if (!clock_bits)
+		return -ENOENT;
+
+	clock_bits <<= shift;
+
+	qe_mux_reg->cmxsi1cr_l |= clock_bits;
+
+	return 0;
+}
+
+int ucc_set_tdm_rxtx_sync(int tdm_num, char *sync_src, enum comm_dir mode)
+{
+	enum qe_clock clock;
+	u32 shift, clock_bits;
+	struct qe_mux *qe_mux_reg = NULL;
+	int source;
+
+	source = -1;
+	qe_mux_reg = &qe_immr->qmx;
+
+	if ((tdm_num > 3 || tdm_num < 0))
+		return -EINVAL;
+
+	/* The communications direction must be RX or TX */
+	if (!((mode == COMM_DIR_RX) || (mode == COMM_DIR_TX)))
+		return -EINVAL;
+
+	switch (mode) {
+	case COMM_DIR_RX:
+		if (strcasecmp("RSYNC", sync_src) == 0) {
+			source = 0;
+			shift = 0;
+			break;
+		}
+		clock = qe_clock_source(sync_src);
+		switch (tdm_num) {
+		case 0:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG10:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 30;
+			break;
+		case 1:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG10:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 28;
+			break;
+		case 2:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG11:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 26;
+			break;
+		case 3:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG11:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 24;
+			break;
+		default:
+			source = -1;
+			break;
+		}
+		break;
+	case COMM_DIR_TX:
+		if (strcasecmp("TSYNC", sync_src) == 0) {
+			source = 0;
+			shift = 0;
+			break;
+		}
+		clock = qe_clock_source(sync_src);
+		switch (tdm_num) {
+		case 0:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG10:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 14;
+			break;
+		case 1:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG10:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 12;
+			break;
+		case 2:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG11:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 10;
+			break;
+		case 3:
+			switch (clock) {
+			case QE_BRG9:   source = 1; break;
+			case QE_BRG11:  source = 2; break;
+			default: source = -1; break;
+			}
+			shift = 8;
+			break;
+		default:
+			source = -1;
+			break;
+		}
+		break;
+	default:
+		source = -1;
+		break;
+	}
+
+	if (source == -1)
+		return -ENOENT;
+
+	clock_bits = (u32) source;
+	clock_bits <<= shift;
+
+
+	qe_mux_reg->cmxsi1syr  |= clock_bits;
+
+	return 0;
+}
diff --git a/arch/powerpc/sysdev/qe_lib/ucc_fast.c b/arch/powerpc/sysdev/qe_lib/ucc_fast.c
index 3223acb..9c8559f 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_fast.c
+++ b/arch/powerpc/sysdev/qe_lib/ucc_fast.c
@@ -327,6 +327,43 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, struct ucc_fast_private ** ucc
 			ucc_fast_free(uccf);
 			return -EINVAL;
 		}
+	} else {
+		/* TDM Rx clock routing */
+		if ((uf_info->tdm_rx_clk != NULL) &&
+			ucc_set_tdm_rxtx_clk(uf_info->ucc_num,
+				uf_info->tdm_rx_clk, COMM_DIR_RX)) {
+			printk(KERN_ERR "%s: illegal value for TDM RX clock",
+				__FUNCTION__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
+		/* TDM Tx clock routing */
+		if ((uf_info->tdm_tx_clk != NULL) &&
+			ucc_set_tdm_rxtx_clk(uf_info->ucc_num,
+				uf_info->tdm_tx_clk, COMM_DIR_TX)) {
+			printk(KERN_ERR "%s: illegal value for TDM TX clock",
+				__FUNCTION__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
+		/* TDM Rx sync routing */
+		if ((uf_info->tdm_rx_sync != NULL) &&
+			ucc_set_tdm_rxtx_sync(uf_info->ucc_num,
+				uf_info->tdm_rx_sync, COMM_DIR_RX)) {
+			printk(KERN_ERR "%s: illegal value for TDM RX"
+				"Frame sync", __FUNCTION__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
+		/* TDM Tx sync routing */
+		if ((uf_info->tdm_tx_sync != NULL) &&
+			ucc_set_tdm_rxtx_sync(uf_info->ucc_num,
+				uf_info->tdm_tx_sync, COMM_DIR_TX)) {
+			printk(KERN_ERR "%s: illegal value for TDM TX"
+					"Frame sync", __FUNCTION__);
+			ucc_fast_free(uccf);
+			return -EINVAL;
+		}
 	}
 
 	/* Set interrupt mask register at UCC level. */
diff --git a/include/asm-powerpc/qe.h b/include/asm-powerpc/qe.h
index bcf60be..51de236 100644
--- a/include/asm-powerpc/qe.h
+++ b/include/asm-powerpc/qe.h
@@ -497,6 +497,14 @@ struct ucc_slow_pram {
 #define UCC_GETH_UCCE_RXF1      0x00000002
 #define UCC_GETH_UCCE_RXF0      0x00000001
 
+/* Transparent UCC Event Register (UCCE) */
+#define UCC_TRANS_UCCE_GRA	0x0080
+#define UCC_TRANS_UCCE_TXE	0x0010
+#define UCC_TRANS_UCCE_RXF	0x0008
+#define UCC_TRANS_UCCE_BSY	0x0004
+#define UCC_TRANS_UCCE_TXB	0x0002
+#define UCC_TRANS_UCCE_RXB	0x0001
+
 /* UPSMR, when used as a UART */
 #define UCC_UART_UPSMR_FLC		0x8000
 #define UCC_UART_UPSMR_SL		0x4000
diff --git a/include/asm-powerpc/ucc.h b/include/asm-powerpc/ucc.h
index 46b09ba..153db97 100644
--- a/include/asm-powerpc/ucc.h
+++ b/include/asm-powerpc/ucc.h
@@ -42,6 +42,10 @@ int ucc_set_qe_mux_mii_mng(unsigned int ucc_num);
 int ucc_set_qe_mux_rxtx(unsigned int ucc_num, enum qe_clock clock,
 	enum comm_dir mode);
 
+int ucc_set_tdm_rxtx_clk(int tdm_num, char *clk_src, enum comm_dir mode);
+
+int ucc_set_tdm_rxtx_sync(int tdm_num, char *clk_src, enum comm_dir mode);
+
 int ucc_mux_set_grant_tsa_bkpt(unsigned int ucc_num, int set, u32 mask);
 
 /* QE MUX clock routing for UCC
diff --git a/include/asm-powerpc/ucc_fast.h b/include/asm-powerpc/ucc_fast.h
index f529f70..d267983 100644
--- a/include/asm-powerpc/ucc_fast.h
+++ b/include/asm-powerpc/ucc_fast.h
@@ -152,6 +152,10 @@ struct ucc_fast_info {
 	enum ucc_fast_rx_decoding_method renc;
 	enum ucc_fast_transparent_tcrc tcrc;
 	enum ucc_fast_sync_len synl;
+	char *tdm_rx_clk;
+	char *tdm_tx_clk;
+	char *tdm_rx_sync;
+	char *tdm_tx_sync;
 };
 
 struct ucc_fast_private {
-- 
1.5.2.4

