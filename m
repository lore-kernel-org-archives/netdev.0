From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/32] sfc: Move efx_mcdi_mac_reconfigure() to
 siena.c and rename
Date: Thu, 22 Aug 2013 13:50:50 +0100
Message-ID: <1377175850.1703.19.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13901 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab3HVMuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:50:54 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EF10 does not include a multicast hash filter, so this function is
specific to Siena.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h     |  1 -
 drivers/net/ethernet/sfc/mcdi_mac.c | 21 ---------------------
 drivers/net/ethernet/sfc/siena.c    | 23 ++++++++++++++++++++++-
 3 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index e62dc04..73bc76e 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -199,7 +199,6 @@ extern int efx_mcdi_flush_rxqs(struct efx_nic *efx);
 extern int efx_mcdi_set_mac(struct efx_nic *efx);
 extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 			      u32 dma_len, int enable, int clear);
-extern int efx_mcdi_mac_reconfigure(struct efx_nic *efx);
 extern bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
 extern enum reset_type efx_mcdi_map_reset_reason(enum reset_type reason);
 extern int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method);
diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
index cf16bf1..1b84b90 100644
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ b/drivers/net/ethernet/sfc/mcdi_mac.c
@@ -112,24 +112,3 @@ fail:
 		  __func__, enable ? "enable" : "disable", rc);
 	return rc;
 }
-
-int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
-{
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_MCAST_HASH_IN_LEN);
-	int rc;
-
-	BUILD_BUG_ON(MC_CMD_SET_MCAST_HASH_IN_LEN !=
-		     MC_CMD_SET_MCAST_HASH_IN_HASH0_OFST +
-		     sizeof(efx->multicast_hash));
-
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
-
-	rc = efx_mcdi_set_mac(efx);
-	if (rc != 0)
-		return rc;
-
-	memcpy(MCDI_PTR(inbuf, SET_MCAST_HASH_IN_HASH0),
-	       efx->multicast_hash.byte, sizeof(efx->multicast_hash));
-	return efx_mcdi_rpc(efx, MC_CMD_SET_MCAST_HASH,
-			    inbuf, sizeof(inbuf), NULL, 0, NULL);
-}
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 6babc8e..1febedb 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -577,6 +577,27 @@ static void siena_stop_nic_stats(struct efx_nic *efx)
 	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 0);
 }
 
+static int siena_mac_reconfigure(struct efx_nic *efx)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_MCAST_HASH_IN_LEN);
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_SET_MCAST_HASH_IN_LEN !=
+		     MC_CMD_SET_MCAST_HASH_IN_HASH0_OFST +
+		     sizeof(efx->multicast_hash));
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
+	rc = efx_mcdi_set_mac(efx);
+	if (rc != 0)
+		return rc;
+
+	memcpy(MCDI_PTR(inbuf, SET_MCAST_HASH_IN_HASH0),
+	       efx->multicast_hash.byte, sizeof(efx->multicast_hash));
+	return efx_mcdi_rpc(efx, MC_CMD_SET_MCAST_HASH,
+			    inbuf, sizeof(inbuf), NULL, 0, NULL);
+}
+
 /**************************************************************************
  *
  * Wake on LAN
@@ -679,7 +700,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.stop_stats = siena_stop_nic_stats,
 	.set_id_led = efx_mcdi_set_id_led,
 	.push_irq_moderation = siena_push_irq_moderation,
-	.reconfigure_mac = efx_mcdi_mac_reconfigure,
+	.reconfigure_mac = siena_mac_reconfigure,
 	.check_mac_fault = efx_mcdi_mac_check_fault,
 	.reconfigure_port = efx_mcdi_phy_reconfigure,
 	.get_wol = siena_get_wol,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
