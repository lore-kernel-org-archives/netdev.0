From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/5] net/core: Uninline skb_bond().
Date: Wed,  2 Jul 2008 18:22:00 -0700
Message-ID: <12150481262025-git-send-email-fubar@us.ibm.com>
References: <12150481222323-git-send-email-fubar@us.ibm.com>
 <12150481241992-git-send-email-fubar@us.ibm.com>
 <1215048125108-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Joe Eykholt <jre@nuovasystems.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33313 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbYGCBWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 21:22:09 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m631M8i7022798
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:08 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m631M8mZ182436
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:08 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m631M704004188
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:08 -0400
In-Reply-To: <1215048125108-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Eykholt <jre@nuovasystems.com>

Otherwise subsequent changes need multiple return values.

Signed-off-by: Joe Eykholt <jre@nuovasystems.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 net/core/dev.c |   28 ++++++++--------------------
 1 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f6944ec..78114f6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1872,22 +1872,6 @@ int netif_rx_ni(struct sk_buff *skb)
 
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
@@ -2092,10 +2076,14 @@ int netif_receive_skb(struct sk_buff *skb)
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
 
-- 
1.5.2.4

