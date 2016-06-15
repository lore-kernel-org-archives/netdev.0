From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 07/17] sfc: Store unicast and multicast promisc flag
 with address cache
Date: Wed, 15 Jun 2016 17:45:56 +0100
Message-ID: <9c33a1c3-beee-e2fb-7ba2-9a458419b085@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:43035 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753138AbcFOQua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:30 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

These flags are built when address cache is updated.
The information will be required when VLAN filtering is added and address
cache is used without re-sync.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 7abb8a7..a2a10dc 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -89,6 +89,8 @@ struct efx_ef10_filter_table {
 	struct efx_ef10_dev_addr dev_mc_list[EFX_EF10_FILTER_DEV_MC_MAX];
 	int dev_uc_count;
 	int dev_mc_count;
+	bool uc_promisc;
+	bool mc_promisc;
 /* Whether in multicast promiscuous mode when last changed */
 	bool mc_promisc_last;
 	struct efx_ef10_filter_vlan vlan;
@@ -3948,7 +3950,7 @@ static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 	spin_unlock_bh(&efx->filter_lock);
 }
 
-static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
+static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct net_device *net_dev = efx->net_dev;
@@ -3957,14 +3959,13 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 	unsigned int i;
 
 	addr_count = netdev_uc_count(net_dev);
-	if (net_dev->flags & IFF_PROMISC)
-		*promisc = true;
+	table->uc_promisc = !!(net_dev->flags & IFF_PROMISC);
 	table->dev_uc_count = 1 + addr_count;
 	ether_addr_copy(table->dev_uc_list[0].addr, net_dev->dev_addr);
 	i = 1;
 	netdev_for_each_uc_addr(uc, net_dev) {
 		if (i >= EFX_EF10_FILTER_DEV_UC_MAX) {
-			*promisc = true;
+			table->uc_promisc = true;
 			break;
 		}
 		ether_addr_copy(table->dev_uc_list[i].addr, uc->addr);
@@ -3972,21 +3973,20 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 	}
 }
 
-static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx, bool *promisc)
+static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct net_device *net_dev = efx->net_dev;
 	struct netdev_hw_addr *mc;
 	unsigned int i, addr_count;
 
-	if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
-		*promisc = true;
+	table->mc_promisc = !!(net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI));
 
 	addr_count = netdev_mc_count(net_dev);
 	i = 0;
 	netdev_for_each_mc_addr(mc, net_dev) {
 		if (i >= EFX_EF10_FILTER_DEV_MC_MAX) {
-			*promisc = true;
+			table->mc_promisc = true;
 			break;
 		}
 		ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
@@ -4252,7 +4252,6 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct net_device *net_dev = efx->net_dev;
-	bool uc_promisc = false, mc_promisc = false;
 
 	if (!efx_dev_registered(efx))
 		return;
@@ -4266,12 +4265,12 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	 * address and broadcast address
 	 */
 	netif_addr_lock_bh(net_dev);
-	efx_ef10_filter_uc_addr_list(efx, &uc_promisc);
-	efx_ef10_filter_mc_addr_list(efx, &mc_promisc);
+	efx_ef10_filter_uc_addr_list(efx);
+	efx_ef10_filter_mc_addr_list(efx);
 	netif_addr_unlock_bh(net_dev);
 
 	/* Insert/renew unicast filters */
-	if (uc_promisc) {
+	if (table->uc_promisc) {
 		efx_ef10_filter_insert_def(efx, false, false);
 		efx_ef10_filter_insert_addr_list(efx, false, false);
 	} else {
@@ -4287,9 +4286,10 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	/* If changing promiscuous state with cascaded multicast filters, remove
 	 * old filters first, so that packets are dropped rather than duplicated
 	 */
-	if (nic_data->workaround_26807 && table->mc_promisc_last != mc_promisc)
+	if (nic_data->workaround_26807 &&
+	    table->mc_promisc_last != table->mc_promisc)
 		efx_ef10_filter_remove_old(efx);
-	if (mc_promisc) {
+	if (table->mc_promisc) {
 		if (nic_data->workaround_26807) {
 			/* If we failed to insert promiscuous filters, rollback
 			 * and fall back to individual multicast filters
@@ -4322,7 +4322,7 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	}
 
 	efx_ef10_filter_remove_old(efx);
-	table->mc_promisc_last = mc_promisc;
+	table->mc_promisc_last = table->mc_promisc;
 }
 
 static int efx_ef10_set_mac_address(struct efx_nic *efx)
