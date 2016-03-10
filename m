From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/5] vti: Fix recource leeks on pmtu discovery
Date: Thu, 10 Mar 2016 11:24:29 +0100
Message-ID: <1457605469-17332-6-git-send-email-steffen.klassert@secunet.com>
References: <1457605469-17332-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36665 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935309AbcCJKyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 05:54:15 -0500
In-Reply-To: <1457605469-17332-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent patch introduced pmtu handling directly in the
vti transmit routine. Unfortunately we now return without
releasing the dst_entry and freeing the sk_buff. This patch
fixes the issue.

Fixes: 325b71fe0f57 ("vti: Add pmtu handling to vti_xmit.")
Reported-by: Mark McKinstry <Mark.McKinstry@alliedtelesis.co.nz>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 6862305..2ea2b6e 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -206,7 +206,8 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 		else
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 
-		return -EMSGSIZE;
+		dst_release(dst);
+		goto tx_error;
 	}
 
 	err = dst_output(tunnel->net, skb->sk, skb);
-- 
1.9.1
