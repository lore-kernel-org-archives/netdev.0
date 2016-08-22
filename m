From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 07/18] liquidio: CN23XX register setup
Date: Sun, 21 Aug 2016 17:12:34 -0700
Message-ID: <1471824765-26473-8-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0069.outbound.protection.outlook.com ([104.47.33.69]:13911
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753857AbcHVA2t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:28:49 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for initializing cn23xx device registers
related to mac, input/output and pf global config.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 295 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  24 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   3 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  38 +++
 4 files changed, 352 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 0884538..a410adc 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -214,6 +214,36 @@ void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct)
 		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_PKT_CNT_INT)));
 }
 
+static void cn23xx_enable_error_reporting(struct octeon_device *oct)
+{
+	u32 regval;
+	u32 uncorrectable_err_mask, corrtable_err_status;
+
+	pci_read_config_dword(oct->pci_dev, CN23XX_CONFIG_PCIE_DEVCTL, &regval);
+	if (regval & 0x00040000) {
+		uncorrectable_err_mask = 0;
+		corrtable_err_status = 0;
+		pci_read_config_dword(oct->pci_dev,
+				      CN23XX_CONFIG_PCIE_UNCORRECT_ERR_MASK,
+				      &uncorrectable_err_mask);
+		pci_read_config_dword(oct->pci_dev,
+				      CN23XX_CONFIG_PCIE_CORRECT_ERR_STATUS,
+				      &corrtable_err_status);
+		dev_err(&oct->pci_dev->dev, "PCI-E Fatal error detected;\n"
+				 "\tdev_ctl_status_reg = 0x%08x\n"
+				 "\tuncorrectable_error_mask_reg = 0x%08x\n"
+				 "\tcorrectable_error_status_reg = 0x%08x\n",
+			    regval, uncorrectable_err_mask,
+			    corrtable_err_status);
+	}
+
+	regval |= 0xf; /* Enable Link error reporting */
+
+	dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: Enabling PCI-E error reporting..\n",
+		oct->octeon_id);
+	pci_write_config_dword(oct->pci_dev, CN23XX_CONFIG_PCIE_DEVCTL, regval);
+}
+
 static u32 cn23xx_coprocessor_clock(struct octeon_device *oct)
 {
 	/* Bits 29:24 of RST_BOOT[PNR_MUL] holds the ref.clock MULTIPLIER
@@ -224,6 +254,234 @@ static u32 cn23xx_coprocessor_clock(struct octeon_device *oct)
 	return (((lio_pci_readq(oct, CN23XX_RST_BOOT) >> 24) & 0x3f) * 50);
 }
 
+u32 cn23xx_pf_get_oq_ticks(struct octeon_device *oct, u32 time_intr_in_us)
+{
+	/* This gives the SLI clock per microsec */
+	u32 oqticks_per_us = cn23xx_coprocessor_clock(oct);
+
+	oct->pfvf_hsword.coproc_tics_per_us = oqticks_per_us;
+
+	/* core clock per us / oq ticks will be fractional. TO avoid that
+	 * we use the method below.
+	 */
+
+	/* This gives the clock cycles per millisecond */
+	oqticks_per_us *= 1000;
+
+	/* This gives the oq ticks (1024 core clock cycles) per millisecond */
+	oqticks_per_us /= 1024;
+
+	/* time_intr is in microseconds. The next 2 steps gives the oq ticks
+	 *  corressponding to time_intr.
+	 */
+	oqticks_per_us *= time_intr_in_us;
+	oqticks_per_us /= 1000;
+
+	return oqticks_per_us;
+}
+
+static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
+{
+	u64 reg_val = 0ULL;
+	u16 mac_no = oct->pcie_port;
+	u16 pf_num = oct->pf_num;
+
+	/* programming SRN and TRS for each MAC(0..3)  */
+
+	dev_dbg(&oct->pci_dev->dev, "%s:Using pcie port %d\n",
+		__func__, mac_no);
+	/* By default, mapping all 64 IOQs to  a single MACs */
+
+	reg_val =
+	    octeon_read_csr64(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num));
+
+	if (oct->rev_id == OCTEON_CN23XX_REV_1_1) {
+		/* setting SRN <6:0>  */
+		reg_val = pf_num * CN23XX_MAX_RINGS_PER_PF_PASS_1_1;
+	} else {
+		/* setting SRN <6:0>  */
+		reg_val = pf_num * CN23XX_MAX_RINGS_PER_PF;
+	}
+
+	/* setting TRS <23:16> */
+	reg_val = reg_val |
+		  (oct->sriov_info.trs << CN23XX_PKT_MAC_CTL_RINFO_TRS_BIT_POS);
+	/* write these settings to MAC register */
+	octeon_write_csr64(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num),
+			   reg_val);
+
+	dev_dbg(&oct->pci_dev->dev, "SLI_PKT_MAC(%d)_PF(%d)_RINFO : 0x%016llx\n",
+		mac_no, pf_num, (u64)octeon_read_csr64
+		(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num)));
+}
+
+static void cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
+{
+	u32 q_no, ern, srn;
+	u64 pf_num;
+	u64 intr_threshold = 0ULL, reg_val = 0ULL;
+	struct octeon_instr_queue *iq;
+	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+
+	pf_num = oct->pf_num;
+
+	srn = oct->sriov_info.pf_srn;
+	ern = srn + oct->sriov_info.num_pf_rings;
+
+	/** Set the MAC_NUM and PVF_NUM in IQ_PKT_CONTROL reg
+	* for all queues.Only PF can set these bits.
+	* bits 29:30 indicate the MAC num.
+	* bits 32:47 indicate the PVF num.
+	*/
+	for (q_no = 0; q_no < ern; q_no++) {
+		reg_val = oct->pcie_port << CN23XX_PKT_INPUT_CTL_MAC_NUM_POS;
+		reg_val |= pf_num << CN23XX_PKT_INPUT_CTL_PF_NUM_POS;
+
+		octeon_write_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+				   reg_val);
+	}
+
+	/* Select ES, RO, NS, RDSIZE,DPTR Fomat#0 for
+	 * pf queues
+	 */
+	for (q_no = srn; q_no < ern; q_no++) {
+		void __iomem *inst_cnt_reg;
+
+		iq = oct->instr_queue[q_no];
+		if (iq)
+			inst_cnt_reg = iq->inst_cnt_reg;
+		else
+			inst_cnt_reg = (u8 *)oct->mmio[0].hw_addr +
+				       CN23XX_SLI_IQ_INSTR_COUNT64(q_no);
+
+		reg_val =
+		    octeon_read_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+
+		reg_val |= CN23XX_PKT_INPUT_CTL_MASK;
+
+		octeon_write_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+				   reg_val);
+
+		/* Set WMARK level for triggering PI_INT */
+		/* intr_threshold = CN23XX_DEF_IQ_INTR_THRESHOLD & */
+		intr_threshold = CFG_GET_IQ_INTR_PKT(cn23xx->conf) &
+				 CN23XX_PKT_IN_DONE_WMARK_MASK;
+
+		writeq((readq(inst_cnt_reg) &
+			~(CN23XX_PKT_IN_DONE_WMARK_MASK <<
+			  CN23XX_PKT_IN_DONE_WMARK_BIT_POS)) |
+		       (intr_threshold << CN23XX_PKT_IN_DONE_WMARK_BIT_POS),
+		       inst_cnt_reg);
+	}
+}
+
+static void cn23xx_pf_setup_global_output_regs(struct octeon_device *oct)
+{
+	u32 reg_val;
+	u32 q_no, ern, srn;
+	u64 time_threshold;
+
+	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+
+	srn = oct->sriov_info.pf_srn;
+	ern = srn + oct->sriov_info.num_pf_rings;
+
+	if (CFG_GET_IS_SLI_BP_ON(cn23xx->conf)) {
+		octeon_write_csr64(oct, CN23XX_SLI_OQ_WMARK, 32);
+	} else {
+		/** Set Output queue watermark to 0 to disable backpressure */
+		octeon_write_csr64(oct, CN23XX_SLI_OQ_WMARK, 0);
+	}
+
+	for (q_no = srn; q_no < ern; q_no++) {
+		reg_val = octeon_read_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(q_no));
+
+		/* set IPTR & DPTR */
+		reg_val |=
+		    (CN23XX_PKT_OUTPUT_CTL_IPTR | CN23XX_PKT_OUTPUT_CTL_DPTR);
+
+		/* reset BMODE */
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_BMODE);
+
+		/* No Relaxed Ordering, No Snoop, 64-bit Byte swap
+		 * for Output Queue ScatterList
+		 * reset ROR_P, NSR_P
+		 */
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_ROR_P);
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_NSR_P);
+
+#ifdef __LITTLE_ENDIAN_BITFIELD
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_ES_P);
+#else
+		reg_val |= (CN23XX_PKT_OUTPUT_CTL_ES_P);
+#endif
+		/* No Relaxed Ordering, No Snoop, 64-bit Byte swap
+		 * for Output Queue Data
+		 * reset ROR, NSR
+		 */
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_ROR);
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_NSR);
+		/* set the ES bit */
+		reg_val |= (CN23XX_PKT_OUTPUT_CTL_ES);
+
+		/* write all the selected settings */
+		octeon_write_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(q_no), reg_val);
+
+		/* Enabling these interrupt in oct->fn_list.enable_interrupt()
+		 * routine which called after IOQ init.
+		 * Set up interrupt packet and time thresholds
+		 * for all the OQs
+		 */
+		time_threshold = cn23xx_pf_get_oq_ticks(
+		    oct, (u32)CFG_GET_OQ_INTR_TIME(cn23xx->conf));
+
+		octeon_write_csr64(oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(q_no),
+				   (CFG_GET_OQ_INTR_PKT(cn23xx->conf) |
+				    ((u64)time_threshold << 32)));
+	}
+
+	/** Setting the water mark level for pko back pressure **/
+	writeq(0x40, (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_OQ_WMARK);
+
+	/** Disabling setting OQs in reset when ring has no dorebells
+	  * enabling this will cause of head of line blocking
+	  */
+	/* Do it only for pass1.1. and pass1.2 */
+	if ((oct->rev_id == OCTEON_CN23XX_REV_1_0) ||
+	    (oct->rev_id == OCTEON_CN23XX_REV_1_1))
+		writeq(readq((u8 *)oct->mmio[0].hw_addr +
+				     CN23XX_SLI_GBL_CONTROL) | 0x2,
+		       (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_GBL_CONTROL);
+
+	/** Enable channel-level backpressure */
+	if (oct->pf_num)
+		writeq(0xffffffffffffffffULL,
+		       (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_OUT_BP_EN2_W1S);
+	else
+		writeq(0xffffffffffffffffULL,
+		       (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_OUT_BP_EN_W1S);
+}
+
+static int cn23xx_setup_pf_device_regs(struct octeon_device *oct)
+{
+	cn23xx_enable_error_reporting(oct);
+
+	/* program the MAC(0..3)_RINFO before setting up input/output regs */
+	cn23xx_setup_global_mac_regs(oct);
+
+	cn23xx_pf_setup_global_input_regs(oct);
+	cn23xx_pf_setup_global_output_regs(oct);
+
+	/* Default error timeout value should be 0x200000 to avoid host hang
+	 * when reads invalid register
+	 */
+	octeon_write_csr64(oct, CN23XX_SLI_WINDOW_CTL, 0x200000ULL);
+
+	/* set SLI_PKT_IN_JABBER to handle large VXLAN packets */
+	octeon_write_csr64(oct, CN23XX_SLI_PKT_IN_JABBER, CN23XX_INPUT_JABBER);
+	return 0;
+}
+
 static void cn23xx_setup_iq_regs(struct octeon_device *oct, u32 iq_no)
 {
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
@@ -294,6 +552,41 @@ static void cn23xx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
 			 reg_val);
 }
 
+static void cn23xx_reinit_regs(struct octeon_device *oct)
+{
+	u32 i;
+
+	/*TODO: Need to wait for QUITEbit to set if RST bit is set */
+	/* RST bit may set, if it receives an FLR or pkt error */
+	dev_dbg(&oct->pci_dev->dev, "-- %s =--\n", __func__);
+
+	for (i = 0; i < MAX_POSSIBLE_OCTEON_INSTR_QUEUES; i++) {
+		if (!(oct->io_qmask.iq & (1ULL << i)))
+			continue;
+		oct->fn_list.setup_iq_regs(oct, i);
+	}
+
+	for (i = 0; i < MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->io_qmask.oq & (1ULL << i)))
+			continue;
+		oct->fn_list.setup_oq_regs(oct, i);
+	}
+
+	oct->fn_list.setup_device_regs(oct);
+
+	oct->fn_list.enable_interrupt(oct);
+
+	oct->fn_list.enable_io_queues(oct);
+
+	/* for (i = 0; i < oct->num_oqs; i++) { */
+	for (i = 0; i < MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES; i++) {
+		if (!(oct->io_qmask.oq & (1ULL << i)))
+			continue;
+		writel(oct->droq[i]->max_count,
+		       oct->droq[i]->pkts_credit_reg);
+	}
+}
+
 static void cn23xx_get_pcie_qlmport(struct octeon_device *oct)
 {
 	oct->pcie_port = (octeon_read_csr(oct, CN23XX_SLI_MAC_NUMBER)) & 0xff;
@@ -433,6 +726,8 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 
 	oct->fn_list.setup_iq_regs = cn23xx_setup_iq_regs;
 	oct->fn_list.setup_oq_regs = cn23xx_setup_oq_regs;
+	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
+	oct->fn_list.reinit_regs = cn23xx_reinit_regs;
 
 	cn23xx_setup_reg_address(oct);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 93bd5d1..f24fa3b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3696,6 +3696,22 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	octeon_set_io_queues_off(octeon_dev);
 
+	if (OCTEON_CN23XX_PF(octeon_dev)) {
+		ret = octeon_dev->fn_list.setup_device_regs(octeon_dev);
+		if (ret) {
+			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: Failed to configure device registers\n");
+			return ret;
+		}
+	}
+
+	/* Initialize soft command buffer pool
+	 */
+	if (octeon_setup_sc_buffer_pool(octeon_dev)) {
+		dev_err(&octeon_dev->pci_dev->dev, "sc buffer pool allocation failed\n");
+		return 1;
+	}
+	atomic_set(&octeon_dev->status, OCT_DEV_SC_BUFF_POOL_INIT_DONE);
+
 	/*  Setup the data structures that manage this Octeon's Input queues. */
 	if (octeon_setup_instr_queues(octeon_dev)) {
 		dev_err(&octeon_dev->pci_dev->dev,
@@ -3707,14 +3723,6 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	}
 	atomic_set(&octeon_dev->status, OCT_DEV_INSTR_QUEUE_INIT_DONE);
 
-	/* Initialize soft command buffer pool
-	 */
-	if (octeon_setup_sc_buffer_pool(octeon_dev)) {
-		dev_err(&octeon_dev->pci_dev->dev, "sc buffer pool allocation failed\n");
-		return 1;
-	}
-	atomic_set(&octeon_dev->status, OCT_DEV_SC_BUFF_POOL_INIT_DONE);
-
 	/* Initialize lists to manage the requests of different types that
 	 * arrive from user & kernel applications for this octeon device.
 	 */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 79e1522..523f406 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -120,6 +120,9 @@
 #define CFG_GET_IQ_DB_MIN(cfg)                   ((cfg)->iq.db_min)
 #define CFG_GET_IQ_DB_TIMEOUT(cfg)               ((cfg)->iq.db_timeout)
 
+#define CFG_GET_IQ_INTR_PKT(cfg)                 ((cfg)->iq.iq_intr_pkt)
+#define CFG_SET_IQ_INTR_PKT(cfg, val)            (cfg)->iq.iq_intr_pkt = val
+
 #define CFG_GET_OQ_MAX_Q(cfg)                    ((cfg)->oq.max_oqs)
 #define CFG_GET_OQ_INFO_PTR(cfg)                 ((cfg)->oq.info_ptr)
 #define CFG_GET_OQ_PKTS_PER_INTR(cfg)            ((cfg)->oq.pkts_per_intr)
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index c1757ce..a84ed82 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -278,6 +278,42 @@ struct octdev_props {
 	struct net_device *netdev;
 };
 
+struct octeon_pf_vf_hs_word {
+#ifdef __LITTLE_ENDIAN_BITFIELD
+	/** PKIND value assigned for the DPI interface */
+	u64        pkind : 8;
+
+	/** OCTEON core clock multiplier   */
+	u64        core_tics_per_us : 16;
+
+	/** OCTEON coprocessor clock multiplier  */
+	u64        coproc_tics_per_us : 16;
+
+	/** app that currently running on OCTEON  */
+	u64        app_mode : 8;
+
+	/** RESERVED */
+	u64 reserved : 16;
+
+#else
+
+	/** RESERVED */
+	u64 reserved : 16;
+
+	/** app that currently running on OCTEON  */
+	u64        app_mode : 8;
+
+	/** OCTEON coprocessor clock multiplier  */
+	u64        coproc_tics_per_us : 16;
+
+	/** OCTEON core clock multiplier   */
+	u64        core_tics_per_us : 16;
+
+	/** PKIND value assigned for the DPI interface */
+	u64        pkind : 8;
+#endif
+};
+
 struct octeon_sriov_info {
 	/* Actual rings left for PF device */
 	u32	num_pf_rings;
@@ -415,6 +451,8 @@ struct octeon_device {
 
 	struct octeon_sriov_info sriov_info;
 
+	struct octeon_pf_vf_hs_word pfvf_hsword;
+
 	int rx_pause;
 	int tx_pause;
 
-- 
1.8.3.1
