From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Don't try to set filters with search
 depths we know won't work
Date: Thu, 07 Oct 2010 18:50:31 +0100
Message-ID: <1286473831.2271.26.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32951 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822Ab0JGRue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 13:50:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The filter engine will time-out and ignore filters beyond
200-something hops.  We also need to avoid infinite loops in
efx_filter_search() when the table is full.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/filter.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index abc884d..52cb608 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -20,6 +20,12 @@
 #define FILTER_CTL_SRCH_FUDGE_WILD 3
 #define FILTER_CTL_SRCH_FUDGE_FULL 1
 
+/* Hard maximum hop limit.  Hardware will time-out beyond 200-something.
+ * We also need to avoid infinite loops in efx_filter_search() when the
+ * table is full.
+ */
+#define FILTER_CTL_SRCH_MAX 200
+
 struct efx_filter_table {
 	u32		offset;		/* address of table relative to BAR */
 	unsigned	size;		/* number of entries */
@@ -183,7 +189,8 @@ static int efx_filter_search(struct efx_filter_table *table,
 	incr = efx_filter_increment(key);
 
 	for (depth = 1, filter_idx = hash & (table->size - 1);
-	     test_bit(filter_idx, table->used_bitmap);
+	     depth <= FILTER_CTL_SRCH_MAX &&
+		     test_bit(filter_idx, table->used_bitmap);
 	     ++depth) {
 		cmp = &table->spec[filter_idx];
 		if (efx_filter_equal(spec, cmp))
@@ -192,6 +199,8 @@ static int efx_filter_search(struct efx_filter_table *table,
 	}
 	if (!for_insert)
 		return -ENOENT;
+	if (depth > FILTER_CTL_SRCH_MAX)
+		return -EBUSY;
 found:
 	*depth_required = depth;
 	return filter_idx;
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

