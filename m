From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] stmmac: Discard masked flags in interrupt status register
Date: Fri, 27 Jan 2017 15:24:43 +0300
Message-ID: <1485519883-24969-1-git-send-email-abrodkin@synopsys.com>
Cc: linux-kernel@vger.kernel.org,
        Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Fabrice Gasnier <fabrice.gasnier@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Phil Reid <preid@electromag.com.au>,
        David Miller <davem@davemloft.net>,
        Alexandre Torgue <alexandre.torgue@gmail.com>,
        Vineet Gupta <Vineet.Gupta1@synopsys.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DW GMAC databook says the following about bits in "Register 15 (Interrupt
Mask Register)":
--------------------------->8-------------------------
When set, this bit __disables_the_assertion_of_the_interrupt_signal__
because of the setting of XXX bit in Register 14 (Interrupt
Status Register).
--------------------------->8-------------------------

In fact even if we mask one bit in the mask register it doesn't prevent
corresponding bit to appear in the status register, it only disables
interrupt generation for corresponding event.

But currently we expect a bit different behavior: status bits to be in
sync with their masks, i.e. if mask for bit A is set in the mask
register then bit A won't appear in the interrupt status register.

This was proven to be incorrect assumption, see discussion here [1].
That misunderstanding causes unexpected behaviour of the GMAC, for
example we were happy enough to just see bogus messages about link
state changes.

So from now on we'll be only checking bits that really may trigger an
interrupt.

[1] https://lkml.org/lkml/2016/11/3/413

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Fabrice Gasnier <fabrice.gasnier@st.com>
Cc: Joachim Eastwood <manabian@gmail.com>
Cc: Phil Reid <preid@electromag.com.au>
Cc: David Miller <davem@davemloft.net>
Cc: Alexandre Torgue <alexandre.torgue@gmail.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index be3c91c7f211..5484fd726d5a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -305,8 +305,12 @@ static int dwmac1000_irq_status(struct mac_device_info *hw,
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
+	u32 intr_mask = readl(ioaddr + GMAC_INT_MASK);
 	int ret = 0;
 
+	/* Discard masked bits */
+	intr_status &= ~intr_mask;
+
 	/* Not used events (e.g. MMC interrupts) are not handled. */
 	if ((intr_status & GMAC_INT_STATUS_MMCTIS))
 		x->mmc_tx_irq_n++;
-- 
2.7.4
