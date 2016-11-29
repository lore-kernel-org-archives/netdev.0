From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: ipv4: Don't crash if passing a null sk to ip_rt_update_pmtu.
Date: Wed, 30 Nov 2016 02:56:47 +0900
Message-ID: <1480442207-43618-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, erezsh@dev.mellanox.co.il,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33022 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753150AbcK2R4y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:56:54 -0500
Received: by mail-pg0-f44.google.com with SMTP id 3so71878989pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:56:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e2d118a1cb5e ("net: inet: Support UID-based routing in IP
protocols.") made __build_flow_key call sock_net(sk) to determine
the network namespace of the passed-in socket. This crashes if sk
is NULL.

Fix this by getting the network namespace from the skb instead.

Reported-by: Erez Shitrit <erezsh@dev.mellanox.co.il>
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d37fc6f..6402d74 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -531,13 +531,14 @@ static void __build_flow_key(const struct net *net, struct flowi4 *fl4,
 static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
 			       const struct sock *sk)
 {
+	const struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph = ip_hdr(skb);
 	int oif = skb->dev->ifindex;
 	u8 tos = RT_TOS(iph->tos);
 	u8 prot = iph->protocol;
 	u32 mark = skb->mark;
 
-	__build_flow_key(sock_net(sk), fl4, sk, iph, oif, tos, prot, mark, 0);
+	__build_flow_key(net, fl4, sk, iph, oif, tos, prot, mark, 0);
 }
 
 static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
-- 
2.8.0.rc3.226.g39d4020
