From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/22] sfc: Don't use
 efx_filter_{build,hash,increment}() for default MAC filters
Date: Mon, 11 Mar 2013 19:54:49 +0000
Message-ID: <1363031689.2608.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16744 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab3CKTyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:54:52 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions happen to work for default MAC filters: they generate
an initial index of 1/0 for unicast/multicast respectively and an
increment of 1 for either, so a search succeeds at depth 2.  But this
is a matter of luck rather than design, and it really won't work well
with the bug fix we're about to do.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   35 +++++++++++++++++++----------------
 1 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 3d94ed7..8d83d98 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -463,13 +463,6 @@ static u32 efx_filter_build(efx_oword_t *filter, struct efx_filter_spec *spec)
 		break;
 	}
 
-	case EFX_FILTER_TABLE_RX_DEF:
-		/* One filter spec per type */
-		BUILD_BUG_ON(EFX_FILTER_INDEX_UC_DEF != 0);
-		BUILD_BUG_ON(EFX_FILTER_INDEX_MC_DEF !=
-			     EFX_FILTER_MC_DEF - EFX_FILTER_UC_DEF);
-		return spec->type - EFX_FILTER_UC_DEF;
-
 	case EFX_FILTER_TABLE_RX_MAC: {
 		bool is_wild = spec->type == EFX_FILTER_MAC_WILD;
 		EFX_POPULATE_OWORD_7(
@@ -667,25 +660,35 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	struct efx_filter_spec *saved_spec;
 	efx_oword_t filter;
 	unsigned int filter_idx, depth = 0;
-	u32 key;
 	int rc;
 
 	if (!table || table->size == 0)
 		return -EINVAL;
 
-	key = efx_filter_build(&filter, spec);
-
 	netif_vdbg(efx, hw, efx->net_dev,
 		   "%s: type %d search_depth=%d", __func__, spec->type,
 		   table->search_depth[spec->type]);
 
-	spin_lock_bh(&state->lock);
+	if (table->id == EFX_FILTER_TABLE_RX_DEF) {
+		/* One filter spec per type */
+		BUILD_BUG_ON(EFX_FILTER_INDEX_UC_DEF != 0);
+		BUILD_BUG_ON(EFX_FILTER_INDEX_MC_DEF !=
+			     EFX_FILTER_MC_DEF - EFX_FILTER_UC_DEF);
+		filter_idx = spec->type - EFX_FILTER_INDEX_UC_DEF;
+
+		spin_lock_bh(&state->lock);
+	} else {
+		u32 key = efx_filter_build(&filter, spec);
+
+		spin_lock_bh(&state->lock);
+
+		rc = efx_filter_search(table, spec, key, &depth);
+		if (rc < 0)
+			goto out;
+		filter_idx = rc;
+		BUG_ON(filter_idx >= table->size);
+	}
 
-	rc = efx_filter_search(table, spec, key, &depth);
-	if (rc < 0)
-		goto out;
-	filter_idx = rc;
-	BUG_ON(filter_idx >= table->size);
 	saved_spec = &table->spec[filter_idx];
 
 	if (test_bit(filter_idx, table->used_bitmap)) {
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
