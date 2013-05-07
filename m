From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] gre: verify packet before using inner header
Date: Tue,  7 May 2013 16:20:50 +0800
Message-ID: <1367914850-11055-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48923 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758757Ab3EGIV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 May 2013 04:21:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

We use ->h_proto of the inner mac header before calling
pskb_may_pull() to verify the length of the packet.
This might not be a problem, but at least we'd better
error out as early as possible.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index cc22363..8a90c67 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -149,6 +149,9 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	} else
 		csum = false;
 
+	if (unlikely(!pskb_may_pull(skb, ghl)))
+		goto out;
+
 	/* setup inner skb. */
 	if (greh->protocol == htons(ETH_P_TEB)) {
 		struct ethhdr *eth = (struct ethhdr *)skb_inner_mac_header(skb);
@@ -158,9 +161,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	}
 
 	skb->encapsulation = 0;
-
-	if (unlikely(!pskb_may_pull(skb, ghl)))
-		goto out;
 	__skb_pull(skb, ghl);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
