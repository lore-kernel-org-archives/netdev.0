From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 2/3] gre: build header correctly for collect metadata tunnels
Date: Fri, 22 Apr 2016 19:44:07 +0200
Message-ID: <7778b1a1e2123d3c9bf541d671fe62caeb6e9fd5.1461346798.git.jbenc@redhat.com>
References: <cover.1461346798.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42262 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932384AbcDVRoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 13:44:23 -0400
In-Reply-To: <cover.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipgre (i.e. not gretap) + collect metadata mode, the skb was assumed to
contain Ethernet header and was encapsulated as ETH_P_TEB. This is not the
case, the interface is ARPHRD_IPGRE and the protocol to be used for
encapsulation is skb->protocol.

Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_gre.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d0abde4236af..f973e0a58993 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -523,7 +523,8 @@ static struct rtable *gre_get_rt(struct sk_buff *skb,
 	return ip_route_output_key(net, fl);
 }
 
-static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
+static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
+			__be16 proto)
 {
 	struct ip_tunnel_info *tun_info;
 	const struct ip_tunnel_key *key;
@@ -575,7 +576,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	flags = tun_info->key.tun_flags & (TUNNEL_CSUM | TUNNEL_KEY);
-	build_header(skb, tunnel_hlen, flags, htons(ETH_P_TEB),
+	build_header(skb, tunnel_hlen, flags, proto,
 		     tunnel_id_to_key(tun_info->key.tun_id), 0);
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
@@ -616,7 +617,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 	const struct iphdr *tnl_params;
 
 	if (tunnel->collect_md) {
-		gre_fb_xmit(skb, dev);
+		gre_fb_xmit(skb, dev, skb->protocol);
 		return NETDEV_TX_OK;
 	}
 
@@ -660,7 +661,7 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	if (tunnel->collect_md) {
-		gre_fb_xmit(skb, dev);
+		gre_fb_xmit(skb, dev, htons(ETH_P_TEB));
 		return NETDEV_TX_OK;
 	}
 
-- 
1.8.3.1
