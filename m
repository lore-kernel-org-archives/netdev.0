From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/20] tg3: Prevent a PCIe tx glitch
Date: Mon, 2 Nov 2009 16:25:06 -0800
Message-ID: <1257211994.21995@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3428 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756146AbZKCBdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prevents a PCIe tx glitch by allowing the transmitter to go
to a low power state.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   24 ++++++++++++++++++++++++
 drivers/net/tg3.h |   26 +++++++++++++++++++++++++-
 2 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1c53250..53a193e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6589,6 +6589,30 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_mdio_start(tp);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780) {
+		u8 phy_addr;
+
+		phy_addr = tp->phy_addr;
+		tp->phy_addr = TG3_PHY_PCIE_ADDR;
+
+		tg3_writephy(tp, TG3_PCIEPHY_BLOCK_ADDR,
+			     TG3_PCIEPHY_TXB_BLK << TG3_PCIEPHY_BLOCK_SHIFT);
+		val = TG3_PCIEPHY_TX0CTRL1_TXOCM | TG3_PCIEPHY_TX0CTRL1_RDCTL |
+		      TG3_PCIEPHY_TX0CTRL1_TXCMV | TG3_PCIEPHY_TX0CTRL1_TKSEL |
+		      TG3_PCIEPHY_TX0CTRL1_NB_EN;
+		tg3_writephy(tp, TG3_PCIEPHY_TX0CTRL1, val);
+		udelay(10);
+
+		tg3_writephy(tp, TG3_PCIEPHY_BLOCK_ADDR,
+			     TG3_PCIEPHY_XGXS_BLK1 << TG3_PCIEPHY_BLOCK_SHIFT);
+		val = TG3_PCIEPHY_PWRMGMT4_LOWPWR_EN |
+		      TG3_PCIEPHY_PWRMGMT4_L1PLLPD_EN;
+		tg3_writephy(tp, TG3_PCIEPHY_PWRMGMT4, val);
+		udelay(10);
+
+		tp->phy_addr = phy_addr;
+	}
+
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 40501cb..530c36b 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1953,10 +1953,34 @@
 #define  NIC_SRAM_MBUF_POOL_BASE5705	0x00010000
 #define  NIC_SRAM_MBUF_POOL_SIZE5705	0x0000e000
 
+
 /* Currently this is fixed. */
+#define TG3_PHY_PCIE_ADDR		0x00
 #define TG3_PHY_MII_ADDR		0x01
 
-/* Tigon3 specific PHY MII registers. */
+
+/*** Tigon3 specific PHY PCIE registers. ***/
+
+#define TG3_PCIEPHY_BLOCK_ADDR		0x1f
+#define  TG3_PCIEPHY_XGXS_BLK1		0x0801
+#define  TG3_PCIEPHY_TXB_BLK		0x0861
+#define  TG3_PCIEPHY_BLOCK_SHIFT	4
+
+/* TG3_PCIEPHY_TXB_BLK */
+#define TG3_PCIEPHY_TX0CTRL1		0x15
+#define  TG3_PCIEPHY_TX0CTRL1_TXOCM	0x0003
+#define  TG3_PCIEPHY_TX0CTRL1_RDCTL	0x0008
+#define  TG3_PCIEPHY_TX0CTRL1_TXCMV	0x0030
+#define  TG3_PCIEPHY_TX0CTRL1_TKSEL	0x0040
+#define  TG3_PCIEPHY_TX0CTRL1_NB_EN	0x0400
+
+/* TG3_PCIEPHY_XGXS_BLK1 */
+#define TG3_PCIEPHY_PWRMGMT4		0x1a
+#define TG3_PCIEPHY_PWRMGMT4_L1PLLPD_EN	0x0038
+#define TG3_PCIEPHY_PWRMGMT4_LOWPWR_EN	0x4000
+
+
+/*** Tigon3 specific PHY MII registers. ***/
 #define  TG3_BMCR_SPEED1000		0x0040
 
 #define MII_TG3_CTRL			0x09 /* 1000-baseT control register */
-- 
1.6.4.4


