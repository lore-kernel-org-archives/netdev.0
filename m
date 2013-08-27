From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/16] sfc: Refactor Falcon-arch filter removal
Date: Tue, 27 Aug 2013 21:48:54 +0100
Message-ID: <1377636534.13272.85.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6136 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815Ab3H0Us5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:48:57 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the special case for removal of default filters from
efx_farch_filter_table_clear_entry() into a wrapper function,
efx_farch_filter_table_remove().  Move the existence and priority
checks into the latter and use it where appropriate.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/farch.c | 74 ++++++++++++++++++++++------------------
 1 file changed, 40 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 1941804..d91bced 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -2516,33 +2516,49 @@ efx_farch_filter_table_clear_entry(struct efx_nic *efx,
 {
 	static efx_oword_t filter;
 
+	EFX_WARN_ON_PARANOID(!test_bit(filter_idx, table->used_bitmap));
+
+	__clear_bit(filter_idx, table->used_bitmap);
+	--table->used;
+	memset(&table->spec[filter_idx], 0, sizeof(table->spec[0]));
+
+	efx_writeo(efx, &filter, table->offset + table->step * filter_idx);
+
+	/* If this filter required a greater search depth than
+	 * any other, the search limit for its type can now be
+	 * decreased.  However, it is hard to determine that
+	 * unless the table has become completely empty - in
+	 * which case, all its search limits can be set to 0.
+	 */
+	if (unlikely(table->used == 0)) {
+		memset(table->search_limit, 0, sizeof(table->search_limit));
+		if (table->id == EFX_FARCH_FILTER_TABLE_TX_MAC)
+			efx_farch_filter_push_tx_limits(efx);
+		else
+			efx_farch_filter_push_rx_config(efx);
+	}
+}
+
+static int efx_farch_filter_remove(struct efx_nic *efx,
+				   struct efx_farch_filter_table *table,
+				   unsigned int filter_idx,
+				   enum efx_filter_priority priority)
+{
+	struct efx_farch_filter_spec *spec = &table->spec[filter_idx];
+
+	if (!test_bit(filter_idx, table->used_bitmap) ||
+	    spec->priority > priority)
+		return -ENOENT;
+
 	if (table->id == EFX_FARCH_FILTER_TABLE_RX_DEF) {
 		/* RX default filters must always exist */
 		efx_farch_filter_reset_rx_def(efx, filter_idx);
 		efx_farch_filter_push_rx_config(efx);
-	} else if (test_bit(filter_idx, table->used_bitmap)) {
-		__clear_bit(filter_idx, table->used_bitmap);
-		--table->used;
-		memset(&table->spec[filter_idx], 0, sizeof(table->spec[0]));
-
-		efx_writeo(efx, &filter,
-			   table->offset + table->step * filter_idx);
-
-		/* If this filter required a greater search depth than
-		 * any other, the search limit for its type can now be
-		 * decreased.  However, it is hard to determine that
-		 * unless the table has become completely empty - in
-		 * which case, all its search limits can be set to 0.
-		 */
-		if (unlikely(table->used == 0)) {
-			memset(table->search_limit, 0,
-			       sizeof(table->search_limit));
-			if (table->id == EFX_FARCH_FILTER_TABLE_TX_MAC)
-				efx_farch_filter_push_tx_limits(efx);
-			else
-				efx_farch_filter_push_rx_config(efx);
-		}
+	} else {
+		efx_farch_filter_table_clear_entry(efx, table, filter_idx);
 	}
+
+	return 0;
 }
 
 int efx_farch_filter_remove_safe(struct efx_nic *efx,
@@ -2567,15 +2583,7 @@ int efx_farch_filter_remove_safe(struct efx_nic *efx,
 	spec = &table->spec[filter_idx];
 
 	spin_lock_bh(&efx->filter_lock);
-
-	if (test_bit(filter_idx, table->used_bitmap) &&
-	    spec->priority == priority) {
-		efx_farch_filter_table_clear_entry(efx, table, filter_idx);
-		rc = 0;
-	} else {
-		rc = -ENOENT;
-	}
-
+	rc = efx_farch_filter_remove(efx, table, filter_idx, priority);
 	spin_unlock_bh(&efx->filter_lock);
 
 	return rc;
@@ -2628,9 +2636,7 @@ efx_farch_filter_table_clear(struct efx_nic *efx,
 
 	spin_lock_bh(&efx->filter_lock);
 	for (filter_idx = 0; filter_idx < table->size; ++filter_idx)
-		if (table->spec[filter_idx].priority <= priority)
-			efx_farch_filter_table_clear_entry(efx, table,
-							   filter_idx);
+		efx_farch_filter_remove(efx, table, filter_idx, priority);
 	spin_unlock_bh(&efx->filter_lock);
 }
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
