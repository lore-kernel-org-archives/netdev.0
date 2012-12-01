From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/13] sfc: lock TX queues when calling
 netif_device_detach()
Date: Sat, 1 Dec 2012 04:44:06 +0000
Message-ID: <1354337046.2640.50.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26193 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab2LAEoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:44:10 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 	Daniel Pieczko <dpieczko@solarflare.com>

The assertion of netif_device_present() at the top of
efx_hard_start_xmit() may fail if we don't do this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c      |    4 ++--
 drivers/net/ethernet/sfc/efx.h      |   13 +++++++++++++
 drivers/net/ethernet/sfc/selftest.c |    2 +-
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 4f86d0c..6f073d0 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2279,7 +2279,7 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 	netif_info(efx, drv, efx->net_dev, "resetting (%s)\n",
 		   RESET_TYPE(method));
 
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 	efx_reset_down(efx, method);
 
 	rc = efx->type->reset(efx, method);
@@ -2758,7 +2758,7 @@ static int efx_pm_freeze(struct device *dev)
 	if (efx->state != STATE_DISABLED) {
 		efx->state = STATE_UNINIT;
 
-		netif_device_detach(efx->net_dev);
+		efx_device_detach_sync(efx);
 
 		efx_stop_all(efx);
 		efx_stop_interrupts(efx, false);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index f11170b..50247df 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -163,4 +163,17 @@ extern void efx_link_status_changed(struct efx_nic *efx);
 extern void efx_link_set_advertising(struct efx_nic *efx, u32);
 extern void efx_link_set_wanted_fc(struct efx_nic *efx, u8);
 
+static inline void efx_device_detach_sync(struct efx_nic *efx)
+{
+	struct net_device *dev = efx->net_dev;
+
+	/* Lock/freeze all TX queues so that we can be sure the
+	 * TX scheduler is stopped when we're done and before
+	 * netif_device_present() becomes false.
+	 */
+	netif_tx_lock(dev);
+	netif_device_detach(dev);
+	netif_tx_unlock(dev);
+}
+
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index f6651d3..2069f51 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -722,7 +722,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* Detach the device so the kernel doesn't transmit during the
 	 * loopback test and the watchdog timeout doesn't fire.
 	 */
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 
 	if (efx->type->test_chip) {
 		rc_reset = efx->type->test_chip(efx, tests);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
