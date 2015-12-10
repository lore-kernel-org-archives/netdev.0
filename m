From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net] sfc: only use RSS filters if we're using RSS
Date: Thu, 10 Dec 2015 13:30:08 +0000
Message-ID: <56697E60.9050304@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:50545 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751151AbbLJNaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 08:30:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this filter insertion on a VF would fail if only one channel
was in use. This would include the unicast station filter and therefore
no traffic would be received.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c  | 23 +++++++++++------------
 drivers/net/ethernet/sfc/efx.h   |  5 +++++
 drivers/net/ethernet/sfc/farch.c |  2 +-
 3 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index c4a0e8a..368e98e 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3309,7 +3309,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 
 		new_spec.priority = EFX_FILTER_PRI_AUTO;
 		new_spec.flags = (EFX_FILTER_FLAG_RX |
-				  EFX_FILTER_FLAG_RX_RSS);
+			(efx_rss_enabled(efx) ? EFX_FILTER_FLAG_RX_RSS : 0));
 		new_spec.dmaq_id = 0;
 		new_spec.rss_context = EFX_FILTER_RSS_CONTEXT_DEFAULT;
 		rc = efx_ef10_filter_push(efx, &new_spec,
@@ -3931,6 +3931,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_dev_addr *addr_list;
+	enum efx_filter_flags filter_flags;
 	struct efx_filter_spec spec;
 	u8 baddr[ETH_ALEN];
 	unsigned int i, j;
@@ -3945,11 +3946,11 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 		addr_count = table->dev_uc_count;
 	}
 
+	filter_flags = efx_rss_enabled(efx) ? EFX_FILTER_FLAG_RX_RSS : 0;
+
 	/* Insert/renew filters */
 	for (i = 0; i < addr_count; i++) {
-		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-				   EFX_FILTER_FLAG_RX_RSS,
-				   0);
+		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO, filter_flags, 0);
 		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
 					 addr_list[i].addr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
@@ -3978,9 +3979,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 
 	if (multicast && rollback) {
 		/* Also need an Ethernet broadcast filter */
-		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-				   EFX_FILTER_FLAG_RX_RSS,
-				   0);
+		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO, filter_flags, 0);
 		eth_broadcast_addr(baddr);
 		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC, baddr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
@@ -4010,13 +4009,14 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	enum efx_filter_flags filter_flags;
 	struct efx_filter_spec spec;
 	u8 baddr[ETH_ALEN];
 	int rc;
 
-	efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-			   EFX_FILTER_FLAG_RX_RSS,
-			   0);
+	filter_flags = efx_rss_enabled(efx) ? EFX_FILTER_FLAG_RX_RSS : 0;
+
+	efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO, filter_flags, 0);
 
 	if (multicast)
 		efx_filter_set_mc_def(&spec);
@@ -4033,8 +4033,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 		if (!nic_data->workaround_26807) {
 			/* Also need an Ethernet broadcast filter */
 			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
-					   EFX_FILTER_FLAG_RX_RSS,
-					   0);
+					   filter_flags, 0);
 			eth_broadcast_addr(baddr);
 			efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
 						 baddr);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 1aaf76c..1082747 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -76,6 +76,11 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 #define EFX_TXQ_MAX_ENT(efx)	(EFX_WORKAROUND_35388(efx) ? \
 				 EFX_MAX_DMAQ_SIZE / 2 : EFX_MAX_DMAQ_SIZE)
 
+static inline bool efx_rss_enabled(struct efx_nic *efx)
+{
+	return efx->rss_spread > 1;
+}
+
 /* Filters */
 
 void efx_mac_reconfigure(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 5a1c5a8..133e9e3 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -2242,7 +2242,7 @@ efx_farch_filter_init_rx_auto(struct efx_nic *efx,
 	 */
 	spec->priority = EFX_FILTER_PRI_AUTO;
 	spec->flags = (EFX_FILTER_FLAG_RX |
-		       (efx->n_rx_channels > 1 ? EFX_FILTER_FLAG_RX_RSS : 0) |
+		       (efx_rss_enabled(efx) ? EFX_FILTER_FLAG_RX_RSS : 0) |
 		       (efx->rx_scatter ? EFX_FILTER_FLAG_RX_SCATTER : 0));
 	spec->dmaq_id = 0;
 }
-- 
2.4.3
