From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 09/10] sfc: Remove filter table IDs from
 filter functions
Date: Fri, 10 Dec 2010 17:39:17 +0000
Message-ID: <1292002757.11673.23.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27024 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428Ab0LJRjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:39:20 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The separation between filter tables is largely an internal detail
and it may be removed in future hardware.  To prepare for that:

- Merge table ID with filter index to make an opaque filter ID
- Wrap efx_filter_table_clear() with a function that clears filters
  from both RX tables, which is all that the current caller requires

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.h     |    5 ++---
 drivers/net/sfc/ethtool.c |    8 ++------
 drivers/net/sfc/filter.c  |   40 ++++++++++++++++++++++++++++++----------
 drivers/net/sfc/filter.h  |    6 ------
 4 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 10a1bf4..003fdb3 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -74,9 +74,8 @@ extern int efx_filter_insert_filter(struct efx_nic *efx,
 				    bool replace);
 extern int efx_filter_remove_filter(struct efx_nic *efx,
 				    struct efx_filter_spec *spec);
-extern void efx_filter_table_clear(struct efx_nic *efx,
-				   enum efx_filter_table_id table_id,
-				   enum efx_filter_priority priority);
+extern void efx_filter_clear_rx(struct efx_nic *efx,
+				enum efx_filter_priority priority);
 
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index d51a6b1..0f46c1a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -558,12 +558,8 @@ static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
 	if (rc)
 		return rc;
 
-	if (!(data & ETH_FLAG_NTUPLE)) {
-		efx_filter_table_clear(efx, EFX_FILTER_TABLE_RX_IP,
-				       EFX_FILTER_PRI_MANUAL);
-		efx_filter_table_clear(efx, EFX_FILTER_TABLE_RX_MAC,
-				       EFX_FILTER_PRI_MANUAL);
-	}
+	if (!(data & ETH_FLAG_NTUPLE))
+		efx_filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
 
 	return 0;
 }
diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 44500b5..e96e6e8 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -26,6 +26,12 @@
  */
 #define FILTER_CTL_SRCH_MAX 200
 
+enum efx_filter_table_id {
+	EFX_FILTER_TABLE_RX_IP = 0,
+	EFX_FILTER_TABLE_RX_MAC,
+	EFX_FILTER_TABLE_COUNT,
+};
+
 struct efx_filter_table {
 	u32		offset;		/* address of table relative to BAR */
 	unsigned	size;		/* number of entries */
@@ -206,6 +212,14 @@ found:
 	return filter_idx;
 }
 
+/* Construct/deconstruct external filter IDs */
+
+static inline int
+efx_filter_make_id(enum efx_filter_table_id table_id, unsigned index)
+{
+	return table_id << 16 | index;
+}
+
 /**
  * efx_filter_insert_filter - add or replace a filter
  * @efx: NIC in which to insert the filter
@@ -213,7 +227,7 @@ found:
  * @replace: Flag for whether the specified filter may replace a filter
  *	with an identical match expression and equal or lower priority
  *
- * On success, return the filter index within its table.
+ * On success, return the filter ID.
  * On failure, return a negative error code.
  */
 int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
@@ -273,6 +287,7 @@ int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	netif_vdbg(efx, hw, efx->net_dev,
 		   "%s: filter type %d index %d rxq %u set",
 		   __func__, spec->type, filter_idx, spec->dmaq_id);
+	rc = efx_filter_make_id(table_id, filter_idx);
 
 out:
 	spin_unlock_bh(&state->lock);
@@ -340,15 +355,9 @@ out:
 	return rc;
 }
 
-/**
- * efx_filter_table_clear - remove filters from a table by priority
- * @efx: NIC from which to remove the filters
- * @table_id: Table from which to remove the filters
- * @priority: Maximum priority to remove
- */
-void efx_filter_table_clear(struct efx_nic *efx,
-			    enum efx_filter_table_id table_id,
-			    enum efx_filter_priority priority)
+static void efx_filter_table_clear(struct efx_nic *efx,
+				   enum efx_filter_table_id table_id,
+				   enum efx_filter_priority priority)
 {
 	struct efx_filter_state *state = efx->filter_state;
 	struct efx_filter_table *table = &state->table[table_id];
@@ -365,6 +374,17 @@ void efx_filter_table_clear(struct efx_nic *efx,
 	spin_unlock_bh(&state->lock);
 }
 
+/**
+ * efx_filter_clear_rx - remove RX filters by priority
+ * @efx: NIC from which to remove the filters
+ * @priority: Maximum priority to remove
+ */
+void efx_filter_clear_rx(struct efx_nic *efx, enum efx_filter_priority priority)
+{
+	efx_filter_table_clear(efx, EFX_FILTER_TABLE_RX_IP, priority);
+	efx_filter_table_clear(efx, EFX_FILTER_TABLE_RX_MAC, priority);
+}
+
 /* Restore filter stater after reset */
 void efx_restore_filters(struct efx_nic *efx)
 {
diff --git a/drivers/net/sfc/filter.h b/drivers/net/sfc/filter.h
index a53319d..d11e4aa 100644
--- a/drivers/net/sfc/filter.h
+++ b/drivers/net/sfc/filter.h
@@ -12,12 +12,6 @@
 
 #include <linux/types.h>
 
-enum efx_filter_table_id {
-	EFX_FILTER_TABLE_RX_IP = 0,
-	EFX_FILTER_TABLE_RX_MAC,
-	EFX_FILTER_TABLE_COUNT,
-};
-
 /**
  * enum efx_filter_type - type of hardware filter
  * @EFX_FILTER_RX_TCP_FULL: RX, matching TCP/IPv4 4-tuple
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

