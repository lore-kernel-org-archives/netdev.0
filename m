From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 net-next 3/9] tg3: Reintroduce 5717_PLUS
Date: Tue, 5 Apr 2011 17:22:45 -0700
Message-ID: <1302049371-13799-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4651 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab1DFAQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 20:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reintroduces the TG3_FLG3_5717_PLUS to identify 5717 and
later devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   40 ++++++++++++++++------------------------
 drivers/net/tg3.h |    1 +
 2 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4f8976b..dc6b60b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1042,8 +1042,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	u32 reg;
 	struct phy_device *phydev;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 		u32 is_serdes;
 
 		tp->phy_addr = PCI_FUNC(tp->pdev->devfn) + 1;
@@ -1621,8 +1620,7 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 	u32 reg;
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-	    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	      GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) &&
+	    ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
 	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)))
 		return;
 
@@ -2045,8 +2043,7 @@ static int tg3_phy_reset(struct tg3 *tp)
 		}
 	}
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) &&
+	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
 	    (tp->phy_flags & TG3_PHYFLG_MII_SERDES))
 		return 0;
 
@@ -7671,8 +7668,7 @@ static void tg3_rings_reset(struct tg3 *tp)
 	/* Disable all transmit rings but the first. */
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 16;
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 4;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 2;
@@ -7686,8 +7682,7 @@ static void tg3_rings_reset(struct tg3 *tp)
 
 
 	/* Disable all receive return rings but the first. */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 17;
 	else if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 16;
@@ -8089,8 +8084,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	     ((u64) tpr->rx_std_mapping >> 32));
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tpr->rx_std_mapping & 0xffffffff));
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
+	if (!(tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
 		tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
 		     NIC_SRAM_RX_BUFFER_DESC);
 
@@ -10848,8 +10842,7 @@ static int tg3_test_memory(struct tg3 *tp)
 	int err = 0;
 	int i;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		mem_tbl = mem_tbl_5717;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		mem_tbl = mem_tbl_57765;
@@ -11930,8 +11923,7 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 			tg3_get_57780_nvram_info(tp);
-		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 			tg3_get_5717_nvram_info(tp);
 		else
 			tg3_get_nvram_info(tp);
@@ -13333,8 +13325,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->pdev_peer = tg3_find_peer(tp);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		tp->tg3_flags3 |= TG3_FLG3_5717_PLUS;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 ||
+	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
 		tp->tg3_flags3 |= TG3_FLG3_57765_PLUS;
 
 	/* Intentionally exclude ASIC_REV_5906 */
@@ -13427,8 +13422,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags3 |= TG3_FLG3_40BIT_DMA_LIMIT_BUG;
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		tp->tg3_flags3 |= TG3_FLG3_LRG_PROD_RING_CAP;
 
 	if ((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
@@ -13962,8 +13956,7 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 			tw32_f(NVRAM_CMD, NVRAM_CMD_RESET);
 		else
 			tg3_nvram_unlock(tp);
-	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-		   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+	} else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
 		if (PCI_FUNC(tp->pdev->devfn) & 1)
 			mac_offset = 0xcc;
 		if (PCI_FUNC(tp->pdev->devfn) > 1)
@@ -14760,8 +14753,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	}
 
 	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
+	    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
 		dev->netdev_ops = &tg3_netdev_ops;
 	else
 		dev->netdev_ops = &tg3_netdev_ops_dma_bug;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6f34db5..b8e6acc 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2917,6 +2917,7 @@ struct tg3 {
 #define TG3_FLG3_L1PLLPD_EN		0x00800000
 #define TG3_FLG3_57765_PLUS		0x01000000
 #define TG3_FLG3_APE_HAS_NCSI		0x02000000
+#define TG3_FLG3_5717_PLUS		0x04000000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.7.3.4


