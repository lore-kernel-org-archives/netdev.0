From: Rajasekar Kumar <sekraj@gmail.com>
Subject: [RFC] net: ipv6: return the first matched rt6_info for multicast
 packets in find_rr_leaf()
Date: Wed, 18 Jan 2017 20:43:37 +0530
Message-ID: <20170118151337.mcub5vyjszy5ltyn@extreme-Latitude-E4310>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a performance issue when large number of interfaces are
enabled with VRRP protocol in 2 router nodes which are connected
to each other. When VRRP hello is received (which is multicast
packet with DIP: ff02::18), a rt6_info node is added to fib6_node
 of address ff02::18. This happens for each interface on which
VRRP is enabled. For 2000 interfaces with VRRP enabled, 2000
rt6_info nodes are added to the same fib6_node. As of today,
find_rr_leaf() goes further to find better match, even after first
successful match based on interface key. In this case, it walks
2000 nodes for every incoming packet/outgoing packet, which is
expensive and not needed. rt6_info match based on supplied
interface match should be sufficient. The first match occurs
when there is interface match, and after that there can not be
another match for multicast packets. So, first match should be
returned for multicast packets.

find_rr_leaf() tries to find best available gateway, mainly based on
interface match and gateway's reachablity info.When this is required
for unicast packets, multicast packets do not need either gateway's
reachability status or gateway's Layer2 address as it is derived
from Destination IP (group address). rt6_info match based on supplied
interface match should be sufficient.

This fix helps in scenario wherein multicast packets arrive in some
interfaces frequently than other interfaces. rt6_info is added to
beginning of list for former cases. Verified this case.

Signed-off-by: Rajasekar Kumar <sekraj@gmail.com>
---
	Changes from first mail:
		- Including netdev@vger.kernel.org, linux-kernel@vger.kernel.org to get review inputs/help
		- Changed the subject prefix to RFC from PATCH 
		- Amended commit message to include test scenario

 net/ipv6/route.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8417c41..609b543 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -703,6 +703,8 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 		}
 
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
+		if (match && ipv6_addr_is_multicast(&rt->rt6i_dst.addr))
+			return match;
 	}
 
 	for (rt = fn->leaf; rt && rt != rr_head; rt = rt->dst.rt6_next) {
@@ -712,13 +714,18 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 		}
 
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
+		if (match && ipv6_addr_is_multicast(&rt->rt6i_dst.addr))
+			return match;
 	}
 
 	if (match || !cont)
 		return match;
 
-	for (rt = cont; rt; rt = rt->dst.rt6_next)
+	for (rt = cont; rt; rt = rt->dst.rt6_next) {
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
+		if (match && ipv6_addr_is_multicast(&rt->rt6i_dst.addr))
+			return match;
+	}
 
 	return match;
 }
-- 
2.9.3
