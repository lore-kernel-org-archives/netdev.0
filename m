From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [net-next 2/3] iwmc3200top: cleanup log messages
Date: Wed, 16 Dec 2009 16:26:25 +0200
Message-ID: <1260973586-10243-2-git-send-email-tomas.winkler@intel.com>
References: <1260973586-10243-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com,
	Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1260973586-10243-1-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. add TRACE level
2. use TRACE where needed to reduce the noise
3  don't INFOEX from driver
4. add DUMP level for packets dumps
5. use correct context for the log messages

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/misc/iwmc3200top/fw-download.c |   26 ++++++++++++++++++--------
 drivers/misc/iwmc3200top/log.h         |   31 ++++++++++++++++++++++---------
 drivers/misc/iwmc3200top/main.c        |   25 ++++++++-----------------
 3 files changed, 48 insertions(+), 34 deletions(-)

diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/iwmc3200top/fw-download.c
index 474be92..07055af 100644
--- a/drivers/misc/iwmc3200top/fw-download.c
+++ b/drivers/misc/iwmc3200top/fw-download.c
@@ -43,7 +43,7 @@ static int iwmct_fw_parser_init(struct iwmct_priv *priv, const u8 *file,
 	struct iwmct_parser *parser = &priv->parser;
 	struct iwmct_fw_hdr *fw_hdr = &parser->versions;
 
-	LOG_INFOEX(priv, INIT, "-->\n");
+	LOG_TRACE(priv, FW_DOWNLOAD, "-->\n");
 
 	LOG_INFO(priv, FW_DOWNLOAD, "file_size=%zd\n", file_size);
 
@@ -69,7 +69,7 @@ static int iwmct_fw_parser_init(struct iwmct_priv *priv, const u8 *file,
 
 	parser->cur_pos += sizeof(struct iwmct_fw_hdr);
 
-	LOG_INFOEX(priv, INIT, "<--\n");
+	LOG_TRACE(priv, FW_DOWNLOAD, "<--\n");
 	return 0;
 }
 
@@ -112,7 +112,7 @@ static int iwmct_parse_next_section(struct iwmct_priv *priv, const u8 **p_sec,
 	struct iwmct_dbg *dbg = &priv->dbg;
 	struct iwmct_fw_sec_hdr *sec_hdr;
 
-	LOG_INFOEX(priv, INIT, "-->\n");
+	LOG_TRACE(priv, FW_DOWNLOAD, "-->\n");
 
 	while (parser->cur_pos + sizeof(struct iwmct_fw_sec_hdr)
 		<= parser->file_size) {
@@ -151,7 +151,7 @@ static int iwmct_parse_next_section(struct iwmct_priv *priv, const u8 **p_sec,
 			"finished with section cur_pos=%zd\n", parser->cur_pos);
 	}
 
-	LOG_INFOEX(priv, INIT, "<--\n");
+	LOG_TRACE(priv, INIT, "<--\n");
 	return 0;
 }
 
@@ -166,7 +166,7 @@ static int iwmct_download_section(struct iwmct_priv *priv, const u8 *p_sec,
 	int ret = 0;
 	u32 cmd = 0;
 
-	LOG_INFOEX(priv, INIT, "-->\n");
+	LOG_TRACE(priv, FW_DOWNLOAD, "-->\n");
 	LOG_INFO(priv, FW_DOWNLOAD, "Download address 0x%x size 0x%zx\n",
 				addr, sec_size);
 
@@ -250,7 +250,7 @@ static int iwmct_download_section(struct iwmct_priv *priv, const u8 *p_sec,
 	if (sent < sec_size)
 		ret = -EINVAL;
 exit:
-	LOG_INFOEX(priv, INIT, "<--\n");
+	LOG_TRACE(priv, FW_DOWNLOAD, "<--\n");
 	return ret;
 }
 
@@ -261,7 +261,7 @@ static int iwmct_kick_fw(struct iwmct_priv *priv, bool jump)
 	int ret;
 	u32 cmd;
 
-	LOG_INFOEX(priv, INIT, "-->\n");
+	LOG_TRACE(priv, FW_DOWNLOAD, "-->\n");
 
 	memset(parser->buf, 0, parser->buf_size);
 	cmd = IWMC_CMD_SIGNATURE << CMD_HDR_SIGNATURE_POS;
@@ -284,7 +284,7 @@ static int iwmct_kick_fw(struct iwmct_priv *priv, bool jump)
 	if (ret)
 		LOG_INFO(priv, FW_DOWNLOAD, "iwmct_tx returned %d", ret);
 
-	LOG_INFOEX(priv, INIT, "<--\n");
+	LOG_TRACE(priv, FW_DOWNLOAD, "<--\n");
 	return 0;
 }
 
@@ -298,6 +298,16 @@ int iwmct_fw_load(struct iwmct_priv *priv)
 	int ret;
 
 
+	LOG_INFO(priv, FW_DOWNLOAD, "barker download request 0x%x is:\n",
+			priv->barker);
+	LOG_INFO(priv, FW_DOWNLOAD, "*******  Top FW %s requested ********\n",
+			(priv->barker & BARKER_DNLOAD_TOP_MSK) ? "was" : "not");
+	LOG_INFO(priv, FW_DOWNLOAD, "*******  GPS FW %s requested ********\n",
+			(priv->barker & BARKER_DNLOAD_GPS_MSK) ? "was" : "not");
+	LOG_INFO(priv, FW_DOWNLOAD, "*******  BT FW %s requested ********\n",
+			(priv->barker & BARKER_DNLOAD_BT_MSK) ? "was" : "not");
+
+
 	/* get the firmware */
 	ret = request_firmware(&raw, fw_name, &priv->func->dev);
 	if (ret < 0) {
diff --git a/drivers/misc/iwmc3200top/log.h b/drivers/misc/iwmc3200top/log.h
index aba8121..4434bb1 100644
--- a/drivers/misc/iwmc3200top/log.h
+++ b/drivers/misc/iwmc3200top/log.h
@@ -37,13 +37,26 @@
 #define LOG_SEV_INFO			3
 #define LOG_SEV_INFOEX			4
 
-#define LOG_SEV_FILTER_ALL		\
-	(BIT(LOG_SEV_CRITICAL) |	\
-	 BIT(LOG_SEV_ERROR)    |	\
-	 BIT(LOG_SEV_WARNING)  | 	\
-	 BIT(LOG_SEV_INFO)     |	\
+/* Log levels not defined for FW */
+#define LOG_SEV_TRACE			5
+#define LOG_SEV_DUMP			6
+
+#define LOG_SEV_FW_FILTER_ALL		\
+	(BIT(LOG_SEV_CRITICAL)	|	\
+	 BIT(LOG_SEV_ERROR)	|	\
+	 BIT(LOG_SEV_WARNING)	| 	\
+	 BIT(LOG_SEV_INFO)	|	\
 	 BIT(LOG_SEV_INFOEX))
 
+#define LOG_SEV_FILTER_ALL		\
+	(BIT(LOG_SEV_CRITICAL)	|	\
+	 BIT(LOG_SEV_ERROR)	|	\
+	 BIT(LOG_SEV_WARNING)	| 	\
+	 BIT(LOG_SEV_INFO)	|	\
+	 BIT(LOG_SEV_INFOEX)	|	\
+	 BIT(LOG_SEV_TRACE)	|	\
+	 BIT(LOG_SEV_DUMP))
+
 /* log source */
 #define LOG_SRC_INIT			0
 #define LOG_SRC_DEBUGFS			1
@@ -104,16 +117,16 @@ do {									\
 			 __func__, __LINE__, ##args);			\
 } while (0)
 
-#define LOG_INFOEX(priv, src, fmt, args...)				\
+#define LOG_TRACE(priv, src, fmt, args...)				\
 do {									\
-	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INFOEX))	\
+	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_TRACE))	\
 		dev_dbg(priv2dev(priv), "%s %d: " fmt,			\
 			 __func__, __LINE__, ##args);			\
 } while (0)
 
 #define LOG_HEXDUMP(src, ptr, len)					\
 do {									\
-	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INFOEX))	\
+	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_DUMP))	\
 		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_NONE,	\
 				16, 1, ptr, len, false);		\
 } while (0)
