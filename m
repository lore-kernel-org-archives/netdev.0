From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 09/18] liquidio: MSIX support for CN23XX
Date: Sun, 21 Aug 2016 17:12:36 -0700
Message-ID: <1471824765-26473-10-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bn3nam01on0082.outbound.protection.outlook.com ([104.47.33.82]:62277
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753959AbcHVA3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:29:16 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support msix interrupt for cn23xx device.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 174 ++++++++++++--
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  12 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |   4 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 255 +++++++++++++++++----
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  39 ++++
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  31 ++-
 6 files changed, 449 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 1a72cc6..0603218 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -558,10 +558,16 @@ static void cn23xx_setup_iq_regs(struct octeon_device *oct, u32 iq_no)
 	 */
 	pkt_in_done = readq(iq->inst_cnt_reg);
 
-	/* Clear the count by writing back what we read, but don't
-	 * enable interrupts
-	 */
-	writeq(pkt_in_done, iq->inst_cnt_reg);
+	if (oct->msix_on) {
+		/* Set CINT_ENB to enable IQ interrupt   */
+		writeq((pkt_in_done | CN23XX_INTR_CINT_ENB),
+		       iq->inst_cnt_reg);
+	} else {
+		/* Clear the count by writing back what we read, but don't
+		 * enable interrupts
+		 */
+		writeq(pkt_in_done, iq->inst_cnt_reg);
+	}
 
 	iq->reset_instr_cnt = 0;
 }
@@ -570,6 +576,9 @@ static void cn23xx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
 {
 	u32 reg_val;
 	struct octeon_droq *droq = oct->droq[oq_no];
+	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+	u64 time_threshold;
+	u64 cnt_threshold;
 
 	oq_no += oct->sriov_info.pf_srn;
 
@@ -586,19 +595,31 @@ static void cn23xx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
 	droq->pkts_credit_reg =
 	    (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_OQ_PKTS_CREDIT(oq_no);
 
-	/* Enable this output queue to generate Packet Timer Interrupt
-	*/
-	reg_val = octeon_read_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no));
-	reg_val |= CN23XX_PKT_OUTPUT_CTL_TENB;
-	octeon_write_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no),
-			 reg_val);
+	if (!oct->msix_on) {
+		/* Enable this output queue to generate Packet Timer Interrupt
+		 */
+		reg_val =
+		    octeon_read_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no));
+		reg_val |= CN23XX_PKT_OUTPUT_CTL_TENB;
+		octeon_write_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no),
+				 reg_val);
 
-	/* Enable this output queue to generate Packet Count Interrupt
-	*/
-	reg_val = octeon_read_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no));
-	reg_val |= CN23XX_PKT_OUTPUT_CTL_CENB;
-	octeon_write_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no),
-			 reg_val);
+		/* Enable this output queue to generate Packet Count Interrupt
+		 */
+		reg_val =
+		    octeon_read_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no));
+		reg_val |= CN23XX_PKT_OUTPUT_CTL_CENB;
+		octeon_write_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(oq_no),
+				 reg_val);
+	} else {
+		time_threshold = cn23xx_pf_get_oq_ticks(
+		    oct, (u32)CFG_GET_OQ_INTR_TIME(cn23xx->conf));
+		cnt_threshold = (u32)CFG_GET_OQ_INTR_PKT(cn23xx->conf);
+
+		octeon_write_csr64(
+		    oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(oq_no),
+		    ((u64)(time_threshold << 32 | cnt_threshold)));
+	}
 }
 
 static void cn23xx_enable_io_queues(struct octeon_device *oct)
@@ -744,6 +765,85 @@ static void cn23xx_disable_io_queues(struct octeon_device *oct)
 	}
 }
 
