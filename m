From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] vti6: Don't report path MTU below IPV6_MIN_MTU.
Date: Mon, 6 Mar 2017 07:57:28 +0100
Message-ID: <1488783448-12588-4-git-send-email-steffen.klassert@secunet.com>
References: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35464 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752772AbdCFG6P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 01:58:15 -0500
In-Reply-To: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vti6_xmit(), the check for IPV6_MIN_MTU before we
send a ICMPV6_PKT_TOOBIG message is missing. So we might
report a PMTU below 1280. Fix this by adding the required
check.

Fixes: ccd740cbc6e ("vti6: Add pmtu handling to vti6_xmit.")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d82042c..9156d6b 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -484,11 +484,15 @@ static bool vti6_state_check(const struct xfrm_state *x,
 	if (!skb->ignore_df && skb->len > mtu) {
 		skb_dst(skb)->ops->update_pmtu(dst, NULL, skb, mtu);
 
-		if (skb->protocol == htons(ETH_P_IPV6))
+		if (skb->protocol == htons(ETH_P_IPV6)) {
+			if (mtu < IPV6_MIN_MTU)
+				mtu = IPV6_MIN_MTU;
+
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		else
+		} else {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
+		}
 
 		return -EMSGSIZE;
 	}
-- 
1.9.1
