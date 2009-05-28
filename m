From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 07/10] wimax/i2400m: sdio: set the block size before enabling the function
Date: Wed, 27 May 2009 18:05:12 -0700
Message-ID: <d791bac79c5e9840a3e5317a4bb79acafde911f9.1243472510.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
 <e9de4b9426eeeddf56110425cfd88e43828e7146.1243472510.git.inaky@linux.intel.com>
 <22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
 <05962df1398ad316feb1e20160b7502731bebc97.1243472510.git.inaky@linux.intel.com>
 <ba98dde3cde9f5910789b32852c692fc8cd0a4aa.1243472510.git.inaky@linux.intel.com>
 <74bd64a25b220d21e50c7c9a85f26ff6617b3728.1243472510.git.inaky@linux.intel.com>
 <f3aea79091a4fc501235f2e743cc073ebd962934.1243472510.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:11221 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756792AbZE1BFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 21:05:49 -0400
In-Reply-To: <f3aea79091a4fc501235f2e743cc073ebd962934.1243472510.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243472509.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
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

