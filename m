From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 10/12] qlcnic: firmware initialization update
Date: Thu, 19 Aug 2010 08:08:31 -0700
Message-ID: <1282230513-25286-11-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:65135 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753924Ab0HSPIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:35 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Cleanup legacy code which is not valid for Qlogic
CNA adapters.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 +-
 drivers/net/qlcnic/qlcnic_hdr.h  |    3 +-
 drivers/net/qlcnic/qlcnic_init.c |  133 +++++++++-----------------------------
 drivers/net/qlcnic/qlcnic_main.c |   38 +++--------
 4 files changed, 47 insertions(+), 131 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index b58c411..43cb925 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -54,6 +54,8 @@
 #define _QLCNIC_LINUX_SUBVERSION 7
 #define QLCNIC_LINUX_VERSIONID  "5.0.7"
 #define QLCNIC_DRV_IDC_VER  0x01
+#define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
+		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
@@ -1233,7 +1235,7 @@ void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter);
 void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter);
 void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter);
 
-int qlcnic_init_firmware(struct qlcnic_adapter *adapter);
+int qlcnic_check_fw_status(struct qlcnic_adapter *adapter);
 void qlcnic_watchdog_task(struct work_struct *work);
 void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter, u32 ringid,
 		struct qlcnic_host_rds_ring *rds_ring);
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index eae03b5..794f657 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -747,7 +747,8 @@ enum {
 
 #define QLCNIC_RESET_TIMEOUT_SECS	10
 #define QLCNIC_INIT_TIMEOUT_SECS	30
-
+#define QLCNIC_HEARTBEAT_PERIOD_MSECS	200
+#define QLCNIC_HEARTBEAT_RETRY_COUNT	30
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 9076675..e7a399f 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -435,11 +435,14 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	u32 off;
 	struct pci_dev *pdev = adapter->pdev;
 
-	/* resetall */
+	QLCWR32(adapter, CRB_CMDPEG_STATE, 0);
+	QLCWR32(adapter, CRB_RCVPEG_STATE, 0);
+
 	qlcnic_rom_lock(adapter);
 	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0xfeffffff);
 	qlcnic_rom_unlock(adapter);
 
+	/* Init HW CRB block */
 	if (qlcnic_rom_fast_read(adapter, 0, &n) != 0 || (n != 0xcafecafe) ||
 			qlcnic_rom_fast_read(adapter, 4, &n) != 0) {
 		dev_err(&pdev->dev, "ERROR Reading crb_init area: val:%x\n", n);
@@ -520,13 +523,10 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	}
 	kfree(buf);
 
-	/* p2dn replyCount */
+	/* Initialize protocol process engine */
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_D + 0xec, 0x1e);
-	/* disable_peg_cache 0 & 1*/
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_D + 0x4c, 8);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_I + 0x4c, 8);
-
-	/* peg_clr_all */
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x8, 0);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0xc, 0);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x8, 0);
@@ -535,10 +535,36 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0xc, 0);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x8, 0);
 	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0xc, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x8, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
+	msleep(1);
+	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
+	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
 	return 0;
 }
 
 int
+qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
+{
+	u32 heartbit, ret = -EIO;
+	int retries = QLCNIC_HEARTBEAT_RETRY_COUNT;
+
+	adapter->heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+	do {
+		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
+		heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+		if (heartbit != adapter->heartbit) {
+			/* Complete firmware handshake */
+			QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+			ret = QLCNIC_RCODE_SUCCESS;
+			break;
+		}
+	} while (--retries);
+
+	return ret;
+}
+
+int
 qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 
 	int timeo;
@@ -905,35 +931,12 @@ qlcnic_get_bios_version(struct qlcnic_adapter *adapter)
 int
 qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
 {
-	u32 count, old_count;
 	u32 val, version, major, minor, build;
-	int i, timeout;
 
 	if (adapter->need_fw_reset)
 		return 1;
 
-	/* last attempt had failed */
-	if (QLCRD32(adapter, CRB_CMDPEG_STATE) == PHAN_INITIALIZE_FAILED)
-		return 1;
-
-	old_count = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
-
-	for (i = 0; i < 10; i++) {
-
-		timeout = msleep_interruptible(200);
-		if (timeout) {
-			QLCWR32(adapter, CRB_CMDPEG_STATE,
-					PHAN_INITIALIZE_FAILED);
-			return -EINTR;
-		}
-
-		count = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
-		if (count != old_count)
-			break;
-	}
-
-	/* firmware is dead */
-	if (count == old_count)
+	if (qlcnic_check_fw_status(adapter))
 		return 1;
 
 	/* check if we have got newer or different file firmware */
@@ -1158,78 +1161,6 @@ qlcnic_release_firmware(struct qlcnic_adapter *adapter)
 	adapter->fw = NULL;
 }
 
