From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/7] sfc: Fix loop condition for
 efx_filter_search() when !for_insert
Date: Thu, 14 Jul 2011 02:16:38 +0100
Message-ID: <1310606198.2756.24.camel@bwh-desktop>
References: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11173 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab1GNBQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:16:42 -0400
In-Reply-To: <1310606090.2756.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_filter_remove_filter() fails to remove inserted filters in some cases.

For example:

  1. Two filters A and B have specifications that result in an initial
     hash collision.
  2. A is inserted first, followed by B.
  3. An attempt to remove B first succeeds, but if A is removed first
     a subsequent attempt to remove B fails.

When searching for an existing filter (!for_insert),
efx_filter_search() must always continue to the maximum search depth
for the given type rather than stopping at the first unused entry.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/filter.c |   41 ++++++++++++++++++++++++-----------------
 1 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index f2fc258..054f0a3 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -335,28 +335,35 @@ static int efx_filter_search(struct efx_filter_table *table,
 			     bool for_insert, int *depth_required)
 {
 	unsigned hash, incr, filter_idx, depth, depth_max;
-	struct efx_filter_spec *cmp;
 
 	hash = efx_filter_hash(key);
 	incr = efx_filter_increment(key);
-	depth_max = (spec->priority <= EFX_FILTER_PRI_HINT ?
-		     FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX);
-
-	for (depth = 1, filter_idx = hash & (table->size - 1);
-	     depth <= depth_max && test_bit(filter_idx, table->used_bitmap);
-	     ++depth) {
-		cmp = &table->spec[filter_idx];
-		if (efx_filter_equal(spec, cmp))
-			goto found;
+
+	filter_idx = hash & (table->size - 1);
+	depth = 1;
+	depth_max = (for_insert ?
+		     (spec->priority <= EFX_FILTER_PRI_HINT ?
+		      FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX) :
+		     table->search_depth[spec->type]);
+
+	for (;;) {
+		/* Return success if entry is used and matches this spec
+		 * or entry is unused and we are trying to insert.
+		 */
+		if (test_bit(filter_idx, table->used_bitmap) ?
+		    efx_filter_equal(spec, &table->spec[filter_idx]) :
+		    for_insert) {
+			*depth_required = depth;
+			return filter_idx;
+		}
+
+		/* Return failure if we reached the maximum search depth */
+		if (depth == depth_max)
+			return for_insert ? -EBUSY : -ENOENT;
+
 		filter_idx = (filter_idx + incr) & (table->size - 1);
+		++depth;
 	}
-	if (!for_insert)
-		return -ENOENT;
-	if (depth > depth_max)
-		return -EBUSY;
-found:
-	*depth_required = depth;
-	return filter_idx;
 }
 
 /* Construct/deconstruct external filter IDs */
-- 
1.7.4.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