@@ -142,7 +155,7 @@ ssize_t store_iwmct_log_level_fw(struct device *d,
 #define LOG_ERROR(priv, src, fmt, args...)
 #define LOG_WARNING(priv, src, fmt, args...)
 #define LOG_INFO(priv, src, fmt, args...)
-#define LOG_INFOEX(priv, src, fmt, args...)
+#define LOG_TRACE(priv, src, fmt, args...)
 #define LOG_HEXDUMP(src, ptr, len)
 
 static inline void iwmct_log_top_message(struct iwmct_priv *priv,
diff --git a/drivers/misc/iwmc3200top/main.c b/drivers/misc/iwmc3200top/main.c
index fafcaa4..3862794 100644
--- a/drivers/misc/iwmc3200top/main.c
+++ b/drivers/misc/iwmc3200top/main.c
@@ -66,7 +66,7 @@ static void iwmct_rescan_worker(struct work_struct *ws)
 
 	ret = bus_rescan_devices(priv->func->dev.bus);
 	if (ret < 0)
-		LOG_INFO(priv, FW_DOWNLOAD, "bus_rescan_devices FAILED!!!\n");
+		LOG_INFO(priv, INIT, "bus_rescan_devices FAILED!!!\n");
 }
 
 static void op_top_message(struct iwmct_priv *priv, struct top_msg *msg)
@@ -137,7 +137,7 @@ int iwmct_send_hcmd(struct iwmct_priv *priv, u8 *cmd, u16 len)
 	int ret;
 	u8 *buf;
 
-	LOG_INFOEX(priv, FW_MSG, "Sending hcmd:\n");
+	LOG_TRACE(priv, FW_MSG, "Sending hcmd:\n");
 
 	/* add padding to 256 for IWMC */
 	((struct top_msg *)cmd)->hdr.flags |= CMD_FLAG_PADDING_256;
@@ -192,7 +192,7 @@ static void iwmct_irq_read_worker(struct work_struct *ws)
 
 	priv = container_of(ws, struct iwmct_priv, isr_worker);
 
-	LOG_INFO(priv, IRQ, "enter iwmct_irq_read_worker %p\n", ws);
+	LOG_TRACE(priv, IRQ, "enter iwmct_irq_read_worker %p\n", ws);
 
 	/* --------------------- Handshake with device -------------------- */
 	sdio_claim_host(priv->func);
@@ -292,15 +292,6 @@ static void iwmct_irq_read_worker(struct work_struct *ws)
 
 	sdio_release_host(priv->func);
 
-
-	LOG_INFO(priv, IRQ, "barker download request 0x%x is:\n", priv->barker);
-	LOG_INFO(priv, IRQ, "*******  Top FW %s requested ********\n",
-			(priv->barker & BARKER_DNLOAD_TOP_MSK) ? "was" : "not");
-	LOG_INFO(priv, IRQ, "*******  GPS FW %s requested ********\n",
-			(priv->barker & BARKER_DNLOAD_GPS_MSK) ? "was" : "not");
-	LOG_INFO(priv, IRQ, "*******  BT FW %s requested ********\n",
-			(priv->barker & BARKER_DNLOAD_BT_MSK) ? "was" : "not");
-
 	if (priv->dbg.fw_download)
 		iwmct_fw_load(priv);
 	else
@@ -312,7 +303,7 @@ exit_release:
 	sdio_release_host(priv->func);
 exit:
 	kfree(buf);
-	LOG_INFO(priv, IRQ, "exit iwmct_irq_read_worker\n");
+	LOG_TRACE(priv, IRQ, "exit iwmct_irq_read_worker\n");
 }
 
 static void iwmct_irq(struct sdio_func *func)
