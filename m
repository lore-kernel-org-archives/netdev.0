From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v3 3/7] pci: Add helper to find a VPD resource data type
Date: Fri, 26 Feb 2010 16:04:41 -0800
Message-ID: <1267229085-21303-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1953 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966618Ab0B0AEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 19:04:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the pci_vpd_find_tag() helper function to find VPD
resource data types in a buffer.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c   |   24 ++++--------------------
 drivers/net/tg3.c    |   26 +++++---------------------
 drivers/pci/Makefile |    2 +-
 drivers/pci/vpd.c    |   43 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/pci.h  |   12 ++++++++++++
 5 files changed, 65 insertions(+), 42 deletions(-)
 create mode 100644 drivers/pci/vpd.c

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7caa98d..02809da 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7759,28 +7759,12 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
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
index 4c24998..3e5696b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12440,7 +12440,7 @@ skip_phy_reset:
 static void __devinit tg3_read_partno(struct tg3 *tp)
 {
 	unsigned char vpd_data[TG3_NVM_VPD_LEN];   /* in little-endian format */
-	unsigned int i;
+	int i;
 	u32 magic;
 
 	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
@@ -12479,28 +12479,12 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 
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
index 0000000..6bc5545
--- /dev/null
+++ b/drivers/pci/vpd.c
@@ -0,0 +1,43 @@
+/*
+ * File:	vpd.c
+ * Purpose:	Provide PCI VPD support
+ *
+ * Copyright (C) 2010 Broadcom Corporation.
+ */
+
+#include <linux/pci.h>
+
+int pci_vpd_find_tag(const u8 *buf, unsigned int off, unsigned int len, u8 rdt)
+{
+	int i;
+
+	for (i = off; i < len; ) {
+		u8 val = buf[i];
+
+		if (val & PCI_VPD_LRDT) {
+			/* Don't return success of the tag isn't complete */
+			if (i + PCI_VPD_LRDT_TAG_SIZE > len)
+				break;
+
+			if (val == rdt)
+				return i;
+
+			i += PCI_VPD_LRDT_TAG_SIZE +
+			     pci_vpd_lrdt_size(&buf[i]);
+		} else {
+			u8 tag = val & ~PCI_VPD_SRDT_LEN_MASK;
+
+			if (tag == rdt)
+				return i;
+
+			if (tag == PCI_VPD_SRDT_END)
+				break;
+
+			i += PCI_VPD_SRDT_TAG_SIZE +
+			     pci_vpd_srdt_size(&buf[i]);
+		}
+	}
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(pci_vpd_find_tag);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index d6f2b17..c2da353 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1384,5 +1384,17 @@ static inline u8 pci_vpd_srdt_size(const u8 *srdt)
 	return (*srdt) & PCI_VPD_SRDT_LEN_MASK;
 }
 
+/**
+ * pci_vpd_find_tag - Locates the Resource Data Type tag provided
+ * @buf: Pointer to buffered vpd data
+ * @off: The offset into the buffer at which to begin the search
+ * @len: The length of the vpd buffer
+ * @rdt: The Resource Data Type to search for
+ *
+ * Returns the index where the Resource Data Type was found or
+ * -ENOENT otherwise.
+ */
+int pci_vpd_find_tag(const u8 *buf, unsigned int off, unsigned int len, u8 rdt);
+
 #endif /* __KERNEL__ */
 #endif /* LINUX_PCI_H */
-- 
1.6.4.4


