From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 4/5] sfc: Limit filter search depth further for
 performance hints (i.e. RFS)
Date: Fri, 19 Nov 2010 18:47:59 +0000
Message-ID: <1290192479.2671.44.camel@bwh-desktop>
References: <1290192176.2671.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23593 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab0KSSsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 13:48:02 -0500
In-Reply-To: <1290192176.2671.38.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/sfc/filter.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 52cb608..e0ad1b8 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -26,6 +26,10 @@
  */
 #define FILTER_CTL_SRCH_MAX 200
 
+/* Don't try very hard to find space for performance hints, as this is
+ * counter-productive. */
+#define FILTER_CTL_SRCH_HINT_MAX 5
+
 struct efx_filter_table {
 	u32		offset;		/* address of table relative to BAR */
 	unsigned	size;		/* number of entries */
@@ -182,15 +186,16 @@ static int efx_filter_search(struct efx_filter_table *table,
 			     struct efx_filter_spec *spec, u32 key,
 			     bool for_insert, int *depth_required)
 {
-	unsigned hash, incr, filter_idx, depth;
+	unsigned hash, incr, filter_idx, depth, depth_max;
 	struct efx_filter_spec *cmp;
 
 	hash = efx_filter_hash(key);
 	incr = efx_filter_increment(key);
+	depth_max = (spec->priority <= EFX_FILTER_PRI_HINT ?
+		     FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX);
 
 	for (depth = 1, filter_idx = hash & (table->size - 1);
-	     depth <= FILTER_CTL_SRCH_MAX &&
-		     test_bit(filter_idx, table->used_bitmap);
+	     depth <= depth_max && test_bit(filter_idx, table->used_bitmap);
 	     ++depth) {
 		cmp = &table->spec[filter_idx];
 		if (efx_filter_equal(spec, cmp))
@@ -199,7 +204,7 @@ static int efx_filter_search(struct efx_filter_table *table,
 	}
 	if (!for_insert)
 		return -ENOENT;
-	if (depth > FILTER_CTL_SRCH_MAX)
+	if (depth > depth_max)
 		return -EBUSY;
 found:
 	*depth_required = depth;
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