@@ -325,12 +316,12 @@ static void iwmct_irq(struct sdio_func *func)
 
 	priv = sdio_get_drvdata(func);
 
-	LOG_INFO(priv, IRQ, "enter iwmct_irq\n");
+	LOG_TRACE(priv, IRQ, "enter iwmct_irq\n");
 
 	/* read the function's status register */
 	val = sdio_readb(func, IWMC_SDIO_INTR_STATUS_ADDR, &ret);
 
-	LOG_INFO(priv, IRQ, "iir value = %d, ret=%d\n", val, ret);
+	LOG_TRACE(priv, IRQ, "iir value = %d, ret=%d\n", val, ret);
 
 	if (!val) {
 		LOG_ERROR(priv, IRQ, "iir = 0, exiting ISR\n");
@@ -372,7 +363,7 @@ static void iwmct_irq(struct sdio_func *func)
 
 	queue_work(priv->wq, &priv->isr_worker);
 
-	LOG_INFO(priv, IRQ, "exit iwmct_irq\n");
+	LOG_TRACE(priv, IRQ, "exit iwmct_irq\n");
 
 	return;
 
@@ -660,7 +651,7 @@ static int __init iwmct_init(void)
 
 	/* Default log filter settings */
 	iwmct_log_set_filter(LOG_SRC_ALL, LOG_SEV_FILTER_RUNTIME);
-	iwmct_log_set_filter(LOG_SRC_FW_MSG, LOG_SEV_FILTER_ALL);
+	iwmct_log_set_filter(LOG_SRC_FW_MSG, LOG_SEV_FW_FILTER_ALL);
 	iwmct_log_set_fw_filter(LOG_SRC_ALL, FW_LOG_SEV_FILTER_RUNTIME);
 
 	rc = sdio_register_driver(&iwmct_driver);
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

