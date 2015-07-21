From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 6/9] sfc: Insert multicast filters as well as mismatch
 filters in promiscuous mode
Date: Tue, 21 Jul 2015 15:10:15 +0100
Message-ID: <55AE52C7.7090909@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:34575 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752833AbbGUOOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:14:55 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

If a function is in promiscuous mode and another function has a broadcast or
 multicast filter inserted, the function in promiscuous mode won't see that
 broadcast or multicast traffic.
Most notably this breaks broadcast, which means ARP doesn't work. Less
 show-stoppingly, a function listening on a multicast address that's also in
 promiscuous mode will not see that multicast traffic if another function is
 also listening on that multicast address.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 104 ++++++++++++++++++++--------------------
 1 file changed, 53 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 18d6388..784b46f 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3758,7 +3758,8 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	struct netdev_hw_addr *uc;
 	struct netdev_hw_addr *mc;
 	unsigned int filter_idx;
-	int i, n, rc;
+	int i, rc;
+	bool uc_promisc = false, mc_promisc = false;
 
 	if (!efx_dev_registered(efx))
 		return;
@@ -3768,13 +3769,11 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 
 	/* Mark old filters that may need to be removed */
 	spin_lock_bh(&efx->filter_lock);
-	n = table->dev_uc_count < 0 ? 1 : table->dev_uc_count;
-	for (i = 0; i < n; i++) {
+	for (i = 0; i < table->dev_uc_count; i++) {
 		filter_idx = table->dev_uc_list[i].id % HUNT_FILTER_TBL_ROWS;
 		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
 	}
-	n = table->dev_mc_count < 0 ? 1 : table->dev_mc_count;
-	for (i = 0; i < n; i++) {
+	for (i = 0; i < table->dev_mc_count; i++) {
 		filter_idx = table->dev_mc_list[i].id % HUNT_FILTER_TBL_ROWS;
 		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
 	}
@@ -3786,7 +3785,8 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	netif_addr_lock_bh(net_dev);
 	if (net_dev->flags & IFF_PROMISC ||
 	    netdev_uc_count(net_dev) >= EFX_EF10_FILTER_DEV_UC_MAX) {
-		table->dev_uc_count = -1;
+		table->dev_uc_count = 0;
+		uc_promisc = true;
 	} else {
 		table->dev_uc_count = 1 + netdev_uc_count(net_dev);
 		ether_addr_copy(table->dev_uc_list[0].addr, net_dev->dev_addr);
@@ -3796,9 +3796,11 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 			i++;
 		}
 	}
-	if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI) ||
-	    netdev_mc_count(net_dev) >= EFX_EF10_FILTER_DEV_MC_MAX) {
-		table->dev_mc_count = -1;
+	if (netdev_mc_count(net_dev) + 2 /* room for broadcast and promisc */
+			>= EFX_EF10_FILTER_DEV_MC_MAX) {
+		table->dev_mc_count = 1;
+		eth_broadcast_addr(table->dev_mc_list[0].addr);
+		mc_promisc = true;
 	} else {
 		table->dev_mc_count = 1 + netdev_mc_count(net_dev);
 		eth_broadcast_addr(table->dev_mc_list[0].addr);
@@ -3807,31 +3809,32 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 			ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
 			i++;
 		}
+		if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
+			mc_promisc = true;
 	}
 	netif_addr_unlock_bh(net_dev);
 
 	/* Insert/renew unicast filters */
-	if (table->dev_uc_count >= 0) {
-		for (i = 0; i < table->dev_uc_count; i++) {
-			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-					   EFX_FILTER_FLAG_RX_RSS,
-					   0);
-			efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-						 table->dev_uc_list[i].addr);
-			rc = efx_ef10_filter_insert(efx, &spec, true);
-			if (rc < 0) {
-				/* Fall back to unicast-promisc */
-				while (i--)
-					efx_ef10_filter_remove_safe(
-						efx, EFX_FILTER_PRI_AUTO,
-						table->dev_uc_list[i].id);
-				table->dev_uc_count = -1;
-				break;
-			}
-			table->dev_uc_list[i].id = rc;
+	for (i = 0; i < table->dev_uc_count; i++) {
+		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
+				   EFX_FILTER_FLAG_RX_RSS,
+				   0);
+		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
+					 table->dev_uc_list[i].addr);
+		rc = efx_ef10_filter_insert(efx, &spec, true);
+		if (rc < 0) {
+			/* Fall back to unicast-promisc */
+			while (i--)
+				efx_ef10_filter_remove_safe(
+					efx, EFX_FILTER_PRI_AUTO,
+					table->dev_uc_list[i].id);
+			table->dev_uc_count = 0;
+			uc_promisc = true;
+			break;
 		}
+		table->dev_uc_list[i].id = rc;
 	}
-	if (table->dev_uc_count < 0) {
+	if (uc_promisc) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
@@ -3839,34 +3842,34 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
 			WARN_ON(1);
-			table->dev_uc_count = 0;
 		} else {
-			table->dev_uc_list[0].id = rc;
+			table->dev_uc_list[table->dev_uc_count++].id = rc;
 		}
 	}
 
 	/* Insert/renew multicast filters */
-	if (table->dev_mc_count >= 0) {
-		for (i = 0; i < table->dev_mc_count; i++) {
-			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-					   EFX_FILTER_FLAG_RX_RSS,
-					   0);
-			efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-						 table->dev_mc_list[i].addr);
-			rc = efx_ef10_filter_insert(efx, &spec, true);
-			if (rc < 0) {
-				/* Fall back to multicast-promisc */
-				while (i--)
-					efx_ef10_filter_remove_safe(
-						efx, EFX_FILTER_PRI_AUTO,
-						table->dev_mc_list[i].id);
-				table->dev_mc_count = -1;
-				break;
-			}
-			table->dev_mc_list[i].id = rc;
+	for (i = 0; i < table->dev_mc_count; i++) {
+		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
+				   EFX_FILTER_FLAG_RX_RSS,
+				   0);
+		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
+					 table->dev_mc_list[i].addr);
+		rc = efx_ef10_filter_insert(efx, &spec, true);
+		if (rc < 0) {
+			/* Fall back to multicast-promisc.
+			 * Leave the broadcast filter.
+			 */
+			while (i > 1)
+				efx_ef10_filter_remove_safe(
+					efx, EFX_FILTER_PRI_AUTO,
+					table->dev_mc_list[--i].id);
+			table->dev_mc_count = i;
+			mc_promisc = true;
+			break;
 		}
+		table->dev_mc_list[i].id = rc;
 	}
-	if (table->dev_mc_count < 0) {
+	if (mc_promisc) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
@@ -3874,9 +3877,8 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
 			WARN_ON(1);
-			table->dev_mc_count = 0;
 		} else {
-			table->dev_mc_list[0].id = rc;
+			table->dev_mc_list[table->dev_mc_count++].id = rc;
 		}
 	}
 
