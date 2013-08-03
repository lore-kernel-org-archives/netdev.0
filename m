From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 8/8] qlcnic: Fix for flash update failure on 83xx adapter
Date: Fri, 2 Aug 2013 23:16:01 -0400
Message-ID: <1375499761-21141-9-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59763 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713Ab3HCECb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 00:02:31 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Flash update routine was improperly checking register read API return value.
Modify register read API and perform proper error check.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   12 +--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  101 ++++++++++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   91 ++++++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |   10 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   63 +++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   40 +++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   25 ++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   17 ++--
 10 files changed, 231 insertions(+), 132 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index f4bb8f5..221645e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1400,8 +1400,8 @@ void qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *, u64, u64);
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) < (high)) && ((addr) >= (low)))
 
-#define QLCRD32(adapter, off) \
-	(adapter->ahw->hw_ops->read_reg)(adapter, off)
+#define QLCRD32(adapter, off, err) \
+	(adapter->ahw->hw_ops->read_reg)(adapter, off, err)
 
 #define QLCWR32(adapter, off, val) \
 	adapter->ahw->hw_ops->write_reg(adapter, off, val)
@@ -1604,7 +1604,7 @@ struct qlcnic_nic_template {
 struct qlcnic_hardware_ops {
 	void (*read_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
 	void (*write_crb) (struct qlcnic_adapter *, char *, loff_t, size_t);
-	int (*read_reg) (struct qlcnic_adapter *, ulong);
+	int (*read_reg) (struct qlcnic_adapter *, ulong, int *);
 	int (*write_reg) (struct qlcnic_adapter *, ulong, u32);
 	void (*get_ocm_win) (struct qlcnic_hardware_context *);
 	int (*get_mac_address) (struct qlcnic_adapter *, u8 *);
@@ -1662,12 +1662,6 @@ static inline void qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
 	adapter->ahw->hw_ops->write_crb(adapter, buf, offset, size);
 }
 
-static inline int qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter,
-				       ulong off)
-{
-	return adapter->ahw->hw_ops->read_reg(adapter, off);
-}
-
 static inline int qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter,
 					ulong off, u32 data)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 94ff7a4..92da998 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -228,17 +228,17 @@ static int __qlcnic_set_win_base(struct qlcnic_adapter *adapter, u32 addr)
 	return 0;
 }
 
-int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *adapter, ulong addr)
+int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *adapter, ulong addr,
+				int *err)
 {
-	int ret;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	ret = __qlcnic_set_win_base(adapter, (u32) addr);
-	if (!ret) {
+	*err = __qlcnic_set_win_base(adapter, (u32) addr);
+	if (!*err) {
 		return QLCRDX(ahw, QLCNIC_WILDCARD);
 	} else {
 		dev_err(&adapter->pdev->dev,
-			"%s failed, addr = 0x%x\n", __func__, (int)addr);
+			"%s failed, addr = 0x%lx\n", __func__, addr);
 		return -EIO;
 	}
 }
@@ -561,7 +561,7 @@ void qlcnic_83xx_cam_unlock(struct qlcnic_adapter *adapter)
 void qlcnic_83xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 			  loff_t offset, size_t size)
 {
-	int ret;
+	int ret = 0;
 	u32 data;
 
 	if (qlcnic_api_lock(adapter)) {
@@ -571,7 +571,7 @@ void qlcnic_83xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 		return;
 	}
 
-	ret = qlcnic_83xx_rd_reg_indirect(adapter, (u32) offset);
+	data = QLCRD32(adapter, (u32) offset, &ret);
 	qlcnic_api_unlock(adapter);
 
 	if (ret == -EIO) {
@@ -580,7 +580,6 @@ void qlcnic_83xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 			__func__, (u32)offset);
 		return;
 	}
-	data = ret;
 	memcpy(buf, &data, size);
 }
 
