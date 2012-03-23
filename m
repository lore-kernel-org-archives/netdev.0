From: Takahiro Shimizu <tshimizu818@gmail.com>
Subject: [PATCH] net/pch_gbe: Fixed the issue that the multicast address is lost when Rx FIFO overrun happened
Date: Fri, 23 Mar 2012 11:16:31 +0900
Message-ID: <1332468991-2614-1-git-send-email-tshimizu818@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Takahiro Shimizu <tshimizu818@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, richardcochran@gmail.com, arnd@arndb.de,
	khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   60 +++++++++++++++++++-
 1 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index d983e76..56089ca 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -382,31 +382,85 @@ static void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
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
1.7.4.4
