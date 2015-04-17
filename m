From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: remove unused 'dev' argument from netif_needs_gso()
Date: Fri, 17 Apr 2015 15:45:04 +0200
Message-ID: <1429278304-22260-1-git-send-email-johannes@sipsolutions.net>
Cc: Tom Herbert <therbert@google.com>, Jesse Gross <jesse@nicira.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47309 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933012AbbDQNpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2015 09:45:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

In commit 04ffcb255f22 ("net: Add ndo_gso_check") Tom originally
added the 'dev' argument to be able to call ndo_gso_check().

Then later, when generalizing this in commit 5f35227ea34b
("net: Generalize ndo_gso_check to ndo_features_check")
Jesse removed the call to ndo_gso_check() in netif_needs_gso()
by calling the new ndo_features_check() in a different place.
This made the 'dev' argument unused.

Remove the unused argument and go back to the code as before.

Cc: Tom Herbert <therbert@google.com>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/macvtap.c      | 2 +-
 drivers/net/xen-netfront.c | 2 +-
 include/linux/netdevice.h  | 2 +-
 net/core/dev.c             | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8362aef0c15e..58c6ba5746d5 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -313,7 +313,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 	 */
 	if (q->flags & IFF_VNET_HDR)
 		features |= vlan->tap_features;
-	if (netif_needs_gso(dev, skb, features)) {
+	if (netif_needs_gso(skb, features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
 		if (IS_ERR(segs))
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 720aaf6313d2..8dcf31063e9a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -560,7 +560,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(!netif_carrier_ok(dev) ||
 		     (slots > 1 && !xennet_can_sg(dev)) ||
-		     netif_needs_gso(dev, skb, netif_skb_features(skb)))) {
+		     netif_needs_gso(skb, netif_skb_features(skb)))) {
 		spin_unlock_irqrestore(&queue->tx_lock, flags);
 		goto drop;
 	}
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b5679aed660b..bcbde799ec69 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3713,7 +3713,7 @@ static inline bool skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
 	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
 }
 
-static inline bool netif_needs_gso(struct net_device *dev, struct sk_buff *skb,
+static inline bool netif_needs_gso(struct sk_buff *skb,
 				   netdev_features_t features)
 {
 	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
diff --git a/net/core/dev.c b/net/core/dev.c
index af4a1b0adc10..1796cef55ab5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2713,7 +2713,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 	if (unlikely(!skb))
 		goto out_null;
 
-	if (netif_needs_gso(dev, skb, features)) {
+	if (netif_needs_gso(skb, features)) {
 		struct sk_buff *segs;
 
 		segs = skb_gso_segment(skb, features);
-- 
2.1.4
