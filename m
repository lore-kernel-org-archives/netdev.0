From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [net-next 1/3] iwmc3200top: clean up fw_download
Date: Wed, 16 Dec 2009 16:26:24 +0200
Message-ID: <1260973586-10243-1-git-send-email-tomas.winkler@intel.com>
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

1. removed redundant NULL-pointers checks in iwmct_fw_load
as release_firmware and kfree are NULL pointer friendly
2. remove redundant memset of the parser since the structure
is fully initialized in iwmct_fw_parser_init function

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/misc/iwmc3200top/fw-download.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/iwmc3200top/fw-download.c
index 50d431e..474be92 100644
--- a/drivers/misc/iwmc3200top/fw-download.c
+++ b/drivers/misc/iwmc3200top/fw-download.c
@@ -50,8 +50,7 @@ static int iwmct_fw_parser_init(struct iwmct_priv *priv, const u8 *file,
 	parser->file = file;
 	parser->file_size = file_size;
 	parser->cur_pos = 0;
-	parser->buf = NULL;
-
+	parser->entry_point = 0;
 	parser->buf = kzalloc(block_size, GFP_KERNEL);
 	if (!parser->buf) {
 		LOG_ERROR(priv, FW_DOWNLOAD, "kzalloc error\n");
@@ -298,8 +297,6 @@ int iwmct_fw_load(struct iwmct_priv *priv)
 	__le32 addr;
 	int ret;
 
-	/* clear parser struct */
-	memset(&priv->parser, 0, sizeof(struct iwmct_parser));
 
 	/* get the firmware */
 	ret = request_firmware(&raw, fw_name, &priv->func->dev);
@@ -317,6 +314,7 @@ int iwmct_fw_load(struct iwmct_priv *priv)
 
 	LOG_INFO(priv, FW_DOWNLOAD, "Read firmware '%s'\n", fw_name);
 
+	/* clear parser struct */
 	ret = iwmct_fw_parser_init(priv, raw->data, raw->size, priv->trans_len);
 	if (ret < 0) {
 		LOG_ERROR(priv, FW_DOWNLOAD,
@@ -324,7 +322,6 @@ int iwmct_fw_load(struct iwmct_priv *priv)
 		goto exit;
 	}
 
-	/* checksum  */
 	if (!iwmct_checksum(priv)) {
 		LOG_ERROR(priv, FW_DOWNLOAD, "checksum error\n");
 		ret = -EINVAL;
@@ -333,23 +330,18 @@ int iwmct_fw_load(struct iwmct_priv *priv)
 
 	/* download firmware to device */
 	while (iwmct_parse_next_section(priv, &pdata, &len, &addr)) {
-		if (iwmct_download_section(priv, pdata, len, addr)) {
+		ret = iwmct_download_section(priv, pdata, len, addr);
+		if (ret) {
 			LOG_ERROR(priv, FW_DOWNLOAD,
 				  "%s download section failed\n", fw_name);
-			ret = -EIO;
 			goto exit;
 		}
 	}
 
-	iwmct_kick_fw(priv, !!(priv->barker & BARKER_DNLOAD_JUMP_MSK));
+	ret = iwmct_kick_fw(priv, !!(priv->barker & BARKER_DNLOAD_JUMP_MSK));
 
 exit:
 	kfree(priv->parser.buf);
-
-	if (raw)
-		release_firmware(raw);
-
-	raw = NULL;
-
+	release_firmware(raw);
 	return ret;
 }
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

