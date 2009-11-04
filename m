From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 02/12] wimax/i2400m: SDIO: fix oops on reset when TXing on uninitialized data
Date: Wed,  4 Nov 2009 13:40:07 -0800
Message-ID: <a8ee303cae6fbdaa639afa50b9d03ce6f0c7d7da.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28863 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932788AbZKDVmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:18 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the SDIO part of the TX resources were initialized/released
with bus_dev_{start,stop}.

The generic code's TX subsystem is destroyed afterwards, so there is a
window from the bus-TX destruction to the generic-TX destruction where
the generic-TX code might call into bus-TX to do transactions.

The SDIO code cannot really cope with this (whereas in USB, how it is
laid out, it correctly ignores it). In any case, it made no sense for
the SDIO TX code to be in i2400m->bus_dev_start/stop(), so moved to
i2400m->bus_setup/release(), which also takes care of the oops.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |   43 ++++++++------------------------------
 1 files changed, 9 insertions(+), 34 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 14e66f0..ec17892 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -46,15 +46,6 @@
  * i2400ms_bus_reset()            Called by i2400m->bus_reset
  *   __i2400ms_reset()
  *     __i2400ms_send_barker()
- *
- * i2400ms_bus_dev_start()        Called by i2400m_dev_start() [who is
- *   i2400ms_tx_setup()           called by i2400m_setup()]
- *   i2400ms_rx_setup()
- *
- * i2400ms_bus_dev_stop()         Called by i2400m_dev_stop() [who is
- *   i2400ms_rx_release()         is called by i2400m_release()]
- *   i2400ms_tx_release()
- *
  */
 
 #include <linux/debugfs.h>
@@ -191,12 +182,17 @@ int i2400ms_bus_setup(struct i2400m *i2400m)
 		goto error_func_enable;
 	}
 
+	result = i2400ms_tx_setup(i2400ms);
+	if (result < 0)
+		goto error_tx_setup;
 	result = i2400ms_rx_setup(i2400ms);
 	if (result < 0)
 		goto error_rx_setup;
 	return 0;
 
 error_rx_setup:
+	i2400ms_tx_release(i2400ms);
+error_tx_setup:
 	sdio_claim_host(func);
 	sdio_disable_func(func);
 	sdio_release_host(func);
@@ -218,6 +214,7 @@ void i2400ms_bus_release(struct i2400m *i2400m)
 	struct sdio_func *func = i2400ms->func;
 
 	i2400ms_rx_release(i2400ms);
+	i2400ms_tx_release(i2400ms);
 	sdio_claim_host(func);
 	sdio_disable_func(func);
 	sdio_release_host(func);
@@ -235,36 +232,14 @@ void i2400ms_bus_release(struct i2400m *i2400m)
 static
 int i2400ms_bus_dev_start(struct i2400m *i2400m)
 {
-	int result;
 	struct i2400ms *i2400ms = container_of(i2400m, struct i2400ms, i2400m);
 	struct sdio_func *func = i2400ms->func;
 	struct device *dev = &func->dev;
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	msleep(200);
-	result = i2400ms_tx_setup(i2400ms);
-	if (result < 0)
-		goto error_tx_setup;
-	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
-	return result;
-
-error_tx_setup:
-	i2400ms_tx_release(i2400ms);
-	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
-	return result;
-}
-
-
-static
-void i2400ms_bus_dev_stop(struct i2400m *i2400m)
-{
-	struct i2400ms *i2400ms = container_of(i2400m, struct i2400ms, i2400m);
-	struct sdio_func *func = i2400ms->func;
-	struct device *dev = &func->dev;
-
-	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
-	i2400ms_tx_release(i2400ms);
-	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
+	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, 0);
+	return 0;
 }
 
 
@@ -506,7 +481,7 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_pl_size_max = I2400MS_PL_SIZE_MAX;
 	i2400m->bus_setup = i2400ms_bus_setup;
 	i2400m->bus_dev_start = i2400ms_bus_dev_start;
-	i2400m->bus_dev_stop = i2400ms_bus_dev_stop;
+	i2400m->bus_dev_stop = NULL;
 	i2400m->bus_release = i2400ms_bus_release;
 	i2400m->bus_tx_kick = i2400ms_bus_tx_kick;
 	i2400m->bus_reset = i2400ms_bus_reset;
-- 
1.6.2.5

