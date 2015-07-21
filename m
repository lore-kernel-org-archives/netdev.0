From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/9] sfc: cope with ENOSYS from efx_mcdi_get_workarounds()
Date: Tue, 21 Jul 2015 15:09:31 +0100
Message-ID: <55AE529B.3000900@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:47032 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbbGUONI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:13:08 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GET_WORKAROUNDS was only introduced in May 2014, not all firmware
 will have it.  So call sites need to handle ENOSYS.
In this case we're probing the bug26807 workaround, which is not
 implemented in any firmware that doesn't have GET_WORKAROUNDS.
 So interpret ENOSYS as 'false'.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 33 ++++++++++++++++++++-------------
 drivers/net/ethernet/sfc/mcdi.c |  6 +++++-
 2 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 1193017..4407117 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2277,20 +2277,27 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 
 	/* Successfully created event queue on channel 0 */
 	rc = efx_mcdi_get_workarounds(efx, &implemented, &enabled);
-	if (rc)
+	if (rc == -ENOSYS) {
+		/* GET_WORKAROUNDS was implemented before the bug26807
+		 * workaround, thus the latter must be unavailable in this fw
+		 */
+		nic_data->workaround_26807 = false;
+		rc = 0;
+	} else if (rc) {
 		goto fail;
-
-	nic_data->workaround_26807 =
-		!!(enabled & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807);
-
-	if (implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807 &&
-	    !nic_data->workaround_26807) {
-		rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG26807,
-					     true);
-		if (!rc)
-			nic_data->workaround_26807 = true;
-		else if (rc == -EPERM)
-			rc = 0;
+	} else {
+		nic_data->workaround_26807 =
+			!!(enabled & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807);
+
+		if (implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG26807 &&
+		    !nic_data->workaround_26807) {
+			rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG26807,
+						     true);
+			if (!rc)
+				nic_data->workaround_26807 = true;
+			else if (rc == -EPERM)
+				rc = 0;
+		}
 	}
 
 	if (!rc)
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 81640f8..58232e7 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1816,7 +1816,11 @@ int efx_mcdi_get_workarounds(struct efx_nic *efx, unsigned int *impl_out,
 	return 0;
 
 fail:
-	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
+	/* Older firmware lacks GET_WORKAROUNDS and this isn't especially
+	 * terrifying.  The call site will have to deal with it though.
+	 */
+	netif_printk(efx, hw, rc == -ENOSYS ? KERN_DEBUG : KERN_ERR,
+		     efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
