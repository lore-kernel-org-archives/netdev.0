From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/6] sfc: Remove EFX_FILTER_FLAG_RX_OVERRIDE_IP
Date: Tue, 2 Oct 2012 02:28:22 +0100
Message-ID: <1349141302.2577.78.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17193 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750897Ab2JBB2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:28:25 -0400
In-Reply-To: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This filter flag cannot yet be set through the ethtool command and
will not be supported on future hardware.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |    8 +----
 drivers/net/ethernet/sfc/filter.c  |   53 +++++-------------------------------
 drivers/net/ethernet/sfc/filter.h  |    7 +----
 3 files changed, 10 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index cf77207..90f078e 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -961,9 +961,7 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 	int rc;
 
 	/* Check that user wants us to choose the location */
-	if (rule->location != RX_CLS_LOC_ANY &&
-	    rule->location != RX_CLS_LOC_FIRST &&
-	    rule->location != RX_CLS_LOC_LAST)
+	if (rule->location != RX_CLS_LOC_ANY)
 		return -EINVAL;
 
 	/* Range-check ring_cookie */
@@ -977,9 +975,7 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 	     rule->m_ext.data[1]))
 		return -EINVAL;
 
-	efx_filter_init_rx(&spec, EFX_FILTER_PRI_MANUAL,
-			   (rule->location == RX_CLS_LOC_FIRST) ?
-			   EFX_FILTER_FLAG_RX_OVERRIDE_IP : 0,
+	efx_filter_init_rx(&spec, EFX_FILTER_PRI_MANUAL, 0,
 			   (rule->ring_cookie == RX_CLS_FLOW_DISC) ?
 			   0xfff : rule->ring_cookie);
 
diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index c3fd61f..e89bad7 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -162,20 +162,12 @@ static void efx_filter_push_rx_config(struct efx_nic *efx)
 			!!(table->spec[EFX_FILTER_INDEX_UC_DEF].flags &
 			   EFX_FILTER_FLAG_RX_RSS));
 		EFX_SET_OWORD_FIELD(
-			filter_ctl, FRF_CZ_UNICAST_NOMATCH_IP_OVERRIDE,
-			!!(table->spec[EFX_FILTER_INDEX_UC_DEF].flags &
-			   EFX_FILTER_FLAG_RX_OVERRIDE_IP));
-		EFX_SET_OWORD_FIELD(
 			filter_ctl, FRF_CZ_MULTICAST_NOMATCH_Q_ID,
 			table->spec[EFX_FILTER_INDEX_MC_DEF].dmaq_id);
 		EFX_SET_OWORD_FIELD(
 			filter_ctl, FRF_CZ_MULTICAST_NOMATCH_RSS_ENABLED,
 			!!(table->spec[EFX_FILTER_INDEX_MC_DEF].flags &
 			   EFX_FILTER_FLAG_RX_RSS));
