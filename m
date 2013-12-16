From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/11] sfc: Don't refer to 'stack' in filter
 implementation
Date: Mon, 16 Dec 2013 21:32:45 +0000
Message-ID: <1387229565.1799.47.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8609 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab3LPVcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:32:48 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change all the 'stack' naming to 'auto' (or other meaningful term);
the device address list is based on more than just what the network
stack wants, and the no-match filters aren't really what the stack
wants at all.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c  | 104 +++++++++++++++++++--------------------
 drivers/net/ethernet/sfc/farch.c |   8 +--
 2 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e5eeac9063d2..2adc8e45461b 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -53,25 +53,25 @@ struct efx_ef10_filter_table {
 
 	struct {
 		unsigned long spec;	/* pointer to spec plus flag bits */
-/* BUSY flag indicates that an update is in progress.  STACK_OLD is
- * used to mark and sweep stack-owned MAC filters.
+/* BUSY flag indicates that an update is in progress.  AUTO_OLD is
+ * used to mark and sweep MAC filters for the device address lists.
  */
 #define EFX_EF10_FILTER_FLAG_BUSY	1UL
-#define EFX_EF10_FILTER_FLAG_STACK_OLD	2UL
+#define EFX_EF10_FILTER_FLAG_AUTO_OLD	2UL
 #define EFX_EF10_FILTER_FLAGS		3UL
 		u64 handle;		/* firmware handle */
 	} *entry;
 	wait_queue_head_t waitq;
 /* Shadow of net_device address lists, guarded by mac_lock */
-#define EFX_EF10_FILTER_STACK_UC_MAX	32
-#define EFX_EF10_FILTER_STACK_MC_MAX	256
+#define EFX_EF10_FILTER_DEV_UC_MAX	32
+#define EFX_EF10_FILTER_DEV_MC_MAX	256
 	struct {
 		u8 addr[ETH_ALEN];
 		u16 id;
-	} stack_uc_list[EFX_EF10_FILTER_STACK_UC_MAX],
-	  stack_mc_list[EFX_EF10_FILTER_STACK_MC_MAX];
-	int stack_uc_count;		/* negative for PROMISC */
-	int stack_mc_count;		/* negative for PROMISC/ALLMULTI */
+	} dev_uc_list[EFX_EF10_FILTER_DEV_UC_MAX],
+	  dev_mc_list[EFX_EF10_FILTER_DEV_MC_MAX];
+	int dev_uc_count;		/* negative for PROMISC */
+	int dev_mc_count;		/* negative for PROMISC/ALLMULTI */
 };
 
 /* An arbitrary search limit for the software hash table */
@@ -2401,7 +2401,7 @@ found:
 			if (saved_spec->priority > EFX_FILTER_PRI_AUTO)
 				saved_spec->flags |= EFX_FILTER_FLAG_RX_OVER_AUTO;
 			table->entry[ins_index].spec &=
-				~EFX_EF10_FILTER_FLAG_STACK_OLD;
+				~EFX_EF10_FILTER_FLAG_AUTO_OLD;
 			rc = ins_index;
 			goto out_unlock;
 		}
@@ -2514,13 +2514,13 @@ static void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
 }
 
 /* Remove a filter.
- * If !stack_requested, remove by ID
- * If stack_requested, remove by index
+ * If !by_index, remove by ID
+ * If by_index, remove by index
  * Filter ID may come from userland and must be range-checked.
  */
 static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 					   enum efx_filter_priority priority,
