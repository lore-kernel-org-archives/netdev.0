From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/5 net-next v2] tg3: Add 57766 device support.
Date: Thu, 14 Feb 2013 16:27:51 -0800
Message-ID: <1360888071-13108-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3081 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759753Ab3BOAKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 19:10:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

The patch also adds a couple of fixes

 - For the 57766 and non Ax versions of 57765, bootcode needs to setup
   the PCIE Fast Training Sequence (FTS) value to prevent transmit hangs.
   Unfortunately, it does not have enough room in the selfboot case (i.e.
   devices with no NVRAM).  The driver needs to implement this.

 - For performance reasons, the 2k DMA engine mode on the 57766 should
   be enabled and dma size limited to 2k for standard sized packets.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   18 +++++++++++++++++-
 drivers/net/ethernet/broadcom/tg3.h |    2 ++
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b1b3bc0..6e676a7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -332,6 +332,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57762)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57766)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5762)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5725)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5727)},
@@ -9179,7 +9180,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		}
 
 		if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_57765_AX) {
-			u32 grc_mode = tr32(GRC_MODE);
+			u32 grc_mode;
+
+			/* Fix transmit hangs */
+			val = tr32(TG3_CPMU_PADRNG_CTL);
+			val |= TG3_CPMU_PADRNG_CTL_RDIV2;
+			tw32(TG3_CPMU_PADRNG_CTL, val);
+
+			grc_mode = tr32(GRC_MODE);
 
 			/* Access the lower 1K of DL PCIE block registers. */
 			val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
@@ -9492,6 +9500,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (tg3_flag(tp, PCI_EXPRESS))
 		rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57766) {
+		tp->dma_limit = 0;
+		if (tp->dev->mtu <= ETH_DATA_LEN) {
+			rdmac_mode |= RDMAC_MODE_JMB_2K_MMRR;
+			tp->dma_limit = TG3_TX_BD_DMA_MAX_2K;
+		}
+	}
+
 	if (tg3_flag(tp, HW_TSO_1) ||
 	    tg3_flag(tp, HW_TSO_2) ||
 	    tg3_flag(tp, HW_TSO_3))
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index ef6ced2..b676728 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1164,6 +1164,8 @@
 #define  CPMU_MUTEX_GNT_DRIVER		 0x00001000
 #define TG3_CPMU_PHY_STRAP		0x00003664
 #define TG3_CPMU_PHY_STRAP_IS_SERDES	 0x00000020
+#define TG3_CPMU_PADRNG_CTL		0x00003668
+#define  TG3_CPMU_PADRNG_CTL_RDIV2	 0x00040000
 /* 0x3664 --> 0x36b0 unused */
 
 #define TG3_CPMU_EEE_MODE		0x000036b0
-- 
1.7.1