@@ -2391,9 +2390,9 @@ int qlcnic_83xx_lockless_flash_read32(struct qlcnic_adapter *adapter,
 				      u32 flash_addr, u8 *p_data,
 				      int count)
 {
-	int i, ret;
-	u32 word, range, flash_offset, addr = flash_addr;
+	u32 word, range, flash_offset, addr = flash_addr, ret;
 	ulong indirect_add, direct_window;
+	int i, err = 0;
 
 	flash_offset = addr & (QLCNIC_FLASH_SECTOR_SIZE - 1);
 	if (addr & 0x3) {
@@ -2411,10 +2410,9 @@ int qlcnic_83xx_lockless_flash_read32(struct qlcnic_adapter *adapter,
 		/* Multi sector read */
 		for (i = 0; i < count; i++) {
 			indirect_add = QLC_83XX_FLASH_DIRECT_DATA(addr);
-			ret = qlcnic_83xx_rd_reg_indirect(adapter,
-							  indirect_add);
-			if (ret == -EIO)
-				return -EIO;
+			ret = QLCRD32(adapter, indirect_add, &err);
+			if (err == -EIO)
+				return err;
 
 			word = ret;
 			*(u32 *)p_data  = word;
@@ -2435,10 +2433,9 @@ int qlcnic_83xx_lockless_flash_read32(struct qlcnic_adapter *adapter,
 		/* Single sector read */
 		for (i = 0; i < count; i++) {
 			indirect_add = QLC_83XX_FLASH_DIRECT_DATA(addr);
-			ret = qlcnic_83xx_rd_reg_indirect(adapter,
-							  indirect_add);
-			if (ret == -EIO)
-				return -EIO;
+			ret = QLCRD32(adapter, indirect_add, &err);
+			if (err == -EIO)
+				return err;
 
 			word = ret;
 			*(u32 *)p_data  = word;
@@ -2454,10 +2451,13 @@ static int qlcnic_83xx_poll_flash_status_reg(struct qlcnic_adapter *adapter)
 {
 	u32 status;
 	int retries = QLC_83XX_FLASH_READ_RETRY_COUNT;
+	int err = 0;
 
 	do {
-		status = qlcnic_83xx_rd_reg_indirect(adapter,
-						     QLC_83XX_FLASH_STATUS);
+		status = QLCRD32(adapter, QLC_83XX_FLASH_STATUS, &err);
+		if (err == -EIO)
+			return err;
+
 		if ((status & QLC_83XX_FLASH_STATUS_READY) ==
 		    QLC_83XX_FLASH_STATUS_READY)
 			break;
@@ -2509,7 +2509,8 @@ int qlcnic_83xx_disable_flash_write(struct qlcnic_adapter *adapter)
 
 int qlcnic_83xx_read_flash_mfg_id(struct qlcnic_adapter *adapter)
 {
-	int ret, mfg_id;
+	int ret, err = 0;
+	u32 mfg_id;
 
 	if (qlcnic_83xx_lock_flash(adapter))
 		return -EIO;
@@ -2524,9 +2525,11 @@ int qlcnic_83xx_read_flash_mfg_id(struct qlcnic_adapter *adapter)
 		return -EIO;
 	}
 
-	mfg_id = qlcnic_83xx_rd_reg_indirect(adapter, QLC_83XX_FLASH_RDDATA);
-	if (mfg_id == -EIO)
-		return -EIO;
+	mfg_id = QLCRD32(adapter, QLC_83XX_FLASH_RDDATA, &err);
+	if (err == -EIO) {
+		qlcnic_83xx_unlock_flash(adapter);
+		return err;
+	}
 
 	adapter->flash_mfg_id = (mfg_id & 0xFF);
 	qlcnic_83xx_unlock_flash(adapter);
@@ -2643,7 +2646,7 @@ int qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
 				 u32 *p_data, int count)
 {
 	u32 temp;
-	int ret = -EIO;
+	int ret = -EIO, err = 0;
 
 	if ((count < QLC_83XX_FLASH_WRITE_MIN) ||
 	    (count > QLC_83XX_FLASH_WRITE_MAX)) {
@@ -2652,8 +2655,10 @@ int qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
 		return -EIO;
 	}
 
-	temp = qlcnic_83xx_rd_reg_indirect(adapter,
-					   QLC_83XX_FLASH_SPI_CONTROL);
+	temp = QLCRD32(adapter, QLC_83XX_FLASH_SPI_CONTROL, &err);
+	if (err == -EIO)
+		return err;
+
 	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_SPI_CONTROL,
 				     (temp | QLC_83XX_FLASH_SPI_CTRL));
 	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
@@ -2702,13 +2707,18 @@ int qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
 		return -EIO;
 	}
 
-	ret = qlcnic_83xx_rd_reg_indirect(adapter, QLC_83XX_FLASH_SPI_STATUS);
+	ret = QLCRD32(adapter, QLC_83XX_FLASH_SPI_STATUS, &err);
+	if (err == -EIO)
+		return err;
+
 	if ((ret & QLC_83XX_FLASH_SPI_CTRL) == QLC_83XX_FLASH_SPI_CTRL) {
 		dev_err(&adapter->pdev->dev, "%s: failed at %d\n",
 			__func__, __LINE__);
 		/* Operation failed, clear error bit */
-		temp = qlcnic_83xx_rd_reg_indirect(adapter,
-						   QLC_83XX_FLASH_SPI_CONTROL);
+		temp = QLCRD32(adapter, QLC_83XX_FLASH_SPI_CONTROL, &err);
+		if (err == -EIO)
+			return err;
+
 		qlcnic_83xx_wrt_reg_indirect(adapter,
 					     QLC_83XX_FLASH_SPI_CONTROL,
 					     (temp | QLC_83XX_FLASH_SPI_CTRL));
@@ -2830,6 +2840,7 @@ int qlcnic_83xx_ms_mem_write128(struct qlcnic_adapter *adapter, u64 addr,
 {
 	int i, j, ret = 0;
 	u32 temp;
+	int err = 0;
 
 	/* Check alignment */
 	if (addr & 0xF)
@@ -2862,8 +2873,12 @@ int qlcnic_83xx_ms_mem_write128(struct qlcnic_adapter *adapter, u64 addr,
 					     QLCNIC_TA_WRITE_START);
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			temp = qlcnic_83xx_rd_reg_indirect(adapter,
-							   QLCNIC_MS_CTRL);
+			temp = QLCRD32(adapter, QLCNIC_MS_CTRL, &err);
+			if (err == -EIO) {
+				mutex_unlock(&adapter->ahw->mem_lock);
+				return err;
+			}
+
 			if ((temp & TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -2885,9 +2900,9 @@ int qlcnic_83xx_ms_mem_write128(struct qlcnic_adapter *adapter, u64 addr,
 int qlcnic_83xx_flash_read32(struct qlcnic_adapter *adapter, u32 flash_addr,
 			     u8 *p_data, int count)
 {
-	int i, ret;
-	u32 word, addr = flash_addr;
+	u32 word, addr = flash_addr, ret;
 	ulong  indirect_addr;
+	int i, err = 0;
 
 	if (qlcnic_83xx_lock_flash(adapter) != 0)
 		return -EIO;
@@ -2907,10 +2922,10 @@ int qlcnic_83xx_flash_read32(struct qlcnic_adapter *adapter, u32 flash_addr,
 		}
 
 		indirect_addr = QLC_83XX_FLASH_DIRECT_DATA(addr);
-		ret = qlcnic_83xx_rd_reg_indirect(adapter,
-						  indirect_addr);
-		if (ret == -EIO)
-			return -EIO;
+		ret = QLCRD32(adapter, indirect_addr, &err);
+		if (err == -EIO)
+			return err;
+
 		word = ret;
 		*(u32 *)p_data  = word;
 		p_data = p_data + 4;
@@ -3376,7 +3391,8 @@ int qlcnic_83xx_set_pauseparam(struct qlcnic_adapter *adapter,
 
 static int qlcnic_83xx_read_flash_status_reg(struct qlcnic_adapter *adapter)
 {
-	int ret;
+	int ret, err = 0;
+	u32 temp;
 
 	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
 				     QLC_83XX_FLASH_OEM_READ_SIG);
@@ -3386,8 +3402,11 @@ static int qlcnic_83xx_read_flash_status_reg(struct qlcnic_adapter *adapter)
 	if (ret)
 		return -EIO;
 
-	ret = qlcnic_83xx_rd_reg_indirect(adapter, QLC_83XX_FLASH_RDDATA);
-	return ret & 0xFF;
+	temp = QLCRD32(adapter, QLC_83XX_FLASH_RDDATA, &err);
+	if (err == -EIO)
+		return err;
+
+	return temp & 0xFF;
 }
 
 int qlcnic_83xx_flash_test(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 2548d14..272f56a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -508,7 +508,7 @@ void qlcnic_83xx_add_sysfs(struct qlcnic_adapter *);
 void qlcnic_83xx_remove_sysfs(struct qlcnic_adapter *);
 void qlcnic_83xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
 void qlcnic_83xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
-int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *, ulong);
+int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *, ulong, int *);
 int qlcnic_83xx_wrt_reg_indirect(struct qlcnic_adapter *, ulong, u32);
 void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *, int, u64 []);
 int qlcnic_83xx_nic_set_promisc(struct qlcnic_adapter *, u32);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 51ab4b5..9f4b8d5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1303,8 +1303,11 @@ static void qlcnic_83xx_dump_pause_control_regs(struct qlcnic_adapter *adapter)
 {
 	int i, j;
 	u32 val = 0, val1 = 0, reg = 0;
+	int err = 0;
 
-	val = QLCRD32(adapter, QLC_83XX_SRE_SHIM_REG);
+	val = QLCRD32(adapter, QLC_83XX_SRE_SHIM_REG, &err);
+	if (err == -EIO)
+		return;
 	dev_info(&adapter->pdev->dev, "SRE-Shim Ctrl:0x%x\n", val);
 
 	for (j = 0; j < 2; j++) {
@@ -1318,7 +1321,9 @@ static void qlcnic_83xx_dump_pause_control_regs(struct qlcnic_adapter *adapter)
 			reg = QLC_83XX_PORT1_THRESHOLD;
 		}
 		for (i = 0; i < 8; i++) {
-			val = QLCRD32(adapter, reg + (i * 0x4));
+			val = QLCRD32(adapter, reg + (i * 0x4), &err);
+			if (err == -EIO)
+				return;
 			dev_info(&adapter->pdev->dev, "0x%x  ", val);
 		}
 		dev_info(&adapter->pdev->dev, "\n");
@@ -1335,8 +1340,10 @@ static void qlcnic_83xx_dump_pause_control_regs(struct qlcnic_adapter *adapter)
 			reg = QLC_83XX_PORT1_TC_MC_REG;
 		}
 		for (i = 0; i < 4; i++) {
-			val = QLCRD32(adapter, reg + (i * 0x4));
-			 dev_info(&adapter->pdev->dev, "0x%x  ", val);
+			val = QLCRD32(adapter, reg + (i * 0x4), &err);
+			if (err == -EIO)
+				return;
+			dev_info(&adapter->pdev->dev, "0x%x  ", val);
 		}
 		dev_info(&adapter->pdev->dev, "\n");
 	}
@@ -1352,17 +1359,25 @@ static void qlcnic_83xx_dump_pause_control_regs(struct qlcnic_adapter *adapter)
 			reg = QLC_83XX_PORT1_TC_STATS;
 		}
 		for (i = 7; i >= 0; i--) {
-			val = QLCRD32(adapter, reg);
+			val = QLCRD32(adapter, reg, &err);
+			if (err == -EIO)
+				return;
 			val &= ~(0x7 << 29);    /* Reset bits 29 to 31 */
 			QLCWR32(adapter, reg, (val | (i << 29)));
-			val = QLCRD32(adapter, reg);
+			val = QLCRD32(adapter, reg, &err);
+			if (err == -EIO)
+				return;
 			dev_info(&adapter->pdev->dev, "0x%x  ", val);
 		}
 		dev_info(&adapter->pdev->dev, "\n");
 	}
 
-	val = QLCRD32(adapter, QLC_83XX_PORT2_IFB_THRESHOLD);
-	val1 = QLCRD32(adapter, QLC_83XX_PORT3_IFB_THRESHOLD);
+	val = QLCRD32(adapter, QLC_83XX_PORT2_IFB_THRESHOLD, &err);
+	if (err == -EIO)
+		return;
+	val1 = QLCRD32(adapter, QLC_83XX_PORT3_IFB_THRESHOLD, &err);
+	if (err == -EIO)
+		return;
 	dev_info(&adapter->pdev->dev,
 		 "IFB-Pause Thresholds: Port 2:0x%x, Port 3:0x%x\n",
 		 val, val1);
@@ -1425,7 +1440,7 @@ static void qlcnic_83xx_take_eport_out_of_reset(struct qlcnic_adapter *adapter)
 static int qlcnic_83xx_check_heartbeat(struct qlcnic_adapter *p_dev)
 {
 	u32 heartbeat, peg_status;
-	int retries, ret = -EIO;
+	int retries, ret = -EIO, err = 0;
 
 	retries = QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT;
 	p_dev->heartbeat = QLC_SHARED_REG_RD32(p_dev,
@@ -1453,11 +1468,11 @@ static int qlcnic_83xx_check_heartbeat(struct qlcnic_adapter *p_dev)
 			 "PEG_NET_2_PC: 0x%x, PEG_NET_3_PC: 0x%x,\n"
 			 "PEG_NET_4_PC: 0x%x\n", peg_status,
 			 QLC_SHARED_REG_RD32(p_dev, QLCNIC_PEG_HALT_STATUS2),
-			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_0),
-			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_1),
-			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_2),
-			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_3),
-			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_4));
+			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_0, &err),
+			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_1, &err),
+			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_2, &err),
+			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_3, &err),
+			 QLCRD32(p_dev, QLC_83XX_CRB_PEG_NET_4, &err));
 
 		if (QLCNIC_FWERROR_CODE(peg_status) == 0x67)
 			dev_err(&p_dev->pdev->dev,
@@ -1501,18 +1516,22 @@ int qlcnic_83xx_check_hw_status(struct qlcnic_adapter *p_dev)
 static int qlcnic_83xx_poll_reg(struct qlcnic_adapter *p_dev, u32 addr,
 				int duration, u32 mask, u32 status)
 {
+	int timeout_error, err = 0;
 	u32 value;
-	int timeout_error;
 	u8 retries;
 
-	value = qlcnic_83xx_rd_reg_indirect(p_dev, addr);
+	value = QLCRD32(p_dev, addr, &err);
+	if (err == -EIO)
+		return err;
 	retries = duration / 10;
 
 	do {
 		if ((value & mask) != status) {
 			timeout_error = 1;
 			msleep(duration / 10);
-			value = qlcnic_83xx_rd_reg_indirect(p_dev, addr);
+			value = QLCRD32(p_dev, addr, &err);
+			if (err == -EIO)
+				return err;
 		} else {
 			timeout_error = 0;
 			break;
@@ -1606,9 +1625,12 @@ int qlcnic_83xx_get_reset_instruction_template(struct qlcnic_adapter *p_dev)
 static void qlcnic_83xx_read_write_crb_reg(struct qlcnic_adapter *p_dev,
 					   u32 raddr, u32 waddr)
 {
-	int value;
+	int err = 0;
+	u32 value;
 
-	value = qlcnic_83xx_rd_reg_indirect(p_dev, raddr);
+	value = QLCRD32(p_dev, raddr, &err);
+	if (err == -EIO)
+		return;
 	qlcnic_83xx_wrt_reg_indirect(p_dev, waddr, value);
 }
 
@@ -1617,12 +1639,16 @@ static void qlcnic_83xx_rmw_crb_reg(struct qlcnic_adapter *p_dev,
 				    u32 raddr, u32 waddr,
 				    struct qlc_83xx_rmw *p_rmw_hdr)
 {
-	int value;
+	int err = 0;
+	u32 value;
 
-	if (p_rmw_hdr->index_a)
+	if (p_rmw_hdr->index_a) {
 		value = p_dev->ahw->reset.array[p_rmw_hdr->index_a];
-	else
-		value = qlcnic_83xx_rd_reg_indirect(p_dev, raddr);
+	} else {
+		value = QLCRD32(p_dev, raddr, &err);
+		if (err == -EIO)
+			return;
+	}
 
 	value &= p_rmw_hdr->mask;
 	value <<= p_rmw_hdr->shl;
@@ -1675,7 +1701,7 @@ static void qlcnic_83xx_poll_list(struct qlcnic_adapter *p_dev,
 	long delay;
 	struct qlc_83xx_entry *entry;
 	struct qlc_83xx_poll *poll;
-	int i;
+	int i, err = 0;
 	unsigned long arg1, arg2;
 
 	poll = (struct qlc_83xx_poll *)((char *)p_hdr +
@@ -1699,10 +1725,12 @@ static void qlcnic_83xx_poll_list(struct qlcnic_adapter *p_dev,
 							 arg1, delay,
 							 poll->mask,
 							 poll->status)){
-					qlcnic_83xx_rd_reg_indirect(p_dev,
-								    arg1);
-					qlcnic_83xx_rd_reg_indirect(p_dev,
-								    arg2);
+					QLCRD32(p_dev, arg1, &err);
+					if (err == -EIO)
+						return;
+					QLCRD32(p_dev, arg2, &err);
+					if (err == -EIO)
+						return;
 				}
 			}
 		}
@@ -1768,7 +1796,7 @@ static void qlcnic_83xx_poll_read_list(struct qlcnic_adapter *p_dev,
 				       struct qlc_83xx_entry_hdr *p_hdr)
 {
 	long delay;
-	int index, i, j;
+	int index, i, j, err;
 	struct qlc_83xx_quad_entry *entry;
 	struct qlc_83xx_poll *poll;
 	unsigned long addr;
@@ -1788,7 +1816,10 @@ static void qlcnic_83xx_poll_read_list(struct qlcnic_adapter *p_dev,
 						  poll->mask, poll->status)){
 				index = p_dev->ahw->reset.array_index;
 				addr = entry->dr_addr;
-				j = qlcnic_83xx_rd_reg_indirect(p_dev, addr);
+				j = QLCRD32(p_dev, addr, &err);
+				if (err == -EIO)
+					return;
+
 				p_dev->ahw->reset.array[index++] = j;
 
 				if (index == QLC_83XX_MAX_RESET_SEQ_ENTRIES)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 8d401ba..d09389b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -104,7 +104,7 @@ static u32
 qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 {
 	u32 rsp;
-	int timeout = 0;
+	int timeout = 0, err = 0;
 
 	do {
 		/* give atleast 1ms for firmware to respond */
@@ -113,7 +113,7 @@ qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 		if (++timeout > QLCNIC_OS_CRB_RETRY_COUNT)
 			return QLCNIC_CDRP_RSP_TIMEOUT;
 
-		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET);
+		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET, &err);
 	} while (!QLCNIC_CDRP_IS_RSP(rsp));
 
 	return rsp;
@@ -122,7 +122,7 @@ qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 			  struct qlcnic_cmd_args *cmd)
 {
-	int i;
+	int i, err = 0;
 	u32 rsp;
 	u32 signature;
 	struct pci_dev *pdev = adapter->pdev;
@@ -148,7 +148,7 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 		dev_err(&pdev->dev, "card response timeout.\n");
 		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
 	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
-		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1));
+		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1), &err);
 		switch (cmd->rsp.arg[0]) {
 		case QLCNIC_RCODE_INVALID_ARGS:
 			fmt = "CDRP invalid args: [%d]\n";
@@ -175,7 +175,7 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
 
 	for (i = 1; i < cmd->rsp.num; i++)
-		cmd->rsp.arg[i] = QLCRD32(adapter, QLCNIC_CDRP_ARG(i));
+		cmd->rsp.arg[i] = QLCRD32(adapter, QLCNIC_CDRP_ARG(i), &err);
 
 	/* Release semaphore */
 	qlcnic_api_unlock(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index ac42cde..7aac23a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -267,7 +267,7 @@ int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 speed, reg;
-	int check_sfp_module = 0;
+	int check_sfp_module = 0, err = 0;
 	u16 pcifn = ahw->pci_func;
 
 	/* read which mode */
@@ -290,7 +290,7 @@ int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
 
 	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		u32 val = 0;
-		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
+		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
 
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
@@ -303,7 +303,7 @@ int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
 		if (netif_running(adapter->netdev) && ahw->has_link_events) {
 			if (ahw->linkup) {
 				reg = QLCRD32(adapter,
-					      P3P_LINK_SPEED_REG(pcifn));
+					      P3P_LINK_SPEED_REG(pcifn), &err);
 				speed = P3P_LINK_SPEED_VAL(pcifn, reg);
 				ahw->link_speed = speed * P3P_LINK_SPEED_MHZ;
 			}
@@ -468,13 +468,14 @@ static int qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 static int qlcnic_82xx_get_registers(struct qlcnic_adapter *adapter,
 				     u32 *regs_buff)
 {
-	int i, j = 0;
+	int i, j = 0, err = 0;
 
 	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
 		regs_buff[i] = QLC_SHARED_REG_RD32(adapter, diag_registers[j]);
 	j = 0;
 	while (ext_diag_registers[j] != -1)
-		regs_buff[i++] = QLCRD32(adapter, ext_diag_registers[j++]);
+		regs_buff[i++] = QLCRD32(adapter, ext_diag_registers[j++],
+					 &err);
 	return i;
 }
 
@@ -524,13 +525,16 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 static u32 qlcnic_test_link(struct net_device *dev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int err = 0;
 	u32 val;
 
 	if (qlcnic_83xx_check(adapter)) {
 		val = qlcnic_83xx_test_link(adapter);
 		return (val & 1) ? 0 : 1;
 	}
-	val = QLCRD32(adapter, CRB_XG_STATE_P3P);
+	val = QLCRD32(adapter, CRB_XG_STATE_P3P, &err);
+	if (err == -EIO)
+		return err;
 	val = XG_LINK_STATE_P3P(adapter->ahw->pci_func, val);
 	return (val == XG_LINK_UP_P3P) ? 0 : 1;
 }
@@ -663,6 +667,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int port = adapter->ahw->physical_port;
+	int err = 0;
 	__u32 val;
 
 	if (qlcnic_83xx_check(adapter)) {
@@ -673,9 +678,13 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port));
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), &err);
+		if (err == -EIO)
+			return;
 		pause->rx_pause = qlcnic_gb_get_rx_flowctl(val);
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, &err);
+		if (err == -EIO)
+			return;
 		switch (port) {
 		case 0:
 			pause->tx_pause = !(qlcnic_gb_get_gb0_mask(val));
@@ -695,7 +704,9 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
+		if (err == -EIO)
+			return;
 		if (port == 0)
 			pause->tx_pause = !(qlcnic_xg_get_xg0_mask(val));
 		else
@@ -712,6 +723,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int port = adapter->ahw->physical_port;
+	int err = 0;
 	__u32 val;
 
 	if (qlcnic_83xx_check(adapter))
@@ -722,7 +734,9 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port));
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), &err);
+		if (err == -EIO)
+			return err;
 
 		if (pause->rx_pause)
 			qlcnic_gb_rx_flowctl(val);