+static u64 cn23xx_pf_msix_interrupt_handler(void *dev)
+{
+	struct octeon_ioq_vector *ioq_vector = (struct octeon_ioq_vector *)dev;
+	struct octeon_device *oct = ioq_vector->oct_dev;
+	u64 pkts_sent;
+	u64 ret = 0;
+	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
+
+	dev_dbg(&oct->pci_dev->dev, "In %s octeon_dev @ %p\n", __func__, oct);
+
+	if (!droq) {
+		dev_err(&oct->pci_dev->dev, "23XX bringup FIXME: oct pfnum:%d ioq_vector->ioq_num :%d droq is NULL\n",
+			oct->pf_num, ioq_vector->ioq_num);
+		return 0;
+	}
+
+	pkts_sent = readq(droq->pkts_sent_reg);
+
+	/* If our device has interrupted, then proceed. Also check
+	 * for all f's if interrupt was triggered on an error
+	 * and the PCI read fails.
+	 */
+	if (!pkts_sent || (pkts_sent == 0xFFFFFFFFFFFFFFFFULL))
+		return ret;
+
+	/* Write count reg in sli_pkt_cnts to clear these int.*/
+	if ((pkts_sent & CN23XX_INTR_PO_INT) ||
+	    (pkts_sent & CN23XX_INTR_PI_INT)) {
+		if (pkts_sent & CN23XX_INTR_PO_INT)
+			ret |= MSIX_PO_INT;
+	}
+
+	if (pkts_sent & CN23XX_INTR_PI_INT)
+		/* We will clear the count when we update the read_index. */
+		ret |= MSIX_PI_INT;
+
+	/* Never need to handle msix mbox intr for pf. They arrive on the last
+	 * msix
+	 */
+	return ret;
+}
+
+static void cn23xx_handle_pcie_error_intr(struct octeon_device *oct, u64 intr64)
+{
+	dev_err(&oct->pci_dev->dev, "OCTEON[%d]: Error Intr: 0x%016llx\n",
+		oct->octeon_id,
+		CVM_CAST64(intr64));
+}
+
+static irqreturn_t cn23xx_interrupt_handler(void *dev)
+{
+	struct octeon_device *oct = (struct octeon_device *)dev;
+	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+	u64 intr64;
+
+	dev_dbg(&oct->pci_dev->dev, "In %s octeon_dev @ %p\n", __func__, oct);
+	intr64 = readq(cn23xx->intr_sum_reg64);
+
+	oct->int_status = 0;
+
+	if (intr64 & CN23XX_INTR_ERR)
+		cn23xx_handle_pcie_error_intr(oct, intr64);
+
+	if (oct->msix_on != 1) {
+		if (intr64 & CN23XX_INTR_PKT_DATA)
+			oct->int_status |= OCT_DEV_INTR_PKT_DATA;
+	}
+
+	if (intr64 & (CN23XX_INTR_DMA0_FORCE))
+		oct->int_status |= OCT_DEV_INTR_DMA0_FORCE;
+	if (intr64 & (CN23XX_INTR_DMA1_FORCE))
+		oct->int_status |= OCT_DEV_INTR_DMA1_FORCE;
+
+	/* Clear the current interrupts */
+	writeq(intr64, cn23xx->intr_sum_reg64);
+
+	return IRQ_HANDLED;
+}
+
 static void cn23xx_reinit_regs(struct octeon_device *oct)
 {
 	u32 i;
@@ -766,7 +866,7 @@ static void cn23xx_reinit_regs(struct octeon_device *oct)
 
 	oct->fn_list.setup_device_regs(oct);
 
-	oct->fn_list.enable_interrupt(oct);
+	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
 
 	oct->fn_list.enable_io_queues(oct);
 
@@ -779,6 +879,37 @@ static void cn23xx_reinit_regs(struct octeon_device *oct)
 	}
 }
 
