From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 12/15] sfc: don't update stats on VF when called
 in atomic context
Date: Tue, 2 Jun 2015 11:40:18 +0100
Message-ID: <556D8812.90906@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:47790 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755949AbbFBKk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:40:27 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The ifenslave command to set up a bond runs in an atomic
context, and it queries the stats on the devices that are
being enslaved. A VF needs to make an MCDI call to update
its stats, which is not allowed in atomic context.

The releasing of the stats_lock is moved to the beginning of
the VF stats update function so that in_interrupt() can be
used; it must be taken again before returning from this
function.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 03f464f..6b8d8f2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1306,11 +1306,24 @@ static int efx_ef10_try_update_nic_stats_vf(struct efx_nic *efx)
 	__le64 *dma_stats;
 	int rc;
 
+	spin_unlock_bh(&efx->stats_lock);
+
+	if (in_interrupt()) {
+		/* If in atomic context, cannot update stats.  Just update the
+		 * software stats and return so the caller can continue.
+		 */
+		spin_lock_bh(&efx->stats_lock);
+		efx_update_sw_stats(efx, stats);
+		return 0;
+	}
+
 	efx_ef10_get_stat_mask(efx, mask);
 
 	rc = efx_nic_alloc_buffer(efx, &stats_buf, dma_len, GFP_ATOMIC);
-	if (rc)
+	if (rc) {
+		spin_lock_bh(&efx->stats_lock);
 		return rc;
+	}
 
 	dma_stats = stats_buf.addr;
 	dma_stats[MC_CMD_MAC_GENERATION_END] = EFX_MC_STATS_GENERATION_INVALID;
@@ -1321,7 +1334,6 @@ static int efx_ef10_try_update_nic_stats_vf(struct efx_nic *efx)
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, EVB_PORT_ID_ASSIGNED);
 
-	spin_unlock_bh(&efx->stats_lock);
 	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
 				NULL, 0, NULL);
 	spin_lock_bh(&efx->stats_lock);
