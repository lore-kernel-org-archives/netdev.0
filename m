From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next v2 02/10] fsl/fman: set HW parser as BMI next engine
Date: Thu, 9 Mar 2017 16:36:57 +0200
Message-ID: <1489070225-7891-3-git-send-email-madalin.bucur@nxp.com>
References: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@nxp.com>, linux-kernel@vger.kernel.org,
 camelia.groza@nxp.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
 dan.carpenter@oracle.com
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Enable the HW parser for all DPAA interfaces.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.c      | 21 ++++++++
 drivers/net/ethernet/freescale/fman/fman_port.c | 72 +++++++++++++++++++++++--
 2 files changed, 90 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index f60845f..d755930 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -59,6 +59,7 @@
 #define DMA_OFFSET		0x000C2000
 #define FPM_OFFSET		0x000C3000
 #define IMEM_OFFSET		0x000C4000
+#define HWP_OFFSET		0x000C7000
 #define CGP_OFFSET		0x000DB000
 
 /* Exceptions bit map */
@@ -218,6 +219,9 @@
 
 #define QMI_GS_HALT_NOT_BUSY		0x00000002
 
+/* HWP defines */
+#define HWP_RPIMAC_PEN			0x00000001
+
 /* IRAM defines */
 #define IRAM_IADD_AIE			0x80000000
 #define IRAM_READY			0x80000000
@@ -475,6 +479,12 @@ struct fman_dma_regs {
 	u32 res00e0[0x400 - 56];
 };
 
+struct fman_hwp_regs {
+	u32 res0000[0x844 / 4];		/* 0x000..0x843 */
+	u32 fmprrpimac;	/* FM Parser Internal memory access control */
+	u32 res[(0x1000 - 0x848) / 4];	/* 0x848..0xFFF */
+};
+
 /* Structure that holds current FMan state.
  * Used for saving run time information.
  */
