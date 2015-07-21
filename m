From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 7/9] sfc: re-factor efx_ef10_filter_sync_rx_mode()
Date: Tue, 21 Jul 2015 15:10:27 +0100
Message-ID: <55AE52D3.7030200@solarflare.com>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:54767 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755196AbbGUOOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:14:18 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

This change is only re-factoring; there are no changes to functionality
 except for a slight elaboration of an error message (on mismatch filter
 insertion failure).

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 217 +++++++++++++++++++++++-----------------
 1 file changed, 126 insertions(+), 91 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 784b46f..1704f71 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -49,6 +49,11 @@ enum {
  */
 #define HUNT_FILTER_TBL_ROWS 8192
 
+struct efx_ef10_dev_addr {
+	u8 addr[ETH_ALEN];
+	u16 id;
+};
+
 struct efx_ef10_filter_table {
 /* The RX match field masks supported by this fw & hw, in order of priority */
 	enum efx_filter_match_flags rx_match_flags[
@@ -69,11 +74,8 @@ struct efx_ef10_filter_table {
 /* Shadow of net_device address lists, guarded by mac_lock */
 #define EFX_EF10_FILTER_DEV_UC_MAX	32
 #define EFX_EF10_FILTER_DEV_MC_MAX	256
-	struct {
-		u8 addr[ETH_ALEN];
-		u16 id;
-	} dev_uc_list[EFX_EF10_FILTER_DEV_UC_MAX],
-	  dev_mc_list[EFX_EF10_FILTER_DEV_MC_MAX];
+	struct efx_ef10_dev_addr dev_uc_list[EFX_EF10_FILTER_DEV_UC_MAX];
+	struct efx_ef10_dev_addr dev_mc_list[EFX_EF10_FILTER_DEV_MC_MAX];
 	int dev_uc_count;		/* negative for PROMISC */
 	int dev_mc_count;		/* negative for PROMISC/ALLMULTI */
 };
@@ -3746,23 +3748,10 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 	kfree(table);
 }
 
-/* Caller must hold efx->filter_sem for read if race against
- * efx_ef10_filter_table_remove() is possible
- */
-static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
+static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	struct net_device *net_dev = efx->net_dev;
-	struct efx_filter_spec spec;
-	bool remove_failed = false;
-	struct netdev_hw_addr *uc;
-	struct netdev_hw_addr *mc;
-	unsigned int filter_idx;
-	int i, rc;
-	bool uc_promisc = false, mc_promisc = false;
-
-	if (!efx_dev_registered(efx))
-		return;
+	unsigned int filter_idx, i;
 
 	if (!table)
 		return;
@@ -3778,29 +3767,40 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
 	}
 	spin_unlock_bh(&efx->filter_lock);
+}
+
+static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct net_device *net_dev = efx->net_dev;
+	struct netdev_hw_addr *uc;
+	unsigned int i;
 
-	/* Copy/convert the address lists; add the primary station
-	 * address and broadcast address
-	 */
-	netif_addr_lock_bh(net_dev);
 	if (net_dev->flags & IFF_PROMISC ||
 	    netdev_uc_count(net_dev) >= EFX_EF10_FILTER_DEV_UC_MAX) {
-		table->dev_uc_count = 0;
-		uc_promisc = true;
-	} else {
-		table->dev_uc_count = 1 + netdev_uc_count(net_dev);
-		ether_addr_copy(table->dev_uc_list[0].addr, net_dev->dev_addr);
-		i = 1;
-		netdev_for_each_uc_addr(uc, net_dev) {
-			ether_addr_copy(table->dev_uc_list[i].addr, uc->addr);
-			i++;
-		}
+		*promisc = true;
 	}
+	table->dev_uc_count = 1 + netdev_uc_count(net_dev);
+	ether_addr_copy(table->dev_uc_list[0].addr, net_dev->dev_addr);
+	i = 1;
+	netdev_for_each_uc_addr(uc, net_dev) {
+		ether_addr_copy(table->dev_uc_list[i].addr, uc->addr);
+		i++;
+	}
+}
+
+static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx, bool *promisc)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct net_device *net_dev = efx->net_dev;
+	struct netdev_hw_addr *mc;
+	unsigned int i;
+
 	if (netdev_mc_count(net_dev) + 2 /* room for broadcast and promisc */
-			>= EFX_EF10_FILTER_DEV_MC_MAX) {
+	    >= EFX_EF10_FILTER_DEV_MC_MAX) {
 		table->dev_mc_count = 1;
 		eth_broadcast_addr(table->dev_mc_list[0].addr);
-		mc_promisc = true;
+		*promisc = true;
 	} else {
 		table->dev_mc_count = 1 + netdev_mc_count(net_dev);
 		eth_broadcast_addr(table->dev_mc_list[0].addr);
@@ -3809,84 +3809,87 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 			ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
 			i++;
 		}
+
 		if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
-			mc_promisc = true;
+			*promisc = true;
 	}
-	netif_addr_unlock_bh(net_dev);
+}
 
