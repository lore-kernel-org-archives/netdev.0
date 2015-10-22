From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] xfrm: Fix pmtu discovery for local generated packets.
Date: Thu, 22 Oct 2015 08:07:19 +0200
Message-ID: <1445494039-2612-5-git-send-email-steffen.klassert@secunet.com>
References: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50536 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383AbbJVGH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 02:07:29 -0400
In-Reply-To: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 044a832a777 ("xfrm: Fix local error reporting crash
with interfamily tunnels") moved the setting of skb->protocol
behind the last access of the inner mode family to fix an
interfamily crash. Unfortunately now skb->protocol might not
be set at all, so we fail dispatch to the inner address family.
As a reault, the local error handler is not called and the
mtu value is not reported back to userspace.

We fix this by setting skb->protocol on message size errors
before we call xfrm_local_error.

Fixes: 044a832a7779c ("xfrm: Fix local error reporting crash with interfamily tunnels")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_output.c | 2 ++
 net/ipv6/xfrm6_output.c | 1 +
 2 files changed, 3 insertions(+)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 2878dbf..41a2613 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -30,6 +30,8 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 
 	mtu = dst_mtu(skb_dst(skb));
 	if (skb->len > mtu) {
+		skb->protocol = htons(ETH_P_IP);
+
 		if (skb->sk)
 			xfrm_local_error(skb, mtu);
 		else
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index be033f2..e15feb7 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -79,6 +79,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 
 	if (!skb->ignore_df && skb->len > mtu) {
 		skb->dev = dst->dev;
+		skb->protocol = htons(ETH_P_IPV6);
 
 		if (xfrm6_local_dontfrag(skb))
 			xfrm6_local_rxpmtu(skb, mtu);
-- 
1.9.1