+static void cn23xx_enable_pf_interrupt(struct octeon_device *oct, u8 intr_flag)
+{
+	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+	u64 intr_val = 0;
+
+	/*  Divide the single write to multiple writes based on the flag. */
+	/* Enable Interrupt */
+	if (intr_flag == OCTEON_ALL_INTR) {
+		writeq(cn23xx->intr_mask64, cn23xx->intr_enb_reg64);
+	} else if (intr_flag & OCTEON_OUTPUT_INTR) {
+		intr_val = readq(cn23xx->intr_enb_reg64);
+		intr_val |= CN23XX_INTR_PKT_DATA;
+		writeq(intr_val, cn23xx->intr_enb_reg64);
+	}
+}
+
+static void cn23xx_disable_pf_interrupt(struct octeon_device *oct, u8 intr_flag)
+{
+	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+	u64 intr_val = 0;
+
+	/* Disable Interrupts */
+	if (intr_flag == OCTEON_ALL_INTR) {
+		writeq(0, cn23xx->intr_enb_reg64);
+	} else if (intr_flag & OCTEON_OUTPUT_INTR) {
+		intr_val = readq(cn23xx->intr_enb_reg64);
+		intr_val &= ~CN23XX_INTR_PKT_DATA;
+		writeq(intr_val, cn23xx->intr_enb_reg64);
+	}
+}
+
 static void cn23xx_get_pcie_qlmport(struct octeon_device *oct)
 {
 	oct->pcie_port = (octeon_read_csr(oct, CN23XX_SLI_MAC_NUMBER)) & 0xff;
@@ -833,7 +964,8 @@ static void cn23xx_setup_reg_address(struct octeon_device *oct)
 	cn23xx_get_pcie_qlmport(oct);
 
 	cn23xx->intr_mask64 = CN23XX_INTR_MASK;
-	cn23xx->intr_mask64 |= CN23XX_INTR_PKT_TIME;
+	if (!oct->msix_on)
+		cn23xx->intr_mask64 |= CN23XX_INTR_PKT_TIME;
 	if (oct->rev_id >= OCTEON_CN23XX_REV_1_1)
 		cn23xx->intr_mask64 |= CN23XX_INTR_VF_MBOX;
 
@@ -918,9 +1050,15 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 
 	oct->fn_list.setup_iq_regs = cn23xx_setup_iq_regs;
 	oct->fn_list.setup_oq_regs = cn23xx_setup_oq_regs;
+	oct->fn_list.process_interrupt_regs = cn23xx_interrupt_handler;
+	oct->fn_list.msix_interrupt_handler = cn23xx_pf_msix_interrupt_handler;
+
 	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
 	oct->fn_list.reinit_regs = cn23xx_reinit_regs;
 
+	oct->fn_list.enable_interrupt = cn23xx_enable_pf_interrupt;
+	oct->fn_list.disable_interrupt = cn23xx_disable_pf_interrupt;
+
 	oct->fn_list.enable_io_queues = cn23xx_enable_io_queues;
 	oct->fn_list.disable_io_queues = cn23xx_disable_io_queues;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index c03d370..60c910b 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -436,7 +436,7 @@ void lio_cn6xxx_reinit_regs(struct octeon_device *oct)
 
 	oct->fn_list.setup_device_regs(oct);
 
-	oct->fn_list.enable_interrupt(oct->chip);
+	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
 
 	oct->fn_list.enable_io_queues(oct);
 
@@ -507,18 +507,20 @@ lio_cn6xxx_update_read_index(struct octeon_instr_queue *iq)
 	return new_idx;
 }
 
-void lio_cn6xxx_enable_interrupt(void *chip)
+void lio_cn6xxx_enable_interrupt(struct octeon_device *oct,
+				 u8 unused __attribute__((unused)))
 {
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	u64 mask = cn6xxx->intr_mask64 | CN6XXX_INTR_DMA0_FORCE;
 
 	/* Enable Interrupt */
 	writeq(mask, cn6xxx->intr_enb_reg64);
 }
 
