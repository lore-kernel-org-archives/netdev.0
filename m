From: Joe Eykholt <jre@nuovasystems.com>
Subject: [PATCH 1/3] bonding: Uninline skb_bond().
Date: Sun, 04 May 2008 20:00:23 -0700
Message-ID: <20080505030023.18871.66057.stgit@feynman.nuovasystems.com>
References: <20080505025801.18871.89526.stgit@feynman.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.nuovasystems.com ([67.91.200.194]:7776 "EHLO
	feynman.nuovasystems.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752084AbYEEDbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 23:31:33 -0400
Received: from feynman.nuovasystems.com (feynman.nuovasystems.com [127.0.0.1])
	by feynman.nuovasystems.com (8.14.2/8.14.2) with ESMTP id m4530Nw7018921
	for <netdev@vger.kernel.org>; Sun, 4 May 2008 20:00:23 -0700
In-Reply-To: <20080505025801.18871.89526.stgit@feynman.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bonding: Uninline skb_bond().

Otherwise subsequent changes need multiple return values.

Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
---
 net/core/dev.c |   28 ++++++++--------------------
 1 files changed, 8 insertions(+), 20 deletions(-)


diff --git a/net/core/dev.c b/net/core/dev.c
index d334446..0335d24 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1816,22 +1816,6 @@ int netif_rx_ni(struct sk_buff *skb)
 
 EXPORT_SYMBOL(netif_rx_ni);
 
-static inline struct net_device *skb_bond(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-
-	if (dev->master) {
-		if (skb_bond_should_drop(skb)) {
-			kfree_skb(skb);
-			return NULL;
-		}
-		skb->dev = dev->master;
-	}
-
-	return dev;
-}
-
-
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
@@ -2036,10 +2020,14 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (!skb->iif)
 		skb->iif = skb->dev->ifindex;
 
-	orig_dev = skb_bond(skb);
-
-	if (!orig_dev)
-		return NET_RX_DROP;
+	orig_dev = skb->dev;
+	if (orig_dev->master) {
+		if (skb_bond_should_drop(skb)) {
+			kfree_skb(skb);
+			return NET_RX_DROP;
+		}
+		skb->dev = orig_dev->master;
+	}
 
 	__get_cpu_var(netdev_rx_stat).total++;
 


