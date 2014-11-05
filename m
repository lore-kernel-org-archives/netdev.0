From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC net] ip_tunnel: Respect the IP_DF bit of the inner packet.
Date: Wed, 5 Nov 2014 09:09:30 +0100
Message-ID: <20141105080930.GE6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43537 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbaKEIJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 03:09:38 -0500
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id 6186B1A008B
	for <netdev@vger.kernel.org>; Wed,  5 Nov 2014 09:09:30 +0100 (CET)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id mtclzp2HfxO7 for <netdev@vger.kernel.org>;
	Wed,  5 Nov 2014 09:09:25 +0100 (CET)
Received: from mail-essen-01.secunet.de (unknown [10.53.40.204])
	by a.mx.secunet.com (Postfix) with ESMTP id 565FB1A0088
	for <netdev@vger.kernel.org>; Wed,  5 Nov 2014 09:09:25 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pmtu calculation depends on the IP_DF bit in tnl_update_pmtu().
If the IP_DF bit is set, the pmtu calculation is based on the outer
packet size. Otherwise it is based on the inner packet size.
If xfrm is used after tunneling through an ipip device, the mtu of
the outer device can be lower than the mtu of the ipip device.
Reporting the mtu of the ipip device is wrong in this case. So
respect the IP_DF bit of the inner packet on ipv4 to report the
calculated mtu of the outer device.

Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---

I marked this as RFC because it affects the mtu calculation of
gre tunnels too. I think it should be ok, but I have no testcase
to confirm the correctness for gre tunnels. So would be good if
someone with gre knowlegde could look at this.

If it turns out that we can't do that for gre, we need to
split this code back into a gre and an ipip version.

 net/ipv4/ip_tunnel.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0bb8e14..f6f2d10 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -738,7 +738,11 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	if (tnl_update_pmtu(dev, skb, rt, tnl_params->frag_off)) {
+	df = tnl_params->frag_off;
+	if (skb->protocol == htons(ETH_P_IP))
+		df |= (inner_iph->frag_off&htons(IP_DF));
+
+	if (tnl_update_pmtu(dev, skb, rt, df)) {
 		ip_rt_put(rt);
 		goto tx_error;
 	}
@@ -767,10 +771,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 			ttl = ip4_dst_hoplimit(&rt->dst);
 	}
 
-	df = tnl_params->frag_off;
-	if (skb->protocol == htons(ETH_P_IP))
-		df |= (inner_iph->frag_off&htons(IP_DF));
-
 	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
 			+ rt->dst.header_len + ip_encap_hlen(&tunnel->encap);
 	if (max_headroom > dev->needed_headroom)
-- 
1.9.1
