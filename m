From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 07/12] qlcnic: 83xx adpater flash interface routines
Date: Thu,  6 Sep 2012 02:22:04 -0400
Message-ID: <1346912529-17406-8-git-send-email-sony.chacko@qlogic.com>
References: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7064 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750914Ab2IFGjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 02:39:20 -0400
In-Reply-To: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Flash interface routines for 83xx adapter

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   32 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  443 ++++++++++++++++++++
 2 files changed, 475 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 20adc2e..cd2dc08 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -307,6 +307,7 @@ struct uni_data_desc{
 
 /* Flash Defines and Structures */
 #define QLCNIC_FLT_LOCATION	0x3F1000
+#define QLCNIC_FDT_LOCATION     0x3F0000
 #define QLCNIC_B0_FW_IMAGE_REGION 0x74
 #define QLCNIC_C0_FW_IMAGE_REGION 0x97
 #define QLCNIC_BOOTLD_REGION    0X72
@@ -327,6 +328,36 @@ struct qlcnic_flt_entry {
 	u32 end_addr;
 };
 
+/* Flash Descriptor Table */
+struct qlcnic_fdt {
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
 /* Magic number to let user know flash is programmed */
 #define	QLCNIC_BDINFO_MAGIC 0x12345678
 
@@ -509,6 +540,7 @@ struct qlcnic_hardware_context {
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	struct qlcnic_fdt fdt;
 	struct qlcnic_83xx_reset reset;
 	struct qlcnic_83xx_idc idc;
 	struct qlcnic_83xx_fw_info fw_info;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 71bf46f..db6e3cc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2095,3 +2095,446 @@ out:
 	qlcnic_free_mbx_args(&cmd);
 	return err;
 }
+
+int
+qlcnic_83xx_lock_flash(struct qlcnic_adapter *adapter)
+{
+	int id, timeout = 0;
+	u32 status = 0;
+
+	while (status == 0) {
+		status = QLCRD(adapter, QLCNIC_FLASH_LOCK);
+		if (status)
+			break;
+
+		if (++timeout >= QLC_83XX_FLASH_LOCK_TIMEOUT) {
+			id = QLCRD(adapter, QLCNIC_FLASH_LOCK_OWNER);
+			dev_err(&adapter->pdev->dev,
+				"%s: failed: lock held by %d\n", __func__, id);
+			return -EIO;
+		}
+		usleep_range(1000, 2000);
+	}
+
+	QLCWR(adapter, QLCNIC_FLASH_LOCK_OWNER, adapter->portnum);
+	return 0;
+}
+
+void
+qlcnic_83xx_unlock_flash(struct qlcnic_adapter *adapter)
+{
+	QLCRD(adapter, QLCNIC_FLASH_UNLOCK);
+	QLCWR(adapter, QLCNIC_FLASH_LOCK_OWNER, 0xFF);
+}
+
+int
+qlcnic_83xx_flash_read32(struct qlcnic_adapter *adapter, u32 flash_addr,
+			 u8 *p_data, int count)
+{
+	int i, err;
+	u32 word;
+	u32 indirect_addr, addr = flash_addr;
+
+	if (qlcnic_83xx_lock_flash(adapter) != 0)
+		return -EIO;
+
+	if (addr & 0x3) {
+		dev_err(&adapter->pdev->dev, "Illegal addr = 0x%x\n", addr);
+		qlcnic_83xx_unlock_flash(adapter);
+		return -EIO;
+	}
+
+	for (i = 0; i < count; i++) {
+		if (qlcnic_83xx_wrt_reg_indirect(adapter,
+						 QLC_83XX_FLASH_DIRECT_WINDOW,
+						 (addr))) {
+			qlcnic_83xx_unlock_flash(adapter);
+			return -EIO;
+		}
+
+		indirect_addr = QLC_83XX_FLASH_DIRECT_DATA(addr);
+
+		word = qlcnic_83xx_rd_reg_indirect(adapter,
+						   indirect_addr,
+						   &err);
+		*(__le32 *)p_data  = le32_to_cpu(word);
+		p_data = p_data + 4;
+		addr = addr + 4;
+	}
+
+	qlcnic_83xx_unlock_flash(adapter);
+
+	return 0;
+}
+
+int
+qlcnic_83xx_lockless_flash_read32(struct qlcnic_adapter *adapter,
+				  u32 flash_addr, u8 *p_data, int count)
+{
+	int err;
+	u32 i, word, flash_offset;
+	u32 indirect_add, direct_window, addr = flash_addr;
+
+	flash_offset = addr & (QLCNIC_FLASH_SECTOR_SIZE - 1);
+
+	if (addr & 0x3) {
+		dev_err(&adapter->pdev->dev, "Illegal addr = 0x%x\n", addr);
+		return -EIO;
+	}
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_DIRECT_WINDOW,
+				     (addr));
+
+	/* Check if data is spread across multiple sectors  */
+	if ((flash_offset + (count * sizeof(u32))) >
+				(QLCNIC_FLASH_SECTOR_SIZE - 1)) {
+
+		/* Multi sector read */
+		for (i = 0; i < count; i++) {
+			indirect_add = QLC_83XX_FLASH_DIRECT_DATA(addr);
+			word = qlcnic_83xx_rd_reg_indirect(adapter,
+							   indirect_add,
+							   &err);
+
+			*(__le32 *)p_data  = le32_to_cpu(word);
+			p_data = p_data + 4;
+			addr = addr + 4;
+			flash_offset = flash_offset + 4;
+
+			if (flash_offset > (QLCNIC_FLASH_SECTOR_SIZE - 1)) {
+				direct_window = QLC_83XX_FLASH_DIRECT_WINDOW;
+				/* This write is needed once for each sector */
+				qlcnic_83xx_wrt_reg_indirect(adapter,
+							     direct_window,
+							     (addr));
+				flash_offset = 0;
+			}
+		}
+	} else {
+		/* Single sector read */
+		for (i = 0; i < count; i++) {
+			indirect_add = QLC_83XX_FLASH_DIRECT_DATA(addr);
+			word = qlcnic_83xx_rd_reg_indirect(adapter,
+							   indirect_add,
+							   &err);
+			*(__le32 *)p_data  = cpu_to_le32(word);
+			p_data = p_data + 4;
+			addr = addr + 4;
+		}
+	}
+
+	return 0;
+}
+
+static int
+qlcnic_83xx_poll_flash_status_reg(struct qlcnic_adapter *adapter)
+{
+	u32 status;
+	int err, retries = QLC_83XX_FLASH_READ_RETRY_COUNT;
+
+	do {
+		status = qlcnic_83xx_rd_reg_indirect(adapter,
+						     QLC_83XX_FLASH_STATUS,
+						     &err);
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
+				     (QLC_83XX_FLASH_FDT_WRITE_DEF_SIG |
+				     adapter->ahw->fdt.write_statusreg_cmd));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
+				     adapter->ahw->fdt.write_enable_bits);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
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
+				     (QLC_83XX_FLASH_FDT_WRITE_DEF_SIG |
+				     adapter->ahw->fdt.write_statusreg_cmd));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
+				     adapter->ahw->fdt.write_enable_bits);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
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
+				     QLC_83XX_FLASH_FDT_READ_MFG_ID_VAL);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_READ_CTRL);
+
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		qlcnic_83xx_unlock_flash(adapter);
+		return -EIO;
+	}
+
+	mfg_id = qlcnic_83xx_rd_reg_indirect(adapter, QLC_83XX_FLASH_RDDATA,
+					     &ret);
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
+	fdt_size = sizeof(struct qlcnic_fdt);
+	count = fdt_size/sizeof(u32);
+
+	if (qlcnic_83xx_lock_flash(adapter))
+		return -EIO;
+
+	memset(&adapter->ahw->fdt, 0, fdt_size);
+	ret = qlcnic_83xx_lockless_flash_read32(adapter, QLCNIC_FDT_LOCATION,
+						(u8 *)&adapter->ahw->fdt,
+						count);
+
+	qlcnic_83xx_unlock_flash(adapter);
+	return ret;
+}
+
+int
+qlcnic_83xx_erase_flash_sector(struct qlcnic_adapter *adapter,
+			       u32 sector_start_addr)
+{
+	u32 reversed_addr;
+	int ret = -EIO;
+
+	if (qlcnic_83xx_lock_flash(adapter) != 0)
+		return -EIO;
+
+	if (adapter->ahw->fdt.flash_manuf == adapter->flash_mfg_id) {
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
+			"%s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	reversed_addr = (((sector_start_addr & 0xFF) << 16) |
+			((sector_start_addr & 0xFF0000) >> 16));
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
+				     reversed_addr);
+
+	if (adapter->ahw->fdt.flash_manuf == adapter->flash_mfg_id)
+		qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+					     (QLC_83XX_FLASH_FDT_ERASE_DEF_SIG |
+					     adapter->ahw->fdt.erase_cmd));
+	else
+		qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+					     QLC_83XX_FLASH_OEM_ERASE_SIG);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_LAST_ERASE_MS_VAL);
+
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		qlcnic_83xx_unlock_flash(adapter);
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	if (adapter->ahw->fdt.flash_manuf == adapter->flash_mfg_id) {
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
+qlcnic_83xx_flash_write32(struct qlcnic_adapter *adapter, u32 addr, u32 *p_data)
+{
+	int ret = -EIO;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				     0x00800000 | (addr >> 2));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA, *p_data);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_LAST_ERASE_MS_VAL);
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			"%s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+int
+qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
+			     u32 *p_data, int count)
+{
+	u32 temp;
+	int ret = -EIO, err;
+
+	if ((count <  QLC_83XX_FLASH_BULK_WRITE_MIN) ||
+	(count >  QLC_83XX_FLASH_BULK_WRITE_MAX)) {
+		dev_err(&adapter->pdev->dev,
+			" %s: Invalid word count\n", __func__);
+		return -EIO;
+	}
+
+	temp = qlcnic_83xx_rd_reg_indirect(adapter, QLC_83XX_FLASH_SPI_CONTROL,
+					   &err);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_SPI_CONTROL,
+				     (temp | QLC_83XX_FLASH_SPI_CTRL));
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				     QLC_83XX_FLASH_ADDR_TEMP_VAL);
+
+	/* First DWORD write */
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA, *p_data++);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_FIRST_MS_PATTERN);
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			"%s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	count--;
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				     QLC_83XX_FLASH_ADDR_SECOND_TEMP_VAL);
+
+	/* Second to N-1 DWORD writes */
+	while (count != 1) {
+		qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
+					     *p_data++);
+		qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+					     QLC_83XX_FLASH_SECOND_MS_PATTERN);
+		ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+		if (ret) {
+			dev_err(&adapter->pdev->dev,
+				 " %s: failed at %d\n", __func__, __LINE__);
+			return -EIO;
+		}
+		count--;
+	}
+
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
+				     QLC_83XX_FLASH_ADDR_TEMP_VAL |
+				     (addr >> 2));
+	/* Last DWORD write */
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA, *p_data++);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_LAST_MS_PATTERN);
+	ret = qlcnic_83xx_poll_flash_status_reg(adapter);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		return -EIO;
+	}
+
+	ret = qlcnic_83xx_rd_reg_indirect(adapter, QLC_83XX_FLASH_SPI_STATUS,
+					  &err);
+	if ((ret & QLC_83XX_FLASH_SPI_CTRL) ==
+	QLC_83XX_FLASH_SPI_CTRL) {
+		dev_err(&adapter->pdev->dev,
+			 " %s: failed at %d\n", __func__, __LINE__);
+		/* Operation failed, clear error bit */
+		temp = qlcnic_83xx_rd_reg_indirect(adapter,
+						   QLC_83XX_FLASH_SPI_CONTROL,
+						   &err);
+		qlcnic_83xx_wrt_reg_indirect(adapter,
+					     QLC_83XX_FLASH_SPI_CONTROL,
+					     (temp | QLC_83XX_FLASH_SPI_CTRL));
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
+				     QLC_83XX_FLASH_OEM_READ_SIG);
+	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
+				     QLC_83XX_FLASH_READ_CTRL);
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
+			 __func__);
+		return 1;
+	}
+	return 0;
+}
-- 
1.7.1
