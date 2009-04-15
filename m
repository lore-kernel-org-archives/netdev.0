From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH stable] sfc: Match calls to netif_napi_add() and
	netif_napi_del()
Date: Wed, 15 Apr 2009 01:39:03 +0100
Message-ID: <1239755943.3203.10.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Greg Kroah-Hartman <greg@kroah.com>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:44148 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751912AbZDOAjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 20:39:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sfc could call netif_napi_add() multiple times for the same
napi_struct, corrupting the list of napi_structs for the associated
device and leading to a busy-loop on device removal.  Move the call to
netif_napi_add() and add a call to netif_napi_del() in the obvious
places.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
We didn't spot this earlier because only netpoll would look at the list,
but this changed with the addition of GRO in 2.6.29.  I have no excuse
for not catching it during the .29 release cycle though.

Ben.

 drivers/net/sfc/efx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ab0e09b..655e9b2 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -424,10 +424,6 @@ static void efx_start_channel(struct efx_channel *channel)
 
 	EFX_LOG(channel->efx, "starting chan %d\n", channel->channel);
 
-	if (!(channel->efx->net_dev->flags & IFF_UP))
-		netif_napi_add(channel->napi_dev, &channel->napi_str,
-			       efx_poll, napi_weight);
-
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we enable it.  Make sure it's cleared before
 	 * then.  Similarly, make sure it sees the enabled flag set. */
@@ -1273,6 +1269,8 @@ static int efx_init_napi(struct efx_nic *efx)
 
 	efx_for_each_channel(channel, efx) {
 		channel->napi_dev = efx->net_dev;
+		netif_napi_add(channel->napi_dev, &channel->napi_str,
+			       efx_poll, napi_weight);
 		rc = efx_lro_init(&channel->lro_mgr, efx);
 		if (rc)
 			goto err;
@@ -1289,6 +1287,8 @@ static void efx_fini_napi(struct efx_nic *efx)
 
 	efx_for_each_channel(channel, efx) {
 		efx_lro_fini(&channel->lro_mgr);
+		if (channel->napi_dev)
+			netif_napi_del(&channel->napi_str);
 		channel->napi_dev = NULL;
 	}
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

