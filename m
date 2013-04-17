From: joseph.salisbury@canonical.com
Subject: [PATCH 1/1][v3.8.y] tg3: Add 57766 device support.
Date: Wed, 17 Apr 2013 15:19:13 -0400
Message-ID: <49c4b657ae7c94fdd3a42fda24045a0ab03ca546.1365020650.git.joseph.salisbury@canonical.com>
References: <cover.1365020650.git.joseph.salisbury@canonical.com>
Cc: stable@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1365020650.git.joseph.salisbury@canonical.com>
In-Reply-To: <cover.1365020650.git.joseph.salisbury@canonical.com>
References: <cover.1365020650.git.joseph.salisbury@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Carlson <mcarlson@broadcom.com>

BugLink: http://bugs.launchpad.net/bugs/1162665

The patch also adds a couple of fixes

 - For the 57766 and non Ax versions of 57765, bootcode needs to setup
   the PCIE Fast Training Sequence (FTS) value to prevent transmit hangs.
   Unfortunately, it does not have enough room in the selfboot case (i.e.
   devices with no NVRAM).  The driver needs to implement this.

 - For performance reasons, the 2k DMA engine mode on the 57766 should
   be enabled and dma size limited to 2k for standard sized packets.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Joseph Salisbury <joseph.salisbury@canonical.com>

(backported from commit d3f677afb8076d09d090ff0a5d1229c9dd9f136e)
---
 drivers/net/ethernet/broadcom/tg3.c |   18 +++++++++++++++++-
 drivers/net/ethernet/broadcom/tg3.h |    2 ++
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3ec98f2..852c8c4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -330,6 +330,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57762)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57766)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -9103,7 +9104,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
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
@@ -9413,6 +9421,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
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
index d330e81..6f9b74c 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1159,6 +1159,8 @@
 #define  CPMU_MUTEX_GNT_DRIVER		 0x00001000
 #define TG3_CPMU_PHY_STRAP		0x00003664
 #define TG3_CPMU_PHY_STRAP_IS_SERDES	 0x00000020
+#define TG3_CPMU_PADRNG_CTL		0x00003668
+#define  TG3_CPMU_PADRNG_CTL_RDIV2	 0x00040000
 /* 0x3664 --> 0x36b0 unused */
 
 #define TG3_CPMU_EEE_MODE		0x000036b0
-- 
1.7.9.5
