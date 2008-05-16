From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/16] sfc: Simplified efx_rx_calc_buffer_size() using get_order()
Date: Fri, 16 May 2008 21:15:06 +0100
Message-ID: <20080516201506.GV28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53513 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752337AbYEPUQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:16:04 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merged it into its only caller, efx_init_channels().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   29 ++++++++---------------------
 1 files changed, 8 insertions(+), 21 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 48aae47..1a065fc 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -317,26 +317,6 @@ static void efx_remove_eventq(struct efx_channel *channel)
  *
  *************************************************************************/
 
-/* Setup per-NIC RX buffer parameters.
- * Calculate the rx buffer allocation parameters required to support
- * the current MTU, including padding for header alignment and overruns.
- */
-static void efx_calc_rx_buffer_params(struct efx_nic *efx)
-{
-	unsigned int order, len;
-
-	len = (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
-	       EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
-	       efx->type->rx_buffer_padding);
-
-	/* Calculate page-order */
-	for (order = 0; ((1u << order) * PAGE_SIZE) < len; ++order)
-		;
-
-	efx->rx_buffer_len = len;
-	efx->rx_buffer_order = order;
-}
-
 static int efx_probe_channel(struct efx_channel *channel)
 {
 	struct efx_tx_queue *tx_queue;
@@ -387,7 +367,14 @@ static int efx_init_channels(struct efx_nic *efx)
 	struct efx_channel *channel;
 	int rc = 0;
 
-	efx_calc_rx_buffer_params(efx);
+	/* Calculate the rx buffer allocation parameters required to
+	 * support the current MTU, including padding for header
+	 * alignment and overruns.
+	 */
+	efx->rx_buffer_len = (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
+			      EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
+			      efx->type->rx_buffer_padding);
+	efx->rx_buffer_order = get_order(efx->rx_buffer_len);
 
 	/* Initialise the channels */
 	efx_for_each_channel(channel, efx) {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
