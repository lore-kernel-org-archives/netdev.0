From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [net-next-2.6 PATCH 1/2] be2net: Changes to support flashing of
	the be2 network adapter
Date: Fri, 4 Sep 2009 18:42:16 +0530
Message-ID: <20090904131205.GA10728@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:60410 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752373AbZIDNMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 09:12:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to support flashing of the be2 network adapter using the
request_firmware() & ethtool infrastructure. The trigger to flash the device
will come from ethtool utility. The driver will invoke request_firmware()
to start the flash process. The file containing the flash image is expected
to be available in /lib/firmware/


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    4 +-
 drivers/net/benet/be_cmds.c    |   30 +++++++-
 drivers/net/benet/be_cmds.h    |   20 +++++-
 drivers/net/benet/be_ethtool.c |   15 ++++
 drivers/net/benet/be_hw.h      |   85 ++++++++++++++++++++-
 drivers/net/benet/be_main.c    |  167 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 317 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 6c45a22..13b72ce 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -28,10 +28,11 @@
 #include <linux/if_vlan.h>
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
+#include <linux/firmware.h>
 
 #include "be_hw.h"
 
-#define DRV_VER			"2.0.400"
+#define DRV_VER			"2.101.205"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define OC_NAME			"Emulex OneConnect 10Gbps NIC"
@@ -361,4 +362,5 @@ static inline u8 is_udp_pkt(struct sk_buff *skb)
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
+extern int be_load_fw(struct be_adapter *adapter, u8 *func);
 #endif				/* BE_H */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 2547ee2..1db0924 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -155,7 +155,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 		if (ready)
 			break;
 
