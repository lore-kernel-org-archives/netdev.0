From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V5 06/22] qlcnic: macros for common register access
Date: Thu,  1 Nov 2012 21:06:38 -0400
Message-ID: <1351818414-25197-7-git-send-email-sony.chacko@qlogic.com>
References: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:36403 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1760053Ab2KBB0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 21:26:09 -0400
In-Reply-To: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA
Use QLCRD and QLCWR macros for 82xx and 83xx common register
access.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h   |    8 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c |   33 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  146 ++++++++++++----------
 3 files changed, 101 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 2b37630..d88baed 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -28,6 +28,14 @@ enum qlcnic_regs {
 	QLCNIC_FLASH_UNLOCK,
 };
 
+/* Read from an address offset from BAR0, existing registers */
+#define QLCRD(a, addr)			\
+	readl(((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+
+/* Write to an address offset from BAR0, existing registers */
+#define QLCWR(a, addr, value)		\
+	writel(value, ((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+
 #define QLCNIC_CMD_CONFIGURE_IP_ADDR		0x1
 #define QLCNIC_CMD_CONFIG_INTRPT		0x2
 #define QLCNIC_CMD_CREATE_RX_CTX		0x7
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index cd7a1fe..b498160 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -5,11 +5,8 @@
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
-#include <linux/netdevice.h>
-#include <linux/delay.h>
-#include <linux/slab.h>
-#include <linux/if_vlan.h>
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 struct crb_addr_pair {
 	u32 addr;
@@ -327,7 +324,6 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 	long done = 0;
 
 	cond_resched();
-
 	while (done == 0) {
 		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS);
 		done &= 2;
@@ -416,8 +412,8 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	u32 off;
 	struct pci_dev *pdev = adapter->pdev;
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, 0);
-	QLCWR32(adapter, CRB_RCVPEG_STATE, 0);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, 0);
+	QLCWR(adapter, QLCNIC_RCVPEG_STATE, 0);
 
 	/* Halt all the indiviual PEGs and other blocks */
 	/* disable all I2Q */
@@ -564,8 +560,8 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
 	msleep(1);
 
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
 
 	return 0;
 }
@@ -576,7 +572,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_CMDPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_CMDPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_CMDPEG_STATE);
 
 		switch (val) {
 		case PHAN_INITIALIZE_COMPLETE:
@@ -592,7 +588,7 @@ static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
 
 	} while (--retries);
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
 
 out_err:
 	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
@@ -607,7 +603,7 @@ qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
 	int retries = QLCNIC_RCVPEG_CHECK_RETRY_COUNT;
 
 	do {
-		val = QLCRD32(adapter, CRB_RCVPEG_STATE);
+		val = QLCRD(adapter, QLCNIC_RCVPEG_STATE);
 
 		if (val == PHAN_PEG_RCV_INITIALIZED)
 			return 0;
@@ -638,7 +634,7 @@ qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	return err;
 }
@@ -649,7 +645,7 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	int timeo;
 	u32 val;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+	val = QLCRD(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
 	val = QLC_DEV_GET_DRV(val, adapter->portnum);
 	if ((val & 0x3) != QLCNIC_TYPE_NIC) {
 		dev_err(&adapter->pdev->dev,
@@ -689,7 +685,7 @@ static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
 	}
 
 	entry_size = flt_hdr.len - sizeof(struct qlcnic_flt_header);
-	flt_entry = (struct qlcnic_flt_entry *)vzalloc(entry_size);
+	flt_entry = vzalloc(entry_size);
 	if (flt_entry == NULL) {
 		dev_warn(&adapter->pdev->dev, "error allocating memory\n");
 		return -EIO;
@@ -1088,11 +1084,11 @@ qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
 	u32 heartbeat, ret = -EIO;
 	int retries = QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT;
 
-	adapter->heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	adapter->heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 
 	do {
 		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
-		heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+		heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 		if (heartbeat != adapter->heartbeat) {
 			ret = QLCNIC_RCODE_SUCCESS;
 			break;
@@ -1262,7 +1258,7 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 	}
 
-	QLCWR32(adapter, QLCNIC_CAM_RAM(0x1fc), QLCNIC_BDINFO_MAGIC);
+	QLCWR(adapter, QLCNIC_FW_IMG_VALID, QLCNIC_BDINFO_MAGIC);
 	return 0;
 }
 
@@ -1315,6 +1311,7 @@ next:
 	}
 }
 
+
 void
 qlcnic_release_firmware(struct qlcnic_adapter *adapter)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 19dd239..3cf0f16 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -10,6 +10,7 @@
 #include <linux/interrupt.h>
 
 #include "qlcnic.h"
+#include "qlcnic_hw.h"
 
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
@@ -114,7 +115,6 @@ static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 
 MODULE_DEVICE_TABLE(pci, qlcnic_pci_tbl);
 
-
 inline void
 qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring)
@@ -411,7 +411,6 @@ int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 	qlcnic_enable_msi_legacy(adapter);
 	return 0;
 }
-
 static void
 qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 {
@@ -530,14 +529,14 @@ static void qlcnic_check_vf(struct qlcnic_adapter *adapter,
 	u32 op_mode, priv_level;
 
 	/* Determine FW API version */
-	adapter->ahw->fw_hal_version = QLCRD32(adapter, QLCNIC_FW_API);
+	adapter->ahw->fw_hal_version = QLCRD(adapter, QLCNIC_FW_API);
 
 	/* Find PCI function number */
 	qlcnic_get_func_no(adapter);
 
 	/* Determine function privilege level */
 	priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
-	op_mode = QLCRD32(adapter, QLCNIC_DRV_OP_MODE);
+	op_mode = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
@@ -626,19 +625,26 @@ static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
 static void
 qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
+	int err;
 	u32 fw_major, fw_minor, fw_build, prev_fw_version;
 	struct pci_dev *pdev = adapter->pdev;
-	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlcnic_fw_dump *fw_dump = &ahw->fw_dump;
 
 	prev_fw_version = adapter->fw_version;
 
-	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
-	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
-	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
+	fw_major = QLCRD(adapter, QLCNIC_FW_VERSION_MAJOR);
+	fw_minor = QLCRD(adapter, QLCNIC_FW_VERSION_MINOR);
+	fw_build = QLCRD(adapter, QLCNIC_FW_VERSION_SUB);
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
-	if (adapter->ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
+	err = qlcnic_get_board_info(adapter);
+	if (err) {
+		dev_err(&pdev->dev, "Error getting board config info.\n");
+		return;
+	}
+	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
 		if (fw_dump->tmpl_hdr == NULL ||
 				adapter->fw_version > prev_fw_version) {
 			if (fw_dump->tmpl_hdr)
@@ -951,10 +957,10 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 		return 0;
 
-	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	while (npar_state != QLCNIC_DEV_NPAR_OPER && --npar_opt_timeo) {
 		msleep(1000);
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	}
 	if (!npar_opt_timeo) {
 		dev_err(&adapter->pdev->dev,
@@ -1019,16 +1025,15 @@ int qlcnic_82xx_start_firmware(struct qlcnic_adapter *adapter)
 		goto err_out;
 
 	qlcnic_release_firmware(adapter);
-	QLCWR32(adapter, CRB_DRIVER_VERSION, QLCNIC_DRIVER_VERSION);
+	QLCWR(adapter, CRB_DRIVER_VERSION, QLCNIC_DRIVER_VERSION);
 
 check_fw_status:
 	err = qlcnic_check_fw_status(adapter);
 	if (err)
 		goto err_out;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
-
 	err = qlcnic_check_eswitch_mode(adapter);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
@@ -1046,7 +1051,7 @@ check_fw_status:
 	return 0;
 
 err_out:
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+	QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 	dev_err(&adapter->pdev->dev, "Device state set to failed\n");
 
 	qlcnic_release_firmware(adapter);
@@ -1934,7 +1939,10 @@ int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 	u32 temp, temp_state, temp_val;
 	int rv = 0;
 
-	temp = QLCRD32(adapter, CRB_TEMP_STATE);
+	temp = 0;
+
+	if (qlcnic_82xx_check(adapter))
+		temp = QLCRD(adapter, QLCNIC_ASIC_TEMP);
 
 	temp_state = qlcnic_get_temp_state(temp);
 	temp_val = qlcnic_get_temp_val(temp);
@@ -2096,7 +2104,7 @@ qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding)
 	val |= encoding << 7;
 	val |= (jiffies - adapter->dev_rst_time) << 8;
 
-	QLCWR32(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
 	adapter->dev_rst_time = jiffies;
 }
 
@@ -2111,14 +2119,14 @@ qlcnic_set_drv_state(struct qlcnic_adapter *adapter, u8 state)
 	if (qlcnic_api_lock(adapter))
 		return -EIO;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 
 	if (state == QLCNIC_DEV_NEED_RESET)
 		QLC_DEV_SET_RST_RDY(val, adapter->portnum);
 	else if (state == QLCNIC_DEV_NEED_QUISCENT)
 		QLC_DEV_SET_QSCNT_RDY(val, adapter->portnum);
 
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
 
@@ -2133,9 +2141,9 @@ qlcnic_clr_drv_state(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -EBUSY;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
 
@@ -2150,20 +2158,20 @@ qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8 failed)
 	if (qlcnic_api_lock(adapter))
 		goto err;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	QLC_DEV_CLR_REF_CNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 
 	if (failed) {
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 		dev_info(&adapter->pdev->dev,
 				"Device state set to Failed. Please Reboot\n");
 	} else if (!(val & 0x11111111))
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_COLD);
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, adapter->portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	qlcnic_api_unlock(adapter);
 err:
@@ -2178,12 +2186,13 @@ static int
 qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 {
 	int act, state, active_mask;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
-	act = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	state = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
+	act = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 
 	if (adapter->flags & QLCNIC_FW_RESET_OWNER) {
-		active_mask = (~(1 << (adapter->ahw->pci_func * 4)));
+		active_mask = (~(1 << (ahw->pci_func * 4)));
 		act = act & active_mask;
 	}
 
@@ -2196,7 +2205,7 @@ qlcnic_check_drv_state(struct qlcnic_adapter *adapter)
 
 static int qlcnic_check_idc_ver(struct qlcnic_adapter *adapter)
 {
-	u32 val = QLCRD32(adapter, QLCNIC_CRB_DRV_IDC_VER);
+	u32 val = QLCRD(adapter, QLCNIC_CRB_DRV_IDC_VER);
 
 	if (val != QLCNIC_DRV_IDC_VER) {
 		dev_warn(&adapter->pdev->dev, "IDC Version mismatch, driver's"
@@ -2220,19 +2229,19 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	if (!(val & (1 << (portnum * 4)))) {
 		QLC_DEV_SET_REF_CNT(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_ACTIVE, val);
 	}
 
-	prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Device state = %u\n", prev_state);
 
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
 		qlcnic_idc_debug_info(adapter, 0);
 		qlcnic_api_unlock(adapter);
 		return 1;
@@ -2243,15 +2252,15 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 		return ret;
 
 	case QLCNIC_DEV_NEED_RESET:
-		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+		val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 		QLC_DEV_SET_RST_RDY(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
 	case QLCNIC_DEV_NEED_QUISCENT:
-		val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+		val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 		QLC_DEV_SET_QSCNT_RDY(val, portnum);
-		QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+		QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		break;
 
 	case QLCNIC_DEV_FAILED:
@@ -2268,7 +2277,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 
 	do {
 		msleep(1000);
-		prev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (prev_state == QLCNIC_DEV_QUISCENT)
 			continue;
@@ -2283,9 +2292,9 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return -1;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+	val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 	QLC_DEV_CLR_RST_QSCNT(val, portnum);
-	QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+	QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 
 	ret = qlcnic_check_idc_ver(adapter);
 	qlcnic_api_unlock(adapter);
@@ -2304,7 +2313,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
 
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	if (dev_state == QLCNIC_DEV_QUISCENT ||
 	    dev_state == QLCNIC_DEV_NEED_QUISCENT) {
 		qlcnic_api_unlock(adapter);
@@ -2333,17 +2342,17 @@ qlcnic_fwinit_work(struct work_struct *work)
 
 	if (!qlcnic_check_drv_state(adapter)) {
 skip_ack_check:
-		dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 		if (dev_state == QLCNIC_DEV_NEED_RESET) {
-			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
-						QLCNIC_DEV_INITIALIZING);
+			QLCWR(adapter, QLCNIC_CRB_DEV_STATE,
+			      QLCNIC_DEV_INITIALIZING);
 			set_bit(__QLCNIC_START_FW, &adapter->state);
 			QLCDB(adapter, DRV, "Restarting fw\n");
 			qlcnic_idc_debug_info(adapter, 0);
-			val = QLCRD32(adapter, QLCNIC_CRB_DRV_STATE);
+			val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 			QLC_DEV_SET_RST_RDY(val, adapter->portnum);
-			QLCWR32(adapter, QLCNIC_CRB_DRV_STATE, val);
+			QLCWR(adapter, QLCNIC_CRB_DRV_STATE, val);
 		}
 
 		qlcnic_api_unlock(adapter);
@@ -2360,7 +2369,7 @@ skip_ack_check:
 	qlcnic_api_unlock(adapter);
 
 wait_npar:
-	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
@@ -2402,7 +2411,7 @@ qlcnic_detach_work(struct work_struct *work)
 	} else
 		qlcnic_down(adapter, netdev);
 
-	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
+	status = QLCRD(adapter, QLCNIC_PEG_HALT_STATUS1);
 
 	if (status & QLCNIC_RCODE_FATAL_ERROR) {
 		dev_err(&adapter->pdev->dev,
@@ -2453,13 +2462,13 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 {
 	u32 state;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 	if (state == QLCNIC_DEV_NPAR_NON_OPER)
 		return;
 
 	if (qlcnic_api_lock(adapter))
 		return;
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
 
@@ -2482,17 +2491,17 @@ void qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *adapter, u32 key)
 	if (qlcnic_api_lock(adapter))
 		return;
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 
 	if (state == QLCNIC_DEV_READY) {
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
 		adapter->flags |= QLCNIC_FW_RESET_OWNER;
 		QLCDB(adapter, DRV, "NEED_RESET state set\n");
 		qlcnic_idc_debug_info(adapter, 0);
 	}
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
-		QLCNIC_DEV_NPAR_NON_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
+	      QLCNIC_DEV_NPAR_NON_OPER);
 	qlcnic_api_unlock(adapter);
 }
 
@@ -2503,7 +2512,7 @@ qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 	if (qlcnic_api_lock(adapter))
 		return;
 
-	QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
+	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
 	QLCDB(adapter, DRV, "NPAR operational state set\n");
 
 	qlcnic_api_unlock(adapter);
@@ -2542,7 +2551,7 @@ qlcnic_attach_work(struct work_struct *work)
 	u32 npar_state;
 
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		npar_state = QLCRD(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 		if (adapter->fw_wait_cnt++ > QLCNIC_DEV_NPAR_OPER_TIMEO)
 			qlcnic_clr_all_drv_state(adapter, 0);
 		else if (npar_state != QLCNIC_DEV_NPAR_OPER)
@@ -2584,14 +2593,14 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 	if (adapter->need_fw_reset)
 		qlcnic_dev_request_reset(adapter, 0);
 
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
 	if (state == QLCNIC_DEV_NEED_RESET) {
 		qlcnic_set_npar_non_operational(adapter);
 		adapter->need_fw_reset = 1;
 	} else if (state == QLCNIC_DEV_NEED_QUISCENT)
 		goto detach;
 
-	heartbeat = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 	if (heartbeat != adapter->heartbeat) {
 		adapter->heartbeat = heartbeat;
 		adapter->fw_fail_cnt = 0;
@@ -2617,19 +2626,19 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_err(&adapter->pdev->dev, "firmware hang detected\n");
+	peg_status = QLCRD(adapter, QLCNIC_PEG_HALT_STATUS1);
 	dev_err(&adapter->pdev->dev, "Dumping hw/fw registers\n"
 			"PEG_HALT_STATUS1: 0x%x, PEG_HALT_STATUS2: 0x%x,\n"
 			"PEG_NET_0_PC: 0x%x, PEG_NET_1_PC: 0x%x,\n"
 			"PEG_NET_2_PC: 0x%x, PEG_NET_3_PC: 0x%x,\n"
 			"PEG_NET_4_PC: 0x%x\n",
-			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1),
-			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS2),
+			peg_status,
+			QLCRD(adapter, QLCNIC_PEG_HALT_STATUS2),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c),
 			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c));
-	peg_status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
 	if (QLCNIC_FWERROR_CODE(peg_status) == 0x67)
 		dev_err(&adapter->pdev->dev,
 			"Firmware aborted with error code 0x00006700. "
@@ -2713,7 +2722,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (adapter->ahw->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
+		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
 		QLCDB(adapter, DRV, "Restarting fw\n");
 	}
 	qlcnic_api_unlock(adapter);
@@ -2786,12 +2795,13 @@ static pci_ers_result_t qlcnic_io_slot_reset(struct pci_dev *pdev)
 
 static void qlcnic_io_resume(struct pci_dev *pdev)
 {
+	u32 state;
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 
 	pci_cleanup_aer_uncorrect_error_status(pdev);
-
-	if (QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) == QLCNIC_DEV_READY &&
-	    test_and_clear_bit(__QLCNIC_AER, &adapter->state))
+	state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
+	if (state == QLCNIC_DEV_READY && test_and_clear_bit(__QLCNIC_AER,
+							    &adapter->state))
 		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
 						FW_POLL_DELAY);
 }
-- 
1.7.1
