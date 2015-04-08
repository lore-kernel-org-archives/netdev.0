From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/2] ipv4: ip_tunnel: use net namespace from rtable not socket
Date: Wed,  8 Apr 2015 17:01:22 +0200
Message-ID: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
Cc: Rick Jones <rick.jones2@hp.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41157 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754109AbbDHPBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 11:01:30 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id C601020842
	for <netdev@vger.kernel.org>; Wed,  8 Apr 2015 11:01:25 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket parameter might legally be NULL, thus sock_net is sometimes
causing a NULL pointer dereference. Using net_device pointer in dst_entry
is more reliable.

Fixes: b6a7719aedd7e5c ("ipv4: hash net ptr into fragmentation bucket selection")
Reported-by: Rick Jones <rick.jones2@hp.com>
Cc: Rick Jones <rick.jones2@hp.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_tunnel_core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 8c4dcc4..ce63ab2 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -74,7 +74,8 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	iph->daddr	=	dst;
 	iph->saddr	=	src;
 	iph->ttl	=	ttl;
-	__ip_select_ident(sock_net(sk), iph, skb_shinfo(skb)->gso_segs ?: 1);
+	__ip_select_ident(dev_net(rt->dst.dev), iph,
+			  skb_shinfo(skb)->gso_segs ?: 1);
 
 	err = ip_local_out_sk(sk, skb);
 	if (unlikely(net_xmit_eval(err)))
-- 
2.1.0
