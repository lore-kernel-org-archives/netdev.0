From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] llc: avoid skb_clone() if there is only one handler
Date: Tue, 22 Feb 2011 19:55:18 +0800
Message-ID: <1298375718-5052-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:59625 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab1BVL4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 06:56:11 -0500
Received: by pzk35 with SMTP id 35so247519pzk.19
        for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 03:56:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/llc/llc_input.c |   25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)
diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index f996874..058f1e9 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -181,25 +181,26 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * LLC functionality
 	 */
 	rcv = rcu_dereference(sap->rcv_func);
-	if (rcv) {
-		struct sk_buff *cskb = skb_clone(skb, GFP_ATOMIC);
-		if (cskb)
-			rcv(cskb, dev, pt, orig_dev);
-	}
 	dest = llc_pdu_type(skb);
-	if (unlikely(!dest || !llc_type_handlers[dest - 1]))
-		goto drop_put;
-	llc_type_handlers[dest - 1](sap, skb);
-out_put:
+	if (unlikely(!dest || !llc_type_handlers[dest - 1])) {
+		if (rcv)
+			rcv(skb, dev, pt, orig_dev);
+		else
+			kfree_skb(skb);
+	} else {
+		if (rcv) {
+			struct sk_buff *cskb = skb_clone(skb, GFP_ATOMIC);
+			if (cskb)
+				rcv(cskb, dev, pt, orig_dev);
+		}
+		llc_type_handlers[dest - 1](sap, skb);
+	}
 	llc_sap_put(sap);
 out:
 	return 0;
 drop:
 	kfree_skb(skb);
 	goto out;
-drop_put:
-	kfree_skb(skb);
-	goto out_put;
 handle_station:
 	if (!llc_station_handler)
 		goto drop;
