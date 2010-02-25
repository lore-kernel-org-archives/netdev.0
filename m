From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/7] pci: Add helper to find a VPD resource data type
Date: Thu, 25 Feb 2010 10:19:18 -0800
Message-ID: <1267121962-6077-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2635 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933232Ab0BYSUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 13:20:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the pci_vpd_find_tag() helper function to find VPD
resource data types in a buffer.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c      |   24 ++++--------------------
 drivers/net/tg3.c       |   26 +++++---------------------
 drivers/pci/Makefile    |    2 +-
 drivers/pci/vpd.c       |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/pci-vpd.h |    2 ++
 5 files changed, 56 insertions(+), 42 deletions(-)
 create mode 100644 drivers/pci/vpd.c

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1c48d4a..2de3576 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7760,28 +7760,12 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 	}
 
 	for (i = 0; i <= BNX2_VPD_LEN - 3; ) {
-		unsigned char val = data[i];
 		unsigned int block_end;
 
-		if (val & PCI_VPD_LRDT) {
-			if (i + PCI_VPD_LRDT_TAG_SIZE > BNX2_VPD_LEN)
-				break;
-
-			if (val != PCI_VPD_LRDT_RO_DATA) {
-				i += PCI_VPD_LRDT_TAG_SIZE +
-				     pci_vpd_lrdt_size(&data[i]);
-
-				continue;
-			}
-		} else {
-			if ((val & PCI_VPD_SRDT_TIN_MASK) == PCI_VPD_STIN_END)
-				break;
-
-			i += PCI_VPD_SRDT_TAG_SIZE +
-			     pci_vpd_srdt_size(&data[i]);
-
-			continue;
-		}
+		i = pci_vpd_find_tag(data, i, BNX2_VPD_LEN,
+				     PCI_VPD_LRDT_RO_DATA);
+		if (i < 0)
+			break;
 
 		block_end = (i + PCI_VPD_LRDT_TAG_SIZE +
 			    pci_vpd_lrdt_size(&data[i]));
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2ec6eca..eaf178b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12441,7 +12441,7 @@ skip_phy_reset:
 static void __devinit tg3_read_partno(struct tg3 *tp)
 {
 	unsigned char vpd_data[TG3_NVM_VPD_LEN];   /* in little-endian format */
-	unsigned int i;
+	int i;
 	u32 magic;
 
 	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
@@ -12480,28 +12480,12 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 
 	/* Now parse and find the part number. */
 	for (i = 0; i < TG3_NVM_VPD_LEN - 2; ) {
-		unsigned char val = vpd_data[i];
 		unsigned int block_end;
 
-		if (val & PCI_VPD_LRDT) {
-			if (i + PCI_VPD_LRDT_TAG_SIZE > TG3_NVM_VPD_LEN)
-				break;
-
-			if (val != PCI_VPD_LRDT_RO_DATA) {
-				i += PCI_VPD_LRDT_TAG_SIZE +
-				     pci_vpd_lrdt_size(&vpd_data[i]);
-
-				continue;
-			}
-		} else {
-			if ((val & PCI_VPD_SRDT_TIN_MASK) == PCI_VPD_STIN_END)
-				break;
-
-			i += PCI_VPD_SRDT_TAG_SIZE +
-			     pci_vpd_srdt_size(&vpd_data[i]);
-
-			continue;
-		}
+		i = pci_vpd_find_tag(vpd_data, i, TG3_NVM_VPD_LEN,
+				     PCI_VPD_LRDT_RO_DATA);
+		if (i < 0)
+			break;
 
 		block_end = i + PCI_VPD_LRDT_TAG_SIZE +
 			    pci_vpd_lrdt_size(&vpd_data[i]);
diff --git a/drivers/pci/Makefile b/drivers/pci/Makefile
index 4df48d5..b2f6d77 100644
--- a/drivers/pci/Makefile
+++ b/drivers/pci/Makefile
@@ -4,7 +4,7 @@
 
 obj-y		+= access.o bus.o probe.o remove.o pci.o quirks.o \
 			pci-driver.o search.o pci-sysfs.o rom.o setup-res.o \
-			irq.o
+			irq.o vpd.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_SYSFS) += slot.o
 
diff --git a/drivers/pci/vpd.c b/drivers/pci/vpd.c
new file mode 100644
index 0000000..1b5b3cc
--- /dev/null
+++ b/drivers/pci/vpd.c
@@ -0,0 +1,44 @@
+/*
+ * File:	vpd.c
+ * Purpose:	Provide PCI VPD support
+ *
+ * Copyright (C) 2010 Broadcom Corporation.
+ */
+
+#include <linux/pci.h>
+#include <linux/pci-vpd.h>
+
+int pci_vpd_find_tag(u8 *data, unsigned int start, unsigned int len, u8 tagid)
+{
+	int i;
+
+	for (i = start; i < start + len; ) {
+		u8 val = data[i];
+
+		if (val & PCI_VPD_LRDT) {
+			/* Don't return success of the tag isn't complete */
+			if (i + PCI_VPD_LRDT_TAG_SIZE > start + len)
+				break;
+
+			if (val == tagid)
+				return i;
+
+			i += PCI_VPD_LRDT_TAG_SIZE +
+			     pci_vpd_lrdt_size(&data[i]);
+		} else {
+			u8 tag = val & ~PCI_VPD_SRDT_LEN_MASK;
+
+			if (tag == tagid)
+				return i;
+
+			if (tag == PCI_VPD_SRDT_END)
+				break;
+
+			i += PCI_VPD_SRDT_TAG_SIZE +
+			     pci_vpd_srdt_size(&data[i]);
+		}
+	}
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(pci_vpd_find_tag);
diff --git a/include/linux/pci-vpd.h b/include/linux/pci-vpd.h
index b80d5c0..04eb87e 100644
--- a/include/linux/pci-vpd.h
+++ b/include/linux/pci-vpd.h
@@ -49,4 +49,6 @@ static inline u8 pci_vpd_srdt_size(u8 *srdt)
 	return (*srdt) & PCI_VPD_SRDT_LEN_MASK;
 }
 
+int pci_vpd_find_tag(u8 *data, unsigned int start, unsigned int len, u8 tagid);
+
 #endif /* LINUX_PCI_VPD_H */
-- 
1.6.4.4


