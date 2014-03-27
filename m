From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net] net: Account for all vlan headers in skb_mac_gso_segment
Date: Thu, 27 Mar 2014 17:26:18 -0400
Message-ID: <1395955578-16715-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279AbaC0V0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 17:26:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_network_protocol() already accounts for multiple vlan
headers that may be present in the skb.  However, skb_mac_gso_segment()
doesn't know anything about it and assumes that skb->mac_len
is set correctly to skip all mac headers.  That may not
always be the case.  If we are simply forwarding the packet (via
bridge or macvtap), all vlan headers may not be accounted for.

A simple solution is to allow skb_network_protocol to return
the vlan depth it has calculated.  This way skb_mac_gso_segment
will correctly skip all mac headers.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
Since v1:
 - Removed conditionals and used dummy variables as suggested by
   Eric Dumazet.

 include/linux/netdevice.h |  2 +-
 net/core/dev.c            | 13 +++++++++----
 net/core/skbuff.c         |  3 ++-
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d855794..18b8c1b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3015,7 +3015,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
 {
 	return __skb_gso_segment(skb, features, true);
 }
-__be16 skb_network_protocol(struct sk_buff *skb);
+__be16 skb_network_protocol(struct sk_buff *skb, int *depth);
 
 static inline bool can_checksum_protocol(netdev_features_t features,
 					 __be16 protocol)
diff --git a/net/core/dev.c b/net/core/dev.c
index a98f7fa..9708893 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2287,7 +2287,7 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
-__be16 skb_network_protocol(struct sk_buff *skb)
+__be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
 	int vlan_depth = ETH_HLEN;
@@ -2314,6 +2314,8 @@ __be16 skb_network_protocol(struct sk_buff *skb)
 		vlan_depth += VLAN_HLEN;
 	}
 
+	*depth = vlan_depth;
+
 	return type;
 }
 
@@ -2327,12 +2329,13 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_offload *ptype;
-	__be16 type = skb_network_protocol(skb);
+	int vlan_depth = skb->mac_len;
+	__be16 type = skb_network_protocol(skb, &vlan_depth);
 
 	if (unlikely(!type))
 		return ERR_PTR(-EINVAL);
 
-	__skb_pull(skb, skb->mac_len);
+	__skb_pull(skb, vlan_depth);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
@@ -2499,8 +2502,10 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 					    const struct net_device *dev,
 					    netdev_features_t features)
 {
+	int tmp;
+
 	if (skb->ip_summed != CHECKSUM_NONE &&
-	    !can_checksum_protocol(features, skb_network_protocol(skb))) {
+	    !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {
 		features &= ~NETIF_F_ALL_CSUM;
 	} else if (illegal_highdma(dev, skb)) {
 		features &= ~NETIF_F_SG;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 869c7af..cac38ba 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2866,8 +2866,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	int err = -ENOMEM;
 	int i = 0;
 	int pos;
+	int dummy;
 
-	proto = skb_network_protocol(head_skb);
+	proto = skb_network_protocol(head_skb, &dummy);
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
-- 
1.8.5.3
