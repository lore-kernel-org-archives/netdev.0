From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch] mac80211: fix memory leak when defraging packets
Date: Thu, 17 May 2007 13:23:56 -0400
Message-ID: <20070517172356.GC7720@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4348 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102AbXEQRcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 13:32:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hong Liu <hong.liu@intel.com>

We forget to free all the fragments when defraging them into one packet.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 net/mac80211/ieee80211.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 873ccb0..ed86804 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -3412,8 +3412,10 @@ ieee80211_rx_h_defragment(struct ieee80211_txrx_data *rx)
 			return TXRX_DROP;
 		}
 	}
-	while ((skb = __skb_dequeue(&entry->skb_list)))
+	while ((skb = __skb_dequeue(&entry->skb_list))) {
 		memcpy(skb_put(rx->skb, skb->len), skb->data, skb->len);
+		dev_kfree_skb(skb);
+	}
 
 	/* Complete frame has been reassembled - process it now */
 	rx->fragmented = 1;