@@ -733,7 +747,9 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 				val);
 		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), val);
 		/* set autoneg */
-		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, &err);
+		if (err == -EIO)
+			return err;
 		switch (port) {
 		case 0:
 			if (pause->tx_pause)
@@ -769,7 +785,9 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return -EIO;
 
-		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
+		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, &err);
+		if (err == -EIO)
+			return err;
 		if (port == 0) {
 			if (pause->tx_pause)
 				qlcnic_xg_unset_xg0_mask(val);
@@ -793,11 +811,14 @@ static int qlcnic_reg_test(struct net_device *dev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 data_read;
+	int err = 0;
 
 	if (qlcnic_83xx_check(adapter))
 		return qlcnic_83xx_reg_test(adapter);
 
-	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0));
+	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0), &err);
+	if (err == -EIO)
+		return err;
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
 		return 1;
 
@@ -1269,17 +1290,20 @@ qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 wol_cfg;
+	int err = 0;
 
 	if (qlcnic_83xx_check(adapter))
 		return;
 	wol->supported = 0;
 	wol->wolopts = 0;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
+	if (err == -EIO)
+		return;
 	if (wol_cfg & (1UL << adapter->portnum))
 		wol->supported |= WAKE_MAGIC;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
 	if (wol_cfg & (1UL << adapter->portnum))
 		wol->wolopts |= WAKE_MAGIC;
 }
