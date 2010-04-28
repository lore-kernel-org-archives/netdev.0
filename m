From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/17] sfc: Set PERIODIC_NOEVENT flag for MC_CMD_MAC_STATS
Date: Wed, 28 Apr 2010 20:29:32 +0100
Message-ID: <1272482972.2549.27.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12560 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab0D1T3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:29:35 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

When set, an event is not sent whenever periodic MAC statistics are
raised.  This avoids unnecessary wake-ups.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi_mac.c |   25 +++++++++----------------
 1 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/sfc/mcdi_mac.c b/drivers/net/sfc/mcdi_mac.c
index 06d24a1..3918263 100644
--- a/drivers/net/sfc/mcdi_mac.c
+++ b/drivers/net/sfc/mcdi_mac.c
@@ -80,7 +80,7 @@ int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 	u8 inbuf[MC_CMD_MAC_STATS_IN_LEN];
 	int rc;
 	efx_dword_t *cmd_ptr;
-	int period = 1000;
+	int period = enable ? 1000 : 0;
 	u32 addr_hi;
 	u32 addr_lo;
 
@@ -92,21 +92,14 @@ int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_ADDR_LO, addr_lo);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_ADDR_HI, addr_hi);
 	cmd_ptr = (efx_dword_t *)MCDI_PTR(inbuf, MAC_STATS_IN_CMD);
-	if (enable)
-		EFX_POPULATE_DWORD_6(*cmd_ptr,
-				     MC_CMD_MAC_STATS_CMD_DMA, 1,
-				     MC_CMD_MAC_STATS_CMD_CLEAR, clear,
-				     MC_CMD_MAC_STATS_CMD_PERIODIC_CHANGE, 1,
-				     MC_CMD_MAC_STATS_CMD_PERIODIC_ENABLE, 1,
-				     MC_CMD_MAC_STATS_CMD_PERIODIC_CLEAR, 0,
-				     MC_CMD_MAC_STATS_CMD_PERIOD_MS, period);
-	else
-		EFX_POPULATE_DWORD_5(*cmd_ptr,
-				     MC_CMD_MAC_STATS_CMD_DMA, 0,
-				     MC_CMD_MAC_STATS_CMD_CLEAR, clear,
-				     MC_CMD_MAC_STATS_CMD_PERIODIC_CHANGE, 1,
-				     MC_CMD_MAC_STATS_CMD_PERIODIC_ENABLE, 0,
-				     MC_CMD_MAC_STATS_CMD_PERIODIC_CLEAR, 0);
+	EFX_POPULATE_DWORD_7(*cmd_ptr,
+			     MC_CMD_MAC_STATS_CMD_DMA, !!enable,
+			     MC_CMD_MAC_STATS_CMD_CLEAR, clear,
+			     MC_CMD_MAC_STATS_CMD_PERIODIC_CHANGE, 1,
+			     MC_CMD_MAC_STATS_CMD_PERIODIC_ENABLE, !!enable,
+			     MC_CMD_MAC_STATS_CMD_PERIODIC_CLEAR, 0,
+			     MC_CMD_MAC_STATS_CMD_PERIODIC_NOEVENT, 1,
+			     MC_CMD_MAC_STATS_CMD_PERIOD_MS, period);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

