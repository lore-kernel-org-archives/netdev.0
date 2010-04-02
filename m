From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 NEXT 5/9] qlcnic: use IDC defined timeout value
Date: Thu,  1 Apr 2010 22:01:32 -0700
Message-ID: <1270184496-18985-6-git-send-email-amit.salecha@qlogic.com>
References: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33091 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755244Ab0DBFBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 01:01:40 -0400
In-Reply-To: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o USE/Read IDC defined timeout value from ROM.
o While resetting chip, don't wait for other pci-func to respond,
  more than reset_ack_timeo seconds,

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 +++-
 drivers/net/qlcnic/qlcnic_hdr.h  |    2 ++
 drivers/net/qlcnic/qlcnic_init.c |   16 ++++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c |   26 ++++++++++++++++----------
 4 files changed, 37 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 8a3446d..87cd1a7 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -958,8 +958,9 @@ struct qlcnic_adapter {
 	u8 dev_state;
 	u8 diag_test;
 	u8 diag_cnt;
+	u8 reset_ack_timeo;
+	u8 dev_init_timeo;
 	u8 rsrd1;
-	u16 rsrd2;
 
 	u8 mac_addr[ETH_ALEN];
 
@@ -1040,6 +1041,7 @@ int qlcnic_need_fw_reset(struct qlcnic_adapter *adapter);
 void qlcnic_request_firmware(struct qlcnic_adapter *adapter);
 void qlcnic_release_firmware(struct qlcnic_adapter *adapter);
 int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter);
+void qlcnic_setup_idc_param(struct qlcnic_adapter *adapter);
 
 int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, int addr, int *valp);
 int qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index e9fb692..51fa3fb 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -695,6 +695,8 @@ enum {
 #define QLCNIC_CRB_DRV_SCRATCH             (QLCNIC_CAM_RAM(0x148))
 #define QLCNIC_CRB_DEV_PARTITION_INFO      (QLCNIC_CAM_RAM(0x14c))
 #define QLCNIC_CRB_DRV_IDC_VER             (QLCNIC_CAM_RAM(0x14c))
+#define QLCNIC_ROM_DEV_INIT_TIMEOUT	(0x3e885c)
+#define QLCNIC_ROM_DRV_RESET_TIMEOUT	(0x3e8860)
 
 		 /* Device State */
 #define QLCNIC_DEV_COLD 		1
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 0a424e0..ccd24f4 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -529,6 +529,22 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+void
+qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
+
+	int timeo;
+
+	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
+		timeo = 30;
+
+	adapter->dev_init_timeo = timeo;
+
+	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DRV_RESET_TIMEOUT, &timeo))
+		timeo = 10;
+
+	adapter->reset_ack_timeo = timeo;
+}
+
 static int
 qlcnic_has_mn(struct qlcnic_adapter *adapter)
 {
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index a234622..38e0829 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -649,7 +649,10 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	if (!qlcnic_can_start_firmware(adapter))
+	err = qlcnic_can_start_firmware(adapter);
+	if (err < 0)
+		return err;
+	else if (!err)
 		goto wait_init;
 
 	first_boot = QLCRD32(adapter, QLCNIC_CAM_RAM(0x1fc));
@@ -1138,6 +1141,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 	}
 
+	qlcnic_setup_idc_param(adapter);
 
 	err = qlcnic_start_firmware(adapter);
 	if (err)
@@ -2027,7 +2031,7 @@ static int
 qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 {
 	u32 val, prev_state;
-	int cnt = 0;
+	u8 dev_init_timeo = adapter->dev_init_timeo;
 	int portnum = adapter->portnum;
 
 	if (qlcnic_api_lock(adapter))
@@ -2072,12 +2076,13 @@ start_fw:
 	}
 
 	qlcnic_api_unlock(adapter);
-	msleep(1000);
-	while ((QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) != QLCNIC_DEV_READY) &&
-			++cnt < 20)
+
+	do {
 		msleep(1000);
+	} while ((QLCRD32(adapter, QLCNIC_CRB_DEV_STATE) != QLCNIC_DEV_READY)
+			&& --dev_init_timeo);
 
-	if (cnt >= 20)
+	if (!dev_init_timeo)
 		return -1;
 
 	if (qlcnic_api_lock(adapter))
@@ -2099,12 +2104,10 @@ qlcnic_fwinit_work(struct work_struct *work)
 			struct qlcnic_adapter, fw_work.work);
 	int dev_state;
 
-	if (++adapter->fw_wait_cnt > FW_POLL_THRESH)
-		goto err_ret;
-
 	if (test_bit(__QLCNIC_START_FW, &adapter->state)) {
 
-		if (qlcnic_check_drv_state(adapter)) {
+		if (qlcnic_check_drv_state(adapter) &&
+			(adapter->fw_wait_cnt++ < adapter->reset_ack_timeo)) {
 			qlcnic_schedule_work(adapter,
 					qlcnic_fwinit_work, FW_POLL_DELAY);
 			return;
@@ -2118,6 +2121,9 @@ qlcnic_fwinit_work(struct work_struct *work)
 		goto err_ret;
 	}
 
+	if (adapter->fw_wait_cnt++ > (adapter->dev_init_timeo / 2))
+		goto err_ret;
+
 	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	switch (dev_state) {
 	case QLCNIC_DEV_READY:
-- 
1.6.0.2

