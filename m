From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH net 1/2] Set skb->protocol properly before calling dst_output()
Date: Tue, 29 Nov 2016 10:35:28 +0800
Message-ID: <20161129023529.17645-1-elicooper@gmx.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:56744 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754387AbcK2Cfs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 21:35:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xfrm is applied to TSO/GSO packets, it follows this path:

    xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()

where skb_gso_segment() relies on skb->protocol to function properly.

This patch sets skb->protocol properly before dst_output() is called,
fixing a bug where GSO packets sent through a sit or ipip6 tunnel are
dropped when xfrm is involved.

Cc: stable@vger.kernel.org
Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
 net/ipv4/ip_output.c   | 4 +++-
 net/ipv6/output_core.c | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 105908d..0180e44 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -117,8 +117,10 @@ int ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 	int err;
 
 	err = __ip_local_out(net, sk, skb);
-	if (likely(err == 1))
+	if (likely(err == 1)) {
+		skb->protocol = htons(ETH_P_IP);
 		err = dst_output(net, sk, skb);
+	}
 
 	return err;
 }
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 7cca8ac..d6e850d 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -166,8 +166,10 @@ int ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 	int err;
 
 	err = __ip6_local_out(net, sk, skb);
-	if (likely(err == 1))
+	if (likely(err == 1)) {
+		skb->protocol = htons(ETH_P_IPV6);
 		err = dst_output(net, sk, skb);
+	}
 
 	return err;
 }
-- 
2.10.2
