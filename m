From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3.6 17/19] mwifiex: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:54:20 +0800
Message-ID: <52CCBDDC.1050503@huawei.com>
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

Use possibly more efficient ether_addr_equal
instead of memcmp.

Cc: Bing Zhao <bzhao@marvell.com>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/wireless/mwifiex/11n.c         | 2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c | 3 +--
 drivers/net/wireless/mwifiex/sta_rx.c      | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwifiex/11n.c
index 0b803c0..6261f8c 100644
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
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index 5511946..24523e4 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -782,8 +782,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
 	}
 
 	/* If BSSID is diff, modify current BSS parameters */
-	if (memcmp(priv->curr_bss_params.bss_descriptor.mac_address,
-		   ibss_coal_resp->bssid, ETH_ALEN)) {
+	if (!ether_addr_equal(priv->curr_bss_params.bss_descriptor.mac_address, ibss_coal_resp->bssid)) {
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
-- 
1.8.0
