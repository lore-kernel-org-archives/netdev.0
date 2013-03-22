From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ip_gre: increase inner ip header ID during segmentation
Date: Fri, 22 Mar 2013 15:50:00 +0800
Message-ID: <1363938600-26129-1-git-send-email-amwang@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740Ab3CVHu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 03:50:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

According to the previous discussion [1] on netdev list, DaveM insists
we should increase the IP header ID for each segmented packets.
This patch fixes it.

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

1. http://marc.info/?t=136384172700001&r=1&w=2

---
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 7a4c710..3cf20a4 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -125,9 +125,11 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	netdev_features_t enc_features;
 	int ghl = GRE_HEADER_SECTION;
 	struct gre_base_hdr *greh;
+	struct iphdr *iph;
 	int mac_len = skb->mac_len;
 	int tnl_hlen;
 	bool csum;
+	__be16 id;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
 				~(SKB_GSO_TCPV4 |
@@ -170,6 +172,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 
+	iph = (struct iphdr *)skb->data;
+	id = iph->id;
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
@@ -179,6 +183,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb = segs;
 	tnl_hlen = skb_tnl_header_len(skb);
 	do {
+		iph = (struct iphdr *)skb->data;
+		iph->id = id++;
 		__skb_push(skb, ghl);
 		if (csum) {
 			__be32 *pcsum;
