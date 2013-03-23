From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] ip_gre: increase inner ip header ID only for IPv4
Date: Sat, 23 Mar 2013 13:29:44 +0800
Message-ID: <1364016584-7189-1-git-send-email-amwang@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535Ab3CWFaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Mar 2013 01:30:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Pravin pointed out the inner network header of a GRE tunnel packet
could be IPv6, where there is no ID. So we should check the version.

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index e20631c..a2516f5 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -128,7 +128,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	struct iphdr *iph;
 	int mac_len = skb->mac_len;
 	int tnl_hlen, id;
-	bool csum;
+	bool csum, ipv4;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
 				~(SKB_GSO_TCPV4 |
@@ -172,7 +172,12 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb->mac_len = skb_inner_network_offset(skb);
 
 	iph = ip_hdr(skb);
-	id = ntohs(iph->id);
+	if (iph->version == 4) {
+		ipv4 = true;
+		id = ntohs(iph->id);
+	} else
+		ipv4 = false;
+
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
@@ -182,8 +187,10 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb = segs;
 	tnl_hlen = skb_tnl_header_len(skb);
 	do {
-		iph = (struct iphdr *)skb->data;
-		iph->id = htons(id++);
+		if (ipv4) {
+			iph = (struct iphdr *)skb->data;
+			iph->id = htons(id++);
+		}
 		__skb_push(skb, ghl);
 		if (csum) {
 			__be32 *pcsum;