-					   u32 filter_id, bool stack_requested)
+					   u32 filter_id, bool by_index)
 {
 	unsigned int filter_idx = filter_id % HUNT_FILTER_TBL_ROWS;
 	struct efx_ef10_filter_table *table = efx->filter_state;
@@ -2547,7 +2547,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 
 	spec = efx_ef10_filter_entry_spec(table, filter_idx);
 	if (!spec ||
-	    (!stack_requested &&
+	    (!by_index &&
 	     efx_ef10_filter_rx_match_pri(table, spec->match_flags) !=
 	     filter_id / HUNT_FILTER_TBL_ROWS)) {
 		rc = -ENOENT;
@@ -2558,7 +2558,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 	    priority == EFX_FILTER_PRI_AUTO) {
 		/* Just remove flags */
 		spec->flags &= ~EFX_FILTER_FLAG_RX_OVER_AUTO;
-		table->entry[filter_idx].spec &= ~EFX_EF10_FILTER_FLAG_STACK_OLD;
+		table->entry[filter_idx].spec &= ~EFX_EF10_FILTER_FLAG_AUTO_OLD;
 		rc = 0;
 		goto out_unlock;
 	}
@@ -2572,7 +2572,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 	spin_unlock_bh(&efx->filter_lock);
 
 	if (spec->flags & EFX_FILTER_FLAG_RX_OVER_AUTO) {
-		/* Reset steering of a stack-owned filter */
+		/* Reset to an automatic filter */
 
 		struct efx_filter_spec new_spec = *spec;
 
@@ -3086,15 +3086,15 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 
 	/* Mark old filters that may need to be removed */
 	spin_lock_bh(&efx->filter_lock);
-	n = table->stack_uc_count < 0 ? 1 : table->stack_uc_count;
+	n = table->dev_uc_count < 0 ? 1 : table->dev_uc_count;
 	for (i = 0; i < n; i++) {
-		filter_idx = table->stack_uc_list[i].id % HUNT_FILTER_TBL_ROWS;
-		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_STACK_OLD;
+		filter_idx = table->dev_uc_list[i].id % HUNT_FILTER_TBL_ROWS;
+		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
 	}
-	n = table->stack_mc_count < 0 ? 1 : table->stack_mc_count;
+	n = table->dev_mc_count < 0 ? 1 : table->dev_mc_count;
 	for (i = 0; i < n; i++) {
-		filter_idx = table->stack_mc_list[i].id % HUNT_FILTER_TBL_ROWS;
-		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_STACK_OLD;
+		filter_idx = table->dev_mc_list[i].id % HUNT_FILTER_TBL_ROWS;
+		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
 	}
 	spin_unlock_bh(&efx->filter_lock);
 
@@ -3103,28 +3103,28 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	 */
 	netif_addr_lock_bh(net_dev);
 	if (net_dev->flags & IFF_PROMISC ||
-	    netdev_uc_count(net_dev) >= EFX_EF10_FILTER_STACK_UC_MAX) {
-		table->stack_uc_count = -1;
+	    netdev_uc_count(net_dev) >= EFX_EF10_FILTER_DEV_UC_MAX) {
+		table->dev_uc_count = -1;
 	} else {
-		table->stack_uc_count = 1 + netdev_uc_count(net_dev);
-		memcpy(table->stack_uc_list[0].addr, net_dev->dev_addr,
+		table->dev_uc_count = 1 + netdev_uc_count(net_dev);
+		memcpy(table->dev_uc_list[0].addr, net_dev->dev_addr,
 		       ETH_ALEN);
 		i = 1;
 		netdev_for_each_uc_addr(uc, net_dev) {
-			memcpy(table->stack_uc_list[i].addr,
+			memcpy(table->dev_uc_list[i].addr,
 			       uc->addr, ETH_ALEN);
 			i++;
 		}
 	}
 	if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI) ||
-	    netdev_mc_count(net_dev) >= EFX_EF10_FILTER_STACK_MC_MAX) {
-		table->stack_mc_count = -1;
+	    netdev_mc_count(net_dev) >= EFX_EF10_FILTER_DEV_MC_MAX) {
+		table->dev_mc_count = -1;
 	} else {
-		table->stack_mc_count = 1 + netdev_mc_count(net_dev);
-		eth_broadcast_addr(table->stack_mc_list[0].addr);
+		table->dev_mc_count = 1 + netdev_mc_count(net_dev);
+		eth_broadcast_addr(table->dev_mc_list[0].addr);
 		i = 1;
 		netdev_for_each_mc_addr(mc, net_dev) {
-			memcpy(table->stack_mc_list[i].addr,
+			memcpy(table->dev_mc_list[i].addr,
 			       mc->addr, ETH_ALEN);
 			i++;
 		}
@@ -3132,27 +3132,27 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	netif_addr_unlock_bh(net_dev);
 
 	/* Insert/renew unicast filters */
-	if (table->stack_uc_count >= 0) {
-		for (i = 0; i < table->stack_uc_count; i++) {
+	if (table->dev_uc_count >= 0) {
+		for (i = 0; i < table->dev_uc_count; i++) {
 			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 					   EFX_FILTER_FLAG_RX_RSS,
 					   0);
 			efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-						 table->stack_uc_list[i].addr);
+						 table->dev_uc_list[i].addr);
 			rc = efx_ef10_filter_insert(efx, &spec, true);
 			if (rc < 0) {
 				/* Fall back to unicast-promisc */
 				while (i--)
 					efx_ef10_filter_remove_safe(
 						efx, EFX_FILTER_PRI_AUTO,
-						table->stack_uc_list[i].id);
-				table->stack_uc_count = -1;
+						table->dev_uc_list[i].id);
+				table->dev_uc_count = -1;
 				break;
 			}
-			table->stack_uc_list[i].id = rc;
+			table->dev_uc_list[i].id = rc;
 		}
 	}
-	if (table->stack_uc_count < 0) {
+	if (table->dev_uc_count < 0) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
@@ -3160,34 +3160,34 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
 			WARN_ON(1);
-			table->stack_uc_count = 0;
+			table->dev_uc_count = 0;
 		} else {
-			table->stack_uc_list[0].id = rc;
+			table->dev_uc_list[0].id = rc;
 		}
 	}
 
 	/* Insert/renew multicast filters */
-	if (table->stack_mc_count >= 0) {
-		for (i = 0; i < table->stack_mc_count; i++) {
+	if (table->dev_mc_count >= 0) {
+		for (i = 0; i < table->dev_mc_count; i++) {
 			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 					   EFX_FILTER_FLAG_RX_RSS,
 					   0);
 			efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-						 table->stack_mc_list[i].addr);
+						 table->dev_mc_list[i].addr);
 			rc = efx_ef10_filter_insert(efx, &spec, true);
 			if (rc < 0) {
 				/* Fall back to multicast-promisc */
 				while (i--)
 					efx_ef10_filter_remove_safe(
 						efx, EFX_FILTER_PRI_AUTO,
-						table->stack_mc_list[i].id);
-				table->stack_mc_count = -1;
+						table->dev_mc_list[i].id);
+				table->dev_mc_count = -1;
 				break;
 			}
-			table->stack_mc_list[i].id = rc;
+			table->dev_mc_list[i].id = rc;
 		}
 	}
