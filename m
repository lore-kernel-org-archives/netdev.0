From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFT 2/3] cxgb4: make configuration load use request_firmware_nowait()
Date: Fri, 20 Jun 2014 17:39:40 -0700
Message-ID: <1403311181-9328-3-git-send-email-mcgrof@do-not-panic.com>
References: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
Cc: poswald@suse.com, santosh@chelsio.com, jcheung@suse.com,
	dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@suse.com
To: hariprasad@chelsio.com, leedom@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

cxgb4 loading can take a while, this is part of the crusade to
change it to be asynchronous. One more to go.

Cc: Philip Oswald <poswald@suse.com>
Cc: Santosh Rastapur <santosh@chelsio.com>
Cc: Jeffrey Cheung <jcheung@suse.com>
Cc: David Chang <dchang@suse.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 113 +++++++++++++++---------
 2 files changed, 73 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index bcf9acf..1507dc2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -650,6 +650,10 @@ struct adapter {
 
 	struct completion flash_comp;
 	int flash_comp_status;
+
+	char fw_config_file[32];
+	struct completion config_comp;
+	int config_comp_status;
 };
 
 /* Defined bit width of user definable filter tuples
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 9cf6f3e..65e4124 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4827,51 +4827,18 @@ static int adap_init0_tweaks(struct adapter *adapter)
 	return 0;
 }
 
-/*
- * Attempt to initialize the adapter via a Firmware Configuration File.
- */
-static int adap_init0_config(struct adapter *adapter, int reset)
+static void cxgb4_config_complete(const struct firmware *cf, void *context)
 {
-	struct fw_caps_config_cmd caps_cmd;
-	const struct firmware *cf;
+	struct adapter *adapter = context;
 	unsigned long mtype = 0, maddr = 0;
 	u32 finiver, finicsum, cfcsum;
-	int ret;
-	int config_issued = 0;
-	char *fw_config_file, fw_config_file_path[256];
 	char *config_name = NULL;
+	struct fw_caps_config_cmd caps_cmd;
+	int config_issued = 0;
+	int ret = 0;
+	char fw_config_file_path[256];
 
-	/*
-	 * Reset device if necessary.
-	 */
-	if (reset) {
-		ret = t4_fw_reset(adapter, adapter->mbox,
-				  PIORSTMODE | PIORST);
-		if (ret < 0)
-			goto bye;
-	}
-
-	/*
-	 * If we have a T4 configuration file under /lib/firmware/cxgb4/,
-	 * then use that.  Otherwise, use the configuration file stored
-	 * in the adapter flash ...
-	 */
-	switch (CHELSIO_CHIP_VERSION(adapter->params.chip)) {
-	case CHELSIO_T4:
-		fw_config_file = FW4_CFNAME;
-		break;
-	case CHELSIO_T5:
-		fw_config_file = FW5_CFNAME;
-		break;
-	default:
-		dev_err(adapter->pdev_dev, "Device %d is not supported\n",
-		       adapter->pdev->device);
-		ret = -EINVAL;
-		goto bye;
-	}
-
-	ret = request_firmware(&cf, fw_config_file, adapter->pdev_dev);
-	if (ret < 0) {
+	if (!cf) {
 		config_name = "On FLASH";
 		mtype = FW_MEMTYPE_CF_FLASH;
 		maddr = t4_flash_cfg_addr(adapter);
@@ -4879,7 +4846,7 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 		u32 params[7], val[7];
 
 		sprintf(fw_config_file_path,
-			"/lib/firmware/%s", fw_config_file);
+			"/lib/firmware/%s", adapter->fw_config_file);
 		config_name = fw_config_file_path;
 
 		if (cf->size >= FLASH_CFG_MAX_SIZE)
@@ -4898,7 +4865,7 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 				 * to write that out separately since we can't
 				 * guarantee that the bytes following the
 				 * residual byte in the buffer returned by
-				 * request_firmware() are zeroed out ...
+				 * request_firmware_nowait() are zeroed out ...
 				 */
 				size_t resid = cf->size & 0x3;
 				size_t size = cf->size & ~0x3;
@@ -5018,7 +4985,8 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	dev_info(adapter->pdev_dev, "Successfully configured using Firmware "\
 		 "Configuration File \"%s\", version %#x, computed checksum %#x\n",
 		 config_name, finiver, cfcsum);
-	return 0;
+	complete(&adapter->config_comp);
+	return;
 
 	/*
 	 * Something bad happened.  Return the error ...  (If the "error"
@@ -5026,10 +4994,67 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	 * want to issue a warning since this is fairly common.)
 	 */
 bye:
+	adapter->flash_comp_status = ret;
 	if (config_issued && ret != -ENOENT)
 		dev_warn(adapter->pdev_dev, "\"%s\" configuration file error %d\n",
 			 config_name, -ret);
-	return ret;
+	complete(&adapter->config_comp);
+}
+
+/*
+ * Attempt to initialize the adapter via a Firmware Configuration File.
+ */
+static int adap_init0_config(struct adapter *adapter, int reset)
+{
+	int ret;
+
+	/*
+	 * Reset device if necessary.
+	 */
+	if (reset) {
+		ret = t4_fw_reset(adapter, adapter->mbox,
+				  PIORSTMODE | PIORST);
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * If we have a T4 configuration file under /lib/firmware/cxgb4/,
+	 * then use that.  Otherwise, use the configuration file stored
+	 * in the adapter flash ...
+	 */
+	switch (CHELSIO_CHIP_VERSION(adapter->params.chip)) {
+	case CHELSIO_T4:
+		snprintf(adapter->fw_config_file,
+			 sizeof(adapter->fw_config_file),
+			 "%s", FW4_CFNAME);
+		break;
+	case CHELSIO_T5:
+		snprintf(adapter->fw_config_file,
+			 sizeof(adapter->fw_config_file),
+			 "%s", FW5_CFNAME);
+		break;
+	default:
+		dev_err(adapter->pdev_dev, "Device %d is not supported\n",
+		       adapter->pdev->device);
+		ret = -EINVAL;
+		return ret;
+	}
+
+	init_completion(&adapter->config_comp);
+	adapter->config_comp_status = 0;
+
+	ret = request_firmware_nowait(THIS_MODULE, 1, adapter->fw_config_file,
+				      adapter->pdev_dev, GFP_KERNEL,
+				      adapter, cxgb4_config_complete);
+	if (ret < 0)
+		return ret;
+
+	wait_for_completion(&adapter->flash_comp);
+	if (adapter->config_comp_status != 0)
+		return adapter->config_comp_status;
+
+	return 0;
 }
 
 /*
-- 
2.0.0
