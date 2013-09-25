From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] ip_tunnel: Do not use stale inner_iph pointer.
Date: Wed, 25 Sep 2013 09:57:47 -0700
Message-ID: <1380128267-16123-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:58612 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751993Ab3IYQ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 12:57:56 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so6233350pbc.39
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 09:57:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While sending packet skb_cow_head() can change skb header which
invalidates inner_iph pointer to skb header. Following patch
avoid using it. Found by code inspection.

This bug was introduced by commit 0e6fbc5b6c6218 (ip_tunnels: extend
iptunnel_xmit()).

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_tunnel.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index ac9fabe..d3fbad4 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -623,6 +623,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 			tunnel->err_count = 0;
 	}
 
+	tos = ip_tunnel_ecn_encap(tos, inner_iph, skb);
 	ttl = tnl_params->ttl;
 	if (ttl == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
@@ -651,8 +652,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
-			    ip_tunnel_ecn_encap(tos, inner_iph, skb), ttl, df,
-			    !net_eq(tunnel->net, dev_net(dev)));
+			    tos, ttl, df, !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 
 	return;
-- 
1.7.1
