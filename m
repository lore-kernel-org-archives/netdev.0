From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [net-2.6 3/3] iwmc3200top: simplify imwct_tx
Date: Mon, 14 Dec 2009 22:30:23 +0200
Message-ID: <1260822623-16480-3-git-send-email-tomas.winkler@intel.com>
References: <1260822623-16480-1-git-send-email-tomas.winkler@intel.com>
 <1260822623-16480-2-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com,
	Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1260822623-16480-2-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. remove address argument since we use same address IWMC_SDIO_DATA_ADDR in
    all cases
2. add __iwmct_tx - non locking tx function for already locked contexts

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/misc/iwmc3200top/fw-download.c |    4 +-
 drivers/misc/iwmc3200top/iwmc3200top.h |    4 +--
 drivers/misc/iwmc3200top/main.c        |   34 +++++++++++++++----------------
 3 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/iwmc3200top/fw-download.c
index 07055af..9dbaeb5 100644
--- a/drivers/misc/iwmc3200top/fw-download.c
+++ b/drivers/misc/iwmc3200top/fw-download.c
@@ -228,7 +228,7 @@ static int iwmct_download_section(struct iwmct_priv *priv, const u8 *p_sec,
 		hdr->cmd = cpu_to_le32(cmd);
 		/* send it down */
 		/* TODO: add more proper sending and error checking */
-		ret = iwmct_tx(priv, 0, parser->buf, trans_size);
+		ret = iwmct_tx(priv, parser->buf, trans_size);
 		if (ret != 0) {
 			LOG_INFO(priv, FW_DOWNLOAD,
 				"iwmct_tx returned %d\n", ret);
@@ -280,7 +280,7 @@ static int iwmct_kick_fw(struct iwmct_priv *priv, bool jump)
 	LOG_HEXDUMP(FW_DOWNLOAD, parser->buf, sizeof(*hdr));
 	/* send it down */
 	/* TODO: add more proper sending and error checking */
-	ret = iwmct_tx(priv, 0, parser->buf, IWMC_SDIO_BLK_SIZE);
+	ret = iwmct_tx(priv, parser->buf, IWMC_SDIO_BLK_SIZE);
 	if (ret)
 		LOG_INFO(priv, FW_DOWNLOAD, "iwmct_tx returned %d", ret);
 
diff --git a/drivers/misc/iwmc3200top/iwmc3200top.h b/drivers/misc/iwmc3200top/iwmc3200top.h
index 43bd510..740ff07 100644
--- a/drivers/misc/iwmc3200top/iwmc3200top.h
+++ b/drivers/misc/iwmc3200top/iwmc3200top.h
@@ -196,9 +196,7 @@ struct iwmct_priv {
 	struct list_head read_req_list;
 };
 
-extern int iwmct_tx(struct iwmct_priv *priv, unsigned int addr,
-		void *src, int count);
-
+extern int iwmct_tx(struct iwmct_priv *priv, void *src, int count);
 extern int iwmct_fw_load(struct iwmct_priv *priv);
 
 extern void iwmct_dbg_init_params(struct iwmct_priv *drv);
diff --git a/drivers/misc/iwmc3200top/main.c b/drivers/misc/iwmc3200top/main.c
index 3862794..dd0a391 100644
--- a/drivers/misc/iwmc3200top/main.c
+++ b/drivers/misc/iwmc3200top/main.c
@@ -49,6 +49,20 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR(DRIVER_COPYRIGHT);
 MODULE_FIRMWARE(FW_NAME(FW_API_VER));
 
+
+static inline int __iwmct_tx(struct iwmct_priv *priv, void *src, int count)
+{
+	return sdio_memcpy_toio(priv->func, IWMC_SDIO_DATA_ADDR, src, count);
+
+}
+int iwmct_tx(struct iwmct_priv *priv, void *src, int count)
+{
+	int ret;
+	sdio_claim_host(priv->func);
+	ret =  __iwmct_tx(priv, src, count);
+	sdio_release_host(priv->func);
+	return ret;
+}
 /*
  * This workers main task is to wait for OP_OPR_ALIVE
  * from TOP FW until ALIVE_MSG_TIMOUT timeout is elapsed.
@@ -158,27 +172,12 @@ int iwmct_send_hcmd(struct iwmct_priv *priv, u8 *cmd, u16 len)
 	}
 
 	memcpy(buf, cmd, len);
-
-	sdio_claim_host(priv->func);
-	ret = sdio_memcpy_toio(priv->func, IWMC_SDIO_DATA_ADDR, buf,
-			       FW_HCMD_BLOCK_SIZE);
-	sdio_release_host(priv->func);
+	ret = iwmct_tx(priv, buf, FW_HCMD_BLOCK_SIZE);
 
 	kfree(buf);
 	return ret;
 }
 
-int iwmct_tx(struct iwmct_priv *priv, unsigned int addr,
-	void *src, int count)
-{
-	int ret;
-
-	sdio_claim_host(priv->func);
-	ret = sdio_memcpy_toio(priv->func, addr, src, count);
-	sdio_release_host(priv->func);
-
-	return ret;
-}
 
 static void iwmct_irq_read_worker(struct work_struct *ws)
 {
@@ -273,8 +272,7 @@ static void iwmct_irq_read_worker(struct work_struct *ws)
 
 		if (barker & BARKER_DNLOAD_SYNC_MSK) {
 			/* Send the same barker back */
-			ret = sdio_memcpy_toio(priv->func, IWMC_SDIO_DATA_ADDR,
-					       buf, iosize);
+			ret = __iwmct_tx(priv, buf, iosize);
 			if (ret) {
 				LOG_ERROR(priv, IRQ,
 					 "error %d echoing barker\n", ret);
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

