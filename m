From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: fix fragmentation for ipv4 xfrm tunnel
Date: Mon, 16 Jun 2008 14:59:46 +0200
Message-ID: <20080616125946.GE9886@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:38759 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077AbYFPNVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 09:21:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When generating the ip header for the transformed packet
we just copy the frag_off field of the ip header from the original packet
to the ip header of the new generated packet. If we receive a packet
as a chain of fragments, all but the last of the new generated packets
have the IP_MF flag set. We have to mask the frag_off field to only
keep the IP_DF flag from the original packet. This got lost with git commit

36cf9acf93e8561d9faec24849e57688a81eb9c5
[IPSEC]: Separate inner/outer mode processing on output

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_mode_tunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 584e6d7..7135279 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -52,7 +52,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 		IP_ECN_clear(top_iph);
 
 	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
-			    0 : XFRM_MODE_SKB_CB(skb)->frag_off;
+		0 : (XFRM_MODE_SKB_CB(skb)->frag_off & htons(IP_DF));
 	ip_select_ident(top_iph, dst->child, NULL);
 
 	top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
-- 
1.5.3

