From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 40/52] sfc: Rework efx_set_multicast_hash()
Date: Mon, 1 Sep 2008 12:49:12 +0100
Message-ID: <20080901114911.GH7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42991 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759096AbYIALtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:14 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When !port_enabled, defer the write to reconfigure_mac_wrapper.

Whilst here, simplify the logic now that efx_start_port() always calls
efx_reconfigure_port().

From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d593086..0d47d6f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -560,6 +560,12 @@ void __efx_reconfigure_port(struct efx_nic *efx)
 	EFX_LOG(efx, "reconfiguring MAC from PHY settings on CPU %d\n",
 		raw_smp_processor_id());
 
+	/* Serialise the promiscuous flag with efx_set_multicast_list. */
+	if (efx_dev_registered(efx)) {
+		netif_addr_lock_bh(efx->net_dev);
+		netif_addr_unlock_bh(efx->net_dev);
+	}
+
 	falcon_reconfigure_xmac(efx);
 
 	/* Inform kernel of loss/gain of carrier */
@@ -1410,26 +1416,19 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	return 0;
 }
 
-/* Context: netif_tx_lock held, BHs disabled. */
+/* Context: netif_addr_lock held, BHs disabled. */
 static void efx_set_multicast_list(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct dev_mc_list *mc_list = net_dev->mc_list;
 	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
-	bool promiscuous;
+	bool promiscuous = !!(net_dev->flags & IFF_PROMISC);
+	bool changed = (efx->promiscuous != promiscuous);
 	u32 crc;
 	int bit;
 	int i;
 
-	/* Set per-MAC promiscuity flag and reconfigure MAC if necessary */
-	promiscuous = !!(net_dev->flags & IFF_PROMISC);
-	if (efx->promiscuous != promiscuous) {
-		efx->promiscuous = promiscuous;
-		/* Close the window between efx_stop_port() and efx_flush_all()
-		 * by only queuing work when the port is enabled. */
-		if (efx->port_enabled)
-			queue_work(efx->workqueue, &efx->reconfigure_work);
-	}
+	efx->promiscuous = promiscuous;
 
 	/* Build multicast hash table */
 	if (promiscuous || (net_dev->flags & IFF_ALLMULTI)) {
@@ -1444,6 +1443,13 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 		}
 	}
 
+	if (!efx->port_enabled)
+		/* Delay pushing settings until efx_start_port() */
+		return;
+
+	if (changed)
+		queue_work(efx->workqueue, &efx->reconfigure_work);
+
 	/* Create and activate new global multicast hash table */
 	falcon_set_multicast_hash(efx);
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

