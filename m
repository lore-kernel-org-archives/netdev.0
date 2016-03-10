From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] vti6: Fix dst_entry leek on pmtu discovery
Date: Thu, 10 Mar 2016 11:24:28 +0100
Message-ID: <1457605469-17332-5-git-send-email-steffen.klassert@secunet.com>
References: <1457605469-17332-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36662 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935307AbcCJKyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 05:54:15 -0500
In-Reply-To: <1457605469-17332-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We may exit without releasing the dst_entry on pmtu discovery,
so don't return directly but goto the te error handling. This
also makes sure that the statistic counter gets updated.

Fixes: ccd740cbc6e0 ("vti6: Add pmtu handling to vti6_xmit.")
Reported-by: Mark McKinstry <Mark.McKinstry@alliedtelesis.co.nz>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 0a8610b..555ac2b 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -479,7 +479,8 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 
-		return -EMSGSIZE;
+		err = -EMSGSIZE;
+		goto tx_err_dst_release;
 	}
 
 	err = dst_output(t->net, skb->sk, skb);
-- 
1.9.1
