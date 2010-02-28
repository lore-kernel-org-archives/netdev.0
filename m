From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/13] bridge: Allow tail-call on br_pass_frame_up
Date: Sun, 28 Feb 2010 13:41:40 +0800
Message-ID: <E1NlbuO-00020c-LV@gondolin.me.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42736 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751531Ab0B1Fln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:41:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Allow tail-call on br_pass_frame_up

This patch allows tail-call on the call to br_pass_frame_up
in br_handle_frame_finish.  This is now possible because of the
previous patch to call br_pass_frame_up last.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_input.c   |   12 +++++++-----
 net/bridge/br_private.h |    6 ++++++
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 9589937..be5ab8d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -20,9 +20,9 @@
 /* Bridge group multicast address 802.1d (pg 51). */
 const u8 br_group_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
 
-static void br_pass_frame_up(struct net_bridge *br, struct sk_buff *skb)
+static int br_pass_frame_up(struct sk_buff *skb)
 {
-	struct net_device *indev, *brdev = br->dev;
+	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
 
 	brdev->stats.rx_packets++;
 	brdev->stats.rx_bytes += skb->len;
@@ -30,8 +30,8 @@ static void br_pass_frame_up(struct net_bridge *br, struct sk_buff *skb)
 	indev = skb->dev;
 	skb->dev = brdev;
 
-	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
-		netif_receive_skb);
+	return NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
+		       netif_receive_skb);
 }
 
 /* note: already called with rcu_read_lock (preempt_disabled) */
@@ -53,6 +53,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (p->state == BR_STATE_LEARNING)
 		goto drop;
 
+	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
+
 	/* The packet skb2 goes to the local host (NULL to skip). */
 	skb2 = NULL;
 
@@ -81,7 +83,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	}
 
 	if (skb2)
-		br_pass_frame_up(br, skb2);
+		return br_pass_frame_up(skb2);
 
 out:
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2114e45..a38d738 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -132,6 +132,12 @@ struct net_bridge
 	struct kobject			*ifobj;
 };
 
+struct br_input_skb_cb {
+	struct net_device *brdev;
+};
+
+#define BR_INPUT_SKB_CB(__skb)	((struct br_input_skb_cb *)(__skb)->cb)
+
 extern struct notifier_block br_device_notifier;
 extern const u8 br_group_address[ETH_ALEN];
 
