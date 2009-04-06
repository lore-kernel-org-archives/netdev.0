From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: fix fragmentation on inter family tunnels
Date: Mon, 6 Apr 2009 15:58:50 +0200
Message-ID: <20090406135850.GK6791@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:42184 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755415AbZDFOUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 10:20:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an ipv4 packet (not locally generated with IP_DF flag not set) bigger
than mtu size is supposed to go via a xfrm ipv6 tunnel, the packetsize
check in xfrm4_tunnel_check_size() is omited and ipv6 drops the packet
without sending a notice to the original sender of the ipv4 packet.

Another issue is that ipv4 connection tracking does reassembling of
incomming fragmented packets. If such a reassembled packet is supposed to
go via a xfrm ipv6 tunnel it will be droped, even if the original sender
did proper fragmentation.

According to RFC 2473 (section 7) tunnel ipv6 packets resulting from the
encapsulation of an original packet are considered as locally generated
packets. If such a packet passed the checks in xfrm{4,6}_tunnel_check_size()
fragmentation is allowed according to RFC 2473 (section 7.1/7.2).

This patch sets skb->local_df in xfrm6_prepare_output() to achieve
fragmentation in this case.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_output.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 0af823c..5ee5a03 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -72,6 +72,7 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 #endif
 
 	skb->protocol = htons(ETH_P_IPV6);
+	skb->local_df = 1;
 
 	return x->outer_mode->output2(x, skb);
 }
-- 
1.5.4.2

