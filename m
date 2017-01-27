From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/4] sfc: fixes to filter restore handling
Date: Fri, 27 Jan 2017 15:02:11 +0000
Message-ID: <b231ea6a-0f47-c316-55b2-bfe247e3946f@solarflare.com>
References: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:18182 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755047AbdA0PKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:10:12 -0500
In-Reply-To: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

If the NIC is switched from full-featured to low-latency, encapsulated
 filters are no longer available, and this causes errors. This patch
 removes those filters from the filter table on restore.
Also, if filters which are removed by the above, or which we fail to
 insert when restoring filters, were UC, MC or broadcast default
 filters, invalidate the corresponding vlan->default_filters entry.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 42 +++++++++++++++++++++++++++++++++++++----
 1 file changed, 38 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 7c53da2..b64b47b 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4557,9 +4557,12 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	unsigned int invalid_filters = 0, failed = 0;
+	struct efx_ef10_filter_vlan *vlan;
 	struct efx_filter_spec *spec;
 	unsigned int filter_idx;
-	bool failed = false;
+	u32 mcdi_flags;
+	int match_pri;
 	int rc;
 
 	WARN_ON(!rwsem_is_locked(&efx->filter_sem));
@@ -4577,6 +4580,20 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 		if (!spec)
 			continue;
 
+		mcdi_flags = efx_ef10_filter_mcdi_flags_from_spec(spec);
+		match_pri = 0;
+		while (match_pri < table->rx_match_count &&
+		       table->rx_match_mcdi_flags[match_pri] != mcdi_flags)
+			++match_pri;
+		if (match_pri >= table->rx_match_count) {
+			invalid_filters++;
+			goto not_restored;
+		}
+		if (spec->rss_context != EFX_FILTER_RSS_CONTEXT_DEFAULT &&
+		    spec->rss_context != nic_data->rx_rss_context)
+			netif_warn(efx, drv, efx->net_dev,
+				   "Warning: unable to restore a filter with specific RSS context.\n");
+
 		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_BUSY;
 		spin_unlock_bh(&efx->filter_lock);
 
@@ -4584,10 +4601,19 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 					  &table->entry[filter_idx].handle,
 					  false);
 		if (rc)
-			failed = true;
-
+			failed++;
 		spin_lock_bh(&efx->filter_lock);
+
 		if (rc) {
+not_restored:
+			list_for_each_entry(vlan, &table->vlan_list, list) {
+				if (vlan->ucdef == filter_idx)
+					vlan->ucdef = EFX_EF10_FILTER_ID_INVALID;
+				if (vlan->mcdef == filter_idx)
+					vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
+				if (vlan->bcast == filter_idx)
+					vlan->bcast = EFX_EF10_FILTER_ID_INVALID;
+			}
 			kfree(spec);
 			efx_ef10_filter_set_entry(table, filter_idx, NULL, 0);
 		} else {
@@ -4598,9 +4624,17 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 
 	spin_unlock_bh(&efx->filter_lock);
 
+	/* This can happen validly if the MC's capabilities have changed, so
+	 * is not an error.
+	 */
+	if (invalid_filters)
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Did not restore %u filters that are now unsupported.\n",
+			  invalid_filters);
+
 	if (failed)
 		netif_err(efx, hw, efx->net_dev,
-			  "unable to restore all filters\n");
+			  "unable to restore %u filters\n", failed);
 	else
 		nic_data->must_restore_filters = false;
 }