@@ -1289,17 +1313,22 @@ qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 wol_cfg;
+	int err = 0;
 
 	if (qlcnic_83xx_check(adapter))
 		return -EOPNOTSUPP;
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
+	if (err == -EIO)
+		return err;
 	if (!(wol_cfg & (1 << adapter->portnum)))
 		return -EOPNOTSUPP;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
+	if (err == -EIO)
+		return err;
 	if (wol->wolopts & WAKE_MAGIC)
 		wol_cfg |= 1UL << adapter->portnum;
 	else
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 4ed7e73..4d5f59b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -317,16 +317,20 @@ static void qlcnic_write_window_reg(u32 addr, void __iomem *bar0, u32 data)
 int
 qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 {
-	int done = 0, timeout = 0;
+	int timeout = 0;
+	int err = 0;
+	u32 done = 0;
 
 	while (!done) {
-		done = QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)));
+		done = QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)),
+			       &err);
 		if (done == 1)
 			break;
 		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
 			dev_err(&adapter->pdev->dev,
 				"Failed to acquire sem=%d lock; holdby=%d\n",
-				sem, id_reg ? QLCRD32(adapter, id_reg) : -1);
+				sem,
+				id_reg ? QLCRD32(adapter, id_reg, &err) : -1);
 			return -EIO;
 		}
 		msleep(1);
