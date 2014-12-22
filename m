From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: ndo_gso_check() must force segmentation
Date: Mon, 22 Dec 2014 07:21:37 -0800
Message-ID: <1419261697.11185.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417020748.29427.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.120658.498602780456343676.davem@davemloft.net>
	 <1417027459.29427.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.153356.461494573591656082.davem@davemloft.net>
	 <0835B3720019904CB8F7AA43166CEEB2ED585A@RTITMBSV03.realtek.com.tw>
	 <1419010603.9773.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1419012837.9773.85.camel@edumazet-glaptop2.roam.corp.google.com>
	  <0835B3720019904CB8F7AA43166CEEB2ED5B01@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32843 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152AbaLVPVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 10:21:39 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so6090800pab.21
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 07:21:39 -0800 (PST)
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2ED5B01@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If ndo_gso_check() returns true, it means a driver wants the stack
to perform software segmentation, even if device features initially
claimed hardware was able handle a TSO packet. 

This means netif_needs_gso() needs to modify the features.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Hayes Wang <hayeswang@realtek.com>
Tested-by: Hayes Wang <hayeswang@realtek.com>
Fixes: 04ffcb255f22 ("net: Add ndo_gso_check")
---
 drivers/net/macvtap.c      |    2 +-
 drivers/net/xen-netfront.c |    4 +++-
 include/linux/netdevice.h  |   18 ++++++++++++------
 net/core/dev.c             |    2 +-
 4 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7df221788cd4..0346bcfe72a5 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -314,7 +314,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 	 */
 	if (q->flags & IFF_VNET_HDR)
 		features |= vlan->tap_features;
-	if (netif_needs_gso(dev, skb, features)) {
+	if (netif_needs_gso(dev, skb, &features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
 		if (IS_ERR(segs))
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 22bcb4e12e2a..9cacabaea175 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -578,6 +578,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	struct netfront_queue *queue = NULL;
 	unsigned int num_queues = dev->real_num_tx_queues;
+	netdev_features_t features;
 	u16 queue_index;
 
 	/* Drop the packet if no queues are set up */
@@ -611,9 +612,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&queue->tx_lock, flags);
 
+	features = netif_skb_features(skb);
 	if (unlikely(!netif_carrier_ok(dev) ||
 		     (slots > 1 && !xennet_can_sg(dev)) ||
-		     netif_needs_gso(dev, skb, netif_skb_features(skb)))) {
+		     netif_needs_gso(dev, skb, &features))) {
 		spin_unlock_irqrestore(&queue->tx_lock, flags);
 		goto drop;
 	}
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c31f74d76ebd..fb1f8c900df9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3608,13 +3608,19 @@ static inline bool skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
 }
 
 static inline bool netif_needs_gso(struct net_device *dev, struct sk_buff *skb,
-				   netdev_features_t features)
+				   netdev_features_t *features)
 {
-	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
-		(dev->netdev_ops->ndo_gso_check &&
-		 !dev->netdev_ops->ndo_gso_check(skb, dev)) ||
-		unlikely((skb->ip_summed != CHECKSUM_PARTIAL) &&
-			 (skb->ip_summed != CHECKSUM_UNNECESSARY)));
+	if (!skb_is_gso(skb))
+		return false;
+	if (!skb_gso_ok(skb, *features))
+		return true;
+	if (dev->netdev_ops->ndo_gso_check &&
+	    !dev->netdev_ops->ndo_gso_check(skb, dev)) {
+		*features &= ~NETIF_F_GSO_MASK;
+		return true;
+	}
+	return skb->ip_summed != CHECKSUM_PARTIAL &&
+	       skb->ip_summed != CHECKSUM_UNNECESSARY;
 }
 
 static inline void netif_set_gso_max_size(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index f411c28d0a66..b61c26b45bb7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2668,7 +2668,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 	if (skb->encapsulation)
 		features &= dev->hw_enc_features;
 
-	if (netif_needs_gso(dev, skb, features)) {
+	if (netif_needs_gso(dev, skb, &features)) {
 		struct sk_buff *segs;
 
 		segs = skb_gso_segment(skb, features);
