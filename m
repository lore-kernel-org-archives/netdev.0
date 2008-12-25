From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 7/8] sfc: When disabling the NIC, close the device rather
	than unregistering it
Date: Thu, 25 Dec 2008 03:42:21 +0000
Message-ID: <1230176541.3401.51.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:4337 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751663AbYLYDmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:42:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should reduce user confusion and may also aid recovery (ioctls
will still be available).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   47 +++++++++++++++++++++++------------------------
 1 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 46c2a8b..5cc59e6 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1332,6 +1332,8 @@ static int efx_net_open(struct net_device *net_dev)
 	EFX_LOG(efx, "opening device %s on CPU %d\n", net_dev->name,
 		raw_smp_processor_id());
 
+	if (efx->state == STATE_DISABLED)
+		return -EIO;
 	if (efx->phy_mode & PHY_MODE_SPECIAL)
 		return -EBUSY;
 
@@ -1350,10 +1352,12 @@ static int efx_net_stop(struct net_device *net_dev)
 	EFX_LOG(efx, "closing %s on CPU %d\n", net_dev->name,
 		raw_smp_processor_id());
 
-	/* Stop the device and flush all the channels */
-	efx_stop_all(efx);
-	efx_fini_channels(efx);
-	efx_init_channels(efx);
+	if (efx->state != STATE_DISABLED) {
+		/* Stop the device and flush all the channels */
+		efx_stop_all(efx);
+		efx_fini_channels(efx);
+		efx_init_channels(efx);
+	}
 
 	return 0;
 }
@@ -1685,7 +1689,7 @@ static int efx_reset(struct efx_nic *efx)
 {
 	struct ethtool_cmd ecmd;
 	enum reset_type method = efx->reset_pending;
-	int rc;
+	int rc = 0;
 
 	/* Serialise with kernel interfaces */
 	rtnl_lock();
@@ -1694,7 +1698,7 @@ static int efx_reset(struct efx_nic *efx)
 	 * flag set so that efx_pci_probe_main will be retried */
 	if (efx->state != STATE_RUNNING) {
 		EFX_INFO(efx, "scheduled reset quenched. NIC not RUNNING\n");
-		goto unlock_rtnl;
+		goto out_unlock;
 	}
 
 	EFX_INFO(efx, "resetting (%d)\n", method);
@@ -1704,7 +1708,7 @@ static int efx_reset(struct efx_nic *efx)
 	rc = falcon_reset_hw(efx, method);
 	if (rc) {
 		EFX_ERR(efx, "failed to reset hardware\n");
-		goto fail;
+		goto out_disable;
 	}
 
 	/* Allow resets to be rescheduled. */
@@ -1718,28 +1722,23 @@ static int efx_reset(struct efx_nic *efx)
 
 	/* Leave device stopped if necessary */
 	if (method == RESET_TYPE_DISABLE) {
+		efx_reset_up(efx, &ecmd, false);
 		rc = -EIO;
-		goto fail;
+	} else {
+		rc = efx_reset_up(efx, &ecmd, true);
 	}
 
-	rc = efx_reset_up(efx, &ecmd, true);
-	if (rc)
-		goto disable;
-
-	EFX_LOG(efx, "reset complete\n");
- unlock_rtnl:
-	rtnl_unlock();
-	return 0;
-
- fail:
-	efx_reset_up(efx, &ecmd, false);
- disable:
-	EFX_ERR(efx, "has been disabled\n");
-	efx->state = STATE_DISABLED;
+out_disable:
+	if (rc) {
+		EFX_ERR(efx, "has been disabled\n");
+		efx->state = STATE_DISABLED;
+		dev_close(efx->net_dev);
+	} else {
+		EFX_LOG(efx, "reset complete\n");
+	}
 
+out_unlock:
 	rtnl_unlock();
-	efx_unregister_netdev(efx);
-	efx_fini_port(efx);
 	return rc;
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
