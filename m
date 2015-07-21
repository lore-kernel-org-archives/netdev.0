From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 9/9] sfc: clean fallbacks between promisc/normal
 in efx_ef10_filter_sync_rx_mode
Date: Tue, 21 Jul 2015 15:11:00 +0100
Message-ID: <55AE52F4.3040805@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:39426 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755196AbbGUOOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:14:36 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate functions for inserting individual and promisc filters; explicit
 fallback logic in efx_ef10_filter_sync_rx_mode(), in order not to overload
 the 'promisc' flag as also meaning "fall back to promisc".

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 288 +++++++++++++++++++++++++++++-----------
 1 file changed, 208 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 0a7cf43..8505d82 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -49,6 +49,7 @@ enum {
  */
 #define HUNT_FILTER_TBL_ROWS 8192
 
+#define EFX_EF10_FILTER_ID_INVALID 0xffff
 struct efx_ef10_dev_addr {
 	u8 addr[ETH_ALEN];
 	u16 id;
@@ -76,8 +77,12 @@ struct efx_ef10_filter_table {
 #define EFX_EF10_FILTER_DEV_MC_MAX	256
 	struct efx_ef10_dev_addr dev_uc_list[EFX_EF10_FILTER_DEV_UC_MAX];
 	struct efx_ef10_dev_addr dev_mc_list[EFX_EF10_FILTER_DEV_MC_MAX];
-	int dev_uc_count;		/* negative for PROMISC */
-	int dev_mc_count;		/* negative for PROMISC/ALLMULTI */
+	int dev_uc_count;
+	int dev_mc_count;
+/* Indices (like efx_ef10_dev_addr.id) for promisc/allmulti filters */
+	u16 ucdef_id;
+	u16 bcast_id;
+	u16 mcdef_id;
 };
 
 /* An arbitrary search limit for the software hash table */
@@ -3273,6 +3278,19 @@ static int efx_ef10_filter_remove_safe(struct efx_nic *efx,
 					       filter_id, false);
 }
 
+static u32 efx_ef10_filter_get_unsafe_id(struct efx_nic *efx, u32 filter_id)
+{
+	return filter_id % HUNT_FILTER_TBL_ROWS;
+}
+
+static int efx_ef10_filter_remove_unsafe(struct efx_nic *efx,
+					 enum efx_filter_priority priority,
+					 u32 filter_id)
+{
+	return efx_ef10_filter_remove_internal(efx, 1U << priority,
+					       filter_id, true);
+}
+
 static int efx_ef10_filter_get_safe(struct efx_nic *efx,
 				    enum efx_filter_priority priority,
 				    u32 filter_id, struct efx_filter_spec *spec)
@@ -3646,6 +3664,10 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 		goto fail;
 	}
 
+	table->ucdef_id = EFX_EF10_FILTER_ID_INVALID;
+	table->bcast_id = EFX_EF10_FILTER_ID_INVALID;
+	table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
+
 	efx->filter_state = table;
 	init_waitqueue_head(&table->waitq);
 	return 0;
@@ -3748,6 +3770,12 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 	kfree(table);
 }
 
+#define EFX_EF10_FILTER_DO_MARK_OLD(id) \
+		if (id != EFX_EF10_FILTER_ID_INVALID) { \
+			filter_idx = efx_ef10_filter_get_unsafe_id(efx, id); \
+			WARN_ON(!table->entry[filter_idx].spec); \
+			table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD; \
+		}
 static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
@@ -3758,33 +3786,39 @@ static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 
 	/* Mark old filters that may need to be removed */
 	spin_lock_bh(&efx->filter_lock);