-		EFX_SET_OWORD_FIELD(
-			filter_ctl, FRF_CZ_MULTICAST_NOMATCH_IP_OVERRIDE,
-			!!(table->spec[EFX_FILTER_INDEX_MC_DEF].flags &
-			   EFX_FILTER_FLAG_RX_OVERRIDE_IP));
 	}
 
 	efx_writeo(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
@@ -480,14 +472,12 @@ static u32 efx_filter_build(efx_oword_t *filter, struct efx_filter_spec *spec)
 
 	case EFX_FILTER_TABLE_RX_MAC: {
 		bool is_wild = spec->type == EFX_FILTER_MAC_WILD;
-		EFX_POPULATE_OWORD_8(
+		EFX_POPULATE_OWORD_7(
 			*filter,
 			FRF_CZ_RMFT_RSS_EN,
 			!!(spec->flags & EFX_FILTER_FLAG_RX_RSS),
 			FRF_CZ_RMFT_SCATTER_EN,
 			!!(spec->flags & EFX_FILTER_FLAG_RX_SCATTER),
-			FRF_CZ_RMFT_IP_OVERRIDE,
-			!!(spec->flags & EFX_FILTER_FLAG_RX_OVERRIDE_IP),
 			FRF_CZ_RMFT_RXQ_ID, spec->dmaq_id,
 			FRF_CZ_RMFT_WILDCARD_MATCH, is_wild,
 			FRF_CZ_RMFT_DEST_MAC_HI, spec->data[2],
@@ -569,31 +559,15 @@ static int efx_filter_search(struct efx_filter_table *table,
 /*
  * Construct/deconstruct external filter IDs.  These must be ordered
  * by matching priority, for RX NFC semantics.
- *
- * Each RX MAC filter entry has a flag for whether it can override an
- * RX IP filter that also matches.  So we assign locations for MAC
- * filters with overriding behaviour, then for IP filters, then for
- * MAC filters without overriding behaviour.
  */
 
-#define EFX_FILTER_MATCH_PRI_RX_MAC_OVERRIDE_IP	0
-#define EFX_FILTER_MATCH_PRI_RX_DEF_OVERRIDE_IP	1
-#define EFX_FILTER_MATCH_PRI_NORMAL_BASE	2
-
 #define EFX_FILTER_INDEX_WIDTH	13
 #define EFX_FILTER_INDEX_MASK	((1 << EFX_FILTER_INDEX_WIDTH) - 1)
 
 static inline u32 efx_filter_make_id(enum efx_filter_table_id table_id,
 				     unsigned int index, u8 flags)
 {
-	unsigned int match_pri = EFX_FILTER_MATCH_PRI_NORMAL_BASE + table_id;
-
-	if (flags & EFX_FILTER_FLAG_RX_OVERRIDE_IP) {
-		if (table_id == EFX_FILTER_TABLE_RX_MAC)
-			match_pri = EFX_FILTER_MATCH_PRI_RX_MAC_OVERRIDE_IP;
-		else if (table_id == EFX_FILTER_TABLE_RX_DEF)
-			match_pri = EFX_FILTER_MATCH_PRI_RX_DEF_OVERRIDE_IP;
-	}
+	unsigned int match_pri = table_id;
 
 	return match_pri << EFX_FILTER_INDEX_WIDTH | index;
 }
@@ -602,14 +576,7 @@ static inline enum efx_filter_table_id efx_filter_id_table_id(u32 id)
 {
 	unsigned int match_pri = id >> EFX_FILTER_INDEX_WIDTH;
 
-	switch (match_pri) {
-	case EFX_FILTER_MATCH_PRI_RX_MAC_OVERRIDE_IP:
-		return EFX_FILTER_TABLE_RX_MAC;
-	case EFX_FILTER_MATCH_PRI_RX_DEF_OVERRIDE_IP:
-		return EFX_FILTER_TABLE_RX_DEF;
-	default:
-		return match_pri - EFX_FILTER_MATCH_PRI_NORMAL_BASE;
-	}
+	return match_pri;
 }
 
 static inline unsigned int efx_filter_id_index(u32 id)
@@ -621,10 +588,7 @@ static inline u8 efx_filter_id_flags(u32 id)
 {
 	unsigned int match_pri = id >> EFX_FILTER_INDEX_WIDTH;
 
-	if (match_pri < EFX_FILTER_MATCH_PRI_NORMAL_BASE)
-		return EFX_FILTER_FLAG_RX | EFX_FILTER_FLAG_RX_OVERRIDE_IP;
-	else if (match_pri <=
-		 EFX_FILTER_MATCH_PRI_NORMAL_BASE + EFX_FILTER_TABLE_RX_DEF)
+	if (match_pri <= EFX_FILTER_TABLE_RX_DEF)
 		return EFX_FILTER_FLAG_RX;
 	else
 		return EFX_FILTER_FLAG_TX;
@@ -637,8 +601,7 @@ u32 efx_filter_get_rx_id_limit(struct efx_nic *efx)
 
 	do {
 		if (state->table[table_id].size != 0)
-			return ((EFX_FILTER_MATCH_PRI_NORMAL_BASE + table_id)
-				<< EFX_FILTER_INDEX_WIDTH) +
+			return (table_id << EFX_FILTER_INDEX_WIDTH) +
 				state->table[table_id].size;
 	} while (table_id--);
 
@@ -781,8 +744,7 @@ int efx_filter_remove_id_safe(struct efx_nic *efx,
 	spin_lock_bh(&state->lock);
 
 	if (test_bit(filter_idx, table->used_bitmap) &&
-	    spec->priority == priority &&
-	    !((spec->flags ^ filter_flags) & EFX_FILTER_FLAG_RX_OVERRIDE_IP)) {
+	    spec->priority == priority) {
 		efx_filter_table_clear_entry(efx, table, filter_idx);
 		if (table->used == 0)
 			efx_filter_table_reset_search_depth(table);
@@ -833,8 +795,7 @@ int efx_filter_get_filter_safe(struct efx_nic *efx,
 	spin_lock_bh(&state->lock);
 
 	if (test_bit(filter_idx, table->used_bitmap) &&
-	    spec->priority == priority &&
-	    !((spec->flags ^ filter_flags) & EFX_FILTER_FLAG_RX_OVERRIDE_IP)) {
+	    spec->priority == priority) {
 		*spec_buf = *spec;
 		rc = 0;
 	} else {
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index 3c77802..5cb5472 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -61,16 +61,12 @@ enum efx_filter_priority {
  *	according to the indirection table.
  * @EFX_FILTER_FLAG_RX_SCATTER: Enable DMA scatter on the receiving
  *	queue.
- * @EFX_FILTER_FLAG_RX_OVERRIDE_IP: Enables a MAC filter to override
- *	any IP filter that matches the same packet.  By default, IP
- *	filters take precedence.
  * @EFX_FILTER_FLAG_RX: Filter is for RX
  * @EFX_FILTER_FLAG_TX: Filter is for TX
  */
 enum efx_filter_flags {
 	EFX_FILTER_FLAG_RX_RSS = 0x01,
 	EFX_FILTER_FLAG_RX_SCATTER = 0x02,
-	EFX_FILTER_FLAG_RX_OVERRIDE_IP = 0x04,
 	EFX_FILTER_FLAG_RX = 0x08,
 	EFX_FILTER_FLAG_TX = 0x10,
 };
@@ -88,8 +84,7 @@ enum efx_filter_flags {
  *
  * The @priority field is used by software to determine whether a new
  * filter may replace an old one.  The hardware priority of a filter
- * depends on the filter type and %EFX_FILTER_FLAG_RX_OVERRIDE_IP
- * flag.
+ * depends on the filter type.
  */
 struct efx_filter_spec {
 	u8	type:4;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
