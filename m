From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] vxlan: Fix TCPv6 segmentation.
Date: Thu,  2 May 2013 19:17:02 -0700
Message-ID: <1367547422-18122-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:55381 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757804Ab3ECCRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 22:17:24 -0400
Received: by mail-da0-f72.google.com with SMTP id a4so1121724dad.3
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 19:17:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set correct skb->protocol so that inner packet can
lookup correct gso handler.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Same issue exist in 3.8.
---
 net/ipv4/udp.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6abbe64..0ae038a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2311,8 +2311,10 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	int outer_hlen;
+	struct ethhdr *inner_eth = (struct ethhdr *)skb_inner_mac_header(skb);
+	__be16 protocol = skb->protocol;
 	netdev_features_t enc_features;
+	int outer_hlen;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
@@ -2322,6 +2324,8 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
+	inner_eth = (struct ethhdr *)skb_mac_header(skb);
+	skb->protocol = inner_eth->h_proto;
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
@@ -2358,6 +2362,7 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 
 		}
 		skb->ip_summed = CHECKSUM_NONE;
+		skb->protocol = protocol;
 	} while ((skb = skb->next));
 out:
 	return segs;
-- 
1.7.1
