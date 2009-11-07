From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 40/75] cxgb3: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 21:53:52 +0000
Message-ID: <1257630832.15927.440.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Divy Le Ray <divy@chelsio.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42423 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753160AbZKGVxx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 16:53:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace run-time string formatting with preprocessor string
manipulation.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/cxgb3/common.h     |    8 +++-----
 drivers/net/cxgb3/cxgb3_main.c |   25 ++++++++++++++++---------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 1b2c305..6ff356d 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -125,11 +125,9 @@ enum {				/* adapter interrupt-maintained statistics */
 	IRQ_NUM_STATS		/* keep last */
 };
 
-enum {
-	TP_VERSION_MAJOR	= 1,
-	TP_VERSION_MINOR	= 1,
-	TP_VERSION_MICRO	= 0
-};
+#define TP_VERSION_MAJOR	1
+#define TP_VERSION_MINOR	1
+#define TP_VERSION_MICRO	0
 
 #define S_TP_VERSION_MAJOR		16
 #define M_TP_VERSION_MAJOR		0xFF
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index c9113d3..b1a5a00 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -44,6 +44,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/firmware.h>
 #include <linux/log2.h>
+#include <linux/stringify.h>
 #include <asm/uaccess.h>
 
 #include "common.h"
@@ -992,11 +993,21 @@ static int bind_qsets(struct adapter *adap)
 	return err;
 }
 
-#define FW_FNAME "cxgb3/t3fw-%d.%d.%d.bin"
-#define TPSRAM_NAME "cxgb3/t3%c_psram-%d.%d.%d.bin"
+#define FW_VERSION __stringify(FW_VERSION_MAJOR) "."			\
+	__stringify(FW_VERSION_MINOR) "." __stringify(FW_VERSION_MICRO)
+#define FW_FNAME "cxgb3/t3fw-" FW_VERSION ".bin"
+#define TPSRAM_VERSION __stringify(TP_VERSION_MAJOR) "."		\
+	__stringify(TP_VERSION_MINOR) "." __stringify(TP_VERSION_MICRO)
+#define TPSRAM_NAME "cxgb3/t3%c_psram-" TPSRAM_VERSION ".bin"
 #define AEL2005_OPT_EDC_NAME "cxgb3/ael2005_opt_edc.bin"
 #define AEL2005_TWX_EDC_NAME "cxgb3/ael2005_twx_edc.bin"
 #define AEL2020_TWX_EDC_NAME "cxgb3/ael2020_twx_edc.bin"
+MODULE_FIRMWARE(FW_FNAME);
+MODULE_FIRMWARE("cxgb3/t3b_psram-" TPSRAM_VERSION ".bin");
+MODULE_FIRMWARE("cxgb3/t3c_psram-" TPSRAM_VERSION ".bin");
+MODULE_FIRMWARE(AEL2005_OPT_EDC_NAME);
+MODULE_FIRMWARE(AEL2005_TWX_EDC_NAME);
+MODULE_FIRMWARE(AEL2020_TWX_EDC_NAME);
 
 static inline const char *get_edc_fw_name(int edc_idx)
 {
@@ -1067,16 +1078,13 @@ int t3_get_edc_fw(struct cphy *phy, int edc_idx, int size)
 static int upgrade_fw(struct adapter *adap)
 {
 	int ret;
-	char buf[64];
 	const struct firmware *fw;
 	struct device *dev = &adap->pdev->dev;
 
-	snprintf(buf, sizeof(buf), FW_FNAME, FW_VERSION_MAJOR,
-		 FW_VERSION_MINOR, FW_VERSION_MICRO);
-	ret = request_firmware(&fw, buf, dev);
+	ret = request_firmware(&fw, FW_FNAME, dev);
 	if (ret < 0) {
 		dev_err(dev, "could not upgrade firmware: unable to load %s\n",
-			buf);
+			FW_FNAME);
 		return ret;
 	}
 	ret = t3_load_fw(adap, fw->data, fw->size);
@@ -1120,8 +1128,7 @@ static int update_tpsram(struct adapter *adap)
 	if (!rev)
 		return 0;
 
-	snprintf(buf, sizeof(buf), TPSRAM_NAME, rev,
-		 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+	snprintf(buf, sizeof(buf), TPSRAM_NAME, rev);
 
 	ret = request_firmware(&tpsram, buf, dev);
 	if (ret < 0) {
-- 
1.6.5.2