-void lio_cn6xxx_disable_interrupt(void *chip)
+void lio_cn6xxx_disable_interrupt(struct octeon_device *oct,
+				  u8 unused __attribute__((unused)))
 {
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 
 	/* Disable Interrupts */
 	writeq(0, cn6xxx->intr_enb_reg64);
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
index 28c4722..e6e15ba 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -90,8 +90,8 @@ void lio_cn6xxx_bar1_idx_write(struct octeon_device *oct, u32 idx, u32 mask);
 u32 lio_cn6xxx_bar1_idx_read(struct octeon_device *oct, u32 idx);
 u32
 lio_cn6xxx_update_read_index(struct octeon_instr_queue *iq);
-void lio_cn6xxx_enable_interrupt(void *chip);
-void lio_cn6xxx_disable_interrupt(void *chip);
+void lio_cn6xxx_enable_interrupt(struct octeon_device *oct, u8 unused);
+void lio_cn6xxx_disable_interrupt(struct octeon_device *oct, u8 unused);
 void cn6xxx_get_pcie_qlmport(struct octeon_device *oct);
 void lio_cn6xxx_setup_reg_address(struct octeon_device *oct, void *chip,
 				  struct octeon_reg_list *reg_list);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 6879799..82b5ebd 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -68,6 +68,8 @@ static int conf_type;
 module_param(conf_type, int, 0);
 MODULE_PARM_DESC(conf_type, "select octeon configuration 0 default 1 ovs");
 
+static int msix_enable = 1;
+
 static int ptp_enable = 1;
 
 /* Bit mask values for lio->ifstate */
@@ -195,6 +197,19 @@ static void octeon_droq_bh(unsigned long pdev)
 		reschedule |= octeon_droq_process_packets(oct, oct->droq[q_no],
 							  MAX_PACKET_BUDGET);
 		lio_enable_irq(oct->droq[q_no], NULL);
+
+		if (OCTEON_CN23XX_PF(oct) && msix_enable) {
+			/* set time and cnt interrupt thresholds for this DROQ
+			 * for NAPI
+			 */
+			int adjusted_q_no = q_no + oct->sriov_info.pf_srn;
+
+			octeon_write_csr64(
+			    oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(adjusted_q_no),
+			    0x5700000040ULL);
+			octeon_write_csr64(
+			    oct, CN23XX_SLI_OQ_PKTS_SENT(adjusted_q_no), 0);
+		}
 	}
 
 	if (reschedule)
@@ -347,7 +362,7 @@ static void stop_pci_io(struct octeon_device *oct)
 	pci_disable_device(oct->pci_dev);
 
 	/* Disable interrupts  */
-	oct->fn_list.disable_interrupt(oct->chip);
+	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
 
 	pcierror_quiesce_device(oct);
 
@@ -910,6 +925,27 @@ static void update_txq_status(struct octeon_device *oct, int iq_num)
 	}
 }
 
+static
+int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
+{
+	struct octeon_device *oct = droq->oct_dev;
+	struct octeon_device_priv *oct_priv =
+	    (struct octeon_device_priv *)oct->priv;
+
+	if (droq->ops.poll_mode) {
+		droq->ops.napi_fn(droq);
+	} else {
+		if (ret & MSIX_PO_INT) {
+			tasklet_schedule(&oct_priv->droq_tasklet);
+			return 1;
+		}
+		/* this will be flushed periodically by check iq db */
+		if (ret & MSIX_PI_INT)
+			return 0;
+	}
+	return 0;
+}
+
 /**
  * \brief Droq packet processor sceduler
  * @param oct octeon device
@@ -940,19 +976,36 @@ void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
 	}
 }
 
+static irqreturn_t
+liquidio_msix_intr_handler(int irq __attribute__((unused)), void *dev)
+{
+	u64 ret;
+	struct octeon_ioq_vector *ioq_vector = (struct octeon_ioq_vector *)dev;
+	struct octeon_device *oct = ioq_vector->oct_dev;
+	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
+
+	ret = oct->fn_list.msix_interrupt_handler(ioq_vector);
+
+	if ((ret & MSIX_PO_INT) || (ret & MSIX_PI_INT))
+		liquidio_schedule_msix_droq_pkt_handler(droq, ret);
+
+	return IRQ_HANDLED;
+}
+
 /**
  * \brief Interrupt handler for octeon
  * @param irq unused
  * @param dev octeon device
  */
 static
