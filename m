From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net] net: ipv4: Don't crash if passing a null sk to ip_do_redirect.
Date: Fri, 23 Dec 2016 00:33:57 +0900
Message-ID: <1482420837-30324-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34613 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756270AbcLVPeF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 10:34:05 -0500
Received: by mail-pf0-f182.google.com with SMTP id c4so40438334pfb.1
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 07:34:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e2d118a1cb5e ("net: inet: Support UID-based routing in IP
protocols.") made ip_do_redirect call sock_net(sk) to determine
the network namespace of the passed-in socket. This crashes if sk
is NULL.

Fix this by getting the network namespace from the skb instead.

Fixes: e2d118a1cb5e ("net: inet: Support UID-based routing in IP protocols.")
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fa5c037227..9eabf49013 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -798,6 +798,7 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 	struct rtable *rt;
 	struct flowi4 fl4;
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	struct net *net = dev_net(skb->dev);
 	int oif = skb->dev->ifindex;
 	u8 tos = RT_TOS(iph->tos);
 	u8 prot = iph->protocol;
@@ -805,7 +806,7 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 
 	rt = (struct rtable *) dst;
 
-	__build_flow_key(sock_net(sk), &fl4, sk, iph, oif, tos, prot, mark, 0);
+	__build_flow_key(net, &fl4, sk, iph, oif, tos, prot, mark, 0);
 	__ip_do_redirect(rt, skb, &fl4, true);
 }
 
-- 
2.8.0.rc3.226.g39d4020
