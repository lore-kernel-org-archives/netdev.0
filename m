From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH net-next] net/ipv6: update flowi6_oif in ip6_dst_lookup_flow if not set
Date: Wed, 15 Jul 2015 21:56:26 +0200
Message-ID: <1436990186-31586-1-git-send-email-phil@nwl.cc>
Cc: David Miller <davem@davemloft.net>, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:36788 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313AbbGOT42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 15:56:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newly created flows don't have flowi6_oif set (at least if the
associated socket is not interface-bound). This leads to a mismatch in
__xfrm6_selector_match() for policies which specify an interface in the
selector (sel->ifindex != 0).

Backtracing shows this happens in code-paths originating from e.g.
ip6_datagram_connect(), rawv6_sendmsg() or tcp_v6_connect(). (UDP was
not tested for.)

In summary, this patch fixes policy matching on outgoing interface for
locally generated packets.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/ipv6/ip6_output.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d5f7716..c5fc852 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1023,6 +1023,8 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 		return ERR_PTR(err);
 	if (final_dst)
 		fl6->daddr = *final_dst;
+	if (!fl6->flowi6_oif)
+		fl6->flowi6_oif = dst->dev->ifindex;
 
 	return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
-- 
2.1.2
