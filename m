From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/6] qlcnic: Add support to run firmware POST
Date: Wed, 27 Aug 2014 12:43:20 -0400
Message-ID: <1409157802-7895-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:24019 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935238AbaH0RQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:16:28 -0400
In-Reply-To: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch adds support to run Power On Self Test (POST) for 83xx adapters.
POST can be run in 3 different speed modes :
	i)  Fast mode (takes about 690 ms)
	ii) Medium mode (takes about 2930 ms)
	iii) Slow mode (takes about 7500 ms)

To run POST, firmware file with name "83xx_post_fw.bin" should be present under
/lib/firmware directory. load_fw_file module parameter is used to specify
POST operation and its speed mode.
load_fw_file = 2 : Fast mode
load_fw_file = 3 : Medium mode
load_fw_file = 4 : Slow mode

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   2 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  | 155 ++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   2 +-
 4 files changed, 158 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 80a5509..1e8bb82 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -540,6 +540,8 @@ struct qlcnic_hardware_context {
 	u8 lb_mode;
 	u16 vxlan_port;
 	struct device *hwmon_dev;
+	u32 post_mode;
+	bool run_post;
 };
 
 struct qlcnic_adapter_stats {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index abda0ce..f3346a3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -83,6 +83,7 @@
 /* Firmware image definitions */
 #define QLC_83XX_BOOTLOADER_FLASH_ADDR	0x10000
 #define QLC_83XX_FW_FILE_NAME		"83xx_fw.bin"
+#define QLC_83XX_POST_FW_FILE_NAME	"83xx_post_fw.bin"
 #define QLC_84XX_FW_FILE_NAME		"84xx_fw.bin"
 #define QLC_83XX_BOOT_FROM_FLASH	0
 #define QLC_83XX_BOOT_FROM_FILE		0x12345678
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index d1bded7..9a2cfe4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2075,6 +2075,121 @@ static void qlcnic_83xx_init_hw(struct qlcnic_adapter *p_dev)
 		dev_err(&p_dev->pdev->dev, "%s: failed\n", __func__);
 }
 
