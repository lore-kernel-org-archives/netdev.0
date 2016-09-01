From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V5 3/8] liquidio: CN23XX IQ access
Date: Thu, 1 Sep 2016 11:16:06 -0700
Message-ID: <1472753771-21141-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1472753771-21141-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-sn1nam01on0080.outbound.protection.outlook.com ([104.47.32.80]:7152
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754217AbcIAVvL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:51:11 -0400
In-Reply-To: <1472753771-21141-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for Instruction Queue(IQ) index manipulation
routines through bar1 of cn23xx.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 66 ++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 2d81206..bddb198 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -887,6 +887,67 @@ static irqreturn_t cn23xx_interrupt_handler(void *dev)
 	return IRQ_HANDLED;
 }
 
+static void cn23xx_bar1_idx_setup(struct octeon_device *oct, u64 core_addr,
+				  u32 idx, int valid)
+{
+	u64 bar1;
+	u64 reg_adr;
+
+	if (!valid) {
+		reg_adr = lio_pci_readq(
+			oct, CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx));
+		WRITE_ONCE(bar1, reg_adr);
+		lio_pci_writeq(oct, (READ_ONCE(bar1) & 0xFFFFFFFEULL),
+			       CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx));
+		reg_adr = lio_pci_readq(
+			oct, CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx));
+		WRITE_ONCE(bar1, reg_adr);
+		return;
+	}
+
+	/*  The PEM(0..3)_BAR1_INDEX(0..15)[ADDR_IDX]<23:4> stores
+	 *  bits <41:22> of the Core Addr
+	 */
+	lio_pci_writeq(oct, (((core_addr >> 22) << 4) | PCI_BAR1_MASK),
+		       CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx));
+
+	WRITE_ONCE(bar1, lio_pci_readq(
+		   oct, CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx)));
+}
+
+static void cn23xx_bar1_idx_write(struct octeon_device *oct, u32 idx, u32 mask)
+{
+	lio_pci_writeq(oct, mask,
+		       CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx));
+}
+
+static u32 cn23xx_bar1_idx_read(struct octeon_device *oct, u32 idx)
+{
+	return (u32)lio_pci_readq(
+	    oct, CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx));
+}
+
+/* always call with lock held */
+static u32 cn23xx_update_read_index(struct octeon_instr_queue *iq)
+{
+	u32 new_idx;
+	u32 last_done;
+	u32 pkt_in_done = readl(iq->inst_cnt_reg);
+
+	last_done = pkt_in_done - iq->pkt_in_done;
+	iq->pkt_in_done = pkt_in_done;
+
+	/* Modulo of the new index with the IQ size will give us
+	 * the new index.  The iq->reset_instr_cnt is always zero for
+	 * cn23xx, so no extra adjustments are needed.
+	 */
+	new_idx = (iq->octeon_read_index +
+		   (u32)(last_done & CN23XX_PKT_IN_DONE_CNT_MASK)) %
+		  iq->max_count;
+
+	return new_idx;
+}
+
 static void cn23xx_enable_pf_interrupt(struct octeon_device *oct, u8 intr_flag)
 {
 	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
@@ -1063,6 +1124,11 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 
 	oct->fn_list.soft_reset = cn23xx_pf_soft_reset;
 	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
+	oct->fn_list.update_iq_read_idx = cn23xx_update_read_index;
+
+	oct->fn_list.bar1_idx_setup = cn23xx_bar1_idx_setup;
+	oct->fn_list.bar1_idx_write = cn23xx_bar1_idx_write;
+	oct->fn_list.bar1_idx_read = cn23xx_bar1_idx_read;
 
 	oct->fn_list.enable_interrupt = cn23xx_enable_pf_interrupt;
 	oct->fn_list.disable_interrupt = cn23xx_disable_pf_interrupt;
-- 
1.8.3.1
