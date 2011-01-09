From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 5/6] offloading: Convert skb_need_linearize() to use precomputed features.
Date: Sun,  9 Jan 2011 08:23:34 -0800
Message-ID: <1294590215-15541-5-git-send-email-jesse@nicira.com>
References: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43182 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab1AIQXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:23:49 -0500
Received: by yxt3 with SMTP id 3so7283890yxt.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:23:49 -0800 (PST)
In-Reply-To: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This switches skb_need_linearize() to use the features that have
been centrally computed.  In doing so, this fixes a problem where
scatter/gather should not be used because the card does not support
checksum offloading on that type of packet.  On device registration
we only check that some form of checksum offloading is available if
scatter/gatther is enabled but we must also check at transmission
time.  Examples of this include IPv6 or vlan packets on a NIC that
only supports IPv4 offloading.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/core/dev.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4cd3e84..2f838f1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2059,22 +2059,13 @@ EXPORT_SYMBOL(netif_skb_features);
  *	   support DMA from it.
  */
 static inline int skb_needs_linearize(struct sk_buff *skb,
-				      struct net_device *dev)
+				      int features)
 {
-	if (skb_is_nonlinear(skb)) {
-		int features = dev->features;
-
-		if (vlan_tx_tag_present(skb))
-			features &= dev->vlan_features;
-
-		return (skb_has_frag_list(skb) &&
-			!(features & NETIF_F_FRAGLIST)) ||
+	return skb_is_nonlinear(skb) &&
+			((skb_has_frag_list(skb) &&
+				!(features & NETIF_F_FRAGLIST)) ||
 			(skb_shinfo(skb)->nr_frags &&
-			(!(features & NETIF_F_SG) ||
-			illegal_highdma(dev, skb)));
-	}
-
-	return 0;
+				!(features & NETIF_F_SG)));
 }
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
@@ -2115,7 +2106,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			if (skb->next)
 				goto gso;
 		} else {
-			if (skb_needs_linearize(skb, dev) &&
+			if (skb_needs_linearize(skb, features) &&
 			    __skb_linearize(skb))
 				goto out_kfree_skb;
 
-- 
1.7.1

