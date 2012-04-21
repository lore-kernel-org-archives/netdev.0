From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/9] pch_gbe: reprogram multicast address register on reset
Date: Sat, 21 Apr 2012 06:50:30 +0200
Message-ID: <8bcb30e119faeb2b2c0aa197fe5d90d1f80d7c1c.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60519 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab2DUEu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 00:50:57 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so10243872wgb.1
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:50:56 -0700 (PDT)
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takahiro Shimizu <tshimizu818@gmail.com>

The reset logic after a Rx FIFO overrun will clear the programmed
multicast addresses. This patch fixes the issue by reprogramming the
registers after the reset.

[ RC - Rebased Takahiro's changes and wrote a commit message
  explaining the changes. ]

Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   60 +++++++++++++++++++-
 1 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 6a9a63b..dc15e93 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -383,31 +383,85 @@ static void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
 }
 
 /**
+ * pch_gbe_mac_save_mac_addr_regs - Save MAC addresse registers
+ * @hw:		Pointer to the HW structure
+ * @addr:	Pointer to the MAC address
+ * @index:  MAC address array register
+ */
+static void
+pch_gbe_mac_save_mac_addr_regs(struct pch_gbe_hw *hw,
+			struct pch_gbe_regs_mac_adr *mac_adr, u32 index)
+{
+	mac_adr->high = ioread32(&hw->reg->mac_adr[index].high);
+	mac_adr->low = ioread32(&hw->reg->mac_adr[index].low);
+}
+
+/**
+ * pch_gbe_mac_store_mac_addr_regs - Store MAC addresse registers
+ * @hw:		Pointer to the HW structure
+ * @addr:	Pointer to the MAC address
+ * @index:  MAC address array register
+ */
+static void
+pch_gbe_mac_store_mac_addr_regs(struct pch_gbe_hw *hw,
+			struct pch_gbe_regs_mac_adr *mac_adr, u32 index)
+{
+	u32 adrmask;
+
+	adrmask = ioread32(&hw->reg->ADDR_MASK);
+	iowrite32((adrmask | (0x0001 << index)), &hw->reg->ADDR_MASK);
+	/* wait busy */
+	pch_gbe_wait_clr_bit(&hw->reg->ADDR_MASK, PCH_GBE_BUSY);
+	/* Set the MAC address to the MAC address xA/xB register */
+	iowrite32(mac_adr->high, &hw->reg->mac_adr[index].high);
+	iowrite32(mac_adr->low, &hw->reg->mac_adr[index].low);
+	iowrite32((adrmask & ~(0x0001 << index)), &hw->reg->ADDR_MASK);
+	/* wait busy */
+	pch_gbe_wait_clr_bit(&hw->reg->ADDR_MASK, PCH_GBE_BUSY);
+}
+
+#define MAC_ADDR_LIST_NUM 16
+/**
  * pch_gbe_mac_reset_hw - Reset hardware
  * @hw:	Pointer to the HW structure
  */
 static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 {
+	struct pch_gbe_regs_mac_adr mac_addr_list[MAC_ADDR_LIST_NUM];
+	int i;
+
 	/* Read the MAC address. and store to the private data */
 	pch_gbe_mac_read_mac_addr(hw);
+	/* Read other MAC addresses */
+	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
+		pch_gbe_mac_save_mac_addr_regs(hw, &mac_addr_list[i], i);
 	iowrite32(PCH_GBE_ALL_RST, &hw->reg->RESET);
 #ifdef PCH_GBE_MAC_IFOP_RGMII
 	iowrite32(PCH_GBE_MODE_GMII_ETHER, &hw->reg->MODE);
 #endif
 	pch_gbe_wait_clr_bit(&hw->reg->RESET, PCH_GBE_ALL_RST);
-	/* Setup the receive address */
+	/* Setup the receive addresses */
 	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
+	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
+		pch_gbe_mac_store_mac_addr_regs(hw, &mac_addr_list[i], i);
 	return;
 }
 
 static void pch_gbe_mac_reset_rx(struct pch_gbe_hw *hw)
 {
-	/* Read the MAC address. and store to the private data */
+	struct pch_gbe_regs_mac_adr mac_addr_list[MAC_ADDR_LIST_NUM];
+	int i;
+
+	/* Read the MAC addresses. and store to the private data */
 	pch_gbe_mac_read_mac_addr(hw);
+	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
+		pch_gbe_mac_save_mac_addr_regs(hw, &mac_addr_list[i], i);
 	iowrite32(PCH_GBE_RX_RST, &hw->reg->RESET);
 	pch_gbe_wait_clr_bit_irq(&hw->reg->RESET, PCH_GBE_RX_RST);
-	/* Setup the MAC address */
+	/* Setup the MAC addresses */
 	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
+	for (i = 1; i < MAC_ADDR_LIST_NUM; i++)
+		pch_gbe_mac_store_mac_addr_regs(hw, &mac_addr_list[i], i);
 	return;
 }
 
-- 
1.7.2.5
