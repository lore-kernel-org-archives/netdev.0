From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Match calls to netif_napi_add() and netif_napi_del()
Date: Wed, 15 Apr 2009 02:17:30 +0100
Message-ID: <1239758250.3203.12.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:45768 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751300AbZDOBRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 21:17:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sfc could call netif_napi_add() multiple times for the same
napi_struct, corrupting the list of napi_structs for the associated
device and leading to a busy-loop on device removal.  Move the call to
netif_napi_add() and add a call to netif_napi_del() in the obvious
places.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index dee23b1..7269a42 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -448,9 +448,6 @@ static void efx_init_channels(struct efx_nic *efx)
 
 		WARN_ON(channel->rx_pkt != NULL);
 		efx_rx_strategy(channel);
-
-		netif_napi_add(channel->napi_dev, &channel->napi_str,
-			       efx_poll, napi_weight);
 	}
 }
 
@@ -1321,6 +1318,8 @@ static int efx_init_napi(struct efx_nic *efx)
 
 	efx_for_each_channel(channel, efx) {
 		channel->napi_dev = efx->net_dev;
+		netif_napi_add(channel->napi_dev, &channel->napi_str,
+			       efx_poll, napi_weight);
 	}
 	return 0;
 }
@@ -1330,6 +1329,8 @@ static void efx_fini_napi(struct efx_nic *efx)
 	struct efx_channel *channel;
 
 	efx_for_each_channel(channel, efx) {
+		if (channel->napi_dev)
+			netif_napi_del(&channel->napi_str);
 		channel->napi_dev = NULL;
 	}
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

