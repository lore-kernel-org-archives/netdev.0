From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 06/21] wimax/i2400m/sdio: Implement I2400M_RT_BUS reset type
Date: Thu, 11 Jun 2009 14:35:43 -0700
Message-ID: <10b1de6b774a531c9054ee01e734a85ffbab179e.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365AbZFKVgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:45 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

This reset type causes the WiMAX function to be disabled and
re-enabled, which will force the WiMAX device to reset and enter boot
mode.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
---
 drivers/net/wimax/i2400m/i2400m-sdio.h |    2 ++
 drivers/net/wimax/i2400m/sdio.c        |   20 +++++++++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index 08c2fb7..2071721 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -78,6 +78,8 @@ enum {
 	/* The number of ticks to wait for the device to signal that
 	 * it is ready */
 	I2400MS_INIT_SLEEP_INTERVAL = 10,
+	/* How long to wait for the device to settle after reset */
+	I2400MS_SETTLE_TIME = 40,
 };
 
 
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 777c981..d6fac5c 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -255,7 +255,7 @@ error_kzalloc:
 static
 int i2400ms_bus_reset(struct i2400m *i2400m, enum i2400m_reset_type rt)
 {
-	int result;
+	int result = 0;
 	struct i2400ms *i2400ms =
 		container_of(i2400m, struct i2400ms, i2400m);
 	struct device *dev = i2400m_dev(i2400m);
@@ -280,8 +280,22 @@ int i2400ms_bus_reset(struct i2400m *i2400m, enum i2400m_reset_type rt)
 					       sizeof(i2400m_COLD_BOOT_BARKER));
 	else if (rt == I2400M_RT_BUS) {
 do_bus_reset:
-		dev_err(dev, "FIXME: SDIO bus reset not implemented\n");
-		result = rt == I2400M_RT_WARM ? -ENODEV : -ENOSYS;
+		/* call netif_tx_disable() before sending IOE disable,
+		 * so that all the tx from network layer are stopped
+		 * while IOE is being reset. Make sure it is called
+		 * only after register_netdev() was issued.
+		 */
+		if (i2400m->wimax_dev.net_dev->reg_state == NETREG_REGISTERED)
+			netif_tx_disable(i2400m->wimax_dev.net_dev);
+
+		sdio_claim_host(i2400ms->func);
+		sdio_disable_func(i2400ms->func);
+		sdio_release_host(i2400ms->func);
+
+		/* Wait for the device to settle */
+		msleep(40);
+
+		result = i2400ms_enable_function(i2400ms->func);
 	} else
 		BUG();
 	if (result < 0 && rt != I2400M_RT_BUS) {
-- 
1.6.2.3