-	for (i = 0; i < table->dev_uc_count; i++) {
-		filter_idx = table->dev_uc_list[i].id % HUNT_FILTER_TBL_ROWS;
-		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
-	}
-	for (i = 0; i < table->dev_mc_count; i++) {
-		filter_idx = table->dev_mc_list[i].id % HUNT_FILTER_TBL_ROWS;
-		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
-	}
+	for (i = 0; i < table->dev_uc_count; i++)
+		EFX_EF10_FILTER_DO_MARK_OLD(table->dev_uc_list[i].id);
+	for (i = 0; i < table->dev_mc_count; i++)
+		EFX_EF10_FILTER_DO_MARK_OLD(table->dev_mc_list[i].id);
+	EFX_EF10_FILTER_DO_MARK_OLD(table->ucdef_id);
+	EFX_EF10_FILTER_DO_MARK_OLD(table->bcast_id);
+	EFX_EF10_FILTER_DO_MARK_OLD(table->mcdef_id);
 	spin_unlock_bh(&efx->filter_lock);
 }
+#undef EFX_EF10_FILTER_DO_MARK_OLD
 
 static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct net_device *net_dev = efx->net_dev;
 	struct netdev_hw_addr *uc;
+	int addr_count;
 	unsigned int i;
 
-	if (net_dev->flags & IFF_PROMISC ||
-	    netdev_uc_count(net_dev) >= EFX_EF10_FILTER_DEV_UC_MAX) {
+	table->ucdef_id = EFX_EF10_FILTER_ID_INVALID;
+	addr_count = netdev_uc_count(net_dev);
+	if (net_dev->flags & IFF_PROMISC)
 		*promisc = true;
-	}
-	table->dev_uc_count = 1 + netdev_uc_count(net_dev);
+	table->dev_uc_count = 1 + addr_count;
 	ether_addr_copy(table->dev_uc_list[0].addr, net_dev->dev_addr);
 	i = 1;
 	netdev_for_each_uc_addr(uc, net_dev) {
+		if (i >= EFX_EF10_FILTER_DEV_UC_MAX) {
+			*promisc = true;
+			break;
+		}
 		ether_addr_copy(table->dev_uc_list[i].addr, uc->addr);
+		table->dev_uc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
 		i++;
 	}
 }
@@ -3792,65 +3826,51 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx, bool *promisc)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct net_device *net_dev = efx->net_dev;
 	struct netdev_hw_addr *mc;
 	unsigned int i, addr_count;
 
+	table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
+	table->bcast_id = EFX_EF10_FILTER_ID_INVALID;
 	if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
 		*promisc = true;
 
-	if (nic_data->workaround_26807) {
-		if (*promisc) {
-			table->dev_mc_count = 0;
-			return;
-		}
-		addr_count = netdev_mc_count(net_dev);
-	} else {
-		/* Allow room for broadcast and promiscuous */
-		addr_count = netdev_mc_count(net_dev) + 2;
-	}
-
-	if (addr_count >= EFX_EF10_FILTER_DEV_MC_MAX) {
-		if (nic_data->workaround_26807) {
-			table->dev_mc_count = 0;
-		} else {
-			table->dev_mc_count = 1;
-			eth_broadcast_addr(table->dev_mc_list[0].addr);
-		}
-		*promisc = true;
-		return;
-	}
-
-	table->dev_mc_count = 1 + netdev_mc_count(net_dev);
-	eth_broadcast_addr(table->dev_mc_list[0].addr);
-	i = 1;
+	addr_count = netdev_mc_count(net_dev);
+	i = 0;
 	netdev_for_each_mc_addr(mc, net_dev) {
+		if (i >= EFX_EF10_FILTER_DEV_MC_MAX) {
+			*promisc = true;
+			break;
+		}
 		ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
+		table->dev_mc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
 		i++;
 	}
+
+	table->dev_mc_count = i;
 }
 
-static void efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
-					     bool multicast, bool *promisc)
+static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
+					     bool multicast, bool rollback)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_dev_addr *addr_list;
 	struct efx_filter_spec spec;
