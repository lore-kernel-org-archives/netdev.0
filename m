From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/11] sfc: Implement efx_nic_type::filter_clear_rx
 operation for EF10
Date: Mon, 16 Dec 2013 21:33:19 +0000
Message-ID: <1387229599.1799.49.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8635 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059Ab3LPVdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:33:23 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The operation can now fail, so change its return type to int.

Remove the inline wrapper while we're changing the signature.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 30 +++++++++++++++++++++++-------
 drivers/net/ethernet/sfc/efx.c        |  2 +-
 drivers/net/ethernet/sfc/efx.h        | 14 --------------
 drivers/net/ethernet/sfc/farch.c      |  3 ++-
 drivers/net/ethernet/sfc/net_driver.h |  7 ++++---
 drivers/net/ethernet/sfc/nic.h        |  4 ++--
 6 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 155602c500d5..b6a0c2133b8a 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2519,7 +2519,7 @@ static void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
  * Filter ID may come from userland and must be range-checked.
  */
 static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
-					   enum efx_filter_priority priority,
+					   unsigned int priority_mask,
 					   u32 filter_id, bool by_index)
 {
 	unsigned int filter_idx = filter_id % HUNT_FILTER_TBL_ROWS;
@@ -2555,7 +2555,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 	}
 
 	if (spec->flags & EFX_FILTER_FLAG_RX_OVER_AUTO &&
-	    priority == EFX_FILTER_PRI_AUTO) {
+	    priority_mask == (1U << EFX_FILTER_PRI_AUTO)) {
 		/* Just remove flags */
 		spec->flags &= ~EFX_FILTER_FLAG_RX_OVER_AUTO;
 		table->entry[filter_idx].spec &= ~EFX_EF10_FILTER_FLAG_AUTO_OLD;
@@ -2563,7 +2563,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 		goto out_unlock;
 	}
 
