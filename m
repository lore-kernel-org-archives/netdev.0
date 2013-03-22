From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 2/2] udp: increase inner ip header ID during segmentation
Date: Fri, 22 Mar 2013 18:31:32 +0800
Message-ID: <1363948292-9902-2-git-send-email-amwang@redhat.com>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
 <1363948292-9902-1-git-send-email-amwang@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751862Ab3CVKcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 06:32:07 -0400
In-Reply-To: <1363948292-9902-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Similar to GRE tunnel, UDP tunnel should take care of IP header ID
too.

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/udp.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7117d14..3c362ee 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2304,7 +2304,8 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	int outer_hlen;
+	int outer_hlen, id;
+	struct iphdr *iph;
 	netdev_features_t enc_features;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
@@ -2315,6 +2316,8 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
+	iph = ip_hdr(skb);
+	id = ntohs(iph->id);
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
@@ -2329,6 +2332,8 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 		int udp_offset = outer_hlen - tnl_hlen;
 
 		skb->mac_len = mac_len;
+		iph = (struct iphdr *)skb_inner_network_header(skb);
+		iph->id = htons(id++);
 
 		skb_push(skb, outer_hlen);
 		skb_reset_mac_header(skb);
-- 
1.7.7.6