+/* POST FW related definations*/
+#define QLC_83XX_POST_SIGNATURE_REG	0x41602014
+#define QLC_83XX_POST_MODE_REG		0x41602018
+#define QLC_83XX_POST_FAST_MODE		0
+#define QLC_83XX_POST_MEDIUM_MODE	1
+#define QLC_83XX_POST_SLOW_MODE		2
+
+/* POST Timeout values in milliseconds */
+#define QLC_83XX_POST_FAST_MODE_TIMEOUT	690
+#define QLC_83XX_POST_MED_MODE_TIMEOUT	2930
+#define QLC_83XX_POST_SLOW_MODE_TIMEOUT	7500
+
+/* POST result values */
+#define QLC_83XX_POST_PASS			0xfffffff0
+#define QLC_83XX_POST_ASIC_STRESS_TEST_FAIL	0xffffffff
+#define QLC_83XX_POST_DDR_TEST_FAIL		0xfffffffe
+#define QLC_83XX_POST_ASIC_MEMORY_TEST_FAIL	0xfffffffc
+#define QLC_83XX_POST_FLASH_TEST_FAIL		0xfffffff8
+
+static int qlcnic_83xx_run_post(struct qlcnic_adapter *adapter)
+{
+	struct qlc_83xx_fw_info *fw_info = adapter->ahw->fw_info;
+	struct device *dev = &adapter->pdev->dev;
+	int timeout, count, ret = 0;
+	u32 signature;
+
+	/* Set timeout values with extra 2 seconds of buffer */
+	switch (adapter->ahw->post_mode) {
+	case QLC_83XX_POST_FAST_MODE:
+		timeout = QLC_83XX_POST_FAST_MODE_TIMEOUT + 2000;
+		break;
+	case QLC_83XX_POST_MEDIUM_MODE:
+		timeout = QLC_83XX_POST_MED_MODE_TIMEOUT + 2000;
+		break;
+	case QLC_83XX_POST_SLOW_MODE:
+		timeout = QLC_83XX_POST_SLOW_MODE_TIMEOUT + 2000;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	strncpy(fw_info->fw_file_name, QLC_83XX_POST_FW_FILE_NAME,
+		QLC_FW_FILE_NAME_LEN);
+
+	ret = request_firmware(&fw_info->fw, fw_info->fw_file_name, dev);
+	if (ret) {
+		dev_err(dev, "POST firmware can not be loaded, skipping POST\n");
+		return 0;
+	}
+
+	ret = qlcnic_83xx_copy_fw_file(adapter);
+	if (ret)
+		return ret;
+
+	/* clear QLC_83XX_POST_SIGNATURE_REG register */
+	qlcnic_ind_wr(adapter, QLC_83XX_POST_SIGNATURE_REG, 0);
+
+	/* Set POST mode */
+	qlcnic_ind_wr(adapter, QLC_83XX_POST_MODE_REG,
+		      adapter->ahw->post_mode);
+
+	QLC_SHARED_REG_WR32(adapter, QLCNIC_FW_IMG_VALID,
+			    QLC_83XX_BOOT_FROM_FILE);
+
+	qlcnic_83xx_start_hw(adapter);
+
+	count = 0;
+	do {
+		msleep(100);
+		count += 100;
+
+		signature = qlcnic_ind_rd(adapter, QLC_83XX_POST_SIGNATURE_REG);
+		if (signature == QLC_83XX_POST_PASS)
+			break;
+	} while (timeout > count);
+
+	if (timeout <= count) {
+		dev_err(dev, "POST timed out, signature = 0x%08x\n", signature);
+		return -EIO;
+	}
+
+	switch (signature) {
+	case QLC_83XX_POST_PASS:
+		dev_info(dev, "POST passed, Signature = 0x%08x\n", signature);
+		break;
+	case QLC_83XX_POST_ASIC_STRESS_TEST_FAIL:
+		dev_err(dev, "POST failed, Test case : ASIC STRESS TEST, Signature = 0x%08x\n",
+			signature);
+		ret = -EIO;
+		break;
+	case QLC_83XX_POST_DDR_TEST_FAIL:
+		dev_err(dev, "POST failed, Test case : DDT TEST, Signature = 0x%08x\n",
+			signature);
+		ret = -EIO;
+		break;
+	case QLC_83XX_POST_ASIC_MEMORY_TEST_FAIL:
+		dev_err(dev, "POST failed, Test case : ASIC MEMORY TEST, Signature = 0x%08x\n",
+			signature);
+		ret = -EIO;
+		break;
+	case QLC_83XX_POST_FLASH_TEST_FAIL:
+		dev_err(dev, "POST failed, Test case : FLASH TEST, Signature = 0x%08x\n",
+			signature);
+		ret = -EIO;
+		break;
+	default:
+		dev_err(dev, "POST failed, Test case : INVALID, Signature = 0x%08x\n",
+			signature);
+		ret = -EIO;
+		break;
+	}
+
+	return ret;
+}
+
 static int qlcnic_83xx_load_fw_image_from_host(struct qlcnic_adapter *adapter)
 {
 	struct qlc_83xx_fw_info *fw_info = adapter->ahw->fw_info;
@@ -2119,8 +2234,27 @@ static int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter)
 
 	if (qlcnic_83xx_copy_bootloader(adapter))
 		return err;
+
+	/* Check if POST needs to be run */
+	if (adapter->ahw->run_post) {
+		err = qlcnic_83xx_run_post(adapter);
+		if (err)
+			return err;
+
+		/* No need to run POST in next reset sequence */
+		adapter->ahw->run_post = false;
+
+		/* Again reset the adapter to load regular firmware  */
+		qlcnic_83xx_stop_hw(adapter);
+		qlcnic_83xx_init_hw(adapter);
+
+		err = qlcnic_83xx_copy_bootloader(adapter);
+		if (err)
+			return err;
+	}
+
 	/* Boot either flash image or firmware image from host file system */
-	if (qlcnic_load_fw_file) {
+	if (qlcnic_load_fw_file == 1) {
 		if (qlcnic_83xx_load_fw_image_from_host(adapter))
 			return err;
 	} else {
@@ -2329,6 +2463,25 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	adapter->rx_mac_learn = false;
 	ahw->msix_supported = !!qlcnic_use_msi_x;
 
+	/* Check if POST needs to be run */
+	switch (qlcnic_load_fw_file) {
+	case 2:
+		ahw->post_mode = QLC_83XX_POST_FAST_MODE;
+		ahw->run_post = true;
+		break;
+	case 3:
+		ahw->post_mode = QLC_83XX_POST_MEDIUM_MODE;
+		ahw->run_post = true;
+		break;
+	case 4:
+		ahw->post_mode = QLC_83XX_POST_SLOW_MODE;
+		ahw->run_post = true;
+		break;
+	default:
+		ahw->run_post = false;
+		break;
+	}
+
 	qlcnic_83xx_init_rings(adapter);
 
 	err = qlcnic_83xx_init_mailbox_work(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8db11e2..f5e29f7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -52,7 +52,7 @@ MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled)");
 module_param_named(auto_fw_reset, qlcnic_auto_fw_reset, int, 0644);
 
 int qlcnic_load_fw_file;
-MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file)");
+MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file, 2=POST in fast mode, 3= POST in medium mode, 4=POST in slow mode)");
 module_param_named(load_fw_file, qlcnic_load_fw_file, int, 0444);
 
 static int qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
-- 
1.8.1.4
