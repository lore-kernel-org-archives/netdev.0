From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/5] netxen: validate unified romimage
Date: Mon, 29 Mar 2010 05:43:43 -0700
Message-ID: <1269866625-26151-4-git-send-email-amit.salecha@qlogic.com>
References: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh K Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:14600 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751362Ab0C2Mnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 08:43:46 -0400
In-Reply-To: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh K Borundia <rajesh.borundia@qlogic.com>

Signed-off-by: Rajesh K Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Validate all sections of unified romimage, before accessing them,
  to avoid seg fault.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 -
 drivers/net/netxen/netxen_nic_init.c |  154 ++++++++++++++++++++++++++++++---
 2 files changed, 140 insertions(+), 15 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 144d2e8..33ae5e1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -420,7 +420,6 @@ struct status_desc {
 } __attribute__ ((aligned(16)));
 
 /* UNIFIED ROMIMAGE *************************/
-#define NX_UNI_FW_MIN_SIZE		0xc8000
 #define NX_UNI_DIR_SECT_PRODUCT_TBL	0x0
 #define NX_UNI_DIR_SECT_BOOTLD		0x6
 #define NX_UNI_DIR_SECT_FW		0x7
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 1c63610..141bc43 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -613,22 +613,123 @@ static struct uni_table_desc *nx_get_table_desc(const u8 *unirom, int section)
 	return NULL;
 }
 
+#define	QLCNIC_FILEHEADER_SIZE	(14 * 4)
+
 static int
-nx_set_product_offs(struct netxen_adapter *adapter)
-{
-	struct uni_table_desc *ptab_descr;
+netxen_nic_validate_header(struct netxen_adapter *adapter)
+ {
 	const u8 *unirom = adapter->fw->data;
-	uint32_t i;
+	struct uni_table_desc *directory = (struct uni_table_desc *) &unirom[0];
+	u32 fw_file_size = adapter->fw->size;
+	u32 tab_size;
 	__le32 entries;
+	__le32 entry_size;
+
+	if (fw_file_size < QLCNIC_FILEHEADER_SIZE)
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
+netxen_nic_validate_bootld(struct netxen_adapter *adapter)
+{
+	struct uni_table_desc *tab_desc;
+	struct uni_data_desc *descr;
+	const u8 *unirom = adapter->fw->data;
+	__le32 idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
+				NX_UNI_BOOTLD_IDX_OFF));
+	u32 offs;
+	u32 tab_size;
+	u32 data_size;
+
+	tab_desc = nx_get_table_desc(unirom, NX_UNI_DIR_SECT_BOOTLD);
+
+	if (!tab_desc)
+		return -EINVAL;
 
+	tab_size = cpu_to_le32(tab_desc->findex) +
+			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
+	offs = cpu_to_le32(tab_desc->findex) +
+		(cpu_to_le32(tab_desc->entry_size) * (idx));
+	descr = (struct uni_data_desc *)&unirom[offs];
+
+	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
+
+	if (adapter->fw->size < data_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int
+netxen_nic_validate_fw(struct netxen_adapter *adapter)
+{
+	struct uni_table_desc *tab_desc;
+	struct uni_data_desc *descr;
+	const u8 *unirom = adapter->fw->data;
+	__le32 idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
+				NX_UNI_FIRMWARE_IDX_OFF));
+	u32 offs;
+	u32 tab_size;
+	u32 data_size;
+
+	tab_desc = nx_get_table_desc(unirom, NX_UNI_DIR_SECT_FW);
+
+	if (!tab_desc)
+		return -EINVAL;
+
+	tab_size = cpu_to_le32(tab_desc->findex) +
+			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
+	offs = cpu_to_le32(tab_desc->findex) +
+		(cpu_to_le32(tab_desc->entry_size) * (idx));
+	descr = (struct uni_data_desc *)&unirom[offs];
+	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
+
+	if (adapter->fw->size < data_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+
+static int
+netxen_nic_validate_product_offs(struct netxen_adapter *adapter)
+{
+	struct uni_table_desc *ptab_descr;
+	const u8 *unirom = adapter->fw->data;
 	int mn_present = (NX_IS_REVISION_P2(adapter->ahw.revision_id)) ?
 			1 : netxen_p3_has_mn(adapter);
+	__le32 entries;
+	__le32 entry_size;
+	u32 tab_size;
+	u32 i;
 
 	ptab_descr = nx_get_table_desc(unirom, NX_UNI_DIR_SECT_PRODUCT_TBL);
 	if (ptab_descr == NULL)
-		return -1;
+		return -EINVAL;
 
 	entries = cpu_to_le32(ptab_descr->num_entries);
+	entry_size = cpu_to_le32(ptab_descr->entry_size);
+	tab_size = cpu_to_le32(ptab_descr->findex) + (entries * entry_size);
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
 
 nomn:
 	for (i = 0; i < entries; i++) {
@@ -657,9 +758,38 @@ nomn:
 		goto nomn;
 	}
 
-	return -1;
+	return -EINVAL;
 }
 
+static int
+netxen_nic_validate_unified_romimage(struct netxen_adapter *adapter)
+{
+	if (netxen_nic_validate_header(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: header validation failed\n");
+		return -EINVAL;
+	}
+
+	if (netxen_nic_validate_product_offs(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: product validation failed\n");
+		return -EINVAL;
+	}
+
+	if (netxen_nic_validate_bootld(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: bootld validation failed\n");
+		return -EINVAL;
+	}
+
+	if (netxen_nic_validate_fw(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: firmware validation failed\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
 
 static struct uni_data_desc *nx_get_data_desc(struct netxen_adapter *adapter,
 			u32 section, u32 idx_offset)
@@ -933,27 +1063,23 @@ static int
 netxen_validate_firmware(struct netxen_adapter *adapter)
 {
 	__le32 val;
-	u32 ver, min_ver, bios, min_size;
+	u32 ver, min_ver, bios;
 	struct pci_dev *pdev = adapter->pdev;
 	const struct firmware *fw = adapter->fw;
 	u8 fw_type = adapter->fw_type;
 
 	if (fw_type == NX_UNIFIED_ROMIMAGE) {
-		if (nx_set_product_offs(adapter))
+		if (netxen_nic_validate_unified_romimage(adapter))
 			return -EINVAL;
-
-		min_size = NX_UNI_FW_MIN_SIZE;
 	} else {
 		val = cpu_to_le32(*(u32 *)&fw->data[NX_FW_MAGIC_OFFSET]);
 		if ((__force u32)val != NETXEN_BDINFO_MAGIC)
 			return -EINVAL;
 
-		min_size = NX_FW_MIN_SIZE;
+		if (fw->size < NX_FW_MIN_SIZE)
+			return -EINVAL;
 	}
 
-	if (fw->size < min_size)
-		return -EINVAL;
-
 	val = nx_get_fw_version(adapter);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-- 
1.6.0.2

