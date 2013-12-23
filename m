From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 18/21] cw1200: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:11:21 +0800
Message-ID: <52B7C5F9.4080300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Solomon Peachy <pizza@shaftnet.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Solomon Peachy <pizza@shaftnet.org>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/wireless/cw1200/sta.c  | 4 ++--
 drivers/net/wireless/cw1200/txrx.c | 7 +++----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/cw1200/sta.c b/drivers/net/wireless/cw1200/sta.c
index 010b252..f5d1c83 100644
--- a/drivers/net/wireless/cw1200/sta.c
+++ b/drivers/net/wireless/cw1200/sta.c
@@ -555,8 +555,8 @@ u64 cw1200_prepare_multicast(struct ieee80211_hw *hw,
 		pr_debug("[STA] multicast: %pM\n", ha->addr);
 		memcpy(&priv->multicast_filter.macaddrs[count],
 		       ha->addr, ETH_ALEN);
-		if (memcmp(ha->addr, broadcast_ipv4, ETH_ALEN) &&
-		    memcmp(ha->addr, broadcast_ipv6, ETH_ALEN))
+		if (!ether_addr_equal_unaligned(ha->addr, broadcast_ipv4) &&
+		    !ether_addr_equal_unaligned(ha->addr, broadcast_ipv6))
 			priv->has_multicast_subscription = true;
 		count++;
 	}
diff --git a/drivers/net/wireless/cw1200/txrx.c b/drivers/net/wireless/cw1200/txrx.c
index e824d4d..bb9eb7b 100644
--- a/drivers/net/wireless/cw1200/txrx.c
+++ b/drivers/net/wireless/cw1200/txrx.c
@@ -816,7 +816,7 @@ static int cw1200_handle_pspoll(struct cw1200_common *priv,
 
 	if (priv->join_status != CW1200_JOIN_STATUS_AP)
 		goto done;
-	if (memcmp(priv->vif->addr, pspoll->bssid, ETH_ALEN))
+	if (!ether_addr_equal_unaligned(priv->vif->addr, pspoll->bssid))
 		goto done;
 
 	rcu_read_lock();
@@ -1166,8 +1166,7 @@ void cw1200_rx_cb(struct cw1200_common *priv,
 			return;
 	} else if (ieee80211_is_beacon(frame->frame_control) &&
 		   !arg->status && priv->vif &&
-		   !memcmp(ieee80211_get_SA(frame), priv->vif->bss_conf.bssid,
-			   ETH_ALEN)) {
+		   ether_addr_equal_unaligned(ieee80211_get_SA(frame), priv->vif->bss_conf.bssid)) {
 		const u8 *tim_ie;
 		u8 *ies = ((struct ieee80211_mgmt *)
 			  (skb->data))->u.beacon.variable;
@@ -1314,7 +1313,7 @@ int cw1200_find_link_id(struct cw1200_common *priv, const u8 *mac)
 	int i, ret = 0;
 	spin_lock_bh(&priv->ps_state_lock);
 	for (i = 0; i < CW1200_MAX_STA_IN_AP_MODE; ++i) {
-		if (!memcmp(mac, priv->link_id_db[i].mac, ETH_ALEN) &&
+		if (ether_addr_equal_unaligned(mac, priv->link_id_db[i].mac) &&
 		    priv->link_id_db[i].status) {
 			priv->link_id_db[i].timestamp = jiffies;
 			ret = i + 1;
-- 
1.8.0