-	int *addr_count;
-	unsigned int i;
+	u8 baddr[ETH_ALEN];
+	unsigned int i, j;
+	int addr_count;
 	int rc;
 
 	if (multicast) {
 		addr_list = table->dev_mc_list;
-		addr_count = &table->dev_mc_count;
+		addr_count = table->dev_mc_count;
 	} else {
 		addr_list = table->dev_uc_list;
-		addr_count = &table->dev_uc_count;
+		addr_count = table->dev_uc_count;
 	}
 
 	/* Insert/renew filters */
-	for (i = 0; i < *addr_count; i++) {
+	for (i = 0; i < addr_count; i++) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
@@ -3858,46 +3878,113 @@ static void efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 					 addr_list[i].addr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
-			/* Fall back to promiscuous, but leave the broadcast
-			 * filter for multicast
-			 */
-			while (i--) {
-				struct efx_ef10_nic_data *nic_data =
-					efx->nic_data;
-
-				if (multicast && i == 1 &&
-				    !nic_data->workaround_26807)
-					break;
-
-				efx_ef10_filter_remove_safe(
-					efx, EFX_FILTER_PRI_AUTO,
-					addr_list[i].id);
+			if (rollback) {
+				netif_info(efx, drv, efx->net_dev,
+					   "efx_ef10_filter_insert failed rc=%d\n",
+					   rc);
+				/* Fall back to promiscuous */
+				for (j = 0; j < i; j++) {
+					if (addr_list[j].id == EFX_EF10_FILTER_ID_INVALID)
+						continue;
+					efx_ef10_filter_remove_unsafe(
+						efx, EFX_FILTER_PRI_AUTO,
+						addr_list[j].id);
+					addr_list[j].id = EFX_EF10_FILTER_ID_INVALID;
+				}
+				return rc;
+			} else {
+				/* mark as not inserted, and carry on */
+				rc = EFX_EF10_FILTER_ID_INVALID;
 			}
-			*addr_count = i;
-			*promisc = true;
-			break;
 		}
-		addr_list[i].id = rc;
+		addr_list[i].id = efx_ef10_filter_get_unsafe_id(efx, rc);
 	}
 
-	if (*promisc) {
+	if (multicast && rollback) {
+		/* Also need an Ethernet broadcast filter */
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
-
-		if (multicast)
-			efx_filter_set_mc_def(&spec);
-		else
-			efx_filter_set_uc_def(&spec);
-
+		eth_broadcast_addr(baddr);
+		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC, baddr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
-		if (rc < 0)
+		if (rc < 0) {
 			netif_warn(efx, drv, efx->net_dev,
-				   "%scast mismatch filter insert failed.",
-				   multicast ? "Multi" : "Uni");
-		else
-			addr_list[(*addr_count)++].id = rc;
+				   "Broadcast filter insert failed rc=%d\n", rc);
+			/* Fall back to promiscuous */
+			for (j = 0; j < i; j++) {
+				if (addr_list[j].id == EFX_EF10_FILTER_ID_INVALID)
+					continue;
+				efx_ef10_filter_remove_unsafe(
+					efx, EFX_FILTER_PRI_AUTO,
+					addr_list[j].id);
+				addr_list[j].id = EFX_EF10_FILTER_ID_INVALID;
+			}
+			return rc;
+		} else {
+			table->bcast_id = efx_ef10_filter_get_unsafe_id(efx, rc);
+		}
 	}