-		if (cnt > 200000) {
+		if (cnt > 4000000) {
 			dev_err(&adapter->pdev->dev, "mbox poll timed out\n");
 			return -1;
 		}
@@ -1040,3 +1040,31 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
+
+int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
+			u32 flash_type, u32 flash_opcode, u32 buf_size)
+{
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
+	struct be_cmd_write_flashrom *req = cmd->va;
+	struct be_sge *sge = nonembedded_sgl(wrb);
+	int status;
+
+	spin_lock(&adapter->mbox_lock);
+	memset(wrb, 0, sizeof(*wrb));
+	be_wrb_hdr_prepare(wrb, cmd->size, false, 1);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_WRITE_FLASHROM, cmd->size);
+	sge->pa_hi = cpu_to_le32(upper_32_bits(cmd->dma));
+	sge->pa_lo = cpu_to_le32(cmd->dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(cmd->size);
+
+	req->params.op_type = cpu_to_le32(flash_type);
+	req->params.op_code = cpu_to_le32(flash_opcode);
+	req->params.data_buf_size = cpu_to_le32(buf_size);
+
+	status = be_mbox_notify(adapter);
+
+	spin_unlock(&adapter->mbox_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 7061806..fd7028e 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -117,6 +117,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_NTWK_MULTICAST_SET		3
 #define OPCODE_COMMON_NTWK_VLAN_CONFIG  		4
 #define OPCODE_COMMON_NTWK_LINK_STATUS_QUERY		5
+#define OPCODE_COMMON_WRITE_FLASHROM			7
 #define OPCODE_COMMON_CQ_CREATE				12
 #define OPCODE_COMMON_EQ_CREATE				13
 #define OPCODE_COMMON_MCC_CREATE        		21
@@ -693,10 +694,24 @@ struct be_cmd_resp_query_fw_cfg {
 	u32 be_config_number;
 	u32 asic_revision;
 	u32 phys_port;
-	u32 function_mode;
+	u32 function_cap;
 	u32 rsvd[26];
 };
 
+/****************** Firmware Flash ******************/
+struct flashrom_params {
+	u32 op_code;
+	u32 op_type;
+	u32 data_buf_size;
+	u32 offset;
+	u8 data_buf[4];
+};
+
+struct be_cmd_write_flashrom {
+	struct be_cmd_req_hdr hdr;
+	struct flashrom_params params;
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -747,3 +762,6 @@ extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 extern int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
 extern void be_process_mcc(struct be_adapter *adapter);
+extern int be_cmd_write_flashrom(struct be_adapter *adapter,
+			struct be_dma_mem *cmd, u32 flash_oper,
+			u32 flash_opcode, u32 buf_size);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 4ff3cc4..11445df 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -332,6 +332,20 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	return status;
 }
 
+static int
+be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	char file_name[ETHTOOL_FLASH_MAX_FILENAME];
+	u32 region;
+
+	file_name[ETHTOOL_FLASH_MAX_FILENAME - 1] = 0;
+	strcpy(file_name, efl->data);
+	region = efl->region;
+
+	return be_load_fw(adapter, file_name);
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -352,4 +366,5 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_strings = be_get_stat_strings,
 	.get_stats_count = be_get_stats_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
+	.flash_device = be_do_flash,
 };
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index d28f0c6..a3394b4 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -204,7 +204,7 @@ struct amap_eth_rx_compl {
 	u8 numfrags[3];		/* dword 1 */
 	u8 rss_flush;		/* dword 2 */
 	u8 cast_enc[2];		/* dword 2 */
-	u8 qnq;			/* dword 2 */
+	u8 vtm;			/* dword 2 */
 	u8 rss_bank;		/* dword 2 */
 	u8 rsvd1[23];		/* dword 2 */
 	u8 lro_pkt;		/* dword 2 */
@@ -216,3 +216,86 @@ struct amap_eth_rx_compl {
 struct be_eth_rx_compl {
 	u32 dw[4];
 };
+
+/* Flashrom related descriptors */
+#define IMAGE_TYPE_FIRMWARE		160
+#define IMAGE_TYPE_BOOTCODE		224
+#define IMAGE_TYPE_OPTIONROM		32
+
+#define NUM_FLASHDIR_ENTRIES		32
+
+#define FLASHROM_TYPE_ISCSI_ACTIVE	0
+#define FLASHROM_TYPE_BIOS		2
+#define FLASHROM_TYPE_PXE_BIOS		3
+#define FLASHROM_TYPE_FCOE_BIOS		8
+#define FLASHROM_TYPE_ISCSI_BACKUP	9
+#define FLASHROM_TYPE_FCOE_FW_ACTIVE	10
+#define FLASHROM_TYPE_FCOE_FW_BACKUP 	11
+
+#define FLASHROM_OPER_FLASH		1
+#define FLASHROM_OPER_SAVE		2
+
+#define FLASH_IMAGE_MAX_SIZE            (1310720) /* Max firmware image size */
+#define FLASH_BIOS_IMAGE_MAX_SIZE       (262144)  /* Max OPTION ROM image sz */
+
+/* Offsets for components on Flash. */
+#define FLASH_iSCSI_PRIMARY_IMAGE_START (1048576)
+#define FLASH_iSCSI_BACKUP_IMAGE_START  (2359296)
+#define FLASH_FCoE_PRIMARY_IMAGE_START  (3670016)
+#define FLASH_FCoE_BACKUP_IMAGE_START   (4980736)
+#define FLASH_iSCSI_BIOS_START          (7340032)
+#define FLASH_PXE_BIOS_START            (7864320)
+#define FLASH_FCoE_BIOS_START           (524288)
+
+struct controller_id {
+	u32 vendor;
+	u32 device;
+	u32 subvendor;
+	u32 subdevice;
+};
+
+struct flash_file_hdr {
+	u8 sign[32];
+	u32 cksum;
+	u32 antidote;
+	struct controller_id cont_id;
+	u32 file_len;
+	u32 chunk_num;
+	u32 total_chunks;
+	u32 num_imgs;
+	u8 build[24];
+};
+
+struct flash_section_hdr {
+	u32 format_rev;
+	u32 cksum;
+	u32 antidote;
+	u32 build_no;
+	u8 id_string[64];
+	u32 active_entry_mask;
+	u32 valid_entry_mask;
+	u32 org_content_mask;
+	u32 rsvd0;
+	u32 rsvd1;
+	u32 rsvd2;
+	u32 rsvd3;
+	u32 rsvd4;
+};
+
+struct flash_section_entry {
+	u32 type;
+	u32 offset;
+	u32 pad_size;
+	u32 image_size;
+	u32 cksum;
+	u32 entry_point;
+	u32 rsvd0;
+	u32 rsvd1;
+	u8 ver_data[32];
+};
+
+struct flash_section_info {
+	u8 cookie[32];
+	struct flash_section_hdr fsec_hdr;
+	struct flash_section_entry fsec_entry[32];
+};
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index bac85f9..d09106f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1699,6 +1699,173 @@ static int be_close(struct net_device *netdev)
 	return 0;
 }
 
+#define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
+char flash_cookie[2][16] =	{"*** SE FLAS",
+				"H DIRECTORY *** "};
+static int be_flash_image(struct be_adapter *adapter,
+			const struct firmware *fw,
+			struct be_dma_mem *flash_cmd, u32 flash_type)
+{
+	int status;
+	u32 flash_op, image_offset = 0, total_bytes, image_size = 0;
+	int num_bytes;
+	const u8 *p = fw->data;
+	struct be_cmd_write_flashrom *req = flash_cmd->va;
+
+	switch (flash_type) {
+	case FLASHROM_TYPE_ISCSI_ACTIVE:
+		image_offset = FLASH_iSCSI_PRIMARY_IMAGE_START;
+		image_size = FLASH_IMAGE_MAX_SIZE;
+		break;
+	case FLASHROM_TYPE_ISCSI_BACKUP:
+		image_offset = FLASH_iSCSI_BACKUP_IMAGE_START;
+		image_size = FLASH_IMAGE_MAX_SIZE;
+		break;
+	case FLASHROM_TYPE_FCOE_FW_ACTIVE:
+		image_offset = FLASH_FCoE_PRIMARY_IMAGE_START;
+		image_size = FLASH_IMAGE_MAX_SIZE;
+		break;
+	case FLASHROM_TYPE_FCOE_FW_BACKUP:
+		image_offset = FLASH_FCoE_BACKUP_IMAGE_START;
+		image_size = FLASH_IMAGE_MAX_SIZE;
+		break;
+	case FLASHROM_TYPE_BIOS:
+		image_offset = FLASH_iSCSI_BIOS_START;
+		image_size = FLASH_BIOS_IMAGE_MAX_SIZE;
+		break;
+	case FLASHROM_TYPE_FCOE_BIOS:
+		image_offset = FLASH_FCoE_BIOS_START;
+		image_size = FLASH_BIOS_IMAGE_MAX_SIZE;
+		break;
+	case FLASHROM_TYPE_PXE_BIOS:
+		image_offset = FLASH_PXE_BIOS_START;
+		image_size = FLASH_BIOS_IMAGE_MAX_SIZE;
+		break;
+	default:
+		return 0;
+	}
+
+	p += sizeof(struct flash_file_hdr) + image_offset;
+	if (p + image_size > fw->data + fw->size)
+		return -1;
+
+	total_bytes = image_size;
+
+	while (total_bytes) {
+		if (total_bytes > 32*1024)
+			num_bytes = 32*1024;
+		else
+			num_bytes = total_bytes;
+		total_bytes -= num_bytes;
+
+		if (!total_bytes)
+			flash_op = FLASHROM_OPER_FLASH;
+		else
+			flash_op = FLASHROM_OPER_SAVE;
+		memcpy(req->params.data_buf, p, num_bytes);
+		p += num_bytes;
+		status = be_cmd_write_flashrom(adapter, flash_cmd,
+				flash_type, flash_op, num_bytes);
+		if (status) {
+			dev_err(&adapter->pdev->dev,
+			"cmd to write to flash rom failed. type/op %d/%d\n",
+			flash_type, flash_op);
+			return -1;
+		}
+		yield();
+	}
+
+	return 0;
+}
+
+int be_load_fw(struct be_adapter *adapter, u8 *func)
+{
+	char fw_file[ETHTOOL_FLASH_MAX_FILENAME];
+	const struct firmware *fw;
+	struct flash_file_hdr *fhdr;
+	struct flash_section_info *fsec = NULL;
+	struct be_dma_mem flash_cmd;
+	int status;
+	const u8 *p;
+	bool entry_found = false;
+	int flash_type;
+	char fw_ver[FW_VER_LEN];
+	char fw_cfg;
+
+	status = be_cmd_get_fw_ver(adapter, fw_ver);
+	if (status)
+		return status;
+
+	fw_cfg = *(fw_ver + 2);
+	if (fw_cfg == '0')
+		fw_cfg = '1';
+	strcpy(fw_file, func);
+
+	status = request_firmware(&fw, fw_file, &adapter->pdev->dev);
+	if (status)
+		goto fw_exit;
+
+	p = fw->data;
+	fhdr = (struct flash_file_hdr *) p;
+	if (memcmp(fhdr->sign, FW_FILE_HDR_SIGN, strlen(FW_FILE_HDR_SIGN))) {
+		dev_err(&adapter->pdev->dev,
+			"Firmware(%s) load error (signature did not match)\n",
+				fw_file);
+		status = -1;
+		goto fw_exit;
+	}
+
+	dev_info(&adapter->pdev->dev, "Flashing firmware file %s\n", fw_file);
+
+	p += sizeof(struct flash_file_hdr);
+	while (p < (fw->data + fw->size)) {
+		fsec = (struct flash_section_info *)p;
+		if (!memcmp(flash_cookie, fsec->cookie, sizeof(flash_cookie))) {
+			entry_found = true;
+			break;
+		}
+		p += 32;
+	}
+
+	if (!entry_found) {
+		status = -1;
+		dev_err(&adapter->pdev->dev,
+			"Flash cookie not found in firmware image\n");
+		goto fw_exit;
+	}
+
+	flash_cmd.size = sizeof(struct be_cmd_write_flashrom) + 32*1024;
+	flash_cmd.va = pci_alloc_consistent(adapter->pdev, flash_cmd.size,
+					&flash_cmd.dma);
+	if (!flash_cmd.va) {
+		status = -ENOMEM;
+		dev_err(&adapter->pdev->dev,
+			"Memory allocation failure while flashing\n");
+		goto fw_exit;
+	}
+
+	for (flash_type = FLASHROM_TYPE_ISCSI_ACTIVE;
+		flash_type <= FLASHROM_TYPE_FCOE_FW_BACKUP; flash_type++) {
+		status = be_flash_image(adapter, fw, &flash_cmd,
+				flash_type);
+		if (status)
+			break;
+	}
+
+	pci_free_consistent(adapter->pdev, flash_cmd.size, flash_cmd.va,
+				flash_cmd.dma);
+	if (status) {
+		dev_err(&adapter->pdev->dev, "Firmware load error\n");
+		goto fw_exit;
+	}
+
+	dev_info(&adapter->pdev->dev, "Firmware flashed succesfully\n");
+
+fw_exit:
+	release_firmware(fw);
+	return status;
+}
+
 static struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
-- 
1.6.0.4

