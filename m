From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 7/8] nfp: use a counter instead of log message for allocation failures
Date: Thu,  2 Nov 2017 01:31:35 -0700
Message-ID: <20171102083136.2096-8-jakub.kicinski@netronome.com>
References: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:43827 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755436AbdKBIc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:29 -0400
Received: by mail-pg0-f68.google.com with SMTP id s75so4455071pgs.0
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:28 -0700 (PDT)
In-Reply-To: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a counter incremented when allocation of replacement
RX page fails.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h         |  3 +++
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 15 ++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 12 +++++++-----
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index d51d8237b984..3d411f0d15b6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -394,6 +394,7 @@ struct nfp_net_rx_ring {
  * @tx_lso:	    Counter of LSO packets sent
  * @tx_errors:	    How many TX errors were encountered
  * @tx_busy:        How often was TX busy (no space)?
+ * @rx_replace_buf_alloc_fail:	Counter of RX buffer allocation failures
  * @irq_vector:     Interrupt vector number (use for talking to the OS)
  * @handler:        Interrupt handler for this ring vector
  * @name:           Name of the interrupt vector
@@ -437,6 +438,8 @@ struct nfp_net_r_vector {
 	u64 hw_csum_tx_inner;
 	u64 tx_gather;
 	u64 tx_lso;
+
+	u64 rx_replace_buf_alloc_fail;
 	u64 tx_errors;
 	u64 tx_busy;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 7147335a8b36..185a3dd35a3f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1209,15 +1209,15 @@ static void *nfp_net_napi_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 
 	if (!dp->xdp_prog) {
 		frag = napi_alloc_frag(dp->fl_bufsz);
+		if (unlikely(!frag))
+			return NULL;
 	} else {
 		struct page *page;
 
 		page = dev_alloc_page();
-		frag = page ? page_address(page) : NULL;
-	}
-	if (!frag) {
-		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
-		return NULL;
+		if (unlikely(!page))
+			return NULL;
+		frag = page_address(page);
 	}
 
 	*dma_addr = nfp_net_dma_map_rx(dp, frag);
@@ -1514,6 +1514,11 @@ nfp_net_rx_drop(const struct nfp_net_dp *dp, struct nfp_net_r_vector *r_vec,
 {
 	u64_stats_update_begin(&r_vec->rx_sync);
 	r_vec->rx_drops++;
+	/* If we have both skb and rxbuf the replacement buffer allocation
+	 * must have failed, count this as an alloc failure.
+	 */
+	if (skb && rxbuf)
+		r_vec->rx_replace_buf_alloc_fail++;
 	u64_stats_update_end(&r_vec->rx_sync);
 
 	/* skb is build based on the frag, free_skb() would free the frag
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index dc016dfec64d..6d5c376f0000 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -181,7 +181,7 @@ static const struct nfp_et_stat nfp_mac_et_stats[] = {
 
 #define NN_ET_GLOBAL_STATS_LEN ARRAY_SIZE(nfp_net_et_stats)
 #define NN_ET_SWITCH_STATS_LEN 9
-#define NN_ET_RVEC_GATHER_STATS 7
+#define NN_ET_RVEC_GATHER_STATS 8
 
 static void nfp_net_get_nspinfo(struct nfp_app *app, char *version)
 {
@@ -444,6 +444,7 @@ static u8 *nfp_vnic_get_sw_stats_strings(struct net_device *netdev, u8 *data)
 	data = nfp_pr_et(data, "hw_rx_csum_ok");
 	data = nfp_pr_et(data, "hw_rx_csum_inner_ok");
 	data = nfp_pr_et(data, "hw_rx_csum_err");
+	data = nfp_pr_et(data, "rx_replace_buf_alloc_fail");
 	data = nfp_pr_et(data, "hw_tx_csum");
 	data = nfp_pr_et(data, "hw_tx_inner_csum");
 	data = nfp_pr_et(data, "tx_gather");
@@ -468,16 +469,17 @@ static u64 *nfp_vnic_get_sw_stats(struct net_device *netdev, u64 *data)
 			tmp[0] = nn->r_vecs[i].hw_csum_rx_ok;
 			tmp[1] = nn->r_vecs[i].hw_csum_rx_inner_ok;
 			tmp[2] = nn->r_vecs[i].hw_csum_rx_error;
+			tmp[3] = nn->r_vecs[i].rx_replace_buf_alloc_fail;
 		} while (u64_stats_fetch_retry(&nn->r_vecs[i].rx_sync, start));
 
 		do {
 			start = u64_stats_fetch_begin(&nn->r_vecs[i].tx_sync);
 			data[1] = nn->r_vecs[i].tx_pkts;
 			data[2] = nn->r_vecs[i].tx_busy;
-			tmp[3] = nn->r_vecs[i].hw_csum_tx;
-			tmp[4] = nn->r_vecs[i].hw_csum_tx_inner;
-			tmp[5] = nn->r_vecs[i].tx_gather;
-			tmp[6] = nn->r_vecs[i].tx_lso;
+			tmp[4] = nn->r_vecs[i].hw_csum_tx;
+			tmp[5] = nn->r_vecs[i].hw_csum_tx_inner;
+			tmp[6] = nn->r_vecs[i].tx_gather;
+			tmp[7] = nn->r_vecs[i].tx_lso;
 		} while (u64_stats_fetch_retry(&nn->r_vecs[i].tx_sync, start));
 
 		data += 3;
-- 
2.14.1
