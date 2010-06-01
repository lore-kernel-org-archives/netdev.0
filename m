From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/12] sfc: Reschedule any resets scheduled inside
 efx_pm_freeze()
Date: Tue, 01 Jun 2010 22:17:24 +0100
Message-ID: <1275427044.2114.27.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50478 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756682Ab0FAVR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:17:27 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

efx_pm_freeze() sets efx->state = STATE_FINI, which means
efx_reset_work() will abort any scheduled resets.

efx_pm_thaw() should reschedule efx_reset_work() again,
since a freeze/thaw will not have reset the hardware.

This bug was spotted by inspection - there is no real world example of
this happening.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 1564605..0319000 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1886,6 +1886,9 @@ static void efx_reset_work(struct work_struct *data)
 {
 	struct efx_nic *efx = container_of(data, struct efx_nic, reset_work);
 
+	if (efx->reset_pending == RESET_TYPE_NONE)
+		return;
+
 	/* If we're not RUNNING then don't reset. Leave the reset_pending
 	 * flag set so that efx_pci_probe_main will be retried */
 	if (efx->state != STATE_RUNNING) {
@@ -2332,6 +2335,9 @@ static int efx_pm_thaw(struct device *dev)
 
 	efx->type->resume_wol(efx);
 
+	/* Reschedule any quenched resets scheduled during efx_pm_freeze() */
+	queue_work(reset_workqueue, &efx->reset_work);
+
 	return 0;
 }
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

