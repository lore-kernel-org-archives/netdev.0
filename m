From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/10] ipvs: do not use random local source address for tunnels
Date: Thu, 23 Jul 2015 01:00:46 +0200
Message-ID: <1437606052-5179-5-git-send-email-pablo@netfilter.org>
References: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

Michael Vallaly reports about wrong source address used
in rare cases for tunneled traffic. Looks like
__ip_vs_get_out_rt in 3.10+ is providing uninitialized
dest_dst->dst_saddr.ip because ip_vs_dest_dst_alloc uses
kmalloc. While we retry after seeing EINVAL from routing
for data that does not look like valid local address, it
still succeeded when this memory was previously used from
other dests and with different local addresses. As result,
we can use valid local address that is not suitable for
our real server.

Fix it by providing 0.0.0.0 every time our cache is refreshed.
By this way we will get preferred source address from routing.

Reported-by: Michael Vallaly <lvs@nolatency.com>
Fixes: 026ace060dfe ("ipvs: optimize dst usage for real server")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b99d806..ec30d68 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -130,7 +130,6 @@ static struct rtable *do_output_route4(struct net *net, __be32 daddr,
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = daddr;
-	fl4.saddr = (rt_mode & IP_VS_RT_MODE_CONNECT) ? *saddr : 0;
 	fl4.flowi4_flags = (rt_mode & IP_VS_RT_MODE_KNOWN_NH) ?
 			   FLOWI_FLAG_KNOWN_NH : 0;
 
-- 
1.7.10.4

