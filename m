From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 3/7] bna: Implement FW Download for New HW
Date: Tue, 27 Sep 2011 13:39:07 -0700
Message-ID: <1317155951-17242-4-git-send-email-rmody@brocade.com>
References: <1317155951-17242-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:35173 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753351Ab1I0Ujc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 16:39:32 -0400
In-Reply-To: <1317155951-17242-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new device ID 0x22 and new asic generation BFI_ASIC_GEN_CT2 for 1860.
Implement FW download from user space for new Brocade HW.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_defs.h  |    7 ++++
 drivers/net/ethernet/brocade/bna/bfi.h       |    1 +
 drivers/net/ethernet/brocade/bna/bnad.c      |    1 +
 drivers/net/ethernet/brocade/bna/cna.h       |    1 +
 drivers/net/ethernet/brocade/bna/cna_fwimg.c |   48 ++++++++++++++++++++-----
 5 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index 66a6207..f9d4100 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -261,6 +261,13 @@ struct bfa_mfg_block {
  * ---------------------- pci definitions ------------
  */
 
+/*
+ * PCI device ID information
+ */
+enum {
+	BFA_PCI_DEVICE_ID_CT2		= 0x22,
+};
+
 #define bfa_asic_id_ct(device)			\
 	((device) == PCI_DEVICE_ID_BROCADE_CT ||	\
 	 (device) == PCI_DEVICE_ID_BROCADE_CT_FC)
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index 4e04c14..54bcafe 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -159,6 +159,7 @@ enum bfi_mclass {
 enum bfi_asic_gen {
 	BFI_ASIC_GEN_CB		= 1,
 	BFI_ASIC_GEN_CT		= 2,
+	BFI_ASIC_GEN_CT2	= 3,
 };
 
 enum bfi_asic_mode {
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index db6c097..320f11c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3477,3 +3477,4 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Brocade 10G PCIe Ethernet driver");
 MODULE_VERSION(BNAD_VERSION);
 MODULE_FIRMWARE(CNA_FW_FILE_CT);
+MODULE_FIRMWARE(CNA_FW_FILE_CT2);
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index cb48742..1b3e90d 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -38,6 +38,7 @@
 extern char bfa_version[];
 
 #define	CNA_FW_FILE_CT	"ctfw.bin"
+#define	CNA_FW_FILE_CT2	"ct2fw.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
 #pragma pack(1)
diff --git a/drivers/net/ethernet/brocade/bna/cna_fwimg.c b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
index e8f4ecd..725b9ff 100644
--- a/drivers/net/ethernet/brocade/bna/cna_fwimg.c
+++ b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
@@ -16,11 +16,12 @@
  * www.brocade.com
  */
 #include <linux/firmware.h>
+#include "bfi.h"
 #include "cna.h"
 
 const struct firmware *bfi_fw;
-static u32 *bfi_image_ct_cna;
-static u32 bfi_image_ct_cna_size;
+static u32 *bfi_image_ct_cna, *bfi_image_ct2_cna;
+static u32 bfi_image_ct_cna_size, bfi_image_ct2_cna_size;
 
 static u32 *
 cna_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
@@ -45,20 +46,47 @@ error:
 u32 *
 cna_get_firmware_buf(struct pci_dev *pdev)
 {
-	if (bfi_image_ct_cna_size == 0)
-		cna_read_firmware(pdev, &bfi_image_ct_cna,
-			&bfi_image_ct_cna_size, CNA_FW_FILE_CT);
-	return bfi_image_ct_cna;
+	if (pdev->device == BFA_PCI_DEVICE_ID_CT2) {
+		if (bfi_image_ct2_cna_size == 0)
+			cna_read_firmware(pdev, &bfi_image_ct2_cna,
+				&bfi_image_ct2_cna_size, CNA_FW_FILE_CT2);
+		return bfi_image_ct2_cna;
+	} else if (bfa_asic_id_ct(pdev->device)) {
+		if (bfi_image_ct_cna_size == 0)
+			cna_read_firmware(pdev, &bfi_image_ct_cna,
+				&bfi_image_ct_cna_size, CNA_FW_FILE_CT);
+		return bfi_image_ct_cna;
+	}
+
+	return NULL;
 }
 
 u32 *
-bfa_cb_image_get_chunk(int type, u32 off)
+bfa_cb_image_get_chunk(enum bfi_asic_gen asic_gen, u32 off)
 {
-	return (u32 *)(bfi_image_ct_cna + off);
+	switch (asic_gen) {
+	case BFI_ASIC_GEN_CT:
+		return (u32 *)(bfi_image_ct_cna + off);
+		break;
+	case BFI_ASIC_GEN_CT2:
+		return (u32 *)(bfi_image_ct2_cna + off);
+		break;
+	default:
+		return NULL;
+	}
 }
 
 u32
-bfa_cb_image_get_size(int type)
+bfa_cb_image_get_size(enum bfi_asic_gen asic_gen)
 {
-	return bfi_image_ct_cna_size;
+	switch (asic_gen) {
+	case BFI_ASIC_GEN_CT:
+		return bfi_image_ct_cna_size;
+		break;
+	case BFI_ASIC_GEN_CT2:
+		return bfi_image_ct2_cna_size;
+		break;
+	default:
+		return 0;
+	}
 }
-- 
1.7.1