+
+	return 0;
+}
+
+static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
+				      bool rollback)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_filter_spec spec;
+	u8 baddr[ETH_ALEN];
+	int rc;
+
+	efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
+			   EFX_FILTER_FLAG_RX_RSS,
+			   0);
+
+	if (multicast)
+		efx_filter_set_mc_def(&spec);
+	else
+		efx_filter_set_uc_def(&spec);
+
+	rc = efx_ef10_filter_insert(efx, &spec, true);
+	if (rc < 0) {
+		netif_warn(efx, drv, efx->net_dev,
+			   "%scast mismatch filter insert failed rc=%d\n",
+			   multicast ? "Multi" : "Uni", rc);
+	} else if (multicast) {
+		table->mcdef_id = efx_ef10_filter_get_unsafe_id(efx, rc);
+		if (!nic_data->workaround_26807) {
+			/* Also need an Ethernet broadcast filter */
+			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
+					   EFX_FILTER_FLAG_RX_RSS,
+					   0);
+			eth_broadcast_addr(baddr);
+			efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
+						 baddr);
+			rc = efx_ef10_filter_insert(efx, &spec, true);
+			if (rc < 0) {
+				netif_warn(efx, drv, efx->net_dev,
+					   "Broadcast filter insert failed rc=%d\n",
+					   rc);
+				if (rollback) {
+					/* Roll back the mc_def filter */
+					efx_ef10_filter_remove_unsafe(
+							efx, EFX_FILTER_PRI_AUTO,
+							table->mcdef_id);
+					table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
+					return rc;
+				}
+			} else {
+				table->bcast_id = efx_ef10_filter_get_unsafe_id(efx, rc);
+			}
+		}
+		rc = 0;
+	} else {
+		table->ucdef_id = rc;
+		rc = 0;
+	}
+	return rc;
 }
 
 /* Remove filters that weren't renewed.  Since nothing else changes the AUTO_OLD
@@ -4014,15 +4101,56 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	efx_ef10_filter_mc_addr_list(efx, &mc_promisc);
 	netif_addr_unlock_bh(net_dev);
 
-	/* Insert/renew filters */
-	efx_ef10_filter_insert_addr_list(efx, false, &uc_promisc);
+	/* Insert/renew unicast filters */
+	if (uc_promisc) {
+		efx_ef10_filter_insert_def(efx, false, false);
+		efx_ef10_filter_insert_addr_list(efx, false, false);
+	} else {
+		/* If any of the filters failed to insert, fall back to
+		 * promiscuous mode - add in the uc_def filter.  But keep
+		 * our individual unicast filters.
+		 */
+		if (efx_ef10_filter_insert_addr_list(efx, false, false))
+			efx_ef10_filter_insert_def(efx, false, false);
+	}
 
+	/* Insert/renew multicast filters */
 	/* If changing promiscuous state with cascaded multicast filters, remove
 	 * old filters first, so that packets are dropped rather than duplicated
 	 */
 	if (nic_data->workaround_26807 && efx->mc_promisc != mc_promisc)
 		efx_ef10_filter_remove_old(efx);
-	efx_ef10_filter_insert_addr_list(efx, true, &mc_promisc);
+	if (mc_promisc) {
+		if (nic_data->workaround_26807) {
+			/* If we failed to insert promiscuous filters, rollback
+			 * and fall back to individual multicast filters
+			 */
+			if (efx_ef10_filter_insert_def(efx, true, true)) {
+				/* Changing promisc state, so remove old filters */
+				efx_ef10_filter_remove_old(efx);
+				efx_ef10_filter_insert_addr_list(efx, true, false);
+			}
+		} else {
+			/* If we failed to insert promiscuous filters, don't
+			 * rollback.  Regardless, also insert the mc_list
+			 */
+			efx_ef10_filter_insert_def(efx, true, false);
+			efx_ef10_filter_insert_addr_list(efx, true, false);
+		}
+	} else {
+		/* If any filters failed to insert, rollback and fall back to
+		 * promiscuous mode - mc_def filter and maybe broadcast.  If
+		 * that fails, roll back again and insert as many of our
+		 * individual multicast filters as we can.
+		 */
+		if (efx_ef10_filter_insert_addr_list(efx, true, true)) {
+			/* Changing promisc state, so remove old filters */
+			if (nic_data->workaround_26807)
+				efx_ef10_filter_remove_old(efx);
+			if (efx_ef10_filter_insert_def(efx, true, true))
+				efx_ef10_filter_insert_addr_list(efx, true, false);
+		}
+	}
 
 	efx_ef10_filter_remove_old(efx);
 	efx->mc_promisc = mc_promisc;
