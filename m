From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH 3/3] pch_gbe: don't reset MAC_RX on FIFO overflow
Date: Mon, 22 Oct 2012 16:43:25 +0200
Message-ID: <1350917005-26350-4-git-send-email-vfalico@redhat.com>
References: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com, agospoda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755154Ab2JVOnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 10:43:41 -0400
In-Reply-To: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when FIFO_ERR happens, we stop the dma, wait for it to become
idle and then reset the whole MAC_RX logic (and after that we must re-set
multicast addresses and also re-enable MAC_RX when we're finally ready to
accept new packets). This leads to CRC errors on high number of incoming
packets and is not needed according to the datasheet.

This patch fixes it by the following steps:

1) remove this reset in pch_gbe_stop_receive(), which causes some functions
to not be used anywhere
2) remove already unused functions pch_gbe_wait_clr_bit_irq() and
pch_gbe_mac_reset_rx() to correctly build
3) move pch_gbe_enable_mac_rx() out of pch_gbe_start_receive() to
pch_gbe_up() where it's only needed after we've removed the MAC_RX reset
4) rename pch_gbe_start/stop_receive() to pch_gbe_enable/disable_dma_rx()
to more precisely reflect what the functions are now doing.

After these changes we already don't see the CRC errors and gain some
increase in RX processing speed.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   66 ++------------------
 1 files changed, 6 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 4ffad78..a8854d0 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -339,26 +339,6 @@ static void pch_gbe_wait_clr_bit(void *reg, u32 bit)
 }
 
 /**
- * pch_gbe_wait_clr_bit_irq - Wait to clear a bit for interrupt context
- * @reg:	Pointer of register
- * @busy:	Busy bit
- */
-static int pch_gbe_wait_clr_bit_irq(void *reg, u32 bit)
-{
-	u32 tmp;
-	int ret = -1;
-	/* wait busy */
-	tmp = 20;
-	while ((ioread32(reg) & bit) && --tmp)
-		udelay(5);
-	if (!tmp)
-		pr_err("Error: busy bit is not cleared\n");
-	else
-		ret = 0;
-	return ret;
-}
-
-/**
  * pch_gbe_mac_mar_set - Set MAC address register
  * @hw:	    Pointer to the HW structure
  * @addr:   Pointer to the MAC address
@@ -409,17 +389,6 @@ static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 	return;
 }
 
-static void pch_gbe_mac_reset_rx(struct pch_gbe_hw *hw)
-{
-	/* Read the MAC addresses. and store to the private data */
-	pch_gbe_mac_read_mac_addr(hw);
-	iowrite32(PCH_GBE_RX_RST, &hw->reg->RESET);
-	pch_gbe_wait_clr_bit_irq(&hw->reg->RESET, PCH_GBE_RX_RST);
-	/* Setup the MAC addresses */
-	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
-	return;
-}
-
 static void pch_gbe_disable_mac_rx(struct pch_gbe_hw *hw)
 {
 	u32 rctl;
@@ -1330,38 +1299,17 @@ void pch_gbe_update_stats(struct pch_gbe_adapter *adapter)
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 
-static void pch_gbe_stop_receive(struct pch_gbe_adapter *adapter)
+static void pch_gbe_disable_dma_rx(struct pch_gbe_hw *hw)
 {
-	struct pch_gbe_hw *hw = &adapter->hw;
 	u32 rxdma;
-	u16 value;
-	int ret;
 
 	/* Disable Receive DMA */
 	rxdma = ioread32(&hw->reg->DMA_CTRL);
 	rxdma &= ~PCH_GBE_RX_DMA_EN;
 	iowrite32(rxdma, &hw->reg->DMA_CTRL);
-	/* Wait Rx DMA BUS is IDLE */
-	ret = pch_gbe_wait_clr_bit_irq(&hw->reg->RX_DMA_ST, PCH_GBE_IDLE_CHECK);
-	if (ret) {
-		/* Disable Bus master */
-		pci_read_config_word(adapter->pdev, PCI_COMMAND, &value);
-		value &= ~PCI_COMMAND_MASTER;
-		pci_write_config_word(adapter->pdev, PCI_COMMAND, value);
-		/* Stop Receive */
-		pch_gbe_mac_reset_rx(hw);
-		/* Enable Bus master */
-		value |= PCI_COMMAND_MASTER;
-		pci_write_config_word(adapter->pdev, PCI_COMMAND, value);
-	} else {
-		/* Stop Receive */
-		pch_gbe_mac_reset_rx(hw);
-	}
-	/* reprogram multicast address register after reset */
-	pch_gbe_set_multi(adapter->netdev);
 }
 
-static void pch_gbe_start_receive(struct pch_gbe_hw *hw)
+static void pch_gbe_enable_dma_rx(struct pch_gbe_hw *hw)
 {
 	u32 rxdma;
 
@@ -1369,9 +1317,6 @@ static void pch_gbe_start_receive(struct pch_gbe_hw *hw)
 	rxdma = ioread32(&hw->reg->DMA_CTRL);
 	rxdma |= PCH_GBE_RX_DMA_EN;
 	iowrite32(rxdma, &hw->reg->DMA_CTRL);
-
-	pch_gbe_enable_mac_rx(hw);
-	return;
 }
 
 /**
@@ -1407,7 +1352,7 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 			int_en = ioread32(&hw->reg->INT_EN);
 			iowrite32((int_en & ~PCH_GBE_INT_RX_FIFO_ERR),
 				  &hw->reg->INT_EN);
-			pch_gbe_stop_receive(adapter);
+			pch_gbe_disable_dma_rx(&adapter->hw);
 			int_st |= ioread32(&hw->reg->INT_ST);
 			int_st = int_st & ioread32(&hw->reg->INT_EN);
 		}
@@ -2014,7 +1959,8 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	pch_gbe_alloc_tx_buffers(adapter, tx_ring);
 	pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
 	adapter->tx_queue_len = netdev->tx_queue_len;
-	pch_gbe_start_receive(&adapter->hw);
+	pch_gbe_enable_dma_rx(&adapter->hw);
+	pch_gbe_enable_mac_rx(&adapter->hw);
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
@@ -2440,7 +2386,7 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 
 	if (adapter->rx_stop_flag) {
 		adapter->rx_stop_flag = false;
-		pch_gbe_start_receive(&adapter->hw);
+		pch_gbe_enable_dma_rx(&adapter->hw);
 	}
 
 	pr_debug("poll_end_flag : %d  work_done : %d  budget : %d\n",
-- 
1.7.1
