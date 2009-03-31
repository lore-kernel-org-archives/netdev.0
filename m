From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Call netif_napi_add() before registering our
	interrupt handler
Date: Tue, 31 Mar 2009 20:07:44 +0100
Message-ID: <1238526464.3254.7.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:53850 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751826AbZCaTHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 15:07:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we use a shared legacy IRQ then our interrupt handler may be called
as soon as it is registered even though IRQs are disabled on the NIC.
Now that the legacy interrupt handler also checks for event delivery,
it may decide to schedule polling in this case.  Ensure that the NAPI
context is valid but disabled at this point.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Please apply this to net-2.6; the bug it fixes is much easier to hit
following commit a9de9a74c69f75e9456cd6b45ecab44ff4c81d04

Ben.

 drivers/net/sfc/efx.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 00c23b1..dee23b1 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -448,6 +448,9 @@ static void efx_init_channels(struct efx_nic *efx)
 
 		WARN_ON(channel->rx_pkt != NULL);
 		efx_rx_strategy(channel);
+
+		netif_napi_add(channel->napi_dev, &channel->napi_str,
+			       efx_poll, napi_weight);
 	}
 }
 
@@ -462,10 +465,6 @@ static void efx_start_channel(struct efx_channel *channel)
 
 	EFX_LOG(channel->efx, "starting chan %d\n", channel->channel);
 
-	if (!(channel->efx->net_dev->flags & IFF_UP))
-		netif_napi_add(channel->napi_dev, &channel->napi_str,
-			       efx_poll, napi_weight);
-
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we enable it.  Make sure it's cleared before
 	 * then.  Similarly, make sure it sees the enabled flag set. */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

