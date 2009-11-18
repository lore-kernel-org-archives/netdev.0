From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [net-next 1/1] iwmc3200top: revamp fw name handling
Date: Thu, 19 Nov 2009 01:55:19 +0200
Message-ID: <1258588519-7939-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com,
	Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. define macro for handling firmware api version
2. add MODULE_FIRMWARE
3. cleanup iwmct_fw_load style

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/misc/iwmc3200top/fw-download.c |   24 ++++++++++--------------
 drivers/misc/iwmc3200top/iwmc3200top.h |    3 +++
 drivers/misc/iwmc3200top/main.c        |    1 +
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/iwmc3200top/fw-download.c
index 33cb693..50d431e 100644
--- a/drivers/misc/iwmc3200top/fw-download.c
+++ b/drivers/misc/iwmc3200top/fw-download.c
@@ -291,35 +291,31 @@ static int iwmct_kick_fw(struct iwmct_priv *priv, bool jump)
 
 int iwmct_fw_load(struct iwmct_priv *priv)
 {
-	const struct firmware *raw = NULL;
-	__le32 addr;
-	size_t len;
+	const u8 *fw_name = FW_NAME(FW_API_VER);
+	const struct firmware *raw;
 	const u8 *pdata;
-	const u8 *name = "iwmc3200top.1.fw";
-	int ret = 0;
+	size_t len;
+	__le32 addr;
+	int ret;
 
 	/* clear parser struct */
 	memset(&priv->parser, 0, sizeof(struct iwmct_parser));
-	if (!name) {
-		ret = -EINVAL;
-		goto exit;
-	}
 
 	/* get the firmware */
-	ret = request_firmware(&raw, name, &priv->func->dev);
+	ret = request_firmware(&raw, fw_name, &priv->func->dev);
 	if (ret < 0) {
 		LOG_ERROR(priv, FW_DOWNLOAD, "%s request_firmware failed %d\n",
-			  name, ret);
+			  fw_name, ret);
 		goto exit;
 	}
 
 	if (raw->size < sizeof(struct iwmct_fw_sec_hdr)) {
 		LOG_ERROR(priv, FW_DOWNLOAD, "%s smaller then (%zd) (%zd)\n",
-			  name, sizeof(struct iwmct_fw_sec_hdr), raw->size);
+			  fw_name, sizeof(struct iwmct_fw_sec_hdr), raw->size);
 		goto exit;
 	}
 
-	LOG_INFO(priv, FW_DOWNLOAD, "Read firmware '%s'\n", name);
+	LOG_INFO(priv, FW_DOWNLOAD, "Read firmware '%s'\n", fw_name);
 
 	ret = iwmct_fw_parser_init(priv, raw->data, raw->size, priv->trans_len);
 	if (ret < 0) {
@@ -339,7 +335,7 @@ int iwmct_fw_load(struct iwmct_priv *priv)
 	while (iwmct_parse_next_section(priv, &pdata, &len, &addr)) {
 		if (iwmct_download_section(priv, pdata, len, addr)) {
 			LOG_ERROR(priv, FW_DOWNLOAD,
-				  "%s download section failed\n", name);
+				  "%s download section failed\n", fw_name);
 			ret = -EIO;
 			goto exit;
 		}
diff --git a/drivers/misc/iwmc3200top/iwmc3200top.h b/drivers/misc/iwmc3200top/iwmc3200top.h
index f572fcf..43bd510 100644
--- a/drivers/misc/iwmc3200top/iwmc3200top.h
+++ b/drivers/misc/iwmc3200top/iwmc3200top.h
@@ -30,6 +30,9 @@
 #include <linux/workqueue.h>
 
 #define DRV_NAME "iwmc3200top"
+#define FW_API_VER 1
+#define _FW_NAME(api) DRV_NAME "." #api ".fw"
+#define FW_NAME(api) _FW_NAME(api)
 
 #define IWMC_SDIO_BLK_SIZE			256
 #define IWMC_DEFAULT_TR_BLK			64
diff --git a/drivers/misc/iwmc3200top/main.c b/drivers/misc/iwmc3200top/main.c
index 02b3dad..fafcaa4 100644
--- a/drivers/misc/iwmc3200top/main.c
+++ b/drivers/misc/iwmc3200top/main.c
@@ -47,6 +47,7 @@ MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
 MODULE_VERSION(DRIVER_VERSION);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR(DRIVER_COPYRIGHT);
+MODULE_FIRMWARE(FW_NAME(FW_API_VER));
 
 /*
  * This workers main task is to wait for OP_OPR_ALIVE
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

