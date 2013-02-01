From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC] xfrm: fix pmtu discovery (kill xfrm6_update_pmtu)
Date: Fri, 1 Feb 2013 09:45:15 +0100
Message-ID: <20130201084515.GA29073@secunet.com>
References: <20130129144325.GB23396@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34978 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639Ab3BAIpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 03:45:17 -0500
Content-Disposition: inline
In-Reply-To: <20130129144325.GB23396@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2013 at 03:43:25PM +0100, Jiri Bohac wrote:
> Hi,
> 
> there is a problem in the xfrm PMTU discovery. This happens with
> IPv6, I'm not sure if the same applies to IPv4:
> 
> Let's have e.g. an ESP transport-mode policy mode between
> two endpoints: A and B. The ESP-encapsulated packets are sent
> over a router R:
> 	A <----> R <----> B
> and the R <----> B link has a small MTU of 1452.
> 
> R sends an ICMPV6_PKT_TOOBIG to A with MTU==1452.
> This is what then happens on A:
> 
> icmpv6_rcv() -> icmpv6_notify() -> esp6_err() -> ip6_update_pmtu()
> 
> This looks up the non-xfrm dst entry to host B (dst_B) and
> decreases its MTU to 1452
> 
> Next time a large TCP segment (len=1452 bytes including TCP/IP
> headers in this example) from A to B is created:
> 
> tcp_sendmsg() -> ... -> inet6_csk_xmit() -> ... -> xfrm_bundle_ok()
> 
> dst->child and xdst->route now point to the dst_B with MTU==1452
> xdst->route_mtu_cached and xdst->child_mtu_cached are both 1500,
> so the MTU of the xfrm bundle's dst (dst_B_xfrm) is decreased to 
> xfrm_state_mtu(dst_B_xfrm, 1452)==1414.
> 
> When the TCP segment reaches ip6_xmit:
> 	skb->len > dst_mtu(dst_B_xfrm)
> 	1452 > 1414
> This generates an ICMPV6_PKT_TOOBIG to self with MTU==1414.
> This is intended to reach the protocol error handler (decrease
> the MSS in the TCP case):

I think the above is the problem, we should not send packet to
big messages to ourselves. The reduced mtu is because of some
local reason (e.g. IPsec), it is not learned and therefore we
should not update the pmtu value.

You could try the patch below. I'm travelling this week, so I
can't do tests myself before monday.

Subject: [PATCH] ipv6: Don't send packet to big messages to self

Calling icmpv6_send() on a local message size error leads to an
incorrect update of the path mtu in the case when IPsec is used.
So use ipv6_local_error() instead to notify the socket about the
error.

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