@@ -341,19 +345,22 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 void
 qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
 {
-	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
+	int err = 0;
+
+	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)), &err);
 }
 
 int qlcnic_ind_rd(struct qlcnic_adapter *adapter, u32 addr)
 {
+	int err = 0;
 	u32 data;
 
 	if (qlcnic_82xx_check(adapter))
 		qlcnic_read_window_reg(addr, adapter->ahw->pci_base0, &data);
 	else {
-		data = qlcnic_83xx_rd_reg_indirect(adapter, addr);
-		if (data == -EIO)
-			return -EIO;
+		data = QLCRD32(adapter, addr, &err);
+		if (err == -EIO)
+			return err;
 	}
 	return data;
 }
@@ -1159,7 +1166,8 @@ int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off,
 	return -EIO;
 }
 
-int qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
+int qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off,
+			      int *err)
 {
 	unsigned long flags;
 	int rv;
@@ -1415,7 +1423,7 @@ int qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
 
 int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter)
 {
-	int offset, board_type, magic;
+	int offset, board_type, magic, err = 0;
 	struct pci_dev *pdev = adapter->pdev;
 
 	offset = QLCNIC_FW_MAGIC_OFFSET;
@@ -1435,7 +1443,9 @@ int qlcnic_82xx_get_board_info(struct qlcnic_adapter *adapter)
 	adapter->ahw->board_type = board_type;
 
 	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
-		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I);
+		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I, &err);
+		if (err == -EIO)
+			return err;
 		if ((gpio & 0x8000) == 0)
 			board_type = QLCNIC_BRDTYPE_P3P_10G_TP;
 	}
