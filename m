From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/2] CW1200: Less function calls in cw1200_load_firmware_cw1200()
 after error detection
Date: Wed, 04 Feb 2015 17:48:42 +0100
Message-ID: <54D24D6A.2020404@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <54D24CC3.9010006@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Kalle Valo <kvalo@codeaurora.org>,
	Solomon Peachy <pizza@shaftnet.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D24CC3.9010006@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 4 Feb 2015 17:28:41 +0100

The functions kfree() and release_firmware() were called in a few cases
by the cw1200_load_firmware_cw1200() function during error handling even if
the passed variables contained still a null pointer.

Corresponding implementation details could be improved by adjustments for
jump targets.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/cw1200/fwio.c | 37 +++++++++++++++++++++++--------------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/cw1200/fwio.c b/drivers/net/wireless/cw1200/fwio.c
index 581dfde..30e7646 100644
--- a/drivers/net/wireless/cw1200/fwio.c
+++ b/drivers/net/wireless/cw1200/fwio.c
@@ -66,25 +66,31 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 	do { \
 		ret = cw1200_apb_write_32(priv, CW1200_APB(reg), (val)); \
 		if (ret < 0) \
-			goto error; \
+			goto exit; \
+	} while (0)
+#define APB_WRITE2(reg, val) \
+	do { \
+		ret = cw1200_apb_write_32(priv, CW1200_APB(reg), (val)); \
+		if (ret < 0) \
+			goto free_buffer; \
 	} while (0)
 #define APB_READ(reg, val) \
 	do { \
 		ret = cw1200_apb_read_32(priv, CW1200_APB(reg), &(val)); \
 		if (ret < 0) \
-			goto error; \
+			goto free_buffer; \
 	} while (0)
 #define REG_WRITE(reg, val) \
 	do { \
 		ret = cw1200_reg_write_32(priv, (reg), (val)); \
 		if (ret < 0) \
-			goto error; \
+			goto exit; \
 	} while (0)
 #define REG_READ(reg, val) \
 	do { \
 		ret = cw1200_reg_read_32(priv, (reg), &(val)); \
 		if (ret < 0) \
-			goto error; \
+			goto exit; \
 	} while (0)
 
 	switch (priv->hw_revision) {
@@ -142,14 +148,14 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 	ret = request_firmware(&firmware, fw_path, priv->pdev);
 	if (ret) {
 		pr_err("Can't load firmware file %s.\n", fw_path);
-		goto error;
+		goto exit;
 	}
 
 	buf = kmalloc(DOWNLOAD_BLOCK_SIZE, GFP_KERNEL | GFP_DMA);
 	if (!buf) {
 		pr_err("Can't allocate firmware load buffer.\n");
 		ret = -ENOMEM;
-		goto error;
+		goto firmware_release;
 	}
 
 	/* Check if the bootloader is ready */
@@ -163,7 +169,7 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 	if (val32 != DOWNLOAD_I_AM_HERE) {
 		pr_err("Bootloader is not ready.\n");
 		ret = -ETIMEDOUT;
-		goto error;
+		goto free_buffer;
 	}
 
 	/* Calculcate number of download blocks */
@@ -171,7 +177,7 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 
 	/* Updating the length in Download Ctrl Area */
 	val32 = firmware->size; /* Explicit cast from size_t to u32 */
-	APB_WRITE(DOWNLOAD_IMAGE_SIZE_REG, val32);
+	APB_WRITE2(DOWNLOAD_IMAGE_SIZE_REG, val32);
 
 	/* Firmware downloading loop */
 	for (block = 0; block < num_blocks; block++) {
@@ -183,7 +189,7 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 		if (val32 != DOWNLOAD_PENDING) {
 			pr_err("Bootloader reported error %d.\n", val32);
 			ret = -EIO;
-			goto error;
+			goto free_buffer;
 		}
 
 		/* loop until put - get <= 24K */
@@ -198,7 +204,7 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 		if ((put - get) > (DOWNLOAD_FIFO_SIZE - DOWNLOAD_BLOCK_SIZE)) {
 			pr_err("Timeout waiting for FIFO.\n");
 			ret = -ETIMEDOUT;
-			goto error;
+			goto free_buffer;
 		}
 
 		/* calculate the block size */
@@ -220,12 +226,12 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 		if (ret < 0) {
 			pr_err("Can't write firmware block @ %d!\n",
 			       put & (DOWNLOAD_FIFO_SIZE - 1));
-			goto error;
+			goto free_buffer;
 		}
 
 		/* update the put register */
 		put += block_size;
-		APB_WRITE(DOWNLOAD_PUT_REG, put);
+		APB_WRITE2(DOWNLOAD_PUT_REG, put);
 	} /* End of firmware download loop */
 
 	/* Wait for the download completion */
@@ -238,18 +244,21 @@ static int cw1200_load_firmware_cw1200(struct cw1200_common *priv)
 	if (val32 != DOWNLOAD_SUCCESS) {
 		pr_err("Wait for download completion failed: 0x%.8X\n", val32);
 		ret = -ETIMEDOUT;
-		goto error;
+		goto free_buffer;
 	} else {
 		pr_info("Firmware download completed.\n");
 		ret = 0;
 	}
 
-error:
+free_buffer:
 	kfree(buf);
+firmware_release:
 	release_firmware(firmware);
+exit:
 	return ret;
 
 #undef APB_WRITE
+#undef APB_WRITE2
 #undef APB_READ
 #undef REG_WRITE
 #undef REG_READ
-- 
2.2.2
