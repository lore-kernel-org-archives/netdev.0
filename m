From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 4/6] qlcnic: validate unified fw image
Date: Mon,  8 Mar 2010 02:14:48 -0800
Message-ID: <1268043290-19929-5-git-send-email-amit.salecha@qlogic.com>
References: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta@dut6195.unminc.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:20447 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753422Ab0CHKOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 05:14:52 -0500
In-Reply-To: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta@dut6195.unminc.com>

Validate all sections of unified fw image, before accessing them,
to avoid seg fault.

Signed-off-by: Sucheta Chakraborty <sucheta@dut6195.unminc.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |  146 ++++++++++++++++++++++++++++++++++++--
 1 files changed, 139 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index f0df971..21a6e9f 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -568,21 +568,123 @@ struct uni_table_desc *qlcnic_get_table_desc(const u8 *unirom, int section)
 	return NULL;
 }
 
+#define FILEHEADER_SIZE (14 * 4)
+
 static int
-qlcnic_set_product_offs(struct qlcnic_adapter *adapter)
+qlcnic_validate_header(struct qlcnic_adapter *adapter)
 {
-	struct uni_table_desc *ptab_descr;
 	const u8 *unirom = adapter->fw->data;
-	u32 i;
+	struct uni_table_desc *directory = (struct uni_table_desc *) &unirom[0];
+	__le32 fw_file_size = adapter->fw->size;
 	__le32 entries;
+	__le32 entry_size;
+	__le32 tab_size;
+
+	if (fw_file_size < FILEHEADER_SIZE)
+		return -EINVAL;
+
+	entries = cpu_to_le32(directory->num_entries);
+	entry_size = cpu_to_le32(directory->entry_size);
+	tab_size = cpu_to_le32(directory->findex) + (entries * entry_size);
+
+	if (fw_file_size < tab_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int
+qlcnic_validate_bootld(struct qlcnic_adapter *adapter)
+{
+	struct uni_table_desc *tab_desc;
+	struct uni_data_desc *descr;
+	const u8 *unirom = adapter->fw->data;
+	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
+				QLCNIC_UNI_BOOTLD_IDX_OFF));
+	__le32 offs;
+	__le32 tab_size;
+	__le32 data_size;
+
+	tab_desc = qlcnic_get_table_desc(unirom, QLCNIC_UNI_DIR_SECT_BOOTLD);
+
+	if (!tab_desc)
+		return -EINVAL;
+
+	tab_size = cpu_to_le32(tab_desc->findex) +
+			(cpu_to_le32(tab_desc->entry_size * (idx + 1)));
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
+	offs = cpu_to_le32(tab_desc->findex) +
+		(cpu_to_le32(tab_desc->entry_size) * (idx));
+	descr = (struct uni_data_desc *)&unirom[offs];
+
+	data_size = descr->findex + cpu_to_le32(descr->size);
+
+	if (adapter->fw->size < data_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int
+qlcnic_validate_fw(struct qlcnic_adapter *adapter)
+{
+	struct uni_table_desc *tab_desc;
+	struct uni_data_desc *descr;
+	const u8 *unirom = adapter->fw->data;
+	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
+				QLCNIC_UNI_FIRMWARE_IDX_OFF));
+	__le32 offs;
+	__le32 tab_size;
+	__le32 data_size;
+
+	tab_desc = qlcnic_get_table_desc(unirom, QLCNIC_UNI_DIR_SECT_FW);
+
+	if (!tab_desc)
+		return -EINVAL;
+
+	tab_size = cpu_to_le32(tab_desc->findex) +
+			(cpu_to_le32(tab_desc->entry_size * (idx + 1)));
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
+	offs = cpu_to_le32(tab_desc->findex) +
+		(cpu_to_le32(tab_desc->entry_size) * (idx));
+	descr = (struct uni_data_desc *)&unirom[offs];
+	data_size = descr->findex + cpu_to_le32(descr->size);
+
+	if (adapter->fw->size < data_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int
+qlcnic_validate_product_offs(struct qlcnic_adapter *adapter)
+{
+	struct uni_table_desc *ptab_descr;
+	const u8 *unirom = adapter->fw->data;
 	int mn_present = qlcnic_has_mn(adapter);
+	__le32 entries;
+	__le32 entry_size;
+	__le32 tab_size;
+	u32 i;
 
 	ptab_descr = qlcnic_get_table_desc(unirom,
 				QLCNIC_UNI_DIR_SECT_PRODUCT_TBL);
-	if (ptab_descr == NULL)
-		return -1;
+	if (!ptab_descr)
+		return -EINVAL;
 
 	entries = cpu_to_le32(ptab_descr->num_entries);
+	entry_size = cpu_to_le32(ptab_descr->entry_size);
+	tab_size = cpu_to_le32(ptab_descr->findex) + (entries * entry_size);
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
 nomn:
 	for (i = 0; i < entries; i++) {
 
@@ -609,7 +711,37 @@ nomn:
 		mn_present = 0;
 		goto nomn;
 	}
-	return -1;
+	return -EINVAL;
+}
+
+static int
+qlcnic_validate_unified_romimage(struct qlcnic_adapter *adapter)
+{
+	if (qlcnic_validate_header(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: header validation failed\n");
+		return -EINVAL;
+	}
+
+	if (qlcnic_validate_product_offs(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: product validation failed\n");
+		return -EINVAL;
+	}
+
+	if (qlcnic_validate_bootld(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: bootld validation failed\n");
+		return -EINVAL;
+	}
+
+	if (qlcnic_validate_fw(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: firmware validation failed\n");
+		return -EINVAL;
+	}
+
+	return 0;
 }
 
 static
@@ -858,7 +990,7 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 	u8 fw_type = adapter->fw_type;
 
 	if (fw_type == QLCNIC_UNIFIED_ROMIMAGE) {
-		if (qlcnic_set_product_offs(adapter))
+		if (qlcnic_validate_unified_romimage(adapter))
 			return -EINVAL;
 
 		min_size = QLCNIC_UNI_FW_MIN_SIZE;
-- 
1.6.0.2

