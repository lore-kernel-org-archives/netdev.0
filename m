From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 09/15] qlcnic: 83xx adpater flash interface routines
Date: Thu, 23 Aug 2012 21:07:13 -0400
Message-ID: <1345770439-30517-10-git-send-email-sony.chacko@qlogic.com>
References: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:8916 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755436Ab2HXBYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 21:24:11 -0400
In-Reply-To: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Flash interface routines for 83xx adapter

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   31 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  344 ++++++++++++++++++--
 2 files changed, 345 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 9e46670..f95477e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -315,6 +315,36 @@ struct qlcnic_flt_entry {
 	u32 end_addr;
 };
 
+struct qlcnic_flash_desc_table {
+	u32	flash_valid;
+	u16	flash_ver;
+	u16	flash_len;
+	u16	flash_cksum;
+	u16	flash_unused;
+	u8	flash_model[16];
+	u16	flash_manuf;
+	u16	flash_id;
+	u8	flash_flag;
+	u8	erase_cmd;
+	u8	alt_erase_cmd;
+	u8	write_enable_cmd;
+	u8	write_enable_bits;
+	u8	write_statusreg_cmd;
+	u8	unprotected_sec_cmd;
+	u8	read_manuf_cmd;
+	u32	block_size;
+	u32	alt_block_size;
+	u32	flash_size;
+	u32	write_enable_data;
+	u8	readid_addr_len;
+	u8	write_disable_bits;
+	u8	read_dev_id_len;
+	u8	chip_erase_cmd;
+	u16	read_timeo;
+	u8	protected_sec_cmd;
+	u8	resvd[65];
+};
+
 /* Magic number to let user know flash is programmed */
 #define	QLCNIC_BDINFO_MAGIC 0x12345678
 
@@ -505,6 +535,7 @@ struct qlcnic_hardware_context {
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	struct qlcnic_flash_desc_table flash_fdt;
 	struct qlcnic_83xx_reset reset;
 	struct qlcnic_83xx_idc idc;
 	struct qlcnic_83xx_fw_info fw_info;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 4edbdd2..c430723 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -4,9 +4,6 @@
 #include <linux/ethtool.h>
 #include <linux/interrupt.h>
 
-/* Array of FW control command structs with command type and required
- * number of input and output arguments respectively.
-*/
 static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
 	{ QLCNIC_CMD_CONFIGURE_IP_ADDR, 6, 1 },
 	{ QLCNIC_CMD_CONFIG_INTRPT, 18, 34 },
@@ -209,7 +206,6 @@ qlcnic_83xx_get_fw_version(struct qlcnic_adapter *adapter)
 	return adapter->fw_version;
 }
 
-/* Caller needs to use locking before accessing this function */
 static int
 __qlcnic_set_win_base(struct qlcnic_adapter *adapter, u32 addr)
 {
@@ -1229,9 +1225,6 @@ qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,
 	return data;
 }
 
-/*
- * Get statistics of MAC and that of Context/Function/Vport
- */
 void
 qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter,
 		struct ethtool_stats *stats, u64 *data)
@@ -1539,7 +1532,6 @@ qlcnic_83xx_mbx_op(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 		dev_info(&adapter->pdev->dev,
 			"Mailbox not available, 0x%x, collect FW dump\n",
 			mbx_val);
-		/* Take FW dump */
 		spin_unlock_irqrestore(&ahw->mbx_lock, flags);
 
 		return cmd->rsp.arg[0];
@@ -1606,9 +1598,6 @@ poll:
 	return rsp;
 }
 
