From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 09/18] ipw2200: Fix endian issues with v3.0 fw image format
Date: Thu, 13 Apr 2006 17:20:12 +0800
Message-ID: <20060413092012.GA28766@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:26538 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S964850AbWDMJ1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:17 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch corrects endian issues with the v3.0 fw image format.

Signed-off-by: James Ketrenos <jketreno@linux.intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

cde366e60f266195a1dd6d40b83c9bc97082f1a5
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 4b02920..7646def 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -3107,10 +3107,10 @@ static int ipw_reset_nic(struct ipw_priv
 
 
 struct ipw_fw {
-	u32 ver;
-	u32 boot_size;
-	u32 ucode_size;
-	u32 fw_size;
+	__le32 ver;
+	__le32 boot_size;
+	__le32 ucode_size;
+	__le32 fw_size;
 	u8 data[0];
 };
 
@@ -3134,8 +3134,8 @@ static int ipw_get_fw(struct ipw_priv *p
 
 	fw = (void *)(*raw)->data;
 
-	if ((*raw)->size < sizeof(*fw) +
-	    fw->boot_size + fw->ucode_size + fw->fw_size) {
+	if ((*raw)->size < sizeof(*fw) + le32_to_cpu(fw->boot_size) +
+	    le32_to_cpu(fw->ucode_size) + le32_to_cpu(fw->fw_size)) {
 		IPW_ERROR("%s is too small or corrupt (%zd)\n",
 			  name, (*raw)->size);
 		return -EINVAL;
@@ -3240,8 +3240,9 @@ static int ipw_load(struct ipw_priv *pri
 
 	fw = (void *)raw->data;
 	boot_img = &fw->data[0];
-	ucode_img = &fw->data[fw->boot_size];
-	fw_img = &fw->data[fw->boot_size + fw->ucode_size];
+	ucode_img = &fw->data[le32_to_cpu(fw->boot_size)];
+	fw_img = &fw->data[le32_to_cpu(fw->boot_size) +
+			   le32_to_cpu(fw->ucode_size)];
 
 	if (rc < 0)
 		goto error;
@@ -3275,7 +3276,7 @@ static int ipw_load(struct ipw_priv *pri
 			IPW_NIC_SRAM_UPPER_BOUND - IPW_NIC_SRAM_LOWER_BOUND);
 
 	/* DMA the initial boot firmware into the device */
-	rc = ipw_load_firmware(priv, boot_img, fw->boot_size);
+	rc = ipw_load_firmware(priv, boot_img, le32_to_cpu(fw->boot_size));
 	if (rc < 0) {
 		IPW_ERROR("Unable to load boot firmware: %d\n", rc);
 		goto error;
@@ -3297,7 +3298,7 @@ static int ipw_load(struct ipw_priv *pri
 	ipw_write32(priv, IPW_INTA_RW, IPW_INTA_BIT_FW_INITIALIZATION_DONE);
 
 	/* DMA the ucode into the device */
-	rc = ipw_load_ucode(priv, ucode_img, fw->ucode_size);
+	rc = ipw_load_ucode(priv, ucode_img, le32_to_cpu(fw->ucode_size));
 	if (rc < 0) {
 		IPW_ERROR("Unable to load ucode: %d\n", rc);
 		goto error;
@@ -3307,7 +3308,7 @@ static int ipw_load(struct ipw_priv *pri
 	ipw_stop_nic(priv);
 
 	/* DMA bss firmware into the device */
-	rc = ipw_load_firmware(priv, fw_img, fw->fw_size);
+	rc = ipw_load_firmware(priv, fw_img, le32_to_cpu(fw->fw_size));
 	if (rc < 0) {
 		IPW_ERROR("Unable to load firmware: %d\n", rc);
 		goto error;
-- 
1.2.6