-irqreturn_t liquidio_intr_handler(int irq __attribute__((unused)), void *dev)
+irqreturn_t liquidio_legacy_intr_handler(int irq __attribute__((unused)),
+					 void *dev)
 {
 	struct octeon_device *oct = (struct octeon_device *)dev;
 	irqreturn_t ret;
 
 	/* Disable our interrupts for the duration of ISR */
-	oct->fn_list.disable_interrupt(oct->chip);
+	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
 
 	ret = oct->fn_list.process_interrupt_regs(oct);
 
@@ -961,7 +1014,7 @@ irqreturn_t liquidio_intr_handler(int irq __attribute__((unused)), void *dev)
 
 	/* Re-enable our interrupts  */
 	if (!(atomic_read(&oct->status) == OCT_DEV_IN_RESET))
-		oct->fn_list.enable_interrupt(oct->chip);
+		oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
 
 	return ret;
 }
@@ -975,24 +1028,108 @@ irqreturn_t liquidio_intr_handler(int irq __attribute__((unused)), void *dev)
 static int octeon_setup_interrupt(struct octeon_device *oct)
 {
 	int irqret, err;
+	struct msix_entry *msix_entries;
+	int i;
+	int num_ioq_vectors;
+
+	if (OCTEON_CN23XX_PF(oct) && msix_enable) {
+		oct->num_msix_irqs = oct->sriov_info.num_pf_rings;
+		/* one non ioq interrupt for handling sli_mac_pf_int_sum */
+		oct->num_msix_irqs += 1;
+
+		oct->msix_entries = kcalloc(
+		    oct->num_msix_irqs, sizeof(struct msix_entry), GFP_KERNEL);
+		if (!oct->msix_entries) {
+			/* dev_err(&oct->pci_dev->dev,
+			* "Memory Alloc failed...\n");
+			 * This is commenting due WARNING: Possible unnecessary
+			 * out of memory' message
+			 */
+			return 1;
+		}
+		msix_entries = (struct msix_entry *)oct->msix_entries;
+		/*Assumption is that pf msix vectors start from pf srn to pf to
+		 * trs and not from 0. if not change this code
+		 */
+		for (i = 0; i < oct->num_msix_irqs - 1; i++)
+			msix_entries[i].entry = oct->sriov_info.pf_srn + i;
+		msix_entries[oct->num_msix_irqs - 1].entry =
+		    oct->sriov_info.trs;
+
+		if (pci_enable_msix(oct->pci_dev, msix_entries,
+				    oct->num_msix_irqs)) {
+			dev_err(&oct->pci_dev->dev, "unable to Allocate MSI-X interrupts\n");
+			kfree(oct->msix_entries);
+			return 1;
+		}
+		dev_dbg(&oct->pci_dev->dev, "OCTEON: Enough MSI-X interrupts are allocated...\n");
+
+		num_ioq_vectors = oct->num_msix_irqs;
+
+		/** For PF, there is one non-ioq interrupt handler */
+		num_ioq_vectors -= 1;
+		irqret = request_irq(msix_entries[num_ioq_vectors].vector,
+				     liquidio_legacy_intr_handler, 0, "octeon",
+				     oct);
+		if (irqret) {
+			dev_err(&oct->pci_dev->dev,
+				"OCTEON: Request_irq failed for MSIX interrupt Error: %d\n",
+				irqret);
+			kfree(oct->msix_entries);
+			return 1;
+		}
 
-	err = pci_enable_msi(oct->pci_dev);
-	if (err)
-		dev_warn(&oct->pci_dev->dev, "Reverting to legacy interrupts. Error: %d\n",
-			 err);
-	else
-		oct->flags |= LIO_FLAG_MSI_ENABLED;
-
-	irqret = request_irq(oct->pci_dev->irq, liquidio_intr_handler,
-			     IRQF_SHARED, "octeon", oct);
-	if (irqret) {
-		if (oct->flags & LIO_FLAG_MSI_ENABLED)
-			pci_disable_msi(oct->pci_dev);
-		dev_err(&oct->pci_dev->dev, "Request IRQ failed with code: %d\n",
-			irqret);
-		return 1;
+		for (i = 0; i < num_ioq_vectors; i++) {
+			irqret = request_irq(msix_entries[i].vector,
+					     liquidio_msix_intr_handler, 0,
+					     "octeon", &oct->ioq_vector[i]);
+			if (irqret) {
+				dev_err(&oct->pci_dev->dev,
+					"OCTEON: Request_irq failed for MSIX interrupt Error: %d\n",
+					irqret);
+				/** Freeing the non-ioq irq vector here . */
+				free_irq(msix_entries[num_ioq_vectors].vector,
+					 oct);
+
+				while (i) {
+					i--;
+					free_irq(msix_entries[i].vector,
+						 &oct->ioq_vector[i]);
+					/** clearing affinity mask. */
+					irq_set_affinity_hint(
+						msix_entries[i].vector, NULL);
+				}
+				kfree(oct->msix_entries);
+				return 1;
+			}
+			oct->ioq_vector[i].vector = msix_entries[i].vector;
+			/* assign the cpu mask for this msix interrupt vector */
+			irq_set_affinity_hint(
+					msix_entries[i].vector,
+					(&oct->ioq_vector[i].affinity_mask));
+		}
+		oct->msix_on = 1;
+		dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: MSI-X enabled\n",
+			oct->octeon_id);
+	} else {
+		err = pci_enable_msi(oct->pci_dev);
+		if (err)
+			dev_warn(&oct->pci_dev->dev, "Reverting to legacy interrupts. Error: %d\n",
+				 err);
+		else
+			oct->flags |= LIO_FLAG_MSI_ENABLED;
+
+		irqret = request_irq(oct->pci_dev->irq,
+				     liquidio_legacy_intr_handler, IRQF_SHARED,
+				     "octeon", oct);
+		if (irqret) {
+			if (oct->flags & LIO_FLAG_MSI_ENABLED)
+				pci_disable_msi(oct->pci_dev);
+			dev_err(&oct->pci_dev->dev, "Request IRQ failed with code: %d\n",
+				irqret);
+			return 1;
+		}
 	}
-
 	return 0;
 }
 
