From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 05/15] wimax/i2400m: during probe, call sdio_disable at most once
Date: Wed,  4 Nov 2009 13:39:46 -0800
Message-ID: <c77ca950abb587bcebad6dcd0b0b41d7c0255ce9.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20710 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932708AbZKDVl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:59 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the Intel Wireless Multicomm 3200, the initialization is
orchestrated by a component called Top. This component also monitors
how many times a function is reset (via sdio_disable) to detect
possible issues and will reset the whole multifunction device if any
function triggers a maximum reset level.

During WiMAX's probe, the driver needs to wait for Top to come up
before it can enable the WiMAX function. If it cannot, it will return
-ENODEV and the Top driver will rescan the SDIO bus once done
loading.

Currently, the WiMAX SDIO probe routine was trying a few times before
returning -ENODEV, and this was triggering Top's too-many-resets
detector. This is, in any case, unnecessary because the Top driver will
force the bus rescan when the functions can be probed successfully.

Added then a maxtries argument to i2400ms_enable_func() and set it to
1 when calling from probe. We want to reuse this function instead of
flat calling out sdio_enable_func() to take advantage of hardware
quirk workarounds.

Reported-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 9d6046f..7c1b843 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -95,17 +95,23 @@ static const struct i2400m_poke_table i2400ms_pokes[] = {
  * when we ask it to explicitly doing). Tries until a timeout is
  * reached.
  *
+ * The @maxtries argument indicates how many times (at most) it should
+ * be tried to enable the function. 0 means forever. This acts along
+ * with the timeout (ie: it'll stop trying as soon as the maximum
+ * number of tries is reached _or_ as soon as the timeout is reached).
+ *
  * The reverse of this is...sdio_disable_function()
  *
  * Returns: 0 if the SDIO function was enabled, < 0 errno code on
  *     error (-ENODEV when it was unable to enable the function).
  */
 static
-int i2400ms_enable_function(struct sdio_func *func)
+int i2400ms_enable_function(struct sdio_func *func, unsigned maxtries)
 {
 	u64 timeout;
 	int err;
 	struct device *dev = &func->dev;
+	unsigned tries = 0;
 
 	d_fnstart(3, dev, "(func %p)\n", func);
 	/* Setup timeout (FIXME: This needs to read the CIS table to
@@ -131,6 +137,10 @@ int i2400ms_enable_function(struct sdio_func *func)
 		}
 		d_printf(2, dev, "SDIO function failed to enable: %d\n", err);
 		sdio_release_host(func);
+		if (maxtries > 0 && ++tries >= maxtries) {
+			err = -ETIME;
+			break;
+		}
 		msleep(I2400MS_INIT_SLEEP_INTERVAL);
 	}
 	/* If timed out, device is not there yet -- get -ENODEV so
@@ -305,7 +315,7 @@ do_bus_reset:
 		/* Wait for the device to settle */
 		msleep(40);
 
-		result = i2400ms_enable_function(i2400ms->func);
+		result = i2400ms_enable_function(i2400ms->func, 0);
 		if (result >= 0)
 			i2400ms_rx_setup(i2400ms);
 	} else
@@ -452,7 +462,7 @@ int i2400ms_probe(struct sdio_func *func,
 		goto error_set_blk_size;
 	}
 
-	result = i2400ms_enable_function(i2400ms->func);
+	result = i2400ms_enable_function(i2400ms->func, 1);
 	if (result < 0) {
 		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
 		goto error_func_enable;
-- 
1.6.2.5

