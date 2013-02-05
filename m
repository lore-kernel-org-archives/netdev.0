From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next] ipv6: Don't send packet to big messages to self
Date: Tue, 5 Feb 2013 12:48:05 +0100
Message-ID: <20130205114804.GH23291@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55588 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130Ab3BELsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 06:48:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling icmpv6_send() on a local message size error leads to an
incorrect update of the path mtu in the case when IPsec is used.
So use ipv6_local_error() instead to notify the socket about the
error.

Reported-by: Jiri Bohac <jbohac@suse.cz>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_output.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7dea45a..14fee26 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -242,9 +242,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 			       dst->dev, dst_output);
 	}
 
-	net_dbg_ratelimited("IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
-	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+	ipv6_local_error(sk, EMSGSIZE, fl6, mtu);
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return -EMSGSIZE;
-- 
1.7.9.5
