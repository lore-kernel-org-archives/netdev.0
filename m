From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Fri, 29 Sep 2006 14:07:32 -0700
Message-ID: <1159564053.3741.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:15886 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751443AbWI2VLE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:11:04 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present.

MSI is defined to be 32-bit write.  The 5706 does 64-bit MSI writes
with byte enables disabled on the unused 32-bit word.  This is legal
but causes problems on the AMD 8132 which will eventually stop
responding after a while.

Without this patch, the MSI test done by the driver during open will
pass, but MSI will eventually stop working after a few MSIs are
written by the device.

AMD believes this incompatibility is unique to the 5706, and
prefers to locally disable MSI rather than globally disabling it
using pci_msi_quirk.

Update version to 1.4.45.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7fcf015..a65a697 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.4.44"
-#define DRV_MODULE_RELDATE	"August 10, 2006"
+#define DRV_MODULE_VERSION	"1.4.45"
+#define DRV_MODULE_RELDATE	"September 29, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -5805,6 +5805,34 @@ bnx2_init_board(struct pci_dev *pdev, st
 		bp->cmd_ticks_int = bp->cmd_ticks;
 	}
 
+	/* Disable MSI on 5706 if AMD 8132 bridge is found.
+	 *
+	 * MSI is defined to be 32-bit write.  The 5706 does 64-bit MSI writes
+	 * with byte enables disabled on the unused 32-bit word.  This is legal
+	 * but causes problems on the AMD 8132 which will eventually stop
+	 * responding after a while.
+	 *
+	 * AMD believes this incompatibility is unique to the 5706, and
+	 * prefers to locally disable MSI rather than globally disabling it
+	 * using pci_msi_quirk.
+	 */
+	if (CHIP_NUM(bp) == CHIP_NUM_5706 && disable_msi == 0) {
+		struct pci_dev *amd_8132 = NULL;
+
+		while ((amd_8132 = pci_get_device(PCI_VENDOR_ID_AMD,
+						  PCI_DEVICE_ID_AMD_8132_BRIDGE,
+						  amd_8132))) {
+			u8 rev;
+
+			pci_read_config_byte(amd_8132, PCI_REVISION_ID, &rev);
+			if (rev >= 0x10 && rev <= 0x13) {
+				disable_msi = 1;
+				pci_dev_put(amd_8132);
+				break;
+			}
+		}
+	}
+
 	bp->autoneg = AUTONEG_SPEED | AUTONEG_FLOW_CTRL;
 	bp->req_line_speed = 0;
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 2cead40..59e52cb 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -506,6 +506,7 @@
 #define PCI_DEVICE_ID_AMD_8151_0	0x7454
 #define PCI_DEVICE_ID_AMD_8131_BRIDGE	0x7450
 #define PCI_DEVICE_ID_AMD_8131_APIC	0x7451
+#define PCI_DEVICE_ID_AMD_8132_BRIDGE	0x7458
 #define PCI_DEVICE_ID_AMD_CS5536_ISA    0x2090
 #define PCI_DEVICE_ID_AMD_CS5536_FLASH  0x2091
 #define PCI_DEVICE_ID_AMD_CS5536_AUDIO  0x2093


