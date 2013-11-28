From: Kamala R <kamala@aristanetworks.com>
Subject: [Patch v3] IPv6: Fixed support for blackhole and prohibit routes
Date: Thu, 28 Nov 2013 14:42:03 +0530
Message-ID: <1385629923-22920-1-git-send-email-kamala@aristanetwors.com>
Cc: linux-kernel@vger.kernel.org, Kamala R <kamala@aristanetworks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kamala R <kamala@aristanetworks.com>

The behaviour of blackhole and prohibit routes has been corrected by setting
the input and output pointers of the dst variable appropriately. For
blackhole routes, they are set to dst_discard and to ip6_pkt_discard and
ip6_pkt_discard_out respectively for prohibit routes.

Signed-off-by: Kamala R <kamala@aristanetworks.com>
---
 net/ipv6/route.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7faa9d5..97125c4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1565,21 +1565,24 @@ int ip6_route_add(struct fib6_config *cfg)
 				goto out;
 			}
 		}
-		rt->dst.output = ip6_pkt_discard_out;
-		rt->dst.input = ip6_pkt_discard;
 		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
 		switch (cfg->fc_type) {
 		case RTN_BLACKHOLE:
 			rt->dst.error = -EINVAL;
+			rt->dst.output = dst_discard;
+			rt->dst.input = dst_discard;
 			break;
 		case RTN_PROHIBIT:
 			rt->dst.error = -EACCES;
+			rt->dst.output = ip6_pkt_prohibit_out;
+			rt->dst.input = ip6_pkt_prohibit;
 			break;
 		case RTN_THROW:
-			rt->dst.error = -EAGAIN;
-			break;
 		default:
-			rt->dst.error = -ENETUNREACH;
+			rt->dst.error = (cfg->fc_type == RTN_THROW) ? -EAGAIN
+					: -ENETUNREACH;
+			rt->dst.output = ip6_pkt_discard_out;
+			rt->dst.input = ip6_pkt_discard;
 			break;
 		}
 		goto install_route;
-- 
1.7.9.5