-/* Allocate mailbox incoming and outgoing registers. It should be used with a
- * follow up call to qlcnic_free_mbx_args
- */
 int qlcnic_83xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
 		struct qlcnic_adapter *adapter, u32 type)
 {
@@ -1685,36 +1674,24 @@ void qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
 	for (i = 0; i < QLC_83XX_MBX_AEN_CNT; i++)
 		event[i] = le32_to_cpu(readl(QLCNIC_MBX_FW(ahw, i)));
 	switch (QLCNIC_MBX_RSP(event[0])) {
-
-	/* This case is only active when we arrive here
-	 * as a result of issuing a mailbox command to
-	 * the firmware.
-	 */
 	case QLCNIC_MBX_LINK_EVENT:
-		/* Link Event */
 		qlcnic_83xx_handle_link_aen(adapter, event);
 		break;
 	case QLCNIC_MBX_COMP_EVENT:
-		/* IDC Completion Notification */
 		qlcnic_83xx_handle_idc_comp_aen(adapter, event);
 		break;
 	case QLCNIC_MBX_REQUEST_EVENT:
-		/* IDC Request Notification */
 		for (i = 0; i < QLC_83XX_MBX_AEN_CNT; i++)
 			adapter->ahw->mbox_aen[i] = QLCNIC_MBX_RSP(event[i]);
-		/* IDC ack wiil be done by worker thread, just set the flag */
 		set_bit(QLC_83XX_MBX_AEN_ACK, &adapter->ahw->idc.status);
 		break;
 	case QLCNIC_MBX_TIME_EXTEND_EVENT:
-		/* IDC Time Extend Notification */
 		break;
 	case QLCNIC_MBX_SFP_INSERT_EVENT:
-		/* IDC SFP+ Transceiver Insertion Notification */
 		dev_info(&adapter->pdev->dev, "SFP+ Insert AEN:0x%x.\n",
 				QLCNIC_MBX_RSP(event[0]));
 		break;
 	case QLCNIC_MBX_SFP_REMOVE_EVENT:
-		/* IDC SFP+ Transceiver Removal Notification */
 		dev_info(&adapter->pdev->dev, "SFP Removed AEN:0x%x.\n",
 				QLCNIC_MBX_RSP(event[0]));
 		break;
@@ -2257,7 +2234,6 @@ void qlcnic_83xx_configure_mac(struct qlcnic_adapter *adapter, u8 *mac,
 	cmd->req.arg[1] = cpu_to_le32(type);
 }
 
-/* Get MAC address of a NIC partition */
 int qlcnic_83xx_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 {
 	int err, i;
@@ -2363,7 +2339,6 @@ int qlcnic_enable_eswitch(struct qlcnic_adapter *adapter, u8 port, u8 enable)
 
 }
 
-/* Configure a NIC partition */
 int qlcnic_83xx_set_nic_info(struct qlcnic_adapter *adapter,
 					struct qlcnic_info *nic)
 {
@@ -2460,7 +2435,6 @@ out:
 	return err;
 }
 
-/* Get PCI Info of a partition */
 int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *adapter,
 				struct qlcnic_pci_info *pci_info)
 {
@@ -2515,10 +2489,6 @@ int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *adapter,
 	return err;
 }
 
-/* Configure interrupts command registers interrupt vectors with the FW
- * @op_type: 1 for creation and 0 for deletion
- * @type: Interrupt type, INTx or MSI-X
- * */
 int qlcnic_83xx_config_intrpt(struct qlcnic_adapter *adapter, bool op_type)
 
 {
@@ -2690,3 +2660,317 @@ qlcnic_83xx_lockless_flash_read_u32(struct qlcnic_adapter *adapter,
 
 	return 0;
 }
+
+static int
+qlcnic_83xx_poll_flash_status_reg(struct qlcnic_adapter *adapter)
+{
+	u32 status;
+	int err, retries = QLC_83XX_FLASH_READ_RETRY_COUNT;
+
+	do {
+		status = qlcnic_83xx_rd_reg_indirect(adapter,
+						QLC_83XX_FLASH_STATUS, &err);
+		if ((status & QLC_83XX_FLASH_STATUS_READY) ==
+						QLC_83XX_FLASH_STATUS_READY)
+			break;
+
+		msleep(QLC_83XX_FLASH_STATUS_REG_POLL_DELAY);
+	} while (--retries);
+
+	if (!retries)
+		return -EIO;
+
+	return 0;
+}
+
+static int
+qlcnic_83xx_enable_flash_write_op(struct qlcnic_adapter *adapter)
+{
+	int ret;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+			(QLC_83XX_FLASH_FDT_WRITE_DEF_SIG |
+			adapter->ahw->flash_fdt.write_statusreg_cmd));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
+			adapter->ahw->flash_fdt.write_enable_bits);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+			QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
+
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret)
+		return -EIO;
+
+	return 0;
+}
+
+static int
+qlcnic_83xx_disable_flash_write_op(struct qlcnic_adapter *adapter)
+{
+	int ret;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+			(QLC_83XX_FLASH_FDT_WRITE_DEF_SIG |
+			adapter->ahw->flash_fdt.write_statusreg_cmd));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
+			adapter->ahw->flash_fdt.write_enable_bits);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+			QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
+
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret)
+		return -EIO;
+
+	return 0;
+}
+
+int
+qlcnic_83xx_read_flash_mfg_id(struct qlcnic_adapter *adapter)
+{
+	int ret, mfg_id;
+
+	if (qlcnic_83xx_lock_flash(adapter))
+		return -EIO;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+			QLC_83XX_FLASH_FDT_READ_MFG_ID_VAL);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+			QLC_83XX_FLASH_READ_CONTROL_VAL);
+
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		qlcnic_83xx_unlock_flash(adapter);
+		return -EIO;
+	}
+
+	mfg_id = qlcnic_83xx_rd_reg_indirect(adapter,
+				QLC_83XX_FLASH_RDDATA, &ret);
+
+	adapter->flash_mfg_id = (mfg_id & 0xFF);
+	qlcnic_83xx_unlock_flash(adapter);
+
+	return 0;
+}
+
+int
+qlcnic_83xx_read_flash_descriptor_table(struct qlcnic_adapter *adapter)
+{
+	int count, fdt_size, ret = 0;
+
+	fdt_size = sizeof(struct qlcnic_flash_desc_table);
+	count = fdt_size/sizeof(u32);
+
+	if (qlcnic_83xx_lock_flash(adapter))
+		return -EIO;
+
+	memset(&adapter->ahw->flash_fdt, 0, fdt_size);
+	ret = qlcnic_83xx_lockless_flash_read_u32(adapter,
+				QLCNIC_FDT_LOCATION,
+				(u8 *)&adapter->ahw->flash_fdt,
+				count);
+
+	qlcnic_83xx_unlock_flash(adapter);
+	return ret;
+}
+
+int
+qlcnic_83xx_erase_flash_sector(struct qlcnic_adapter *adapter,
+					u32 sector_start_addr)
+{
+	u32 reversed_addr;
+	int ret = -EIO;
+
+	if (qlcnic_83xx_lock_flash(adapter) != 0)
+		return -EIO;
+
+	if (adapter->ahw->flash_fdt.flash_manuf == adapter->flash_mfg_id) {
+		ret = qlcnic_83xx_enable_flash_write_op(adapter);
+		if (ret) {
+			qlcnic_83xx_unlock_flash(adapter);
+			dev_err(&adapter->pdev->dev,
+				"%s failed at %d\n",
+				__func__, __LINE__);
+			return ret;
+		}
+	}
+
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		qlcnic_83xx_unlock_flash(adapter);
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	reversed_addr = (((sector_start_addr & 0xFF) << 16) |
+			((sector_start_addr & 0xFF0000) >> 16));
+
+	qlcnic_83xx_wrt_reg_indirect(adapter,
+				QLC_83XX_FLASH_WRDATA, reversed_addr);
+
+	if (adapter->ahw->flash_fdt.flash_manuf == adapter->flash_mfg_id)
+		qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+			(QLC_83XX_FLASH_FDT_ERASE_DEF_SIG |
+			adapter->ahw->flash_fdt.erase_cmd));
+	else
+		qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				QLC_83XX_FLASH_OEM_ERASE_SIG);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				QLC_83XX_FLASH_LAST_ERASE_MS_VAL);
+
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		qlcnic_83xx_unlock_flash(adapter);
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	if (adapter->ahw->flash_fdt.flash_manuf == adapter->flash_mfg_id) {
+		ret = qlcnic_83xx_disable_flash_write_op(adapter);
+		if (ret) {
+			qlcnic_83xx_unlock_flash(adapter);
+			dev_err(&adapter->pdev->dev,
+				 " %s: failed at %d\n", __func__, __LINE__);
+			return ret;
+		}
+	}
+
+	qlcnic_83xx_unlock_flash(adapter);
+
+	return 0;
+}
+
+int
+qlcnic_83xx_flash_write_u32(struct qlcnic_adapter *adapter, u32 addr,
+					u32 *p_data)
+{
+	int ret = -EIO;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+						0x00800000 | (addr >> 2));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA, *p_data);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				QLC_83XX_FLASH_LAST_ERASE_MS_VAL);
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+int
+qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
+					u32 *p_data, int u32_word_count)
+{
+	u32 temp;
+	int ret = -EIO, err;
+
+	if ((u32_word_count <  QLC_83XX_FLASH_BULK_WRITE_MIN) ||
+	(u32_word_count >  QLC_83XX_FLASH_BULK_WRITE_MAX)) {
+		dev_err(&adapter->pdev->dev,
+			 " %s: Invalid word count\n", __func__);
+		return -EIO;
+	}
+
+	temp = qlcnic_83xx_rd_reg_indirect(adapter,
+				QLC_83XX_FLASH_SPI_CONTROL, &err);
+	qlcnic_83xx_wrt_reg_indirect(adapter,
+				QLC_83XX_FLASH_SPI_CONTROL,
+				(temp | QLC_83XX_FLASH_SPI_CONTROL_VAL));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				QLC_83XX_FLASH_ADDR_TEMP_VAL);
+
+	/* First DWORD write */
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA, *p_data++);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				QLC_83XX_FLASH_FIRST_WRITE_MS_PATTERN);
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	u32_word_count--;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+			QLC_83XX_FLASH_ADDR_SECOND_TEMP_VAL);
+
+	/* Second to N-1 DWORD writes */
+	while (u32_word_count != 1) {
+		qlcnic_83xx_wrt_reg_indirect(adapter,
+					QLC_83XX_FLASH_WRDATA, *p_data++);
+		qlcnic_83xx_wrt_reg_indirect(adapter,
+					QLC_83XX_FLASH_CONTROL,
+					QLC_83XX_FLASH_SECOND_WRITE_MS_PATTERN);
+		ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+		if (ret) {
+			dev_err(&adapter->pdev->dev,
+				 " %s: failed at %d\n", __func__, __LINE__);
+			return -EIO;
+		}
+		u32_word_count--;
+	}
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				QLC_83XX_FLASH_ADDR_TEMP_VAL | (addr >> 2));
+	/* Last DWORD write */
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA, *p_data++);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				QLC_83XX_FLASH_LAST_WRITE_MS_PATTERN);
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	ret = qlcnic_83xx_rd_reg_indirect(adapter,
+				QLC_83XX_FLASH_SPI_STATUS, &err);
+	if ((ret & QLC_83XX_FLASH_SPI_CONTROL_VAL) ==
+	QLC_83XX_FLASH_SPI_CONTROL_VAL) {
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		/* Operation failed, clear error bit */
+		temp = qlcnic_83xx_rd_reg_indirect(adapter,
+					QLC_83XX_FLASH_SPI_CONTROL, &err);
+		qlcnic_83xx_wrt_reg_indirect(adapter,
+				QLC_83XX_FLASH_SPI_CONTROL,
+				(temp | QLC_83XX_FLASH_SPI_CONTROL_VAL));
+	}
+
+	return 0;
+}
+
+static int
+qlcnic_83xx_read_flash_status_reg(struct qlcnic_adapter *adapter)
+{
+	int ret, err;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				QLC_83XX_FLASH_OEM_READ_SIG);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				QLC_83XX_FLASH_READ_CONTROL_VAL);
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret)
+		return -EIO;
+
+	ret = qlcnic_83xx_rd_reg_indirect(adapter, QLC_83XX_FLASH_RDDATA, &err);
+	return ret&0xFF;
+}
+
+int qlcnic_83xx_flash_test(struct qlcnic_adapter *adapter)
+{
+	int status;
+
+	status = qlcnic_83xx_read_flash_status_reg(adapter);
+	if (status == -EIO) {
+		dev_info(&adapter->pdev->dev, "%s: EEPROM test failed.\n",
+			__func__);
+		return 1;
+	}
+	return 0;
+}
-- 
1.7.1
