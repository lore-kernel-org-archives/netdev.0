From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 13/18] liquidio: CN23XX IQ access
Date: Sun, 21 Aug 2016 17:12:40 -0700
Message-ID: <1471824765-26473-14-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bn3nam01on0057.outbound.protection.outlook.com ([104.47.33.57]:45888
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753360AbcHVAaE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:30:04 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
index 335d0eb..c2fc4dc 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -910,6 +910,67 @@ static void cn23xx_reinit_regs(struct octeon_device *oct)
 	}
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
@@ -1087,6 +1148,11 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 	oct->fn_list.soft_reset = cn23xx_pf_soft_reset;
 	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
 	oct->fn_list.reinit_regs = cn23xx_reinit_regs;
+	oct->fn_list.update_iq_read_idx = cn23xx_update_read_index;
+
+	oct->fn_list.bar1_idx_setup = cn23xx_bar1_idx_setup;
+	oct->fn_list.bar1_idx_write = cn23xx_bar1_idx_write;
+	oct->fn_list.bar1_idx_read = cn23xx_bar1_idx_read;
 
 	oct->fn_list.enable_interrupt = cn23xx_enable_pf_interrupt;
 	oct->fn_list.disable_interrupt = cn23xx_disable_pf_interrupt;
-- 
1.8.3.1