@@ -606,6 +616,7 @@ struct fman {
 	struct fman_bmi_regs __iomem *bmi_regs;
 	struct fman_qmi_regs __iomem *qmi_regs;
 	struct fman_dma_regs __iomem *dma_regs;
+	struct fman_hwp_regs __iomem *hwp_regs;
 	fman_exceptions_cb *exception_cb;
 	fman_bus_error_cb *bus_error_cb;
 	/* Spinlock for FMan use */
@@ -999,6 +1010,12 @@ static void qmi_init(struct fman_qmi_regs __iomem *qmi_rg,
 	iowrite32be(tmp_reg, &qmi_rg->fmqm_ien);
 }
 
+static void hwp_init(struct fman_hwp_regs __iomem *hwp_rg)
+{
+	/* enable HW Parser */
+	iowrite32be(HWP_RPIMAC_PEN, &hwp_rg->fmprrpimac);
+}
+
 static int enable(struct fman *fman, struct fman_cfg *cfg)
 {
 	u32 cfg_reg = 0;
@@ -1793,6 +1810,7 @@ static int fman_config(struct fman *fman)
 	fman->bmi_regs = base_addr + BMI_OFFSET;
 	fman->qmi_regs = base_addr + QMI_OFFSET;
 	fman->dma_regs = base_addr + DMA_OFFSET;
+	fman->hwp_regs = base_addr + HWP_OFFSET;
 	fman->base_addr = base_addr;
 
 	spin_lock_init(&fman->spinlock);
@@ -2062,6 +2080,9 @@ static int fman_init(struct fman *fman)
 	/* Init QMI Registers */
 	qmi_init(fman->qmi_regs, fman->cfg);
 
+	/* Init HW Parser */
+	hwp_init(fman->hwp_regs);
+
 	err = enable(fman, cfg);
 	if (err != 0)
 		return err;
diff --git a/drivers/net/ethernet/freescale/fman/fman_port.c b/drivers/net/ethernet/freescale/fman/fman_port.c
index 9f3bb50..f314348 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.c
+++ b/drivers/net/ethernet/freescale/fman/fman_port.c
@@ -62,6 +62,7 @@
 
 #define BMI_PORT_REGS_OFFSET				0
 #define QMI_PORT_REGS_OFFSET				0x400
+#define HWP_PORT_REGS_OFFSET				0x800
 
 /* Default values */
 #define DFLT_PORT_BUFFER_PREFIX_CONTEXT_DATA_ALIGN		\
@@ -182,7 +183,7 @@
 #define NIA_ENG_BMI					0x00500000
 #define NIA_ENG_QMI_ENQ					0x00540000
 #define NIA_ENG_QMI_DEQ					0x00580000
-
+#define NIA_ENG_HWP					0x00440000
 #define NIA_BMI_AC_ENQ_FRAME				0x00000002
 #define NIA_BMI_AC_TX_RELEASE				0x000002C0
 #define NIA_BMI_AC_RELEASE				0x000000C0
@@ -317,6 +318,19 @@ struct fman_port_qmi_regs {
 	u32 fmqm_pndcc;		/* PortID n Dequeue Confirm Counter */
 };
 
+#define HWP_HXS_COUNT 16
+#define HWP_HXS_PHE_REPORT 0x00000800
+#define HWP_HXS_PCAC_PSTAT 0x00000100
+#define HWP_HXS_PCAC_PSTOP 0x00000001
+struct fman_port_hwp_regs {
+	struct {
+		u32 ssa; /* Soft Sequence Attachment */
+		u32 lcv; /* Line-up Enable Confirmation Mask */
+	} pmda[HWP_HXS_COUNT]; /* Parse Memory Direct Access Registers */
+	u32 reserved080[(0x3f8 - 0x080) / 4]; /* (0x080-0x3f7) */
+	u32 fmpr_pcac; /* Configuration Access Control */
+};
+
 /* QMI dequeue prefetch modes */
 enum fman_port_deq_prefetch {
 	FMAN_PORT_DEQ_NO_PREFETCH, /* No prefetch mode */
@@ -436,6 +450,7 @@ struct fman_port {
 
 	union fman_port_bmi_regs __iomem *bmi_regs;
 	struct fman_port_qmi_regs __iomem *qmi_regs;
+	struct fman_port_hwp_regs __iomem *hwp_regs;
 
 	struct fman_sp_buffer_offsets buffer_offsets;
 
@@ -521,9 +536,12 @@ static int init_bmi_rx(struct fman_port *port)
 	/* NIA */
 	tmp = (u32)cfg->rx_fd_bits << BMI_NEXT_ENG_FD_BITS_SHIFT;
 
-	tmp |= NIA_ENG_BMI | NIA_BMI_AC_ENQ_FRAME;
+	tmp |= NIA_ENG_HWP;
 	iowrite32be(tmp, &regs->fmbm_rfne);
 
+	/* Parser Next Engine NIA */
+	iowrite32be(NIA_ENG_BMI | NIA_BMI_AC_ENQ_FRAME, &regs->fmbm_rfpne);
+
 	/* Enqueue NIA */
 	iowrite32be(NIA_ENG_QMI_ENQ | NIA_ORDER_RESTOR, &regs->fmbm_rfene);
 
@@ -665,6 +683,50 @@ static int init_qmi(struct fman_port *port)
 	return 0;
 }
 
+static void stop_port_hwp(struct fman_port *port)
+{
+	struct fman_port_hwp_regs __iomem *regs = port->hwp_regs;
+	int cnt = 100;
+
+	iowrite32be(HWP_HXS_PCAC_PSTOP, &regs->fmpr_pcac);
+
+	while (cnt-- > 0 &&
+	       (ioread32be(&regs->fmpr_pcac) & HWP_HXS_PCAC_PSTAT))
+		udelay(10);
+	if (!cnt)
+		pr_err("Timeout stopping HW Parser\n");
+}
+
+static void start_port_hwp(struct fman_port *port)
+{
+	struct fman_port_hwp_regs __iomem *regs = port->hwp_regs;
+	int cnt = 100;
+
+	iowrite32be(0, &regs->fmpr_pcac);
+
+	while (cnt-- > 0 &&
+	       !(ioread32be(&regs->fmpr_pcac) & HWP_HXS_PCAC_PSTAT))
+		udelay(10);
+	if (!cnt)
+		pr_err("Timeout starting HW Parser\n");
+}
+
+static void init_hwp(struct fman_port *port)
+{
+	struct fman_port_hwp_regs __iomem *regs = port->hwp_regs;
+	int i;
+
+	stop_port_hwp(port);
+
+	for (i = 0; i < HWP_HXS_COUNT; i++) {
+		/* enable HXS error reporting into FD[STATUS] PHE */
+		iowrite32be(0x00000000, &regs->pmda[i].ssa);
+		iowrite32be(0xffffffff, &regs->pmda[i].lcv);
+	}
+
+	start_port_hwp(port);
+}
+
 static int init(struct fman_port *port)
 {
 	int err;
@@ -673,6 +735,8 @@ static int init(struct fman_port *port)
 	switch (port->port_type) {
 	case FMAN_PORT_TYPE_RX:
 		err = init_bmi_rx(port);
+		if (!err)
+			init_hwp(port);
 		break;
 	case FMAN_PORT_TYPE_TX:
 		err = init_bmi_tx(port);
@@ -686,7 +750,8 @@ static int init(struct fman_port *port)
 
 	/* Init QMI registers */
 	err = init_qmi(port);
-	return err;
+	if (err)
+		return err;
 
 	return 0;
 }
@@ -1276,6 +1341,7 @@ int fman_port_config(struct fman_port *port, struct fman_port_params *params)
 	/* set memory map pointers */
 	port->bmi_regs = base_addr + BMI_PORT_REGS_OFFSET;
 	port->qmi_regs = base_addr + QMI_PORT_REGS_OFFSET;
+	port->hwp_regs = base_addr + HWP_PORT_REGS_OFFSET;
 
 	port->max_frame_length = DFLT_PORT_MAX_FRAME_LENGTH;
 	/* resource distribution. */
-- 
2.1.0
