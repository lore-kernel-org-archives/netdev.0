From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 1/3] offloading: Make scatter/gather more tolerant of vlans.
Date: Fri, 29 Oct 2010 15:14:53 -0700
Message-ID: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50140 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932900Ab0J2WPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 18:15:03 -0400
Received: by qwf7 with SMTP id 7so2743176qwf.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 15:15:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When checking if it is necessary to linearize a packet, we currently
use vlan_features if the packet contains either an in-band or out-
of-band vlan tag.  However, in-band tags aren't special in any way
for scatter/gather since they are part of the packet buffer and are
simply more data to DMA.  Therefore, only use vlan_features for out-
of-band tags, which could potentially have some interaction with
scatter/gather.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 35dfb83..d21d655 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1977,15 +1977,20 @@ static inline void skb_orphan_try(struct sk_buff *skb)
 static inline int skb_needs_linearize(struct sk_buff *skb,
 				      struct net_device *dev)
 {
-	int features = dev->features;
+	if (skb_is_nonlinear(skb)) {
+		int features = dev->features;
 
-	if (skb->protocol == htons(ETH_P_8021Q) || vlan_tx_tag_present(skb))
-		features &= dev->vlan_features;
+		if (vlan_tx_tag_present(skb))
+			features &= dev->vlan_features;
 
-	return skb_is_nonlinear(skb) &&
-	       ((skb_has_frag_list(skb) && !(features & NETIF_F_FRAGLIST)) ||
-		(skb_shinfo(skb)->nr_frags && (!(features & NETIF_F_SG) ||
-					      illegal_highdma(dev, skb))));
+		return (skb_has_frag_list(skb) &&
+			!(features & NETIF_F_FRAGLIST)) ||
+			(skb_shinfo(skb)->nr_frags &&
+			(!(features & NETIF_F_SG) ||
+			illegal_highdma(dev, skb)));
+	}
+
+	return 0;
 }
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-- 
1.7.1

