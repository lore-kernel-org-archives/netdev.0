From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/22] sfc: Remove redundant parameter to
 efx_filter_search()
Date: Mon, 11 Mar 2013 19:54:36 +0000
Message-ID: <1363031676.2608.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16735 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948Ab3CKTyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:54:39 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'for_insert' parameter is redundant since there are no longer
any other operations that need to search based on a filter spec.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 2fdd3a5..3d94ed7 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -522,7 +522,7 @@ static bool efx_filter_equal(const struct efx_filter_spec *left,
 
 static int efx_filter_search(struct efx_filter_table *table,
 			     struct efx_filter_spec *spec, u32 key,
-			     bool for_insert, unsigned int *depth_required)
+			     unsigned int *depth_required)
 {
 	unsigned hash, incr, filter_idx, depth, depth_max;
 
@@ -531,25 +531,20 @@ static int efx_filter_search(struct efx_filter_table *table,
 
 	filter_idx = hash & (table->size - 1);
 	depth = 1;
-	depth_max = (for_insert ?
-		     (spec->priority <= EFX_FILTER_PRI_HINT ?
-		      FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX) :
-		     table->search_depth[spec->type]);
+	depth_max = (spec->priority <= EFX_FILTER_PRI_HINT ?
+		     FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX);
 
 	for (;;) {
-		/* Return success if entry is used and matches this spec
-		 * or entry is unused and we are trying to insert.
-		 */
-		if (test_bit(filter_idx, table->used_bitmap) ?
-		    efx_filter_equal(spec, &table->spec[filter_idx]) :
-		    for_insert) {
+		/* Return success if entry is unused or matches this spec */
+		if (!test_bit(filter_idx, table->used_bitmap) ||
+		    efx_filter_equal(spec, &table->spec[filter_idx])) {
 			*depth_required = depth;
 			return filter_idx;
 		}
 
 		/* Return failure if we reached the maximum search depth */
 		if (depth == depth_max)
-			return for_insert ? -EBUSY : -ENOENT;
+			return -EBUSY;
 
 		filter_idx = (filter_idx + incr) & (table->size - 1);
 		++depth;
@@ -686,7 +681,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 
 	spin_lock_bh(&state->lock);
 
-	rc = efx_filter_search(table, spec, key, true, &depth);
+	rc = efx_filter_search(table, spec, key, &depth);
 	if (rc < 0)
 		goto out;
 	filter_idx = rc;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
