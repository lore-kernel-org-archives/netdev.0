From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 5/9] liquidio CN23XX: VF register access
Date: Mon, 28 Nov 2016 00:50:34 -0800
Message-ID: <1480323038-13702-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480323038-13702-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0082.outbound.protection.outlook.com ([104.47.36.82]:36608
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751148AbcK1JF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 04:05:28 -0500
In-Reply-To: <1480323038-13702-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for VF device register access.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    | 189 +++++++++++++++++++++
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |   5 +
 3 files changed, 196 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
index 60fd138..ad4e442 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
@@ -76,6 +76,161 @@ static int cn23xx_vf_reset_io_queues(struct octeon_device *oct, u32 num_queues)
 	return ret_val;
 }
 
+static int cn23xx_vf_setup_global_input_regs(struct octeon_device *oct)
+{
+	struct octeon_cn23xx_vf *cn23xx = (struct octeon_cn23xx_vf *)oct->chip;
+	struct octeon_instr_queue *iq;
+	u64 q_no, intr_threshold;
+	u64 d64;
+
+	if (cn23xx_vf_reset_io_queues(oct, oct->sriov_info.rings_per_vf))
+		return -1;
+
+	for (q_no = 0; q_no < (oct->sriov_info.rings_per_vf); q_no++) {
+		void __iomem *inst_cnt_reg;
+
+		octeon_write_csr64(oct, CN23XX_VF_SLI_IQ_DOORBELL(q_no),
+				   0xFFFFFFFF);
+		iq = oct->instr_queue[q_no];
+
+		if (iq)
+			inst_cnt_reg = iq->inst_cnt_reg;
+		else
+			inst_cnt_reg = (u8 *)oct->mmio[0].hw_addr +
+				       CN23XX_VF_SLI_IQ_INSTR_COUNT64(q_no);
+
+		d64 = octeon_read_csr64(oct,
+					CN23XX_VF_SLI_IQ_INSTR_COUNT64(q_no));
+
+		d64 &= 0xEFFFFFFFFFFFFFFFL;
+
+		octeon_write_csr64(oct, CN23XX_VF_SLI_IQ_INSTR_COUNT64(q_no),
+				   d64);
+
+		/* Select ES, RO, NS, RDSIZE,DPTR Fomat#0 for
+		 * the Input Queues
+		 */
+		octeon_write_csr64(oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no),
+				   CN23XX_PKT_INPUT_CTL_MASK);
+
+		/* set the wmark level to trigger PI_INT */
+		intr_threshold = CFG_GET_IQ_INTR_PKT(cn23xx->conf) &
+				 CN23XX_PKT_IN_DONE_WMARK_MASK;
+
+		writeq((readq(inst_cnt_reg) &
+			~(CN23XX_PKT_IN_DONE_WMARK_MASK <<
+			  CN23XX_PKT_IN_DONE_WMARK_BIT_POS)) |
+		       (intr_threshold << CN23XX_PKT_IN_DONE_WMARK_BIT_POS),
+		       inst_cnt_reg);
+	}
+	return 0;
+}
+
+static void cn23xx_vf_setup_global_output_regs(struct octeon_device *oct)
+{
+	u32 reg_val;
+	u32 q_no;
+
+	for (q_no = 0; q_no < (oct->sriov_info.rings_per_vf); q_no++) {
+		octeon_write_csr(oct, CN23XX_VF_SLI_OQ_PKTS_CREDIT(q_no),
+				 0xFFFFFFFF);
+
+		reg_val =
+		    octeon_read_csr(oct, CN23XX_VF_SLI_OQ_PKTS_SENT(q_no));
+
+		reg_val &= 0xEFFFFFFFFFFFFFFFL;
+
+		reg_val =
+		    octeon_read_csr(oct, CN23XX_VF_SLI_OQ_PKT_CONTROL(q_no));
+
+		/* set IPTR & DPTR */
+		reg_val |=
+		    (CN23XX_PKT_OUTPUT_CTL_IPTR | CN23XX_PKT_OUTPUT_CTL_DPTR);
+
+		/* reset BMODE */
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_BMODE);
+
+		/* No Relaxed Ordering, No Snoop, 64-bit Byte swap
+		 * for Output Queue ScatterList reset ROR_P, NSR_P
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
+		 * for Output Queue Data reset ROR, NSR
+		 */
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_ROR);
+		reg_val &= ~(CN23XX_PKT_OUTPUT_CTL_NSR);
+		/* set the ES bit */
+		reg_val |= (CN23XX_PKT_OUTPUT_CTL_ES);
+
+		/* write all the selected settings */
+		octeon_write_csr(oct, CN23XX_VF_SLI_OQ_PKT_CONTROL(q_no),
+				 reg_val);
+	}
+}
+
+static int cn23xx_setup_vf_device_regs(struct octeon_device *oct)
+{
+	if (cn23xx_vf_setup_global_input_regs(oct))
+		return -1;
+
+	cn23xx_vf_setup_global_output_regs(oct);
+
+	return 0;
+}
+
+static void cn23xx_setup_vf_iq_regs(struct octeon_device *oct, u32 iq_no)
+{
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
+	u64 pkt_in_done;
+
+	/* Write the start of the input queue's ring and its size */
+	octeon_write_csr64(oct, CN23XX_VF_SLI_IQ_BASE_ADDR64(iq_no),
+			   iq->base_addr_dma);
+	octeon_write_csr(oct, CN23XX_VF_SLI_IQ_SIZE(iq_no), iq->max_count);
+
+	/* Remember the doorbell & instruction count register addr
+	 * for this queue
+	 */
+	iq->doorbell_reg =
+	    (u8 *)oct->mmio[0].hw_addr + CN23XX_VF_SLI_IQ_DOORBELL(iq_no);
+	iq->inst_cnt_reg =
+	    (u8 *)oct->mmio[0].hw_addr + CN23XX_VF_SLI_IQ_INSTR_COUNT64(iq_no);
+	dev_dbg(&oct->pci_dev->dev, "InstQ[%d]:dbell reg @ 0x%p instcnt_reg @ 0x%p\n",
+		iq_no, iq->doorbell_reg, iq->inst_cnt_reg);
+
+	/* Store the current instruction counter (used in flush_iq
+	 * calculation)
+	 */
+	pkt_in_done = readq(iq->inst_cnt_reg);
+
+	iq->reset_instr_cnt = 0;
+}
+
+static void cn23xx_setup_vf_oq_regs(struct octeon_device *oct, u32 oq_no)
+{
+	struct octeon_droq *droq = oct->droq[oq_no];
+
+	octeon_write_csr64(oct, CN23XX_VF_SLI_OQ_BASE_ADDR64(oq_no),
+			   droq->desc_ring_dma);
+	octeon_write_csr(oct, CN23XX_VF_SLI_OQ_SIZE(oq_no), droq->max_count);
+
+	octeon_write_csr(oct, CN23XX_VF_SLI_OQ_BUFF_INFO_SIZE(oq_no),
+			 (droq->buffer_size | (OCT_RH_SIZE << 16)));
+
+	/* Get the mapped address of the pkt_sent and pkts_credit regs */
+	droq->pkts_sent_reg =
+	    (u8 *)oct->mmio[0].hw_addr + CN23XX_VF_SLI_OQ_PKTS_SENT(oq_no);
+	droq->pkts_credit_reg =
+	    (u8 *)oct->mmio[0].hw_addr + CN23XX_VF_SLI_OQ_PKTS_CREDIT(oq_no);
+}
+
 static int cn23xx_enable_vf_io_queues(struct octeon_device *oct)
 {
 	u32 q_no;
@@ -181,8 +336,42 @@ int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
 		}
 	}
 
