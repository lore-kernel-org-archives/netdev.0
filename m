From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 07/10] wimax/i2400m: sdio: set the block size before enabling the function
Date: Thu, 28 May 2009 18:12:11 -0700
Message-ID: <a0a4c4c9e54ee4255f46eedb572ad69ee34c77b6.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:45064 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753495AbZE2ELr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 00:11:47 -0400
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From a fix by Cindy H Kao:

  Block size has to be set before sending IOE enable because the
  firmware reads the block size register before it reads IOE register.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 5ac5e76..777c981 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -409,19 +409,19 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_fw_names = i2400ms_bus_fw_names;
 	i2400m->bus_bm_mac_addr_impaired = 1;
 
-	result = i2400ms_enable_function(i2400ms->func);
-	if (result < 0) {
-		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
-		goto error_func_enable;
-	}
-
 	sdio_claim_host(func);
 	result = sdio_set_block_size(func, I2400MS_BLK_SIZE);
+	sdio_release_host(func);
 	if (result < 0) {
 		dev_err(dev, "Failed to set block size: %d\n", result);
 		goto error_set_blk_size;
 	}
-	sdio_release_host(func);
+
+	result = i2400ms_enable_function(i2400ms->func);
+	if (result < 0) {
+		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
+		goto error_func_enable;
+	}
 
 	result = i2400m_setup(i2400m, I2400M_BRI_NO_REBOOT);
 	if (result < 0) {
@@ -440,12 +440,12 @@ int i2400ms_probe(struct sdio_func *func,
 error_debugfs_add:
 	i2400m_release(i2400m);
 error_setup:
-	sdio_set_drvdata(func, NULL);
 	sdio_claim_host(func);
-error_set_blk_size:
 	sdio_disable_func(func);
 	sdio_release_host(func);
 error_func_enable:
+error_set_blk_size:
+	sdio_set_drvdata(func, NULL);
 	free_netdev(net_dev);
 error_alloc_netdev:
 	return result;
-- 
1.6.2.3

