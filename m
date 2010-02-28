From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/13] bridge: Use BR_INPUT_SKB_CB on xmit path
Date: Sun, 28 Feb 2010 13:41:42 +0800
Message-ID: <E1NlbuQ-00020u-RC@gondolin.me.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42742 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751849Ab0B1Flp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:41:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Use BR_INPUT_SKB_CB on xmit path

this patch makes BR_INPUT_SKB_CB available on the xmit path so
that we could avoid passing the br pointer around for the purpose
of collecting device statistics.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_device.c  |    2 ++
 net/bridge/br_forward.c |    5 +++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 1a99c4e..be35629 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -26,6 +26,8 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
 
+	BR_INPUT_SKB_CB(skb)->brdev = dev;
+
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 6cd50c6..2e1cb43 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -111,6 +111,7 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
+	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
 
 	prev = NULL;
 
@@ -120,7 +121,7 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 				struct sk_buff *skb2;
 
 				if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
-					br->dev->stats.tx_dropped++;
+					dev->stats.tx_dropped++;
 					goto out;
 				}
 
@@ -137,7 +138,7 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	if (skb0) {
 		skb = skb_clone(skb, GFP_ATOMIC);
 		if (!skb) {
-			br->dev->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			goto out;
 		}
 	}