-	if (table->stack_mc_count < 0) {
+	if (table->dev_mc_count < 0) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 				   EFX_FILTER_FLAG_RX_RSS,
 				   0);
@@ -3195,20 +3195,20 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
 			WARN_ON(1);
-			table->stack_mc_count = 0;
+			table->dev_mc_count = 0;
 		} else {
-			table->stack_mc_list[0].id = rc;
+			table->dev_mc_list[0].id = rc;
 		}
 	}
 
 	/* Remove filters that weren't renewed.  Since nothing else
-	 * changes the STACK_OLD flag or removes these filters, we
+	 * changes the AUTO_OLD flag or removes these filters, we
 	 * don't need to hold the filter_lock while scanning for
 	 * these filters.
 	 */
 	for (i = 0; i < HUNT_FILTER_TBL_ROWS; i++) {
 		if (ACCESS_ONCE(table->entry[i].spec) &
-		    EFX_EF10_FILTER_FLAG_STACK_OLD) {
+		    EFX_EF10_FILTER_FLAG_AUTO_OLD) {
 			if (efx_ef10_filter_remove_internal(
 				    efx, EFX_FILTER_PRI_AUTO, i, true) < 0)
 				remove_failed = true;
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index fbd923ddf546..378d6b968c4c 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -2184,8 +2184,8 @@ efx_farch_filter_to_gen_spec(struct efx_filter_spec *gen_spec,
 }
 
 static void
-efx_farch_filter_init_rx_for_stack(struct efx_nic *efx,
-				   struct efx_farch_filter_spec *spec)
+efx_farch_filter_init_rx_auto(struct efx_nic *efx,
+			      struct efx_farch_filter_spec *spec)
 {
 	/* If there's only one channel then disable RSS for non VF
 	 * traffic, thereby allowing VFs to use RSS when the PF can't.
@@ -2547,7 +2547,7 @@ static int efx_farch_filter_remove(struct efx_nic *efx,
 		return -ENOENT;
 
 	if (spec->flags & EFX_FILTER_FLAG_RX_OVER_AUTO) {
-		efx_farch_filter_init_rx_for_stack(efx, spec);
+		efx_farch_filter_init_rx_auto(efx, spec);
 		efx_farch_filter_push_rx_config(efx);
 	} else {
 		efx_farch_filter_table_clear_entry(efx, table, filter_idx);
@@ -2815,7 +2815,7 @@ int efx_farch_filter_table_probe(struct efx_nic *efx)
 		for (i = 0; i < EFX_FARCH_FILTER_SIZE_RX_DEF; i++) {
 			spec = &table->spec[i];
 			spec->type = EFX_FARCH_FILTER_UC_DEF + i;
-			efx_farch_filter_init_rx_for_stack(efx, spec);
+			efx_farch_filter_init_rx_auto(efx, spec);
 			__set_bit(i, table->used_bitmap);
 		}
 	}


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
