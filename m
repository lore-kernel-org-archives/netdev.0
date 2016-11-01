From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH net v3 1/2] ip6_tunnel: Clear IP6CB in ip6tunnel_xmit()
Date: Tue,  1 Nov 2016 23:45:12 +0800
Message-ID: <20161101154513.30347-1-elicooper@gmx.com>
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:55031 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750712AbcKAPpc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 11:45:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->cb may contain data from previous layers. In the observed scenario,
the garbage data were misinterpreted as IP6CB(skb)->frag_max_size, so
that small packets sent through the tunnel are mistakenly fragmented.

This patch unconditionally clears the control buffer in ip6tunnel_xmit(),
which affects ip6_tunnel, ip6_udp_tunnel and ip6_gre. Currently none of
these tunnels set IP6CB(skb)->flags, otherwise it needs to be done earlier.

Cc: stable@vger.kernel.org
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
v3: moves to ip6tunnel_xmit() and clears IP6CB unconditionally
v2: clears the whole IP6CB altogether and does it after encapsulation

 include/net/ip6_tunnel.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 20ed969..1b1cf33 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -146,6 +146,7 @@ static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 {
 	int pkt_len, err;
 
+	memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 	pkt_len = skb->len - skb_inner_network_offset(skb);
 	err = ip6_local_out(dev_net(skb_dst(skb)->dev), sk, skb);
 	if (unlikely(net_xmit_eval(err)))
-- 
2.10.1