-	if (spec->priority != priority) {
+	if (!(priority_mask & (1U << spec->priority))) {
 		rc = -ENOENT;
 		goto out_unlock;
 	}
@@ -2619,7 +2619,8 @@ static int efx_ef10_filter_remove_safe(struct efx_nic *efx,
 				       enum efx_filter_priority priority,
 				       u32 filter_id)
 {
-	return efx_ef10_filter_remove_internal(efx, priority, filter_id, false);
+	return efx_ef10_filter_remove_internal(efx, 1U << priority,
+					       filter_id, false);
 }
 
 static int efx_ef10_filter_get_safe(struct efx_nic *efx,
@@ -2645,10 +2646,24 @@ static int efx_ef10_filter_get_safe(struct efx_nic *efx,
 	return rc;
 }
 
-static void efx_ef10_filter_clear_rx(struct efx_nic *efx,
+static int efx_ef10_filter_clear_rx(struct efx_nic *efx,
 				     enum efx_filter_priority priority)
 {
-	/* TODO */
+	unsigned int priority_mask;
+	unsigned int i;
+	int rc;
+
+	priority_mask = (((1U << (priority + 1)) - 1) &
+			 ~(1U << EFX_FILTER_PRI_AUTO));
+
+	for (i = 0; i < HUNT_FILTER_TBL_ROWS; i++) {
+		rc = efx_ef10_filter_remove_internal(efx, priority_mask,
+						     i, true);
+		if (rc && rc != -ENOENT)
+			return rc;
+	}
+
+	return 0;
 }
 
 static u32 efx_ef10_filter_count_rx_used(struct efx_nic *efx,
@@ -3210,7 +3225,8 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		if (ACCESS_ONCE(table->entry[i].spec) &
 		    EFX_EF10_FILTER_FLAG_AUTO_OLD) {
 			if (efx_ef10_filter_remove_internal(
-				    efx, EFX_FILTER_PRI_AUTO, i, true) < 0)
+				    efx, 1U << EFX_FILTER_PRI_AUTO,
+				    i, true) < 0)
 				remove_failed = true;
 		}
 	}
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index d6a927021523..ff0d9c624560 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2151,7 +2151,7 @@ static int efx_set_features(struct net_device *net_dev, netdev_features_t data)
 
 	/* If disabling RX n-tuple filtering, clear existing filters */
 	if (net_dev->features & ~data & NETIF_F_NTUPLE)
-		efx_filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
+		return efx->type->filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 3a67030c73ea..601224736b9b 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -134,20 +134,6 @@ efx_filter_get_filter_safe(struct efx_nic *efx,
 	return efx->type->filter_get_safe(efx, priority, filter_id, spec);
 }
 
-/**
- * efx_farch_filter_clear_rx - remove RX filters by priority
- * @efx: NIC from which to remove the filters
- * @priority: Maximum priority to remove
- *
- * Remove all RX filters whose priority is less than or equal to the
- * given @priority and is not %EFX_FILTER_PRI_AUTO.
- */
-static inline void efx_filter_clear_rx(struct efx_nic *efx,
-				       enum efx_filter_priority priority)
-{
-	return efx->type->filter_clear_rx(efx, priority);
-}
-
 static inline u32 efx_filter_count_rx_used(struct efx_nic *efx,
 					   enum efx_filter_priority priority)
 {
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index eed0741c2497..f72489a105ca 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -2638,7 +2638,7 @@ efx_farch_filter_table_clear(struct efx_nic *efx,
 	spin_unlock_bh(&efx->filter_lock);
 }
 
-void efx_farch_filter_clear_rx(struct efx_nic *efx,
+int efx_farch_filter_clear_rx(struct efx_nic *efx,
 			       enum efx_filter_priority priority)
 {
 	efx_farch_filter_table_clear(efx, EFX_FARCH_FILTER_TABLE_RX_IP,
@@ -2647,6 +2647,7 @@ void efx_farch_filter_clear_rx(struct efx_nic *efx,
 				     priority);
 	efx_farch_filter_table_clear(efx, EFX_FARCH_FILTER_TABLE_RX_DEF,
 				     priority);
+	return 0;
 }
 
 u32 efx_farch_filter_count_rx_used(struct efx_nic *efx,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 1b3c4e5207c5..a0de5c50a0e7 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1044,7 +1044,8 @@ struct efx_mtd_partition {
  * @filter_insert: add or replace a filter
  * @filter_remove_safe: remove a filter by ID, carefully
  * @filter_get_safe: retrieve a filter by ID, carefully
- * @filter_clear_rx: remove RX filters by priority
+ * @filter_clear_rx: Remove all RX filters whose priority is less than or
+ *	equal to the given priority and is not %EFX_FILTER_PRI_AUTO
  * @filter_count_rx_used: Get the number of filters in use at a given priority
  * @filter_get_rx_id_limit: Get maximum value of a filter id, plus 1
  * @filter_get_rx_ids: Get list of RX filters at a given priority
@@ -1166,8 +1167,8 @@ struct efx_nic_type {
 	int (*filter_get_safe)(struct efx_nic *efx,
 			       enum efx_filter_priority priority,
 			       u32 filter_id, struct efx_filter_spec *);
-	void (*filter_clear_rx)(struct efx_nic *efx,
-				enum efx_filter_priority priority);
+	int (*filter_clear_rx)(struct efx_nic *efx,
+			       enum efx_filter_priority priority);
 	u32 (*filter_count_rx_used)(struct efx_nic *efx,
 				    enum efx_filter_priority priority);
 	u32 (*filter_get_rx_id_limit)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index c665ff6c8012..e25aaf6bda87 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -693,8 +693,8 @@ int efx_farch_filter_remove_safe(struct efx_nic *efx,
 int efx_farch_filter_get_safe(struct efx_nic *efx,
 			      enum efx_filter_priority priority, u32 filter_id,
 			      struct efx_filter_spec *);
-void efx_farch_filter_clear_rx(struct efx_nic *efx,
-			       enum efx_filter_priority priority);
+int efx_farch_filter_clear_rx(struct efx_nic *efx,
+			      enum efx_filter_priority priority);
 u32 efx_farch_filter_count_rx_used(struct efx_nic *efx,
 				   enum efx_filter_priority priority);
 u32 efx_farch_filter_get_rx_id_limit(struct efx_nic *efx);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