+	oct->fn_list.setup_iq_regs = cn23xx_setup_vf_iq_regs;
+	oct->fn_list.setup_oq_regs = cn23xx_setup_vf_oq_regs;
+	oct->fn_list.setup_device_regs = cn23xx_setup_vf_device_regs;
+
 	oct->fn_list.enable_io_queues = cn23xx_enable_vf_io_queues;
 	oct->fn_list.disable_io_queues = cn23xx_disable_vf_io_queues;
 
 	return 0;
 }
+
+void cn23xx_dump_vf_iq_regs(struct octeon_device *oct)
+{
+	u32 regval, q_no;
+
+	dev_dbg(&oct->pci_dev->dev, "SLI_IQ_DOORBELL_0 [0x%x]: 0x%016llx\n",
+		CN23XX_VF_SLI_IQ_DOORBELL(0),
+		CVM_CAST64(octeon_read_csr64(
+					oct, CN23XX_VF_SLI_IQ_DOORBELL(0))));
+
+	dev_dbg(&oct->pci_dev->dev, "SLI_IQ_BASEADDR_0 [0x%x]: 0x%016llx\n",
+		CN23XX_VF_SLI_IQ_BASE_ADDR64(0),
+		CVM_CAST64(octeon_read_csr64(
+			oct, CN23XX_VF_SLI_IQ_BASE_ADDR64(0))));
+
+	dev_dbg(&oct->pci_dev->dev, "SLI_IQ_FIFO_RSIZE_0 [0x%x]: 0x%016llx\n",
+		CN23XX_VF_SLI_IQ_SIZE(0),
+		CVM_CAST64(octeon_read_csr64(oct, CN23XX_VF_SLI_IQ_SIZE(0))));
+
+	for (q_no = 0; q_no < oct->sriov_info.rings_per_vf; q_no++) {
+		dev_dbg(&oct->pci_dev->dev, "SLI_PKT[%d]_INPUT_CTL [0x%x]: 0x%016llx\n",
+			q_no, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no),
+			CVM_CAST64(octeon_read_csr64(
+				oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no))));
+	}
+
+	pci_read_config_dword(oct->pci_dev, CN23XX_CONFIG_PCIE_DEVCTL, &regval);
+	dev_dbg(&oct->pci_dev->dev, "Config DevCtl [0x%x]: 0x%08x\n",
+		CN23XX_CONFIG_PCIE_DEVCTL, regval);
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
index 6785796..d17c1ce 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -35,4 +35,6 @@ struct octeon_cn23xx_vf {
 #define BUSY_READING_REG_VF_LOOP_COUNT		10000
 
 int cn23xx_setup_octeon_vf_device(struct octeon_device *oct);
+
+void cn23xx_dump_vf_initialized_regs(struct octeon_device *oct);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 41fc9d2..61c8b78 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -241,6 +241,11 @@ static int octeon_device_init(struct octeon_device *oct)
 		return 1;
 	}
 
+	if (oct->fn_list.setup_device_regs(oct)) {
+		dev_err(&oct->pci_dev->dev, "device registers configuration failed\n");
+		return 1;
+	}
+
 	return 0;
 }
 
-- 
1.8.3.1
