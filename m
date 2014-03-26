From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] net: Account for all vlan headers in skb_mac_gso_segment
Date: Wed, 26 Mar 2014 11:51:11 -0400
Message-ID: <1395849071-15432-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754790AbaCZPv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 11:51:27 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2QFpQ49003960
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 11:51:27 -0400
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
 include/linux/netdevice.h |  2 +-
 net/core/dev.c            | 12 ++++++++----
 net/core/skbuff.c         |  2 +-
 3 files changed, 10 insertions(+), 6 deletions(-)

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
index a98f7fa..49c41e6 100644
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
@@ -2314,6 +2314,9 @@ __be16 skb_network_protocol(struct sk_buff *skb)
 		vlan_depth += VLAN_HLEN;
 	}
 
+	if (depth)
+		*depth = vlan_depth;
+
 	return type;
 }
 
@@ -2327,12 +2330,13 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_offload *ptype;
-	__be16 type = skb_network_protocol(skb);
+	int vlan_depth = 0;
+	__be16 type = skb_network_protocol(skb, &vlan_depth);
 
 	if (unlikely(!type))
 		return ERR_PTR(-EINVAL);
 
-	__skb_pull(skb, skb->mac_len);
+	__skb_pull(skb, vlan_depth > skb->mac_len ? vlan_depth : skb->mac_len);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
@@ -2500,7 +2504,7 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 					    netdev_features_t features)
 {
 	if (skb->ip_summed != CHECKSUM_NONE &&
-	    !can_checksum_protocol(features, skb_network_protocol(skb))) {
+	    !can_checksum_protocol(features, skb_network_protocol(skb, NULL))) {
 		features &= ~NETIF_F_ALL_CSUM;
 	} else if (illegal_highdma(dev, skb)) {
 		features &= ~NETIF_F_SG;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 869c7af..25d8cd8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2867,7 +2867,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	int i = 0;
 	int pos;
 
-	proto = skb_network_protocol(head_skb);
+	proto = skb_network_protocol(head_skb, NULL);
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
-- 
1.8.5.3
