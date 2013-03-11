From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/22] sfc: Fix replacement detection in
 efx_filter_insert_filter()
Date: Mon, 11 Mar 2013 19:55:11 +0000
Message-ID: <1363031711.2608.46.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16759 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab3CKTzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:55:14 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_filter_insert_filter() uses the first table entry in the hash chain
that either has the same match values or is empty.  This means that
replacement doesn't always work correctly:

1. Insert filter F1 with match values M1, hashing to H1, at first
   possible entry E1.
2. Insert filter F2 with match values M2, hashing to H1, at second
   possible entry E2.
3. Remove filter F1.
4. Insert filter F3 with match values M2, hashing to H1, at first
   possible entry E1.

F3 should have either replaced F2 or been rejected (depending on
priority and the replace_equal parameter).

Instead, search for both a matching filter that the inserted filter
would replace, and an available insertion point, up to the applicable
maximum search depths.  If we insert at lower depth than a replaced
filter, clear the replaced filter.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   89 +++++++++++++++++++++++++++----------
 1 files changed, 66 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 769560a..0de8daf 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -66,6 +66,10 @@ struct efx_filter_state {
 #endif
 };
 
+static void efx_filter_table_clear_entry(struct efx_nic *efx,
+					 struct efx_filter_table *table,
+					 unsigned int filter_idx);
+
 /* The filter hash function is LFSR polynomial x^16 + x^3 + 1 of a 32-bit
  * key derived from the n-tuple.  The initial LFSR state is 0xffff. */
 static u16 efx_filter_hash(u32 key)
@@ -626,9 +630,9 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 {
 	struct efx_filter_state *state = efx->filter_state;
 	struct efx_filter_table *table = efx_filter_spec_table(state, spec);
-	struct efx_filter_spec *saved_spec;
 	efx_oword_t filter;
-	unsigned int filter_idx, depth = 0;
+	int rep_index, ins_index;
+	unsigned int depth = 0;
 	int rc;
 
 	if (!table || table->size == 0)
@@ -643,44 +647,74 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 		BUILD_BUG_ON(EFX_FILTER_INDEX_UC_DEF != 0);
 		BUILD_BUG_ON(EFX_FILTER_INDEX_MC_DEF !=
 			     EFX_FILTER_MC_DEF - EFX_FILTER_UC_DEF);
-		filter_idx = spec->type - EFX_FILTER_INDEX_UC_DEF;
+		rep_index = spec->type - EFX_FILTER_INDEX_UC_DEF;
+		ins_index = rep_index;
 
 		spin_lock_bh(&state->lock);
 	} else {
+		/* Search concurrently for
+		 * (1) a filter to be replaced (rep_index): any filter
+		 *     with the same match values, up to the current
+		 *     search depth for this type, and
+		 * (2) the insertion point (ins_index): (1) or any
+		 *     free slot before it or up to the maximum search
+		 *     depth for this priority
+		 * We fail if we cannot find (2).
+		 *
+		 * We can stop once either
+		 * (a) we find (1), in which case we have definitely
+		 *     found (2) as well; or
+		 * (b) we have searched exhaustively for (1), and have
+		 *     either found (2) or searched exhaustively for it
+		 */
 		u32 key = efx_filter_build(&filter, spec);
 		unsigned int hash = efx_filter_hash(key);
 		unsigned int incr = efx_filter_increment(key);
-		unsigned int depth_max =
+		unsigned int max_rep_depth = table->search_depth[spec->type];
+		unsigned int max_ins_depth =
 			spec->priority <= EFX_FILTER_PRI_HINT ?
 			FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX;
+		unsigned int i = hash & (table->size - 1);
 
-		filter_idx = hash & (table->size - 1);
+		ins_index = -1;
 		depth = 1;
 
 		spin_lock_bh(&state->lock);
 
 		for (;;) {
-			if (!test_bit(filter_idx, table->used_bitmap) ||
-			    efx_filter_equal(spec, &table->spec[filter_idx]))
+			if (!test_bit(i, table->used_bitmap)) {
+				if (ins_index < 0)
+					ins_index = i;
+			} else if (efx_filter_equal(spec, &table->spec[i])) {
+				/* Case (a) */
+				if (ins_index < 0)
+					ins_index = i;
+				rep_index = i;
 				break;
+			}
 
-			/* Return failure if we reached the maximum search
-			 * depth
-			 */
-			if (depth == depth_max) {
-				rc = -EBUSY;
-				goto out;
+			if (depth >= max_rep_depth &&
+			    (ins_index >= 0 || depth >= max_ins_depth)) {
+				/* Case (b) */
+				if (ins_index < 0) {
+					rc = -EBUSY;
+					goto out;
+				}
+				rep_index = -1;
+				break;
 			}
 
-			filter_idx = (filter_idx + incr) & (table->size - 1);
+			i = (i + incr) & (table->size - 1);
 			++depth;
 		}
 	}
 
-	saved_spec = &table->spec[filter_idx];
+	/* If we found a filter to be replaced, check whether we
+	 * should do so
+	 */
+	if (rep_index >= 0) {
+		struct efx_filter_spec *saved_spec = &table->spec[rep_index];
 
-	if (test_bit(filter_idx, table->used_bitmap)) {
-		/* Should we replace the existing filter? */
 		if (spec->priority == saved_spec->priority && !replace_equal) {
 			rc = -EEXIST;
 			goto out;
@@ -689,11 +723,14 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 			rc = -EPERM;
 			goto out;
 		}
-	} else {
-		__set_bit(filter_idx, table->used_bitmap);
+	}
+
+	/* Insert the filter */
+	if (ins_index != rep_index) {
+		__set_bit(ins_index, table->used_bitmap);
 		++table->used;
 	}
-	*saved_spec = *spec;
+	table->spec[ins_index] = *spec;
 
 	if (table->id == EFX_FILTER_TABLE_RX_DEF) {
 		efx_filter_push_rx_config(efx);
@@ -707,13 +744,19 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 		}
 
 		efx_writeo(efx, &filter,
-			   table->offset + table->step * filter_idx);
+			   table->offset + table->step * ins_index);
+
+		/* If we were able to replace a filter by inserting
+		 * at a lower depth, clear the replaced filter
+		 */
+		if (ins_index != rep_index && rep_index >= 0)
+			efx_filter_table_clear_entry(efx, table, rep_index);
 	}
 
 	netif_vdbg(efx, hw, efx->net_dev,
 		   "%s: filter type %d index %d rxq %u set",
-		   __func__, spec->type, filter_idx, spec->dmaq_id);
-	rc = efx_filter_make_id(spec, filter_idx);
+		   __func__, spec->type, ins_index, spec->dmaq_id);
+	rc = efx_filter_make_id(spec, ins_index);
 
 out:
 	spin_unlock_bh(&state->lock);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
