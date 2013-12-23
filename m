From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 15/21] mwifiex: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:11:02 +0800
Message-ID: <52B7C5E6.7030807@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Bing Zhao <bzhao@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Bing Zhao <bzhao@marvell.com>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/wireless/mwifiex/11n.c           | 4 ++--
 drivers/net/wireless/mwifiex/11n_rxreorder.c | 4 ++--
 drivers/net/wireless/mwifiex/cfg80211.c      | 2 +-
 drivers/net/wireless/mwifiex/scan.c          | 4 +---
 drivers/net/wireless/mwifiex/sta_cmdresp.c   | 3 +--
 drivers/net/wireless/mwifiex/sta_rx.c        | 2 +-
 drivers/net/wireless/mwifiex/uap_event.c     | 2 +-
 drivers/net/wireless/mwifiex/wmm.c           | 2 +-
 8 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwifiex/11n.c
index 0b803c0..b9f0e7e 100644
--- a/drivers/net/wireless/mwifiex/11n.c
+++ b/drivers/net/wireless/mwifiex/11n.c
@@ -483,7 +483,7 @@ mwifiex_get_ba_tbl(struct mwifiex_private *priv, int tid, u8 *ra)
 
 	spin_lock_irqsave(&priv->tx_ba_stream_tbl_lock, flags);
 	list_for_each_entry(tx_ba_tsr_tbl, &priv->tx_ba_stream_tbl_ptr, list) {
-		if (!memcmp(tx_ba_tsr_tbl->ra, ra, ETH_ALEN) &&
+		if (ether_addr_equal_unaligned(tx_ba_tsr_tbl->ra, ra) &&
 		    tx_ba_tsr_tbl->tid == tid) {
 			spin_unlock_irqrestore(&priv->tx_ba_stream_tbl_lock,
 					       flags);
@@ -676,7 +676,7 @@ void mwifiex_del_tx_ba_stream_tbl_by_ra(struct mwifiex_private *priv, u8 *ra)
 
 	spin_lock_irqsave(&priv->tx_ba_stream_tbl_lock, flags);
 	list_for_each_entry_safe(tbl, tmp, &priv->tx_ba_stream_tbl_ptr, list) {
-		if (!memcmp(tbl->ra, ra, ETH_ALEN)) {
+		if (ether_addr_equal_unaligned(tbl->ra, ra)) {
 			spin_unlock_irqrestore(&priv->tx_ba_stream_tbl_lock,
 					       flags);
 			mwifiex_11n_delete_tx_ba_stream_tbl_entry(priv, tbl);
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wireless/mwifiex/11n_rxreorder.c
index ada809f..a180298 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.c
@@ -164,7 +164,7 @@ mwifiex_11n_get_rx_reorder_tbl(struct mwifiex_private *priv, int tid, u8 *ta)
 
 	spin_lock_irqsave(&priv->rx_reorder_tbl_lock, flags);
 	list_for_each_entry(tbl, &priv->rx_reorder_tbl_ptr, list) {
-		if (!memcmp(tbl->ta, ta, ETH_ALEN) && tbl->tid == tid) {
+		if (ether_addr_equal_unaligned(tbl->ta, ta) && tbl->tid == tid) {
 			spin_unlock_irqrestore(&priv->rx_reorder_tbl_lock,
 					       flags);
 			return tbl;
@@ -188,7 +188,7 @@ void mwifiex_11n_del_rx_reorder_tbl_by_ta(struct mwifiex_private *priv, u8 *ta)
 
 	spin_lock_irqsave(&priv->rx_reorder_tbl_lock, flags);
 	list_for_each_entry_safe(tbl, tmp, &priv->rx_reorder_tbl_ptr, list) {
-		if (!memcmp(tbl->ta, ta, ETH_ALEN)) {
+		if (ether_addr_equal_unaligned(tbl->ta, ta)) {
 			spin_unlock_irqrestore(&priv->rx_reorder_tbl_lock,
 					       flags);
 			mwifiex_del_rx_reorder_entry(priv, tbl);
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 4d23647..05fe28a 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -992,7 +992,7 @@ mwifiex_cfg80211_get_station(struct wiphy *wiphy, struct net_device *dev,
 
 	if (!priv->media_connected)
 		return -ENOENT;
-	if (memcmp(mac, priv->cfg_bssid, ETH_ALEN))
+	if (!ether_addr_equal_unaligned(mac, priv->cfg_bssid))
 		return -ENOENT;
 
 	return mwifiex_dump_station_info(priv, sinfo);
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index 0ed0664..cb19afd 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1817,9 +1817,7 @@ int mwifiex_ret_802_11_scan(struct mwifiex_private *priv,
 				bss_priv->band = band;
 				bss_priv->fw_tsf = fw_tsf;
 				if (priv->media_connected &&
-				    !memcmp(bssid,
-					    priv->curr_bss_params.bss_descriptor
-					    .mac_address, ETH_ALEN))
+				    ether_addr_equal_unaligned(bssid, priv->curr_bss_params.bss_descriptor.mac_address))
 					mwifiex_update_curr_bss_params(priv,
 								       bss);
 				cfg80211_put_bss(priv->wdev->wiphy, bss);
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index 5511946..fe58245 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -782,8 +782,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
 	}
 
 	/* If BSSID is diff, modify current BSS parameters */
-	if (memcmp(priv->curr_bss_params.bss_descriptor.mac_address,
-		   ibss_coal_resp->bssid, ETH_ALEN)) {
+	if (!ether_addr_equal_unaligned(priv->curr_bss_params.bss_descriptor.mac_address, ibss_coal_resp->bssid)) {
 		/* BSSID */
 		memcpy(priv->curr_bss_params.bss_descriptor.mac_address,
 		       ibss_coal_resp->bssid, ETH_ALEN);
diff --git a/drivers/net/wireless/mwifiex/sta_rx.c b/drivers/net/wireless/mwifiex/sta_rx.c
index 0bb510d..4651d67 100644
--- a/drivers/net/wireless/mwifiex/sta_rx.c
+++ b/drivers/net/wireless/mwifiex/sta_rx.c
@@ -224,7 +224,7 @@ int mwifiex_process_sta_rx_packet(struct mwifiex_private *priv,
 	 * directly to os. Don't pass thru rx reordering
 	 */
 	if (!IS_11N_ENABLED(priv) ||
-	    memcmp(priv->curr_addr, rx_pkt_hdr->eth803_hdr.h_dest, ETH_ALEN)) {
+	    !ether_addr_equal_unaligned(priv->curr_addr, rx_pkt_hdr->eth803_hdr.h_dest)) {
 		mwifiex_process_rx_packet(priv, skb);
 		return ret;
 	}
diff --git a/drivers/net/wireless/mwifiex/uap_event.c b/drivers/net/wireless/mwifiex/uap_event.c
index 7180665..41de26a 100644
--- a/drivers/net/wireless/mwifiex/uap_event.c
+++ b/drivers/net/wireless/mwifiex/uap_event.c
@@ -36,7 +36,7 @@ mwifiex_get_sta_entry(struct mwifiex_private *priv, u8 *mac)
 		return NULL;
 
 	list_for_each_entry(node, &priv->sta_list, list) {
-		if (!memcmp(node->mac_addr, mac, ETH_ALEN))
+		if (ether_addr_equal_unaligned(node->mac_addr, mac))
 			return node;
 	}
 
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwifiex/wmm.c
index 13eaeed..6a62f64 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -576,7 +576,7 @@ mwifiex_wmm_get_ralist_node(struct mwifiex_private *priv, u8 tid,
 
 	list_for_each_entry(ra_list, &priv->wmm.tid_tbl_ptr[tid].ra_list,
 			    list) {
-		if (!memcmp(ra_list->ra, ra_addr, ETH_ALEN))
+		if (ether_addr_equal_unaligned(ra_list->ra, ra_addr))
 			return ra_list;
 	}
 
-- 
1.8.0
