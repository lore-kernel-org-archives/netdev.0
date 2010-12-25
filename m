From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: bridge: check the length of skb after nf_bridge_maybe_copy_header()
Date: Sat, 25 Dec 2010 21:41:30 +0800
Message-ID: <1293284490-17114-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51496 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab0LYNmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 08:42:21 -0500
Received: by iyi12 with SMTP id 12so6376750iyi.19
        for <netdev@vger.kernel.org>; Sat, 25 Dec 2010 05:42:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since nf_bridge_maybe_copy_header() may change the length of skb,
we should check the length of skb after it to handle the ppoe skbs.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/bridge/br_forward.c |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 2bd11ec..ee64287 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -41,17 +41,13 @@ static inline unsigned packet_length(const struct sk_buff *skb)
 
 int br_dev_queue_push_xmit(struct sk_buff *skb)
 {
-	/* drop mtu oversized packets except gso */
-	if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
+	/* ip_fragment doesn't copy the MAC header */
+	if (nf_bridge_maybe_copy_header(skb) ||
+	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
 		kfree_skb(skb);
-	else {
-		/* ip_fragment doesn't copy the MAC header */
-		if (nf_bridge_maybe_copy_header(skb))
-			kfree_skb(skb);
-		else {
-			skb_push(skb, ETH_HLEN);
-			dev_queue_xmit(skb);
-		}
+	} else {
+		skb_push(skb, ETH_HLEN);
+		dev_queue_xmit(skb);
 	}
 
 	return 0;
