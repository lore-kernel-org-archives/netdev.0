From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/16] sfc: Allow efx_nic_type::dimension_resources
 to fail
Date: Fri, 30 Aug 2013 04:40:25 +0100
Message-ID: <1377834025.2552.33.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34996 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab3H3Dka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:40:30 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   10 +++++++---
 drivers/net/ethernet/sfc/falcon.c     |    3 ++-
 drivers/net/ethernet/sfc/net_driver.h |    2 +-
 drivers/net/ethernet/sfc/siena.c      |    3 ++-
 4 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 84c47d3..59aa73c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1513,9 +1513,11 @@ static int efx_probe_nic(struct efx_nic *efx)
 	 * in MSI-X interrupts. */
 	rc = efx_probe_interrupts(efx);
 	if (rc)
-		goto fail;
+		goto fail1;
 
-	efx->type->dimension_resources(efx);
+	rc = efx->type->dimension_resources(efx);
+	if (rc)
+		goto fail2;
 
 	if (efx->n_channels > 1)
 		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
@@ -1533,7 +1535,9 @@ static int efx_probe_nic(struct efx_nic *efx)
 
 	return 0;
 
-fail:
+fail2:
+	efx_remove_interrupts(efx);
+fail1:
 	efx->type->remove(efx);
 	return rc;
 }
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index ec77611..a7b30ddb 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2174,10 +2174,11 @@ out:
 	return rc;
 }
 
-static void falcon_dimension_resources(struct efx_nic *efx)
+static int falcon_dimension_resources(struct efx_nic *efx)
 {
 	efx->rx_dc_base = 0x20000;
 	efx->tx_dc_base = 0x26000;
+	return 0;
 }
 
 /* Probe all SPI devices on the NIC */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 54900f3..89974f7 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1036,7 +1036,7 @@ struct efx_nic_type {
 	int (*probe)(struct efx_nic *efx);
 	void (*remove)(struct efx_nic *efx);
 	int (*init)(struct efx_nic *efx);
-	void (*dimension_resources)(struct efx_nic *efx);
+	int (*dimension_resources)(struct efx_nic *efx);
 	void (*fini)(struct efx_nic *efx);
 	void (*monitor)(struct efx_nic *efx);
 	enum reset_type (*map_reset_reason)(enum reset_type reason);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 89180d4..1500405 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -177,13 +177,14 @@ static int siena_probe_nvconfig(struct efx_nic *efx)
 	return rc;
 }
 
-static void siena_dimension_resources(struct efx_nic *efx)
+static int siena_dimension_resources(struct efx_nic *efx)
 {
 	/* Each port has a small block of internal SRAM dedicated to
 	 * the buffer table and descriptor caches.  In theory we can
 	 * map both blocks to one port, but we don't.
 	 */
 	efx_farch_dimension_resources(efx, FR_CZ_BUF_FULL_TBL_ROWS / 2);
+	return 0;
 }
 
 static unsigned int siena_mem_map_size(struct efx_nic *efx)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
