From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/32] sfc: Merge efx_mcdi_mac_check_fault() and
 efx_mcdi_get_mac_faults()
Date: Fri, 27 Jan 2012 20:46:10 +0000
Message-ID: <1327697170.2503.21.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63633 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753281Ab2A0UqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:46:13 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The latter is only called by the former, which is a very short
wrapper.  Further, gcc 4.5 may currently wrongly warn that the
'faults' variable may be used uninitialised.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_mac.c |   25 +++++++------------------
 1 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
index 4907062..559d798 100644
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ b/drivers/net/ethernet/sfc/mcdi_mac.c
@@ -51,7 +51,7 @@ static int efx_mcdi_set_mac(struct efx_nic *efx)
 			    NULL, 0, NULL);
 }
 
-static int efx_mcdi_get_mac_faults(struct efx_nic *efx, u32 *faults)
+bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
 {
 	u8 outbuf[MC_CMD_GET_LINK_OUT_LEN];
 	size_t outlength;
@@ -61,16 +61,13 @@ static int efx_mcdi_get_mac_faults(struct efx_nic *efx, u32 *faults)
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
 			  outbuf, sizeof(outbuf), &outlength);
-	if (rc)
-		goto fail;
-
-	*faults = MCDI_DWORD(outbuf, GET_LINK_OUT_MAC_FAULT);
-	return 0;
+	if (rc) {
+		netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+			  __func__, rc);
+		return true;
+	}
 
-fail:
-	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
-		  __func__, rc);
-	return rc;
+	return MCDI_DWORD(outbuf, GET_LINK_OUT_MAC_FAULT) != 0;
 }
 
 int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
@@ -127,11 +124,3 @@ int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
 
 	return 0;
 }
-
-
-bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
-{
-	u32 faults;
-	int rc = efx_mcdi_get_mac_faults(efx, &faults);
-	return (rc != 0) || (faults != 0);
-}
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
