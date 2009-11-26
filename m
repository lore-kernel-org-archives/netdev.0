From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/16] sfc: Move Falcon board/PHY/MAC monitoring code to
	falcon.c
Date: Thu, 26 Nov 2009 02:11:45 +0000
Message-ID: <1259201505.2806.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31312 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbZKZCLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:11:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c    |   11 +----------
 drivers/net/sfc/falcon.c |   15 +++++++++++++++
 drivers/net/sfc/falcon.h |    1 +
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 41ca5db..d17cea9 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1293,7 +1293,6 @@ static void efx_monitor(struct work_struct *data)
 {
 	struct efx_nic *efx = container_of(data, struct efx_nic,
 					   monitor_work.work);
-	int rc;
 
 	EFX_TRACE(efx, "hardware monitor executing on CPU %d\n",
 		  raw_smp_processor_id());
@@ -1305,15 +1304,7 @@ static void efx_monitor(struct work_struct *data)
 		goto out_requeue;
 	if (!efx->port_enabled)
 		goto out_unlock;
-	rc = falcon_board(efx)->type->monitor(efx);
-	if (rc) {
-		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
-			(rc == -ERANGE) ? "reported fault" : "failed");
-		efx->phy_mode |= PHY_MODE_LOW_POWER;
-		falcon_sim_phy_event(efx);
-	}
-	efx->phy_op->poll(efx);
-	efx->mac_op->poll(efx);
+	falcon_monitor(efx);
 
 out_unlock:
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 3ab2daf..c43c5e6 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2612,6 +2612,21 @@ fail5:
 	return rc;
 }
 
+void falcon_monitor(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = falcon_board(efx)->type->monitor(efx);
+	if (rc) {
+		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
+			(rc == -ERANGE) ? "reported fault" : "failed");
+		efx->phy_mode |= PHY_MODE_LOW_POWER;
+		falcon_sim_phy_event(efx);
+	}
+	efx->phy_op->poll(efx);
+	efx->mac_op->poll(efx);
+}
+
 /* Zeroes out the SRAM contents.  This routine must be called in
  * process context and is allowed to sleep.
  */
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 61fab0a..05e51c2 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -158,6 +158,7 @@ extern int falcon_probe_nic(struct efx_nic *efx);
 extern int falcon_init_nic(struct efx_nic *efx);
 extern int falcon_flush_queues(struct efx_nic *efx);
 extern int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
+extern void falcon_monitor(struct efx_nic *efx);
 extern void falcon_remove_nic(struct efx_nic *efx);
 extern void falcon_update_nic_stats(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