@@ -1475,10 +1485,13 @@ int
 qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 {
 	u32 wol_cfg;
+	int err = 0;
 
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV);
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
 	if (wol_cfg & (1UL << adapter->portnum)) {
-		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG);
+		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
+		if (err == -EIO)
+			return err;
 		if (wol_cfg & (1 << adapter->portnum))
 			return 1;
 	}
@@ -1539,6 +1552,7 @@ void qlcnic_82xx_get_func_no(struct qlcnic_adapter *adapter)
 void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 			  loff_t offset, size_t size)
 {
+	int err = 0;
 	u32 data;
 	u64 qmdata;
 
@@ -1546,7 +1560,7 @@ void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
 		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
 		memcpy(buf, &qmdata, size);
 	} else {
-		data = QLCRD32(adapter, offset);
+		data = QLCRD32(adapter, offset, &err);
 		memcpy(buf, &data, size);
 	}
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 2c22504..4a71b28 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -154,7 +154,7 @@ struct qlcnic_hardware_context;
 struct qlcnic_adapter;
 
 int qlcnic_82xx_start_firmware(struct qlcnic_adapter *);
-int qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong);
+int qlcnic_82xx_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong, int *);
 int qlcnic_82xx_hw_write_wx_2M(struct qlcnic_adapter *, ulong, u32);
 int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int);
 int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index a202309..974d626 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -286,10 +286,11 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 {
 	long timeout = 0;
 	long done = 0;
+	int err = 0;
 
 	cond_resched();
 	while (done == 0) {
-		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS);
+		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS, &err);
 		done &= 2;
 		if (++timeout >= QLCNIC_MAX_ROM_WAIT_USEC) {
 			dev_err(&adapter->pdev->dev,
@@ -304,6 +305,8 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 			    u32 addr, u32 *valp)
 {
+	int err = 0;
+
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ADDRESS, addr);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 3);
@@ -317,7 +320,9 @@ static int do_rom_fast_read(struct qlcnic_adapter *adapter,
 	udelay(10);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
-	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA);
+	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA, &err);
+	if (err == -EIO)
+		return err;
 	return 0;
 }
 
