From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 17/17] sfc: Store MAC address from NVRAM in
 net_device::perm_addr
Date: Thu, 02 Dec 2010 23:48:28 +0000
Message-ID: <1291333708.3259.40.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13163 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171Ab0LBXsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:48:31 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some reason we failed to make this change when perm_addr was
introduced.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    8 +++++---
 drivers/net/sfc/falcon.c     |    2 +-
 drivers/net/sfc/net_driver.h |    2 --
 drivers/net/sfc/siena.c      |    8 +-------
 4 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7e820d9..f3e4043 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -909,6 +909,7 @@ static void efx_mac_work(struct work_struct *data)
 
 static int efx_probe_port(struct efx_nic *efx)
 {
+	unsigned char *perm_addr;
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev, "create port\n");
@@ -922,11 +923,12 @@ static int efx_probe_port(struct efx_nic *efx)
 		return rc;
 
 	/* Sanity check MAC address */
-	if (is_valid_ether_addr(efx->mac_address)) {
-		memcpy(efx->net_dev->dev_addr, efx->mac_address, ETH_ALEN);
+	perm_addr = efx->net_dev->perm_addr;
+	if (is_valid_ether_addr(perm_addr)) {
+		memcpy(efx->net_dev->dev_addr, perm_addr, ETH_ALEN);
 	} else {
 		netif_err(efx, probe, efx->net_dev, "invalid MAC address %pM\n",
-			  efx->mac_address);
+			  perm_addr);
 		if (!allow_bad_hwaddr) {
 			rc = -EINVAL;
 			goto err;
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 07f684e..70e4f7d 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1297,7 +1297,7 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	}
 
 	/* Read the MAC addresses */
-	memcpy(efx->mac_address, nvconfig->mac_address[0], ETH_ALEN);
+	memcpy(efx->net_dev->perm_addr, nvconfig->mac_address[0], ETH_ALEN);
 
 	netif_dbg(efx, probe, efx->net_dev, "PHY is %d phy_id %d\n",
 		  efx->phy_type, efx->mdio.prtad);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 6dd5e6d..0d19fbf 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -678,7 +678,6 @@ struct efx_filter_state;
  * @stats_buffer: DMA buffer for statistics
  * @stats_lock: Statistics update lock. Serialises statistics fetches
  * @mac_op: MAC interface
- * @mac_address: Permanent MAC address
  * @phy_type: PHY type
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
@@ -762,7 +761,6 @@ struct efx_nic {
 	spinlock_t stats_lock;
 
 	struct efx_mac_operations *mac_op;
-	unsigned char mac_address[ETH_ALEN];
 
 	unsigned int phy_type;
 	struct efx_phy_operations *phy_op;
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index b315980..bf84561 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -194,13 +194,7 @@ static int siena_reset_hw(struct efx_nic *efx, enum reset_type method)
 
 static int siena_probe_nvconfig(struct efx_nic *efx)
 {
-	int rc;
-
-	rc = efx_mcdi_get_board_cfg(efx, efx->mac_address, NULL);
-	if (rc)
-		return rc;
-
-	return 0;
+	return efx_mcdi_get_board_cfg(efx, efx->net_dev->perm_addr, NULL);
 }
 
 static int siena_probe_nic(struct efx_nic *efx)
-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

