From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 3/3] qlcnic: Fix endianess issue in firmware load from file operation
Date: Mon, 18 Aug 2014 09:31:55 -0400
Message-ID: <1408368715-8048-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1408368715-8048-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:31983 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbaHROEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 10:04:32 -0400
In-Reply-To: <1408368715-8048-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Firmware binary file is in little endian. On big-endian architecture, while
writing this binary FW file to adapters memory, writel() swaps the data resulting into
corruption of FW image. So, swap the data before writing into adapters memory.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   35 ++++++++++++++------
 1 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index f33559b..86783e1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1378,31 +1378,45 @@ static int qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 {
 	struct qlc_83xx_fw_info *fw_info = adapter->ahw->fw_info;
 	const struct firmware *fw = fw_info->fw;
-	u32 dest, *p_cache;
+	u32 dest, *p_cache, *temp;
 	int i, ret = -EIO;
+	__le32 *temp_le;
 	u8 data[16];
 	size_t size;
 	u64 addr;
 
+	temp = kzalloc(fw->size, GFP_KERNEL);
+	if (!temp) {
+		release_firmware(fw);
+		fw_info->fw = NULL;
+		return -ENOMEM;
+	}
+
+	temp_le = (__le32 *)fw->data;
+
+	/* FW image in file is in little endian, swap the data to nullify
+	 * the effect of writel() operation on big endian platform.
+	 */
+	for (i = 0; i < fw->size / sizeof(u32); i++)
+		temp[i] = __le32_to_cpu(temp_le[i]);
+
 	dest = QLCRDX(adapter->ahw, QLCNIC_FW_IMAGE_ADDR);
 	size = (fw->size & ~0xF);
-	p_cache = (u32 *)fw->data;
+	p_cache = temp;
 	addr = (u64)dest;
 
 	ret = qlcnic_ms_mem_write128(adapter, addr,
 				     p_cache, size / 16);
 	if (ret) {
 		dev_err(&adapter->pdev->dev, "MS memory write failed\n");
-		release_firmware(fw);
-		fw_info->fw = NULL;
-		return -EIO;
+		goto exit;
 	}
 
 	/* alignment check */
 	if (fw->size & 0xF) {
 		addr = dest + size;
 		for (i = 0; i < (fw->size & 0xF); i++)
-			data[i] = fw->data[size + i];
+			data[i] = temp[size + i];
 		for (; i < 16; i++)
 			data[i] = 0;
 		ret = qlcnic_ms_mem_write128(adapter, addr,
@@ -1410,15 +1424,16 @@ static int qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 		if (ret) {
 			dev_err(&adapter->pdev->dev,
 				"MS memory write failed\n");
-			release_firmware(fw);
-			fw_info->fw = NULL;
-			return -EIO;
+			goto exit;
 		}
 	}
+
+exit:
 	release_firmware(fw);
 	fw_info->fw = NULL;
+	kfree(temp);
 
-	return 0;
+	return ret;
 }
 
 static void qlcnic_83xx_dump_pause_control_regs(struct qlcnic_adapter *adapter)
-- 
1.5.6
