From: divy@chelsio.com
Subject: [PATCH 2.6.21 2/4] cxgb3 - Auto-load FW if mismatch detected
Date: Sun, 18 Mar 2007 13:10:06 -0700
Message-ID: <20070318201006.16292.12877.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28131 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933120AbXCRUKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 16:10:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

The driver attempts to upgrade the FW if the card has the wrong version.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---
---

 drivers/net/Kconfig            |    1 +
 drivers/net/cxgb3/cxgb3_main.c |   25 +++++++++++++++++++++++++
 drivers/net/cxgb3/t3_hw.c      |    5 +++--
 3 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5ff0922..1b6459b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2374,6 +2374,7 @@ config CHELSIO_T1_NAPI
 config CHELSIO_T3
         tristate "Chelsio Communications T3 10Gb Ethernet support"
         depends on PCI
+	select FW_LOADER
         help
           This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
           adapters.
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index eb0a4e0..b9bcda8 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -42,6 +42,7 @@
 #include <linux/workqueue.h>
 #include <linux/proc_fs.h>
 #include <linux/rtnetlink.h>
+#include <linux/firmware.h>
 #include <asm/uaccess.h>
 
 #include "common.h"
@@ -707,6 +708,28 @@ static void bind_qsets(struct adapter *a
 	}
 }
 
+#define FW_FNAME "t3fw-%d.%d.bin"
+
+static int upgrade_fw(struct adapter *adap)
+{
+	int ret;
+	char buf[64];
+	const struct firmware *fw;
+	struct device *dev = &adap->pdev->dev;
+
+	snprintf(buf, sizeof(buf), FW_FNAME, FW_VERSION_MAJOR,
+		 FW_VERSION_MINOR);
+	ret = request_firmware(&fw, buf, dev);
+	if (ret < 0) {
+		dev_err(dev, "could not upgrade firmware: unable to load %s\n",
+			buf);
+		return ret;
+	}
+	ret = t3_load_fw(adap, fw->data, fw->size);
+	release_firmware(fw);
+	return ret;
+}
+
 /**
  *	cxgb_up - enable the adapter
  *	@adapter: adapter being enabled
@@ -723,6 +746,8 @@ static int cxgb_up(struct adapter *adap)
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
+		if (err == -EINVAL)
+			err = upgrade_fw(adap);
 		if (err)
 			goto out;
 
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index eaa7a2e..983ee81 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -681,7 +681,8 @@ enum {
 	SF_ERASE_SECTOR = 0xd8,	/* erase sector */
 
 	FW_FLASH_BOOT_ADDR = 0x70000,	/* start address of FW in flash */
-	FW_VERS_ADDR = 0x77ffc	/* flash address holding FW version */
+	FW_VERS_ADDR = 0x77ffc,    /* flash address holding FW version */
+	FW_MIN_SIZE = 8            /* at least version and csum */
 };
 
 /**
@@ -935,7 +936,7 @@ int t3_load_fw(struct adapter *adapter,
 	const u32 *p = (const u32 *)fw_data;
 	int ret, addr, fw_sector = FW_FLASH_BOOT_ADDR >> 16;
 
-	if (size & 3)
+	if ((size & 3) || size < FW_MIN_SIZE)
 		return -EINVAL;
 	if (size > FW_VERS_ADDR + 8 - FW_FLASH_BOOT_ADDR)
 		return -EFBIG;
