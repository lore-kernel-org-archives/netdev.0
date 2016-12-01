From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH net v2 2/3] ipv6: Set skb->protocol properly for local output
Date: Thu,  1 Dec 2016 10:05:11 +0800
Message-ID: <20161201020512.21661-2-elicooper@gmx.com>
References: <20161201020512.21661-1-elicooper@gmx.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:52961 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755899AbcLACHD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 21:07:03 -0500
In-Reply-To: <20161201020512.21661-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xfrm is applied to TSO/GSO packets, it follows this path:

    xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()

where skb_gso_segment() relies on skb->protocol to function properly.

This patch sets skb->protocol to ETH_P_IPV6 before dst_output() is called,
fixing a bug where GSO packets sent through an ipip6 tunnel are dropped
when xfrm is involved.

Cc: stable@vger.kernel.org
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
v2: place the assignment before the netfilter hook

 net/ipv6/output_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 7cca8ac..cd42523 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -155,6 +155,8 @@ int __ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 	if (unlikely(!skb))
 		return 0;
 
+	skb->protocol = htons(ETH_P_IPV6);
+
 	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
 		       dst_output);
-- 
2.10.2
