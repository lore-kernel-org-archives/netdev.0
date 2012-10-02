From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 6/6] sfc: Fix the reported priorities of different
 filter types
Date: Tue, 2 Oct 2012 02:28:47 +0100
Message-ID: <1349141327.2577.79.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17217 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750897Ab2JBB2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:28:50 -0400
In-Reply-To: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each RX filter table contains filters with two different levels of
specificity: TCP/IPv4 and UDP/IPv4 filters match the local address and
port and optionally the remote address and port; Ethernet filters
match the local address and optionally the VID.  The more specific
filters always override less specific filters within the same table,
and should be numbered accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   69 ++++++++++++++++++++++++++++--------
 1 files changed, 53 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index e89bad7..8af42cd 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -557,26 +557,62 @@ static int efx_filter_search(struct efx_filter_table *table,
 }
 
 /*
- * Construct/deconstruct external filter IDs.  These must be ordered
- * by matching priority, for RX NFC semantics.
+ * Construct/deconstruct external filter IDs.  At least the RX filter
+ * IDs must be ordered by matching priority, for RX NFC semantics.
+ *
+ * Deconstruction needs to be robust against invalid IDs so that
+ * efx_filter_remove_id_safe() and efx_filter_get_filter_safe() can
+ * accept user-provided IDs.
  */
 
+#define EFX_FILTER_MATCH_PRI_COUNT	5
+
+static const u8 efx_filter_type_match_pri[EFX_FILTER_TYPE_COUNT] = {
+	[EFX_FILTER_TCP_FULL]	= 0,
+	[EFX_FILTER_UDP_FULL]	= 0,
+	[EFX_FILTER_TCP_WILD]	= 1,
+	[EFX_FILTER_UDP_WILD]	= 1,
+	[EFX_FILTER_MAC_FULL]	= 2,
+	[EFX_FILTER_MAC_WILD]	= 3,
+	[EFX_FILTER_UC_DEF]	= 4,
+	[EFX_FILTER_MC_DEF]	= 4,
+};
+
+static const enum efx_filter_table_id efx_filter_range_table[] = {
+	EFX_FILTER_TABLE_RX_IP,		/* RX match pri 0 */
+	EFX_FILTER_TABLE_RX_IP,
+	EFX_FILTER_TABLE_RX_MAC,
+	EFX_FILTER_TABLE_RX_MAC,
+	EFX_FILTER_TABLE_RX_DEF,	/* RX match pri 4 */
+	EFX_FILTER_TABLE_COUNT,		/* TX match pri 0; invalid */
+	EFX_FILTER_TABLE_COUNT,		/* invalid */
+	EFX_FILTER_TABLE_TX_MAC,
+	EFX_FILTER_TABLE_TX_MAC,	/* TX match pri 3 */
+};
+
 #define EFX_FILTER_INDEX_WIDTH	13
 #define EFX_FILTER_INDEX_MASK	((1 << EFX_FILTER_INDEX_WIDTH) - 1)
 
-static inline u32 efx_filter_make_id(enum efx_filter_table_id table_id,
-				     unsigned int index, u8 flags)
+static inline u32
+efx_filter_make_id(const struct efx_filter_spec *spec, unsigned int index)
 {
-	unsigned int match_pri = table_id;
+	unsigned int range;
+
+	range = efx_filter_type_match_pri[spec->type];
+	if (!(spec->flags & EFX_FILTER_FLAG_RX))
+		range += EFX_FILTER_MATCH_PRI_COUNT;
 
-	return match_pri << EFX_FILTER_INDEX_WIDTH | index;
+	return range << EFX_FILTER_INDEX_WIDTH | index;
 }
 
 static inline enum efx_filter_table_id efx_filter_id_table_id(u32 id)
 {
-	unsigned int match_pri = id >> EFX_FILTER_INDEX_WIDTH;
+	unsigned int range = id >> EFX_FILTER_INDEX_WIDTH;
 
-	return match_pri;
+	if (range < ARRAY_SIZE(efx_filter_range_table))
+		return efx_filter_range_table[range];
+	else
+		return EFX_FILTER_TABLE_COUNT; /* invalid */
 }
 
 static inline unsigned int efx_filter_id_index(u32 id)
@@ -586,9 +622,9 @@ static inline unsigned int efx_filter_id_index(u32 id)
 
 static inline u8 efx_filter_id_flags(u32 id)
 {
-	unsigned int match_pri = id >> EFX_FILTER_INDEX_WIDTH;
+	unsigned int range = id >> EFX_FILTER_INDEX_WIDTH;
 
-	if (match_pri <= EFX_FILTER_TABLE_RX_DEF)
+	if (range < EFX_FILTER_MATCH_PRI_COUNT)
 		return EFX_FILTER_FLAG_RX;
 	else
 		return EFX_FILTER_FLAG_TX;
@@ -597,13 +633,15 @@ static inline u8 efx_filter_id_flags(u32 id)
 u32 efx_filter_get_rx_id_limit(struct efx_nic *efx)
 {
 	struct efx_filter_state *state = efx->filter_state;
-	unsigned int table_id = EFX_FILTER_TABLE_RX_DEF;
+	unsigned int range = EFX_FILTER_MATCH_PRI_COUNT - 1;
+	enum efx_filter_table_id table_id;
 
 	do {
+		table_id = efx_filter_range_table[range];
 		if (state->table[table_id].size != 0)
-			return (table_id << EFX_FILTER_INDEX_WIDTH) +
+			return range << EFX_FILTER_INDEX_WIDTH |
 				state->table[table_id].size;
-	} while (table_id--);
+	} while (range--);
 
 	return 0;
 }
@@ -681,7 +719,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	netif_vdbg(efx, hw, efx->net_dev,
 		   "%s: filter type %d index %d rxq %u set",
 		   __func__, spec->type, filter_idx, spec->dmaq_id);
-	rc = efx_filter_make_id(table->id, filter_idx, spec->flags);
+	rc = efx_filter_make_id(spec, filter_idx);
 
 out:
 	spin_unlock_bh(&state->lock);
@@ -888,8 +926,7 @@ s32 efx_filter_get_rx_ids(struct efx_nic *efx,
 					goto out;
 				}
 				buf[count++] = efx_filter_make_id(
-					table_id, filter_idx,
-					table->spec[filter_idx].flags);
+					&table->spec[filter_idx], filter_idx);
 			}
 		}
 	}
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
