From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] xfrm6: Fix the nexthdr offset in _decode_session6.
Date: Mon, 26 Jan 2015 08:48:23 +0100
Message-ID: <1422258503-26978-3-git-send-email-steffen.klassert@secunet.com>
References: <1422258503-26978-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34914 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbbAZHse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 02:48:34 -0500
In-Reply-To: <1422258503-26978-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_decode_session() was originally designed for the
usage in the receive path where the correct nexthdr offset
is stored in IP6CB(skb)->nhoff. Over time this function
spread to code that is used in the output path (netfilter,
vti) where IP6CB(skb)->nhoff is not set. As a result, we
get a wrong nexthdr and the upper layer flow informations
are wrong. This can leed to incorrect policy lookups.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_policy.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index aa48302..48bf5a0 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -134,8 +134,14 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	u16 offset = sizeof(*hdr);
 	struct ipv6_opt_hdr *exthdr;
 	const unsigned char *nh = skb_network_header(skb);
-	u8 nexthdr = nh[IP6CB(skb)->nhoff];
+	u16 nhoff = IP6CB(skb)->nhoff;
 	int oif = 0;
+	u8 nexthdr;
+
+	if (!nhoff)
+		nhoff = offsetof(struct ipv6hdr, nexthdr);
+
+	nexthdr = nh[nhoff];
 
 	if (skb_dst(skb))
 		oif = skb_dst(skb)->dev->ifindex;
-- 
1.9.1
