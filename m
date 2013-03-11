From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/22] sfc: Merge efx_filter_search() into
 efx_filter_insert()
Date: Mon, 11 Mar 2013 19:55:00 +0000
Message-ID: <1363031700.2608.45.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16752 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991Ab3CKTzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:55:03 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_filter_search() is only called from efx_filter_insert(), and
neither function is very long.  The following bug fix requires a more
sophisticated search with a third result, which is going to be easier
to implement as part of the same function.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   60 +++++++++++++++----------------------
 1 files changed, 24 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 8d83d98..769560a 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -513,37 +513,6 @@ static bool efx_filter_equal(const struct efx_filter_spec *left,
 	return true;
 }
 
-static int efx_filter_search(struct efx_filter_table *table,
-			     struct efx_filter_spec *spec, u32 key,
-			     unsigned int *depth_required)
-{
-	unsigned hash, incr, filter_idx, depth, depth_max;
-
-	hash = efx_filter_hash(key);
-	incr = efx_filter_increment(key);
-
-	filter_idx = hash & (table->size - 1);
-	depth = 1;
-	depth_max = (spec->priority <= EFX_FILTER_PRI_HINT ?
-		     FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX);
-
-	for (;;) {
-		/* Return success if entry is unused or matches this spec */
-		if (!test_bit(filter_idx, table->used_bitmap) ||
-		    efx_filter_equal(spec, &table->spec[filter_idx])) {
-			*depth_required = depth;
-			return filter_idx;
-		}
-
-		/* Return failure if we reached the maximum search depth */
-		if (depth == depth_max)
-			return -EBUSY;
-
-		filter_idx = (filter_idx + incr) & (table->size - 1);
-		++depth;
-	}
-}
-
 /*
  * Construct/deconstruct external filter IDs.  At least the RX filter
  * IDs must be ordered by matching priority, for RX NFC semantics.
@@ -679,14 +648,33 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 		spin_lock_bh(&state->lock);
 	} else {
 		u32 key = efx_filter_build(&filter, spec);
+		unsigned int hash = efx_filter_hash(key);
+		unsigned int incr = efx_filter_increment(key);
+		unsigned int depth_max =
+			spec->priority <= EFX_FILTER_PRI_HINT ?
+			FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX;
+
+		filter_idx = hash & (table->size - 1);
+		depth = 1;
 
 		spin_lock_bh(&state->lock);
 
-		rc = efx_filter_search(table, spec, key, &depth);
-		if (rc < 0)
-			goto out;
-		filter_idx = rc;
-		BUG_ON(filter_idx >= table->size);
+		for (;;) {
+			if (!test_bit(filter_idx, table->used_bitmap) ||
+			    efx_filter_equal(spec, &table->spec[filter_idx]))
+				break;
+
+			/* Return failure if we reached the maximum search
+			 * depth
+			 */
+			if (depth == depth_max) {
+				rc = -EBUSY;
+				goto out;
+			}
+
+			filter_idx = (filter_idx + incr) & (table->size - 1);
+			++depth;
+		}
 	}
 
 	saved_spec = &table->spec[filter_idx];
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
