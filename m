From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 8/9] sfc: support cascaded multicast filters
Date: Tue, 21 Jul 2015 15:10:44 +0100
Message-ID: <55AE52E4.8080703@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:43541 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755196AbbGUOOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:14:22 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

If the workaround to support cascaded multicast filters ("workaround_26807") is
enabled, the broadcast filter and individual multicast filters are not inserted
when in promiscuous or allmulti mode.

There is a race while inserting and removing filters when entering and leaving
promiscuous mode.  When changing promiscuous state with cascaded multicast
filters, the old multicast filters are removed before inserting the new filters
to avoid duplicating packets; this can lead to dropped packets until all
filters have been inserted.

The efx_nic:mc_promisc flag is added to record the presence of a multicast
promiscuous filter; this gives a simple way to tell if the promiscuous state is
changing.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 56 ++++++++++++++++++++++++++---------
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 2 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 1704f71..0a7cf43 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3792,26 +3792,42 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx, bool *promisc)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct net_device *net_dev = efx->net_dev;
 	struct netdev_hw_addr *mc;
-	unsigned int i;
+	unsigned int i, addr_count;
 
-	if (netdev_mc_count(net_dev) + 2 /* room for broadcast and promisc */
-	    >= EFX_EF10_FILTER_DEV_MC_MAX) {
-		table->dev_mc_count = 1;
-		eth_broadcast_addr(table->dev_mc_list[0].addr);
+	if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
 		*promisc = true;
+
+	if (nic_data->workaround_26807) {
+		if (*promisc) {
+			table->dev_mc_count = 0;
+			return;
+		}
+		addr_count = netdev_mc_count(net_dev);
 	} else {
-		table->dev_mc_count = 1 + netdev_mc_count(net_dev);
-		eth_broadcast_addr(table->dev_mc_list[0].addr);
-		i = 1;
-		netdev_for_each_mc_addr(mc, net_dev) {
-			ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
-			i++;
+		/* Allow room for broadcast and promiscuous */
+		addr_count = netdev_mc_count(net_dev) + 2;
+	}
+
+	if (addr_count >= EFX_EF10_FILTER_DEV_MC_MAX) {
+		if (nic_data->workaround_26807) {
+			table->dev_mc_count = 0;
+		} else {
+			table->dev_mc_count = 1;
+			eth_broadcast_addr(table->dev_mc_list[0].addr);
 		}
+		*promisc = true;
+		return;
+	}
 
-		if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
-			*promisc = true;
+	table->dev_mc_count = 1 + netdev_mc_count(net_dev);
+	eth_broadcast_addr(table->dev_mc_list[0].addr);
+	i = 1;
+	netdev_for_each_mc_addr(mc, net_dev) {
+		ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
+		i++;
 	}
 }
 
@@ -3846,7 +3862,11 @@ static void efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 			 * filter for multicast
 			 */
 			while (i--) {
-				if (multicast && i == 1)
+				struct efx_ef10_nic_data *nic_data =
+					efx->nic_data;
+
+				if (multicast && i == 1 &&
+				    !nic_data->workaround_26807)
 					break;
 
 				efx_ef10_filter_remove_safe(
@@ -3974,6 +3994,7 @@ reset_nic:
 static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct net_device *net_dev = efx->net_dev;
 	bool uc_promisc = false, mc_promisc = false;
 
@@ -3995,9 +4016,16 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 
 	/* Insert/renew filters */
 	efx_ef10_filter_insert_addr_list(efx, false, &uc_promisc);
+
+	/* If changing promiscuous state with cascaded multicast filters, remove
+	 * old filters first, so that packets are dropped rather than duplicated
+	 */
+	if (nic_data->workaround_26807 && efx->mc_promisc != mc_promisc)
+		efx_ef10_filter_remove_old(efx);
 	efx_ef10_filter_insert_addr_list(efx, true, &mc_promisc);
 
 	efx_ef10_filter_remove_old(efx);
+	efx->mc_promisc = mc_promisc;
 }
 
 static int efx_ef10_set_mac_address(struct efx_nic *efx)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 47d1e3a..4d35313 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -925,6 +925,7 @@ struct vfdi_status;
  * @stats_lock: Statistics update lock. Must be held when calling
  *	efx_nic_type::{update,start,stop}_stats.
  * @n_rx_noskb_drops: Count of RX packets dropped due to failure to allocate an skb
+ * @mc_promisc: Whether in multicast promiscuous mode when last changed
  *
  * This is stored in the private area of the &struct net_device.
  */
@@ -1072,6 +1073,7 @@ struct efx_nic {
 	int last_irq_cpu;
 	spinlock_t stats_lock;
 	atomic_t n_rx_noskb_drops;
+	bool mc_promisc;
 };
 
 static inline int efx_dev_registered(struct efx_nic *efx)
