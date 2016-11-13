From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 2/2] bnx2: Wait for in-flight DMA to complete at probe
 stage
Date: Sun, 13 Nov 2016 12:15:24 +0800
Message-ID: <20161113041524.GF15325@x1>
References: <1478871995-29652-1-git-send-email-bhe@redhat.com>
 <1478871995-29652-3-git-send-email-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, pmenzel@molgen.mpg.de,
        jroedel@suse.de, dyoung@redhat.com
To: netdev@vger.kernel.org, Michael Chan <michael.chan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478871995-29652-3-git-send-email-bhe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In-flight DMA from 1st kernel could continue going in kdump kernel.
New io-page table has been created before bnx2 does reset at open stage.
We have to wait for the in-flight DMA to complete to avoid it look up
into the newly created io-page table at probe stage.

Suggested-by: Michael Chan <michael.chan@broadcom.com>
Signed-off-by: Baoquan He <bhe@redhat.com>
---
v1->v2:
    Michael suggested to wait for the in-flight DMA to complete at probe
    stage. So give up the old method of trying to reset chip at probe
    stage, take the new way accordingly.

 drivers/net/ethernet/broadcom/bnx2.c | 38 ++++++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index c557972..1f7034d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -49,6 +49,7 @@
 #include <linux/firmware.h>
 #include <linux/log2.h>
 #include <linux/aer.h>
+#include <linux/crash_dump.h>
 
 #if IS_ENABLED(CONFIG_CNIC)
 #define BCM_CNIC 1
@@ -4764,15 +4765,16 @@ bnx2_setup_msix_tbl(struct bnx2 *bp)
 	BNX2_WR(bp, BNX2_PCI_GRC_WINDOW3_ADDR, BNX2_MSIX_PBA_ADDR);
 }
 
-static int
-bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
+static void
+bnx2_wait_dma_complete(struct bnx2 *bp)
 {
 	u32 val;
-	int i, rc = 0;
-	u8 old_port;
+	int i;
 
-	/* Wait for the current PCI transaction to complete before
-	 * issuing a reset. */
+	/*
+	 * Wait for the current PCI transaction to complete before
+	 * issuing a reset.
+	 */
 	if ((BNX2_CHIP(bp) == BNX2_CHIP_5706) ||
 	    (BNX2_CHIP(bp) == BNX2_CHIP_5708)) {
 		BNX2_WR(bp, BNX2_MISC_ENABLE_CLR_BITS,
@@ -4796,6 +4798,21 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		}
 	}
 
+	return;
+}
+
+
+static int
+bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
+{
+	u32 val;
+	int i, rc = 0;
+	u8 old_port;
+
+	/* Wait for the current PCI transaction to complete before
+	 * issuing a reset. */
+	bnx2_wait_dma_complete(bp);
+
 	/* Wait for the firmware to tell us it is ok to issue a reset. */
 	bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT0 | reset_code, 1, 1);
 
@@ -8580,6 +8597,15 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
+	/*
+	 * In-flight DMA from 1st kernel could continue going in kdump kernel.
+	 * New io-page table has been created before bnx2 does reset at open stage.
+	 * We have to wait for the in-flight DMA to complete to avoid it look up
+	 * into the newly created io-page table.
+	 */
+	if (is_kdump_kernel())
+		bnx2_wait_dma_complete(bp);
+
 	memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
 
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
-- 
2.5.5