@@ -1015,6 +1152,9 @@ liquidio_probe(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
+	if (pdev->device == OCTEON_CN23XX_PF_VID)
+		oct_dev->msix_on = msix_enable;
+
 	dev_info(&pdev->dev, "Initializing device %x:%x.\n",
 		 (u32)pdev->vendor, (u32)pdev->device);
 
@@ -1054,6 +1194,7 @@ liquidio_probe(struct pci_dev *pdev,
 static void octeon_destroy_resources(struct octeon_device *oct)
 {
 	int i;
+	struct msix_entry *msix_entries;
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)oct->priv;
 
@@ -1098,15 +1239,34 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 			dev_err(&oct->pci_dev->dev, "OQ had pending packets\n");
 
 		/* Disable interrupts  */
-		oct->fn_list.disable_interrupt(oct->chip);
+		oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
+
+		if (oct->msix_on) {
+			msix_entries = (struct msix_entry *)oct->msix_entries;
+			for (i = 0; i < oct->num_msix_irqs - 1; i++) {
+				/* clear the affinity_cpumask */
+				irq_set_affinity_hint(msix_entries[i].vector,
+						      NULL);
+				free_irq(msix_entries[i].vector,
+					 &oct->ioq_vector[i]);
+			}
+			/* non-iov vector's argument is oct struct */
+			free_irq(msix_entries[i].vector, oct);
 
-		/* Release the interrupt line */
-		free_irq(oct->pci_dev->irq, oct);
+			pci_disable_msix(oct->pci_dev);
+			kfree(oct->msix_entries);
+			oct->msix_entries = NULL;
+		} else {
+			/* Release the interrupt line */
+			free_irq(oct->pci_dev->irq, oct);
 
-		if (oct->flags & LIO_FLAG_MSI_ENABLED)
-			pci_disable_msi(oct->pci_dev);
+			if (oct->flags & LIO_FLAG_MSI_ENABLED)
+				pci_disable_msi(oct->pci_dev);
+		}
 
-		/* fallthrough */
+		if (OCTEON_CN23XX_PF(oct))
+			octeon_free_ioq_vector(oct);
+	/* fallthrough */
 	case OCT_DEV_IN_RESET:
 	case OCT_DEV_DROQ_INIT_DONE:
 		/*atomic_set(&oct->status, OCT_DEV_DROQ_INIT_DONE);*/
@@ -2194,7 +2354,12 @@ static int liquidio_open(struct net_device *netdev)
 
 	ifstate_set(lio, LIO_IFSTATE_RUNNING);
 
-	setup_tx_poll_fn(netdev);
+	if (OCTEON_CN23XX_PF(oct)) {
+		if (!oct->msix_on)
+			setup_tx_poll_fn(netdev);
+	} else {
+		setup_tx_poll_fn(netdev);
+	}
 
 	start_txq(netdev);
 
@@ -2240,7 +2405,12 @@ static int liquidio_stop(struct net_device *netdev)
 	/* Now it should be safe to tell Octeon that nic interface is down. */
 	send_rx_ctrl_cmd(lio, 0);
 
-	cleanup_tx_poll_fn(netdev);
+	if (OCTEON_CN23XX_PF(oct)) {
+		if (!oct->msix_on)
+			cleanup_tx_poll_fn(netdev);
+	} else {
+		cleanup_tx_poll_fn(netdev);
+	}
 
 	if (lio->ptp_clock) {
 		ptp_clock_unregister(lio->ptp_clock);
@@ -2252,7 +2422,6 @@ static int liquidio_stop(struct net_device *netdev)
 	return 0;
 }
 
-
 /**
  * \brief Converts a mask based on net device flags
  * @param netdev network device
@@ -3740,15 +3909,23 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	atomic_set(&octeon_dev->status, OCT_DEV_DROQ_INIT_DONE);
 
-	/* The input and output queue registers were setup earlier (the queues
-	 * were not enabled). Any additional registers that need to be
-	 * programmed should be done now.
-	 */
-	ret = octeon_dev->fn_list.setup_device_regs(octeon_dev);
-	if (ret) {
-		dev_err(&octeon_dev->pci_dev->dev,
-			"Failed to configure device registers\n");
-		return ret;
+	if (OCTEON_CN23XX_PF(octeon_dev)) {
+		if (octeon_allocate_ioq_vector(octeon_dev)) {
+			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: ioq vector allocation failed\n");
+			return 1;
+		}
+
+	} else {
+		/* The input and output queue registers were setup earlier (the
+		 * queues were not enabled). Any additional registers
+		 * that need to be programmed should be done now.
+		 */
+		ret = octeon_dev->fn_list.setup_device_regs(octeon_dev);
+		if (ret) {
+			dev_err(&octeon_dev->pci_dev->dev,
+				"Failed to configure device registers\n");
+			return ret;
+		}
 	}
 
 	/* Initialize the tasklet that handles output queue packet processing.*/
@@ -3762,7 +3939,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		return 1;
 
 	/* Enable Octeon device interrupts */
-	octeon_dev->fn_list.enable_interrupt(octeon_dev->chip);
+	octeon_dev->fn_list.enable_interrupt(octeon_dev, OCTEON_ALL_INTR);
 
 	/* Enable the input and output queues for this Octeon device */
 	octeon_dev->fn_list.enable_io_queues(octeon_dev);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 120b78e..5252763 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -746,6 +746,45 @@ struct octeon_device *octeon_allocate_device(u32 pci_id,
 	return oct;
 }
 
+int
+octeon_allocate_ioq_vector(struct octeon_device  *oct)
+{
+	int i, num_ioqs = 0;
+	struct octeon_ioq_vector *ioq_vector;
+	int cpu_num;
+	int size;
+
+	if (OCTEON_CN23XX_PF(oct))
+		num_ioqs = oct->sriov_info.num_pf_rings;
+	size = sizeof(struct octeon_ioq_vector) * num_ioqs;
+
+	oct->ioq_vector = vmalloc(size);
+	if (!oct->ioq_vector)
+		return 1;
+	memset(oct->ioq_vector, 0, size);
+	for (i = 0; i < num_ioqs; i++) {
+		ioq_vector		= &oct->ioq_vector[i];
+		ioq_vector->oct_dev	= oct;
+		ioq_vector->iq_index	= i;
+		ioq_vector->droq_index	= i;
+
+		cpu_num = i % num_online_cpus();
+		cpumask_set_cpu(cpu_num, &ioq_vector->affinity_mask);
+
+		if (oct->chip_id == OCTEON_CN23XX_PF_VID)
+			ioq_vector->ioq_num	= i + oct->sriov_info.pf_srn;
+		else
+			ioq_vector->ioq_num	= i;
+	}
+	return 0;
+}
+
+void
+octeon_free_ioq_vector(struct octeon_device *oct)
+{
+	vfree(oct->ioq_vector);
+}
+
 /* this function is only for setting up the first queue */
 int octeon_setup_instr_queues(struct octeon_device *oct)
 {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index a84ed82..8e28ff4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -52,6 +52,9 @@ enum octeon_pci_swap_mode {
 	OCTEON_PCI_32BIT_LW_SWAP = 3
 };
 
+#define  OCTEON_OUTPUT_INTR   (2)
+#define  OCTEON_ALL_INTR      0xff
+
 /*---------------   PCI BAR1 index registers -------------*/
 
 /* BAR1 Mask */
@@ -205,6 +208,7 @@ struct octeon_fn_list {
 	void (*setup_oq_regs)(struct octeon_device *, u32);
 
 	irqreturn_t (*process_interrupt_regs)(void *);
+	u64 (*msix_interrupt_handler)(void *);
 	int (*soft_reset)(struct octeon_device *);
 	int (*setup_device_regs)(struct octeon_device *);
 	void (*reinit_regs)(struct octeon_device *);
@@ -216,8 +220,8 @@ struct octeon_fn_list {
 	void (*enable_oq_pkt_time_intr)(struct octeon_device *, u32);
 	void (*disable_oq_pkt_time_intr)(struct octeon_device *, u32);
 
-	void (*enable_interrupt)(void *);
-	void (*disable_interrupt)(void *);
+	void (*enable_interrupt)(struct octeon_device *, u8);
+	void (*disable_interrupt)(struct octeon_device *, u8);
 
 	void (*enable_io_queues)(struct octeon_device *);
 	void (*disable_io_queues)(struct octeon_device *);
@@ -278,6 +282,9 @@ struct octdev_props {
 	struct net_device *netdev;
 };
 
+#define MSIX_PO_INT    0x1
+#define MSIX_PI_INT    0x2
+
 struct octeon_pf_vf_hs_word {
 #ifdef __LITTLE_ENDIAN_BITFIELD
 	/** PKIND value assigned for the DPI interface */
@@ -325,6 +332,15 @@ struct octeon_sriov_info {
 
 };
 
+struct octeon_ioq_vector {
+	struct octeon_device   *oct_dev;
+	int		        iq_index;
+	int		        droq_index;
+	int			vector;
+	struct cpumask		affinity_mask;
+	u32			ioq_num;
+};
+
 /** The Octeon device.
  *  Each Octeon device has this structure to represent all its
  *  components.
@@ -449,10 +465,19 @@ struct octeon_device {
 
 	void *priv;
 
+	int num_msix_irqs;
+
+	void *msix_entries;
+
 	struct octeon_sriov_info sriov_info;
 
 	struct octeon_pf_vf_hs_word pfvf_hsword;
 
+	int msix_on;
+
+	/** IOq information of it's corresponding MSI-X interrupt. */
+	struct octeon_ioq_vector    *ioq_vector;
+
 	int rx_pause;
 	int tx_pause;
 
@@ -720,6 +745,8 @@ void *oct_get_config_info(struct octeon_device *oct, u16 card_type);
  */
 struct octeon_config *octeon_get_conf(struct octeon_device *oct);
 
+void octeon_free_ioq_vector(struct octeon_device *oct);
+int octeon_allocate_ioq_vector(struct octeon_device  *oct);
 void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq);
 
 /* LiquidIO driver pivate flags */
-- 
1.8.3.1
