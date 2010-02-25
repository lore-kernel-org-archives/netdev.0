From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/7] pci: Add PCI LRDT tag size and section size
Date: Thu, 25 Feb 2010 10:19:16 -0800
Message-ID: <1267121962-6077-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: jbarnes@virtuousgeek.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a preprocessor constant to describe the PCI VPD large
resource data type tag size and an inline function to extract the large
resource section size from the large resource data type tag.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c      |    9 ++++++---
 drivers/net/tg3.c       |   14 +++++++-------
 include/linux/pci-vpd.h |   26 ++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/pci-vpd.h

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 65df1de..9f5b0fc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -21,6 +21,7 @@
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
+#include <linux/pci-vpd.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -7763,15 +7764,17 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 		unsigned int block_end;
 
 		if (val == 0x82 || val == 0x91) {
-			i = (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
+			i += PCI_VPD_LRDT_TAG_SIZE +
+			     pci_vpd_lrdt_size(&data[i]);
 			continue;
 		}
 
 		if (val != 0x90)
 			goto vpd_done;
 
-		block_end = (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
-		i += 3;
+		block_end = (i + PCI_VPD_LRDT_TAG_SIZE +
+			    pci_vpd_lrdt_size(&data[i]));
+		i += PCI_VPD_LRDT_TAG_SIZE;
 
 		if (block_end > BNX2_VPD_LEN)
 			goto vpd_done;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7f82b02..6cab97f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -27,6 +27,7 @@
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <linux/pci-vpd.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -12483,19 +12484,18 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		unsigned int block_end;
 
 		if (val == 0x82 || val == 0x91) {
-			i = (i + 3 +
-			     (vpd_data[i + 1] +
-			      (vpd_data[i + 2] << 8)));
+			i += PCI_VPD_LRDT_TAG_SIZE +
+			     pci_vpd_lrdt_size(&vpd_data[i]);
 			continue;
 		}
 
 		if (val != 0x90)
 			goto out_not_found;
 
-		block_end = (i + 3 +
-			     (vpd_data[i + 1] +
-			      (vpd_data[i + 2] << 8)));
-		i += 3;
+		block_end = i + PCI_VPD_LRDT_TAG_SIZE +
+			    pci_vpd_lrdt_size(&vpd_data[i]);
+
+		i += PCI_VPD_LRDT_TAG_SIZE;
 
 		if (block_end > TG3_NVM_VPD_LEN)
 			goto out_not_found;
diff --git a/include/linux/pci-vpd.h b/include/linux/pci-vpd.h
new file mode 100644
index 0000000..c077369
--- /dev/null
+++ b/include/linux/pci-vpd.h
@@ -0,0 +1,26 @@
+/*
+ *	pci-vpd.h
+ *
+ *	PCI VPD defines and function prototypes
+ *
+ *	Copyright (C) 2010 Broadcom Corporation.
+ *
+ *	For more information, please consult the following manuals (look at
+ *	http://www.pcisig.com/ for how to get them):
+ *
+ *	PCI Local Bus Specification, Rev. 3.0 : Appendix I
+ */
+
+#ifndef LINUX_PCI_VPD_H
+#define LINUX_PCI_VPD_H
+
+#include <linux/pci.h>
+
+#define PCI_VPD_LRDT_TAG_SIZE	3
+
+static inline u16 pci_vpd_lrdt_size(u8 *lrdt)
+{
+	return (u16)lrdt[1] + ((u16)lrdt[2] << 8);
+}
+
+#endif /* LINUX_PCI_VPD_H */
-- 
1.6.4.4
