From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] xfrm4: Don't call icmp_send on local error
Date: Thu, 30 Jun 2011 11:20:41 +0200
Message-ID: <20110630092041.GD13201@secunet.com>
References: <20110630091820.GB13201@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51328 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637Ab1F3JUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 05:20:03 -0400
Content-Disposition: inline
In-Reply-To: <20110630091820.GB13201@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling icmp_send() on a local message size error leads to
an incorrect update of the path mtu. So use ip_local_error()
instead to notify the socket about the error.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_output.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 2d51840..327a617 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -32,7 +32,12 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	dst = skb_dst(skb);
 	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
+		if (skb->sk)
+			ip_local_error(skb->sk, EMSGSIZE, ip_hdr(skb)->daddr,
+				       inet_sk(skb->sk)->inet_dport, mtu);
+		else
+			icmp_send(skb, ICMP_DEST_UNREACH,
+				  ICMP_FRAG_NEEDED, htonl(mtu));
 		ret = -EMSGSIZE;
 	}
 out:
-- 
1.7.0.4

