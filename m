From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v2] net: adjust skb_gso_segment() for calling in rx path
Date: Wed,  6 Feb 2013 10:36:38 +0800
Message-ID: <1360118198-25440-1-git-send-email-amwang@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755684Ab3BFCg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 21:36:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

skb_gso_segment() is almost always called in tx path,
except for openvswitch. It calls this function when
it receives the packet and tries to queue it to user-space.
In this special case, the ->ip_summed check inside
skb_gso_segment() is no longer true, as ->ip_summed value
has different meanings on rx path.

This patch adjusts skb_gso_segment() so that we can at least
avoid such warnings on checksum.

Cc: Jesse Gross <jesse@nicira.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/netdevice.h  |   11 +++++++++--
 net/core/dev.c             |   21 ++++++++++++++++-----
 net/openvswitch/datapath.c |    2 +-
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 85b0949..ab2774e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2662,8 +2662,15 @@ extern int netdev_master_upper_dev_link(struct net_device *dev,
 extern void netdev_upper_dev_unlink(struct net_device *dev,
 				    struct net_device *upper_dev);
 extern int skb_checksum_help(struct sk_buff *skb);
-extern struct sk_buff *skb_gso_segment(struct sk_buff *skb,
-	netdev_features_t features);
+extern struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
+	netdev_features_t features, bool tx_path);
+
+static inline
+struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
+{
+	return __skb_gso_segment(skb, features, true);
+}
+
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
diff --git a/net/core/dev.c b/net/core/dev.c
index a87bc74..ac9a97a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2302,18 +2302,29 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+/* openvswitch calls this on rx path, so we need a different check.
+ */
+static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
+{
+	if (tx_path)
+		return skb->ip_summed != CHECKSUM_PARTIAL;
+	else
+		return skb->ip_summed == CHECKSUM_NONE;
+}
+
 /**
- *	skb_gso_segment - Perform segmentation on skb.
+ *	__skb_gso_segment - Perform segmentation on skb.
  *	@skb: buffer to segment
  *	@features: features for the output path (see dev->features)
+ *	@tx_path: whether it is called in TX path
  *
  *	This function segments the given skb and returns a list of segments.
  *
  *	It may return NULL if the skb requires no segmentation.  This is
  *	only possible when GSO is used for verifying header integrity.
  */
-struct sk_buff *skb_gso_segment(struct sk_buff *skb,
-	netdev_features_t features)
+struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
+				  netdev_features_t features, bool tx_path)
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_offload *ptype;
@@ -2336,7 +2347,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	skb->mac_len = skb->network_header - skb->mac_header;
 	__skb_pull(skb, skb->mac_len);
 
-	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+	if (unlikely(skb_needs_check(skb, tx_path))) {
 		skb_warn_bad_offload(skb);
 
 		if (skb_header_cloned(skb) &&
@@ -2365,7 +2376,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 
 	return segs;
 }
-EXPORT_SYMBOL(skb_gso_segment);
+EXPORT_SYMBOL(__skb_gso_segment);
 
 /* Take action when hardware reception checksum errors are detected. */
 #ifdef CONFIG_BUG
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d8c13a9..9dc537d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -301,7 +301,7 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
 	struct sk_buff *segs, *nskb;
 	int err;
 
-	segs = skb_gso_segment(skb, NETIF_F_SG | NETIF_F_HW_CSUM);
+	segs = __skb_gso_segment(skb, NETIF_F_SG | NETIF_F_HW_CSUM, false);
 	if (IS_ERR(segs))
 		return PTR_ERR(segs);
 
-- 
1.7.7.6
