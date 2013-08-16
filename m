From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: Add support for 84xx adapters to load firmware from file
Date: Fri, 16 Aug 2013 19:07:16 -0400
Message-ID: <3eef70490ce682e6ba934ef09f2c3aa807b9e468.1376720973.git.himanshu.madhani@qlogic.com>
References: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33074 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755625Ab3HQAHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:07:09 -0400
In-Reply-To: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

o Use appropriate firmware image file name based on device IDs.

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  2 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  | 28 ++++++++++++++++++++--
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index b89b074..d4c58c6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -84,9 +84,11 @@
 /* Firmware image definitions */
 #define QLC_83XX_BOOTLOADER_FLASH_ADDR	0x10000
 #define QLC_83XX_FW_FILE_NAME		"83xx_fw.bin"
+#define QLC_84XX_FW_FILE_NAME		"84xx_fw.bin"
 #define QLC_83XX_BOOT_FROM_FLASH	0
 #define QLC_83XX_BOOT_FROM_FILE		0x12345678
 
+#define QLC_FW_FILE_NAME_LEN		20
 #define QLC_83XX_MAX_RESET_SEQ_ENTRIES	16
 
 #define QLC_83XX_MBX_POST_BC_OP		0x1
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 17c26a1..8efbc131 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1947,12 +1947,36 @@ static void qlcnic_83xx_init_hw(struct qlcnic_adapter *p_dev)
 		dev_err(&p_dev->pdev->dev, "%s: failed\n", __func__);
 }
 
+static inline void qlcnic_83xx_get_fw_file_name(struct qlcnic_adapter *adapter,
+						char *file_name)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	memset(file_name, 0, QLC_FW_FILE_NAME_LEN);
+
+	switch (pdev->device) {
+	case PCI_DEVICE_ID_QLOGIC_QLE834X:
+		strncpy(file_name, QLC_83XX_FW_FILE_NAME,
+			QLC_FW_FILE_NAME_LEN);
+		break;
+	case PCI_DEVICE_ID_QLOGIC_QLE844X:
+		strncpy(file_name, QLC_84XX_FW_FILE_NAME,
+			QLC_FW_FILE_NAME_LEN);
+		break;
+	default:
+		dev_err(&pdev->dev, "%s: Invalid device id\n",
+			__func__);
+	}
+}
+
 static int qlcnic_83xx_load_fw_image_from_host(struct qlcnic_adapter *adapter)
 {
+	char fw_file_name[QLC_FW_FILE_NAME_LEN];
 	int err = -EIO;
 
-	if (request_firmware(&adapter->ahw->fw_info.fw,
-			     QLC_83XX_FW_FILE_NAME, &(adapter->pdev->dev))) {
+	qlcnic_83xx_get_fw_file_name(adapter, fw_file_name);
+	if (request_firmware(&adapter->ahw->fw_info.fw, fw_file_name,
+			     &(adapter->pdev->dev))) {
 		dev_err(&adapter->pdev->dev,
 			"No file FW image, loading flash FW image.\n");
 		QLC_SHARED_REG_WR32(adapter, QLCNIC_FW_IMG_VALID,
-- 
1.8.1.4