-static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
-{
-	u32 val;
-	int retries = 60;
-
-	do {
-		val = QLCRD32(adapter, CRB_CMDPEG_STATE);
-
-		switch (val) {
-		case PHAN_INITIALIZE_COMPLETE:
-		case PHAN_INITIALIZE_ACK:
-			return 0;
-		case PHAN_INITIALIZE_FAILED:
-			goto out_err;
-		default:
-			break;
-		}
-
-		msleep(500);
-
-	} while (--retries);
-
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
-
-out_err:
-	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
-		      "complete, state: 0x%x.\n", val);
-	return -EIO;
-}
-
-static int
-qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
-{
-	u32 val;
-	int retries = 2000;
-
-	do {
-		val = QLCRD32(adapter, CRB_RCVPEG_STATE);
-
-		if (val == PHAN_PEG_RCV_INITIALIZED)
-			return 0;
-
-		msleep(10);
-
-	} while (--retries);
-
-	if (!retries) {
-		dev_err(&adapter->pdev->dev, "Receive Peg initialization not "
-			      "complete, state: 0x%x.\n", val);
-		return -EIO;
-	}
-
-	return 0;
-}
-
-int qlcnic_init_firmware(struct qlcnic_adapter *adapter)
-{
-	int err;
-
-	err = qlcnic_cmd_peg_ready(adapter);
-	if (err)
-		return err;
-
-	err = qlcnic_receive_peg_ready(adapter);
-	if (err)
-		return err;
-
-	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
-
-	return err;
-}
-
 static void
 qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 				struct qlcnic_fw_msg *msg)
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 6e246c8..fa87a96 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -940,18 +940,13 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 static int
 qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 {
-	int val, err, first_boot;
+	int err;
 
 	err = qlcnic_can_start_firmware(adapter);
 	if (err < 0)
 		return err;
 	else if (!err)
-		goto wait_init;
-
-	first_boot = QLCRD32(adapter, QLCNIC_CAM_RAM(0x1fc));
-	if (first_boot == 0x55555555)
-		/* This is the first boot after power up */
-		QLCWR32(adapter, QLCNIC_CAM_RAM(0x1fc), QLCNIC_BDINFO_MAGIC);
+		goto check_fw_status;
 
 	if (load_fw_file)
 		qlcnic_request_firmware(adapter);
@@ -963,21 +958,12 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 	}
 
 	err = qlcnic_need_fw_reset(adapter);
-	if (err < 0)
-		goto err_out;
 	if (err == 0)
-		goto wait_init;
-
-	if (first_boot != 0x55555555) {
-		QLCWR32(adapter, CRB_CMDPEG_STATE, 0);
-		QLCWR32(adapter, CRB_RCVPEG_STATE, 0);
-		qlcnic_pinit_from_rom(adapter);
-		msleep(1);
-	}
-
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
-	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
+		goto set_dev_ready;
 
+	err = qlcnic_pinit_from_rom(adapter);
+	if (err)
+		goto err_out;
 	qlcnic_set_port_mode(adapter);
 
 	err = qlcnic_load_firmware(adapter);
@@ -985,18 +971,14 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 		goto err_out;
 
 	qlcnic_release_firmware(adapter);
+	QLCWR32(adapter, CRB_DRIVER_VERSION, QLCNIC_DRIVER_VERSION);
 
-	val = (_QLCNIC_LINUX_MAJOR << 16)
-		| ((_QLCNIC_LINUX_MINOR << 8))
-		| (_QLCNIC_LINUX_SUBVERSION);
-	QLCWR32(adapter, CRB_DRIVER_VERSION, val);
-
-wait_init:
-	/* Handshake with the card before we register the devices. */
-	err = qlcnic_init_firmware(adapter);
+check_fw_status:
+	err = qlcnic_check_fw_status(adapter);
 	if (err)
 		goto err_out;
 
+set_dev_ready:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
 	err = qlcnic_check_npar_opertional(adapter);
-- 
1.6.0.2

