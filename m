From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 2/2] sfc: Fix NAPI list corruption during ring
 reallocation
Date: Tue, 07 Dec 2010 21:42:44 +0000
Message-ID: <1291758165.21627.21.camel@bwh-desktop>
References: <1291758047.21627.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41849 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab0LGVmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 16:42:47 -0500
In-Reply-To: <1291758047.21627.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call netif_napi_{add,del}() on the NAPI contexts in the new and
old channels, respectively.

Since efx_init_napi() cannot fail, make its return type void.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   31 +++++++++++++++++++------------
 1 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d06cb74..fb83cdd 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -197,7 +197,9 @@ MODULE_PARM_DESC(debug, "Bitmapped debugging message enable value");
 
 static void efx_remove_channels(struct efx_nic *efx);
 static void efx_remove_port(struct efx_nic *efx);
+static void efx_init_napi(struct efx_nic *efx);
 static void efx_fini_napi(struct efx_nic *efx);
+static void efx_fini_napi_channel(struct efx_channel *channel);
 static void efx_fini_struct(struct efx_nic *efx);
 static void efx_start_all(struct efx_nic *efx);
 static void efx_stop_all(struct efx_nic *efx);
@@ -430,6 +432,7 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
 
 		*channel = *old_channel;
 
+		channel->napi_dev = NULL;
 		memset(&channel->eventq, 0, sizeof(channel->eventq));
 
 		rx_queue = &channel->rx_queue;
@@ -740,9 +743,13 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 	if (rc)
 		goto rollback;
 
+	efx_init_napi(efx);
+
 	/* Destroy old channels */
-	for (i = 0; i < efx->n_channels; i++)
+	for (i = 0; i < efx->n_channels; i++) {
+		efx_fini_napi_channel(other_channel[i]);
 		efx_remove_channel(other_channel[i]);
+	}
 out:
 	/* Free unused channel structures */
 	for (i = 0; i < efx->n_channels; i++)
@@ -1601,7 +1608,7 @@ static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
  *
  **************************************************************************/
 
-static int efx_init_napi(struct efx_nic *efx)
+static void efx_init_napi(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
 
@@ -1610,18 +1617,21 @@ static int efx_init_napi(struct efx_nic *efx)
 		netif_napi_add(channel->napi_dev, &channel->napi_str,
 			       efx_poll, napi_weight);
 	}
-	return 0;
+}
+
+static void efx_fini_napi_channel(struct efx_channel *channel)
+{
+	if (channel->napi_dev)
+		netif_napi_del(&channel->napi_str);
+	channel->napi_dev = NULL;
 }
 
 static void efx_fini_napi(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
 
-	efx_for_each_channel(channel, efx) {
-		if (channel->napi_dev)
-			netif_napi_del(&channel->napi_str);
-		channel->napi_dev = NULL;
-	}
+	efx_for_each_channel(channel, efx)
+		efx_fini_napi_channel(channel);
 }
 
 /**************************************************************************
@@ -2343,9 +2353,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	if (rc)
 		goto fail1;
 
-	rc = efx_init_napi(efx);
-	if (rc)
-		goto fail2;
+	efx_init_napi(efx);
 
 	rc = efx->type->init(efx);
 	if (rc) {
@@ -2376,7 +2384,6 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	efx->type->fini(efx);
  fail3:
 	efx_fini_napi(efx);
- fail2:
 	efx_remove_all(efx);
  fail1:
 	return rc;
-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