-	/* Insert/renew unicast filters */
-	for (i = 0; i < table->dev_uc_count; i++) {
-		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-				   EFX_FILTER_FLAG_RX_RSS,
-				   0);
-		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-					 table->dev_uc_list[i].addr);
-		rc = efx_ef10_filter_insert(efx, &spec, true);
-		if (rc < 0) {
-			/* Fall back to unicast-promisc */
-			while (i--)
-				efx_ef10_filter_remove_safe(
-					efx, EFX_FILTER_PRI_AUTO,
-					table->dev_uc_list[i].id);
-			table->dev_uc_count = 0;
-			uc_promisc = true;
-			break;
-		}
-		table->dev_uc_list[i].id = rc;
-	}
-	if (uc_promisc) {
-		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-				   EFX_FILTER_FLAG_RX_RSS,
-				   0);
-		efx_filter_set_uc_def(&spec);
-		rc = efx_ef10_filter_insert(efx, &spec, true);
-		if (rc < 0) {
-			WARN_ON(1);
-		} else {
-			table->dev_uc_list[table->dev_uc_count++].id = rc;
-		}
+static void efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
+					     bool multicast, bool *promisc)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_dev_addr *addr_list;
+	struct efx_filter_spec spec;
+	int *addr_count;
+	unsigned int i;
+	int rc;
+
+	if (multicast) {
+		addr_list = table->dev_mc_list;
+		addr_count = &table->dev_mc_count;
+	} else {
+		addr_list = table->dev_uc_list;
+		addr_count = &table->dev_uc_count;
 	}
 
-	/* Insert/renew multicast filters */
-	for (i = 0; i < table->dev_mc_count; i++) {
+	/* Insert/renew filters */
+	for (i = 0; i < *addr_count; i++) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
 		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-					 table->dev_mc_list[i].addr);
+					 addr_list[i].addr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
-			/* Fall back to multicast-promisc.
-			 * Leave the broadcast filter.
+			/* Fall back to promiscuous, but leave the broadcast
+			 * filter for multicast
 			 */
-			while (i > 1)
+			while (i--) {
+				if (multicast && i == 1)
+					break;
+
 				efx_ef10_filter_remove_safe(
 					efx, EFX_FILTER_PRI_AUTO,
-					table->dev_mc_list[--i].id);
-			table->dev_mc_count = i;
-			mc_promisc = true;
+					addr_list[i].id);
+			}
+			*addr_count = i;
+			*promisc = true;
 			break;
 		}
-		table->dev_mc_list[i].id = rc;
+		addr_list[i].id = rc;
 	}
-	if (mc_promisc) {
+
+	if (*promisc) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
-		efx_filter_set_mc_def(&spec);
+
+		if (multicast)
+			efx_filter_set_mc_def(&spec);
+		else
+			efx_filter_set_uc_def(&spec);
+
 		rc = efx_ef10_filter_insert(efx, &spec, true);
-		if (rc < 0) {
-			WARN_ON(1);
-		} else {
-			table->dev_mc_list[table->dev_mc_count++].id = rc;
-		}
+		if (rc < 0)
+			netif_warn(efx, drv, efx->net_dev,
+				   "%scast mismatch filter insert failed.",
+				   multicast ? "Multi" : "Uni");
+		else
+			addr_list[(*addr_count)++].id = rc;
 	}
+}
+
+/* Remove filters that weren't renewed.  Since nothing else changes the AUTO_OLD
+ * flag or removes these filters, we don't need to hold the filter_lock while
+ * scanning for these filters.
+ */
+static void efx_ef10_filter_remove_old(struct efx_nic *efx)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	bool remove_failed = false;
+	int i;
 
-	/* Remove filters that weren't renewed.  Since nothing else
-	 * changes the AUTO_OLD flag or removes these filters, we
-	 * don't need to hold the filter_lock while scanning for
-	 * these filters.
-	 */
 	for (i = 0; i < HUNT_FILTER_TBL_ROWS; i++) {
 		if (ACCESS_ONCE(table->entry[i].spec) &
 		    EFX_EF10_FILTER_FLAG_AUTO_OLD) {
@@ -3965,6 +3968,38 @@ reset_nic:
 	return rc ? rc : rc2;
 }
 
+/* Caller must hold efx->filter_sem for read if race against
+ * efx_ef10_filter_table_remove() is possible
+ */
+static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct net_device *net_dev = efx->net_dev;
+	bool uc_promisc = false, mc_promisc = false;
+
+	if (!efx_dev_registered(efx))
+		return;
+
+	if (!table)
+		return;
+
+	efx_ef10_filter_mark_old(efx);
+
+	/* Copy/convert the address lists; add the primary station
+	 * address and broadcast address
+	 */
+	netif_addr_lock_bh(net_dev);
+	efx_ef10_filter_uc_addr_list(efx, &uc_promisc);
+	efx_ef10_filter_mc_addr_list(efx, &mc_promisc);
+	netif_addr_unlock_bh(net_dev);
+
+	/* Insert/renew filters */
+	efx_ef10_filter_insert_addr_list(efx, false, &uc_promisc);
+	efx_ef10_filter_insert_addr_list(efx, true, &mc_promisc);
+
+	efx_ef10_filter_remove_old(efx);
+}
+
 static int efx_ef10_set_mac_address(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_SET_MAC_IN_LEN);
