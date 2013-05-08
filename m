From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH] gso: Handle Trans-Ether-Bridging protocol in skb_network_protocol()
Date: Tue,  7 May 2013 23:41:07 -0700
Message-ID: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:46034 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752082Ab3EHGlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 02:41:13 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so1101583pad.30
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 23:41:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than having logic to calculate inner protocol in every
tunnel gso handler move it to gso code. This simplifies code.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Cong Wang <amwang@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/dev.c |   11 +++++++++++
 net/ipv4/gre.c |    8 +-------
 net/ipv4/udp.c |    4 +---
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 40b1fad..fc1e289 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2213,6 +2213,17 @@ __be16 skb_network_protocol(struct sk_buff *skb)
 	__be16 type = skb->protocol;
 	int vlan_depth = ETH_HLEN;
 
+	/* Tunnel gso handlers can set protocol to ethernet. */
+	if (type == htons(ETH_P_TEB)) {
+		struct ethhdr *eth;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))
+			return 0;
+
+		eth = (struct ethhdr *)skb_mac_header(skb);
+		type = eth->h_proto;
+	}
+
 	while (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
 		struct vlan_hdr *vh;
 
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index cc22363..b2e805a 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -150,13 +150,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		csum = false;
 
 	/* setup inner skb. */
-	if (greh->protocol == htons(ETH_P_TEB)) {
-		struct ethhdr *eth = (struct ethhdr *)skb_inner_mac_header(skb);
-		skb->protocol = eth->h_proto;
-	} else {
-		skb->protocol = greh->protocol;
-	}
-
+	skb->protocol = greh->protocol;
 	skb->encapsulation = 0;
 
 	if (unlikely(!pskb_may_pull(skb, ghl)))
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0ae038a..0bf5d39 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2311,7 +2311,6 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	struct ethhdr *inner_eth = (struct ethhdr *)skb_inner_mac_header(skb);
 	__be16 protocol = skb->protocol;
 	netdev_features_t enc_features;
 	int outer_hlen;
@@ -2324,8 +2323,7 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
-	inner_eth = (struct ethhdr *)skb_mac_header(skb);
-	skb->protocol = inner_eth->h_proto;
+	skb->protocol = htons(ETH_P_TEB);
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
-- 
1.7.1
