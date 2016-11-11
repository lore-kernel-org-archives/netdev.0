From: Baoquan He <bhe@redhat.com>
Subject: [PATCH 2/2] bnx2: Hard reset bnx2 chip at probe stage
Date: Fri, 11 Nov 2016 21:46:35 +0800
Message-ID: <1478871995-29652-3-git-send-email-bhe@redhat.com>
References: <1478871995-29652-1-git-send-email-bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, pmenzel@molgen.mpg.de,
        jroedel@suse.de, dyoung@redhat.com, Baoquan He <bhe@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478871995-29652-1-git-send-email-bhe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit 3e1be7a ("bnx2: Reset device during driver initialization"),
firmware requesting code was moved to driver probe stage, into function
bnx2_init_one. But if bnx2 driver is build into kernel, it will fail
to request firmware because firmware is contained in initramfs, but
initramfs has not been uncommpressed and mounted yet when do_initcalls
called.

So in order to reset the device at probe stage, have to hard reset bnx2
chip wihtout involving firmware handling. So in this patch add function
bnx2_hard_reset_chip which only trys to hard reset bnx2 chip and only
will be called in kdump kernel.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 62 ++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index c557972..84e3f12 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -49,6 +49,7 @@
 #include <linux/firmware.h>
 #include <linux/log2.h>
 #include <linux/aer.h>
+#include <linux/crash_dump.h>
 
 #if IS_ENABLED(CONFIG_CNIC)
 #define BCM_CNIC 1
@@ -4765,6 +4766,58 @@ bnx2_setup_msix_tbl(struct bnx2 *bp)
 }
 
 static int
+bnx2_hard_reset_chip(struct bnx2 *bp)
+{
+	u32 val;
+	int i, rc = 0;
+
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
+		BNX2_WR(bp, BNX2_MISC_COMMAND, BNX2_MISC_COMMAND_HD_RESET);
+		BNX2_RD(bp, BNX2_MISC_COMMAND);
+		udelay(5);
+
+		val = BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
+		      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
+
+		BNX2_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
+
+	} else {
+		val = BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
+		      BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
+		      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
+
+		/* Chip reset. */
+		BNX2_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
+
+		/* Reading back any register after chip reset will hang the
+		 * bus on 5706 A0 and A1.  The msleep below provides plenty
+		 * of margin for write posting.
+		 */
+		if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) ||
+		    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1))
+			msleep(20);
+
+		/* Reset takes approximate 30 usec */
+		for (i = 0; i < 10; i++) {
+			val = BNX2_RD(bp, BNX2_PCICFG_MISC_CONFIG);
+			if ((val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
+				    BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) == 0)
+				break;
+			udelay(10);
+		}
+
+		if (val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
+			   BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) {
+			pr_err("Chip reset did not complete\n");
+			return -EBUSY;
+		}
+	}
+
+	return rc;
+}
+
+
+static int
 bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 {
 	u32 val;
@@ -8580,6 +8633,15 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
+
+	/*
+	 * Kdump kernel need reset device at probe stage if hardware iommu
+	 * is deployed. Otherwise in-flight DMA will continue going until
+	 * reset is done in open stage.
+	 */
+	if (is_kdump_kernel())
+		bnx2_hard_reset_chip(bp);
+
 	memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
 
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
-- 
2.5.5
