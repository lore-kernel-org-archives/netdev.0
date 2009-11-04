From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 10/12] wimax/iwmc3200: overwrite SDIO IOR timeout value to avoid platform hang
Date: Wed,  4 Nov 2009 13:39:46 -0800
Message-ID: <f2696fbdb623993a9b4c05455df7ae3158a01111.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:16607 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758260AbZKDVlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:51 -0500
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

The default SDIO IOE wait timeout returned from iwmc3200-wimax's CCCR
is not efficient. This inefficiency will actually cause problems on
Moorestown platforms (system hang).

This is a sillicon bug that requires a software patch to by
overwritting func->enable_timeout. The new value I2400MS_IOR_TIMEOUT
is recommended and verified from the system integration results.

Future sillicon releases will have this default value corrected in the
future.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m-sdio.h |    2 ++
 drivers/net/wimax/i2400m/sdio.c        |    8 ++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index 66884eb..cfaedfa 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -81,6 +81,8 @@ enum {
 	I2400MS_INIT_SLEEP_INTERVAL = 10,
 	/* How long to wait for the device to settle after reset */
 	I2400MS_SETTLE_TIME = 40,
+	/* The number of msec to wait for IOR after sending IOE */
+	IWMC3200_IOR_TIMEOUT = 10,
 };
 
 
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 1429608..0d64d16 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -115,6 +115,14 @@ int i2400ms_enable_function(struct sdio_func *func)
 	err = -ENODEV;
 	while (err != 0 && time_before64(get_jiffies_64(), timeout)) {
 		sdio_claim_host(func);
+		/*
+		 * There is a sillicon bug on the IWMC3200, where the
+		 * IOE timeout will cause problems on Moorestown
+		 * platforms (system hang). We explicitly overwrite
+		 * func->enable_timeout here to work around the issue.
+		 */
+		if (func->device == SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX)
+			func->enable_timeout = IWMC3200_IOR_TIMEOUT;
 		err = sdio_enable_func(func);
 		if (0 == err) {
 			sdio_release_host(func);
-- 
1.6.2.5

