From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 3/8] sfc: Change filter ID generation to satisfy
 priority semantics of RX NFC
Date: Tue, 3 Jan 2012 22:05:15 +0000
Message-ID: <1325628315.2832.39.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36879 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754891Ab2ACWFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:05:19 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also add note that the efx_filter_spec::priority field has nothing
to do with priority between multiple matching filters.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   43 ++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sfc/filter.h |    5 ++++
 2 files changed, 43 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 2b9636f..1e079bd 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -366,12 +366,45 @@ static int efx_filter_search(struct efx_filter_table *table,
 	}
 }
 
-/* Construct/deconstruct external filter IDs */
+/*
+ * Construct/deconstruct external filter IDs.  These must be ordered
+ * by matching priority, for RX NFC semantics.
+ *
+ * Each RX MAC filter entry has a flag for whether it can override an
+ * RX IP filter that also matches.  So we assign locations for MAC
+ * filters with overriding behaviour, then for IP filters, then for
+ * MAC filters without overriding behaviour.
+ */
+
+#define EFX_FILTER_INDEX_WIDTH	13
+#define EFX_FILTER_INDEX_MASK	((1 << EFX_FILTER_INDEX_WIDTH) - 1)
+
+static inline u32 efx_filter_make_id(enum efx_filter_table_id table_id,
+				     unsigned int index, u8 flags)
+{
+	return (table_id == EFX_FILTER_TABLE_RX_MAC &&
+		flags & EFX_FILTER_FLAG_RX_OVERRIDE_IP) ?
+		index :
+		(table_id + 1) << EFX_FILTER_INDEX_WIDTH | index;
+}
+
+static inline enum efx_filter_table_id efx_filter_id_table_id(u32 id)
+{
+	return (id <= EFX_FILTER_INDEX_MASK) ?
+		EFX_FILTER_TABLE_RX_MAC :
+		(id >> EFX_FILTER_INDEX_WIDTH) - 1;
+}
+
+static inline unsigned int efx_filter_id_index(u32 id)
+{
+	return id & EFX_FILTER_INDEX_MASK;
+}
 
-static inline int
-efx_filter_make_id(enum efx_filter_table_id table_id, unsigned index)
+static inline u8 efx_filter_id_flags(u32 id)
 {
-	return table_id << 16 | index;
+	return (id <= EFX_FILTER_INDEX_MASK) ?
+		EFX_FILTER_FLAG_RX | EFX_FILTER_FLAG_RX_OVERRIDE_IP :
+		EFX_FILTER_FLAG_RX;
 }
 
 /**
@@ -439,7 +472,7 @@ int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	netif_vdbg(efx, hw, efx->net_dev,
 		   "%s: filter type %d index %d rxq %u set",
 		   __func__, spec->type, filter_idx, spec->dmaq_id);
-	rc = efx_filter_make_id(table->id, filter_idx);
+	rc = efx_filter_make_id(table->id, filter_idx, spec->flags);
 
 out:
 	spin_unlock_bh(&state->lock);
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index 872f213..dc9a256 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -78,6 +78,11 @@ enum efx_filter_flags {
  *
  * Use the efx_filter_set_*() functions to initialise the @type and
  * @data fields.
+ *
+ * The @priority field is used by software to determine whether a new
+ * filter may replace an old one.  The hardware priority of a filter
+ * depends on the filter type and %EFX_FILTER_FLAG_RX_OVERRIDE_IP
+ * flag.
  */
 struct efx_filter_spec {
 	u8	type:4;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
