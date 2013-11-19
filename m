From: Kamala R <kamala@aristanetworks.com>
Subject: [PATCH 1/1] IPv6: Fixed support for blackhole and prohibit routes
Date: Tue, 19 Nov 2013 22:19:33 +0530
Message-ID: <1384879773-8800-1-git-send-email-kamala@aristanetwors.com>
Cc: linux-kernel@vger.kernel.org, Kamala R <kamala@aristanetworks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kamala R <kamala@aristanetworks.com>

The behaviour of blackhole and prohibit routes has been corrected by setting the input and output
function pointers of the dst variable appropriately. For blackhole routes, they are set to
dst_discard and for prohibit routes they are set to ip6_pkt_prohibit and ip6_pkt_prohbit_out
respectively.

Signed-off-by: Kamala R <kamala@aristanetworks.com>
---
 net/ipv6/route.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f54e3a1..f2289fd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1564,21 +1564,25 @@ int ip6_route_add(struct fib6_config *cfg)
 				goto out;
 			}
 		}
-		rt->dst.output = ip6_pkt_discard_out;
-		rt->dst.input = ip6_pkt_discard;
+
 		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
+		rt->dst.error = (cfg->fc_type == RTN_BLACKHOLE) ? -EINVAL
+				: ((cfg->fc_type == RTN_PROHIBIT ? -EACCES
+				: ((cfg->fc_type == RTN_THROW ? -EAGAIN
+				: -ENETUNREACH))));
 		switch (cfg->fc_type) {
 		case RTN_BLACKHOLE:
-			rt->dst.error = -EINVAL;
+			rt->dst.output = dst_discard;
+			rt->dst.input = dst_discard;
 			break;
 		case RTN_PROHIBIT:
-			rt->dst.error = -EACCES;
+			rt->dst.output = ip6_pkt_prohibit_out;
+			rt->dst.input = ip6_pkt_prohibit;
 			break;
 		case RTN_THROW:
-			rt->dst.error = -EAGAIN;
-			break;
 		default:
-			rt->dst.error = -ENETUNREACH;
+			rt->dst.output = ip6_pkt_discard_out;
+			rt->dst.input = ip6_pkt_discard;
 			break;
 		}
 		goto install_route;
-- 
1.7.9.5
