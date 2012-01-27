From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/32] sfc: Remove fallback for invalid permanent
 MAC address
Date: Fri, 27 Jan 2012 20:44:50 +0000
Message-ID: <1327697090.2503.16.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63545 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753631Ab2A0Uox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:44:53 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By the time we look at the MAC address in efx_probe_port(), either the
driver or the firmware has already validated the board configuration.
The possibility of having an invalid MAC address just isn't worth
considering.  It certainly isn't worth having a compile-time option
for this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   32 ++------------------------------
 1 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index d7301d2..eff5d30 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -122,15 +122,6 @@ static int napi_weight = 64;
  */
 static unsigned int efx_monitor_interval = 1 * HZ;
 
-/* This controls whether or not the driver will initialise devices
- * with invalid MAC addresses stored in the EEPROM or flash.  If true,
- * such devices will be initialised with a random locally-generated
- * MAC address.  This allows for loading the sfc_mtd driver to
- * reprogram the flash, even if the flash contents (including the MAC
- * address) have previously been erased.
- */
-static unsigned int allow_bad_hwaddr;
-
 /* Initial interrupt moderation settings.  They can be modified after
  * module load with ethtool.
  *
@@ -916,7 +907,6 @@ static void efx_mac_work(struct work_struct *data)
 
 static int efx_probe_port(struct efx_nic *efx)
 {
-	unsigned char *perm_addr;
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev, "create port\n");
@@ -929,28 +919,10 @@ static int efx_probe_port(struct efx_nic *efx)
 	if (rc)
 		return rc;
 
-	/* Sanity check MAC address */
-	perm_addr = efx->net_dev->perm_addr;
-	if (is_valid_ether_addr(perm_addr)) {
-		memcpy(efx->net_dev->dev_addr, perm_addr, ETH_ALEN);
-	} else {
-		netif_err(efx, probe, efx->net_dev, "invalid MAC address %pM\n",
-			  perm_addr);
-		if (!allow_bad_hwaddr) {
-			rc = -EINVAL;
-			goto err;
-		}
-		random_ether_addr(efx->net_dev->dev_addr);
-		netif_info(efx, probe, efx->net_dev,
-			   "using locally-generated MAC %pM\n",
-			   efx->net_dev->dev_addr);
-	}
+	/* Initialise MAC address to permanent address */
+	memcpy(efx->net_dev->dev_addr, efx->net_dev->perm_addr, ETH_ALEN);
 
 	return 0;
-
- err:
-	efx->type->remove_port(efx);
-	return rc;
 }
 
 static int efx_init_port(struct efx_nic *efx)
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
