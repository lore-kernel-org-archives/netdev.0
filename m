From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 10/15] sfc: suppress ENOENT error messages from
 MC_CMD_MAC_STATS
Date: Tue, 2 Jun 2015 11:39:49 +0100
Message-ID: <556D87F5.3010406@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:47527 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755651AbbFBKkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:40:03 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

MC_CMD_MAC_STATS can be called on a function before a
vadaptor has been created, as the kernel can call into this
through ndo_get_stats/ndo_get_stats64.

If MC_CMD_MAC_STATS is called before the DMA queues have been
setup, so that a vadaptor has not been created yet, firmware
will return ENOENT. This is expected, so suppress the MCDI
error message in this case.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c      | 11 ++++++++---
 drivers/net/ethernet/sfc/mcdi_port.c |  8 ++++++--
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index b880d98..a79a24f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1316,11 +1316,16 @@ static int efx_ef10_try_update_nic_stats_vf(struct efx_nic *efx)
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, EVB_PORT_ID_ASSIGNED);
 
 	spin_unlock_bh(&efx->stats_lock);
-	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf), NULL,
-			  0, NULL);
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
+				NULL, 0, NULL);
 	spin_lock_bh(&efx->stats_lock);
-	if (rc)
+	if (rc) {
+		/* Expect ENOENT if DMA queues have not been set up */
+		if (rc != -ENOENT || atomic_read(&efx->active_queues))
+			efx_mcdi_display_error(efx, MC_CMD_MAC_STATS,
+					       sizeof(inbuf), NULL, 0, rc);
 		goto out;
+	}
 
 	generation_end = dma_stats[MC_CMD_MAC_GENERATION_END];
 	if (generation_end == EFX_MC_STATS_GENERATION_INVALID) {
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index fffc348..7f295c4 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -948,8 +948,12 @@ static int efx_mcdi_mac_stats(struct efx_nic *efx,
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, nic_data->vport_id);
 
-	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
-			  NULL, 0, NULL);
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
+				NULL, 0, NULL);
+	/* Expect ENOENT if DMA queues have not been set up */
+	if (rc && (rc != -ENOENT || atomic_read(&efx->active_queues)))
+		efx_mcdi_display_error(efx, MC_CMD_MAC_STATS, sizeof(inbuf),
+				       NULL, 0, rc);
 	return rc;
 }
 
