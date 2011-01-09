From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 4/6] offloading: Convert dev_gso_segment() to use precomputed features.
Date: Sun,  9 Jan 2011 08:23:33 -0800
Message-ID: <1294590215-15541-4-git-send-email-jesse@nicira.com>
References: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:48080 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab1AIQXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:23:47 -0500
Received: by ywl5 with SMTP id 5so7269958ywl.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:23:47 -0800 (PST)
In-Reply-To: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This switches dev_gso_segment() to use the device features computed
by the centralized routine.  In doing so, it fixes a problem where
it would always use dev->features, instead of those appropriate
to the number of vlan tags if any are present.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/core/dev.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1444ed3..4cd3e84 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1971,16 +1971,14 @@ static void dev_gso_skb_destructor(struct sk_buff *skb)
 /**
  *	dev_gso_segment - Perform emulated hardware segmentation on skb.
  *	@skb: buffer to segment
+ *	@features: device features as applicable to this skb
  *
  *	This function segments the given skb and stores the list of segments
  *	in skb->next.
  */
-static int dev_gso_segment(struct sk_buff *skb)
+static int dev_gso_segment(struct sk_buff *skb, int features)
 {
-	struct net_device *dev = skb->dev;
 	struct sk_buff *segs;
-	int features = dev->features & ~(illegal_highdma(dev, skb) ?
-					 NETIF_F_SG : 0);
 
 	segs = skb_gso_segment(skb, features);
 
@@ -2112,7 +2110,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		if (netif_needs_gso(skb, features)) {
-			if (unlikely(dev_gso_segment(skb)))
+			if (unlikely(dev_gso_segment(skb, features)))
 				goto out_kfree_skb;
 			if (skb->next)
 				goto gso;
-- 
1.7.1

