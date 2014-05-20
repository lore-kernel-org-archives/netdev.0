From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] vlan: Fix build error wth vlan_get_encap_level()
Date: Tue, 20 May 2014 10:59:26 -0400
Message-ID: <1400597966-2825-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976AbaETO7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 10:59:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new function vlan_get_encap_level() uses vlan_dev_priv()
which is only conditionally avaialble when VLAN support is
enabled.  Make vlan_get_encap_level() conditionally available
as well.

Fixes: 44a4085538c8 ("bonding: Fix stacked device detection in arp monitoring")
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_vlan.h | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index c901b13..b2acc4a 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -198,6 +198,12 @@ extern void vlan_vids_del_by_dev(struct net_device *dev,
 				 const struct net_device *by_dev);
 
 extern bool vlan_uses_dev(const struct net_device *dev);
+
+static inline int vlan_get_encap_level(struct net_device *dev)
+{
+	BUG_ON(!is_vlan_dev(dev));
+	return vlan_dev_priv(dev)->nest_level;
+}
 #else
 static inline struct net_device *
 __vlan_find_dev_deep(struct net_device *real_dev,
@@ -264,6 +270,11 @@ static inline bool vlan_uses_dev(const struct net_device *dev)
 {
 	return false;
 }
+static inline int vlan_get_encap_level(struct net_device *dev)
+{
+	BUG();
+	return 0;
+}
 #endif
 
 static inline bool vlan_hw_offload_capable(netdev_features_t features,
@@ -485,9 +496,4 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
 		skb->protocol = htons(ETH_P_802_2);
 }
 
-static inline int vlan_get_encap_level(struct net_device *dev)
-{
-	BUG_ON(!is_vlan_dev(dev));
-	return vlan_dev_priv(dev)->nest_level;
-}
 #endif /* !(_LINUX_IF_VLAN_H_) */
-- 
1.9.0
