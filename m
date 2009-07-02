From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [PATCH] be2net: Implementation of request_firmware interface.
Date: Thu, 2 Jul 2009 16:48:40 +0530
Message-ID: <20090702111820.GA21085@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:46861 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751538AbZGBLSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 07:18:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please review and apply patch to net-next tree. Patch implements the 
request_firmware interface.

- Sarvesh

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be.h      |    1 
 drivers/net/benet/be_cmds.c |   28 ++++
 drivers/net/benet/be_cmds.h |   18 +++
 drivers/net/benet/be_hw.h   |   89 ++++++++++++++
 drivers/net/benet/be_main.c |  271 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 407 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index f703758..4f9ae46 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -29,6 +29,7 @@ #include <linux/if_vlan.h>
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
 #include <linux/inet_lro.h>
+#include <linux/firmware.h>
 
 #include "be_hw.h"
 
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 583517e..acb3115 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1061,3 +1061,31 @@ int be_cmd_query_fw_cfg(struct be_ctrl_i
 	spin_unlock(&ctrl->mbox_lock);
 	return status;
 }
+
+int be_cmd_write_flashrom(struct be_ctrl_info *ctrl, struct be_dma_mem *cmd,
+			u32 flash_type, u32 flash_opcode, u32 buf_size)
+{
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_cmd_write_flashrom *req = cmd->va;
+	struct be_sge *sge = nonembedded_sgl(wrb);
+	int status;
+
+	spin_lock(&ctrl->mbox_lock);
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
+	status = be_mbox_db_ring(ctrl);
+
+	spin_unlock(&ctrl->mbox_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 747626d..e2b8479 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -117,6 +117,7 @@ #define OPCODE_COMMON_NTWK_MAC_SET			2
 #define OPCODE_COMMON_NTWK_MULTICAST_SET		3
 #define OPCODE_COMMON_NTWK_VLAN_CONFIG  		4
 #define OPCODE_COMMON_NTWK_LINK_STATUS_QUERY		5
+#define OPCODE_COMMON_WRITE_FLASHROM			7
 #define OPCODE_COMMON_CQ_CREATE				12
 #define OPCODE_COMMON_EQ_CREATE				13
 #define OPCODE_COMMON_MCC_CREATE        		21
@@ -697,6 +698,20 @@ struct be_cmd_resp_query_fw_cfg {
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
 extern int be_pci_fnum_get(struct be_ctrl_info *ctrl);
 extern int be_cmd_POST(struct be_ctrl_info *ctrl);
 extern int be_cmd_mac_addr_query(struct be_ctrl_info *ctrl, u8 *mac_addr,
@@ -745,4 +760,7 @@ extern int be_cmd_set_flow_control(struc
 extern int be_cmd_get_flow_control(struct be_ctrl_info *ctrl,
 			u32 *tx_fc, u32 *rx_fc);
 extern int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num);
+extern int be_cmd_write_flashrom(struct be_ctrl_info *ctrl,
+			struct be_dma_mem *cmd, u32 flash_oper,
+			u32 flash_opcode, u32 buf_size);
 extern void be_process_mcc(struct be_ctrl_info *ctrl);
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index b02e805..6035f1b 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -55,6 +55,28 @@ #define MEMBAR_CTRL_INT_CTRL_HOSTINTR_MA
 #define MEMBAR_CTRL_INT_CTRL_PFUNC_MASK  	0x7 	/* bits 26 - 28 */
 #define MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT	26
 
+/********* Soft Reset registers ***********/
+#define PCICFG_SOFT_RESET_CSR_OFFSET		0x5c
+#define PCICFG_SOFT_RESET_MASK			(1 << 7) /* bit 7 */
+
+#define PCICFG_ONLINE0_CSR_OFFSET		0xb0
+#define PCICFG_ONLINE1_CSR_OFFSET		0xb4
+#define PCICFG_MPU_IRAM_ONLINE_MASK		(1 << 3) /* bit 3 */
+
+#define PCICFG_UE_STATUS_LOW_MASK_OFFSET	0xa8
+#define PCICFG_UE_STATUS_HIGH_MASK_OFFSET	0xac
+
+#define MPU_EP_CONTROL_CSR_OFFSET		0x0
+#define MPU_EP_CONTROL_CPU_RESET_MASK		(1 << 31) /* bit 31 */
+
+/********* POST Descriptors ***************/
+#define MPU_EP_SEMAPHORE_OFFSET			0xac
+#define MPU_POST_ERR_MASK			(1 << 31) /* bit 31 */
+#define MPU_POST_STAGE_MASK			0xFFFF	/* bits 0 - 15 */
+#define MPU_POST_STAGE_ARMFW_RDY		0xc000
+#define MPU_POST_STAGE_AWAIT_HOST_RDY		0x1
+#define MPU_POST_STAGE_HOST_RDY			0x2
+
 /********* Event Q door bell *************/
 #define DB_EQ_OFFSET			DB_CQ_OFFSET
 #define DB_EQ_RING_ID_MASK		0x1FF	/* bits 0 - 8 */
@@ -215,3 +237,70 @@ struct amap_eth_rx_compl {
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
+#define FLASHROM_TYPE_FIRMWARE		0
+#define FLASHROM_TYPE_REDBOOT		1
+#define FLASHROM_TYPE_BIOS		2
+
+#define FLASHROM_OPER_FLASH		1
+#define FLASHROM_OPER_SAVE		2
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
index 66c10c8..fd9f3b5 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1635,6 +1635,273 @@ static int be_close(struct net_device *n
 	return 0;
 }
 
+#define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
+char flash_cookie[2][16] =	{"*** SE FLAS",
+				"H DIRECTORY *** "};
+static int be_flash_image(struct be_adapter *adapter,
+			const struct firmware *fw,
+			struct flash_section_info *fsec,
+			struct be_dma_mem *flash_cmd, u32 flash_type)
+{
+	int status;
+	u32 flash_op, image_type = 0, total_bytes;
+	int num_bytes, i;
+	const u8 *p = fw->data;
+	struct flash_section_entry *fsec_entry = NULL;
+	struct be_cmd_write_flashrom *req = flash_cmd->va;
+
+	switch (flash_type) {
+	case FLASHROM_TYPE_FIRMWARE:
+		image_type = IMAGE_TYPE_FIRMWARE;
+		break;
+	case FLASHROM_TYPE_BIOS:
+		image_type = IMAGE_TYPE_OPTIONROM;
+		break;
+	case FLASHROM_TYPE_REDBOOT:
+		image_type = IMAGE_TYPE_BOOTCODE;
+		break;
+	}
+
+	for (i = 0; i < NUM_FLASHDIR_ENTRIES; i++) {
+		if ((fsec->fsec_entry[i].type == image_type) &&
+		(fsec->fsec_hdr.active_entry_mask & (1<<i)) &&
+		(fsec->fsec_hdr.valid_entry_mask & (1<<i))) {
+			fsec_entry = &fsec->fsec_entry[i];
+			break;
+		}
+	}
+
+	if (!fsec_entry) {
+		dev_err(&adapter->pdev->dev,
+			"Section missing in firmware image\n");
+		return -1;
+	}
+
+	p += sizeof(struct flash_file_hdr) + fsec_entry->offset;
+	if (p + fsec_entry->image_size > fw->data + fw->size)
+		return -1;
+
+	total_bytes = fsec_entry->image_size;
+	if (total_bytes%256)
+		total_bytes = (256 - total_bytes%256) + total_bytes;
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
+		status = be_cmd_write_flashrom(&adapter->ctrl, flash_cmd,
+				flash_type, flash_op, num_bytes);
+		if (status)
+			return -1;
+		yield();
+	}
+
+	return 0;
+}
+
+static int be_wait_for_post_cmpl(struct be_ctrl_info *ctrl)
+{
+	u32 post_err, post_stage, reg;
+	int status = 0, i = 0;
+
+	do {
+		reg = ioread32(ctrl->csr + MPU_EP_SEMAPHORE_OFFSET);
+		post_err = reg & MPU_POST_ERR_MASK;
+		post_stage = reg & MPU_POST_STAGE_MASK;
+		yield();
+		udelay(1000);
+
+	} while (!post_err &&
+		 (post_stage !=  MPU_POST_STAGE_ARMFW_RDY) &&
+		 (i++ < 60000));
+
+	if (post_err || (post_stage != MPU_POST_STAGE_ARMFW_RDY))
+		status = -1;
+
+	return status;
+}
+
+static int be_pci_soft_reset(struct be_ctrl_info *ctrl)
+{
+	u8 __iomem *addr;
+	u32 soft_reset, val;
+	int i = 0;
+
+	addr = ctrl->pcicfg + PCICFG_SOFT_RESET_CSR_OFFSET;
+	val = ioread32(addr);
+	val |= PCICFG_SOFT_RESET_MASK;
+	iowrite32(val, addr);
+
+	/* Wait till soft reset is deasserted */
+	do {
+		udelay(50);
+		val = ioread32(addr);
+		soft_reset = val & PCICFG_SOFT_RESET_MASK;
+	} while (soft_reset && (i++ < 1024));
+
+	if (soft_reset)
+		return -1;
+
+	/* Mask all UEs */
+	val = 0xffffffff;
+	addr = ctrl->pcicfg + PCICFG_UE_STATUS_LOW_MASK_OFFSET;
+	iowrite32(val, addr);
+
+	addr = ctrl->pcicfg + PCICFG_UE_STATUS_HIGH_MASK_OFFSET;
+	iowrite32(val, addr);
+
+	/* Take everyone offline except mpu iram */
+	val = 0;
+	addr = ctrl->pcicfg + PCICFG_ONLINE0_CSR_OFFSET;
+	iowrite32(val, addr);
+
+	val = PCICFG_MPU_IRAM_ONLINE_MASK;
+	addr = ctrl->pcicfg + PCICFG_ONLINE1_CSR_OFFSET;
+	iowrite32(val, addr);
+
+	udelay(20000);
+
+	/* Soft Again*/
+	addr = ctrl->pcicfg + PCICFG_SOFT_RESET_CSR_OFFSET;
+	val = ioread32(addr);
+	val |= PCICFG_SOFT_RESET_MASK;
+
+	iowrite32(val, addr);
+
+	i = 0;
+	do {
+		udelay(50);
+		val = ioread32(addr);
+		soft_reset = val & PCICFG_SOFT_RESET_MASK;
+	} while (soft_reset && (i++ < 1024));
+
+	if (soft_reset)
+		return -1;
+
+	udelay(20000);
+
+	/* Take mpu out of reset*/
+	addr = ctrl->csr + MPU_EP_CONTROL_CSR_OFFSET;
+	val = ioread32(addr);
+	val &= ~MPU_EP_CONTROL_CPU_RESET_MASK;
+
+	iowrite32(val, addr);
+
+	if (be_wait_for_post_cmpl(ctrl))
+		return -1;
+
+	return 0;
+}
+
+int be_load_fw(struct be_adapter *adapter)
+{
+	char fw_file[64];
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
+	status = be_cmd_get_fw_ver(&adapter->ctrl, fw_ver);
+	if (status)
+		return status;
+
+	fw_cfg = *(fw_ver + 2);
+	if (fw_cfg == '0')
+		fw_cfg = '1';
+	sprintf(fw_file, "be2-cna%c-fw.ufi", fw_cfg);
+
+	if (request_firmware(&fw, fw_file, &adapter->pdev->dev))
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
+	/* fw ver on board matches */
+	if (!strncmp(fhdr->sign + strlen(FW_FILE_HDR_SIGN), fw_ver,
+			FW_VER_LEN))
+		goto fw_exit;
+
+	dev_info(&adapter->pdev->dev,
+		"Flashing firmware file %s\n", fw_file);
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
+	for (flash_type = FLASHROM_TYPE_FIRMWARE;
+		flash_type <= FLASHROM_TYPE_BIOS; flash_type++) {
+		status = be_flash_image(adapter, fw, fsec, &flash_cmd,
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
+	if (be_pci_soft_reset(&adapter->ctrl)) {
+		dev_err(&adapter->pdev->dev,
+			"Chip reset after load new firmware failed\n");
+		status = -1;
+	}
+
+	if (!status && !be_cmd_get_fw_ver(&adapter->ctrl, fw_ver))
+		dev_info(&adapter->pdev->dev,
+			"Firmware(ver: %s) flashed succesfully\n", fw_ver);
+fw_exit:
+	release_firmware(fw);
+	return status;
+}
+
 static int be_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
 				void **ip_hdr, void **tcpudp_hdr,
 				u64 *hdr_flags, void *priv)
@@ -1926,6 +2193,10 @@ static int __devinit be_probe(struct pci
 	if (status)
 		goto free_netdev;
 
+	status = be_load_fw(adapter);
+	if (status)
+		goto ctrl_clean;
+
 	status = be_stats_init(adapter);
 	if (status)
 		goto ctrl_clean;
-- 
1.4.0

