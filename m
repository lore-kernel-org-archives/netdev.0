From: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2] mac80211: rx: frames received out of order
Date: Wed, 13 Jul 2016 14:57:56 +0300
Message-ID: <20160713115758.25395-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>, Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>

Upon forwarding frames from Rx to Tx in mesh, driver clones the skb.
It zeros the tx_info and doesn't set hw_queue correctly. It then enqueues
the frame in queue 0 (VOICE) instead of the correct queue.
Upon re-queue of this frame, driver inserts it to the correct queue (e.g. BE).
After that, driver dequeue frames from 2 different queues and sends them out of order.
To fix this, driver will set the tx_info->hw_queue to the correct queue when cloning the skb.

Signed-off-by: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>
Signed-off-by: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
---
V2 - Revised comment

 net/mac80211/rx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 9a1eb70..88dc744 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2392,6 +2392,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 	info->flags |= IEEE80211_TX_INTFL_NEED_TXPROCESSING;
 	info->control.vif = &rx->sdata->vif;
 	info->control.jiffies = jiffies;
+	info->hw_queue = q;
 	if (is_multicast_ether_addr(fwd_hdr->addr1)) {
 		IEEE80211_IFSTA_MESH_CTR_INC(ifmsh, fwded_mcast);
 		memcpy(fwd_hdr->addr2, sdata->vif.addr, ETH_ALEN);
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
