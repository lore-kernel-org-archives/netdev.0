From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/12] sfc: Workaround flush failures on Falcon B0
Date: Tue, 01 Jun 2010 22:17:51 +0100
Message-ID: <1275427071.2114.28.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50511 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541Ab0FAVRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:17:54 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Under certain conditions a PHY may backpressure Falcon B0
in such a way that flushes timeout. In normal circumstances
the phy poller would fix the PHY, and the flush could complete.

But efx_nic_flush_queues() is always called after efx_stop_all(),
so the poller has been stopped. Even if this weren't the case,
how long would we have to wait for the poller to fix this? And
several callers of efx_nic_flush_queues() are about to reset
the device anyway - so we don't need to do anything.

Work around this bug by scheduling a reset. Ensure that the
MAC is never rewired back into the datapath before the reset
runs (we already ignore all rx events anyway).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c         |   13 +++++++++++--
 drivers/net/sfc/falcon.c      |    8 +++++---
 drivers/net/sfc/nic.c         |    3 ---
 drivers/net/sfc/workarounds.h |    2 +-
 4 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 0319000..d1a1d32 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -27,6 +27,7 @@
 #include "nic.h"
 
 #include "mcdi.h"
+#include "workarounds.h"
 
 /**************************************************************************
  *
@@ -556,10 +557,18 @@ static void efx_fini_channels(struct efx_nic *efx)
 	BUG_ON(efx->port_enabled);
 
 	rc = efx_nic_flush_queues(efx);
-	if (rc)
+	if (rc && EFX_WORKAROUND_7803(efx)) {
+		/* Schedule a reset to recover from the flush failure. The
+		 * descriptor caches reference memory we're about to free,
+		 * but falcon_reconfigure_mac_wrapper() won't reconnect
+		 * the MACs because of the pending reset. */
+		EFX_ERR(efx, "Resetting to recover from flush failure\n");
+		efx_schedule_reset(efx, RESET_TYPE_ALL);
+	} else if (rc) {
 		EFX_ERR(efx, "failed to flush queues\n");
-	else
+	} else {
 		EFX_LOG(efx, "successfully flushed all queues\n");
+	}
 
 	efx_for_each_channel(channel, efx) {
 		EFX_LOG(channel->efx, "shut down chan %d\n", channel->channel);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 655b697..8558865 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -548,7 +548,9 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 {
 	struct efx_link_state *link_state = &efx->link_state;
 	efx_oword_t reg;
-	int link_speed;
+	int link_speed, isolate;
+
+	isolate = (efx->reset_pending != RESET_TYPE_NONE);
 
 	switch (link_state->speed) {
 	case 10000: link_speed = 3; break;
@@ -570,7 +572,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	 * discarded. */
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 		EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN,
-				    !link_state->up);
+				    !link_state->up || isolate);
 	}
 
 	efx_writeo(efx, &reg, FR_AB_MAC_CTRL);
@@ -584,7 +586,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, 1);
 	/* Unisolate the MAC -> RX */
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, !isolate);
 	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 }
 
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 5d3aaec..ec0bb80 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1219,9 +1219,6 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		rx_queue->flushed = FLUSH_DONE;
 	}
 
-	if (EFX_WORKAROUND_7803(efx))
-		return 0;
-
 	return -ETIMEDOUT;
 }
 
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 518f7fc..782e45a 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -54,7 +54,7 @@
 /* Increase filter depth to avoid RX_RESET */
 #define EFX_WORKAROUND_7244 EFX_WORKAROUND_FALCON_A
 /* Flushes may never complete */
-#define EFX_WORKAROUND_7803 EFX_WORKAROUND_FALCON_A
+#define EFX_WORKAROUND_7803 EFX_WORKAROUND_FALCON_AB
 /* Leak overlength packets rather than free */
 #define EFX_WORKAROUND_8071 EFX_WORKAROUND_FALCON_A
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

