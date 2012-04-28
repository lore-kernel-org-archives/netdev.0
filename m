From: roy.qing.li@gmail.com
Subject: [PATCH net-next] pch_gbe: reprogram multicast address register on reset
Date: Sat, 28 Apr 2012 13:53:41 +0800
Message-ID: <1335592421-31406-1-git-send-email-roy.qing.li@gmail.com>
Cc: richardcochran@gmail.com, tshimizu818@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:32784 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab2D1Fxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 01:53:54 -0400
Received: by dadz8 with SMTP id z8so1833590dad.10
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 22:53:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

The reset logic after a Rx FIFO overrun will clear the programmed
multicast addresses. This patch fixes the issue by reprogramming the
registers after the reset.

The commit eefc48b tried to fix this problem, but it introduces
unnecessary codes. In fact, all multicast addresses have been saved
in netdev->mc, So we can call pch_gbe_set_multi() directly after
reset_hw and reset_rx.

This commit kills 50+ line codes

Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   60 ++------------------
 1 files changed, 5 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 107f41a..c9c182b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -120,6 +120,7 @@ static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
 static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
 static void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg,
 			       int data);
+static void pch_gbe_set_multi(struct net_device *netdev);
 
 #ifdef CONFIG_PCH_PTP
 static struct sock_filter ptp_filter[] = {
@@ -391,58 +392,13 @@ static void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
 }
 
 /**
- * pch_gbe_mac_save_mac_addr_regs - Save MAC addresse registers
- * @hw:		Pointer to the HW structure
- * @addr:	Pointer to the MAC address
- * @index:  MAC address array register
- */
-static void
-pch_gbe_mac_save_mac_addr_regs(struct pch_gbe_hw *hw,
-			struct pch_gbe_regs_mac_adr *mac_adr, u32 index)
-{
-	mac_adr->high = ioread32(&hw->reg->mac_adr[index].high);
-	mac_adr->low = ioread32(&hw->reg->mac_adr[index].low);
-}
-
-/**
- * pch_gbe_mac_store_mac_addr_regs - Store MAC addresse registers
- * @hw:		Pointer to the HW structure
- * @addr:	Pointer to the MAC address
- * @index:  MAC address array register
- */
-static void
-pch_gbe_mac_store_mac_addr_regs(struct pch_gbe_hw *hw,
-			struct pch_gbe_regs_mac_adr *mac_adr, u32 index)
-{
-	u32 adrmask;
-
-	adrmask = ioread32(&hw->reg->ADDR_MASK);
-	iowrite32((adrmask | (0x0001 << index)), &hw->reg->ADDR_MASK);
-	/* wait busy */
-	pch_gbe_wait_clr_bit(&hw->reg->ADDR_MASK, PCH_GBE_BUSY);
-	/* Set the MAC address to the MAC address xA/xB register */
-	iowrite32(mac_adr->high, &hw->reg->mac_adr[index].high);
-	iowrite32(mac_adr->low, &hw->reg->mac_adr[index].low);
-	iowrite32((adrmask & ~(0x0001 << index)), &hw->reg->ADDR_MASK);
-	/* wait busy */
-	pch_gbe_wait_clr_bit(&hw->reg->ADDR_MASK, PCH_GBE_BUSY);
-}
-
-#define MAC_ADDR_LIST_NUM 16
-/**
  * pch_gbe_mac_reset_hw - Reset hardware
  * @hw:	Pointer to the HW structure
  */
 static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 {
-	struct pch_gbe_regs_mac_adr mac_addr_list[MAC_ADDR_LIST_NUM];
-	int i;
-
 	/* Read the MAC address. and store to the private data */
 	pch_gbe_mac_read_mac_addr(hw);
-	/* Read other MAC addresses */
-	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
-		pch_gbe_mac_save_mac_addr_regs(hw, &mac_addr_list[i], i);
 	iowrite32(PCH_GBE_ALL_RST, &hw->reg->RESET);
 #ifdef PCH_GBE_MAC_IFOP_RGMII
 	iowrite32(PCH_GBE_MODE_GMII_ETHER, &hw->reg->MODE);
@@ -450,26 +406,17 @@ static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 	pch_gbe_wait_clr_bit(&hw->reg->RESET, PCH_GBE_ALL_RST);
 	/* Setup the receive addresses */
 	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
-	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
-		pch_gbe_mac_store_mac_addr_regs(hw, &mac_addr_list[i], i);
 	return;
 }
 
 static void pch_gbe_mac_reset_rx(struct pch_gbe_hw *hw)
 {
-	struct pch_gbe_regs_mac_adr mac_addr_list[MAC_ADDR_LIST_NUM];
-	int i;
-
 	/* Read the MAC addresses. and store to the private data */
 	pch_gbe_mac_read_mac_addr(hw);
-	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
-		pch_gbe_mac_save_mac_addr_regs(hw, &mac_addr_list[i], i);
 	iowrite32(PCH_GBE_RX_RST, &hw->reg->RESET);
 	pch_gbe_wait_clr_bit_irq(&hw->reg->RESET, PCH_GBE_RX_RST);
 	/* Setup the MAC addresses */
 	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
-	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
-		pch_gbe_mac_store_mac_addr_regs(hw, &mac_addr_list[i], i);
 	return;
 }
 
@@ -836,6 +783,8 @@ void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter)
 void pch_gbe_reset(struct pch_gbe_adapter *adapter)
 {
 	pch_gbe_mac_reset_hw(&adapter->hw);
+	/* reprogram multicast address register after reset */
+	pch_gbe_set_multi(adapter->netdev);
 	/* Setup the receive address. */
 	pch_gbe_mac_init_rx_addrs(&adapter->hw, PCH_GBE_MAR_ENTRIES);
 	if (pch_gbe_hal_init_hw(&adapter->hw))
@@ -1398,6 +1347,8 @@ static void pch_gbe_stop_receive(struct pch_gbe_adapter *adapter)
 		/* Stop Receive */
 		pch_gbe_mac_reset_rx(hw);
 	}
+	/* reprogram multicast address register after reset */
+	pch_gbe_set_multi(adapter->netdev);
 }
 
 static void pch_gbe_start_receive(struct pch_gbe_hw *hw)
@@ -1980,7 +1931,6 @@ static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter)
 }
 
 
-static void pch_gbe_set_multi(struct net_device *netdev);
 /**
  * pch_gbe_up - Up GbE network device
  * @adapter:  Board private structure
-- 
1.7.1
