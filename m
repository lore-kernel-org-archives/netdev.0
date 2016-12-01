From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH net v2 1/3] ipv4: Set skb->protocol properly for local output
Date: Thu,  1 Dec 2016 10:05:10 +0800
Message-ID: <20161201020512.21661-1-elicooper@gmx.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:51735 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751673AbcLACHD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 21:07:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xfrm is applied to TSO/GSO packets, it follows this path:

    xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()

where skb_gso_segment() relies on skb->protocol to function properly.

This patch sets skb->protocol to ETH_P_IP before dst_output() is called,
fixing a bug where GSO packets sent through a sit tunnel are dropped
when xfrm is involved.

Cc: stable@vger.kernel.org
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
v2: place the assignment before the netfilter hook

 net/ipv4/ip_output.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 105908d..877bdb0 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -107,6 +107,8 @@ int __ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 	if (unlikely(!skb))
 		return 0;
 
+	skb->protocol = htons(ETH_P_IP);
+
 	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
 		       dst_output);
-- 
2.10.2