@@ -369,11 +374,11 @@ int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp)
 
 int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 {
-	int addr, val;
+	int addr, err = 0;
 	int i, n, init_delay;
 	struct crb_addr_pair *buf;
 	unsigned offset;
-	u32 off;
+	u32 off, val;
 	struct pci_dev *pdev = adapter->pdev;
 
 	QLC_SHARED_REG_WR32(adapter, QLCNIC_CMDPEG_STATE, 0);
@@ -402,7 +407,9 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xb0000, 0x00);
 
 	/* halt sre */
-	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000);
+	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000, &err);
+	if (err == -EIO)
+		return err;
 	QLCWR32(adapter, QLCNIC_CRB_SRE + 0x1000, val & (~(0x1)));
 
 	/* halt epg */
@@ -719,10 +726,12 @@ qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
 static int
 qlcnic_has_mn(struct qlcnic_adapter *adapter)
 {
-	u32 capability;
-	capability = 0;
+	u32 capability = 0;
+	int err = 0;
 
-	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY);
+	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY, &err);
+	if (err == -EIO)
+		return err;
 	if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
 		return 1;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a849446..ee013fc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -977,8 +977,8 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 static int
 qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 {
-	int err;
 	struct qlcnic_info nic_info;
+	int err = 0;
 
 	memset(&nic_info, 0, sizeof(struct qlcnic_info));
 	err = qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw->pci_func);
@@ -993,7 +993,9 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
 		u32 temp;
-		temp = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
+		temp = QLCRD32(adapter, CRB_FW_CAPABILITIES_2, &err);
+		if (err == -EIO)
+			return err;
 		adapter->ahw->extra_capability[0] = temp;
 	}
 	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
@@ -3095,6 +3097,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 {
 	u32 state = 0, heartbeat;
 	u32 peg_status;
+	int err = 0;
 
 	if (qlcnic_check_temp(adapter))
 		goto detach;
@@ -3141,11 +3144,11 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 			"PEG_NET_4_PC: 0x%x\n",
 			peg_status,
 			QLC_SHARED_REG_RD32(adapter, QLCNIC_PEG_HALT_STATUS2),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c),
-			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c));
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c, &err),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c, &err));
 	if (QLCNIC_FWERROR_CODE(peg_status) == 0x67)
 		dev_err(&adapter->pdev->dev,
 			"Firmware aborted with error code 0x00006700. "
-- 
1.5.6
