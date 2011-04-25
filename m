From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/6] tg3: Fix int generation hw bug for 5719 /
 5720
Date: Mon, 25 Apr 2011 15:42:45 -0700
Message-ID: <1303771370-32579-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2534 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255Ab1DYWae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 18:30:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the 5719 and 5720, there is a bug where the hardware will
misinterpret a status tag update and leave interrupts permanently
disabled.  This patch enables a hardware fix that works around the
issue.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    3 +++
 drivers/net/tg3.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 693f36e..a72d031 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8198,6 +8198,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		      ~DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
 		if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0)
 			val &= ~DMA_RWCTRL_CRDRDR_RDMA_MRRS_MSK;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57765 &&
+		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717)
+			val |= DMA_RWCTRL_TAGGED_STAT_WA;
 		tw32(TG3PCI_DMA_RW_CTRL, val | tp->dma_rwctrl);
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
 		   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index eaa7669..6f37d2a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -188,6 +188,7 @@
 #define   METAL_REV_B2			 0x02
 #define TG3PCI_DMA_RW_CTRL		0x0000006c
 #define  DMA_RWCTRL_DIS_CACHE_ALIGNMENT  0x00000001
+#define  DMA_RWCTRL_TAGGED_STAT_WA	 0x00000080
 #define  DMA_RWCTRL_CRDRDR_RDMA_MRRS_MSK 0x00000380
 #define  DMA_RWCTRL_READ_BNDRY_MASK	 0x00000700
 #define  DMA_RWCTRL_READ_BNDRY_DISAB	 0x00000000
-- 
1.7.3.4


