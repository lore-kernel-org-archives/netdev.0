From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 07/12] wimax/i2400m: correctly identify all iwmc3200-based SKUs
Date: Wed,  4 Nov 2009 13:40:12 -0800
Message-ID: <02eb41ef2a8631022fd90e096c57562dec9e7a9a.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28864 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932789AbZKDVmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:20 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different paths of the i2400m SDIO driver need to take care of a few
SKU-specific quirks. For the ones that are common to to all the
iwmc3200 based devices, introduce i2400ms->iwmc3200 [set in
i2400ms_probe()], so it doesn't have to check against the list of
iwmc3200 SKU IDs on each quirk site.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m-sdio.h |    3 +++
 drivers/net/wimax/i2400m/sdio.c        |   16 +++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index 18218a2..fba482c 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -114,6 +114,9 @@ struct i2400ms {
 	wait_queue_head_t bm_wfa_wq;
 	int bm_wait_result;
 	size_t bm_ack_size;
+
+	/* Device is any of the iwmc3200 SKUs */
+	unsigned iwmc3200:1;
 };
 
 
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 20ab22e..079f900 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -105,8 +105,9 @@ static const struct i2400m_poke_table i2400ms_pokes[] = {
  *     error (-ENODEV when it was unable to enable the function).
  */
 static
-int i2400ms_enable_function(struct sdio_func *func, unsigned maxtries)
+int i2400ms_enable_function(struct i2400ms *i2400ms, unsigned maxtries)
 {
+	struct sdio_func *func = i2400ms->func;
 	u64 timeout;
 	int err;
 	struct device *dev = &func->dev;
@@ -126,7 +127,7 @@ int i2400ms_enable_function(struct sdio_func *func, unsigned maxtries)
 		 * platforms (system hang). We explicitly overwrite
 		 * func->enable_timeout here to work around the issue.
 		 */
-		if (func->device == SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX)
+		if (i2400ms->iwmc3200)
 			func->enable_timeout = IWMC3200_IOR_TIMEOUT;
 		err = sdio_enable_func(func);
 		if (0 == err) {
@@ -176,7 +177,7 @@ int i2400ms_bus_setup(struct i2400m *i2400m)
 		goto error_set_blk_size;
 	}
 
-	result = i2400ms_enable_function(func, 1);
+	result = i2400ms_enable_function(i2400ms, 1);
 	if (result < 0) {
 		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
 		goto error_func_enable;
@@ -487,6 +488,15 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_bm_mac_addr_impaired = 1;
 	i2400m->bus_bm_pokes_table = &i2400ms_pokes[0];
 
+	switch (func->device) {
+	case SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX:
+	case SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX_2G5:
+		i2400ms->iwmc3200 = 1;
+		break;
+	default:
+		i2400ms->iwmc3200 = 0;
+	}
+
 	result = i2400m_setup(i2400m, I2400M_BRI_NO_REBOOT);
 	if (result < 0) {
 		dev_err(dev, "cannot setup device: %d\n", result);
-- 
1.6.2.5

