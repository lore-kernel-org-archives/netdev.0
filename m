From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] ip_tunnel: fix ipv4 pmtu check to honor inner ip header df
Date: Mon,  6 Jul 2015 11:35:50 +0300
Message-ID: <1436171750-6029-1-git-send-email-timo.teras@iki.fi>
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:34077 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbGFIgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 04:36:02 -0400
Received: by lagx9 with SMTP id x9so145477108lag.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 01:36:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frag needed should be sent only if the inner header asked
to not fragment. Currently fragmentation is broken if the
tunnel has df set. The tunnel's df needs to be still checked
to update internally the pmtu cache.

This got broken in commit 23a3647bc4f93bac and this fixes
the pmtu check back to the way it was.

Fixes: 23a3647bc4f93bac ("ip_tunnels: Use skb-len to PMTU check.")
Cc: Pravin B Shelar <pshelar@nicira.com>
---
Should go to -stable queues (3.12.y and never).

 net/ipv4/ip_tunnel.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0bb8e14..6822572 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -587,7 +587,8 @@ int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 EXPORT_SYMBOL(ip_tunnel_encap);
 
 static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
-			    struct rtable *rt, __be16 df)
+			    struct rtable *rt, __be16 df,
+			    const struct iphdr *inner_iph)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	int pkt_size = skb->len - tunnel->hlen - dev->hard_header_len;
@@ -604,7 +605,8 @@ static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		if (!skb_is_gso(skb) &&
-		    (df & htons(IP_DF)) && mtu < pkt_size) {
+		    (inner_iph->frag_off & htons(IP_DF)) &&
+		    mtu < pkt_size) {
 			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 			return -E2BIG;
@@ -738,7 +740,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off)) {
+	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off, inner_iph)) {
 		ip_rt_put(rt);
 		goto tx_error;
 	}
-- 
2.4.5
