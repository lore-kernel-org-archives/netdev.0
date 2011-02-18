From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/3] sfc: Limit filter search depth further
 for performance hints (i.e. RFS)
Date: Fri, 18 Feb 2011 16:03:49 +0000
Message-ID: <1298045029.2570.9.camel@bwh-desktop>
References: <1298044839.2570.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39140 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757123Ab1BRQDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:03:52 -0500
In-Reply-To: <1298044839.2570.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/filter.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index d4722c4..47a1b79 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -27,6 +27,10 @@
  */
 #define FILTER_CTL_SRCH_MAX 200
 
+/* Don't try very hard to find space for performance hints, as this is
+ * counter-productive. */
+#define FILTER_CTL_SRCH_HINT_MAX 5
+
 enum efx_filter_table_id {
 	EFX_FILTER_TABLE_RX_IP = 0,
 	EFX_FILTER_TABLE_RX_MAC,
@@ -325,15 +329,16 @@ static int efx_filter_search(struct efx_filter_table *table,
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
@@ -342,7 +347,7 @@ static int efx_filter_search(struct efx_filter_table *table,
 	}
 	if (!for_insert)
 		return -ENOENT;
-	if (depth > FILTER_CTL_SRCH_MAX)
+	if (depth > depth_max)
 		return -EBUSY;
 found:
 	*depth_required = depth;
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

