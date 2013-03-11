From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/22] sfc: More sensible semantics for
 efx_filter_insert_filter() replace flag
Date: Mon, 11 Mar 2013 19:54:25 +0000
Message-ID: <1363031665.2608.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16725 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab3CKTy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:54:28 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'replace' flag to efx_filter_insert_filter() controls whether the
new filter may replace *any* filter, and is checked even before
priority comparison.  But lower-priority filters should never
block insertion of higher-priority filters.

Change the priority checking so that lower-priority filters are
replaced regardless of the value of the flag, and rename the
flag to 'replace_equal'.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 8af42cd..2fdd3a5 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -650,14 +650,22 @@ u32 efx_filter_get_rx_id_limit(struct efx_nic *efx)
  * efx_filter_insert_filter - add or replace a filter
  * @efx: NIC in which to insert the filter
  * @spec: Specification for the filter
- * @replace: Flag for whether the specified filter may replace a filter
- *	with an identical match expression and equal or lower priority
+ * @replace_equal: Flag for whether the specified filter may replace an
+ *	existing filter with equal priority
  *
  * On success, return the filter ID.
  * On failure, return a negative error code.
+ *
+ * If an existing filter has equal match values to the new filter
+ * spec, then the new filter might replace it, depending on the
+ * relative priorities.  If the existing filter has lower priority, or
+ * if @replace_equal is set and it has equal priority, then it is
+ * replaced.  Otherwise the function fails, returning -%EPERM if
+ * the existing filter has higher priority or -%EEXIST if it has
+ * equal priority.
  */
 s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
-			     bool replace)
+			     bool replace_equal)
 {
 	struct efx_filter_state *state = efx->filter_state;
 	struct efx_filter_table *table = efx_filter_spec_table(state, spec);
@@ -687,7 +695,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 
 	if (test_bit(filter_idx, table->used_bitmap)) {
 		/* Should we replace the existing filter? */
-		if (!replace) {
+		if (spec->priority == saved_spec->priority && !replace_equal) {
 			rc = -EEXIST;
 			goto out;
 		}
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
