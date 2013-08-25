From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/16] sfc: Remove bogus call to
 efx_release_tx_buffers()
Date: Mon, 26 Aug 2013 00:06:23 +0100
Message-ID: <1377471983.2586.78.camel@deadeye.wl.decadent.org.uk>
References: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50360 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690Ab3HYXG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 19:06:28 -0400
In-Reply-To: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_unregister_netdev() should not call efx_release_tx_buffers()
directly, as it is already done when closing the device:
efx_net_stop() -> efx_stop_all() -> efx_stop_datapath() ->
efx_fini_tx_queue() -> efx_release_tx_buffers().

(This was presumably a workaround for a race between efx_stop_all()
and the data path that has since been properly fixed.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index ee9242c..0c3c0c1 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2156,22 +2156,11 @@ fail_locked:
 
 static void efx_unregister_netdev(struct efx_nic *efx)
 {
-	struct efx_channel *channel;
-	struct efx_tx_queue *tx_queue;
-
 	if (!efx->net_dev)
 		return;
 
 	BUG_ON(netdev_priv(efx->net_dev) != efx);
 
-	/* Free up any skbs still remaining. This has to happen before
-	 * we try to unregister the netdev as running their destructors
-	 * may be needed to get the device ref. count to 0. */
-	efx_for_each_channel(channel, efx) {
-		efx_for_each_channel_tx_queue(tx_queue, channel)
-			efx_release_tx_buffers(tx_queue);
-	}
-
 	strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
